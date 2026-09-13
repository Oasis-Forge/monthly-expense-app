import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 15, 10);
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

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
    settings = await testSettings();
  });

  Future<void> showHome(WidgetTester tester) async {
    await tester.pumpWidget(testApp(provider, settings, const HomeScreen()));
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

  testWidgets('amounts use the chosen currency (CUR-2)', (tester) async {
    settings = await testSettings({'currency_code': 'EUR'});

    await showHome(tester);

    expect(find.text('€12.50'), findsOneWidget);
  });

  testWidgets('swiping a row moves it to the trash with Undo (DEL-2)', (
    tester,
  ) async {
    await showHome(tester);
    await tester.drag(find.text('Lunch'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsNothing);
    expect(provider.deletedTransactions.single.id, 'a');
    expect(find.text('Transaction deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.deletedTransactions, isEmpty);
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
