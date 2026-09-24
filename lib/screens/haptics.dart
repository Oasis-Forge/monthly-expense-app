import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// What the phone says back (HAP-1–HAP-4). All of it follows the phone's own
/// vibration setting: there is nothing here for the app to switch off, and a
/// phone without a motor simply feels none of it.

/// A key on the amount keypad, where a digit appearing is otherwise the only
/// sign the tap landed (HAP-1).
void keyFeedback() => unawaited(HapticFeedback.selectionClick());

/// The one firmer knock in the app: a record has just been written (HAP-2).
void saveFeedback() => unawaited(HapticFeedback.mediumImpact());

/// The point in a swipe where letting go would delete the row (HAP-3).
void thresholdFeedback() => unawaited(HapticFeedback.selectionClick());

/// Wired to a [Dismissible]'s `onUpdate`: one tick as the row passes the
/// point where letting go would delete it, and none on the way back (HAP-3).
void swipeUpdate(DismissUpdateDetails details) {
  if (details.reached && !details.previousReached) thresholdFeedback();
}
