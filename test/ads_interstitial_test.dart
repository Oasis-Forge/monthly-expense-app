import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';

import 'helpers.dart';

void main() {
  final now = DateTime(2026, 9, 20, 12);
  final longBefore = DateTime(2026, 1, 1);

  /// Someone past the first run (ADS-4) who first opened the app
  /// [firstOpened] and last saw a full-screen ad at [lastShown].
  Future<SettingsProvider> settled({
    DateTime? firstOpened,
    DateTime? lastShown,
  }) => testSettings({
    'setup_done': true,
    'walkthrough_seen': true,
    'first_opened_at': (firstOpened ?? longBefore).toUtc().toIso8601String(),
    if (lastShown != null) 'last_interstitial': lastShown.toIso8601String(),
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

  group('the day, and the days before it (ADS-12)', () {
    test('nothing before ten transactions', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      await provider.primeInterstitial(9);
      await provider.showAtSeam(AdSeam.leftInsights, 9);

      expect(ads.interstitialsRequested, 0);
      expect(ads.interstitialsShown, 0);
    });

    test('a first day is no obstacle once ten are recorded (ADS-12)', () async {
      final ads = filling();
      final provider = await started(await settled(firstOpened: now), ads);

      await provider.primeInterstitial(10);
      await provider.showAtSeam(AdSeam.leftInsights, 10);

      expect(ads.interstitialsShown, 1);
    });

    test('one a day, and the second seam gets nothing', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      await provider.primeInterstitial(20);
      await provider.showAtSeam(AdSeam.leftInsights, 20);
      await provider.primeInterstitial(20);
      await provider.showAtSeam(AdSeam.madeReport, 20);

      expect(ads.interstitialsShown, 1);
      // The spent day is not even asked about again.
      expect(ads.interstitialsRequested, 1);
    });

    test('yesterday does not count against today', () async {
      final ads = filling();
      final provider = await started(
        await settled(lastShown: now.subtract(const Duration(days: 1))),
        ads,
      );

      await provider.primeInterstitial(20);
      await provider.showAtSeam(AdSeam.exportedCsv, 20);

      expect(ads.interstitialsShown, 1);
    });

    test('an hour earlier the same day does', () async {
      final ads = filling();
      final provider = await started(
        await settled(lastShown: now.subtract(const Duration(hours: 1))),
        ads,
      );

      await provider.primeInterstitial(20);
      await provider.showAtSeam(AdSeam.exportedCsv, 20);

      expect(ads.interstitialsShown, 0);
    });
  });

  group('a seam is never a wait (ADS-13)', () {
    test('one that finds nothing ready passes in silence', () async {
      final ads = FakeAdService(canStart: true);
      final provider = await started(await settled(), ads);

      await provider.primeInterstitial(20);
      await provider.showAtSeam(AdSeam.importedCsv, 20);

      expect(provider.interstitialReady, isFalse);
      expect(ads.interstitialsShown, 0);
    });

    test('and does not spend the day it could not fill', () async {
      final ads = FakeAdService(canStart: true);
      final settings = await settled();
      final provider = await started(settings, ads);

      await provider.primeInterstitial(20);
      await provider.showAtSeam(AdSeam.importedCsv, 20);
      // The network comes back later in the day.
      ads.interstitialFills = true;
      await provider.primeInterstitial(20);
      await provider.showAtSeam(AdSeam.madeReport, 20);

      expect(ads.interstitialsShown, 1);
    });

    test('a seam fetches nothing of its own', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      await provider.showAtSeam(AdSeam.leftInsights, 20);

      expect(ads.interstitialsRequested, 0);
      expect(ads.interstitialsShown, 0);
    });

    test('priming twice still holds only one', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      await provider.primeInterstitial(20);
      await provider.primeInterstitial(20);

      expect(ads.interstitialsRequested, 1);
    });
  });

  group('what governs a banner governs this (ADS-15)', () {
    test('not before setup and the walkthrough', () async {
      final ads = filling();
      final provider = await started(await testSettings(), ads);

      await provider.primeInterstitial(20);

      expect(ads.interstitialsRequested, 0);
    });

    test('not once the ads are bought away', () async {
      final ads = filling();
      final provider = await started(
        await settled(),
        ads,
        purchases: FakePurchases(stage: PurchaseStage.owned),
      );

      await provider.primeInterstitial(20);

      expect(ads.interstitialsRequested, 0);
    });

    test('not while the app is locked', () async {
      final ads = filling();
      final provider = await started(
        await settled(),
        ads,
        locked: ValueNotifier(true),
      );

      await provider.primeInterstitial(20);

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

      await provider.primeInterstitial(20);
      expect(provider.interstitialReady, isTrue);
      purchases.settle(PurchaseStage.owned);
      await provider.showAtSeam(AdSeam.leftInsights, 20);

      expect(ads.interstitialsShown, 0);
      expect(ads.interstitialsDropped, 1);
    });

    test('one in hand is let go when the app locks in between', () async {
      final ads = filling();
      final locked = ValueNotifier(false);
      final provider = await started(await settled(), ads, locked: locked);

      await provider.primeInterstitial(20);
      locked.value = true;
      await provider.showAtSeam(AdSeam.leftInsights, 20);

      expect(ads.interstitialsShown, 0);
      expect(ads.interstitialsDropped, 1);
    });
  });

  group('never over an Undo (ADS-11, DEL-2)', () {
    test('a seam inside the five seconds lets its ad go', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      await provider.primeInterstitial(20);
      AdsProvider.noteUndoShown();
      await provider.showAtSeam(AdSeam.leftInsights, 20);

      expect(ads.interstitialsShown, 0);
      expect(ads.interstitialsDropped, 1);
    });

    test('once it has gone, the next seam may show one', () async {
      final ads = filling();
      final provider = await started(await settled(), ads);

      AdsProvider.noteUndoShown(
        DateTime.now().subtract(const Duration(seconds: 6)),
      );
      await provider.primeInterstitial(20);
      await provider.showAtSeam(AdSeam.leftInsights, 20);

      expect(ads.interstitialsShown, 1);
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
