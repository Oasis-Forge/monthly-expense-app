import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/app_update.dart';

void main() {
  final now = DateTime(2026, 9, 24, 14);

  group('updateIsDue (UPD-2, UPD-4)', () {
    test('a locked app is offered nothing (LOCK-1)', () {
      expect(updateIsDue(now: now, askedOn: null, locked: true), isFalse);
    });

    test('a device never asked before is asked', () {
      expect(updateIsDue(now: now, askedOn: null, locked: false), isTrue);
    });

    test('not twice in one day, whatever came of the first', () {
      expect(
        updateIsDue(now: now, askedOn: DateTime(2026, 9, 24, 1), locked: false),
        isFalse,
      );
    });

    test('again the next day, a minute later is enough', () {
      expect(
        updateIsDue(
          now: now,
          askedOn: DateTime(2026, 9, 23, 23, 59),
          locked: false,
        ),
        isTrue,
      );
    });

    test('the stored instant is read in the phone own day (UPD-4)', () {
      // The setting is written in UTC, so a day either side of midnight
      // would otherwise ask twice, or not at all.
      expect(
        updateIsDue(
          now: now,
          askedOn: DateTime(2026, 9, 24, 9).toUtc(),
          locked: false,
        ),
        isFalse,
      );
    });
  });
}
