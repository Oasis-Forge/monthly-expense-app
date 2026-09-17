import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kReleaseMode;

/// Which slot an ad is for. Each has its own unit so AdMob reports on them
/// separately (ADS-1).
enum AdPlacement { home, insights }

/// The AdMob identifiers, and which set a build uses.
///
/// A release build serves the real units; every other build serves Google's
/// public test units. That is not a convenience: AdMob's policy forbids
/// impressions and clicks on your own live ads, and a development build that
/// serves them is the usual way an account is suspended. Change
/// [liveAdsEverywhere] only to check a real fill, and never tap the result.
///
/// None of these are secrets — they ship inside every APK — so they belong in
/// the repository rather than in a build secret.
class AdsConfig {
  const AdsConfig._();

  /// Set true to serve the real units in debug and profile builds too. Read
  /// the warning above first.
  static const liveAdsEverywhere = false;

  /// Google's test units, documented at
  /// https://developers.google.com/admob/flutter/test-ads. They always fill,
  /// and they earn nothing.
  static const _testAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const _testAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';

  // The real units, from the AdMob console. The app IDs also go in
  // `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`,
  // where the SDK reads them before Dart runs; keep all three in step.
  // Empty means "not set up yet", and then no ad is ever requested.
  static const liveAppIdAndroid = '';
  static const liveAppIdIos = '';
  static const liveBannerHomeAndroid = '';
  static const liveBannerInsightsAndroid = '';
  static const liveBannerHomeIos = '';
  static const liveBannerInsightsIos = '';

  static bool get _live => kReleaseMode || liveAdsEverywhere;

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  /// Whether this build has units to ask for at all. A release built before
  /// the real IDs were filled in shows no ads rather than asking with a
  /// placeholder (ADS-2: an empty slot shows nothing).
  static bool get isConfigured =>
      supportsAds && bannerUnitId(AdPlacement.home).isNotEmpty;

  /// Only Android and iOS have the SDK; the desktop builds have no ads at
  /// all, and neither does a test.
  static bool get supportsAds =>
      defaultTargetPlatform == TargetPlatform.android || _isIos;

  static String get appId => _live
      ? (_isIos ? liveAppIdIos : liveAppIdAndroid)
      : (_isIos ? _testAppIdIos : _testAppIdAndroid);

  static String bannerUnitId(AdPlacement placement) {
    if (!_live) return _isIos ? _testBannerIos : _testBannerAndroid;
    return switch ((placement, _isIos)) {
      (AdPlacement.home, false) => liveBannerHomeAndroid,
      (AdPlacement.insights, false) => liveBannerInsightsAndroid,
      (AdPlacement.home, true) => liveBannerHomeIos,
      (AdPlacement.insights, true) => liveBannerInsightsIos,
    };
  }

  /// True while the build is serving Google's test units, so a release that
  /// is quietly earning nothing is easy to spot.
  static bool get servingTestAds => !_live;
}
