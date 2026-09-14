import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/backup_screen.dart';
import 'package:monthly_expense_app/screens/import_screen.dart';

import 'helpers.dart';

void main() {
  const cash = Account.cashId;
  final today = DateTime(2026, 9, 15, 10);

  late FakeDB db;
  late FakeBackupFiles files;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    db = FakeDB(accounts: [testAccount(cash), testAccount('acc-bank')]);
    files = FakeBackupFiles();
    provider = TransactionProvider(db: db, clock: () => today);
    await provider.load();
    settings = await testSettings();
  });

  /// Puts [csv] behind the file dialog.
  void fileHolds(String csv) => files.toOpen = utf8.encode(csv);

  /// Opens the import screen the way the app does, from Backup & restore
  /// (IMP-1), so what it says on the way back has somewhere to land.
  Future<void> openImport(WidgetTester tester) async {
    // The preview is one long page; a tall window keeps all of it built, so
    // the tests can look at any part of it without scrolling first.
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        const BackupScreen(),
        backup: testBackupService(db, files: files),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import a CSV'));
    await tester.pumpAndSettle();
  }

  /// Opens the screen and picks the file waiting in [files].
  Future<void> pickFile(WidgetTester tester) async {
    await openImport(tester);
    await tester.tap(find.text('Choose a file'));
    await tester.pumpAndSettle();
  }

  testWidgets('nothing is written until the user confirms (IMP-5)', (
    tester,
  ) async {
    fileHolds(
      'date,amount,type,title\n'
      '2026-09-01,12.50,expense,Coffee\n'
      '2026-09-02,900,income,Pay\n',
    );
    await pickFile(tester);

    expect(find.text('2 rows will be imported'), findsOne);
    expect(find.textContaining('Coffee'), findsOne);
    expect(provider.transactions, isEmpty);

    await tester.tap(find.text('Import 2 rows'));
    await tester.pumpAndSettle();

    expect(provider.transactions, hasLength(2));
    expect(find.text('2 records imported'), findsOne);
  });

  testWidgets('the columns it matched are shown and can be corrected '
      '(IMP-3)', (tester) async {
    fileHolds('when,value,memo\n2026-09-01,12.50,Coffee\n');
    await pickFile(tester);

    // "when" and "value" are known names for the two columns a file needs;
    // "memo" reads as a note, which isn't where this file's text belongs.
    expect(
      find.widgetWithText(DropdownButtonFormField<int?>, 'Date'),
      findsOne,
    );
    expect(find.text('when'), findsOne);
    expect(find.text('value'), findsOne);

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<int?>, 'Title'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('memo').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();

    expect(provider.transactions.single.title, 'Coffee');
    expect(provider.transactions.single.note, isNull);
  });

  testWidgets('a column can be turned off again (IMP-3)', (tester) async {
    fileHolds('date,amount,type,note\n2026-09-01,5,expense,private\n');
    await pickFile(tester);

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<int?>, 'Note'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not used').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();

    expect(provider.transactions.single.note, isNull);
  });

  testWidgets('a long file shows the first rows and says how many more '
      '(IMP-5)', (tester) async {
    fileHolds(
      [
        'date,amount,type,title',
        for (var day = 1; day <= 12; day++)
          '2026-09-${day.toString().padLeft(2, '0')},$day,expense,Row $day',
      ].join('\n'),
    );
    await pickFile(tester);

    expect(find.textContaining('Row 8'), findsOne);
    expect(find.textContaining('Row 9'), findsNothing);
    expect(find.text('and 4 more'), findsOne);
  });

  testWidgets('a file with no date column is refused, and can be fixed '
      '(IMP-4)', (tester) async {
    fileHolds('xyzzy,amount\n2026-09-01,12.50\n');
    await pickFile(tester);

    expect(
      find.textContaining('No column in that file could be read as a date'),
      findsOne,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Nothing to import'),
    );
    expect(button.onPressed, isNull);

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<int?>, 'Date'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('xyzzy').last);
    await tester.pumpAndSettle();

    expect(find.text('1 row will be imported'), findsOne);
    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();
    expect(provider.transactions.single.date, DateTime(2026, 9, 1));
  });

  testWidgets('every skipped row is counted and given a reason (IMP-5)', (
    tester,
  ) async {
    fileHolds(
      'date,amount,type,title\n'
      '2026-09-01,12.50,expense,Coffee\n'
      'sometime,3,expense,Tea\n'
      '2026-09-03,nothing,expense,Cake\n'
      '2026-09-04,0,expense,Free\n',
    );
    await pickFile(tester);

    expect(find.text('1 row will be imported'), findsOne);
    expect(find.text("1 row has a date the app can't read"), findsAtLeast(1));
    expect(
      find.text("1 row has an amount the app can't read"),
      findsAtLeast(1),
    );
    expect(find.text('1 row is for no money at all'), findsAtLeast(1));
    // The unreadable cell is shown as written, so the user can find it.
    expect(find.text('sometime · Tea'), findsOne);
  });

  testWidgets('the date order can be changed when the file is ambiguous '
      '(IMP-6)', (tester) async {
    fileHolds('date,amount,type\n03/04/2026,5,expense\n');
    await pickFile(tester);

    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();
    expect(provider.transactions.single.date, DateTime(2026, 4, 3));

    await tester.pumpAndSettle();
  });

  testWidgets('month first reads the same file the other way (IMP-6)', (
    tester,
  ) async {
    fileHolds('date,amount,type\n03/04/2026,5,expense\n');
    await pickFile(tester);

    await tester.tap(find.text('Month first'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();

    expect(provider.transactions.single.date, DateTime(2026, 3, 4));
  });

  testWidgets('a name the app has not got is mapped on the preview '
      '(IMP-7)', (tester) async {
    fileHolds(
      'date,amount,type,category,account\n'
      '2026-09-01,5,expense,Eating out,Savings\n',
    );
    await pickFile(tester);

    expect(find.text("Names this app hasn't got"), findsOne);
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Eating out'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Savings'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('acc-bank').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();

    final tx = provider.transactions.single;
    expect(tx.categoryId, 'cat-food');
    expect(tx.accountId, 'acc-bank');
    expect(provider.categories.where((c) => c.name == 'Eating out'), isEmpty);
  });

  testWidgets('a name the app does have is used without asking (IMP-3)', (
    tester,
  ) async {
    fileHolds('date,amount,type,category\n2026-09-01,5,expense,Rent\n');
    await pickFile(tester);

    expect(find.text("Names this app hasn't got"), findsNothing);
    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();

    expect(provider.transactions.single.categoryId, 'cat-rent');
  });

  testWidgets('importing the same file twice adds nothing the second time '
      '(IMP-8)', (tester) async {
    const csv = 'date,amount,type,title\n2026-09-01,12.50,expense,Coffee\n';
    fileHolds(csv);
    await pickFile(tester);
    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();
    expect(provider.transactions, hasLength(1));

    fileHolds(csv);
    await pickFile(tester);

    expect(find.text('1 row is already in the app'), findsAtLeast(1));
    expect(find.text('Nothing will be imported'), findsOne);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Nothing to import'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('this app\'s own export reads back whole (IMP-2)', (
    tester,
  ) async {
    fileHolds(
      'Date,Type,Amount,Currency,Category,Account,To account,Title,Note\n'
      '2026-09-01,expense,12.50,USD,Food,acc-cash,,Coffee,black\n'
      '2026-09-02,transfer,100.00,USD,,acc-cash,acc-bank,,moved\n',
    );
    await pickFile(tester);

    expect(find.text("Names this app hasn't got"), findsNothing);
    await tester.tap(find.text('Import 2 rows'));
    await tester.pumpAndSettle();

    final tx = provider.transactions.single;
    expect(
      (tx.title, tx.note, tx.categoryId, tx.accountId),
      ('Coffee', 'black', 'cat-food', cash),
    );
    expect(tx.amount, const Money(12500));
    expect(tx.type, TransactionType.expense);
    final transfer = provider.transfers.single;
    expect((transfer.fromAccountId, transfer.toAccountId), (cash, 'acc-bank'));
    expect(transfer.amount, const Money(100000));
  });

  testWidgets('a failed write says so and adds nothing', (tester) async {
    fileHolds('date,amount,type\n2026-09-01,5,expense\n');
    await pickFile(tester);
    db.failWrites = true;

    await tester.tap(find.text('Import 1 row'));
    await tester.pumpAndSettle();

    expect(
      find.text('Couldn\'t import that file. Nothing was added.'),
      findsOne,
    );
    expect(provider.transactions, isEmpty);
    expect(find.byType(ImportScreen), findsOne);
  });

  testWidgets('a file that cannot be read says so', (tester) async {
    files.fail = true;
    await openImport(tester);

    await tester.tap(find.text('Choose a file'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't read that file. Try again."), findsOne);
    expect(find.text('Choose a file'), findsOne);
  });

  testWidgets('cancelling the dialog leaves the screen as it was', (
    tester,
  ) async {
    files.toOpen = null;
    await openImport(tester);

    await tester.tap(find.text('Choose a file'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a file'), findsOne);
    expect(find.text('Columns'), findsNothing);
  });

  testWidgets('Backup & restore opens it (IMP-1)', (tester) async {
    await openImport(tester);

    expect(find.byType(ImportScreen), findsOne);
    expect(find.text('Choose a file'), findsOne);
  });
}
