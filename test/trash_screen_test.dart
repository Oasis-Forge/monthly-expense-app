import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
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

  testWidgets('a deleted transfer is in the trash too, and restores (DEL-5)', (
    tester,
  ) async {
    fake.accounts.add(testAccount('bank'));
    fake.transfers.add(
      testTransfer(
        't',
        Account.cashId,
        'bank',
        50,
        DateTime(2026, 9, 12),
      ).copyWith(deletedAt: DateTime.utc(2026, 9, 15, 9)),
    );
    await provider.load();

    await showTrash(tester);

    expect(find.text('acc-cash → bank'), findsOneWidget);
    expect(find.text('\$50 · deleted for good in 30 days'), findsOneWidget);

    await tester.tap(find.byTooltip('Restore').first);
    await tester.pumpAndSettle();

    expect(provider.transfers.single.id, 't');
    expect(provider.deletedTransfers, isEmpty);
  });

  testWidgets('the trash lists what was deleted last, first (DEL-5)', (
    tester,
  ) async {
    fake.accounts.add(testAccount('bank'));
    fake.transfers.add(
      testTransfer(
        't',
        Account.cashId,
        'bank',
        50,
        DateTime(2026, 9, 12),
      ).copyWith(deletedAt: DateTime.utc(2026, 9, 15, 9)),
    );
    await provider.load();

    await showTrash(tester);

    // The transfer went at 9am on the 15th, the lunch a day earlier.
    final rows = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(rows, hasLength(2));
    expect(
      ((rows.first.title as Text).data, (rows.last.title as Text).data),
      ('acc-cash → bank', 'Lunch'),
    );
  });

  testWidgets('a failed transfer restore keeps it and says so (DEL-5)', (
    tester,
  ) async {
    fake.accounts.add(testAccount('bank'));
    fake.transfers.add(
      testTransfer(
        't',
        Account.cashId,
        'bank',
        50,
        DateTime(2026, 9, 12),
      ).copyWith(deletedAt: DateTime.utc(2026, 9, 15, 9)),
    );
    await provider.load();
    await showTrash(tester);
    fake.failWrites = true;

    await tester.tap(find.byTooltip('Restore').first);
    await tester.pumpAndSettle();

    expect(find.text('acc-cash → bank'), findsOneWidget);
    expect(
      find.text("Couldn't restore the transfer. Try again."),
      findsOneWidget,
    );
  });

  testWidgets('an empty trash says so, with nothing of either kind', (
    tester,
  ) async {
    provider = TransactionProvider(
      db: FakeDB(),
      clock: () => DateTime(2026, 9, 15, 12),
    );
    await provider.load();

    await showTrash(tester);

    expect(find.text('Trash is empty.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('a note deleted before a reload can be found in the trash, and '
      'restored (NOTE-7, DEL-5)', (tester) async {
    final notesDb = FakeDB(notes: [testNote('n1', 'Pay rent')]);
    provider = TransactionProvider(
      db: notesDb,
      clock: () => DateTime(2026, 9, 15, 12),
    );
    await provider.load();
    await provider.deleteNote('n1');

    // Simulate the app relaunching: a fresh provider loading from the same
    // database, the way the failure scenario describes ("the process is
    // dead"), rather than the note only surviving via the Undo snackbar.
    provider = TransactionProvider(
      db: notesDb,
      clock: () => DateTime(2026, 9, 15, 12),
    );
    await provider.load();

    await showTrash(tester);

    expect(find.text('Pay rent'), findsOneWidget);

    await tester.tap(find.byTooltip('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Trash is empty.'), findsOneWidget);
    expect(provider.deletedNotes, isEmpty);
    expect(provider.noteById('n1'), isNotNull);
  });

  testWidgets('a failed note restore keeps it and says so (NOTE-7)', (
    tester,
  ) async {
    final notesDb = FakeDB(
      notes: [
        testNote(
          'n1',
          'Pay rent',
        ).copyWith(deletedAt: DateTime.utc(2026, 9, 14)),
      ],
    );
    provider = TransactionProvider(
      db: notesDb,
      clock: () => DateTime(2026, 9, 15, 12),
    );
    await provider.load();
    await showTrash(tester);
    notesDb.failWrites = true;

    await tester.tap(find.byTooltip('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.text("Couldn't restore the note. Try again."), findsOneWidget);
  });
}
