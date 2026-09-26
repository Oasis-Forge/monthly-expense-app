// Reaches into the plugin's own implementation for two things a widget test
// cannot mock any other way: the platform channel's exact codec (needed so a
// faked MobileAds#initialize reply survives the round trip, ADS-4, ADS-5),
// and the UMP channel's public mutable static, so consent can be faked
// without a second platform channel.
// ignore_for_file: implementation_imports
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart'
    show AdMessageCodec;
import 'package:google_mobile_ads/src/ump/user_messaging_channel.dart';

import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/services/ad_service.dart';
import 'package:monthly_expense_app/services/ads_config.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';
import 'package:monthly_expense_app/services/tracking_prompt.dart';

import 'helpers.dart';

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

    test(
      'the slot is a standard banner tall, not the large one (ADS-3)',
      () async {
        // Standing in for the plugin's side of its channel.
        const channel = MethodChannel('plugins.flutter.io/google_mobile_ads');
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        final asked = <String>[];
        messenger.setMockMethodCallHandler(channel, (call) async {
          asked.add(call.method);
          return 57;
        });
        addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

        expect(await DeviceAdService().bannerHeight(360), 57);
        // The large size leaves a blank band above and below most ads.
        expect(asked, ['AdSize#getAnchoredAdaptiveBannerAdSize']);
      },
    );
  });

  group('consent before the SDK ever starts (ADS-4, ADS-5, ADS-10, '
      'privacy-ios-desktop#9)', () {
    // The same channel name and codec the plugin's own AdInstanceManager
    // uses, so a faked reply to MobileAds#initialize decodes cleanly on its
    // side of the round trip.
    MethodChannel adsChannel() => MethodChannel(
      'plugins.flutter.io/google_mobile_ads',
      StandardMethodCodec(AdMessageCodec()),
    );

    late ConsentInformation originalConsentInfo;
    late UserMessagingChannel originalMessaging;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      originalConsentInfo = ConsentInformation.instance;
      originalMessaging = UserMessagingChannel.instance;
    });

    tearDown(() {
      ConsentInformation.instance = originalConsentInfo;
      UserMessagingChannel.instance = originalMessaging;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(adsChannel(), null);
    });

    /// Answers every consent call the same way, and records the order the
    /// consent steps and the SDK's own start happen in.
    ({List<String> order, void Function() install}) fakeConsent({
      required bool canRequest,
    }) {
      final order = <String>[];
      ConsentInformation.instance = _FakeConsentInformation(
        order,
        canRequest: canRequest,
      );
      UserMessagingChannel.instance = _FakeUserMessagingChannel(order);
      return (
        order: order,
        install: () {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(adsChannel(), (call) async {
                if (call.method == 'MobileAds#initialize') {
                  order.add('MobileAds#initialize');
                  return InitializationStatus(<String, AdapterStatus>{});
                }
                return null;
              });
        },
      );
    }

    test(
      'consent is settled, and checked, before the SDK is ever initialized',
      () async {
        final fake = fakeConsent(canRequest: true);
        fake.install();

        final started = await DeviceAdService().start();

        expect(started, isTrue);
        expect(fake.order, [
          'requestConsentInfoUpdate',
          'loadAndShowConsentFormIfRequired',
          'MobileAds#initialize',
        ]);
      },
    );

    test('a refusal means the SDK is never initialized at all', () async {
      final fake = fakeConsent(canRequest: false);
      fake.install();

      final started = await DeviceAdService().start();

      expect(started, isFalse);
      expect(fake.order, isNot(contains('MobileAds#initialize')));
    });

    group('then the tracking prompt, on iOS alone (ADS-17)', () {
      setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);

      test('comes after the consent flow and before the SDK starts', () async {
        final fake = fakeConsent(canRequest: true);
        fake.install();
        final tracking = FakeTrackingPrompt(log: fake.order);

        final started = await DeviceAdService(tracking: tracking).start();

        expect(started, isTrue);
        expect(tracking.asked, 1);
        expect(fake.order, [
          'requestConsentInfoUpdate',
          'loadAndShowConsentFormIfRequired',
          'tracking status',
          'tracking prompt',
          'MobileAds#initialize',
        ]);
      });

      test('saying no still starts the SDK: ads, just not personalised '
          '(ADS-5)', () async {
        final fake = fakeConsent(canRequest: true);
        fake.install();
        final tracking = FakeTrackingPrompt(
          answer: TrackingStatus.denied,
          log: fake.order,
        );

        final started = await DeviceAdService(tracking: tracking).start();

        expect(started, isTrue);
        expect(tracking.asked, 1);
        expect(fake.order.last, 'MobileAds#initialize');
      });

      test('is not asked when consent does not allow ads at all', () async {
        final fake = fakeConsent(canRequest: false);
        fake.install();
        final tracking = FakeTrackingPrompt(log: fake.order);

        final started = await DeviceAdService(tracking: tracking).start();

        expect(started, isFalse);
        expect(tracking.asked, 0);
        expect(fake.order, isNot(contains('tracking status')));
        expect(fake.order, isNot(contains('MobileAds#initialize')));
      });

      test('is not asked again once iOS has an answer', () async {
        // An earlier launch answered it, the consent message asked it
        // itself, or the device does not allow it to be asked at all.
        for (final known in [
          TrackingStatus.authorized,
          TrackingStatus.denied,
          TrackingStatus.restricted,
        ]) {
          final fake = fakeConsent(canRequest: true);
          fake.install();
          final tracking = FakeTrackingPrompt(current: known, log: fake.order);

          expect(await DeviceAdService(tracking: tracking).start(), isTrue);

          expect(tracking.asked, 0, reason: '$known');
          expect(fake.order, contains('MobileAds#initialize'));
        }
      });

      test('a prompt that fails still starts the SDK', () async {
        final fake = fakeConsent(canRequest: true);
        fake.install();

        final started = await DeviceAdService(tracking: _BrokenTrackingPrompt())
            .start();

        expect(started, isTrue);
        expect(fake.order.last, 'MobileAds#initialize');
      });

      test('waits for the app to be active, which iOS insists on', () async {
        final binding = TestWidgetsFlutterBinding.instance;
        addTearDown(
          () =>
              binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed),
        );
        binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        final fake = fakeConsent(canRequest: true);
        fake.install();
        final tracking = FakeTrackingPrompt(log: fake.order);

        final started = DeviceAdService(tracking: tracking).start();
        await pumpEventQueue();

        expect(tracking.asked, 0);
        expect(fake.order, isNot(contains('MobileAds#initialize')));

        binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

        expect(await started, isTrue);
        expect(tracking.asked, 1);
        expect(fake.order.last, 'MobileAds#initialize');
      });

      test('never goes over the lock screen (LOCK-2)', () async {
        final locked = ValueNotifier(true);
        final fake = fakeConsent(canRequest: true);
        fake.install();
        final tracking = FakeTrackingPrompt(log: fake.order);

        final started = DeviceAdService(
          tracking: tracking,
          locked: locked,
        ).start();
        await pumpEventQueue();

        expect(tracking.asked, 0);
        expect(fake.order, isNot(contains('MobileAds#initialize')));

        locked.value = false;

        expect(await started, isTrue);
        expect(tracking.asked, 1);
        expect(fake.order.last, 'MobileAds#initialize');
      });

      test('the app hands the real service its lock (LOCK-2)', () {
        // main.dart builds the one DeviceAdService, and no test builds the
        // app with it, so read the source: without the lock, the wait above
        // would only ever wait for the app to be active.
        final main = File('lib/main.dart').readAsStringSync();
        expect(main, contains('DeviceAdService(locked: appIsLocked)'));
      });

      test('is never asked on Android', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        final fake = fakeConsent(canRequest: true);
        fake.install();
        final tracking = FakeTrackingPrompt(log: fake.order);

        expect(await DeviceAdService(tracking: tracking).start(), isTrue);

        expect(tracking.asked, 0);
        expect(fake.order, [
          'requestConsentInfoUpdate',
          'loadAndShowConsentFormIfRequired',
          'MobileAds#initialize',
        ]);
      });

      test(
        'is never asked once "Remove ads" is bought (ADS-8, PAY-1)',
        () async {
          // The ad software is never started for someone who has paid, so
          // neither the consent form nor this prompt ever reaches them.
          Future<({List<String> order, FakeTrackingPrompt tracking})> launch({
            required bool owned,
          }) async {
            final fake = fakeConsent(canRequest: true);
            fake.install();
            final tracking = FakeTrackingPrompt(log: fake.order);
            final provider = AdsProvider(
              await testSettings({
                'setup_done': true,
                'walkthrough_seen': true,
              }),
              ads: DeviceAdService(tracking: tracking),
              purchases: FakePurchases(
                stage: PurchaseStage.offered,
                owns: owned,
              ),
            );
            addTearDown(provider.dispose);
            await provider.start();
            return (order: fake.order, tracking: tracking);
          }

          final paid = await launch(owned: true);
          expect(paid.tracking.asked, 0);
          expect(paid.order, isEmpty);

          // The same launch without the purchase does ask, so the one above is
          // quiet because of it.
          final free = await launch(owned: false);
          expect(free.tracking.asked, 1);
          expect(free.order.last, 'MobileAds#initialize');
        },
      );
    });
  });
}

