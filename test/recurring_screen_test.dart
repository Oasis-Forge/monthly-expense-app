import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/recurring_rule_screen.dart';
import 'package:monthly_expense_app/screens/recurring_screen.dart';

import 'helpers.dart';

/// A [FakeDB] whose recurring-rule insert takes a beat, wide enough for a
/// second Save tap to land before the first save finishes
/// (data-integrity#5).
class _SlowRuleDB extends FakeDB {
  @override
  Future<void> insertRecurringRule(RecurringRule rule) async {
    await Future.delayed(const Duration(milliseconds: 60));
    await super.insertRecurringRule(rule);
  }
}

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    // Rent came due on Sep 1; Gym starts on Sep 20.
    fake = FakeDB(
      rules: [
        testRule('Rent', 900, DateTime(2026, 9)),
        testRule('Gym', 30, DateTime(2026, 9, 20)),
      ],
    );
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings();
  });

  Future<void> showRecurring(WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(provider, settings, const RecurringScreen()),
    );
    await tester.pump();
  }

  /// Opens the rule form, on a phone screen, from a placeholder page.
  Future<void> openForm(WidgetTester tester, {RecurringRule? editing}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecurringRuleScreen(editing: editing),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String label, String text) async {
    final field = find.widgetWithText(TextFormField, label);
    await revealInForm(tester, field);
    await tester.enterText(field, text);
  }

  Future<void> tapInForm(WidgetTester tester, Finder finder) async {
    await revealInForm(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) =>
      tapInForm(tester, find.widgetWithText(FilledButton, 'Save'));

  RecurringRule savedRule(String title) =>
      provider.recurringRules.firstWhere((r) => r.title == title);

  group('recurring screen', () {
    testWidgets('lists due, upcoming, and rules (RCR-2, RCR-7)', (
      tester,
    ) async {
      await showRecurring(tester);

      expect(find.text('Due'), findsOneWidget);
      expect(find.text('Next 30 days'), findsOneWidget);
      // Rent is due (Sep 1), upcoming (Oct 1), and a rule; Gym is upcoming
      // (Sep 20) and a rule.
      expect(find.text('Rent'), findsNWidgets(3));
      expect(find.text('Gym'), findsNWidgets(2));
      expect(find.text('Every month'), findsNWidgets(2));
    });

    testWidgets('posting a due occurrence adds the transaction', (
      tester,
    ) async {
      await showRecurring(tester);

      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      expect(provider.transactions.single.title, 'Rent');
      expect(find.text('Due'), findsNothing);
    });

    testWidgets('skipping a due occurrence adds nothing', (tester) async {
      await showRecurring(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(provider.transactions, isEmpty);
      expect(fake.occurrences.single.status, OccurrenceStatus.skipped);
      expect(find.text('Due'), findsNothing);
    });

    testWidgets('tapping a due occurrence posts an edited amount (RCR-2)', (
      tester,
    ) async {
      await showRecurring(tester);

      await tester.tap(find.text('Rent').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Post').last);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid amount'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '950');
      await tester.tap(find.widgetWithText(FilledButton, 'Post').last);
      await tester.pumpAndSettle();

      expect(provider.transactions.single.amount, const Money(950000));
    });

    testWidgets(
      "the post dialog's amount field symbol side matches the locale's "
      'display side, in German (CUR-5, LANG-5, pr61#11)',
      (tester) async {
        // German writes the symbol after the figures, unlike English.
        settings = await testSettings({'language': 'de'});
        await showRecurring(tester);

        await tester.tap(find.text('Rent').first);
        await tester.pumpAndSettle();

        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField),
            matching: find.byType(TextField),
          ),
        );
        expect(field.decoration?.prefixText, isNull);
        expect(field.decoration?.suffixText, contains('\$'));
      },
    );

    testWidgets('cancelling the amount dialog posts nothing', (tester) async {
      await showRecurring(tester);

      await tester.tap(find.text('Rent').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(provider.transactions, isEmpty);
    });

    testWidgets('a failed post shows an error', (tester) async {
      fake.failWrites = true;
      await showRecurring(tester);

      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't post the transaction. Try again."),
        findsOneWidget,
      );
      expect(provider.dueOccurrences, hasLength(1));
    });

    testWidgets('a rule can be paused, resumed, and deleted (RCR-5, RCR-6)', (
      tester,
    ) async {
      await showRecurring(tester);

      await tester.tap(find.text('Rent').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Pause'));
      await tester.pumpAndSettle();
      expect(provider.recurringRuleById('Rent')!.isPaused, isTrue);

      await tester.tap(find.byTooltip('Resume'));
      await tester.pumpAndSettle();
      expect(provider.recurringRuleById('Rent')!.isPaused, isFalse);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(provider.recurringRuleById('Rent'), isNull);
      expect(find.byType(RecurringRuleScreen), findsNothing);
    });

    testWidgets('a deleted rule comes back with Undo (DEL-2, rules-6-10#12)', (
      tester,
    ) async {
      await showRecurring(tester);

      await tester.tap(find.text('Rent').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      expect(provider.recurringRuleById('Rent'), isNull);
      expect(find.text('Recurring transaction deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect({for (final r in provider.recurringRules) r.id}, {'Rent', 'Gym'});
      expect(fake.rules.firstWhere((r) => r.id == 'Rent').deletedAt, isNull);
      // Rent's 1 Sep is waiting in Due again.
      expect(provider.dueOccurrences, hasLength(1));
    });

    testWidgets('pausing or resuming and then saving keeps the change '
        '(RCR-5, RCR-6, audit rules-6-10#3)', (tester) async {
      await showRecurring(tester);

      await tester.tap(find.text('Rent').last);
      await tester.pumpAndSettle();
      await tapInForm(tester, find.byTooltip('Pause'));
      expect(provider.recurringRuleById('Rent')!.isPaused, isTrue);

      await save(tester);
      expect(provider.recurringRuleById('Rent')!.isPaused, isTrue);

      await tester.tap(find.text('Rent').last);
      await tester.pumpAndSettle();
      await tapInForm(tester, find.byTooltip('Resume'));
      expect(provider.recurringRuleById('Rent')!.isPaused, isFalse);

      await save(tester);
      expect(provider.recurringRuleById('Rent')!.isPaused, isFalse);
    });
  });

  group('rule form (RCR-1)', () {
    testWidgets('a new rule waits for a tap by default', (tester) async {
      await openForm(tester);

      await enter(tester, 'Amount', '15');
      await enter(tester, 'Title (optional)', 'Streaming');
      await save(tester);

      final rule = savedRule('Streaming');
      expect(
        (rule.autoPost, rule.amount, rule.frequency, rule.interval),
        (false, const Money(15000), RecurrenceFrequency.month, 1),
      );
      expect(find.byType(RecurringRuleScreen), findsNothing);
    });

    testWidgets('double-tapping Save on a new rule creates only one '
        '(audit data-integrity#5)', (tester) async {
      final slowFake = _SlowRuleDB();
      final slowProvider = TransactionProvider(
        db: slowFake,
        clock: () => DateTime(2026, 9, 15),
      );
      await slowProvider.load();
      final slowSettings = await testSettings();

      // Push the form as a route, the way the Recurring screen does, so a
      // completed save can pop back to a real screen underneath.
      usePhoneScreen(tester);
      await tester.pumpWidget(
        testApp(
          slowProvider,
          slowSettings,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RecurringRuleScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final amountField = find.widgetWithText(TextFormField, 'Amount');
      await revealInForm(tester, amountField);
      await tester.enterText(amountField, '900');

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      await revealInForm(tester, saveButton);

      // Two taps close together, as a real double-tap (or a retry after a
      // slow first save) would land.
      await tester.tap(saveButton);
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tap(saveButton);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(slowProvider.recurringRules, hasLength(1));
    });

    testWidgets('frequency, interval, end, and auto-post are saved', (
      tester,
    ) async {
      await openForm(tester);
      final start = DateTime.now();

      await enter(tester, 'Amount', '20');
      await enter(tester, 'Title (optional)', 'Lessons');
      await enter(tester, 'Every', '2');
      await tapInForm(tester, find.text('Months'));
      await tester.tap(find.text('Weeks').last);
      await tester.pumpAndSettle();
      await tapInForm(tester, find.byTooltip('Next day').first);
      await tapInForm(tester, find.text('After'));
      await enter(tester, 'Times', '3');
      await tapInForm(tester, find.text('Post automatically'));
      await save(tester);

      final rule = savedRule('Lessons');
      expect(
        (
          rule.frequency,
          rule.interval,
          rule.endType,
          rule.endCount,
          rule.autoPost,
        ),
        (RecurrenceFrequency.week, 2, RecurrenceEnd.afterCount, 3, true),
      );
      expect(rule.startDate, DateTime(start.year, start.month, start.day + 1));
    });

    testWidgets('whole numbers from 1 are required', (tester) async {
      await openForm(tester);

      await enter(tester, 'Amount', '20');
      await enter(tester, 'Every', '0');
      await tapInForm(tester, find.text('After'));
      await save(tester);

      await revealInForm(tester, find.text('Enter a whole number from 1'));
      expect(find.text('Enter a whole number from 1'), findsOneWidget);
      expect(find.text('Enter a whole number from 1 to 999'), findsOneWidget);
    });

    testWidgets('the interval error names its maximum (review-state-3)', (
      tester,
    ) async {
      await openForm(tester);

      await enter(tester, 'Amount', '20');
      await enter(tester, 'Every', '1000');
      await save(tester);

      await revealInForm(
        tester,
        find.text('Enter a whole number from 1 to 999'),
      );
      expect(find.text('Enter a whole number from 1 to 999'), findsOneWidget);
      expect(provider.recurringRules, hasLength(2));
    });

    testWidgets('the repeat count has no cap, so a rule with a long count '
        'still saves (RCR-1, review-state-3)', (tester) async {
      final daily = testRule('Rent', 900, DateTime(2026, 9)).copyWith(
        frequency: RecurrenceFrequency.day,
        endType: RecurrenceEnd.afterCount,
        endCount: 1095,
      );
      fake.rules
        ..clear()
        ..add(daily);
      await provider.load();
      await openForm(tester, editing: provider.recurringRuleById('Rent'));

      await enter(tester, 'Amount', '950');
      await save(tester);

      expect(find.byType(RecurringRuleScreen), findsNothing);
      final rule = provider.recurringRuleById('Rent')!;
      expect((rule.amount, rule.endCount), (const Money(950000), 1095));

      await openForm(tester);
      await enter(tester, 'Amount', '5');
      await enter(tester, 'Title (optional)', 'Coffee');
      await tapInForm(tester, find.text('After'));
      await enter(tester, 'Times', '100000');
      await save(tester);
      expect(savedRule('Coffee').endCount, 100000);
    });

    testWidgets(
      'an interval large enough to overflow the date range is rejected '
      '(audit money-time#7)',
      (tester) async {
        await openForm(tester);

        await enter(tester, 'Amount', '20');
        await enter(tester, 'Every', '300000');
        await save(tester);

        expect(find.byType(RecurringRuleScreen), findsOneWidget);
        // Only the two rules from setUp (Rent, Gym); nothing new was saved.
        expect(provider.recurringRules, hasLength(2));
      },
    );

    testWidgets('an end date before the start is rejected', (tester) async {
      final invalid = testRule(
        'Rent',
        900,
        DateTime(2026, 9),
      ).copyWith(endType: RecurrenceEnd.onDate, endDate: DateTime(2026, 8));
      await openForm(tester, editing: invalid);

      await save(tester);

      expect(find.text('The end date must be after the start'), findsOneWidget);
      expect(find.byType(RecurringRuleScreen), findsOneWidget);
    });

    testWidgets('editing can switch the type and ends on a date', (
      tester,
    ) async {
      await openForm(tester, editing: provider.recurringRuleById('Gym'));

      await tapInForm(tester, find.text('Income'));
      await tapInForm(tester, find.text('On date'));
      await save(tester);

      final rule = provider.recurringRuleById('Gym')!;
      expect(
        (rule.type, rule.categoryId, rule.endType),
        (TransactionType.income, 'cat-salary', RecurrenceEnd.onDate),
      );
      expect(rule.endDate, DateTime(2027, 9, 20));
    });

    testWidgets('with two accounts the rule can use either', (tester) async {
      fake.accounts.add(testAccount('bank'));
      await provider.load();
      await openForm(tester);

      await enter(tester, 'Amount', '5');
      await enter(tester, 'Title (optional)', 'Fees');
      await tapInForm(
        tester,
        find.widgetWithText(DropdownButtonFormField<String>, 'acc-cash'),
      );
      await tester.tap(find.text('bank').last);
      await tester.pumpAndSettle();
      await save(tester);

      expect(savedRule('Fees').accountId, 'bank');
      // Transactions still default to Cash; only this rule uses the bank.
      expect(provider.defaultAccountId(), Account.cashId);
    });

    testWidgets('failed saves and pauses show an error', (tester) async {
      await openForm(tester, editing: provider.recurringRuleById('Gym'));
      fake.failWrites = true;

      await tester.tap(find.byTooltip('Pause'));
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't save the recurring transaction. Try again."),
        findsOneWidget,
      );

      // The pause's snack bar sits over the Save button; clear it first so
      // the tap actually reaches Save instead of silently landing on the
      // snack bar (test-quality#5).
      ScaffoldMessenger.of(tester.element(find.byType(RecurringRuleScreen)))
          .removeCurrentSnackBar();
      await tester.pumpAndSettle();

      await save(tester);
      expect(
        find.text("Couldn't save the recurring transaction. Try again."),
        findsOneWidget,
      );
      expect(find.byType(RecurringRuleScreen), findsOneWidget);
      expect(provider.recurringRuleById('Gym')!.isPaused, isFalse);
    });
  });

  testWidgets('the screen says what the rules cost a month and what is next '
      '(RCR-8)', (tester) async {
    // Rent moved off the first, so nothing is overdue: the next line stays
    // silent while anything is waiting (RCR-8).
    fake.rules
      ..clear()
      ..addAll([
        testRule('Rent', 900, DateTime(2026, 10)),
        testRule('Gym', 30, DateTime(2026, 9, 20)),
      ]);
    await provider.load();
    await showRecurring(tester);

    // Rent 900 a month and Gym 30 a month, with Gym falling on the 20th.
    expect(find.text('\$930 a month in bills'), findsOneWidget);
    expect(find.text('Next: Gym, in 5 days'), findsOneWidget);
  });

  testWidgets('every row on the screen starts at the same left edge (CAT-6)', (
    tester,
  ) async {
    // Due, upcoming and rules are three lists on one screen. A bare icon in
    // any of them sits narrower than a CircleAvatar, and ListTile insets its
    // title from the leading widget, so one odd row pulls a whole list out
    // of line with the others.
    await showRecurring(tester);

    final avatars = find.descendant(
      of: find.byType(ListTile),
      matching: find.byType(CircleAvatar),
    );
    expect(avatars, findsWidgets);

    final lefts = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => tile.leading.runtimeType)
        .toSet();
    expect(lefts, {
      CircleAvatar,
    }, reason: 'every row leads with the same shape, or the titles stagger');
  });

  testWidgets('nothing is named next while something is overdue (RCR-8)', (
    tester,
  ) async {
    // The shared rules leave rent waiting since the first. "Next: Gym, in 5
    // days" over a list of things already due is a contradiction.
    await showRecurring(tester);

    expect(find.text('Due'), findsOneWidget);
    expect(find.text('\$930 a month in bills'), findsOneWidget);
    expect(find.textContaining('Next:'), findsNothing);
  });

  testWidgets('rules that are all income leave the total out (RCR-8)', (
    tester,
  ) async {
    fake.rules
      ..clear()
      ..add(
        testRule(
          'Salary',
          2000,
          DateTime(2026, 9, 20),
        ).copyWith(type: TransactionType.income),
      );
    await provider.load();
    await showRecurring(tester);

    expect(find.textContaining('a month in bills'), findsNothing);
    expect(find.text('Next: Salary, in 5 days'), findsOneWidget);
  });
}
