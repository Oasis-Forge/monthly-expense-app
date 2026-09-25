import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/report.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transaction_filter.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/report_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    fake = FakeDB(
      transactions: [
        testTx('a', TransactionType.expense, 25, DateTime(2026, 9, 4)),
        testTx('b', TransactionType.income, 900, DateTime(2026, 9, 2)),
        testTx('old', TransactionType.expense, 12, DateTime(2025, 4, 3)),
      ],
    );
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings();
  });

  /// Pumps until [finder] matches, or gives up. The preview never settles in
  /// a widget test — PdfPreview keeps a spinner going, because rasterising a
  /// PDF needs the platform — so pumpAndSettle can't be used past it.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int frames = 100,
  }) async {
    // buildReportPdf's page layout now runs on a real background isolate
    // (report_pdf.dart, PDF-6): that future only settles on the real event
    // loop, not the fake one this test's pump runs on. So each round gives
    // the isolate some real time via runAsync, then pumps the fake zone so
    // the continuation that woke up when it finished actually runs.
    for (var i = 0; i < frames; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      // A duration has to be passed here, not pump(): with none, the fake
      // clock doesn't advance and a chain of zero-delay timers (step() in
      // buildReportPdf) never drains, so this would just spin for [frames]
      // rounds and time out instead of ever finding [finder].
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  Future<void> showReport(
    WidgetTester tester, {
    TransactionFilter? filter,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(provider, settings, ReportScreen(filter: filter)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('in a language with no face it explains instead of offering a '
      'report (PDF-7)', (tester) async {
    settings = await testSettings({'language': 'ja'});

    await showReport(tester);

    expect(find.text('この言語はまだ利用できません'), findsOneWidget);
    // None of the choosing is there: there is nothing to choose.
    expect(find.byType(SegmentedButton<ReportRange>), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
  });

  testWidgets('a language with a face still gets the form (PDF-7)', (
    tester,
  ) async {
    settings = await testSettings({'language': 'hi'});

    await showReport(tester);

    expect(find.byType(SegmentedButton<ReportRange>), findsOneWidget);
  });

  testWidgets('it opens on this period, with the other ranges offered '
      '(PDF-1)', (tester) async {
    await showReport(tester);

    expect(find.text('This period'), findsOneWidget);
    expect(find.text('Dates'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    // No date fields until Dates is chosen.
    expect(find.text('From'), findsNothing);
  });

  testWidgets('choosing Dates reveals a from and a to (PDF-1)', (tester) async {
    await showReport(tester);

    await tester.tap(find.text('Dates'));
    await tester.pumpAndSettle();

    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
  });

  testWidgets('choosing Year offers the years there is data for (PDF-1)', (
    tester,
  ) async {
    await showReport(tester);

    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();

    expect(find.text('2026'), findsWidgets);
    expect(find.text('2025'), findsWidgets);
  });

  testWidgets('opened from Search, it starts on that search\'s dates '
      '(PDF-1)', (tester) async {
    await showReport(
      tester,
      filter: TransactionFilter(
        from: DateTime(2026, 9, 3),
        to: DateTime(2026, 9, 9),
      ),
    );

    // Dates is already chosen, so the fields are showing.
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
  });

  testWidgets(
    'opened from Search, the account filter carries over too (PDF-1)',
    (tester) async {
      await showReport(
        tester,
        filter: const TransactionFilter(accountId: Account.cashId),
      );

      // The account dropdown already shows the searched account, not "All
      // accounts" (testAccount names each account after its ID).
      expect(find.text('acc-cash'), findsOneWidget);
      expect(find.text('All accounts'), findsNothing);
    },
  );

  testWidgets(
    'opened from Search, an archived account still carries over instead of '
    'falling back to "All accounts" (PDF-1)',
    (tester) async {
      // Search itself offers archived accounts too, so a report opened on
      // one has to seed from every account, not just the active ones.
      provider = TransactionProvider(
        db: FakeDB(
          transactions: fake.rows,
          accounts: [
            testAccount(Account.cashId),
            testAccount('savings').copyWith(archivedAt: DateTime(2026, 1, 1)),
          ],
        ),
        clock: () => DateTime(2026, 9, 15),
      );
      await provider.load();

      await showReport(
        tester,
        filter: const TransactionFilter(accountId: 'savings'),
      );

      // Falling back to "All accounts" here would report on every account,
      // the exact over-sharing the archived filter is meant to avoid
      // (testAccount names each account after its ID).
      expect(find.text('savings'), findsOneWidget);
      expect(find.text('All accounts'), findsNothing);
    },
  );

  testWidgets(
    'a query, type, or category from Search shows the narrowed notice '
    '(PDF-1, ACC-6, review-money-2)',
    (tester) async {
      await showReport(tester, filter: const TransactionFilter(query: 'Rent'));

      expect(
        find.text('This report stays narrowed to your search.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('the account or dates alone from Search show no narrowed notice '
      '(PDF-1)', (tester) async {
    // reportMatchesFor treats these the same way: they seed the report's
    // own controls, but narrow nothing it shows (BAL-2, BAL-3).
    await showReport(
      tester,
      filter: TransactionFilter(
        accountId: Account.cashId,
        from: DateTime(2026, 9, 3),
        to: DateTime(2026, 9, 9),
      ),
    );

    expect(
      find.text('This report stays narrowed to your search.'),
      findsNothing,
    );
  });

  group(
    'what a report from Search draws from (PDF-1, BAK-5, BAL-2, BAL-3)',
    () {
      late ExpenseTransaction rent;
      late List<ExpenseTransaction> all;
      // The labels don't matter to this group; each function just has to be
      // one reportMatchesFor can call.
      String categoryName(Category category) => category.id;
      String accountName(Account account) => account.id;

      setUp(() async {
        rent = testTx(
          'rent',
          TransactionType.expense,
          800,
          DateTime(2026, 9, 1),
          title: 'Rent',
        );
        all = [
          rent,
          testTx('e2', TransactionType.expense, 20, DateTime(2026, 9, 5)),
          testTx('i1', TransactionType.income, 900, DateTime(2026, 9, 2)),
        ];
        provider = TransactionProvider(
          db: FakeDB(
            transactions: all,
            transfers: [
              testTransfer(
                't',
                Account.cashId,
                Account.cashId,
                50,
                DateTime(2026, 9, 3),
              ),
            ],
          ),
          clock: () => DateTime(2026, 9, 15),
        );
        await provider.load();
      });

      test('opened from Home or Insights, there is no narrowing predicate', () {
        expect(
          reportMatchesFor(
            provider,
            null,
            categoryName: categoryName,
            accountName: accountName,
            decimalMark: '.',
          ),
          isNull,
        );
      });

      test('the account and dates in a Search filter play no part in the '
          "predicate; they're the report's own controls instead", () {
        expect(
          reportMatchesFor(
            provider,
            TransactionFilter(
              accountId: 'no-such-account',
              from: DateTime(2099),
              to: DateTime(2099),
            ),
            categoryName: categoryName,
            accountName: accountName,
            decimalMark: '.',
          ),
          isNull,
        );
      });

      test('a type filter from Search excludes the other type', () {
        final matches = reportMatchesFor(
          provider,
          const TransactionFilter(type: TransactionType.income),
          categoryName: categoryName,
          accountName: accountName,
          decimalMark: '.',
        );
        expect(all.where(matches!), [all[2]]);
      });

      test(
        'a text query narrows the report without giving it a false balance or '
        'listing transfers (BAL-2, BAL-3, BAK-5)',
        () {
          final matches = reportMatchesFor(
            provider,
            const TransactionFilter(query: 'Rent'),
            categoryName: categoryName,
            accountName: accountName,
            decimalMark: '.',
          );

          ReportData build({bool Function(ExpenseTransaction)? matches}) =>
              buildReport(
                from: DateTime(2026, 9, 1),
                to: DateTime(2026, 9, 30),
                today: provider.today,
                transactions: provider.transactions,
                transfers: provider.transfers,
                accounts: provider.accounts,
                matches: matches,
              );

          final unfiltered = build();
          final filtered = build(matches: matches);

          // The bug this reproduces: pre-filtering the transaction list before
          // buildReport worked out the balances from it, so a query gave a
          // false opening and closing balance (BAL-2, BAL-3).
          expect(filtered.openingBalance, unfiltered.openingBalance);
          expect(filtered.closingBalance, unfiltered.closingBalance);
          // The unfiltered report includes the transfer; the filtered one
          // leaves it out entirely, along with the non-matching transaction.
          final filteredEntries = filtered.byDay.values.expand((e) => e);
          expect(filteredEntries.single.transaction!.id, 'rent');
          expect(
            unfiltered.byDay.values.expand((e) => e).any((e) => e.isTransfer),
            isTrue,
          );
        },
      );

      test(
        'a comma-decimal query gives the same matches through reportMatchesFor '
        "as through the provider's own search (CUR-2, review-money-1, "
        'review-state-2)',
        () async {
          // Reproduces the merge artifact directly: search_screen.dart
          // passes the currency's own decimal mark to provider.search, and
          // reportMatchesFor has to be given the same thing rather than
          // silently falling back to '.' (which would read "1,500" as
          // ambiguous and reject it instead of matching the 1.5 entry).
          final tnd = testTx(
            'tnd',
            TransactionType.expense,
            1.5,
            DateTime(2026, 9, 6),
          );
          provider = TransactionProvider(
            db: FakeDB(transactions: [...all, tnd]),
            clock: () => DateTime(2026, 9, 15),
          );
          await provider.load();

          const filter = TransactionFilter(query: '1,500');
          final searchIds = provider
              .search(
                filter,
                categoryName: categoryName,
                accountName: accountName,
                decimalMark: ',',
              )
              .transactions
              .map((tx) => tx.id);
          final matches = reportMatchesFor(
            provider,
            filter,
            categoryName: categoryName,
            accountName: accountName,
            decimalMark: ',',
          )!;
          final reportIds = [tnd, ...all].where(matches).map((tx) => tx.id);

          expect(reportIds, unorderedEquals(searchIds));
          expect(reportIds, contains('tnd'));
        },
      );

      // review-money-3: this is the one function ReportScreen._create calls
      // to build the data it previews and exports (reportDataFor), so a test
      // that only exercised reportMatchesFor and buildReport directly, as
      // the tests above do, would stay green even if _create stopped
      // wiring the filter through.
      test('reportDataFor wires the Search filter through to the data the '
          'screen builds and exports (PDF-1)', () {
        final data = reportDataFor(
          provider: provider,
          filter: const TransactionFilter(query: 'Rent'),
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 30),
          categoryName: categoryName,
          accountName: accountName,
          decimalMark: '.',
        );

        final entries = data.byDay.values.expand((e) => e);
        expect(entries.single.transaction!.id, 'rent');
        expect(data.searchInfo?.query, 'Rent');
      });
    },
  );

  group('reportDataFor prices the range it was asked for (BUD-5, '
      'money-time#5)', () {
    Budget versionOf(String id, int limit, DateTime from) => Budget(
      id: id,
      categoryId: 'cat-food',
      limit: Money(limit),
      effectiveFrom: from,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    // review-money-5 / money-time#5: reportDataFor passes
    // `provider.budgetLimit(id, Period.containing(from, ...))` rather than
    // `provider.budgetLimit(id)`, which resolves whatever period the
    // provider is showing regardless of the report's own range. Groceries
    // was 300 from September and raised to 500 from October (BUD-5); a
    // custom Sep 1-30 report made while Home is on October must still price
    // against September's 300, not October's 500.
    test('a custom range in a past period uses that period\'s own limit, '
        'not the one the provider is showing', () async {
      final fake = FakeDB(
        transactions: [
          testTx('g', TransactionType.expense, 250, DateTime(2026, 9, 10)),
        ],
        budgets: [
          versionOf('b1', 300000, DateTime(2026, 9)),
          versionOf('b2', 500000, DateTime(2026, 10)),
        ],
      );
      final provider = TransactionProvider(
        db: fake,
        clock: () => DateTime(2026, 10, 15),
      );
      await provider.load();

      final data = reportDataFor(
        provider: provider,
        filter: null,
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 30),
        categoryName: (category) => category.id,
        accountName: (account) => account.id,
        decimalMark: '.',
      );

      expect(data.expenseCategories.single.budget, const Money(300000));
    });
  });

  group('reportDataFor and an archived category\'s budget (BUD-5, BUD-6, '
      'review-pdf-archived-budget)', () {
    test('the current period leaves out the budget for a category archived '
        'since, the same as budgetStatuses', () async {
      final fake = FakeDB(
        transactions: [
          testTx('g', TransactionType.expense, 250, DateTime(2026, 9, 10)),
        ],
        budgets: [
          Budget(
            id: 'b1',
            categoryId: 'cat-food',
            limit: const Money(300000),
            effectiveFrom: DateTime(2026, 9),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        ],
      );
      final provider = TransactionProvider(
        db: fake,
        clock: () => DateTime(2026, 9, 15),
      );
      await provider.load();
      await provider.archiveCategory('cat-food');

      final data = reportDataFor(
        provider: provider,
        filter: null,
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 30),
        categoryName: (category) => category.id,
        accountName: (account) => account.id,
        decimalMark: '.',
      );

      expect(data.expenseCategories.single.budget, isNull);
    });
  });

  testWidgets('every account is offered, plus all of them together '
      '(PDF-1)', (tester) async {
    await showReport(tester);

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();

    expect(find.text('All accounts'), findsWidgets);
    // testAccount names each account after its ID.
    expect(find.text('acc-cash'), findsWidgets);
  });

  testWidgets('turning the transaction list off greys what it contains '
      '(PDF-3)', (tester) async {
    await showReport(tester);

    SwitchListTile tile(String label) => tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, label),
    );

    expect(tile('Titles and notes').onChanged, isNotNull);
    expect(tile('Account names').onChanged, isNotNull);

    await tester.tap(
      find.widgetWithText(SwitchListTile, 'The transaction list'),
    );
    await tester.pumpAndSettle();

    expect(tile('Titles and notes').onChanged, isNull);
    expect(tile('Account names').onChanged, isNull);
  });

  testWidgets('a backwards range is refused rather than built (PDF-1)', (
    tester,
  ) async {
    // Seeded backwards, which the screen has to catch before it builds.
    await showReport(
      tester,
      filter: TransactionFilter(
        from: DateTime(2026, 9, 20),
        to: DateTime(2026, 9, 1),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pumpAndSettle();

    expect(
      find.text('The first date has to come before the last.'),
      findsOneWidget,
    );
  });

  testWidgets('creating shows progress, then the preview (PDF-4, PDF-6)', (
    tester,
  ) async {
    await showReport(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pump();

    expect(find.text('Building the report'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // PDF-4: nothing to share or print until the report exists.
    expect(find.byIcon(Icons.share), findsNothing);

    await pumpUntil(tester, find.text('Report'));
    // The progress dialog's own pop animation can still be mid-flight the
    // instant the preview's title first appears; give it a few more frames
    // to finish closing before checking it's gone.
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Building the report'), findsNothing);
    expect(find.text('Report'), findsOneWidget);
  });

  testWidgets('closing the preview is a seam for the full-screen ad '
      '(ADS-11)', (tester) async {
    // A seam shows one to someone who has done ten things today and did
    // not install the app on this run (ADS-12).
    provider = TransactionProvider(
      db: FakeDB(
        transactions: [
          for (var i = 0; i < 12; i++)
            testTx('t$i', TransactionType.expense, 5, DateTime(2026, 9, 4)),
        ],
      ),
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings({
      'setup_done': true,
      'walkthrough_seen': true,
      'first_opened_at': DateTime(2026, 1, 1).toUtc().toIso8601String(),
      'ad_activity': SettingsProvider.adActivityThreshold,
      'ad_activity_day': DateTime.now().toUtc().toIso8601String(),
    });
    final ads = FakeAdService(canStart: true, interstitialFills: true);
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(provider, settings, const ReportScreen(), ads: ads),
    );
    await tester.pumpAndSettle();
    // In the app the SDK started long ago; here the provider is built on
    // its first read, so this is what a running app already has (ADS-4).
    Provider.of<AdsProvider>(
      tester.element(find.byType(ReportScreen)),
      listen: false,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pump();
    await pumpUntil(tester, find.text('Report'));
    expect(ads.interstitialsShown, 0, reason: 'not over the report itself');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(ads.interstitialsShown, 1);
  });

  testWidgets('cancelling leaves you on the options, with no report '
      '(PDF-6)', (tester) async {
    await showReport(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Building the report'), findsNothing);
    expect(find.text('Report'), findsNothing);
    expect(find.text('Create the report'), findsOneWidget);
  });

  testWidgets('a report can still be created after one is cancelled', (
    tester,
  ) async {
    await showReport(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await pumpUntil(tester, find.text('Report'));

    expect(find.text('Report'), findsOneWidget);
  });

  testWidgets(
    'a cancel that lands while the report is still laying out leaves you on '
    'the report screen, with no preview and no ad (PDF-6)',
    (tester) async {
      // Nearly all of it on one day, so content-building only yields a
      // couple of times: the page layout that follows (moved off the UI
      // isolate in report_pdf.dart) then dominates the time between the tap
      // on Create and the bytes coming back, giving Cancel a real window to
      // land after buildReportPdf's last isCancelled check, same as the
      // race the finding describes.
      fake = FakeDB(
        transactions: [
          for (var i = 0; i < 4000; i++)
            testTx('big-$i', TransactionType.expense, 5, DateTime(2026, 9, 4)),
        ],
      );
      provider = TransactionProvider(
        db: fake,
        clock: () => DateTime(2026, 9, 15),
      );
      await provider.load();
      settings = await testSettings({
        'setup_done': true,
        'walkthrough_seen': true,
        'first_opened_at': DateTime(2026, 1, 1).toUtc().toIso8601String(),
        'ad_activity': SettingsProvider.adActivityThreshold,
        'ad_activity_day': DateTime.now().toUtc().toIso8601String(),
      });
      final ads = FakeAdService(canStart: true, interstitialFills: true);
      usePhoneScreen(tester);
      await tester.pumpWidget(
        testApp(provider, settings, const ReportScreen(), ads: ads),
      );
      await tester.pumpAndSettle();
      // In the app the SDK started long ago; here the provider is built on
      // its first read, so this is what a running app already has (ADS-4).
      Provider.of<AdsProvider>(
        tester.element(find.byType(ReportScreen)),
        listen: false,
      );
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(
          find.widgetWithText(FilledButton, 'Create the report'),
        );
        await tester.pump();
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pump();

        // Wait for _busy to clear (the button re-enables) rather than for a
        // fixed number of pumps: the isolate hop's real duration varies with
        // machine load, and a real-zone future inside a fake-async pump
        // loop would otherwise just hang.
        for (var i = 0; i < 300; i++) {
          await tester.pump(const Duration(milliseconds: 20));
          final button = tester.widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Create the report'),
          );
          if (button.onPressed != null) break;
        }
      });

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Create the report'),
      );
      expect(
        button.onPressed,
        isNotNull,
        reason: 'the build never finished within the wait budget',
      );
      expect(find.text('Report'), findsNothing);
      expect(find.byType(ReportScreen), findsOneWidget);
      expect(ads.interstitialsShown, 0);
    },
  );
}
