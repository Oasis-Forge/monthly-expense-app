import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/rating.dart';

void main() {
  final firstOpened = DateTime(2026, 9, 1);
  final aWeekOn = firstOpened.add(ratingAge);

  bool due({
    int entries = ratingEntries,
    DateTime? now,
    String version = '1.24.0+36',
    String? askedVersion,
    bool locked = false,
    bool adShownThisSession = false,
    bool updateAskedToday = false,
  }) => ratingIsDue(
    entries: entries,
    firstOpened: firstOpened,
    now: now ?? aWeekOn,
    version: version,
    askedVersion: askedVersion,
    locked: locked,
    adShownThisSession: adShownThisSession,
    updateAskedToday: updateAskedToday,
  );

  group('when the app may ask for a rating (RATE-1, RATE-3, RATE-4)', () {
    test('fifteen entries and a week is the moment, and not before', () {
      expect(due(), isTrue);

      // One entry short, or one day short, and it says nothing.
      expect(due(entries: ratingEntries - 1), isFalse);
      expect(due(now: aWeekOn.subtract(const Duration(days: 1))), isFalse);
      // More of either is still a yes.
      expect(due(entries: 400), isTrue);
      expect(due(now: DateTime(2027)), isTrue);
    });

    test('the lines are fifteen entries and a week, in figures (RATE-1)', () {
      // Written out rather than through the constants, so that moving either
      // line is a change to the rule and cannot pass unnoticed.
      final later = DateTime(2026, 9, 30);
      expect(due(entries: 14, now: later), isFalse);
      expect(due(entries: 15, now: later), isTrue);
      // Opened on 1 September: not yet on the 7th, and due by the 8th.
      expect(due(entries: 15, now: DateTime(2026, 9, 7, 12)), isFalse);
      expect(due(entries: 15, now: DateTime(2026, 9, 8, 12)), isTrue);
    });

    test('a version that has asked never asks again', () {
      expect(due(askedVersion: '1.24.0+36'), isFalse);
      // The next version may ask once of its own.
      expect(due(askedVersion: '1.23.1+35'), isTrue);
      expect(due(askedVersion: null), isTrue);
    });

    test('never over a lock screen, and never after an ad', () {
      expect(due(locked: true), isFalse);
      expect(due(adShownThisSession: true), isFalse);
    });

    test('never on the same day the update was offered, even once that '
        'save is done (UPD-3)', () {
      expect(due(updateAskedToday: true), isFalse);
      // Another day, and it is owed again.
      expect(due(updateAskedToday: false), isTrue);
    });
  });
}
