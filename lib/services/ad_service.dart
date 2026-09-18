import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// A banner that has loaded and can go on screen, with the height the slot
/// has to reserve for it (ADS-2).
class LoadedBanner {
  const LoadedBanner({
    required this.view,
    required this.height,
    required this.dispose,
  });

  final Widget view;
  final double height;

  /// Frees the platform view. A slot calls this when it goes away.
  final Future<void> Function() dispose;
}

/// What the app asks of the ad network, behind an interface so widget tests
/// and the desktop builds never reach the SDK (ADS-1).
///
/// Nothing here takes anything the user typed: no amounts, titles, notes,
/// categories, accounts or search terms, and no keywords made from them
/// (ADS-7). The only request the app makes carries no targeting at all.
abstract interface class AdService {
  /// Starts the SDK and settles consent where the law asks for it — the EEA,
  /// the UK and Switzerland (ADS-5). Returns whether ads may be requested;
  /// false when consent was refused outright, the SDK failed to start, or
  /// this build has no units (ADS-2).
  Future<bool> start();

  /// Whether Settings should offer "Privacy options" (ADS-5). Only true in
  /// the places whose law asks for the form.
  bool get privacyOptionsRequired;

  /// Reopens the consent form from Settings (ADS-5).
  Future<void> showPrivacyOptions();

  /// The height a slot [width] wide has to reserve, asked before any ad is
  /// requested so the slot is already the right size when one arrives
  /// (ADS-2). Null when this build can't show one.
  Future<double?> bannerHeight(double width);

  /// A banner for [placement] at [width] logical pixels, or null if none
  /// filled. A slot that gets null shows nothing at all (ADS-2).
  Future<LoadedBanner?> loadBanner(AdPlacement placement, double width);
}

/// The Windows, Linux and macOS builds, where there is no ad SDK at all: no
/// slot ever fills, and nothing is asked of the network (ADS-1).
class NoAdService implements AdService {
  const NoAdService();

  @override
  bool get privacyOptionsRequired => false;

  @override
  Future<bool> start() async => false;

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  Future<double?> bannerHeight(double width) async => null;

  @override
  Future<LoadedBanner?> loadBanner(AdPlacement placement, double width) async =>
      null;
}

/// Set with `--dart-define=CONSENT_TEST_REGION=eea` (or `us`) to see the
/// consent form from anywhere. See [consentTestGeography].
const _consentTestRegion = String.fromEnvironment('CONSENT_TEST_REGION');

/// Where the consent form should believe the device is, or null for "where
/// it really is".
///
/// The form only appears in the places whose law asks for it (ADS-5), so
/// from anywhere else it can't be seen, let alone checked. A debug build run
/// with `CONSENT_TEST_REGION=eea` behaves as if it were in the EEA, and with
/// `us` as if it were in a regulated US state — the two messages published
/// in AdMob. A release build ignores the setting whatever it says, so no
/// real user can ever be shown a form meant for somewhere else. Emulators
/// need nothing more; a physical phone also has to be registered as a test
/// device in AdMob.
DebugGeography? consentTestGeography({
  required bool debug,
  required String region,
}) {
  if (!debug) return null;
  return switch (region.toLowerCase()) {
    'eea' => DebugGeography.debugGeographyEea,
    'us' => DebugGeography.debugGeographyRegulatedUsState,
    _ => null,
  };
}

/// The real thing, over `google_mobile_ads`.
class DeviceAdService implements AdService {
  bool _started = false;
  bool _canRequest = false;
  PrivacyOptionsRequirementStatus _privacyOptions =
      PrivacyOptionsRequirementStatus.unknown;

  @override
  bool get privacyOptionsRequired =>
      _privacyOptions == PrivacyOptionsRequirementStatus.required;

  @override
  Future<bool> start() async {
    if (_started) return _canRequest;
    _started = true;
    // Desktop has no SDK, and a build whose real units are still blank has
    // nothing to ask with.
    if (!AdsConfig.isConfigured) return false;

    await _settleConsent();
    if (!_canRequest) return false;
    await MobileAds.instance.initialize();
    return _canRequest;
  }

  /// Runs the consent flow to its end: the form appears only where it is
  /// required, and refusing means non-personalised ads rather than none —
  /// the SDK decides that, and answers [canRequestAds] accordingly (ADS-5).
  Future<void> _settleConsent() async {
    final consent = ConsentInformation.instance;
    final testing = consentTestGeography(
      debug: kDebugMode,
      region: _consentTestRegion,
    );
    // Testing the form means seeing it: forget the last answer each launch.
    if (testing != null) await consent.reset();
    final updated = Completer<void>();
    consent.requestConsentInfoUpdate(
      ConsentRequestParameters(
        consentDebugSettings: testing == null
            ? null
            : ConsentDebugSettings(debugGeography: testing),
      ),
      updated.complete,
      // A consent lookup that fails leaves the user unasked, so nothing is
      // requested. Ads are worth less than getting this wrong.
      (error) => updated.complete(),
    );
    await updated.future;

    final dismissed = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired(
      (error) => dismissed.complete(),
    );
    await dismissed.future;

    _canRequest = await consent.canRequestAds();
    _privacyOptions = await consent.getPrivacyOptionsRequirementStatus();
  }

  @override
  Future<void> showPrivacyOptions() async {
    final closed = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((error) => closed.complete());
    await closed.future;
    // The answer may have changed both of these.
    _canRequest = await ConsentInformation.instance.canRequestAds();
    _privacyOptions = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
  }

  @override
  Future<double?> bannerHeight(double width) async =>
      (await _sizeFor(width))?.height.toDouble();

  /// Anchored adaptive: the height follows the device and the orientation,
  /// and the SDK promises the same height for any given width, so a slot can
  /// reserve it before asking for an ad and nothing moves later (ADS-2).
  ///
  /// The standard size, not the large one the plugin now points to. The large
  /// slot is up to 15% of the screen, and the ordinary banners that fill it
  /// sit in its middle with blank space above and below, taken from the
  /// user's screen for nothing (ADS-3). Revisit if a plugin upgrade drops it.
  Future<AnchoredAdaptiveBannerAdSize?> _sizeFor(double width) =>
      // ignore: deprecated_member_use
      AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        width.truncate(),
      );

  @override
  Future<LoadedBanner?> loadBanner(AdPlacement placement, double width) async {
    if (!_canRequest) return null;
    final size = await _sizeFor(width);
    if (size == null) return null;

    final loaded = Completer<LoadedBanner?>();
    final banner = BannerAd(
      size: size,
      adUnitId: AdsConfig.bannerUnitId(placement),
      // No targeting: the SDK is handed nothing the user typed (ADS-7).
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (loaded.isCompleted) return;
          loaded.complete(
            LoadedBanner(
              view: AdWidget(ad: ad as BannerAd),
              height: size.height.toDouble(),
              dispose: ad.dispose,
            ),
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!loaded.isCompleted) loaded.complete(null);
        },
      ),
    );
    await banner.load();
    return loaded.future;
  }
}
