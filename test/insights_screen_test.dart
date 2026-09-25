import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transfer.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/budgets_screen.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/insights_screen.dart';
import 'package:monthly_expense_app/screens/note_form_screen.dart';
import 'package:monthly_expense_app/screens/transaction_row_menu.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  const income = TransactionType.income;
  final today = DateTime(2026, 9, 15);
  late SettingsProvider settings;

  Future<void> showInsights(
    WidgetTester tester,
    List<ExpenseTransaction> transactions, {
    List<Budget> budgets = const [],
    List<Transfer> transfers = const [],
    List<Note> notes = const [],
    Map<String, Object> settingsValues = const {},
  }) async {
    usePhoneScreen(tester);
    final provider = TransactionProvider(
      db: FakeDB(
        transactions: transactions,
        budgets: budgets,
        transfers: transfers,
        notes: notes,
        accounts: [testAccount(Account.cashId), testAccount('bank')],
      ),
      clock: () => today,
    );
    await provider.load();
    settings = await testSettings(settingsValues);
    await tester.pumpWidget(
      testApp(provider, settings, const InsightsScreen()),
    );
    await tester.pump();
  }

  Future<void> openTab(WidgetTester tester, String tab) async {
    await tester.tap(find.text(tab));
    await tester.pumpAndSettle();
  }

  Budget budget(String? categoryId, int limit) {
    return Budget(
      id: categoryId ?? 'overall',
      categoryId: categoryId,
      limit: Money(limit * 1000),
      effectiveFrom: DateTime(2026, 9),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  final spending = [
    testTx('f', expense, 30, DateTime(2026, 9, 5)),
    testTx('r', expense, 10, DateTime(2026, 9, 6), categoryId: 'cat-rent'),
  ];

  group('categories (INS-3)', () {
    testWidgets('shows the empty state when the period has no expenses', (
      tester,
    ) async {
      await showInsights(tester, [
        testTx('s', income, 100, DateTime(2026, 9, 5)),
      ]);

      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text('No expenses in this period yet.'), findsOneWidget);
      expect(find.text('Budgets'), findsNothing);
    });

    testWidgets('a slice takes its category\'s colour, not its rank (CAT-6)', (
      tester,
    ) async {
      // Rent outspends food, so the ranking and the category order disagree.
      // That is the whole of it: the colour used to come from the position in
      // this sorted list, so a category changed colour when its month did.
      await showInsights(tester, [
        testTx('f', expense, 10, DateTime(2026, 9, 5)),
        testTx('r', expense, 30, DateTime(2026, 9, 6), categoryId: 'cat-rent'),
      ]);

      final byId = {for (final c in testCategories()) c.id: c};
      final sections = tester
          .widget<PieChart>(find.byType(PieChart))
          .data
          .sections;

      expect(sections, hasLength(2));
      expect(sections.first.color, Color(byId['cat-rent']!.color!));
      expect(sections[1].color, Color(byId['cat-food']!.color!));

      // And the legend below reads the same colours in the same order, so the
      // chart and its key cannot drift apart.
      final circles = tester
          .widgetList<CircleAvatar>(
            find.descendant(
              of: find.byType(ListTile, skipOffstage: false),
              matching: find.byType(CircleAvatar, skipOffstage: false),
            ),
          )
          .toList();
      expect(circles, hasLength(2));
      expect(circles.first.backgroundColor, sections.first.color);
      expect(circles[1].backgroundColor, sections[1].color);
    });

    testWidgets('lists spending by category with the total', (tester) async {
      await showInsights(tester, spending);

      expect(
        find.text('Total spent: \$40', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Food', skipOffstage: false), findsOneWidget);
      expect(find.text('Rent', skipOffstage: false), findsOneWidget);
    });

    testWidgets("each row shows its own category's amount, not another's "
        '(INS-3)', (tester) async {
      await showInsights(tester, spending);

      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Food', skipOffstage: false),
          matching: find.text('\$30', skipOffstage: false),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Rent', skipOffstage: false),
          matching: find.text('\$10', skipOffstage: false),
        ),
        findsOneWidget,
      );
    });

    testWidgets('income has its own chart', (tester) async {
      await showInsights(tester, [
        ...spending,
        testTx('s', income, 100, DateTime(2026, 9, 5)),
      ]);

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(
        find.text('Total income: \$100', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Salary', skipOffstage: false), findsOneWidget);
      expect(find.text('Food', skipOffstage: false), findsNothing);
    });

    testWidgets('the arrows show another period', (tester) async {
      await showInsights(tester, spending);

      await tester.tap(find.byTooltip('Previous period'));
      await tester.pumpAndSettle();

      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('No expenses in this period yet.'), findsOneWidget);
    });

    testWidgets('budget bars show what is left per day or how much is over', (
      tester,
    ) async {
      await showInsights(
        tester,
        spending,
        budgets: [
          budget(null, 1000),
          budget('cat-food', 46),
          budget('cat-rent', 5),
        ],
      );

      expect(find.text('Budgets'), findsOneWidget);
      // September 15–30 is 16 days, today included.
      expect(find.text('\$960 left · \$60 a day'), findsOneWidget);
      expect(find.text('\$30 of \$46'), findsOneWidget);
      expect(find.text('\$16 left · \$1 a day'), findsOneWidget);
      expect(find.text('Over by \$5'), findsOneWidget);
    });

    testWidgets('the budgets button opens the budgets screen', (tester) async {
      await showInsights(tester, spending);

      await tester.tap(find.byTooltip('Budgets'));
      await tester.pumpAndSettle();

      expect(find.byType(BudgetsScreen), findsOneWidget);
    });
    testWidgets('the chart says how the period compares with the one before '
        '(INS-6)', (tester) async {
      await showInsights(tester, [
        // August: food 100, transport 50.
        testTx('a', TransactionType.expense, 100, DateTime(2026, 8, 3)),
        testTx(
          'b',
          TransactionType.expense,
          50,
          DateTime(2026, 8, 9),
          categoryId: 'cat-transport',
        ),
        // September: food down to 60, and shopping out of nowhere.
        testTx('c', TransactionType.expense, 60, DateTime(2026, 9, 4)),
        testTx(
          'd',
          TransactionType.expense,
          20,
          DateTime(2026, 9, 5),
          categoryId: 'cat-shopping',
        ),
      ]);

      // 150 last month against 80 this one.
      expect(find.text('\$70 less than last month'), findsOneWidget);
      // Food fell from 100 to 60; shopping had nothing to fall from.
      expect(find.text('-40%'), findsOneWidget);
      expect(find.text('new'), findsOneWidget);
    });

    testWidgets(
      'a rising category shows a plus, and a change under half a percent '
      'shows no label at all (INS-6, pr61#5, pr56+60#2)',
      (tester) async {
        await showInsights(tester, [
          // August: rent 50, transport 1000, shopping 1000.
          testTx(
            'a',
            expense,
            50,
            DateTime(2026, 8, 3),
            categoryId: 'cat-rent',
          ),
          testTx(
            'b',
            expense,
            1000,
            DateTime(2026, 8, 9),
            categoryId: 'cat-transport',
          ),
          testTx(
            'c',
            expense,
            1000,
            DateTime(2026, 8, 10),
            categoryId: 'cat-shopping',
          ),
          // September: rent doubles (+100%); transport falls just under
          // half a percent, which intl's own NumberFormat still signs
          // from the unrounded value, so before the fix it rounded to
          // "-0%" instead of hiding like the same-sized rise (INS-6);
          // shopping rises just under half a percent too.
          testTx(
            'd',
            expense,
            100,
            DateTime(2026, 9, 4),
            categoryId: 'cat-rent',
          ),
          testTx(
            'e',
            expense,
            999.5,
            DateTime(2026, 9, 5),
            categoryId: 'cat-transport',
          ),
          testTx(
            'f',
            expense,
            1001,
            DateTime(2026, 9, 6),
            categoryId: 'cat-shopping',
          ),
        ]);

        // The rise carries a plus, from the language's own negative
        // pattern with the sign swapped, not a bare '+' pasted in front
        // (LANG-5, CUR-5).
        expect(find.text('+100%'), findsOneWidget);
        // Neither small change rounds away to a fake "-0%" or "0%".
        expect(find.text('-0%'), findsNothing);
        expect(find.text('0%'), findsNothing);
      },
    );

    testWidgets('the earliest period on record compares with nothing (INS-6)', (
      tester,
    ) async {
      await showInsights(tester, [
        testTx('a', TransactionType.expense, 60, DateTime(2026, 9, 4)),
      ]);

      expect(find.textContaining('than last month'), findsNothing);
      expect(find.text('new'), findsNothing);
    });
  });

  group('calendar (INS-1)', () {
    final month = [
      testTx('groceries', expense, 30, DateTime(2026, 9, 5)),
      testTx(
        'flat',
        expense,
        10,
        DateTime(2026, 9, 6),
        title: 'Flat',
        categoryId: 'cat-rent',
      ),
      testTx('pay', income, 100, DateTime(2026, 9, 15), title: 'Paycheck'),
      testTx('concert', expense, 40, DateTime(2026, 9, 20)),
    ];

    testWidgets('days show their totals and today is listed first', (
      tester,
    ) async {
      await showInsights(tester, month);
      await openTab(tester, 'Calendar');
      final compact = settings.compactCurrencyFormat('en');

      expect(find.text('Sep 1'), findsOneWidget);
      // Signed, not just coloured, on the calendar cell too (A11Y-4, CUR-5).
      expect(
        find.text(compact.signedFormat(30, isIncome: false)),
        findsOneWidget,
      );
      // The calendar cell, and the day list's own signed row for Paycheck
      // below it, format the same for a whole number (INS-1, DET-1).
      expect(
        find.text(compact.signedFormat(100, isIncome: true)),
        findsNWidgets(2),
      );
      // Upcoming days show their amounts too, faintly.
      expect(
        find.text(compact.signedFormat(40, isIncome: false)),
        findsOneWidget,
      );
      expect(find.text('Tuesday, September 15, 2026'), findsOneWidget);
      expect(find.text('Paycheck'), findsOneWidget);
    });

    testWidgets('tapping a day lists its entries, which open to read (DET-1)', (
      tester,
    ) async {
      await showInsights(tester, month);
      await openTab(tester, 'Calendar');

      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();
      expect(find.text('Sunday, September 6, 2026'), findsOneWidget);

      await tester.tap(find.text('Flat'));
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets("a day's entries carry the row menu too (ROW-1, ROW-2)", (
      tester,
    ) async {
      await showInsights(tester, month);
      await openTab(tester, 'Calendar');

      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();
      // ROW-2: the form opens prefilled, on top of the calendar.
      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.text('Flat'), findsWidgets);
      expect(find.text('10'), findsWidgets);
    });

    testWidgets('empty days say so; transfers are listed', (tester) async {
      await showInsights(
        tester,
        month,
        transfers: [
          testTransfer('t', Account.cashId, 'bank', 50, DateTime(2026, 9, 3)),
        ],
      );
      await openTab(tester, 'Calendar');

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing on this day.'), findsOneWidget);

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('acc-cash → bank'));
      await tester.pumpAndSettle();
      expect(find.text('Edit transfer'), findsOneWidget);
    });

    testWidgets('a note due that day lists there and opens it (NOTE-5)', (
      tester,
    ) async {
      await showInsights(
        tester,
        month,
        notes: [testNote('n', 'Pay rent', dueDate: DateTime(2026, 9, 6))],
      );
      await openTab(tester, 'Calendar');

      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();
      expect(find.text('Notes due'), findsOneWidget);
      expect(find.text('Pay rent'), findsOneWidget);

      await tester.tap(find.text('Pay rent'));
      await tester.pumpAndSettle();
      expect(find.byType(NoteFormScreen), findsOneWidget);
    });

    testWidgets('weeks start on the locale day until one is chosen (PER-4)', (
      tester,
    ) async {
      double x(String text) => tester.getCenter(find.text(text)).dx;

      await showInsights(tester, month);
      await openTab(tester, 'Calendar');
      expect(x('Sun'), lessThan(x('Mon')));

      await showInsights(tester, month, settingsValues: {'week_start_day': 1});
      await openTab(tester, 'Calendar');
      expect(x('Mon'), lessThan(x('Sun')));
    });

    testWidgets('outside today\'s period, a hint replaces the day list', (
      tester,
    ) async {
      await showInsights(tester, month);
      await openTab(tester, 'Calendar');

      await tester.tap(find.byTooltip('Previous period'));
      await tester.pumpAndSettle();

      expect(find.text('Tap a day to see its transactions.'), findsOneWidget);
    });
    for (final language in ['ar', 'ur']) {
      testWidgets(
        'the day\'s row keeps its sign against its figures in $language '
        '(LANG-5, pr56+60#7)',
        (tester) async {
          await showInsights(
            tester,
            month,
            settingsValues: {'language': language},
          );
          final l10n = lookupAppLocalizations(Locale(language));
          await openTab(tester, l10n.calendarTab);
          // Today (the fixed clock's Sept 15) is selected by default, so
          // day-of-month digits -- which some languages format with their
          // own numerals -- don't need tapping at all.
          await tester.pumpAndSettle();

          // Where the sign actually lands, not just whether the widget
          // declares a direction: that check alone passed either way, even
          // when a hand-pasted sign had drifted to the far end of the row.
          final row = find.ancestor(
            of: find.text('Paycheck'),
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
  });

  group('trend (INS-2)', () {
    final history = [
      testTx('july', income, 200, DateTime(2026, 7)),
      testTx('august', expense, 60, DateTime(2026, 8, 10)),
      testTx('september', expense, 30, DateTime(2026, 9, 5)),
      testTx('pay', income, 100, DateTime(2026, 9, 15)),
    ];

    testWidgets('lists recent periods and their averages', (tester) async {
      await showInsights(tester, history);
      await openTab(tester, 'Trend');

      expect(
        find.text('Average per period · Income \$50 · Expense \$15'),
        findsOneWidget,
      );
      expect(
        find.text('Income \$100 · Expense \$30', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('\$70', skipOffstage: false), findsOneWidget);
      expect(find.text('-\$60', skipOffstage: false), findsOneWidget);

      await tester.tap(find.text('12 months'));
      await tester.pumpAndSettle();
      expect(
        find.text('Average per period · Income \$25 · Expense \$7.50'),
        findsOneWidget,
      );
    });

    testWidgets('periods that have not started stay out of the averages', (
      tester,
    ) async {
      await showInsights(tester, history);
      await openTab(tester, 'Trend');

      // November: June to November, of which October and November are
      // still to come, so the averages cover four periods.
      await tester.tap(find.byTooltip('Next period'));
      await tester.tap(find.byTooltip('Next period'));
      await tester.pumpAndSettle();

      expect(
        find.text('Average per period · Income \$75 · Expense \$22.50'),
        findsOneWidget,
      );
    });

    testWidgets('the top of the amount axis gets no label of its own '
        '(INS-5)', (tester) async {
      await showInsights(tester, [
        // An earlier period, so a trend can be drawn at all (EMPTY-4). It
        // sits before the six the chart shows, so it adds no bar of its own.
        testTx('older', income, 1, DateTime(2026, 1, 5)),
        testTx('pay', income, 3650, DateTime(2026, 9, 15)),
      ]);
      await openTab(tester, 'Trend');

      // $3.65K is only where the axis ends, not a gridline, and its label
      // would sit on top of the $3.5K one.
      expect(find.text('\$3.65K'), findsNothing);
      expect(find.text('\$3K'), findsOneWidget);
    });
    testWidgets('a net is coloured only when it is below zero (CUR-5)', (
      tester,
    ) async {
      await showInsights(tester, history);
      await openTab(tester, 'Trend');

      // A period that came out ahead keeps the ordinary text colour; only
      // the one below zero is painted, and in the app's own red.
      final ahead = tester.widget<Text>(find.text('\$70', skipOffstage: false));
      expect(ahead.style?.color, isNull);

      final behind = tester.widget<Text>(
        find.text('-\$60', skipOffstage: false),
      );
      expect(behind.style?.color, const Color(expenseInkLight));
    });
  });

  group('other periods', () {
    testWidgets('past budgets show what was left; future ones only the limit '
        '(BUD-6)', (tester) async {
      await showInsights(
        tester,
        [testTx('aug', expense, 20, DateTime(2026, 8, 5)), ...spending],
        budgets: [
          Budget(
            id: 'food',
            categoryId: 'cat-food',
            limit: const Money(50000),
            effectiveFrom: DateTime(2026, 8),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
          budget('cat-rent', 10),
        ],
      );
      expect(find.text('Limit reached'), findsOneWidget);

      await tester.tap(find.byTooltip('Previous period'));
      await tester.pumpAndSettle();
      expect(find.text('\$30 left'), findsOneWidget);

      await tester.tap(find.byTooltip('Next period'));
      await tester.tap(find.byTooltip('Next period'));
      await tester.pumpAndSettle();
      expect(find.text('Limit \$50'), findsOneWidget);
      expect(find.text('Limit \$10'), findsOneWidget);
    });

    testWidgets('upcoming entries in the day list are marked (BAL-4)', (
      tester,
    ) async {
      await showInsights(tester, [
        testTx('concert', expense, 40, DateTime(2026, 9, 20)),
      ]);
      await openTab(tester, 'Calendar');

      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      expect(find.text('Food · Upcoming'), findsOneWidget);
    });
  });
}
