import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show DebugGeography;

import 'package:monthly_expense_app/services/ad_service.dart';
import 'package:monthly_expense_app/services/ads_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('no ad service at all (ADS-1)', () {
    // What Windows and Linux get: the calls are all there, and every one of
    // them answers "nothing", so no screen has to know the difference.
    const service = NoAdService();

    test('it starts by saying no', () async {
      expect(await service.start(), isFalse);
    });

    test(
      'it offers no privacy options, and showing them does nothing',
      () async {
        expect(service.privacyOptionsRequired, isFalse);
        await expectLater(service.showPrivacyOptions(), completes);
      },
    );

    test('it reserves no height and fills no slot (ADS-2)', () async {
      expect(await service.bannerHeight(360), isNull);
      for (final placement in AdPlacement.values) {
        expect(await service.loadBanner(placement, 360), isNull);
      }
    });
  });

  group('pretending to be somewhere else, to see the consent form (ADS-5)', () {
    test('a debug build can pretend to be in the EEA or a US state', () {
      expect(
        consentTestGeography(debug: true, region: 'eea'),
        DebugGeography.debugGeographyEea,
      );
      expect(
        consentTestGeography(debug: true, region: 'US'),
        DebugGeography.debugGeographyRegulatedUsState,
      );
    });

    test('a release build never pretends, whatever it is told', () {
      // The guard that matters: no real user may be shown a form meant for
      // somewhere else, even if a build was made with the setting on.
      for (final region in ['eea', 'us', 'EEA']) {
        expect(consentTestGeography(debug: false, region: region), isNull);
      }
    });

    test(
      'without the setting, or with nonsense, the device is where it is',
      () {
        expect(consentTestGeography(debug: true, region: ''), isNull);
        expect(consentTestGeography(debug: true, region: 'mars'), isNull);
      },
    );
  });

  group('the real service, before it can ask for anything', () {
    test(
      'a build with no units configured never starts the SDK (ADS-10)',
      () async {
        // Windows is the clearest case of "not configured": no SDK at all.
        // Reaching the SDK here would throw a missing-plugin error, so the
        // fact that this returns quietly is the assertion.
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        final service = DeviceAdService();

        expect(await service.start(), isFalse);
        expect(service.privacyOptionsRequired, isFalse);
        // And nothing is requested off the back of it.
        expect(await service.loadBanner(AdPlacement.home, 360), isNull);
      },
    );

    test('starting twice does not start twice', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final service = DeviceAdService();

      expect(await service.start(), isFalse);
      // The second call takes the remembered answer rather than going round
      // the consent flow again.
      expect(await service.start(), isFalse);
    });

    test('no privacy options row until the SDK has said so (ADS-5)', () {
      expect(DeviceAdService().privacyOptionsRequired, isFalse);
    });
  });
}
