import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/insights_screen.dart';
import 'package:monthly_expense_app/screens/period_selector.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// The whole app, past setup, with an interstitial already earned (ADS-12)
  /// so the Insights seam has one in hand to offer.
  Future<FakeAdService> startEarned(
    WidgetTester tester,
    FakeShortcuts shortcuts,
  ) async {
    final ads = FakeAdService(canStart: true, interstitialFills: true);
    await tester.pumpWidget(
      MonthlyExpenseApp(
        settings: await testSettings({
          'setup_done': true,
          'walkthrough_seen': true,
          'first_opened_at': DateTime(2026, 1, 1).toUtc().toIso8601String(),
          'ad_activity': SettingsProvider.adActivityThreshold,
          'ad_activity_day': DateTime.now().toUtc().toIso8601String(),
        }),
        homeWidget: const NoopHomeWidgetService(),
        reviews: FakeReviews(supported: false),
        updates: FakeUpdates(supported: false),
        shortcuts: shortcuts,
        ads: ads,
        purchases: FakePurchases(),
      ),
    );
    await tester.pump();

    final transactions = tester
        .element(find.byType(MaterialApp))
        .read<TransactionProvider>();
    for (var i = 0; i < 200 && !transactions.isLoaded; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(transactions.isLoaded, isTrue, reason: 'the database never loaded');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    return ads;
  }

  testWidgets(
    'a shortcut tap that leaves Insights while it is still open does not '
    'fire the Insights seam over the form it opens instead (ADS-1, '
    'ADS-11, ADS-14, rules-22-25-31-35#6)',
    (tester) async {
      final shortcuts = FakeShortcuts();
      final ads = await startEarned(tester, shortcuts);

      // Open Insights the ordinary way: tapping the period label (INS-4).
      // The row is [prev IconButton, label InkWell, next IconButton]; the
      // label is the one whose tap opens Insights.
      await tester.tap(
        find
            .descendant(
              of: find.byType(PeriodSelector),
              matching: find.byType(InkWell),
            )
            .at(1),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InsightsScreen), findsOneWidget);

      final adsProvider = tester
          .element(find.byType(MaterialApp))
          .read<AdsProvider>();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      expect(
        adsProvider.interstitialReady,
        isTrue,
        reason:
            'the seam must have an ad in hand for this test to mean '
            'anything',
      );

      // A shortcut tap arrives while Insights is still open: it pops back
      // to Home and immediately opens the add form, racing the Insights
      // seam's own `opened.then(...)`.
      shortcuts.choose('add_expense');
      await tester.pump();
      // Lets the new route's page build; the seam's microtask has already
      // had its turn by this point.
      await tester.pump();
      await tester.pump();

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(
        ads.interstitialsShown,
        0,
        reason:
            'ADS-1/ADS-11/ADS-14: the Insights seam must never fire once '
            'the add form is on top of it',
      );
      expect(
        ads.interstitialsDropped,
        1,
        reason:
            'the primed interstitial should be let go rather than kept '
            'for a later, unrelated seam',
      );
    },
  );

  testWidgets(
    'a widget tap that leaves Insights while it is still open does not fire '
    'the Insights seam over the form it opens instead (ADS-1, ADS-11, '
    'ADS-14, rules-22-25-31-35#6)',
    (tester) async {
      final shortcuts = FakeShortcuts();
      final ads = await startEarned(tester, shortcuts);
      addTearDown(() => tappedWidgetAction.value = null);

      await tester.tap(
        find
            .descendant(
              of: find.byType(PeriodSelector),
              matching: find.byType(InkWell),
            )
            .at(1),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InsightsScreen), findsOneWidget);

      final adsProvider = tester
          .element(find.byType(MaterialApp))
          .read<AdsProvider>();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      expect(
        adsProvider.interstitialReady,
        isTrue,
        reason:
            'the seam must have an ad in hand for this test to mean '
            'anything',
      );

      // A widget tap arrives while Insights is still open: it pops back to
      // Home and immediately opens the add form, racing the Insights seam's
      // own `opened.then(...)`, the same as a shortcut tap does.
      tappedWidgetAction.value = HomeWidgetAction.addExpense;
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(
        ads.interstitialsShown,
        0,
        reason:
            'ADS-1/ADS-11/ADS-14: the Insights seam must never fire once '
            'the add form is on top of it',
      );
      expect(
        ads.interstitialsDropped,
        1,
        reason:
            'the primed interstitial should be let go rather than kept '
            'for a later, unrelated seam',
      );
    },
  );

  testWidgets(
    'a widget tap on the numbers (open_home) that closes Insights and '
    'lands back on Home does not fire the Insights seam either, even '
    'though Home ends up as the current route (ADS-1, ADS-11, '
    'rules-22-25-31-35#6)',
    (tester) async {
      final shortcuts = FakeShortcuts();
      final ads = await startEarned(tester, shortcuts);
      addTearDown(() => tappedWidgetAction.value = null);

      await tester.tap(
        find
            .descendant(
              of: find.byType(PeriodSelector),
              matching: find.byType(InkWell),
            )
            .at(1),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InsightsScreen), findsOneWidget);

      final adsProvider = tester
          .element(find.byType(MaterialApp))
          .read<AdsProvider>();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      expect(
        adsProvider.interstitialReady,
        isTrue,
        reason:
            'the seam must have an ad in hand for this test to mean '
            'anything',
      );

      // A tap on the widget's numbers only pops back to Home: nothing is
      // pushed over it, so Home is current by the time the Insights route's
      // future resolves, exactly as it would be for the ordinary "back to
      // Home" case.
      tappedWidgetAction.value = HomeWidgetAction.openHome;
      await tester.pumpAndSettle();

      expect(find.byType(InsightsScreen), findsNothing);
      expect(
        ads.interstitialsShown,
        0,
        reason:
            'ADS-1: a widget tap that closed Insights while it was open '
            'must never bring back a full-screen ad the instant the app '
            'resumes, even when it lands on Home with nothing pushed',
      );
      expect(
        ads.interstitialsDropped,
        1,
        reason:
            'the primed interstitial should be let go rather than kept '
            'for a later, unrelated seam',
      );
    },
  );

  testWidgets('leaving Insights the ordinary way still shows the seam (ADS-11, '
      'ADS-13)', (tester) async {
    final shortcuts = FakeShortcuts();
    final ads = await startEarned(tester, shortcuts);

    await tester.tap(
      find
          .descendant(
            of: find.byType(PeriodSelector),
            matching: find.byType(InkWell),
          )
          .at(1),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InsightsScreen), findsOneWidget);

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(ads.interstitialsShown, 1);
    expect(ads.interstitialsDropped, 0);
  });
}
