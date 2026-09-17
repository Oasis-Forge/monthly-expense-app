import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/services/ads_config.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';

import 'helpers.dart';

void main() {
  /// Settings for someone past the first run, which is when ads are allowed
  /// to start at all (ADS-4).
  Future<SettingsProvider> settled() =>
      testSettings({'setup_done': true, 'walkthrough_seen': true});

  AdsProvider build(
    SettingsProvider settings, {
    FakeAdService? ads,
    FakePurchases? purchases,
    ValueNotifier<bool>? locked,
  }) => AdsProvider(settings, ads: ads, purchases: purchases, locked: locked);

  group('when an ad may be asked for (ADS-4)', () {
    test('not during setup or the walkthrough', () async {
      final settings = await testSettings();
      final ads = FakeAdService(canStart: true);
      final provider = build(settings, ads: ads);

      await provider.start();

      expect(ads.started, isFalse);
      expect(provider.showAds, isFalse);
    });

    test('only setup finished is still not enough', () async {
      final settings = await testSettings({'setup_done': true});
      final ads = FakeAdService(canStart: true);
      final provider = build(settings, ads: ads);

      await provider.start();

      expect(ads.started, isFalse);
      expect(provider.showAds, isFalse);
    });

    test('once both are done, the SDK starts and slots may fill', () async {
      final ads = FakeAdService(canStart: true);
      final provider = build(await settled(), ads: ads);

      await provider.start();

      expect(ads.started, isTrue);
      expect(provider.showAds, isTrue);
    });

    test('finishing the walkthrough is what starts it', () async {
      final settings = await testSettings({'setup_done': true});
      final ads = FakeAdService(canStart: true);
      final provider = build(settings, ads: ads);
      await provider.start();
      expect(ads.started, isFalse);

      await settings.completeWalkthrough();
      // The provider hears the settings change and starts by itself.
      await pumpEventQueue();

      expect(ads.started, isTrue);
      expect(provider.showAds, isTrue);
    });

    test('a refused consent lookup means no request at all', () async {
      // canStart false is what the service answers when consent was refused
      // outright or the lookup failed.
      final ads = FakeAdService(canStart: false);
      final provider = build(await settled(), ads: ads);

      await provider.start();

      expect(ads.started, isTrue);
      expect(provider.showAds, isFalse);
      expect(await provider.loadBanner(AdPlacement.home, 360), isNull);
      expect(ads.requested, isEmpty);
    });

    test('the store is asked whatever the first run says', () async {
      // A purchase has to be known about before any slot could show, so the
      // store is asked even during setup (PAY-5).
      final purchases = FakePurchases();
      final provider = build(await testSettings(), purchases: purchases);

      await provider.start();

      expect(purchases.started, isTrue);
    });
  });

  group('bought away (ADS-8, PAY-1)', () {
    test('no slot fills once the purchase is owned', () async {
      final ads = FakeAdService(canStart: true, fills: true);
      final purchases = FakePurchases(stage: PurchaseStage.owned);
      final provider = build(await settled(), ads: ads, purchases: purchases);

      await provider.start();

      expect(provider.adsRemoved, isTrue);
      expect(provider.showAds, isFalse);
      expect(await provider.loadBanner(AdPlacement.home, 360), isNull);
      // Nobody who has paid is asked for consent to ads they won't see.
      expect(ads.started, isFalse);
    });

    test('buying stops the slots without a restart', () async {
      final ads = FakeAdService(canStart: true, fills: true);
      final purchases = FakePurchases(stage: PurchaseStage.offered);
      final provider = build(await settled(), ads: ads, purchases: purchases);
      await provider.start();
      expect(provider.showAds, isTrue);

      var notified = 0;
      provider.addListener(() => notified++);
      purchases.settle(PurchaseStage.owned);

      expect(provider.showAds, isFalse);
      expect(notified, greaterThan(0));
    });

    test('buying and restoring go to the store', () async {
      final purchases = FakePurchases(stage: PurchaseStage.offered);
      final provider = build(await settled(), purchases: purchases);

      await provider.buyRemoveAds();
      await provider.restorePurchases();

      expect(purchases.buys, 1);
      expect(purchases.restores, 1);
    });
  });

  group('behind the lock (ADS-9)', () {
    test('nothing loads while the app is locked', () async {
      final locked = ValueNotifier(true);
      final ads = FakeAdService(canStart: true, fills: true);
      final provider = build(await settled(), ads: ads, locked: locked);
      await provider.start();

      expect(provider.showAds, isFalse);
      expect(await provider.loadBanner(AdPlacement.home, 360), isNull);
      expect(ads.requested, isEmpty);

      locked.value = false;

      expect(provider.showAds, isTrue);
      expect(await provider.loadBanner(AdPlacement.home, 360), isNotNull);
    });

    test('locking again notifies, so the slots go', () async {
      final locked = ValueNotifier(false);
      final provider = build(
        await settled(),
        ads: FakeAdService(canStart: true),
        locked: locked,
      );
      await provider.start();
      var notified = 0;
      provider.addListener(() => notified++);

      locked.value = true;

      expect(provider.showAds, isFalse);
      expect(notified, 1);
    });
  });

  group('the slot height (ADS-2)', () {
    test('is looked up once and kept', () async {
      final ads = FakeAdService(canStart: true, height: 60);
      final provider = build(await settled(), ads: ads);
      await provider.start();

      expect(await provider.bannerHeight(360), 60);
      // A second screen's slot gets the same answer without asking again.
      ads.height = 999;
      expect(await provider.bannerHeight(360), 60);
      // A different width is its own question.
      expect(await provider.bannerHeight(720), 999);
    });

    test('is there for the next slot to use on its first frame', () async {
      final provider = build(
        await settled(),
        ads: FakeAdService(canStart: true, height: 60),
      );
      await provider.start();
      // Nothing known until something has asked.
      expect(provider.knownBannerHeight(360), isNull);

      await provider.bannerHeight(360);

      expect(provider.knownBannerHeight(360), 60);
      // Only for the width that was asked about.
      expect(provider.knownBannerHeight(720), isNull);
    });

    test('is not offered once the ads are bought (ADS-8)', () async {
      final purchases = FakePurchases(stage: PurchaseStage.offered);
      final provider = build(
        await settled(),
        ads: FakeAdService(canStart: true, height: 60),
        purchases: purchases,
      );
      await provider.start();
      await provider.bannerHeight(360);
      expect(provider.knownBannerHeight(360), 60);

      purchases.settle(PurchaseStage.owned);

      expect(provider.knownBannerHeight(360), isNull);
    });

    test('is nothing when no ad may be shown', () async {
      final provider = build(
        await settled(),
        purchases: FakePurchases(stage: PurchaseStage.owned),
      );
      await provider.start();

      expect(await provider.bannerHeight(360), isNull);
    });
  });

  group('privacy options (ADS-5)', () {
    test('offered only where the SDK says the law asks', () async {
      final ads = FakeAdService(canStart: true);
      final provider = build(await settled(), ads: ads);
      await provider.start();
      expect(provider.privacyOptionsRequired, isFalse);

      ads.privacyOptionsRequired = true;

      expect(provider.privacyOptionsRequired, isTrue);
    });

    test('opening the form goes to the SDK and then rebuilds', () async {
      final ads = FakeAdService(canStart: true, privacyOptionsRequired: true);
      final provider = build(await settled(), ads: ads);
      await provider.start();
      var notified = 0;
      provider.addListener(() => notified++);

      await provider.showPrivacyOptions();

      expect(ads.privacyOptionsShown, 1);
      expect(notified, 1);
    });
  });

  test('without services, nothing is asked of anyone', () async {
    // What the Windows and Linux builds get (ADS-1).
    final provider = AdsProvider(await settled());

    await provider.start();

    expect(provider.showAds, isFalse);
    expect(provider.stage, PurchaseStage.unavailable);
    expect(provider.privacyOptionsRequired, isFalse);
    expect(await provider.bannerHeight(360), isNull);
    expect(await provider.loadBanner(AdPlacement.insights, 360), isNull);
  });
}
