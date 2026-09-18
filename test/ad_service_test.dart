import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

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
