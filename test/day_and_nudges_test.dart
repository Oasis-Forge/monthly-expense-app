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
      provider.returnToToday();

      expect(provider.selectedDay, DateTime(2026, 10, 1));
      expect(provider.period.start, DateTime(2026, 10));
    });

    test('a day the user chose stays chosen', () async {
      var now = DateTime(2026, 9, 24, 23, 50);
      final provider = TransactionProvider(db: FakeDB(), clock: () => now);
      await provider.load();
      provider.selectDay(DateTime(2026, 9, 21));

      now = DateTime(2026, 9, 25, 8);
      provider.returnToToday();

      expect(provider.selectedDay, DateTime(2026, 9, 21));
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
