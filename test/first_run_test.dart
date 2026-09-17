import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/first_run_gate.dart';
import 'package:monthly_expense_app/screens/settings_screen.dart';
import 'package:monthly_expense_app/screens/walkthrough_screen.dart';
import 'package:monthly_expense_app/services/backup_service.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 16, 9);
  late FakeDB db;
  late FakeBackupFiles files;
  late TransactionProvider provider;
  late BackupService service;

  setUp(() async {
    db = FakeDB();
    files = FakeBackupFiles();
    provider = TransactionProvider(db: db, clock: () => today);
    await provider.load();
    service = testBackupService(db, files: files, clock: () => today);
  });

  /// Opens the app as [SettingsProvider] finds it, on the widget the first
  /// launch decides between.
  Future<void> start(WidgetTester tester, SettingsProvider settings) async {
    tester.view.physicalSize = const Size(600, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(provider, settings, const FirstRunGate(), backup: service),
    );
    await tester.pumpAndSettle();
  }

  /// The same shared_preferences store read again, as a relaunch would.
  Future<SettingsProvider> relaunch(WidgetTester tester) async {
    // The provider saves without awaiting; let those writes land first.
    await tester.pump();
    return SettingsProvider(
      await SharedPreferences.getInstance(),
      deviceLocale: 'en_US',
      clock: () => today,
    );
  }

  /// A backup from another phone: one dinner, in euros.
  Future<Uint8List> otherPhoneBackup() async {
    final other = FakeDB(
      transactions: [
        testTx(
          'dinner',
          TransactionType.expense,
          20,
          DateTime(2026, 9, 12),
          title: 'Dinner',
        ),
      ],
    );
    final backup = await testBackupService(
      other,
      clock: () => DateTime(2026, 9, 1, 8),
    ).create(await testSettings({'currency_code': 'EUR'}));
    return utf8.encode(backup.toJson());
  }

  group('what a launch opens (RUN-5)', () {
    testWidgets('a fresh install starts at setup (RUN-3)', (tester) async {
      await start(tester, await testSettings({}, () => today));

      expect(find.text('Continue'), findsOne);
      expect(find.text('Add your first transaction'), findsNothing);
    });

    testWidgets('setup comes back until it is finished', (tester) async {
      final settings = await testSettings({}, () => today);
      await start(tester, settings);
      expect(settings.setupDone, isFalse);

      // Closed on the setup page, opened again.
      final second = await relaunch(tester);

      expect(second.setupDone, isFalse);
      expect(second.walkthroughSeen, isFalse);
    });

    testWidgets('an update on a phone that has used the app opens Home', (
      tester,
    ) async {
      final settings = await testSettings({
        'first_opened_at': '2026-01-04T08:00:00.000Z',
        'currency_code': 'EUR',
      }, () => today);

      await start(tester, settings);

      expect(settings.setupDone, isTrue);
      expect(settings.walkthroughSeen, isTrue);
      expect(settings.currencyCode, 'EUR');
      expect(find.text('Add your first transaction'), findsOne);
    });

    testWidgets('the walkthrough runs once, even when it is skipped', (
      tester,
    ) async {
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Add in seconds'), findsOne);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Add your first transaction'), findsOne);
      expect(settings.walkthroughSeen, isTrue);
      expect((await relaunch(tester)).walkthroughSeen, isTrue);
    });
  });

  group('setup (RUN-3)', () {
    testWidgets('the language and the currency come from the device', (
      tester,
    ) async {
      await start(tester, await testSettings({}, () => today));

      expect(find.text('English'), findsOne);
      expect(find.text('USD · US Dollar'), findsOne);
      // Nothing else is asked for.
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('picking a language switches the page at once (LANG-1)', (
      tester,
    ) async {
      await start(tester, await testSettings({}, () => today));

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Türkçe'));
      await tester.pumpAndSettle();

      expect(find.text('Devam'), findsOne);
    });

    testWidgets('the currency can be changed here (CUR-1)', (tester) async {
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('USD · US Dollar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'euro');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Euro'));
      await tester.pumpAndSettle();

      expect(settings.currencyCode, 'EUR');
      expect(find.text('EUR · Euro'), findsOne);
    });

    testWidgets('Continue finishes setup and hands over to the walkthrough', (
      tester,
    ) async {
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(settings.setupDone, isTrue);
      expect((await relaunch(tester)).setupDone, isTrue);
      expect(find.text('Add in seconds'), findsOne);
    });

    testWidgets('a restored backup brings its settings and skips the '
        'walkthrough (BAK-2)', (tester) async {
      files.toOpen = await otherPhoneBackup();
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('Restore a backup'));
      await tester.pumpAndSettle();

      expect(find.text('Dinner'), findsOne);
      expect(settings.currencyCode, 'EUR');
      expect(settings.setupDone, isTrue);
      expect(settings.walkthroughSeen, isTrue);
    });

    testWidgets('a backup that will not open says so, and setup stays', (
      tester,
    ) async {
      files.fail = true;
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('Restore a backup'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't open the file. Try again."), findsOne);
      expect(find.text('Continue'), findsOne);
      expect(settings.setupDone, isFalse);
    });

    testWidgets('a file that is not a backup says so (BAK-2)', (tester) async {
      files.toOpen = utf8.encode('a shopping list, not a backup');
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('Restore a backup'));
      await tester.pumpAndSettle();

      expect(find.text("This file isn't a Monthly Expenses backup."), findsOne);
      expect(settings.setupDone, isFalse);
    });

    testWidgets('a restore that fails leaves setup as it was', (tester) async {
      files.toOpen = await otherPhoneBackup();
      db.failWrites = true;
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('Restore a backup'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't restore the backup. Your data wasn't changed."),
        findsOne,
      );
      expect(settings.setupDone, isFalse);
      expect(find.text('Continue'), findsOne);
    });

    testWidgets('an imported CSV finishes setup, and the walkthrough still '
        'follows (IMP-1)', (tester) async {
      files.toOpen = utf8.encode(
        'date,amount,type,title\n2026-09-14,12.50,expense,Coffee\n',
      );
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('Import a CSV'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a file'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import 1 row'));
      await tester.pumpAndSettle();

      expect(provider.transactions, hasLength(1));
      expect(settings.setupDone, isTrue);
      expect(find.text('Add in seconds'), findsOne);
    });

    testWidgets('leaving the import empty-handed keeps setup', (tester) async {
      final settings = await testSettings({}, () => today);
      await start(tester, settings);

      await tester.tap(find.text('Import a CSV'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(settings.setupDone, isFalse);
      expect(find.text('Continue'), findsOne);
    });
  });

  group('walkthrough (RUN-4)', () {
    /// Settings past setup, with the walkthrough still to come.
    Future<SettingsProvider> afterSetup() =>
        testSettings({'setup_done': true}, () => today);

    testWidgets('four pages, and the last one opens Home', (tester) async {
      final settings = await afterSetup();
      await start(tester, settings);

      for (final title in [
        'Add in seconds',
        'Plan the month',
        'See where it goes',
      ]) {
        expect(find.text(title), findsOne);
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Yours alone'), findsOne);

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(find.text('Add your first transaction'), findsOne);
      expect(settings.walkthroughSeen, isTrue);
    });

    testWidgets('the dots say which page is on screen', (tester) async {
      final semantics = tester.ensureSemantics();
      await start(tester, await afterSetup());

      expect(find.bySemanticsLabel('Page 1 of 4'), findsOne);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Page 2 of 4'), findsOne);

      semantics.dispose();
    });

    testWidgets('a phone asking for less movement gets no animation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testApp(
          provider,
          await afterSetup(),
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: const WalkthroughScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      // One frame: an animated page would still be on its way.
      await tester.pump();

      expect(find.text('Plan the month'), findsOne);
    });

    testWidgets('Settings plays it again and closes back (RUN-5)', (
      tester,
    ) async {
      final settings = await testSettings({
        'first_opened_at': '2026-01-04T08:00:00.000Z',
      }, () => today);
      tester.view.physicalSize = const Size(600, 4000);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        testApp(provider, settings, const SettingsScreen(), backup: service),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Replay the walkthrough'));
      await tester.pumpAndSettle();
      expect(find.text('Add in seconds'), findsOne);

      // The last page finishes rather than starting anything.
      for (var page = 1; page < 4; page++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Get started'), findsNothing);
      expect(find.text('Done'), findsNWidgets(2));

      await tester.tap(find.text('Done').first);
      await tester.pumpAndSettle();

      expect(find.text('Replay the walkthrough'), findsOne);
      expect(settings.walkthroughSeen, isTrue);
    });
  });
}
