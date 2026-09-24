import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:monthly_expense_app/services/review_service.dart';
import 'package:monthly_expense_app/services/shortcut_service.dart';

/// The plugin's own class, answered rather than reached.
class _FakeInAppReview implements InAppReview {
  _FakeInAppReview({this.available = true});

  final bool available;
  int requested = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async => requested++;

  @override
  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) async {}
}

class _FakeQuickActions implements QuickActions {
  List<ShortcutItem>? items;
  QuickActionHandler? handler;

  @override
  Future<void> initialize(QuickActionHandler handler) async =>
      this.handler = handler;

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async =>
      this.items = items;

  @override
  Future<void> clearShortcutItems() async => items = null;
}

void main() {
  /// Runs [body] as though the app were on [platform].
  Future<void> on(TargetPlatform platform, Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = platform;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await body();
    debugDefaultTargetPlatformOverride = null;
  }

  group('the rating sheet at the platform edge (RATE-2, RATE-5)', () {
    test(
      'a phone asks the store, once the store says it is available',
      () async {
        await on(TargetPlatform.android, () async {
          final review = _FakeInAppReview();
          final service = DeviceReviewService(review: review);

          expect(service.supported, isTrue);
          await service.ask();
          expect(review.requested, 1);
        });
      },
    );

    test('a store that is not ready is not asked twice over', () async {
      await on(TargetPlatform.iOS, () async {
        final review = _FakeInAppReview(available: false);
        await DeviceReviewService(review: review).ask();

        expect(review.requested, 0);
      });
    });

    test('a desktop build asks nothing at all', () async {
      await on(TargetPlatform.windows, () async {
        final review = _FakeInAppReview();
        final service = DeviceReviewService(review: review);

        expect(service.supported, isFalse);
        await service.ask();
        expect(review.requested, 0);
        expect(deviceOrNoReviews(), isA<NoReviews>());
      });
      await on(TargetPlatform.android, () async {
        expect(deviceOrNoReviews(), isA<DeviceReviewService>());
      });
    });

    test('the version it counts against is the running one (RATE-4)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      PackageInfo.setMockInitialValues(
        appName: 'Monthly Expenses',
        packageName: 'com.oasisforge.monthlyexpenses',
        version: '1.25.0',
        buildNumber: '37',
        buildSignature: '',
      );

      expect(await DeviceReviewService().version(), '1.25.0+37');
    });

    test('nothing at all is still a ReviewService', () async {
      const service = NoReviews();

      expect(service.supported, isFalse);
      expect(await service.version(), isEmpty);
      await service.ask();
    });
  });

  group('the icon menu at the platform edge (NAV-8)', () {
    test('a phone is given the three items and hears the choice', () async {
      await on(TargetPlatform.android, () async {
        final actions = _FakeQuickActions();
        final service = DeviceShortcuts(actions);
        var chosen = '';

        expect(service.supported, isTrue);
        service.onSelected((type) => chosen = type);
        await service.setItems([
          (type: 'add_expense', label: 'Add expense'),
          (type: 'transfer', label: 'Transfer'),
        ]);

        expect(actions.items?.map((item) => item.type).toList(), [
          'add_expense',
          'transfer',
        ]);
        expect(actions.items?.first.localizedTitle, 'Add expense');

        actions.handler?.call('transfer');
        expect(chosen, 'transfer');
      });
    });

    test('a desktop build is given nothing', () async {
      await on(TargetPlatform.linux, () async {
        final actions = _FakeQuickActions();
        final service = DeviceShortcuts(actions);

        expect(service.supported, isFalse);
        service.onSelected((_) {});
        await service.setItems([(type: 'add_expense', label: 'Add expense')]);

        expect(actions.items, isNull);
        expect(actions.handler, isNull);
        expect(deviceOrNoShortcuts(), isA<NoShortcuts>());
      });
    });

    test('nothing at all is still a ShortcutService', () async {
      const service = NoShortcuts();

      expect(service.supported, isFalse);
      service.onSelected((_) {});
      await service.setItems([(type: 'add_expense', label: 'Add expense')]);
    });
  });
}
