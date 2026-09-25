import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/accounts_screen.dart';
import 'package:monthly_expense_app/screens/backup_screen.dart';
import 'package:monthly_expense_app/screens/budget_progress.dart';
import 'package:monthly_expense_app/screens/budgets_screen.dart';
import 'package:monthly_expense_app/screens/categories_screen.dart';
import 'package:monthly_expense_app/screens/day_strip.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/insights_screen.dart';
import 'package:monthly_expense_app/screens/notes_screen.dart';
import 'package:monthly_expense_app/screens/recurring_screen.dart';
import 'package:monthly_expense_app/screens/report_screen.dart';
import 'package:monthly_expense_app/screens/search_screen.dart';
import 'package:monthly_expense_app/screens/settings_screen.dart';
import 'package:monthly_expense_app/screens/transaction_detail_screen.dart';
import 'package:monthly_expense_app/screens/transfer_screen.dart';
import 'package:monthly_expense_app/screens/trash_screen.dart';
import 'package:monthly_expense_app/services/backup_service.dart';

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

  Future<void> showHome(WidgetTester tester, {BackupService? backup}) async {
    await tester.pumpWidget(
      testApp(provider, settings, const HomeScreen(), backup: backup),
    );
    await tester.pump();
  }

  /// Opens the navigation drawer and taps one of its rows (NAV-1). The list
  /// is longer than a phone, so the row may need scrolling to.
  Future<void> openMenu(WidgetTester tester, String item) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(item),
      120,
      scrollable: find
          .descendant(
            of: find.byType(Drawer),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(item));
    await tester.pumpAndSettle();
  }

  Future<void> swipe(WidgetTester tester, String text) async {
    await tester.drag(find.text(text), const Offset(-600, 0));
    await tester.pumpAndSettle();
  }

  /// Adds a bank account and a transfer to it on Sep 16.
  Future<void> addTransfer() async {
    fake.accounts.add(testAccount('bank'));
    fake.transfers.add(
      testTransfer('t', Account.cashId, 'bank', 50, DateTime(2026, 9, 15)),
    );
    await provider.load();
  }

  /// Brings the stored transactions to the reminder's 20 (BAK-7), with
  /// settings first opened in August.
  Future<void> reachReminder([Map<String, Object> values = const {}]) async {
    fake.rows.addAll([
      for (var i = 0; i < 18; i++)
        testTx('old$i', TransactionType.expense, 1, DateTime(2026, 8)),
    ]);
    await provider.load();
    settings = await testSettings({
      'first_opened_at': '2026-08-01T00:00:00.000Z',
      ...values,
    }, () => today);
  }

  testWidgets('future-dated rows are marked upcoming and not counted', (
    tester,
  ) async {
    // DAY-5: every day in the period, so the concert's day shows as well.
    provider.clearSelectedDay();
    await showHome(tester);

    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Food · Upcoming'), findsOneWidget);
    // The expense total is only lunch; the concert hasn't happened yet. Its
    // day still carries a total of its own (DAY-7), signed rather than told
    // apart by colour alone (A11Y-4, CUR-5): lunch's row, its day total, and
    // the period's own net (nothing but this expense) all read "-$12.50".
    expect(find.text('\$12.50'), findsOneWidget);
    expect(find.text('-\$12.50'), findsNWidgets(3));
    // The concert's own row and its day total both read "-$40" now; before,
    // only the row was signed and the day total read the bare "$40" (DAY-7,
    // A11Y-4).
    expect(find.text('\$40'), findsNothing);
    expect(find.text('-\$40'), findsNWidgets(2));
  });

  testWidgets(
    'income and expense are not interchangeable, in the summary or a row '
    '(CUR-5, DAY-7, BAL-3)',
    (tester) async {
      fake.rows.add(
        testTx(
          'c',
          TransactionType.income,
          100,
          DateTime(2026, 9, 15),
          title: 'Salary',
        ),
      );
      await provider.load();

      await showHome(tester);

      // The summary: income's own tile shows $100, expense's own tile shows
      // $12.50 (the concert is still upcoming and uncounted).
      final incomeTile = find
          .ancestor(of: find.text('Income'), matching: find.byType(Column))
          .first;
      final expenseTile = find
          .ancestor(of: find.text('Expense'), matching: find.byType(Column))
          .first;
      expect(
        find.descendant(of: incomeTile, matching: find.text('\$100')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: expenseTile, matching: find.text('\$12.50')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: incomeTile, matching: find.text('\$12.50')),
        findsNothing,
      );

      // The day row: the salary reads as a plus, the lunch as a minus.
      final salaryRow = find
          .ancestor(of: find.text('Salary'), matching: find.byType(ListTile))
          .first;
      final lunchRow = find
          .ancestor(of: find.text('Lunch'), matching: find.byType(ListTile))
          .first;
      expect(
        find.descendant(of: salaryRow, matching: find.text('+\$100')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: lunchRow, matching: find.text('-\$12.50')),
        findsOneWidget,
      );
    },
  );

  testWidgets('the balance carries forward from earlier periods (BAL-2)', (
    tester,
  ) async {
    fake.rows.add(
      testTx('pay', TransactionType.income, 100, DateTime(2026, 8, 20)),
    );
    await provider.load();

    await showHome(tester);

    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Carried forward \$100'), findsOneWidget);
    expect(find.text('\$87.50'), findsOneWidget);
  });

  testWidgets('with carrying forward off, the card shows this period (BAL-3)', (
    tester,
  ) async {
    settings = await testSettings({'show_carried_forward': false});

    await showHome(tester);

    expect(find.text('This period'), findsOneWidget);
    expect(find.textContaining('Carried forward'), findsNothing);
  });

  testWidgets(
    'with carrying forward off, the amount is the period net, not the '
    'closing balance (BAL-3, BAL-2)',
    (tester) async {
      // Same earlier-period income as BAL-2, so carried forward ($100) and
      // period net (-$12.50) are different numbers, unlike the base BAL-3
      // test above where both happen to be the same because there is no
      // prior period.
      fake.rows.add(
        testTx('pay', TransactionType.income, 100, DateTime(2026, 8, 20)),
      );
      await provider.load();
      settings = await testSettings({'show_carried_forward': false});

      await showHome(tester);

      expect(find.text('This period'), findsOneWidget);
      // A day row can show the same figure, so look inside the summary card.
      expect(
        find.descendant(of: find.byType(Card), matching: find.text('-\$12.50')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(Card), matching: find.text('\$87.50')),
        findsNothing,
      );
    },
  );

  testWidgets('amounts use the chosen currency (CUR-2)', (tester) async {
    settings = await testSettings({'currency_code': 'EUR'});

    await showHome(tester);

    // The summary's expense, and the day's own total (DAY-7), the row, and
    // the period's own net all signed rather than coloured alone (A11Y-4).
    expect(find.text('€12.50'), findsOneWidget);
    expect(find.text('-€12.50'), findsNWidgets(3));
  });

  testWidgets('the arrows move between periods', (tester) async {
    await showHome(tester);

    await tester.tap(find.byTooltip('Previous period'));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);

    await tester.tap(find.byTooltip('Next period'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets('a month starting on the 25th shows both dates (PER-3)', (
    tester,
  ) async {
    provider = TransactionProvider(db: fake, clock: () => today, startDay: 25);
    await provider.load();

    await showHome(tester);

    expect(find.text('Aug 25 – Sep 24'), findsOneWidget);
  });

  testWidgets('the app bar, the drawer, and the add button open their '
      'screens (NAV-1, NAV-4)', (tester) async {
    await showHome(tester);

    Future<void> openAndReturn(
      Future<void> Function() open,
      Type screen,
    ) async {
      await open();
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget);
      // ADD-9: a form's first Back only closes its keypad, so leaving one
      // takes a second press.
      await tester.pageBack();
      await tester.pumpAndSettle();
      if (find.byType(screen).evaluate().isNotEmpty) {
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    }

    await openAndReturn(
      () => tester.tap(find.byTooltip('Search')),
      SearchScreen,
    );
    // NAV-6: the gear replaced the Insights action, which the drawer names
    // three times over.
    await openAndReturn(
      () => tester.tap(find.byTooltip('Settings')),
      SettingsScreen,
    );
    // Every destination the drawer names opens from it (NAV-1).
    for (final (label, screen) in [
      ('Add expense', AddTransactionScreen),
      ('Add income', AddTransactionScreen),
      ('Transfer', TransferScreen),
      ('Budgets', BudgetsScreen),
      ('Recurring', RecurringScreen),
      ('Notes', NotesScreen),
      ('Spending by category', InsightsScreen),
      ('Calendar', InsightsScreen),
      ('Trend', InsightsScreen),
      ('Search', SearchScreen),
      ('Accounts', AccountsScreen),
      ('Categories', CategoriesScreen),
      ('Settings', SettingsScreen),
      ('Export PDF', ReportScreen),
      ('Backup & restore', BackupScreen),
      ('Trash', TrashScreen),
    ]) {
      await openAndReturn(() => openMenu(tester, label), screen);
    }

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });

  testWidgets('the first launch offers one action: add a transaction (RUN-1)', (
    tester,
  ) async {
    // A phone, not the default wide-and-short test surface: Home shows the
    // day strip, the summary card and the welcome, and they all fit.
    usePhoneScreen(tester);
    provider = TransactionProvider(db: FakeDB(), clock: () => today);
    await provider.load();

    await showHome(tester);

    expect(find.text('Welcome to Monthly Expenses'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('No transactions in this period yet.'), findsNothing);

    await tester.tap(find.text('Add your first transaction'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });

  testWidgets('tapping the period opens the calendar for it (INS-4)', (
    tester,
  ) async {
    await showHome(tester);

    await tester.tap(find.text('September 2026'));
    await tester.pumpAndSettle();

    expect(find.byType(InsightsScreen), findsOneWidget);
    final tabs = DefaultTabController.of(tester.element(find.byType(TabBar)));
    expect(tabs.index, 1);
    // The period came with it, rather than resetting (PER-1).
    expect(find.text('September 2026'), findsOneWidget);
  });

  testWidgets('the drawer opens each view of Insights directly (NAV-1)', (
    tester,
  ) async {
    await showHome(tester);

    for (final (label, tab) in [
      ('Spending by category', 0),
      ('Calendar', 1),
      ('Trend', 2),
    ]) {
      await openMenu(tester, label);

      expect(find.byType(InsightsScreen), findsOneWidget);
      final tabs = DefaultTabController.of(tester.element(find.byType(TabBar)));
      expect(tabs.index, tab, reason: label);

      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('the drawer adds an expense or an income directly (NAV-1)', (
    tester,
  ) async {
    await showHome(tester);

    for (final (label, type) in [
      ('Add expense', TransactionType.expense),
      ('Add income', TransactionType.income),
    ]) {
      await openMenu(tester, label);

      final segments = tester.widget<SegmentedButton<TransactionType>>(
        find.byType(SegmentedButton<TransactionType>),
      );
      expect(segments.selected, {type}, reason: label);

      // ADD-9: the first Back closes the keypad the form opened with.
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Export CSV saves the selected period (BAK-5)', (tester) async {
    final files = FakeBackupFiles();
    await showHome(tester, backup: testBackupService(fake, files: files));

    await openMenu(tester, 'Export CSV');

    final csv = utf8.decode(
      files.saved['monthly-expenses-2026-09-01_2026-09-30.csv']!,
    );
    expect(csv, contains(',Lunch,'));
    expect(csv, contains(',Concert,'));
    expect(find.text('CSV saved'), findsOneWidget);
  });

  testWidgets('a failed export shows an error', (tester) async {
    final files = FakeBackupFiles()..fail = true;
    await showHome(tester, backup: testBackupService(fake, files: files));

    await openMenu(tester, 'Export CSV');

    expect(find.text("Couldn't export the CSV. Try again."), findsOneWidget);
  });

  testWidgets('the backup reminder can wait for later (BAK-7)', (tester) async {
    await reachReminder();
    await showHome(tester);
    expect(find.text('Back up your data to keep it safe'), findsOneWidget);

    await tester.tap(find.byTooltip('Not now'));
    await tester.pump();

    expect(find.text('Back up your data to keep it safe'), findsNothing);
  });

  testWidgets('the backup reminder opens Backup & restore', (tester) async {
    await reachReminder({'last_backup_at': '2026-08-01T12:00:00.000Z'});
    await showHome(tester);

    await tester.tap(find.text('Last backup Aug 1, 2026. Time for a new one?'));
    await tester.pumpAndSettle();

    expect(find.byType(BackupScreen), findsOneWidget);
  });

  testWidgets('due recurring transactions show a notice (RCR-2)', (
    tester,
  ) async {
    fake.rules.add(testRule('Gym', 30, DateTime(2026, 9)));
    await provider.load();

    await showHome(tester);
    await tester.tap(find.text('1 recurring transaction is due'));
    await tester.pumpAndSettle();

    expect(find.byType(RecurringScreen), findsOneWidget);
  });

  group('the budgets card (BUD-7, BUD-8)', () {
    Budget limit(String id, String? categoryId, int amount) => Budget(
      id: id,
      categoryId: categoryId,
      limit: Money(amount * 1000),
      effectiveFrom: DateTime(2026, 9),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    testWidgets('no budgets, no card', (tester) async {
      await showHome(tester);

      expect(find.byType(ExpansionTile), findsNothing);
    });

    testWidgets('one line at first, every budget once opened', (tester) async {
      fake.budgets.addAll([
        limit('all', null, 125),
        limit('food', 'cat-food', 10),
      ]);
      await provider.load();

      await showHome(tester);
      // Lunch (12.50) is 10% of the overall budget, and puts food over; the
      // concert on the 18th doesn't count yet (BAL-4).
      expect(find.text('10% used · 1 over'), findsOneWidget);
      expect(find.byType(BudgetProgress), findsNothing);
      // The line says it in red; there's no separate notice for it.
      expect(find.text('1 budget is over its limit'), findsNothing);

      await tester.tap(find.text('Budgets'));
      await tester.pumpAndSettle();

      expect(find.byType(BudgetProgress), findsNWidgets(2));
      // Each bar with what's spent of its limit and the share used, but not
      // the line under it, which stays in Insights.
      expect(find.text('\$12.50 of \$125   10%'), findsOneWidget);
      expect(find.text('\$12.50 of \$10   125%'), findsOneWidget);
      // Inside this card only: the summary card above it leads with exactly
      // this figure for the overall budget now, which is the one place on
      // Home BUD-10 lets it appear.
      expect(
        find.descendant(
          of: find.byType(BudgetProgress),
          matching: find.textContaining('left'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(BudgetProgress),
          matching: find.textContaining('Over by'),
        ),
        findsNothing,
      );

      // The fuller picture: Insights, on the tab that lists the budgets
      // above the spending by category.
      await tester.tap(find.text('Spending by category'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<InsightsScreen>(find.byType(InsightsScreen)).initialTab,
        0,
      );
      expect(find.text('Over by \$2.50'), findsOneWidget);
    });

    testWidgets('a future period with nothing recorded still shows its '
        'budgets, as limits only (BUD-6)', (tester) async {
      fake.budgets.add(limit('food', 'cat-food', 10));
      await provider.load();

      await showHome(tester);
      await tester.tap(find.byTooltip('Next period'));
      await tester.pumpAndSettle();

      expect(find.text('1 budget set'), findsOneWidget);
      expect(find.text('No transactions in this period yet.'), findsOneWidget);

      // Opened, each budget shows only its limit: nothing is spent yet.
      await tester.tap(find.text('Budgets'));
      await tester.pumpAndSettle();

      expect(find.text('Limit \$10'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('a short list with budgets still collapses it (BAL-7)', (
      tester,
    ) async {
      // The case that used to fail: the budgets card closed leaves so little
      // to scroll that collapsing the card gave the list back more room than
      // the finger had taken, and the offset was corrected back to the top.
      fake.budgets.add(
        Budget(
          id: 'all',
          categoryId: null,
          limit: const Money(125000),
          effectiveFrom: DateTime(2026, 9),
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      for (var i = 0; i < 4; i++) {
        fake.rows.add(
          testTx(
            'x$i',
            TransactionType.expense,
            1,
            DateTime(2026, 9, 15),
            title: 'Row $i',
          ),
        );
      }
      await provider.load();

      await showHome(tester);
      expect(find.text('Income'), findsOneWidget);

      // A finger that only moves forward, a step at a time.
      final gesture = await tester.startGesture(const Offset(400, 400));
      final offsets = <double>[];
      for (var i = 0; i < 8; i++) {
        await gesture.moveBy(const Offset(0, -12));
        await tester.pump();
        offsets.add(
          tester.widget<Scrollable>(find.byType(Scrollable).last).controller ==
                  null
              ? Scrollable.of(tester.element(find.byType(CustomScrollView)))
                    .position
                    .pixels
              : 0,
        );
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Income'), findsNothing);
      // It never ran backwards under a forward finger.
      for (var i = 1; i < offsets.length; i++) {
        expect(
          offsets[i],
          greaterThanOrEqualTo(offsets[i - 1]),
          reason: 'offset went backwards at step $i: $offsets',
        );
      }
    });

    testWidgets('scrolling folds the budgets card, the top opens it (BUD-9)', (
      tester,
    ) async {
      fake.budgets.add(
        Budget(
          id: 'all',
          categoryId: null,
          limit: const Money(125000),
          effectiveFrom: DateTime(2026, 9),
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      for (var i = 0; i < 10; i++) {
        fake.rows.add(
          testTx(
            'x$i',
            TransactionType.expense,
            1,
            DateTime(2026, 9, 15),
            title: 'Row $i',
          ),
        );
      }
      await provider.load();

      await showHome(tester);
      await tester.tap(find.text('Budgets'));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetProgress), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Folded away while the entries are being read (BUD-9).
      expect(find.byType(BudgetProgress), findsNothing);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await tester.pumpAndSettle();

      // Back at the top it is as the user left it.
      expect(find.byType(BudgetProgress), findsOneWidget);
    });
  });

  testWidgets('notes due in the period show a notice (NOTE-5)', (tester) async {
    fake.notes.add(testNote('n', 'Pay rent', dueDate: DateTime(2026, 9, 20)));
    await provider.load();

    await showHome(tester);
    await tester.tap(find.text('1 note is due'));
    await tester.pumpAndSettle();

    expect(find.byType(NotesScreen), findsOneWidget);
  });

  testWidgets('tapping a row opens it to read, and the pencil to edit '
      '(DET-1, DET-3)', (tester) async {
    await showHome(tester);

    await tester.tap(find.text('Lunch'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Edit Transaction'), findsNothing);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsOneWidget);
  });

  testWidgets('swiping a row moves it to the trash with Undo (DEL-2)', (
    tester,
  ) async {
    await showHome(tester);
    await swipe(tester, 'Lunch');

    expect(find.text('Lunch'), findsNothing);
    expect(provider.deletedTransactions.single.id, 'a');
    expect(find.text('Transaction deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.deletedTransactions, isEmpty);
  });

  testWidgets('the Undo snackbar goes away on its own after about five seconds '
      '(DEL-2)', (tester) async {
    await showHome(tester);
    await swipe(tester, 'Lunch');
    expect(find.text('Transaction deleted'), findsOneWidget);

    // persist: false is what makes this happen at all: a snack bar with
    // an action otherwise stays open for good. The timer fires at the 5s
    // mark, but removal runs its own exit animation across a few more
    // frames, so a single pump(6s) isn't enough on its own.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text('Transaction deleted'), findsNothing);
    expect(find.text('Undo'), findsNothing);
    // The delete itself was never undone; it just stopped offering to.
    expect(provider.deletedTransactions.single.id, 'a');
  });

  testWidgets('a failed undo shows an error', (tester) async {
    await showHome(tester);
    await swipe(tester, 'Lunch');
    fake.failWrites = true;

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't restore the transaction. Try again."),
      findsOneWidget,
    );
    expect(provider.deletedTransactions, hasLength(1));
  });

  testWidgets('a failed swipe delete keeps the row and shows an error', (
    tester,
  ) async {
    fake.failWrites = true;

    await showHome(tester);
    await swipe(tester, 'Lunch');

    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.transactions, hasLength(2));
    expect(
      find.text("Couldn't delete the transaction. Try again."),
      findsOneWidget,
    );
  });

  testWidgets('transfers are listed, not counted, and open for editing', (
    tester,
  ) async {
    await addTransfer();
    await showHome(tester);

    expect(find.text('acc-cash → bank'), findsOneWidget);
    expect(find.text('\$50'), findsOneWidget);
    // The summary's expense, and lunch's own day total (DAY-7), the row, and
    // the period's own net, all signed (A11Y-4); the transfer counts in none
    // of them.
    expect(find.text('\$12.50'), findsOneWidget);
    expect(find.text('-\$12.50'), findsNWidgets(3));

    await tester.tap(find.text('acc-cash → bank'));
    await tester.pumpAndSettle();

    expect(find.text('Edit transfer'), findsOneWidget);
  });

  testWidgets('swiping a transfer deletes it with Undo', (tester) async {
    await addTransfer();
    await showHome(tester);

    await swipe(tester, 'acc-cash → bank');
    expect(provider.transfers, isEmpty);
    expect(find.text('Transfer deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(provider.transfers, hasLength(1));
    expect(find.text('acc-cash → bank'), findsOneWidget);
  });

  testWidgets('a failed transfer delete keeps the row and shows an error', (
    tester,
  ) async {
    await addTransfer();
    fake.failWrites = true;
    await showHome(tester);

    await swipe(tester, 'acc-cash → bank');

    expect(find.text('acc-cash → bank'), findsOneWidget);
    expect(find.text("Couldn't save the transfer. Try again."), findsOneWidget);
  });

  group('the day strip (DAY-1 – DAY-7)', () {
    testWidgets('Home opens on today, with that day on its own (DAY-1)', (
      tester,
    ) async {
      await showHome(tester);

      // A week of days, and only today's entries under them.
      expect(find.text('19'), findsOneWidget);
      expect(find.text('Sep 15, 2026'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Concert'), findsNothing);
    });

    testWidgets('another day in the week shows that day instead', (
      tester,
    ) async {
      await showHome(tester);

      await tester.tap(find.text('18'));
      await tester.pumpAndSettle();

      expect(find.text('Sep 18, 2026'), findsOneWidget);
      expect(find.text('Concert'), findsOneWidget);
      expect(find.text('Lunch'), findsNothing);
    });

    testWidgets('a day with nothing on it says so (DAY-7)', (tester) async {
      await showHome(tester);

      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing on this day.'), findsOneWidget);
      expect(find.text('Lunch'), findsNothing);
    });

    testWidgets('the chosen day again shows the whole period (DAY-5)', (
      tester,
    ) async {
      await showHome(tester);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Concert'), findsOneWidget);
    });

    testWidgets('a day in another period brings the period with it (DAY-3)', (
      tester,
    ) async {
      await showHome(tester);

      // Two weeks back from 13–19 September reaches 30 August – 5 September.
      for (var i = 0; i < 2; i++) {
        await tester.drag(find.byType(DayStrip), const Offset(600, 0));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('31'));
      await tester.pumpAndSettle();

      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('Aug 31, 2026'), findsOneWidget);
    });

    testWidgets('the period arrows leave the strip on that period (DAY-6)', (
      tester,
    ) async {
      await showHome(tester);

      await tester.tap(find.byTooltip('Previous period'));
      await tester.pumpAndSettle();

      // August holds no today, so it shows every day it has (DAY-6).
      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('No transactions in this period yet.'), findsOneWidget);
    });

    testWidgets('a past month opens on a week mostly its own, and the days '
        'of another month are dimmed (DAY-6, DAY-3)', (tester) async {
      await showHome(tester);
      final strip = find.byType(DayStrip);
      Finder inStrip(String day) =>
          find.descendant(of: strip, matching: find.text(day));

      await tester.tap(find.byTooltip('Previous period'));
      await tester.pumpAndSettle();

      // 1 August 2026 is a Saturday, so its week is six days of July: one
      // tap on any of them used to take Home to July. The strip opens on
      // 2–8 August instead.
      for (final day in ['2', '3', '4', '5', '6', '7', '8']) {
        expect(inStrip(day), findsOneWidget, reason: 'August $day');
      }
      expect(inStrip('26'), findsNothing);

      // A swipe back reaches 26 July – 1 August, July's days dimmed.
      await tester.drag(strip, const Offset(600, 0));
      await tester.pumpAndSettle();
      double dimming(String day) => tester
          .widget<Opacity>(
            find.ancestor(of: inStrip(day), matching: find.byType(Opacity)),
          )
          .opacity;
      expect(dimming('26'), outsidePeriodOpacity);
      expect(dimming('1'), 1);
      expect(find.text('August 2026'), findsOneWidget);
    });

    testWidgets('a day shows its own income and expense (DAY-7)', (
      tester,
    ) async {
      fake.rows.add(
        testTx(
          'c',
          TransactionType.income,
          30,
          DateTime(2026, 9, 15),
          title: 'Pay',
        ),
      );
      await provider.load();

      await showHome(tester);

      // Each side in the summary, unsigned, and again both on its own row
      // and the day's own total (DAY-7, DAY-8), signed rather than told
      // apart by colour alone (A11Y-4).
      expect(find.text('\$30'), findsOneWidget);
      expect(find.text('+\$30'), findsNWidgets(2));
      expect(find.text('\$12.50'), findsOneWidget);
      expect(find.text('-\$12.50'), findsNWidgets(2));
    });

    testWidgets('a transfer dated ahead is marked upcoming (BAL-4)', (
      tester,
    ) async {
      fake.accounts.add(testAccount('bank'));
      fake.transfers.add(
        testTransfer('t2', Account.cashId, 'bank', 20, DateTime(2026, 9, 18)),
      );
      await provider.load();

      await showHome(tester);
      await tester.tap(find.text('18'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer · Upcoming'), findsOneWidget);
    });

    testWidgets('a different first day of the week moves the strip (DAY-2)', (
      tester,
    ) async {
      await showHome(tester);
      expect(find.text('19'), findsOneWidget);

      // Weeks starting on Wednesday put today, a Tuesday, at the end of
      // 9–15 September (PER-4).
      await settings.setWeekStartDay(3);
      await tester.pumpAndSettle();

      expect(find.text('9'), findsOneWidget);
      expect(find.text('19'), findsNothing);
    });
  });

  group("a row's own actions (ROW-1 – ROW-4)", () {
    testWidgets('the menu duplicates the entry, writing nothing yet (ROW-2)', (
      tester,
    ) async {
      await showHome(tester);

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();
      // ROW-1: the menu opens, the entry does not.
      expect(find.byType(TransactionDetailScreen), findsNothing);
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.text('12.5'), findsWidgets);
      expect(provider.transactions, hasLength(2));
    });

    testWidgets('Delete asks first, and Cancel keeps the row (ROW-3)', (
      tester,
    ) async {
      await showHome(tester);

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this transaction?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Lunch'), findsOneWidget);
      expect(provider.transactions, hasLength(2));
    });

    testWidgets('confirming deletes it to the trash, with Undo (DEL-2)', (
      tester,
    ) async {
      await showHome(tester);

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(provider.transactions, hasLength(1));
      expect(find.text('Transaction deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(provider.transactions, hasLength(2));
    });

    testWidgets('a swipe still deletes without asking (ROW-4)', (tester) async {
      await showHome(tester);

      await swipe(tester, 'Lunch');

      expect(find.text('Delete this transaction?'), findsNothing);
      expect(provider.transactions, hasLength(1));
      expect(find.text('Transaction deleted'), findsOneWidget);
    });

    testWidgets('a failed delete from the menu says so and keeps the row', (
      tester,
    ) async {
      fake.failWrites = true;
      await showHome(tester);

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't delete the transaction. Try again."),
        findsOneWidget,
      );
      expect(find.text('Lunch'), findsOneWidget);
      expect(provider.transactions, hasLength(2));
    });
  });

  group('the line the card leads with (BAL-8, BUD-11)', () {
    Budget overall(int amount) => Budget(
      id: 'all',
      categoryId: null,
      limit: Money(amount * 1000),
      effectiveFrom: DateTime(2026, 9),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    testWidgets('no budget: what has gone, per day, and an offer', (
      tester,
    ) async {
      await showHome(tester);

      // Lunch counts, the concert on the 18th does not yet (BAL-4), over the
      // fifteen days of September so far.
      expect(find.text('\$12.50 spent · \$0.83 a day so far'), findsOneWidget);
      expect(find.text('Set a monthly budget'), findsOneWidget);
    });

    testWidgets('an overall budget: what is left, and no offer', (
      tester,
    ) async {
      fake.budgets.add(overall(125));
      await provider.load();

      await showHome(tester);

      // $112.50 left over the sixteen days to the end of the period (BUD-3).
      expect(find.text('\$112.50 left · \$7.03 a day'), findsOneWidget);
      expect(find.text('Set a monthly budget'), findsNothing);
    });

    testWidgets('past the limit it says how much over, not a share', (
      tester,
    ) async {
      fake.budgets.add(overall(10));
      await provider.load();

      await showHome(tester);

      expect(
        find.descendant(
          of: find.byType(Card),
          matching: find.text('Over by \$2.50'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('it stays on the one line the card collapses to', (
      tester,
    ) async {
      fake.budgets.add(overall(125));
      await provider.load();
      await showHome(tester);

      await tester.tap(find.text('Balance'));
      await tester.pumpAndSettle();

      // The card is one line now, and the number is still on it: this is the
      // state a scroll leaves Home in (BAL-7).
      expect(find.text('Income'), findsNothing);
      expect(find.text('\$112.50 left · \$7.03 a day'), findsOneWidget);
    });

    testWidgets('the offer opens the overall budget, not a fold', (
      tester,
    ) async {
      await showHome(tester);

      await tester.tap(find.text('Set a monthly budget'));
      await tester.pumpAndSettle();

      // Its own target: the card's own tap would only have folded it (BAL-6).
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Overall'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('setting one from the offer turns the line around', (
      tester,
    ) async {
      await showHome(tester);

      await tester.tap(find.text('Set a monthly budget'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '125');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // BUD-5: the budget starts from the current period, and the line is
      // about what is left from here rather than what has gone.
      expect(provider.budgetLimit(null), const Money(125000));
      expect(find.text('Set a monthly budget'), findsNothing);
      expect(find.text('\$112.50 left · \$7.03 a day'), findsOneWidget);
    });

    testWidgets('an overall budget: no offer on a period before it started '
        '(BUD-11, rules-6-10#8)', (tester) async {
      fake.budgets.add(overall(125));
      await provider.load();
      await showHome(tester);
      expect(find.text('Set a monthly budget'), findsNothing);

      // BUD-11: the offer goes as soon as a budget exists, whichever period
      // Home is showing.
      provider.previousPeriod();
      await tester.pump();

      expect(find.text('Set a monthly budget'), findsNothing);
    });

    testWidgets('from a past period the offer starts from the period before '
        'the current one, offers no Remove, and saves for the current period '
        '(BUD-5, BUD-11, rules-6-10#8)', (tester) async {
      fake.rows.addAll([
        testTx('aug', TransactionType.expense, 80, DateTime(2026, 8, 10)),
        testTx('jul', TransactionType.expense, 40, DateTime(2026, 7, 10)),
      ]);
      await provider.load();
      await showHome(tester);
      provider.previousPeriod();
      await tester.pump();

      await tester.tap(find.text('Set a monthly budget'));
      await tester.pumpAndSettle();

      // August's spending, the period before the current one; not July's,
      // the period before the one on screen.
      expect(find.widgetWithText(TextFormField, '80'), findsOneWidget);
      // Nothing is set yet, so there is nothing to remove.
      expect(find.text('Remove'), findsNothing);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        provider.budgetLimit(null, provider.currentPeriod),
        const Money(80000),
      );
      expect(fake.budgets.single.effectiveFrom, DateTime(2026, 9));
    });

    testWidgets('a budget that will not save says so', (tester) async {
      await showHome(tester);
      fake.failWrites = true;

      await tester.tap(find.text('Set a monthly budget'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '125');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't save the budget. Try again."), findsOneWidget);
      expect(provider.budgetLimit(null), isNull);
      // Still on offer, since there is still no budget.
      expect(find.text('Set a monthly budget'), findsOneWidget);
    });
  });

  group('the summary card (BAL-6, BAL-7)', () {
    testWidgets('tapping it leaves the balance, and it is remembered', (
      tester,
    ) async {
      await showHome(tester);
      expect(find.text('Income'), findsOneWidget);

      await tester.tap(find.text('Balance'));
      await tester.pumpAndSettle();

      expect(find.text('Income'), findsNothing);
      expect(find.text('Expense'), findsNothing);
      expect(find.text('Balance'), findsOneWidget);
      // The row under it shows the same amount, so look inside the card.
      expect(
        find.descendant(of: find.byType(Card), matching: find.text('-\$12.50')),
        findsOneWidget,
      );
      expect(settings.summaryCollapsed, isTrue);
    });

    testWidgets('a card left collapsed opens again on a tap', (tester) async {
      settings = await testSettings({'summary_collapsed': true});

      await showHome(tester);
      expect(find.text('Income'), findsNothing);

      await tester.tap(find.text('Balance'));
      await tester.pumpAndSettle();

      expect(find.text('Income'), findsOneWidget);
      expect(settings.summaryCollapsed, isFalse);
    });

    testWidgets('scrolling the list collapses it; the top opens it (BAL-7)', (
      tester,
    ) async {
      for (var i = 0; i < 20; i++) {
        fake.rows.add(
          testTx(
            'x$i',
            TransactionType.expense,
            1,
            DateTime(2026, 9, 15),
            title: 'Row $i',
          ),
        );
      }
      await provider.load();

      await showHome(tester);
      expect(find.text('Income'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Income'), findsNothing);
      expect(find.text('Balance'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(find.text('Income'), findsOneWidget);
      // Scrolling never changed what the user had chosen.
      expect(settings.summaryCollapsed, isFalse);
    });

    testWidgets('the strip is there before the first entry (DAY-2)', (
      tester,
    ) async {
      provider = TransactionProvider(db: FakeDB(), clock: () => today);
      await provider.load();

      await showHome(tester);

      expect(find.text('Welcome to Monthly Expenses'), findsOneWidget);
      expect(find.byType(DayStrip), findsOneWidget);
    });
  });

  testWidgets('a swipe ticks as it passes the point of no return (HAP-3)', (
    tester,
  ) async {
    usePhoneScreen(tester);
    final haptics = captureHaptics();
    await showHome(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Lunch')),
    );
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump();
    expect(haptics, isEmpty);

    await gesture.moveBy(const Offset(-160, 0));
    await tester.pump();
    expect(haptics, ['HapticFeedbackType.selectionClick']);

    // Nothing more on the way back, and nothing on the way out again.
    await gesture.moveBy(const Offset(160, 0));
    await tester.pump();
    expect(haptics, ['HapticFeedbackType.selectionClick']);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the pinned summary card follows a currency change (CUR-3)', (
    tester,
  ) async {
    await showHome(tester);
    expect(find.textContaining('\$'), findsWidgets);

    await settings.setCurrencyCode('JPY');
    await tester.pumpAndSettle();

    // The card is a pinned header and rebuilds only when its delegate says
    // to: without the currency in that comparison it kept the old symbol
    // while the rows below it had already changed.
    expect(find.textContaining('\$'), findsNothing);
    expect(find.textContaining('¥'), findsWidgets);
  });
}
