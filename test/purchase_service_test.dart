import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// For InAppPurchasePlatformAddition, which the fake store has to name and
// `in_app_purchase.dart` doesn't re-export.
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import 'package:monthly_expense_app/services/purchase_service.dart';

/// A store under the test's control, in place of the real
/// `InAppPurchase.instance`.
class FakeStore implements InAppPurchase {
  FakeStore({this.available = true, this.products = const ['remove_ads']});

  bool available;

  /// Which product IDs the store knows about.
  List<String> products;

  /// Set to make `buyNonConsumable` throw, as a store that refuses the
  /// request does.
  Object? buyThrows;
  Object? restoreThrows;

  /// False for a purchase sheet that never opens.
  bool launches = true;

  final _updates = StreamController<List<PurchaseDetails>>.broadcast();
  int buys = 0;
  int restores = 0;
  final completed = <String>[];
  bool streamClosed = false;

  /// Pushes an update the way the platform does.
  void send(PurchaseDetails purchase) => _updates.add([purchase]);

  void fail(Object error) => _updates.addError(error);

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _updates.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async => ProductDetailsResponse(
    productDetails: [
      for (final id in identifiers.where(products.contains))
        ProductDetails(
          id: id,
          title: 'Remove ads',
          description: 'No more ads',
          price: 'US\$2.99',
          rawPrice: 2.99,
          currencyCode: 'USD',
        ),
    ],
    notFoundIDs: identifiers.where((id) => !products.contains(id)).toList(),
  );

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    if (buyThrows != null) throw buyThrows!;
    buys++;
    return launches;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    if (restoreThrows != null) throw restoreThrows!;
    restores++;
    // What the real Android plugin does: the query's own result goes to the
    // stream once the query has come back, and an account that owns nothing
    // gets an empty list rather than silence.
    //
    // On the event queue, not in this microtask: on a device the answer comes
    // back over its own platform-channel message, a turn or more after this
    // call returns. Adding it here instead would let a single `await` on
    // `start()` collect it, and no test could tell the two orderings apart.
    if (!answersRestores) return;
    unawaited(Future(() => _updates.add([...owned])));
  }

  /// What `restorePurchases` reports as already owned.
  List<PurchaseDetails> owned = const [];

  /// False for a store that takes the question and never answers it — iOS
  /// with nothing to restore, or an outage.
  bool answersRestores = true;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completed.add(purchase.productID);

  @override
  Future<String> countryCode() async => 'US';

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async => throw UnimplementedError();

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() =>
      throw UnimplementedError();
}

