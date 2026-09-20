import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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
