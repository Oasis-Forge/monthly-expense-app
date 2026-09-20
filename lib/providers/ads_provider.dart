import 'package:flutter/foundation.dart';

import '../services/ad_service.dart';
import '../services/ads_config.dart';
import '../services/purchase_service.dart';
import 'settings_provider.dart';

/// Where a full-screen ad may appear (ADS-11): the moment a self-contained
/// job has ended and the user is on their way out of it. There are four,
/// and a screen cannot invent a fifth without a rule and a value here.
enum AdSeam {
  /// Back to Home from Insights.
  leftInsights,

  /// A PDF report has been made.
  madeReport,

  /// A CSV export has been written.
  exportedCsv,

  /// An import has finished.
  importedCsv,
}

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

  /// When an Undo was last put on screen (DEL-2). Static because the snack
  /// bar is shown from screens that have no provider in hand, and there is
  /// only ever one app.
  static DateTime? _undoShownAt;

  /// Told by [showUndoSnackBar] that an Undo is on screen, so a seam in the
  /// next five seconds lets its ad go rather than cover the way back
  /// (ADS-11). [at] is for tests.
  static void noteUndoShown([DateTime? at]) =>
      _undoShownAt = at ?? DateTime.now();

  /// Forgets it, for tests that must not inherit another's Undo.
  static void forgetUndo() => _undoShownAt = null;

  static bool get _undoOnScreen {
    final shown = _undoShownAt;
    return shown != null &&
        DateTime.now().difference(shown) < const Duration(seconds: 5);
  }

  LoadedInterstitial? _interstitial;
  bool _fetching = false;

  /// Whether one is in hand, so a test can say what a seam will do.
  bool get interstitialReady => _interstitial != null;

  /// Fetches the full-screen ad for a seam that is coming, so arriving at
  /// it costs no wait (ADS-13). Safe to call again: it holds one at most,
  /// and it asks for nothing on a day that is already spent (ADS-12).
  Future<void> primeInterstitial(int transactionCount) async {
    if (_interstitial != null || _fetching) return;
    if (!_mayShowInterstitial(transactionCount)) return;
    _fetching = true;
    _interstitial = await _ads.loadInterstitial();
    _fetching = false;
  }

  /// Shows the full-screen ad at [seam] if one is already in hand, and
  /// counts the day's one showing only once it has really been seen
  /// (ADS-12). A seam that finds nothing ready passes in silence, and
  /// nothing is fetched to fill it (ADS-13).
  Future<void> showAtSeam(AdSeam seam, int transactionCount) async {
    final ad = _interstitial;
    if (ad == null) return;
    _interstitial = null;
    // Bought away, locked, or the day spent since it was fetched: let it go
    // rather than keep it for a moment that no longer allows one (ADS-15).
    if (!_mayShowInterstitial(transactionCount)) {
      await ad.dispose();
      return;
    }
    await ad.show();
    await _settings.markInterstitialShown();
  }

  /// Everything a banner has to satisfy (ADS-15), plus the day's own cap
  /// (ADS-12) and a build with a unit to ask with (ADS-16).
  bool _mayShowInterstitial(int transactionCount) =>
      showAds &&
      AdsConfig.interstitialConfigured &&
      _settings.interstitialDue(transactionCount) &&
      !_undoOnScreen;

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
    _interstitial?.dispose();
    super.dispose();
  }
}
