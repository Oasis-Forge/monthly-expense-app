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
  ///
  /// It does not return until the store has answered, so that whoever reads
  /// [adsRemoved] afterwards reads a settled answer rather than "nothing, so
  /// far". [AdsProvider.start] reads it immediately, and starting the ad SDK
  /// on someone who has paid asks them for consent to ads they will never see
  /// (ADS-8). An implementation that cannot get an answer gives up rather
  /// than hanging.
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
  DevicePurchaseService({InAppPurchase? store, Duration? answerGrace})
    : _store = store ?? InAppPurchase.instance,
      _answerGrace = answerGrace ?? const Duration(seconds: 3);

  final InAppPurchase _store;
  StreamSubscription<List<PurchaseDetails>>? _updates;

  /// How long [start] waits for the store to say what is owned before giving
  /// up on it. Only a store that answers with silence ever reaches it.
  final Duration _answerGrace;

  /// Completed by the first stream event after [start] — the store's answer
  /// about what this account owns (PAY-5).
  final _answered = Completer<void>();
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
      onError: (_) {
        // A stream that errors has answered too (ADS-8).
        if (!_answered.isCompleted) _answered.complete();
        _settle(PurchaseStage.unavailable);
      },
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
    // comes back through the stream, so the answer is not in hand when this
    // returns — it is in hand when that event has been handled. Returning any
    // earlier tells a paying user's app that nothing is owned, and the ad SDK
    // starts and asks them for consent to ads they will never see (ADS-8).
    try {
      await _store.restorePurchases();
    } catch (error) {
      // A store that refuses the question has answered it as far as we are
      // concerned: waiting longer would only hold the app back.
      _lastError = '$error';
      notifyListeners();
      return;
    }
    // Android sends the restore's own result even when nothing is owned, so
    // this normally completes on the next turn of the loop. The grace is for
    // a store that answers with silence.
    await _answered.future.timeout(_answerGrace, onTimeout: () {});
  }

  @override
  Future<void> buy() async {
    final product = _product;
    if (product == null || _stage == PurchaseStage.owned) return;
    _lastError = null;
    _settle(PurchaseStage.pending);
    try {
      final launched = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      // A sheet that never opened sends nothing back, so waiting for the
      // store would never end.
      if (!launched) {
        _lastError = 'The store did not open the purchase.';
        _settle(PurchaseStage.offered);
      }
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
    // The store has answered. An empty list is an answer too: it is what
    // Android sends back when the account owns nothing (ADS-8).
    if (!_answered.isCompleted) _answered.complete();
    for (final purchase in purchases) {
      // Android reports a sheet that closed with no purchase in it — backed
      // out of, declined, or already owned — with no product ID at all. Only
      // one thing is sold, so it is about ours.
      if (purchase.productID.isEmpty) {
        await _onSheetClosed(purchase);
        continue;
      }
      if (purchase.productID != PurchaseService.removeAdsId) continue;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _settle(PurchaseStage.pending);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Whatever went wrong on the way, it ended owned.
          _lastError = null;
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

  /// A purchase sheet that closed without naming a product. It proves nothing
  /// is owned, so it only ever puts the price back (PAY-8); the store is then
  /// asked what this account owns, which is how "already owned" or a
  /// purchase reported without its details still ends with the ads off.
  Future<void> _onSheetClosed(PurchaseDetails result) async {
    if (_stage != PurchaseStage.pending) return;
    _lastError = result.status == PurchaseStatus.error
        ? result.error?.message
        : null;
    _settle(
      _product == null ? PurchaseStage.unavailable : PurchaseStage.offered,
    );
    if (result.status == PurchaseStatus.canceled) return;
    try {
      await _store.restorePurchases();
    } catch (_) {
      // The price is back and Restore purchases sits beside it.
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
