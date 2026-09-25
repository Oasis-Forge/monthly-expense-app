import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/models/backup.dart';
import 'package:monthly_expense_app/models/reminders.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/backup_screen.dart';
import 'package:monthly_expense_app/services/backup_service.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  final today = DateTime(2026, 9, 15, 10);
  late FakeDB fake;
  late FakeBackupFiles files;
  late TransactionProvider provider;
  late SettingsProvider settings;
  late BackupService service;

  setUp(() async {
    fake = FakeDB(
      transactions: [
        testTx('lunch', expense, 12.5, DateTime(2026, 9, 10), title: 'Lunch'),
      ],
    );
    files = FakeBackupFiles();
    provider = TransactionProvider(db: fake, clock: () => today);
    await provider.load();
    service = testBackupService(fake, files: files, clock: () => today);
  });

  Future<void> showBackup(WidgetTester tester) async {
    settings = await testSettings({}, () => today);
    await tester.pumpWidget(
      testApp(provider, settings, const BackupScreen(), backup: service),
    );
    await tester.pumpAndSettle();
  }

  /// A backup file from another device, in euros, holding only a dinner.
  Future<Uint8List> otherDeviceBackup() async {
    final other = FakeDB(
      transactions: [
        testTx('dinner', expense, 20, DateTime(2026, 9, 12), title: 'Dinner'),
      ],
    );
    final backup = await testBackupService(
      other,
      clock: () => DateTime(2026, 9, 1, 8),
    ).create(await testSettings({'currency_code': 'EUR'}));
    return utf8.encode(backup.toJson());
  }

  Future<void> openFile(WidgetTester tester) async {
    await tester.tap(find.text('Restore from a file'));
    await tester.pumpAndSettle();
  }

  Future<void> tapRestore(WidgetTester tester) async {
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
  }

  List<String?> titles() => [for (final t in provider.transactions) t.title];

  testWidgets('Back up now saves a file and shows when (BAK-1, BAK-7)', (
    tester,
  ) async {
    await showBackup(tester);
    expect(find.text('No backup yet'), findsOneWidget);

    await tester.tap(find.text('Back up now'));
    await tester.pumpAndSettle();

    expect(files.saved.keys, ['monthly-expenses-backup-2026-09-15.json']);
    expect(find.text('Backup saved'), findsOneWidget);
    expect(find.textContaining('Last backup Sep 15, 2026'), findsOneWidget);
  });

  testWidgets('a failed backup shows an error', (tester) async {
    files.fail = true;
    await showBackup(tester);

    await tester.tap(find.text('Back up now'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't save the backup. Try again."), findsOneWidget);
    expect(settings.lastBackupAt, isNull);
  });

  testWidgets('Merge adds the backup and keeps these settings (BAK-3)', (
    tester,
  ) async {
    files.toOpen = await otherDeviceBackup();
    await showBackup(tester);

    await openFile(tester);
    expect(find.text('Restore backup'), findsOneWidget);
    expect(find.textContaining('· 1 transaction'), findsOneWidget);
    await tapRestore(tester);

    expect(titles(), unorderedEquals(['Dinner', 'Lunch']));
    expect(settings.currencyCode, 'USD');
    // The five categories and Cash match; only the dinner is new.
    expect(
      find.text('Merged: 1 added, 0 updated, 6 unchanged'),
      findsOneWidget,
    );
    expect(files.kept, hasLength(1));
  });

  testWidgets('Replace uses the backup, and its automatic copy undoes it '
      '(BAK-2)', (tester) async {
    files.toOpen = await otherDeviceBackup();
    await showBackup(tester);

    await openFile(tester);
    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(
      find.text('Delete your data and use only the backup, with its settings.'),
      findsOneWidget,
    );
    await tapRestore(tester);

    expect(titles(), ['Dinner']);
    expect(settings.currencyCode, 'EUR');
    expect(find.text('Restored 1 transaction'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    expect(find.text('Restore this copy?'), findsOneWidget);
    await tapRestore(tester);

    expect(titles(), ['Lunch']);
    expect(settings.currencyCode, 'USD');
  });

  testWidgets(
    'a restore reschedules reminders with the real app lock, language, and '
    'nudge setting, not the load() defaults (LOCK-2, NOTE-6, NUDGE-8, '
    'NUDGE-9, pr59#6)',
    (tester) async {
      fake.notes.add(
        testNote(
          'note-1',
          'Pay Dr. X 300',
          dueDate: DateTime(2026, 9, 20),
          reminderAt: DateTime(2026, 9, 20, 9),
        ),
      );
      // Fixed, and before the note's reminder: otherwise, as real
      // wall-clock time moves past this fixture's date, the reminder looks
      // like one that already passed (NOTE-6) rather than the future one
      // this test means to keep scheduled.
      final reminders = FakeReminderService(now: () => today);
      provider = TransactionProvider(
        db: fake,
        clock: () => today,
        reminders: reminders,
      );
      // The real settings at launch: app lock on, empty-day nudge on.
      await provider.load(
        appLockOn: true,
        locale: const Locale('en'),
        nudge: const NudgeSettings(on: true, hour: 20, minute: 0),
      );
      expect(reminders.scheduled['note-1'], isTrue);
      expect(reminders.nudgesLocked, isTrue);

      files.toOpen = await otherDeviceBackup();
      settings = await testSettings({
        'app_lock': true,
        'empty_day_nudge': true,
      }, () => today);
      await tester.pumpWidget(
        testApp(provider, settings, const BackupScreen(), backup: service),
      );
      await tester.pumpAndSettle();

      await openFile(tester);
      await tapRestore(tester);

      // note-1 is still open after the merge; it should keep being
      // scheduled with the real, current app lock -- not the false/en/off
      // defaults `transactions.load()` falls back to when called with no
      // arguments.
      expect(
        reminders.scheduled['note-1'],
        isTrue,
        reason:
            'the note reminder body should still be hidden behind app '
            'lock after a restore',
      );
      expect(
        reminders.nudgesLocked,
        isTrue,
        reason: 'the empty-day nudge should still be worded for app lock on',
      );
    },
  );

  testWidgets('cancelling a restore changes nothing', (tester) async {
    files.toOpen = await otherDeviceBackup();
    await showBackup(tester);

    await openFile(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(titles(), ['Lunch']);
    expect(files.kept, isEmpty);
  });

  testWidgets('other files and newer backups are refused (BAK-4)', (
    tester,
  ) async {
    await showBackup(tester);

    files.toOpen = utf8.encode('hello');
    await openFile(tester);
    expect(
      find.text("This file isn't a Monthly Expenses backup."),
      findsOneWidget,
    );

    files.toOpen = utf8.encode(
      BackupData(
        schemaVersion: 99,
        createdAt: DateTime.utc(2026),
        tables: const {},
      ).toJson(),
    );
    await openFile(tester);
    expect(
      find.text(
        'This backup is from a newer version of the app. Update the app, '
        'then try again.',
      ),
      findsOneWidget,
    );
    expect(titles(), ['Lunch']);
  });

  testWidgets('failures to open or restore leave the data as it was', (
    tester,
  ) async {
    await showBackup(tester);

    files.fail = true;
    await openFile(tester);
    expect(find.text("Couldn't open the file. Try again."), findsOneWidget);

    files
      ..fail = false
      ..toOpen = await otherDeviceBackup();
    fake.failWrites = true;
    await openFile(tester);
    await tapRestore(tester);

    expect(
      find.text("Couldn't restore the backup. Your data wasn't changed."),
      findsOneWidget,
    );
    expect(titles(), ['Lunch']);
  });

  testWidgets('the backup reminder can be turned off (BAK-7)', (tester) async {
    await showBackup(tester);

    await tester.tap(find.text('Backup reminder'));
    await tester.pumpAndSettle();

    expect(settings.backupReminder, isFalse);
  });

  testWidgets('an automatic backup restores only after confirming', (
    tester,
  ) async {
    await service.keepCurrentData(await testSettings());
    fake.rows.clear();
    await provider.load();
    await showBackup(tester);

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(titles(), isEmpty);
    expect(files.kept, hasLength(1));
  });

  testWidgets('a restore is never a seam for the full-screen ad: someone '
      'putting their records back is not an audience (ADS-11, '
      'rules-22-25-31-35#11)', (tester) async {
    files.toOpen = await otherDeviceBackup();
    final earnedSettings = await testSettings({
      'setup_done': true,
      'walkthrough_seen': true,
      'first_opened_at': DateTime(2026, 1, 1).toUtc().toIso8601String(),
      'ad_activity': SettingsProvider.adActivityThreshold,
      'ad_activity_day': today.toUtc().toIso8601String(),
    }, () => today);
    final ads = FakeAdService(canStart: true, interstitialFills: true);

    await tester.pumpWidget(
      testApp(
        provider,
        earnedSettings,
        const BackupScreen(),
        backup: service,
        ads: ads,
      ),
    );
    await tester.pumpAndSettle();
    // In the app the SDK started long ago; here the provider is built on
    // its first read, so this is what a running app already has (ADS-4).
    Provider.of<AdsProvider>(
      tester.element(find.byType(BackupScreen)),
      listen: false,
    );
    await tester.pumpAndSettle();

    await openFile(tester);
    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    await tapRestore(tester);

    expect(titles(), ['Dinner']);
    expect(ads.interstitialsShown, 0);
  });
}
