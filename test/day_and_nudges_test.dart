import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

void main() {
  group('back in the app on a later day (DAY-1, PER-1, ADD-3)', () {
    test('Home moves on to today, across a month end too', () async {
      var now = DateTime(2026, 9, 30, 23, 50);
      final provider = TransactionProvider(db: FakeDB(), clock: () => now);
      await provider.load();
      expect(provider.selectedDay, DateTime(2026, 9, 30));

      now = DateTime(2026, 10, 1, 8);
      await provider.returnToToday();

      expect(provider.selectedDay, DateTime(2026, 10, 1));
      expect(provider.period.start, DateTime(2026, 10));
    });

    test('a day the user chose stays chosen', () async {
      var now = DateTime(2026, 9, 24, 23, 50);
      final provider = TransactionProvider(db: FakeDB(), clock: () => now);
      await provider.load();
      provider.selectDay(DateTime(2026, 9, 21));

      now = DateTime(2026, 9, 25, 8);
      await provider.returnToToday();

      expect(provider.selectedDay, DateTime(2026, 9, 21));
    });

    test(
      'returnToToday is a no-op when the day has not changed (DAY-1)',
      () async {
        final now = DateTime(2026, 9, 24, 10);
        final provider = TransactionProvider(db: FakeDB(), clock: () => now);
        await provider.load();

        var notified = 0;
        provider.addListener(() => notified++);

        // The clock has not moved to a new day since load(); resuming again
        // must change nothing and notify no one.
        await provider.returnToToday();

        expect(notified, 0);
      },
    );

    test('an automatic occurrence due after the app resumes on a new day, with '
        'no reload, is posted (RCR-4, RCR-7, audit rules-6-10#7)', () async {
      var now = DateTime(2026, 9, 30, 22);
      final provider = TransactionProvider(
        db: FakeDB(
          rules: [testRule('Rent', 900, DateTime(2026, 10, 1), autoPost: true)],
        ),
        clock: () => now,
      );
      await provider.load();
      // Loaded the evening before: the occurrence is due tomorrow, so
      // nothing has posted yet.
      expect(provider.transactions, isEmpty);

      // The clock crosses midnight while the process stays alive (no new
      // load()); the app comes back to the foreground on the new day,
      // same as main.dart's AppLifecycleState.resumed handler.
      now = DateTime(2026, 10, 1, 9);
      await provider.returnToToday();

      expect(
        provider.transactions,
        hasLength(1),
        reason: 'the automatic occurrence due today should have posted',
      );
    });

    test(
      'a shortcut or widget tap brings a stale day forward too, so a new '
      'entry does not land on an earlier day (DAY-1, DAY-9, NAV-8)',
      () async {
        var now = DateTime(2026, 9, 20, 9);
        final provider = TransactionProvider(db: FakeDB(), clock: () => now);
        await provider.load();
        expect(provider.selectedDay, DateTime(2026, 9, 20));

        // Four days pass in the same period, with no lifecycle-resumed event
        // in between -- exactly what a shortcut or widget tap's _open does
        // in main.dart before pushing the add-transaction form.
        now = DateTime(2026, 9, 24, 10);
        provider.showCurrentPeriod();

        expect(provider.selectedDay, DateTime(2026, 9, 24));
        expect(provider.newEntryDate, DateTime(2026, 9, 24, 10));
      },
    );

    test('showCurrentPeriod keeps a day the user deliberately chose (WID-3, '
        'ADD-3, DAY-9)', () async {
      var now = DateTime(2026, 9, 24, 9);
      final provider = TransactionProvider(db: FakeDB(), clock: () => now);
      await provider.load();
      provider.selectDay(DateTime(2026, 9, 21));

      now = DateTime(2026, 9, 24, 10);
      provider.showCurrentPeriod();

      expect(provider.newEntryDate, DateTime(2026, 9, 21, 10));
    });
  });

  test(
    'an entry made today calls off tonight\'s empty-day nudge (NUDGE-4)',
    () async {
      final now = DateTime(2026, 9, 15, 9);
      final reminders = FakeReminderService();
      final provider = TransactionProvider(
        db: FakeDB(),
        clock: () => now,
        reminders: reminders,
      );
      await provider.load(
        nudge: const NudgeSettings(on: true, hour: 20, minute: 0),
      );
      bool tonight() => reminders.nudges.any(
        (r) =>
            r.kind == ReminderKind.emptyDay &&
            r.at == DateTime(2026, 9, 15, 20),
      );
      expect(tonight(), isTrue);

      await provider.addTransaction(
        testTx('t1', TransactionType.expense, 5, DateTime(2026, 9, 15)),
      );
      await pumpEventQueue();

      expect(tonight(), isFalse);
    },
  );

  test('ignored nudges wait for the entries to be read (NUDGE-5)', () async {
    final provider = TransactionProvider(
      db: FakeDB(),
      clock: () => DateTime(2026, 9, 15, 9),
    );
    var loaded = false;
    final waiting = provider.whenLoaded.then((_) => loaded = true);
    await pumpEventQueue();
    expect(loaded, isFalse);

    await provider.load();
    await waiting;

    expect(loaded, isTrue);
    expect(provider.isLoaded, isTrue);
  });
}
