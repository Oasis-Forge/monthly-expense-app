import 'package:flutter/foundation.dart';

import '../services/ad_service.dart';
import '../services/ads_config.dart';
import '../services/purchase_service.dart';
import 'settings_provider.dart';

/// The one place that decides whether an ad slot fills (ADS-4, ADS-8,
/// ADS-9), and the only route from "Remove ads" to the slots going away.
///
/// A slot asks this, never the SDK, so an ad-free build and a paid ad-free
/// app are the same code path (ADS-8).
class AdsProvider extends ChangeNotifier {
  AdsProvider(
    this._settings, {
    AdService? ads,
    PurchaseService? purchases,
    ValueListenable<bool>? locked,
  }) : _ads = ads ?? const NoAdService(),
       _purchases = purchases ?? NoPurchases(),
       _locked = locked ?? ValueNotifier(false) {
    _purchases.addListener(_onChanged);
    _settings.addListener(_onSettingsChanged);
    _locked.addListener(_onChanged);
  }

  final AdService _ads;
  final PurchaseService _purchases;
  final SettingsProvider _settings;
  final ValueListenable<bool> _locked;

  bool _started = false;
  bool _mayRequest = false;

  /// Whether a slot should ask for an ad at all.
  ///
  /// Not before setup and the walkthrough are finished and consent has been
  /// answered (ADS-4), not once the ads have been bought away (ADS-8,
  /// PAY-1), and not while the app is locked (ADS-9, LOCK-2).
  bool get showAds => _mayRequest && !_purchases.adsRemoved && !_locked.value;

  /// Whether Settings offers "Privacy options" (ADS-5).
  bool get privacyOptionsRequired => _ads.privacyOptionsRequired;

  bool get adsRemoved => _purchases.adsRemoved;

  PurchaseStage get stage => _purchases.stage;

  String? get price => _purchases.price;

  String? get lastError => _purchases.lastError;

  /// Whether this build could ever show an ad: the desktop builds and the
  /// tests never can (ADS-1).
  bool get supported => AdsConfig.supportsAds;

  /// Starts the store and, once the first minutes of the app are over, the
  /// ad SDK (ADS-4). Safe to call again; it only acts once.
  Future<void> start() async {
    await _purchases.start();
    await _startAdsIfReady();
  }

  Future<void> _startAdsIfReady() async {
    if (_started) return;
    // ADS-4: the first minutes of the app belong to the app, so nothing is
    // requested — and no consent form appears — until setup (RUN-3) and the
    // walkthrough (RUN-4) are behind us.
    if (!_settings.setupDone || !_settings.walkthroughSeen) return;
    // Someone who has already paid is never asked for consent to ads they
    // will not see.
    if (_purchases.adsRemoved) return;
    _started = true;
    _mayRequest = await _ads.start();
    notifyListeners();
  }

  /// The height every slot reserves, looked up once and kept.
  Future<double?> bannerHeight(double width) async {
    if (!showAds) return null;
    return _heights[width] ??= await _ads.bannerHeight(width);
  }

  /// The height already known for [width], or null if it has never been
  /// asked for. A slot uses it on its first frame, so every slot after the
  /// first is the right size straight away instead of growing from nothing
  /// (ADS-2).
  double? knownBannerHeight(double width) => showAds ? _heights[width] : null;

  final _heights = <double, double?>{};

  /// Asks for a banner, or null when nothing filled (ADS-2).
  Future<LoadedBanner?> loadBanner(AdPlacement placement, double width) {
    if (!showAds) return Future.value(null);
    return _ads.loadBanner(placement, width);
  }

  Future<void> showPrivacyOptions() async {
    await _ads.showPrivacyOptions();
    notifyListeners();
  }

  Future<void> buyRemoveAds() => _purchases.buy();

  Future<void> restorePurchases() => _purchases.restore();

  void _onChanged() => notifyListeners();

  void _onSettingsChanged() {
    // Finishing the walkthrough is what lets the first request happen.
    _startAdsIfReady();
    notifyListeners();
  }

  @override
  void dispose() {
    _purchases.removeListener(_onChanged);
    _settings.removeListener(_onSettingsChanged);
    _locked.removeListener(_onChanged);
    super.dispose();
  }
}
