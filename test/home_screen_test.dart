import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 15, 10);
  late FakeDB fake;
  late TransactionProvider provider;

  setUp(() async {
    fake = FakeDB(
      transactions: [
        testTx(
          'a',
          TransactionType.expense,
          12.5,
          DateTime(2026, 9, 15),
          title: 'Lunch',
        ),
        testTx(
          'b',
          TransactionType.expense,
          40,
          DateTime(2026, 9, 18),
          title: 'Concert',
        ),
      ],
    );
    provider = TransactionProvider(db: fake, clock: () => today);
    await provider.load();
  });

  Future<void> showHome(WidgetTester tester) async {
    await tester.pumpWidget(testApp(provider, const HomeScreen()));
    await tester.pump();
  }

  testWidgets('future-dated rows are marked upcoming and not counted', (
    tester,
  ) async {
    await showHome(tester);

    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Food · Upcoming'), findsOneWidget);
    // The expense total is only lunch; the concert hasn't happened yet.
    expect(find.text('\$12.50'), findsOneWidget);
  });

  testWidgets('swiping a row soft-deletes the transaction', (tester) async {
    await showHome(tester);
    await tester.drag(find.text('Lunch'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsNothing);
    expect([for (final t in provider.transactions) t.id], ['b']);
    expect(fake.rows.firstWhere((t) => t.id == 'a').deletedAt, isNotNull);
  });

  testWidgets('a failed swipe delete keeps the row and shows an error', (
    tester,
  ) async {
    fake.failWrites = true;

    await showHome(tester);
    await tester.drag(find.text('Lunch'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.transactions, hasLength(2));
    expect(
      find.text("Couldn't delete the transaction. Try again."),
      findsOneWidget,
    );
  });
}