void main() {
  PurchaseDetails purchase(
    PurchaseStatus status, {
    String id = 'remove_ads',
    bool pendingComplete = true,
    IAPError? error,
  }) =>
      PurchaseDetails(
          productID: id,
          verificationData: PurchaseVerificationData(
            localVerificationData: '',
            serverVerificationData: '',
            source: 'test',
          ),
          transactionDate: null,
          status: status,
        )
        ..pendingCompletePurchase = pendingComplete
        ..error = error;

  group('asking the store at launch (PAY-5)', () {
    test('a store that is not there leaves nothing to sell', () async {
      final store = FakeStore(available: false);
      final service = DevicePurchaseService(store: store);

      await service.start();

      expect(service.stage, PurchaseStage.unavailable);
      expect(service.price, isNull);
      expect(service.adsRemoved, isFalse);
    });

    test(
      'a store without the product leaves nothing to sell (PAY-3)',
      () async {
        final store = FakeStore(products: const []);
        final service = DevicePurchaseService(store: store);

        await service.start();

        expect(service.stage, PurchaseStage.unavailable);
      },
    );

    test('the product brings its own price (PAY-6)', () async {
      final store = FakeStore();
      final service = DevicePurchaseService(store: store);

      await service.start();

      expect(service.stage, PurchaseStage.offered);
      expect(service.price, 'US\$2.99');
      // What this account already owns is asked for at every launch.
      expect(store.restores, 1);
    });

    test(
      'start knows what is owned before it returns (ADS-8, PAY-1)',
      () async {
        final store = FakeStore()..owned = [purchase(PurchaseStatus.restored)];
        final service = DevicePurchaseService(store: store);

        await service.start();

        // The receipt lands on the stream a turn after restorePurchases
        // returns. Until this was waited for, start() handed back "nothing is
        // owned", and AdsProvider took it at its word: the SDK started and a
        // paying user was asked for consent to ads they will never see.
        expect(service.stage, PurchaseStage.owned);
        expect(service.adsRemoved, isTrue);
      },
    );

    test('owning nothing is an answer, not a silence (ADS-4)', () async {
      final store = FakeStore();
      final service = DevicePurchaseService(
        store: store,
        // Long enough that the test would time out if the empty list the
        // store sends back were not treated as the answer it is.
        answerGrace: const Duration(seconds: 30),
      );

      await service.start();

      expect(service.stage, PurchaseStage.offered);
      expect(service.adsRemoved, isFalse);
    });

    test('a store that answers with silence lets go (ADS-4)', () async {
      final store = FakeStore()..answersRestores = false;
      final service = DevicePurchaseService(
        store: store,
        answerGrace: const Duration(milliseconds: 20),
      );

      await service.start();

      // Failing open: the free users the banners exist for are not made to
      // wait out an outage.
      expect(service.stage, PurchaseStage.offered);
      expect(service.adsRemoved, isFalse);
    });

    test('a store that refuses the question is not fatal', () async {
      final store = FakeStore()..restoreThrows = Exception('store is down');
      final service = DevicePurchaseService(
        store: store,
        answerGrace: const Duration(milliseconds: 20),
      );

      await service.start();

      expect(service.stage, PurchaseStage.offered);
      expect(service.lastError, contains('store is down'));
    });
  });

  group('what the store sends back', () {
    late FakeStore store;
    late DevicePurchaseService service;

    setUp(() async {
      store = FakeStore();
      service = DevicePurchaseService(store: store);
      await service.start();
    });

    tearDown(() => service.dispose());

    test(
      'a purchase turns the ads off and is completed (PAY-1, PAY-8)',
      () async {
        store.send(purchase(PurchaseStatus.purchased));
        await pumpEventQueue();

        expect(service.adsRemoved, isTrue);
        expect(service.stage, PurchaseStage.owned);
        // Not completing it would have the store charge again.
        expect(store.completed, ['remove_ads']);
      },
    );

    test('a restored purchase counts the same (PAY-5)', () async {
      store.send(purchase(PurchaseStatus.restored));
      await pumpEventQueue();

      expect(service.adsRemoved, isTrue);
      expect(store.completed, ['remove_ads']);
    });

    test('pending leaves everything as it was (PAY-8)', () async {
      store.send(purchase(PurchaseStatus.pending, pendingComplete: false));
      await pumpEventQueue();

      expect(service.stage, PurchaseStage.pending);
      expect(service.adsRemoved, isFalse);
      expect(store.completed, isEmpty);
    });

    test('an error says so, and the ads stay (PAY-8)', () async {
      store.send(
        purchase(
          PurchaseStatus.error,
          error: IAPError(source: 'test', code: 'nope', message: 'No good'),
        ),
      );
      await pumpEventQueue();

      expect(service.stage, PurchaseStage.offered);
      expect(service.adsRemoved, isFalse);
      expect(service.lastError, 'No good');
      // Even a failure is completed, or the store keeps sending it.
      expect(store.completed, ['remove_ads']);
    });

    test('backing out is not a failure, so nothing is said', () async {
      store.send(purchase(PurchaseStatus.canceled));
      await pumpEventQueue();

      expect(service.stage, PurchaseStage.offered);
      expect(service.lastError, isNull);
    });

    test('another product is none of our business', () async {
      store.send(purchase(PurchaseStatus.purchased, id: 'something_else'));
      await pumpEventQueue();

      expect(service.adsRemoved, isFalse);
      expect(store.completed, isEmpty);
    });

    test('once owned, a later event never puts the ads back (PAY-1)', () async {
      store.send(purchase(PurchaseStatus.purchased));
      await pumpEventQueue();
      expect(service.adsRemoved, isTrue);

      store.send(purchase(PurchaseStatus.canceled));
      await pumpEventQueue();

      expect(service.adsRemoved, isTrue);
      expect(service.stage, PurchaseStage.owned);
    });

    group('a sheet that closes without naming a product (PAY-8)', () {
      // What Android sends when the sheet closes with no purchase in it.
      PurchaseDetails closed(PurchaseStatus status, {String? message}) =>
          purchase(
            status,
            id: '',
            pendingComplete: false,
            error: message == null
                ? null
                : IAPError(source: 'test', code: 'purchase', message: message),
          );

      test('backing out puts the price back, and says nothing', () async {
        await service.buy();

        store.send(closed(PurchaseStatus.canceled));
        await pumpEventQueue();

        expect(service.stage, PurchaseStage.offered);
        expect(service.lastError, isNull);
        expect(store.restores, 1);
        expect(store.completed, isEmpty);
      });

      test(
        'a failure puts the price back, says so, and asks what is owned',
        () async {
          await service.buy();

          store.send(closed(PurchaseStatus.error, message: 'declined'));
          await pumpEventQueue();

          expect(service.stage, PurchaseStage.offered);
          expect(service.lastError, 'declined');
          expect(store.restores, 2);
        },
      );

      test('"already owned" ends with the ads off, and no error', () async {
        await service.buy();

        store.send(closed(PurchaseStatus.error, message: 'itemAlreadyOwned'));
        await pumpEventQueue();
        // The store answers the question that followed.
        store.send(purchase(PurchaseStatus.restored));
        await pumpEventQueue();

        expect(service.adsRemoved, isTrue);
        expect(service.lastError, isNull);
      });

      test('a purchase with no product in it proves nothing', () async {
        await service.buy();

        store.send(closed(PurchaseStatus.purchased));
        await pumpEventQueue();

        expect(service.adsRemoved, isFalse);
        expect(service.stage, PurchaseStage.offered);
        expect(store.restores, 2);
      });

      test('a failed check afterwards still leaves the price', () async {
        await service.buy();
        store.restoreThrows = StateError('no');

        store.send(closed(PurchaseStatus.error, message: 'declined'));
        await pumpEventQueue();

        expect(service.stage, PurchaseStage.offered);
      });

      test('with no purchase under way, it changes nothing', () async {
        store.send(closed(PurchaseStatus.error, message: 'stray'));
        await pumpEventQueue();

        expect(service.stage, PurchaseStage.offered);
        expect(service.lastError, isNull);
        expect(store.restores, 1);
      });
    });

    test(
      'a broken stream leaves nothing to sell rather than a dead button',
      () async {
        store.fail(StateError('the platform went away'));
        await pumpEventQueue();

        expect(service.stage, PurchaseStage.unavailable);
      },
    );
  });

  group('buying', () {
    test('sends it to the store and waits (PAY-8)', () async {
      final store = FakeStore();
      final service = DevicePurchaseService(store: store);
      await service.start();

      await service.buy();

      expect(store.buys, 1);
      expect(service.stage, PurchaseStage.pending);
      expect(service.adsRemoved, isFalse);
    });

    test('a store that refuses the request leaves the price there', () async {
      final store = FakeStore()..buyThrows = StateError('no');
      final service = DevicePurchaseService(store: store);
      await service.start();

      await service.buy();

      expect(service.stage, PurchaseStage.offered);
      expect(service.lastError, isNotNull);
    });

    test('a sheet that never opens puts the price back (PAY-8)', () async {
      final store = FakeStore()..launches = false;
      final service = DevicePurchaseService(store: store);
      await service.start();

      await service.buy();

      expect(store.buys, 1);
      expect(service.stage, PurchaseStage.offered);
      expect(service.lastError, isNotNull);
    });

    test('nothing happens when there is nothing to buy', () async {
      final service = DevicePurchaseService(
        store: FakeStore(products: const []),
      );
      await service.start();

      await service.buy();

      expect(service.stage, PurchaseStage.unavailable);
    });

    test('buying again once owned does nothing (PAY-8)', () async {
      final store = FakeStore();
      final service = DevicePurchaseService(store: store);
      await service.start();
      store.send(purchase(PurchaseStatus.purchased));
      await pumpEventQueue();

      await service.buy();

      expect(store.buys, 0);
      expect(service.stage, PurchaseStage.owned);
    });
  });

  group('restoring (PAY-5)', () {
    test('asks the store again', () async {
      final store = FakeStore();
      final service = DevicePurchaseService(store: store);
      await service.start();

      await service.restore();

      expect(store.restores, 2);
    });

    test('a failure is reported, not swallowed', () async {
      final store = FakeStore();
      final service = DevicePurchaseService(store: store);
      await service.start();
      store.restoreThrows = StateError('no');

      await service.restore();

      expect(service.lastError, isNotNull);
    });
  });

  test('the desktop builds have no store at all (PAY-3)', () async {
    final service = NoPurchases();

    await service.start();
    await service.buy();
    await service.restore();

    expect(service.stage, PurchaseStage.unavailable);
    expect(service.price, isNull);
    expect(service.lastError, isNull);
    expect(service.adsRemoved, isFalse);
  });
}
