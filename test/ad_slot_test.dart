import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/ad_slot.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/insights_screen.dart';
import 'package:monthly_expense_app/screens/remove_ads_screen.dart';
import 'package:monthly_expense_app/screens/report_screen.dart';
import 'package:monthly_expense_app/screens/setup_screen.dart';
import 'package:monthly_expense_app/screens/walkthrough_screen.dart';
import 'package:monthly_expense_app/services/ads_config.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';

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
      ],
    );
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    // Past setup and the walkthrough, which is when a slot may fill (ADS-4).
    settings = await testSettings({
      'setup_done': true,
      'walkthrough_seen': true,
    });
  });

  /// Pumps [screen] and lets the slot ask for its height and its ad, both of
  /// which happen after the first frame.
  Future<void> show(
    WidgetTester tester,
    Widget screen, {
    FakeAdService? ads,
    FakePurchases? purchases,
    ValueNotifier<bool>? locked,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        screen,
        ads: ads,
        purchases: purchases,
        locked: locked,
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  Finder banner(AdPlacement placement) =>
      find.byKey(ValueKey('ad-${placement.name}'));

  group('where the slots are (ADS-1, ADS-3)', () {
    testWidgets('Home has one, at the bottom and outside the day list', (
      tester,
    ) async {
      await show(
        tester,
        const HomeScreen(),
        ads: FakeAdService(canStart: true, fills: true),
      );

      expect(banner(AdPlacement.home), findsOneWidget);
      // ADS-3: it is the Scaffold's bottom bar, not a row in the body, so
      // nothing scrolls under it and the add button sits above it.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomNavigationBar, isA<AdSlot>());
      // The lowest thing on the screen.
      final slot = tester.getRect(find.byType(AdSlot));
      expect(slot.bottom, tester.getSize(find.byType(MaterialApp)).height);
    });

    testWidgets('Insights has one, with its own unit', (tester) async {
      final ads = FakeAdService(canStart: true, fills: true);

      await show(tester, const InsightsScreen(), ads: ads);

      expect(banner(AdPlacement.insights), findsOneWidget);
      expect(ads.requested, [AdPlacement.insights]);
    });

    testWidgets('the add form, setup, the walkthrough and the report have '
        'none', (tester) async {
      for (final screen in const [
        AddTransactionScreen(),
        SetupScreen(),
        WalkthroughScreen(),
        ReportScreen(),
      ]) {
        final ads = FakeAdService(canStart: true, fills: true);
        await show(tester, screen, ads: ads);

        expect(
          find.byType(AdSlot),
          findsNothing,
          reason: '${screen.runtimeType} must carry no ad',
        );
        expect(ads.requested, isEmpty, reason: '${screen.runtimeType}');
      }
    });
  });

  group('the slot holds its height (ADS-2)', () {
    testWidgets('an empty slot shows nothing at all, but keeps its room', (
      tester,
    ) async {
      // The request comes back with nothing, as an unfilled slot does.
      await show(
        tester,
        const HomeScreen(),
        ads: FakeAdService(canStart: true, fills: false, height: 50),
      );

      expect(banner(AdPlacement.home), findsNothing);
      // No frame, no placeholder, no label: the slot is blank.
      expect(find.text('Advertisement'), findsNothing);
      // ADS-2: the room is still reserved, so the arrival of an ad can't
      // shift what is under a finger.
      expect(tester.getSize(find.byType(AdSlot)).height, greaterThan(50));
    });

    testWidgets('the height is reserved before the ad turns up', (
      tester,
    ) async {
      final ads = FakeAdService(canStart: true, fills: true, height: 60);
      await show(tester, const HomeScreen(), ads: ads);

      // Whatever happens to the ad, the slot is the same height.
      final withAd = tester.getSize(find.byType(AdSlot)).height;
      expect(tester.getSize(banner(AdPlacement.home)).height, 60);
      expect(withAd, greaterThan(60));
    });
  });

  group('when there is no slot at all', () {
    testWidgets('bought away, it takes no room (ADS-8, PAY-1)', (tester) async {
      final ads = FakeAdService(canStart: true, fills: true);

      await show(
        tester,
        const HomeScreen(),
        ads: ads,
        purchases: FakePurchases(stage: PurchaseStage.owned),
      );

      expect(banner(AdPlacement.home), findsNothing);
      expect(tester.getSize(find.byType(AdSlot)).height, 0);
      expect(ads.requested, isEmpty);
    });

    testWidgets('locked, nothing is asked for (ADS-9)', (tester) async {
      final ads = FakeAdService(canStart: true, fills: true);

      await show(
        tester,
        const HomeScreen(),
        ads: ads,
        locked: ValueNotifier(true),
      );

      expect(tester.getSize(find.byType(AdSlot)).height, 0);
      expect(ads.requested, isEmpty);
    });

    testWidgets('during the first run, nothing is asked for (ADS-4)', (
      tester,
    ) async {
      settings = await testSettings();
      final ads = FakeAdService(canStart: true, fills: true);

      await show(tester, const HomeScreen(), ads: ads);

      expect(tester.getSize(find.byType(AdSlot)).height, 0);
      expect(ads.requested, isEmpty);
    });
  });

  group('the one quiet place it sells (PAY-7)', () {
    testWidgets('the slot carries a Remove ads link that opens the screen', (
      tester,
    ) async {
      await show(
        tester,
        const HomeScreen(),
        ads: FakeAdService(canStart: true, fills: true),
      );

      await tester.tap(
        find.descendant(
          of: find.byType(AdSlot),
          matching: find.text('Remove ads'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RemoveAdsScreen), findsOneWidget);
    });
  });

  testWidgets('a purchase that lands takes the slot away there and then '
      '(ADS-8, PAY-1)', (tester) async {
    final ads = FakeAdService(canStart: true, fills: true);
    final purchases = FakePurchases(stage: PurchaseStage.offered);
    await show(tester, const HomeScreen(), ads: ads, purchases: purchases);
    expect(banner(AdPlacement.home), findsOneWidget);

    purchases.settle(PurchaseStage.owned);
    await tester.pump();

    // Gone, with its room, and the banner handed back to the SDK.
    expect(banner(AdPlacement.home), findsNothing);
    expect(tester.getSize(find.byType(AdSlot)).height, 0);
    expect(ads.live, 0);
  });

  testWidgets('a change of width asks again, at the new one (ADS-2)', (
    tester,
  ) async {
    final ads = FakeAdService(canStart: true, fills: true);
    await show(tester, const HomeScreen(), ads: ads, purchases: null);
    expect(ads.requested, [AdPlacement.home]);

    // A wider screen: a rotation, or a desktop window being dragged. The
    // height is left alone so this stays a test of the slot.
    tester.view.physicalSize = const Size(500 * 3, 800 * 3);
    addTearDown(tester.view.resetPhysicalSize);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    // A second request, for the new width, and only one banner alive.
    expect(ads.requested, [AdPlacement.home, AdPlacement.home]);
    expect(ads.live, 1);
  });

  group('giving the banner back', () {
    testWidgets('leaving the screen does', (tester) async {
      final ads = FakeAdService(canStart: true, fills: true);
      await show(tester, const InsightsScreen(), ads: ads);
      expect(ads.live, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(ads.live, 0);
    });

    testWidgets('an ad that arrives after the screen has gone is handed '
        'straight back', (tester) async {
      // Otherwise the platform view outlives the screen that asked for it.
      final ads = FakeAdService(canStart: true, fills: true)..holdLoads = true;
      await show(tester, const InsightsScreen(), ads: ads);
      expect(ads.requested, [AdPlacement.insights]);

      await tester.pumpWidget(const SizedBox.shrink());
      ads.deliver();
      await tester.pump();

      expect(ads.live, 0);
    });

    testWidgets('an ad for the old width is dropped, not shown (ADS-2)', (
      tester,
    ) async {
      final ads = FakeAdService(canStart: true, fills: true)..holdLoads = true;
      await show(tester, const HomeScreen(), ads: ads);

      // The width changes while the first request is still in flight.
      tester.view.physicalSize = const Size(500 * 3, 800 * 3);
      addTearDown(tester.view.resetPhysicalSize);
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(ads.requested, hasLength(2));

      // Both answer; only the one for the width on screen is kept.
      ads.deliver();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(ads.live, 1);
      expect(banner(AdPlacement.home), findsOneWidget);
    });
  });
}
