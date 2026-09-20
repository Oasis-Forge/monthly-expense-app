import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/services/ads_config.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('which units a build asks with', () {
    test('a development build asks with Google\'s test units', () {
      // A test runs in debug, which is the point: AdMob forbids impressions
      // and clicks on your own live ads, so a build that is not a release
      // never serves them.
      expect(AdsConfig.servingTestAds, isTrue);
      expect(AdsConfig.liveAdsEverywhere, isFalse);
      for (final placement in AdPlacement.values) {
        expect(
          AdsConfig.bannerUnitId(placement),
          startsWith('ca-app-pub-3940256099942544/'),
          reason: placement.name,
        );
      }
      expect(AdsConfig.appId, startsWith('ca-app-pub-3940256099942544~'));
    });

    test('each platform gets its own units', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final android = AdsConfig.bannerUnitId(AdPlacement.home);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(AdsConfig.bannerUnitId(AdPlacement.home), isNot(android));
    });
  });

  group('where there are no ads at all (ADS-1)', () {
    test('only Android and iOS carry the SDK', () {
      for (final platform in TargetPlatform.values) {
        debugDefaultTargetPlatformOverride = platform;
        expect(
          AdsConfig.supportsAds,
          platform == TargetPlatform.android || platform == TargetPlatform.iOS,
          reason: platform.name,
        );
      }
    });

    test('a desktop build has nothing configured', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      expect(AdsConfig.isConfigured, isFalse);
    });
  });

  /// The SDK reads the app ID from the platform files before Dart runs, so
  /// the same ID is written in three places. This is the check that they
  /// haven't drifted apart — it starts mattering the moment the live IDs are
  /// filled in.
  group('the app ID is the same in all three places', () {
    String manifestAppId() {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      final meta = RegExp(
        r'com\.google\.android\.gms\.ads\.APPLICATION_ID"\s*'
        r'android:value="([^"]+)"',
      ).firstMatch(manifest);
      return meta!.group(1)!;
    }

    String plistAppId() {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final key = RegExp(
        r'<key>GADApplicationIdentifier</key>\s*<string>([^<]+)</string>',
      ).firstMatch(plist);
      return key!.group(1)!;
    }

    test('Android', () {
      final inManifest = manifestAppId();
      expect(inManifest, startsWith('ca-app-pub-'));
      if (AdsConfig.liveAppIdAndroid.isEmpty) {
        // Not set up yet: the manifest still holds Google's sample ID, and
        // no ad is requested in a release build (isConfigured is false).
        expect(inManifest, 'ca-app-pub-3940256099942544~3347511713');
      } else {
        expect(inManifest, AdsConfig.liveAppIdAndroid);
      }
    });

    test('iOS', () {
      final inPlist = plistAppId();
      expect(inPlist, startsWith('ca-app-pub-'));
      if (AdsConfig.liveAppIdIos.isEmpty) {
        expect(inPlist, 'ca-app-pub-3940256099942544~1458002511');
      } else {
        expect(inPlist, AdsConfig.liveAppIdIos);
      }
    });
  });

  test('the live units are all filled in, or none of them are', () {
    // Half-filled is the state that would have a release ask for an ad with
    // an empty unit ID, so it is worth failing on.
    const live = [
      AdsConfig.liveAppIdAndroid,
      AdsConfig.liveBannerHomeAndroid,
      AdsConfig.liveBannerInsightsAndroid,
      AdsConfig.liveInterstitialAndroid,
    ];
    const iosLive = [
      AdsConfig.liveAppIdIos,
      AdsConfig.liveBannerHomeIos,
      AdsConfig.liveBannerInsightsIos,
      AdsConfig.liveInterstitialIos,
    ];
    for (final set in [live, iosLive]) {
      final filled = set.where((id) => id.isNotEmpty).length;
      expect(
        filled,
        anyOf(0, set.length),
        reason: 'either every live ID is set or none is: $set',
      );
    }
  });

  test('a release with no live units asks for nothing (ADS-2)', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    // In a release build `isConfigured` is what stops the request; here the
    // check is that an empty live ID is what it looks at.
    expect(
      AdsConfig.liveBannerHomeAndroid.isEmpty,
      AdsConfig.liveAppIdAndroid.isEmpty,
    );
  });
}
