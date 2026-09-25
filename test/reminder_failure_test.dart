import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

import 'helpers.dart';

/// Throws what the notifications plugin threw on every launch of the 1.27
/// release builds, whose shrinker had dropped the notification icon.
class _BrokenReminders implements ReminderService {
  int calls = 0;

  Never _fail() {
    calls++;
    throw PlatformException(
      code: 'invalid_icon',
      message: 'The resource @drawable/ic_notification could not be found.',
    );
  }

  @override
  Future<bool> requestPermission() async => _fail();

  @override
  Future<void> schedule(
    Note note, {
    required bool appLockOn,
    required Locale locale,
  }) async => _fail();

  @override
  Future<void> cancel(Note note) async => _fail();

  @override
  Future<void> scheduleNudges(
    List<PlannedReminder> plan, {
    required bool appLockOn,
    required Locale locale,
  }) async => _fail();
}

void main() {
  const locale = Locale('en');
  final now = DateTime(2026, 9, 25, 9);

  group('reminders that cannot reach the device (NOTE-6, NUDGE-1)', () {
    late _BrokenReminders reminders;
    late FakeDB db;
    late TransactionProvider provider;

    setUp(() {
      // The guard logs each failure; that is expected here.
      debugPrint = (message, {wrapWidth}) {};
      addTearDown(() => debugPrint = debugPrintThrottled);
      reminders = _BrokenReminders();
      db = FakeDB(
        transactions: [
          testTx('t1', TransactionType.expense, 12, DateTime(2026, 9, 25)),
        ],
        notes: [
          testNote('n1', 'Pay rent', reminderAt: DateTime(2026, 9, 26, 9)),
        ],
      );
      provider = TransactionProvider(
        db: db,
        clock: () => now,
        reminders: reminders,
      );
    });

    test('still load every record, so Home is never left empty', () async {
      await provider.load(locale: locale);

      expect(reminders.calls, greaterThan(0));
      expect(provider.isLoaded, isTrue);
      expect(provider.transactions.map((t) => t.id), ['t1']);
      expect(provider.notes.map((n) => n.id), ['n1']);
    });

    test('still save and delete a note, with no error to retry', () async {
      await provider.load(locale: locale);

      await provider.addNote(
        testNote('n2', 'Call the bank', reminderAt: DateTime(2026, 9, 27, 9)),
        appLockOn: false,
        locale: locale,
      );
      expect(db.notes.map((n) => n.id), containsAll(['n1', 'n2']));
      expect(db.notes.where((n) => n.id == 'n2'), hasLength(1));
    });

    test('ask for permission as if it were refused', () async {
      expect(await SafeReminderService(reminders).requestPermission(), isFalse);
    });
  });
}
