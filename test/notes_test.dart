import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 15, 10);
  const locale = Locale('en');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('provider notes (NOTE-1–NOTE-8)', () {
    late FakeDB fake;
    late FakeReminderService reminders;
    late DateTime now;
    late TransactionProvider provider;

    Future<void> reload() async {
      provider = TransactionProvider(
        db: fake,
        clock: () => now,
        reminders: reminders,
      );
      await provider.load(locale: locale);
    }

    Future<void> add(
      String id,
      String text, {
      DateTime? dueDate,
      DateTime? reminderAt,
      num? amount,
      String? categoryId,
    }) => provider.addNote(
      testNote(
        id,
        text,
        dueDate: dueDate,
        reminderAt: reminderAt,
        amount: amount,
        categoryId: categoryId,
      ),
      appLockOn: false,
      locale: locale,
    );

    setUp(() async {
      now = today;
      fake = FakeDB();
      reminders = FakeReminderService(now: () => now);
      await reload();
    });

    test('open notes sort overdue first, then by due date, then dateless notes '
        'by last edit (NOTE-2)', () async {
      await add('a', 'No date A');
      now = now.add(const Duration(minutes: 1));
      await add('b', 'No date B');
      await add('c', 'Due later', dueDate: DateTime(2026, 9, 20));
      await add('d', 'Overdue', dueDate: DateTime(2026, 9, 1));
      await add('e', 'Due today', dueDate: DateTime(2026, 9, 15));

      expect(
        [for (final n in provider.openNotes) n.id],
        ['d', 'e', 'c', 'b', 'a'],
      );
    });

    test('done notes list separately, most recently done first', () async {
      await add('a', 'One');
      await add('b', 'Two');
      await provider.setNoteDone('a', true, appLockOn: false, locale: locale);
      now = now.add(const Duration(minutes: 1));
      await provider.setNoteDone('b', true, appLockOn: false, locale: locale);

      expect(provider.openNotes, isEmpty);
      expect([for (final n in provider.doneNotes) n.id], ['b', 'a']);
    });

    test(
      'notesDueInPeriod and notesDueOn match open notes due in range (NOTE-5)',
      () async {
        await add('a', 'In period', dueDate: DateTime(2026, 9, 20));
        await add('b', 'Next period', dueDate: DateTime(2026, 10, 1));
        await add('c', 'No date');

        expect([for (final n in provider.notesDueInPeriod) n.id], ['a']);
        expect(
          [for (final n in provider.notesDueOn(DateTime(2026, 9, 20))) n.id],
          ['a'],
        );
        expect(
          [for (final n in provider.notesDueOn(DateTime(2026, 10, 1))) n.id],
          ['b'],
        );
        expect(provider.notesDueOn(DateTime(2026, 9, 21)), isEmpty);

        await provider.setNoteDone('a', true, appLockOn: false, locale: locale);
        expect(provider.notesDueInPeriod, isEmpty);
      },
    );

    test('deleting and restoring a note is undoable (NOTE-7)', () async {
      await add('a', 'Keep me');
      await provider.deleteNote('a');
      expect(provider.notes, isEmpty);

      await provider.restoreNote('a', appLockOn: false, locale: locale);
      expect(provider.notes.single.id, 'a');
      expect(provider.notes.single.deletedAt, isNull);
    });

    test('recording a note links it to the transaction and marks it done '
        '(NOTE-4)', () async {
      await add('a', 'Buy milk', amount: 5, categoryId: 'cat-food');
      await provider.recordNote('a', 'tx-1', appLockOn: false, locale: locale);

      final note = provider.noteById('a')!;
      expect(note.isDone, isTrue);
      expect(note.transactionId, 'tx-1');
      expect(provider.noteForTransaction('tx-1')?.id, 'a');
    });

    test('deleting the linked transaction reopens the note and re-arms its '
        'reminder (NOTE-4)', () async {
      await add(
        'a',
        'Buy milk',
        dueDate: DateTime(2026, 9, 20),
        reminderAt: DateTime(2026, 9, 20, 9),
      );
      await provider.addTransaction(
        testTx('tx-1', TransactionType.expense, 5, now),
      );
      await provider.recordNote('a', 'tx-1', appLockOn: false, locale: locale);
      expect(reminders.scheduled.containsKey('a'), isFalse);

      await provider.deleteTransaction('tx-1');

      final note = provider.noteById('a')!;
      expect(note.isDone, isFalse);
      expect(note.transactionId, isNull);
      expect(reminders.scheduled['a'], false);
    });

    test('undoing that delete marks the note done and linked again '
        '(NOTE-4, DEL-2)', () async {
      await add(
        'a',
        'Buy milk',
        dueDate: DateTime(2026, 9, 20),
        reminderAt: DateTime(2026, 9, 20, 9),
      );
      await provider.addTransaction(
        testTx('tx-1', TransactionType.expense, 5, now),
      );
      await provider.recordNote('a', 'tx-1', appLockOn: false, locale: locale);
      final doneAt = provider.noteById('a')!.doneAt;
      await provider.deleteTransaction('tx-1');

      await provider.restoreTransaction('tx-1');

      final note = provider.noteById('a')!;
      expect(note.transactionId, 'tx-1');
      expect(note.doneAt, doneAt);
      expect(reminders.scheduled.containsKey('a'), isFalse);
    });

    test('an edit made before the undo survives it (NOTE-4)', () async {
      await add('a', 'Buy milk');
      await provider.addTransaction(
        testTx('tx-1', TransactionType.expense, 5, now),
      );
      await provider.recordNote('a', 'tx-1', appLockOn: false, locale: locale);
      await provider.deleteTransaction('tx-1');
      await provider.updateNote(
        provider.noteById('a')!.copyWith(text: 'Buy oat milk'),
        appLockOn: false,
        locale: locale,
      );

      await provider.restoreTransaction('tx-1');

      final note = provider.noteById('a')!;
      expect(note.text, 'Buy oat milk');
      expect(note.transactionId, 'tx-1');
      expect(note.isDone, isTrue);
    });

    test('reminders are scheduled while open with a future time, and cancelled '
        'once done or deleted (NOTE-6)', () async {
      await add(
        'a',
        'Remind me',
        dueDate: DateTime(2026, 9, 20),
        reminderAt: DateTime(2026, 9, 20, 9),
      );
      expect(reminders.scheduled['a'], false);

      await provider.setNoteDone('a', true, appLockOn: false, locale: locale);
      expect(reminders.scheduled.containsKey('a'), isFalse);

      await provider.setNoteDone('a', false, appLockOn: true, locale: locale);
      expect(reminders.scheduled['a'], true);

      await provider.deleteNote('a');
      expect(reminders.scheduled.containsKey('a'), isFalse);
    });

    test(
      'reminders resync on load, e.g. after a reboot or a restore (NOTE-6)',
      () async {
        await add(
          'a',
          'Remind me',
          dueDate: DateTime(2026, 9, 20),
          reminderAt: DateTime(2026, 9, 20, 9),
        );
        reminders.scheduled.clear();

        await reload();

        expect(reminders.scheduled['a'], false);
      },
    );

    test('rescheduling re-words pending reminders for the new app lock '
        '(NOTE-6, LOCK-2)', () async {
      await add(
        'a',
        'Remind me',
        dueDate: DateTime(2026, 9, 20),
        reminderAt: DateTime(2026, 9, 20, 9),
      );
      expect(reminders.scheduled['a'], false);

      await provider.rescheduleReminders(appLockOn: true, locale: locale);

      expect(reminders.scheduled['a'], true);
    });

    group('a reminder whose time just passed is not cancelled for good '
        '(NOTE-6, NUDGE-9)', () {
      test(
        'one minute past keeps its scheduled entry through a reschedule',
        () async {
          now = DateTime(2026, 9, 20, 9);
          await add(
            'a',
            'Remind me',
            dueDate: DateTime(2026, 9, 20),
            reminderAt: DateTime(2026, 9, 20, 9),
          );
          now = DateTime(2026, 9, 20, 9, 1);

          await provider.rescheduleReminders(appLockOn: false, locale: locale);

          expect(
            reminders.scheduled.containsKey('a'),
            isTrue,
            reason:
                'the pending inexact alarm is still there; a reschedule '
                'must not drop it',
          );
        },
      );

      test('a done note is still cancelled even within the window', () async {
        now = DateTime(2026, 9, 20, 9);
        await add(
          'a',
          'Remind me',
          dueDate: DateTime(2026, 9, 20),
          reminderAt: DateTime(2026, 9, 20, 9),
        );
        now = DateTime(2026, 9, 20, 9, 1);

        await provider.setNoteDone('a', true, appLockOn: false, locale: locale);

        expect(reminders.scheduled.containsKey('a'), isFalse);
      });

      test('more than two hours past is not rescheduled', () async {
        now = DateTime(2026, 9, 20, 9);
        await add(
          'a',
          'Remind me',
          dueDate: DateTime(2026, 9, 20),
          reminderAt: DateTime(2026, 9, 20, 9),
        );
        now = DateTime(2026, 9, 20, 9, 1);
        await provider.rescheduleReminders(appLockOn: false, locale: locale);
        expect(reminders.scheduled.containsKey('a'), isTrue);

        now = DateTime(2026, 9, 20, 11, 1);
        await provider.rescheduleReminders(appLockOn: false, locale: locale);

        expect(reminders.scheduled.containsKey('a'), isFalse);
      });

      test(
        'a changed time cancels the old one, even within the window',
        () async {
          now = DateTime(2026, 9, 20, 9);
          await add(
            'a',
            'Remind me',
            dueDate: DateTime(2026, 9, 20),
            reminderAt: DateTime(2026, 9, 20, 9),
          );
          now = DateTime(2026, 9, 20, 9, 1);
          await provider.rescheduleReminders(appLockOn: false, locale: locale);
          expect(reminders.scheduled.containsKey('a'), isTrue);

          // Edited to a different time that has also already passed.
          await provider.updateNote(
            provider
                .noteById('a')!
                .copyWith(reminderAt: DateTime(2026, 9, 20, 8)),
            appLockOn: false,
            locale: locale,
          );

          expect(reminders.scheduled.containsKey('a'), isFalse);
        },
      );
    });
  });
}
