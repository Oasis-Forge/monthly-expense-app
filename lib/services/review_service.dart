import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The store's own rating sheet (RATE-2), and the version the app is running
/// as, which is what "once per version" counts against (RATE-4).
abstract class ReviewService {
  /// Whether this build can ask at all (RATE-5).
  bool get supported;

  /// The running version, in the `1.24.0+36` shape the backup file uses.
  Future<String> version();

  /// Asks the store to put its sheet up. The store decides whether it really
  /// appears and says nothing either way, which is why the caller counts the
  /// asking as spent before this is awaited (RATE-4).
  Future<void> ask();
}

class DeviceReviewService implements ReviewService {
  DeviceReviewService({InAppReview? review})
    : _review = review ?? InAppReview.instance;

  final InAppReview _review;

  @override
  bool get supported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<String> version() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  @override
  Future<void> ask() async {
    if (!supported || !await _review.isAvailable()) return;
    await _review.requestReview();
  }
}

/// Windows and Linux, where there is no store sheet to ask through and no
/// review code that could reach a network (RATE-5, RUN-2).
class NoReviews implements ReviewService {
  const NoReviews();

  @override
  bool get supported => false;

  @override
  Future<String> version() async => '';

  @override
  Future<void> ask() async {}
}

/// The store's sheet where there is a store, and nothing at all where there
/// is not (RATE-5).
ReviewService deviceOrNoReviews() =>
    defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS
    ? DeviceReviewService()
    : const NoReviews();
