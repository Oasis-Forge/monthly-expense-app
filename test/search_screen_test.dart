import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/search_screen.dart';
import 'package:monthly_expense_app/screens/transaction_row_menu.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    fake = FakeDB(
      accounts: [testAccount(Account.cashId), testAccount('bank')],
      transactions: [
        testTx(
          'lunch',
          TransactionType.expense,
          12.5,
          DateTime(2026, 9, 10),
          title: 'Café lunch',
        ),
        testTx(
          'rent',
          TransactionType.expense,
          900,
          DateTime(2026, 9, 1),
          title: 'Flat',
          categoryId: 'cat-rent',
        ).copyWith(accountId: 'bank'),
        testTx(
          'pay',
          TransactionType.income,
          2000,
          DateTime(2026, 8, 30),
          title: 'Salary',
        ),
      ],
    );
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings();
  });

  Future<void> showSearch(WidgetTester tester, {String? language}) async {
    if (language != null) settings = await testSettings({'language': language});
    await tester.pumpWidget(testApp(provider, settings, const SearchScreen()));
    await tester.pump();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).first, text);
    await tester.pump();
  }

  Future<void> choose(WidgetTester tester, int dropdown, String item) async {
    await tester.tap(find.byType(DropdownButton<String?>).at(dropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  testWidgets('typing narrows the results and their totals (SRCH-1, SRCH-3)', (
    tester,
  ) async {
    await showSearch(tester);
    expect(
      find.text('3 results · Income \$2,000 · Expense \$912.50'),
      findsOneWidget,
    );

    await type(tester, 'cafe');

    expect(find.text('Café lunch'), findsOneWidget);
    expect(find.text('Flat'), findsNothing);
    expect(
      find.text('1 result · Income \$0 · Expense \$12.50'),
      findsOneWidget,
    );
  });

  testWidgets('type, category, and account filters combine (SRCH-2)', (
    tester,
  ) async {
    await showSearch(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Income'));
    await tester.pump();
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Flat'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pump();
    await choose(tester, 0, '🏠 Rent');
    expect(find.text('Flat'), findsOneWidget);
    expect(find.text('Café lunch'), findsNothing);

    await choose(tester, 0, 'All categories');
    await choose(tester, 1, 'acc-cash');
    expect(find.text('Café lunch'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Flat'), findsNothing);
  });

  testWidgets('a date range narrows the results until it is cleared', (
    tester,
  ) async {
    await showSearch(tester);

    // The filter row scrolls sideways; bring the date chip into view.
    await tester.ensureVisible(find.text('All time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All time'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Start Date'),
      '09/01/2026',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'End Date'),
      '09/10/2026',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Sep 1 – Sep 10'), findsOneWidget);
    expect(find.text('Café lunch'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Clear dates'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear dates'));
    await tester.pump();

    expect(find.text('All time', skipOffstage: false), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
  });

  testWidgets(
    'a date range can start before 2015 when older records exist, and '
    'finds them (SRCH-2, rules-1-5#12)',
    (tester) async {
      final oldFake = FakeDB(
        accounts: [testAccount(Account.cashId)],
        transactions: [
          testTx(
            'old',
            TransactionType.expense,
            40,
            DateTime(2012, 3, 4),
            title: 'Old expense',
          ),
          testTx(
            'new',
            TransactionType.expense,
            10,
            DateTime(2026, 9, 10),
            title: 'New expense',
          ),
        ],
      );
      final oldProvider = TransactionProvider(
        db: oldFake,
        clock: () => DateTime(2026, 9, 15),
      );
      await oldProvider.load();

      await tester.pumpWidget(
        testApp(oldProvider, settings, const SearchScreen()),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('All time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All time'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Start Date'),
        '03/01/2012',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'End Date'),
        '03/10/2012',
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // A fixed firstDate of 2015 would have rejected 03/01/2012 as out of
      // range and left the range unset; SRCH-2 says a date range must be
      // able to reach every record. The chip and results below prove the
      // range was accepted instead.
      expect(find.text('Mar 1 – Mar 10'), findsOneWidget);
      expect(find.text('Old expense'), findsOneWidget);
      expect(find.text('New expense'), findsNothing);
    },
  );

  testWidgets(
    'a date range can end after 2100 when a future-dated record exists, '
    'and finds it (SRCH-2, rules-1-5#12)',
    (tester) async {
      final futureFake = FakeDB(
        accounts: [testAccount(Account.cashId)],
        transactions: [
          testTx(
            'future',
            TransactionType.expense,
            15,
            DateTime(2101, 6, 1),
            title: 'Future expense',
          ),
          testTx(
            'current',
            TransactionType.expense,
            10,
            DateTime(2026, 9, 10),
            title: 'Current expense',
          ),
        ],
      );
      final futureProvider = TransactionProvider(
        db: futureFake,
        clock: () => DateTime(2026, 9, 15),
      );
      await futureProvider.load();

      await tester.pumpWidget(
        testApp(futureProvider, settings, const SearchScreen()),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('All time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All time'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Start Date'),
        '05/25/2101',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'End Date'),
        '06/05/2101',
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('May 25 – Jun 5'), findsOneWidget);
      expect(find.text('Future expense'), findsOneWidget);
      expect(find.text('Current expense'), findsNothing);
    },
  );

  testWidgets('reopening the range picker after the record that widened it is '
      'deleted does not crash, and keeps the picked range (SRCH-2, '
      'rules-1-5#12)', (tester) async {
    final oldFake = FakeDB(
      accounts: [testAccount(Account.cashId)],
      transactions: [
        testTx(
          'old2012',
          TransactionType.expense,
          40,
          DateTime(2012, 3, 4),
          title: 'Old expense',
        ),
      ],
    );
    final oldProvider = TransactionProvider(
      db: oldFake,
      clock: () => DateTime(2026, 9, 15),
    );
    await oldProvider.load();

    await tester.pumpWidget(
      testApp(oldProvider, settings, const SearchScreen()),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('All time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All time'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Start Date'),
      '03/01/2012',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'End Date'),
      '03/10/2012',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Mar 1 – Mar 10'), findsOneWidget);

    // The only 2012 record is gone. Without widening firstDate/lastDate
    // to bracket the range already picked, _dateBounds would snap
    // firstDate back to 2015 and showDateRangePicker's initialDateRange
    // assertion would fire on reopen -- the same crash DateField already
    // guards against (rules-1-5#12).
    await oldProvider.deleteTransaction('old2012');
    await tester.pump();

    await tester.ensureVisible(find.text('Mar 1 – Mar 10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mar 1 – Mar 10'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Mar 1 – Mar 10'), findsOneWidget);
  });

  testWidgets('no matches shows a message; a result opens to read (DET-1)', (
    tester,
  ) async {
    await showSearch(tester);

    await type(tester, 'zzz');
    expect(find.text('No matching transactions.'), findsOneWidget);

    await type(tester, 'flat');
    await tester.tap(find.text('Flat'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
  });

  testWidgets('Export CSV saves exactly the matches (BAK-5)', (tester) async {
    final files = FakeBackupFiles();
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        const SearchScreen(),
        backup: testBackupService(fake, files: files),
      ),
    );
    await tester.pump();

    await type(tester, 'flat');
    await tester.tap(find.byTooltip('Export CSV'));
    await tester.pumpAndSettle();

    final csv = utf8.decode(
      files.saved['monthly-expenses-search-2026-09-15.csv']!,
    );
    expect(csv, contains(',Flat,'));
    expect(csv, isNot(contains('Salary')));
    expect(find.text('CSV saved'), findsOneWidget);

    await type(tester, 'zzz');
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.file_download_outlined),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('a result carries the same row menu as Home (ROW-1, ROW-3)', (
    tester,
  ) async {
    await showSearch(tester);

    expect(find.byTooltip('More actions'), findsNWidgets(3));
    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this transaction?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(provider.transactions, hasLength(2));
    expect(find.text('Transaction deleted'), findsOneWidget);
  });

  for (final language in ['ar', 'ur']) {
    testWidgets(
      'the row keeps its sign against its figures in $language (LANG-5, '
      'pr56+60#7)',
      (tester) async {
        await showSearch(tester, language: language);
        await tester.pumpAndSettle();

        // Where the sign actually lands, not just whether the widget
        // declares a direction: that check alone passed either way, even
        // when a hand-pasted sign had drifted to the far end of the row.
        // Found by the row it belongs to rather than by matching digits or
        // an ASCII '-$', neither of which every language's currency
        // pattern renders literally.
        final row = find.ancestor(
          of: find.text('Café lunch'),
          matching: find.byType(ListTile),
        );
        final amount = tester.widget<Text>(
          find.descendant(
            of: find.descendant(
              of: row,
              matching: find.byType(TransactionRowTrailing),
            ),
            matching: find.byType(Text),
          ),
        );
        expectSignTouchesFigures(amount);
      },
    );
  }
}
