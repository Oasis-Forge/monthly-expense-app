import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// How the one purchase the app sells is getting on (PAY-1, PAY-8).
enum PurchaseStage {
  /// Nothing has been asked of the store yet.
  checking,

  /// The store can't be reached, or has no such product — so nothing is
  /// offered rather than a button that fails (PAY-3).
  unavailable,

  /// The store answered and the purchase is there to buy.
  offered,

  /// Sent to the store and not yet settled. Nothing changes until it is
  /// (PAY-8).
  pending,

  /// Bought, or restored on a new device (PAY-1, PAY-5).
  owned,
}

/// "Remove ads": one non-consumable purchase, with no account and no server
/// of ours — the store's own receipt on the device decides it (PAY-5).
///
/// The device implementation is [DevicePurchaseService]; tests use a fake.
abstract class PurchaseService extends ChangeNotifier {
  /// The product as it is named in the Play Console and App Store Connect.
  /// Changing it after the first release orphans what people already bought.
  static const removeAdsId = 'remove_ads';

  PurchaseStage get stage;

  /// The price as the store gives it, in the buyer's own currency, never
  /// hard-coded and nothing to do with the app's currency setting (PAY-6).
  String? get price;

  /// Set when the last attempt failed, for the screen to show once.
  String? get lastError;

  bool get adsRemoved => stage == PurchaseStage.owned;

  /// Asks the store what this costs and what is already owned. Called at
  /// every launch, so a refund or a family-shared purchase lands without a
  /// reinstall (PAY-5).
  Future<void> start();

  Future<void> buy();

  /// "Restore purchases", beside the price (PAY-5).
  Future<void> restore();
}

/// The platforms with no store plugin — Windows and Linux — where asking
/// `InAppPurchase.instance` for anything would throw. Nothing is owned and
/// nothing is offered, so the screen says there is nothing to sell (PAY-3).
class NoPurchases extends PurchaseService {
  @override
  PurchaseStage get stage => PurchaseStage.unavailable;

  @override
  String? get price => null;

  @override
  String? get lastError => null;

  @override
  Future<void> start() async {}

  @override
  Future<void> buy() async {}

  @override
  Future<void> restore() async {}
}

/// The real thing, over `in_app_purchase`.
class DevicePurchaseService extends PurchaseService {
  DevicePurchaseService({InAppPurchase? store})
    : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;
  StreamSubscription<List<PurchaseDetails>>? _updates;
  PurchaseStage _stage = PurchaseStage.checking;
  ProductDetails? _product;
  String? _lastError;

  @override
  PurchaseStage get stage => _stage;

  @override
  String? get price => _product?.price;

  @override
  String? get lastError => _lastError;

  @override
  Future<void> start() async {
    // Listening first: a purchase left pending by a closed app arrives here
    // as soon as the stream opens, and finishing it is what stops a second
    // charge (PAY-8).
    _updates ??= _store.purchaseStream.listen(
      _onUpdates,
      onError: (_) => _settle(PurchaseStage.unavailable),
    );

    if (!await _store.isAvailable()) return _settle(PurchaseStage.unavailable);

    final response = await _store.queryProductDetails({
      PurchaseService.removeAdsId,
    });
    final product = response.productDetails.firstOrNull;
    if (product == null) return _settle(PurchaseStage.unavailable);
    _product = product;
    _settle(PurchaseStage.offered);

    // What the store already knows about this account (PAY-5). Anything owned
    // comes back through the stream.
    await _store.restorePurchases();
  }

  @override
  Future<void> buy() async {
    final product = _product;
    if (product == null || _stage == PurchaseStage.owned) return;
    _lastError = null;
    _settle(PurchaseStage.pending);
    try {
      await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (error) {
      _lastError = '$error';
      _settle(PurchaseStage.offered);
    }
  }

  @override
  Future<void> restore() async {
    _lastError = null;
    try {
      await _store.restorePurchases();
    } catch (error) {
      _lastError = '$error';
      notifyListeners();
    }
  }

  Future<void> _onUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != PurchaseService.removeAdsId) continue;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _settle(PurchaseStage.pending);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _settle(PurchaseStage.owned);
        case PurchaseStatus.error:
          _lastError = purchase.error?.message;
          _settle(
            _product == null
                ? PurchaseStage.unavailable
                : PurchaseStage.offered,
          );
        case PurchaseStatus.canceled:
          // Backing out is not a failure, so it says nothing.
          _settle(
            _product == null
                ? PurchaseStage.unavailable
                : PurchaseStage.offered,
          );
      }
      // Always, whatever the outcome: an uncompleted purchase is retried by
      // the store and can charge twice (PAY-8).
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
  }

  void _settle(PurchaseStage stage) {
    // Owning it is final for this session: a later "offered" from a stray
    // stream event must not put the ads back (PAY-1).
    if (_stage == PurchaseStage.owned && stage != PurchaseStage.owned) return;
    if (_stage == stage) return;
    _stage = stage;
    notifyListeners();
  }

  @override
  void dispose() {
    _updates?.cancel();
    super.dispose();
  }
}
