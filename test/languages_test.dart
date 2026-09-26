import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/l10n/languages.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/backup_screen.dart';
import 'package:monthly_expense_app/screens/budgets_screen.dart';
import 'package:monthly_expense_app/screens/form_fields.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/import_screen.dart';
import 'package:monthly_expense_app/screens/insights_screen.dart';
import 'package:monthly_expense_app/screens/note_form_screen.dart';
import 'package:monthly_expense_app/screens/notes_screen.dart';
import 'package:monthly_expense_app/screens/recurring_screen.dart';
import 'package:monthly_expense_app/screens/remove_ads_screen.dart';
import 'package:monthly_expense_app/screens/report_screen.dart';
import 'package:monthly_expense_app/screens/search_screen.dart';
import 'package:monthly_expense_app/screens/settings_screen.dart';
import 'package:monthly_expense_app/screens/setup_screen.dart';
import 'package:monthly_expense_app/screens/transaction_detail_screen.dart';
import 'package:monthly_expense_app/screens/transfer_screen.dart';
import 'package:monthly_expense_app/screens/walkthrough_screen.dart';
import 'package:monthly_expense_app/services/backup_service.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';
import 'package:monthly_expense_app/services/report_fonts.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  const income = TransactionType.income;
  final today = DateTime(2026, 9, 15, 10);

  /// Data that fills every screen: the recurring notice on Home, an overall
  /// and a category budget, a due recurring rule, two accounts, and a trend
  /// with income in September.
  Future<TransactionProvider> loadProvider() async {
    final provider = TransactionProvider(
      db: FakeDB(
        transactions: [
          testTx('a', expense, 1234.5, DateTime(2026, 9, 15), title: 'Lunch'),
          testTx('b', income, 3000, DateTime(2026, 9, 1), title: 'Salary'),
          testTx('c', expense, 80, DateTime(2026, 9, 20), title: 'Concert'),
          testTx('d', expense, 45, DateTime(2026, 8, 10)),
        ],
        accounts: [
          testAccount(Account.cashId),
          testAccount('bank', opening: 500),
        ],
        budgets: [
          Budget(
            id: 'overall',
            categoryId: null,
            limit: const Money(1000 * 1000),
            effectiveFrom: DateTime(2026, 9),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
          Budget(
            id: 'food',
            categoryId: 'cat-food',
            limit: const Money(1500 * 1000),
            effectiveFrom: DateTime(2026, 9),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        ],
        rules: [testRule('Rent', 900, DateTime(2026, 9, 1))],
      ),
      clock: () => today,
    );
    await provider.load();
    return provider;
  }

  /// Shows [screen] in [language] on a phone at 1.3× text size.
  Future<void> show(
    WidgetTester tester,
    String language,
    Widget screen, {
    BackupService? backup,
    PurchaseService? purchases,
  }) async {
    usePhoneScreen(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final settings = await testSettings({'language': language});
    await tester.pumpWidget(
      testApp(
        await loadProvider(),
        settings,
        screen,
        backup: backup,
        purchases: purchases,
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  /// Drags [scrollable] to its end in bounded steps, so a lazy list lays out
  /// every child at least once (LANG-6, test-quality#8): otherwise only the
  /// first screenful — what a phone shows before scrolling — is ever built
  /// and checked for overflow. A no-op when nothing is scrollable (e.g. the
  /// report screen with no font for the language).
  Future<void> scrollToEnd(WidgetTester tester, Finder scrollable) async {
    if (scrollable.evaluate().isEmpty) return;
    var position = tester.state<ScrollableState>(scrollable).position;
    var guard = 0;
    while (position.pixels < position.maxScrollExtent && guard < 60) {
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pump();
      position = tester.state<ScrollableState>(scrollable).position;
      guard++;
    }
  }

  /// Screen names (as keyed in [screens]) whose content is a plain lazy
  /// `ListView`, so only the rows already on a phone's screen are ever laid
  /// out unless something scrolls the rest into view (test-quality#8).
  const lazyListScreens = {
    'Settings',
    'Backup',
    'Export PDF',
    'Transaction details',
    'Remove ads',
    'Recurring',
    'Budgets',
  };

  /// A file with something for every part of the import preview: two rows to
  /// import, one skipped for each reason, and names this app hasn't got.
  const importSample =
      'date,amount,type,category,account,to account,title,note\n'
      '2026-09-01,12.50,expense,Eating out,Savings,,Coffee and a pastry,'
      'paid by card\n'
      '2026-09-02,900,income,Salary,Savings,,Monthly pay,\n'
      '2026-09-03,100,transfer,Savings,,,Moving money,\n'
      'sometime,3,expense,Eating out,Savings,,Tea,\n'
      '2026-09-05,nothing,expense,Eating out,Savings,,Cake,\n'
      '2026-09-06,0,expense,Eating out,Savings,,Nothing at all,\n';

  /// A backup service whose open dialog hands back [importSample].
  BackupService withSampleCsv() => testBackupService(
    FakeDB(),
    files: FakeBackupFiles()..toOpen = utf8.encode(importSample),
  );

  const screens = <String, Widget>{
    'Home': HomeScreen(),
    'Add transaction': AddTransactionScreen(),
    'Transfer': TransferScreen(),
    'Search': SearchScreen(),
    'Insights': InsightsScreen(),
    'Budgets': BudgetsScreen(),
    'Recurring': RecurringScreen(),
    'Notes': NotesScreen(),
    'Note form': NoteFormScreen(),
    'Export PDF': ReportScreen(),
    'Settings': SettingsScreen(),
    'Backup': BackupScreen(),
    'Import': ImportScreen(),
    'Transaction details': TransactionDetailScreen(id: 'a'),
    'Setup': SetupScreen(),
    'Walkthrough': WalkthroughScreen(),
    'Remove ads': RemoveAdsScreen(),
  };

  group('deviceWeekStartIndex follows the device region, not just the '
      'language (PER-4, rules-1-5#5)', () {
    test('English (UK) is Monday, unlike plain English (Sunday)', () {
      expect(deviceWeekStartIndex(const [Locale('en', 'GB')], 'en'), 1);
    });

    test('Portugal is Monday, though intl reads Sunday for it, same as '
        'Brazil', () {
      expect(deviceWeekStartIndex(const [Locale('pt', 'PT')], 'pt'), 1);
      expect(deviceWeekStartIndex(const [Locale('pt', 'BR')], 'pt'), 0);
    });

    test('a language the user picked on purpose, unconnected to the '
        "device's region, defers to the caller's own default", () {
      // The device is set to English (US); the user chose French, so
      // the device's region says nothing about French's own default.
      expect(deviceWeekStartIndex(const [Locale('en', 'US')], 'fr'), isNull);
    });

    test('no device locale at all defers the same way', () {
      expect(deviceWeekStartIndex(const [], 'en'), isNull);
    });

    test('a device locale with no region defers the same way', () {
      expect(deviceWeekStartIndex(const [Locale('en')], 'en'), isNull);
    });

    test('a device set to a language the app lacks first, then the resolved '
        'one, still matches the resolved one, not just .first '
        '(rules-1-5#5)', () {
      // resolveAppLocale would match en_GB here, since the app has no
      // Norwegian — not deviceLocales.first, which is Norwegian.
      expect(
        deviceWeekStartIndex(const [
          Locale('nb', 'NO'),
          Locale('en', 'GB'),
        ], 'en'),
        1,
      );
    });
  });

  group('screens fit in every language at 1.3× text (LANG-6)', () {
    for (final language in appLanguages.keys) {
      final l10n = lookupAppLocalizations(Locale(language));
      for (final MapEntry(key: name, value: screen) in screens.entries) {
        testWidgets('$language: $name', (tester) async {
          await show(
            tester,
            language,
            screen,
            backup: screen is ImportScreen ? withSampleCsv() : null,
            // The price and the buy button are the longest text on that
            // screen, so it is checked with something to sell (PAY-6).
            purchases: screen is RemoveAdsScreen
                ? FakePurchases(stage: PurchaseStage.offered, price: 'US\$2.99')
                : null,
          );
          if (screen is HomeScreen) {
            // The budgets card, opened: a bar, amounts and a share each
            // (BUD-8).
            await tester.tap(find.text(l10n.budgetsTitle));
            await tester.pumpAndSettle();
            expect(find.text(l10n.drawerSpending), findsOne);
            // Every drawer row is text of its own, and the list is longer
            // than a phone, so it is scrolled through (NAV-1, NAV-2).
            tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
            await tester.pumpAndSettle();
            await tester.scrollUntilVisible(
              find.text(l10n.trashTitle),
              120,
              scrollable: find
                  .descendant(
                    of: find.byType(Drawer),
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            await tester.pumpAndSettle();
          }
          if (screen is ImportScreen) {
            // The preview is the part with the long labels in it.
            await tester.tap(find.text(l10n.importChooseFile));
            await tester.pumpAndSettle();
            expect(find.text(l10n.importColumnsHeader), findsOne);
          }
          if (screen is WalkthroughScreen) {
            // Each page carries its own text, so every one is looked at,
            // including the one that brings data in (RUN-4).
            for (var page = 1; page < 5; page++) {
              await tester.tap(find.text(l10n.walkthroughNextButton));
              await tester.pumpAndSettle();
            }
            expect(find.text(l10n.walkthroughBringTitle), findsOne);
          }
          if (screen is AddTransactionScreen) {
            // The label's own text lands on the field's RenderEditable
            // rather than the floating label once autofocus has already
            // opened the keypad, so this used to tap without proving
            // anything about tapping Amount actually opening it
            // (test-quality#12); the field itself is always hit-testable.
            await tester.tap(
              find.widgetWithText(TextFormField, l10n.amountLabel),
            );
            await tester.pump();
            expect(find.byType(AmountKeypad), findsOneWidget);
            // The keypad pushes the Save buttons further down the form's
            // own lazy list, so scroll past it to lay them out too
            // (test-quality#8).
            await scrollToEnd(
              tester,
              find
                  .descendant(
                    of: find.byType(Form),
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
          }
          if (screen is InsightsScreen) {
            for (final tab in [l10n.calendarTab, l10n.trendTab]) {
              await tester.tap(find.text(tab));
              await tester.pumpAndSettle();
            }
          }
          if (screen is ReportScreen) {
            if (ReportFonts.unsupportedLanguages.contains(language)) {
              // No face for this script, so the screen says so instead of
              // offering a report (PDF-7).
              expect(find.text(l10n.reportNoFontTitle), findsOne);
            } else {
              // The date fields and the year list only appear once chosen.
              for (final range in [
                l10n.reportRangeCustom,
                l10n.reportRangeYear,
              ]) {
                await tester.tap(find.text(range));
                await tester.pumpAndSettle();
              }
            }
          }
          if (lazyListScreens.contains(name)) {
            await scrollToEnd(tester, find.byType(Scrollable).first);
          }
        });
      }
    }
  });

  group('Arabic runs right to left (LANG-5)', () {
    final l10n = lookupAppLocalizations(const Locale('ar'));
    double x(WidgetTester tester, Finder finder) => tester.getCenter(finder).dx;

    testWidgets('the earlier-period arrow sits on the right', (tester) async {
      await show(tester, 'ar', const HomeScreen());
      expect(
        x(tester, find.byTooltip(l10n.previousPeriodTooltip)),
        greaterThan(x(tester, find.byTooltip(l10n.nextPeriodTooltip))),
      );
    });

    testWidgets('the drawer opens from the right (NAV-3)', (tester) async {
      await show(tester, 'ar', const HomeScreen());
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      // A phone is 360 wide here: the drawer is against the right edge.
      expect(tester.getTopRight(find.byType(Drawer)).dx, 360);
      expect(tester.getTopLeft(find.byType(Drawer)).dx, greaterThan(0));
    });

    testWidgets('the walkthrough skips on the left and runs right to left', (
      tester,
    ) async {
      await show(tester, 'ar', const WalkthroughScreen());
      // A phone is 360 wide here, so the end of the row is its left half.
      expect(x(tester, find.text(l10n.skipButton)), lessThan(180));

      final first = x(tester, find.text(l10n.walkthroughEntryTitle));
      await tester.tap(find.text(l10n.walkthroughNextButton));
      // One frame starts the slide, the next takes it partway.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The page being left moves right as the next one comes in from the
      // left (RUN-4, LANG-5).
      expect(
        x(tester, find.text(l10n.walkthroughEntryTitle)),
        greaterThan(first),
      );
      expect(
        x(tester, find.text(l10n.walkthroughPlanTitle)),
        lessThan(x(tester, find.text(l10n.walkthroughEntryTitle))),
      );
    });

    testWidgets('the previous-day arrow sits on the right', (tester) async {
      await show(tester, 'ar', const AddTransactionScreen());
      await revealInForm(tester, find.byTooltip(l10n.previousDayTooltip));
      expect(
        x(tester, find.byTooltip(l10n.previousDayTooltip)),
        greaterThan(x(tester, find.byTooltip(l10n.nextDayTooltip))),
      );
    });

    testWidgets('the keypad and the amount stay left to right', (tester) async {
      await show(tester, 'ar', const AddTransactionScreen());
      // The field's own RenderEditable, not the floating label text, which
      // autofocus already moved out from under the tap (test-quality#12).
      await tester.tap(find.widgetWithText(TextFormField, l10n.amountLabel));
      await tester.pump();

      Finder key(String label) => find.descendant(
        of: find.byType(AmountKeypad),
        matching: find.text(label),
      );
      expect(x(tester, key('7')), lessThan(x(tester, key('9'))));
      final amount = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, l10n.amountLabel),
          matching: find.byType(TextField),
        ),
      );
      expect(amount.textDirection, TextDirection.ltr);
      expect(amount.textAlign, TextAlign.right);
    });

    testWidgets('an imported row keeps its sign against its figures', (
      tester,
    ) async {
      await show(tester, 'ar', const ImportScreen(), backup: withSampleCsv());
      await tester.tap(find.text(l10n.importChooseFile));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.textContaining('12.50'), 200);
      await tester.pumpAndSettle();

      final amount = tester.widget<Text>(find.textContaining('12.50'));
      // Where it sits, not what the widget declares: the row used to force a
      // direction, and when that went the hand-pasted sign was left outside
      // the isolate and bidi carried it to the far end of the row (LANG-5).
      expectSignTouchesFigures(amount);
    });

    testWidgets(
      'a rising category keeps its plus against its figures, not floated '
      'to the far end of the line (INS-6, LANG-5, CUR-5)',
      (tester) async {
        await show(tester, 'ar', const InsightsScreen());

        // changeLabel used to paste a bare '+' in front of the formatted
        // percent, which bidi could carry to the far end of the line.
        final changeFinder = find.byWidgetPredicate(
          (widget) => widget is Text && (widget.data?.contains('+') ?? false),
        );
        await tester.dragUntilVisible(
          changeFinder,
          find.byType(Scrollable).first,
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
        expect(changeFinder, findsOneWidget);
        final change = tester.widget<Text>(changeFinder);
        expectSignTouchesFigures(change);
      },
    );

    testWidgets('the trend starts with the newest period on the left, and '
        'amounts sit on the right', (tester) async {
      await show(tester, 'ar', const InsightsScreen());
      await tester.tap(find.text(l10n.trendTab));
      await tester.pumpAndSettle();

      final chart = tester.widget<BarChart>(find.byType(BarChart)).data;
      expect(chart.barGroups.first.barRods.first.toY, 3000);
      expect(chart.barGroups.last.barRods.first.toY, 0);
      expect(chart.titlesData.rightTitles.sideTitles.showTitles, isTrue);
      expect(chart.titlesData.leftTitles.sideTitles.showTitles, isFalse);
    });
  });

  group('Urdu runs right to left as well (LANG-5)', () {
    final l10n = lookupAppLocalizations(const Locale('ur'));
    double x(WidgetTester tester, Finder finder) => tester.getCenter(finder).dx;

    test('it is listed as right to left, with Arabic', () {
      expect(rightToLeftLanguages, unorderedEquals({'ar', 'ur'}));
    });

    testWidgets('the earlier-period arrow sits on the right', (tester) async {
      await show(tester, 'ur', const HomeScreen());
      expect(
        x(tester, find.byTooltip(l10n.previousPeriodTooltip)),
        greaterThan(x(tester, find.byTooltip(l10n.nextPeriodTooltip))),
      );
    });

    testWidgets('the drawer opens from the right (NAV-3)', (tester) async {
      await show(tester, 'ur', const HomeScreen());
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      // A phone is 360 wide here: the drawer is against the right edge.
      expect(tester.getTopRight(find.byType(Drawer)).dx, 360);
    });

    testWidgets('the amount on a transaction keeps its figures in one piece', (
      tester,
    ) async {
      await show(tester, 'ur', const TransactionDetailScreen(id: 'a'));

      final amount = tester.widget<Text>(find.textContaining('1,234.50'));
      // Where the sign actually lands, not just whether the widget declares
      // a direction: that check alone passed either way (pr56+60#7).
      expectSignTouchesFigures(amount);
    });
  });
}
