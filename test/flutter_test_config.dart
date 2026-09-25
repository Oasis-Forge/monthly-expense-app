import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/screens/app_lock.dart';

/// Runs before every test in every file under `test/` (each file's own
/// `setUp`/`tearDown` still apply on top of this). [appIsLocked] and
/// [AdsProvider]'s undo timer both live in top-level statics, so without
/// this a test that forgets to reset one can leave it set for whichever
/// test the runner happens to schedule next -- passing or failing by
/// order rather than by what it actually checks (ADS-9, ADS-11, LOCK-2,
/// test-quality#11).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() {
    appIsLocked.value = false;
    AdsProvider.forgetUndo();
  });
  await testMain();
}
