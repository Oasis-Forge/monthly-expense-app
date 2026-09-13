import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/trash_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;

  setUp(() async {
    fake = FakeDB(
      transactions: [
        testTx(
          'a',
          TransactionType.expense,
          12.5,
          DateTime(2026, 9, 10),
          title: 'Lunch',
        ).copyWith(deletedAt: DateTime.utc(2026, 9, 14)),
      ],
    );
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15, 12),
    );
    await provider.load();
  });

  Future<void> showTrash(WidgetTester tester) async {
    final settings = await testSettings();
    await tester.pumpWidget(testApp(provider, settings, const TrashScreen()));
    await tester.pump();
  }

  testWidgets('restoring takes a transaction out of the trash (DEL-4)', (
    tester,
  ) async {
    await showTrash(tester);

    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('\$12.50 · deleted for good in 29 days'), findsOneWidget);

    await tester.tap(find.byTooltip('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Trash is empty.'), findsOneWidget);
    expect(provider.transactions.single.id, 'a');
    expect(provider.transactions.single.date, DateTime(2026, 9, 10));
  });

  testWidgets('a failed restore keeps the item and shows an error', (
    tester,
  ) async {
    await showTrash(tester);
    fake.failWrites = true;

    await tester.tap(find.byTooltip('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsOneWidget);
    expect(
      find.text("Couldn't restore the transaction. Try again."),
      findsOneWidget,
    );
  });
}