/// A tracking prompt whose plugin call fails.
class _BrokenTrackingPrompt extends FakeTrackingPrompt {
  @override
  Future<TrackingStatus> request() async =>
      throw PlatformException(code: 'unavailable');
}

class _FakeConsentInformation implements ConsentInformation {
  _FakeConsentInformation(this.order, {this.canRequest = true});

  final List<String> order;
  final bool canRequest;

  @override
  void requestConsentInfoUpdate(
    ConsentRequestParameters params,
    OnConsentInfoUpdateSuccessListener successListener,
    OnConsentInfoUpdateFailureListener failureListener,
  ) {
    order.add('requestConsentInfoUpdate');
    successListener();
  }

  @override
  Future<bool> isConsentFormAvailable() async => true;

  @override
  Future<ConsentStatus> getConsentStatus() async => ConsentStatus.obtained;

  @override
  Future<void> reset() async {}

  @override
  Future<bool> canRequestAds() async => canRequest;

  @override
  Future<PrivacyOptionsRequirementStatus>
  getPrivacyOptionsRequirementStatus() async =>
      PrivacyOptionsRequirementStatus.notRequired;
}

class _FakeUserMessagingChannel extends UserMessagingChannel {
  _FakeUserMessagingChannel(this.order)
    : super(const MethodChannel('test/ump-unused'));

  final List<String> order;

  @override
  Future<FormError?> loadAndShowConsentFormIfRequired() async {
    order.add('loadAndShowConsentFormIfRequired');
    return null;
  }
}
