import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/insights_screen.dart';

import 'helpers.dart';

/// Home showing one account instead of every one (ACC-6 to ACC-9).
void main() {
  const expense = TransactionType.expense;
  const income = TransactionType.income;
  const cash = Account.cashId;
  const bank = 'acct-bank';
  final today = DateTime(2026, 9, 15, 10);

  Money money(num amount) => Money((amount * 1000).round());

  /// Cash opens at 100, Bank at 50. In September: 30 spent and 200 earned on
  /// Cash, 7 spent on Bank.
  FakeDB twoAccounts({
    List<dynamic> extraTransfers = const [],
    DateTime? bankOpenedOn,
  }) {
    return FakeDB(
      transactions: [
        testTx('cash-spend', expense, 30, DateTime(2026, 9, 10)),
        testTx('cash-earn', income, 200, DateTime(2026, 9, 11)),
        testTx(
          'bank-spend',
          expense,
          7,
          DateTime(2026, 9, 12),
          accountId: bank,
        ),
      ],
      transfers: [...extraTransfers.cast()],
      accounts: [
        testAccount(cash, opening: 100),
        testAccount(bank, opening: 50, on: bankOpenedOn),
      ],
    );
  }

  Future<TransactionProvider> loaded(FakeDB db) async {
    final provider = TransactionProvider(db: db, clock: () => today);
    await provider.load();
    return provider;
  }

  group('what Home is showing (ACC-6)', () {
    test(
      'every account by default, and the totals cover all of them',
      () async {
        final provider = await loaded(twoAccounts());

        expect(provider.accountFilterId, isNull);
        expect(provider.periodExpense, money(37));
        expect(provider.periodIncome, money(200));
      },
    );

    test('one account leaves the other one out of the totals', () async {
      final provider = await loaded(twoAccounts());

      provider.selectAccountFilter(bank);

      expect(provider.accountFilterId, bank);
      expect(provider.periodExpense, money(7));
      expect(provider.periodIncome, Money.zero);
    });

    test('and out of the day list and each day\'s totals (ACC-7)', () async {
      final provider = await loaded(twoAccounts());

      provider.selectAccountFilter(bank);

      final ids = [
        for (final day in provider.groupedByDay.values)
          for (final tx in day) tx.id,
      ];
      expect(ids, ['bank-spend']);
      expect(provider.dailyTotals[DateTime(2026, 9, 10)], isNull);
      expect(provider.dailyTotals[DateTime(2026, 9, 12)]?.expense, money(7));
    });

    test('going back to every account restores the totals', () async {
      final provider = await loaded(twoAccounts());

      provider
        ..selectAccountFilter(bank)
        ..selectAccountFilter(null);

      expect(provider.periodExpense, money(37));
    });

    test(
      'an account archived since it was chosen falls back to every one',
      () async {
        final db = twoAccounts();
        final provider = await loaded(db);
        provider.selectAccountFilter(bank);
        expect(provider.periodExpense, money(7));

        await provider.archiveAccount(bank);

        expect(provider.accountFilterId, isNull);
        expect(provider.periodExpense, money(37));
      },
    );

    test('an account that is not there at all falls back too', () async {
      final provider = await loaded(twoAccounts());

      provider.selectAccountFilter('never-existed');

      expect(provider.accountFilterId, isNull);
      expect(provider.periodExpense, money(37));
    });
  });

  group('one account\'s balance (ACC-8)', () {
    test('carries forward only that account\'s opening balance', () async {
      final provider = await loaded(twoAccounts());

      provider.selectAccountFilter(bank);

      // Bank opened at 50 before September and spent 7 in it.
      expect(provider.carriedForward, money(50));
      expect(provider.closingBalance, money(43));
    });

    test(
      'a transfer in counts, though it is neither income nor expense',
      () async {
        final provider = await loaded(
          twoAccounts(
            extraTransfers: [
              testTransfer('t1', cash, bank, 25, DateTime(2026, 9, 13)),
            ],
          ),
        );

        provider.selectAccountFilter(bank);

        // BAL-1: still no income, and the expense is unchanged.
        expect(provider.periodIncome, Money.zero);
        expect(provider.periodExpense, money(7));
        // ACC-4: but the money did arrive, so the balance has it.
        expect(provider.closingBalance, money(68));
      },
    );

    test('and a transfer out takes it away again', () async {
      final provider = await loaded(
        twoAccounts(
          extraTransfers: [
            testTransfer('t1', bank, cash, 25, DateTime(2026, 9, 13)),
          ],
        ),
      );

      provider.selectAccountFilter(bank);

      expect(provider.closingBalance, money(18));
    });

    test('a transfer before the period carries forward', () async {
      final provider = await loaded(
        twoAccounts(
          extraTransfers: [
            testTransfer('t1', cash, bank, 25, DateTime(2026, 8, 20)),
          ],
        ),
      );

      provider.selectAccountFilter(bank);

      expect(provider.carriedForward, money(75));
      expect(provider.closingBalance, money(68));
    });

    test('an upcoming transfer counts nowhere yet (BAL-4)', () async {
      final provider = await loaded(
        twoAccounts(
          extraTransfers: [
            testTransfer('t1', cash, bank, 25, DateTime(2026, 9, 30)),
          ],
        ),
      );

      provider.selectAccountFilter(bank);

      expect(provider.closingBalance, money(43));
      // It is still listed, as upcoming.
      expect(provider.periodTransfers.map((t) => t.id), ['t1']);
    });

    test('across every account a transfer still nets to zero', () async {
      final provider = await loaded(
        twoAccounts(
          extraTransfers: [
            testTransfer('t1', cash, bank, 25, DateTime(2026, 9, 13)),
          ],
        ),
      );

      // 150 opening + 200 earned − 37 spent, with the transfer cancelling out.
      expect(provider.closingBalance, money(313));
    });
  });

  group('the transfers Home lists', () {
    test('only the ones touching the chosen account', () async {
      final provider = await loaded(
        twoAccounts(
          extraTransfers: [
            testTransfer('touches', cash, bank, 25, DateTime(2026, 9, 13)),
            testTransfer('elsewhere', 'a', 'b', 5, DateTime(2026, 9, 14)),
          ],
        ),
      );

      provider.selectAccountFilter(bank);

      expect(provider.periodTransfers.map((t) => t.id), ['touches']);
    });

    test('every one of them when Home shows every account', () async {
      final provider = await loaded(
        twoAccounts(
          extraTransfers: [
            testTransfer('touches', cash, bank, 25, DateTime(2026, 9, 13)),
            testTransfer('elsewhere', 'a', 'b', 5, DateTime(2026, 9, 14)),
          ],
        ),
      );

      expect(provider.periodTransfers.length, 2);
    });
  });

  group('what a new entry starts on (ACC-9)', () {
    test('the chosen account, ahead of the last one used', () async {
      final provider = await loaded(twoAccounts());
      // The newest transaction is on Bank, so without a choice that wins.
      expect(provider.defaultAccountId(), bank);

      provider.selectAccountFilter(cash);

      expect(provider.defaultAccountId(), cash);
    });

    test('the last one used again once Home shows every account', () async {
      final provider = await loaded(twoAccounts());

      provider
        ..selectAccountFilter(cash)
        ..selectAccountFilter(null);

      expect(provider.defaultAccountId(), bank);
    });
  });

  group('what the choice does not reach', () {
    testWidgets('the card\'s lead line goes while one account is on (BAL-9)', (
      tester,
    ) async {
      final provider = await loaded(twoAccounts());
      final settings = await testSettings();
      await tester.pumpWidget(testApp(provider, settings, const HomeScreen()));
      await tester.pumpAndSettle();
      // Every account: the line is there, and so is its offer.
      expect(find.text('Set a monthly budget'), findsOneWidget);

      provider.selectAccountFilter(bank);
      await settings.setAccountFilterId(bank);
      await tester.pumpAndSettle();

      // One account: gone entirely. A budget counts every account (ACC-7),
      // so the figure would be every account's under a label naming one.
      expect(find.text('Set a monthly budget'), findsNothing);
      expect(find.textContaining('a day so far'), findsNothing);
    });

    test('budgets keep measuring every account (ACC-7)', () async {
      // A $50 food budget. All the food spending is on Cash; Bank Card has
      // none of it. Found on the phone: with Bank Card chosen the card read
      // "0% used" of a budget that is in fact 60% gone.
      final db = FakeDB(
        transactions: [
          testTx('cash-food', expense, 30, DateTime(2026, 9, 10)),
          testTx(
            'bank-other',
            expense,
            7,
            DateTime(2026, 9, 12),
            accountId: bank,
            categoryId: 'cat-transport',
          ),
        ],
        accounts: [
          testAccount(cash, opening: 100),
          testAccount(bank, opening: 50),
        ],
        budgets: [
          Budget(
            id: 'b-food',
            categoryId: 'cat-food',
            limit: money(50),
            effectiveFrom: DateTime(2026, 9),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        ],
      );
      final provider = await loaded(db);

      Money foodSpent() => provider.budgetStatuses
          .firstWhere((s) => s.categoryId == 'cat-food')
          .spent;

      expect(foodSpent(), money(30));

      provider.selectAccountFilter(bank);

      // Home's own totals follow the account...
      expect(provider.periodExpense, money(7));
      // ...but the budget does not: the limit was never per-account.
      expect(foodSpent(), money(30));
    });

    test('the home-screen widget still shows the whole of the money', () async {
      final provider = await loaded(twoAccounts());

      provider.selectAccountFilter(bank);

      final entry = provider.widgetTimeline().first;
      expect(entry.expense, money(37));
      expect(entry.income, money(200));
    });

    testWidgets('Export CSV carries every account, not just the chosen one '
        '(ACC-7, BAK-5)', (tester) async {
      const savings = 'acct-savings';
      final db = twoAccounts(
        extraTransfers: [
          testTransfer('t1', cash, savings, 10, DateTime(2026, 9, 13)),
        ],
      );
      db.accounts.add(testAccount(savings, opening: 0));
      final provider = await loaded(db);
      final settings = await testSettings();
      final files = FakeBackupFiles();

      provider.selectAccountFilter(bank);
      await settings.setAccountFilterId(bank);

      await tester.pumpWidget(
        testApp(
          provider,
          settings,
          const HomeScreen(),
          backup: testBackupService(FakeDB(), files: files),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Export CSV'),
        120,
        scrollable: find
            .descendant(
              of: find.byType(Drawer),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export CSV'));
      await tester.pumpAndSettle();

      final csv = utf8.decode(
        files.saved['monthly-expenses-2026-09-01_2026-09-30.csv']!,
      );
      // ACC-7: the CSV export is one of the things the account choice must
      // not reach, so with Bank chosen, Cash's rows are still there.
      expect(csv, contains('cash-spend'));
      expect(csv, contains('bank-spend'));
      expect(csv, contains(cash));
      expect(csv, contains(savings));
    });
  });

  group('driving it on Home', () {
    testWidgets('the wallet picks an account, and the card says which', (
      tester,
    ) async {
      usePhoneScreen(tester);
      // Home opens on today and lists that day alone (DAY-1), so both
      // entries are dated today for the list to have anything to filter.
      final provider = await loaded(
        FakeDB(
          transactions: [
            testTx('cash-spend', expense, 30, today),
            testTx('bank-spend', expense, 7, today, accountId: bank),
          ],
          accounts: [
            testAccount(cash, opening: 100),
            testAccount(bank, opening: 50),
          ],
        ),
      );
      final settings = await testSettings();
      await tester.pumpWidget(testApp(provider, settings, const HomeScreen()));
      await tester.pumpAndSettle();

      // Every account to begin with: the label is the balance, not a name.
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text(bank), findsNothing);

      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      expect(find.text('All accounts'), findsOneWidget);

      await tester.tap(find.text(bank).last);
      await tester.pumpAndSettle();

      // ACC-6: the account's name stands in for the label.
      expect(find.text('Balance'), findsNothing);
      expect(find.text(bank), findsWidgets);
      expect(provider.accountFilterId, bank);
      // ACC-6: and it is saved, so the next launch opens on it.
      expect(settings.accountFilterId, bank);
      // ACC-7: the day list is that account's alone.
      expect(find.text('cash-spend'), findsNothing);
      expect(find.text('bank-spend'), findsOneWidget);
    });

    testWidgets('Insights names the account it is showing, and only then', (
      tester,
    ) async {
      usePhoneScreen(tester);
      final provider = await loaded(twoAccounts());
      final settings = await testSettings();
      await tester.pumpWidget(
        testApp(provider, settings, const InsightsScreen()),
      );
      await tester.pumpAndSettle();

      // Every account: nothing is being hidden, so nothing is said.
      expect(find.text(bank), findsNothing);
      // The way to change it is there, because there are two accounts.
      expect(
        find.byIcon(Icons.account_balance_wallet_outlined),
        findsOneWidget,
      );

      provider.selectAccountFilter(bank);
      await tester.pumpAndSettle();

      // ACC-6: now it has something to say, it says it.
      expect(find.text(bank), findsWidgets);
    });

    testWidgets('with one account there is no control at all (ACC-6)', (
      tester,
    ) async {
      usePhoneScreen(tester);
      final provider = await loaded(
        FakeDB(accounts: [testAccount(cash, opening: 100)]),
      );
      final settings = await testSettings();
      await tester.pumpWidget(
        testApp(provider, settings, const InsightsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsNothing);
    });

    testWidgets('and hands every account back again (ACC-6)', (tester) async {
      usePhoneScreen(tester);
      final provider = await loaded(
        FakeDB(
          transactions: [
            testTx('cash-spend', expense, 30, today),
            testTx('bank-spend', expense, 7, today, accountId: bank),
          ],
          accounts: [
            testAccount(cash, opening: 100),
            testAccount(bank, opening: 50),
          ],
        ),
      );
      final settings = await testSettings();
      provider.selectAccountFilter(bank);
      await settings.setAccountFilterId(bank);
      await tester.pumpWidget(testApp(provider, settings, const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      // The sheet says which account is chosen, to a screen reader as well
      // as to the eye.
      expect(
        tester.widget<ListTile>(find.widgetWithText(ListTile, bank)).selected,
        isTrue,
      );
      await tester.tap(find.text('All accounts'));
      await tester.pumpAndSettle();

      // ACC-6: back to the whole of the money, label and all, and the device
      // forgets the choice rather than opening on it again.
      expect(provider.accountFilterId, isNull);
      expect(settings.accountFilterId, isNull);
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('cash-spend'), findsOneWidget);
    });

    testWidgets('Insights switches from its toolbar and its banner', (
      tester,
    ) async {
      usePhoneScreen(tester);
      final provider = await loaded(twoAccounts());
      final settings = await testSettings();
      await tester.pumpWidget(
        testApp(provider, settings, const InsightsScreen()),
      );
      await tester.pumpAndSettle();

      // The toolbar's wallet opens the same sheet Home's does.
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      expect(find.text('All accounts'), findsOneWidget);
      await tester.tap(find.text(bank).last);
      await tester.pumpAndSettle();
      expect(provider.accountFilterId, bank);
      expect(settings.accountFilterId, bank);

      // ACC-6: the banner naming the account is itself the way to change it,
      // so a filtered screen never has to be left to undo the filter.
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined).last);
      await tester.pumpAndSettle();
      expect(find.text('All accounts'), findsOneWidget);
      await tester.tap(find.text('All accounts'));
      await tester.pumpAndSettle();
      expect(provider.accountFilterId, isNull);
    });

    testWidgets('and the banner puts every account back in one tap', (
      tester,
    ) async {
      usePhoneScreen(tester);
      final provider = await loaded(twoAccounts());
      final settings = await testSettings();
      provider.selectAccountFilter(bank);
      await settings.setAccountFilterId(bank);
      await tester.pumpWidget(
        testApp(provider, settings, const InsightsScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(provider.accountFilterId, isNull);
      expect(settings.accountFilterId, isNull);
      // ACC-6: with nothing hidden there is nothing to say, so the banner goes.
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('the one line keeps the way back (ACC-6, BAL-6)', (
      tester,
    ) async {
      usePhoneScreen(tester);
      final provider = await loaded(twoAccounts());
      final settings = await testSettings();
      // The state a scroll leaves Home in, and the one it opens in when that
      // is how it was left.
      await settings.setSummaryCollapsed(true);
      await tester.pumpWidget(testApp(provider, settings, const HomeScreen()));
      await tester.pumpAndSettle();

      // Every account: nothing to say, so no control and no room spent on it.
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsNothing);

      provider.selectAccountFilter(bank);
      await tester.pumpAndSettle();

      // One account: the line names it (BAL-6) and hands it back in one tap,
      // without the card having to be opened first.
      expect(find.text(bank), findsOneWidget);
      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All accounts'));
      await tester.pumpAndSettle();

      expect(provider.accountFilterId, isNull);
      expect(settings.accountFilterId, isNull);
      expect(find.text('Balance'), findsOneWidget);
    });

    testWidgets('a long account name gives way rather than overflowing', (
      tester,
    ) async {
      usePhoneScreen(tester);
      // An account's name is the user's own words, and the one line has the
      // balance to fit as well (LANG-4).
      const long = 'Joint savings account at the building society';
      final provider = await loaded(
        FakeDB(
          transactions: [testTx('cash-spend', expense, 30, today)],
          accounts: [
            testAccount(cash, opening: 100),
            testAccount(long, opening: 5000),
          ],
        ),
      );
      final settings = await testSettings();
      await settings.setSummaryCollapsed(true);
      provider.selectAccountFilter(long);
      await tester.pumpWidget(testApp(provider, settings, const HomeScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(long), findsOneWidget);
    });

    testWidgets('the one line runs to its own edge (BAL-6)', (tester) async {
      usePhoneScreen(tester);
      final provider = await loaded(twoAccounts());
      final settings = await testSettings();
      await settings.setSummaryCollapsed(true);
      await tester.pumpWidget(testApp(provider, settings, const HomeScreen()));
      await tester.pumpAndSettle();

      // A short label is the case that catches it: two flexible children
      // would split the row between them, "Balance" would hand its half
      // back, and the balance and the chevron would sit stranded mid-card
      // with a hole after them. The balance takes what it needs, the label
      // what is left, and the chevron lands on the edge.
      final row = tester.getRect(
        find
            .ancestor(of: find.text('Balance'), matching: find.byType(Row))
            .first,
      );
      final label = tester.getRect(find.text('Balance'));
      final chevron = tester.getRect(find.byIcon(Icons.expand_more));
      expect(label.left, moreOrLessEquals(row.left, epsilon: 0.5));
      expect(chevron.right, moreOrLessEquals(row.right, epsilon: 0.5));
    });

    test(
      'the sheet offers every account that is not archived (ACC-5)',
      () async {
        final db = twoAccounts();
        final provider = await loaded(db);
        await provider.archiveAccount(bank);

        expect(provider.activeAccounts.map((a) => a.id), [cash]);
      },
    );
  });

  group('the choice is remembered on this device', () {
    test('a saved account comes back, and clearing it removes it', () async {
      final settings = await testSettings();
      expect(settings.accountFilterId, isNull);

      await settings.setAccountFilterId(bank);
      expect(settings.accountFilterId, bank);

      await settings.setAccountFilterId(null);
      expect(settings.accountFilterId, isNull);
    });

    test(
      'both the choice and its clearing survive a relaunch (ACC-6)',
      () async {
        final settings = await testSettings();
        Future<String?> relaunched() async =>
            SettingsProvider(await SharedPreferences.getInstance())
                .accountFilterId;

        await settings.setAccountFilterId(bank);
        expect(await relaunched(), bank);

        // "All accounts" chosen: the next launch opens on every account.
        await settings.setAccountFilterId(null);
        expect(await relaunched(), isNull);
      },
    );
  });
}
