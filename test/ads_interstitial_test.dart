import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';

import 'helpers.dart';

void main() {
  final now = DateTime(2026, 9, 20, 12);
  final longBefore = DateTime(2026, 1, 1);
  const earned = SettingsProvider.adActivityThreshold;

  /// Someone past the first run (ADS-4) who has done [activity] things on
  /// [activityDay], and who did not install the app on this run unless
  /// [firstRun] says so (ADS-12).
  Future<SettingsProvider> settled({
    int activity = earned,
    DateTime? activityDay,
    bool firstRun = false,
  }) => testSettings({
    'setup_done': true,
    'walkthrough_seen': true,
    if (!firstRun) 'first_opened_at': longBefore.toUtc().toIso8601String(),
    'ad_activity': activity,
    'ad_activity_day': (activityDay ?? now).toUtc().toIso8601String(),
  }, () => now);

  Future<AdsProvider> started(
    SettingsProvider settings,
    FakeAdService ads, {
    FakePurchases? purchases,
    ValueNotifier<bool>? locked,
  }) async {
    final provider = AdsProvider(
      settings,
      ads: ads,
      purchases: purchases,
      locked: locked,
    );
    await provider.start();
    return provider;
  }

  // No test inherits another test's Undo (ADS-11).
  setUp(AdsProvider.forgetUndo);

  FakeAdService filling() =>
      FakeAdService(canStart: true, interstitialFills: true);

  group('earned by use, not by the calendar (ADS-12)', () {
    test('nine things done is not enough', () async {
      final ads = filling();
      final provider = await started(await settled(activity: 9), ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsRequested, 0);
      expect(ads.interstitialsShown, 0);
    });

    test('the tenth earns one', () async {
      final ads = filling();
      final provider = await started(await settled(activity: earned), ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsShown, 1);
    });

    test('ten counted one at a time earn one too', () async {
      final ads = filling();
      final provider = await started(await settled(activity: 0), ads);

      for (var i = 0; i < earned; i++) {
        await provider.noteActivity();
      }
      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.madeReport);

      expect(ads.interstitialsShown, 1);
    });

    test('showing one starts the count again', () async {
      final ads = filling();
      final settings = await settled(activity: earned);
      final provider = await started(settings, ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(settings.adActivity, 0);
      expect(settings.adActivityEarned, isFalse);
    });

    test('a failed show costs nothing: the count is not spent and the '
        'session is not marked interrupted (ADS-12, ADS-13)', () async {
      final ads = filling()..interstitialShowSucceeds = false;
      final settings = await settled(activity: earned);
      final provider = await started(settings, ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsShown, 0);
      expect(
        settings.adActivity,
        earned,
        reason:
            'a fetch that fails to show costs the user nothing, so the '
            'next seam may still try (ADS-13)',
      );
      expect(
        provider.interstitialShown,
        isFalse,
        reason: 'an ad nobody saw must not block the rating ask (RATE-3)',
      );
    });

    test('and ten more earn another the same day', () async {
      final ads = filling();
      final provider = await started(await settled(activity: earned), ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.leftInsights);
      for (var i = 0; i < earned; i++) {
        await provider.noteActivity();
      }
      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.exportedCsv);

      expect(ads.interstitialsShown, 2, reason: 'no ceiling on the day');
    });

    test("a count from yesterday is not today's", () async {
      final ads = filling();
      final settings = await settled(
        activity: earned * 3,
        activityDay: now.subtract(const Duration(days: 1)),
      );
      final provider = await started(settings, ads);

      await provider.primeInterstitial();

      expect(settings.adActivity, 0, reason: 'a light day does not carry');
      expect(ads.interstitialsRequested, 0);
    });

    test('and today starts again from one, not from yesterday', () async {
      final settings = await settled(
        activity: earned * 3,
        activityDay: now.subtract(const Duration(days: 1)),
      );

      await settings.noteAdActivity();

      expect(settings.adActivity, 1);
    });

    test('nor is a count from the same date a month or a year ago', () async {
      for (final day in [
        DateTime(2026, 8, 20, 12),
        DateTime(2025, 9, 20, 12),
      ]) {
        final settings = await settled(activity: earned, activityDay: day);

        expect(settings.adActivity, 0, reason: '$day');
        expect(settings.adActivityEarned, isFalse, reason: '$day');
      }
    });

    test("today is the phone's own day, either side of midnight UTC", () async {
      // Stored in UTC, as noteAdActivity writes it. East of UTC the first
      // minutes of the day fall on yesterday's UTC date, and west of it the
      // last ones on tomorrow's, so both ends of today are tried.
      for (final at in [
        DateTime(2026, 9, 20, 0, 30),
        DateTime(2026, 9, 20, 23, 30),
      ]) {
        final settings = await settled(activity: earned, activityDay: at);

        expect(settings.adActivity, earned, reason: '$at');
      }
    });

    test('a restart the same day does not bring a spent count back', () async {
      final ads = filling();
      final provider = await started(await settled(activity: earned), ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.leftInsights);
      final reopened = SettingsProvider(
        await SharedPreferences.getInstance(),
        clock: () => now,
      );

      expect(ads.interstitialsShown, 1);
      expect(reopened.adActivity, 0);
      expect(reopened.adActivityEarned, isFalse);
    });
  });

  group('never during the run that installed it (ADS-12)', () {
    test('however much is done in it', () async {
      final ads = filling();
      final provider = await started(
        await settled(activity: earned * 5, firstRun: true),
        ads,
      );

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.importedCsv);

      expect(ads.interstitialsRequested, 0);
      expect(ads.interstitialsShown, 0);
    });

    test('the run after it is another matter', () async {
      final ads = filling();
      final provider = await started(await settled(activity: earned), ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.importedCsv);

      expect(ads.interstitialsShown, 1);
    });
  });

  group('a seam is never a wait (ADS-13)', () {
    test('one that finds nothing ready passes in silence', () async {
      final ads = FakeAdService(canStart: true);
      final provider = await started(await settled(), ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.importedCsv);

      expect(provider.interstitialReady, isFalse);
      expect(ads.interstitialsShown, 0);
    });

    test('and does not spend what it could not fill', () async {
      final ads = FakeAdService(canStart: true);
      final settings = await settled();
      final provider = await started(settings, ads);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.importedCsv);
      // The network comes back later in the day.
      ads.interstitialFills = true;
      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.madeReport);

      expect(ads.interstitialsShown, 1);
      expect(settings.adActivity, 0, reason: 'spent only once it was seen');
    });

    test('a seam fetches nothing of its own', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsRequested, 0);
      expect(ads.interstitialsShown, 0);
    });

    test('priming twice still holds only one', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      await provider.primeInterstitial();
      await provider.primeInterstitial();

      expect(ads.interstitialsRequested, 1);
    });

    test(
      'nor does priming again while the first is still on its way',
      () async {
        final ads = filling();
        final provider = await started(await settled(), ads);

        // Insights left and opened again before the first fetch came back.
        await Future.wait([
          provider.primeInterstitial(),
          provider.primeInterstitial(),
        ]);

        expect(ads.interstitialsRequested, 1);
      },
    );
  });

  group('what the rating sheet reads (RATE-3)', () {
    test('an ad really seen marks the visit as interrupted', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);
      expect(provider.interstitialShown, isFalse);

      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsShown, 1);
      expect(provider.interstitialShown, isTrue);
    });
  });

  group('what governs a banner governs this (ADS-15)', () {
    test('not before setup and the walkthrough', () async {
      final ads = filling();
      final provider = await started(await testSettings(), ads);

      await provider.primeInterstitial();

      expect(ads.interstitialsRequested, 0);
    });

    test('not once the ads are bought away', () async {
      final ads = filling();
      final provider = await started(
        await settled(),
        ads,
        purchases: FakePurchases(stage: PurchaseStage.owned),
      );

      await provider.primeInterstitial();

      expect(ads.interstitialsRequested, 0);
    });

    test('not while the app is locked', () async {
      final ads = filling();
      final provider = await started(
        await settled(),
        ads,
        locked: ValueNotifier(true),
      );

      await provider.primeInterstitial();

      expect(ads.interstitialsRequested, 0);
    });

    test('one in hand is let go when the ads are bought in between', () async {
      final ads = filling();
      final purchases = FakePurchases();
      final provider = await started(
        await settled(),
        ads,
        purchases: purchases,
      );

      await provider.primeInterstitial();
      expect(provider.interstitialReady, isTrue);
      purchases.settle(PurchaseStage.owned);
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsShown, 0);
      expect(ads.interstitialsDropped, 1);
    });

    test('one in hand is let go when the app locks in between', () async {
      final ads = filling();
      final locked = ValueNotifier(false);
      final provider = await started(await settled(), ads, locked: locked);

      await provider.primeInterstitial();
      locked.value = true;
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsShown, 0);
      expect(ads.interstitialsDropped, 1);
    });
  });

  group('never over an Undo (ADS-11, DEL-2)', () {
    test('a seam inside the five seconds lets its ad go', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      await provider.primeInterstitial();
      AdsProvider.noteUndoShown();
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsShown, 0);
      expect(ads.interstitialsDropped, 1);
    });

    test('once it has gone, the next seam may show one', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      AdsProvider.noteUndoShown(
        DateTime.now().subtract(const Duration(seconds: 6)),
      );
      await provider.primeInterstitial();
      await provider.showAtSeam(AdSeam.leftInsights);

      expect(ads.interstitialsShown, 1);
    });
  });

  group('what counts as a thing done (ADS-12)', () {
    testWidgets('every screen opened counts one, the app opening does not', (
      tester,
    ) async {
      final settings = await settled(activity: 0);
      final ads = AdsProvider(
        settings,
        ads: FakeAdService(),
        purchases: FakePurchases(),
      );
      addTearDown(ads.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<AdsProvider>.value(
          value: ads,
          child: MaterialApp(
            navigatorObservers: [AdActivityObserver()],
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SizedBox()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      expect(settings.adActivity, 0, reason: 'the app opening is not a screen');

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(settings.adActivity, 1);
    });

    // A dialog, a dropdown and a popup menu each push a route on the same
    // root navigator that AdActivityObserver watches, but none of them is a
    // new screen (ADS-12): they are chrome inside the screen already open —
    // the category dropdown, the date picker, a row's menu — and counting
    // them let a single entry earn most of a full-screen ad by itself.
    testWidgets('a dialog does not count as a screen opened', (tester) async {
      final settings = await settled(activity: 0);
      final ads = AdsProvider(
        settings,
        ads: FakeAdService(),
        purchases: FakePurchases(),
      );
      addTearDown(ads.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<AdsProvider>.value(
          value: ads,
          child: MaterialApp(
            navigatorObservers: [AdActivityObserver()],
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(title: Text('hi')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(
        settings.adActivity,
        0,
        reason: 'a dialog is not a screen opened, only a page route is',
      );
    });

    testWidgets('a dropdown does not count as a screen opened', (tester) async {
      final settings = await settled(activity: 0);
      final ads = AdsProvider(
        settings,
        ads: FakeAdService(),
        purchases: FakePurchases(),
      );
      addTearDown(ads.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<AdsProvider>.value(
          value: ads,
          child: MaterialApp(
            navigatorObservers: [AdActivityObserver()],
            home: Scaffold(
              body: DropdownButtonFormField<int>(
                initialValue: 1,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('one')),
                  DropdownMenuItem(value: 2, child: Text('two')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('one'));
      await tester.pumpAndSettle();

      expect(
        settings.adActivity,
        0,
        reason: 'a dropdown is not a screen opened, only a page route is',
      );
    });

    testWidgets('a popup menu does not count as a screen opened', (
      tester,
    ) async {
      final settings = await settled(activity: 0);
      final ads = AdsProvider(
        settings,
        ads: FakeAdService(),
        purchases: FakePurchases(),
      );
      addTearDown(ads.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<AdsProvider>.value(
          value: ads,
          child: MaterialApp(
            navigatorObservers: [AdActivityObserver()],
            home: Scaffold(
              body: PopupMenuButton<int>(
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 1, child: Text('one')),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<int>));
      await tester.pumpAndSettle();

      expect(
        settings.adActivity,
        0,
        reason: 'a popup menu is not a screen opened, only a page route is',
      );
    });
  });

  group('the seams themselves (ADS-11)', () {
    test('there are four, and a screen cannot invent a fifth', () {
      expect(AdSeam.values, hasLength(4));
      expect(
        AdSeam.values,
        containsAll([
          AdSeam.leftInsights,
          AdSeam.madeReport,
          AdSeam.exportedCsv,
          AdSeam.importedCsv,
        ]),
      );
    });
  });
}
