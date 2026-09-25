import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/backup.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/transaction.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  final now = DateTime(2026, 9, 15, 10);
  late Directory dir;
  final opened = <DBHelper>[];

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    dir = Directory.systemTemp.createTempSync('backup_test');
  });

  tearDown(() async {
    for (final helper in opened) {
      await helper.close();
    }
    opened.clear();
    dir.deleteSync(recursive: true);
  });

  DBHelper helperAt(String file) {
    final helper = DBHelper(path: p.join(dir.path, file));
    opened.add(helper);
    return helper;
  }

  /// A Sep 1 expense, last saved on [updated] (Sep 1 by default).
  ExpenseTransaction tx(
    String id, {
    String? title,
    DateTime? updated,
    DateTime? deleted,
  }) => testTx(
    id,
    expense,
    10,
    DateTime(2026, 9),
    title: title,
  ).copyWith(updatedAt: updated ?? DateTime.utc(2026, 9), deletedAt: deleted);

  RecurringOccurrence posted(String transactionId, DateTime date) =>
      RecurringOccurrence(
        ruleId: 'rent',
        date: date,
        status: OccurrenceStatus.posted,
        transactionId: transactionId,
        createdAt: DateTime.utc(2026, 9),
      );

  Budget foodBudget() => Budget(
    id: 'food',
    categoryId: 'cat-food',
    limit: const Money(50000),
    effectiveFrom: DateTime(2026, 9),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  List<int> encode(BackupData backup) => utf8.encode(backup.toJson());

  Matcher refusedAs(BackupProblem problem) => throwsA(
    isA<BackupException>().having((e) => e.problem, 'problem', problem),
  );

  test(
    'Replace restores every table and the settings (BAK-1, BAK-2)',
    () async {
      final source = helperAt('source.db');
      await source.insertTransaction(tx('lunch', title: 'Lunch'));
      await source.insertTransaction(
        tx('old', deleted: DateTime.utc(2026, 9, 2)),
      );
      await source.insertAccount(testAccount('bank', opening: 100));
      await source.insertTransfer(
        testTransfer('move', Account.cashId, 'bank', 5, DateTime(2026, 9, 3)),
      );
      await source.insertCategory(
        Category(
          id: 'coffee',
          type: expense,
          name: 'Coffee',
          icon: '☕',
          sortOrder: 20,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      await source.insertBudget(foodBudget());
      await source.insertRecurringRule(
        testRule('rent', 900, DateTime(2026, 9)),
      );
      await source.postOccurrence(
        tx('rent-sep'),
        posted('rent-sep', DateTime(2026, 9)),
      );
      await source.insertNote(testNote('note-1', 'Pay the rent'));
      final backup = await testBackupService(source, clock: () => now).create(
        await testSettings({
          'currency_code': 'EUR',
          'month_start_day': 25,
          'week_start_day': 1,
        }),
      );

      final target = helperAt('target.db');
      await target.insertTransaction(tx('mine'));
      final service = testBackupService(target, clock: () => now);
      final settings = await testSettings();

      final read = await service.read(encode(backup));
      final result = await service.restore(read, RestoreMode.replace, settings);

      expect(
        (read.appVersion, read.schemaVersion),
        ('1.0.0+1', target.version),
      );
      expect(result.transactionCount, 2);
      expect(await target.exportTables(), await source.exportTables());
      expect(
        (settings.currencyCode, settings.startDay, settings.weekStartDay),
        ('EUR', 25, 1),
      );
      // The replaced data was kept first.
      final kept = await service.keptBackups();
      expect(kept.single.backup.tables['transactions']!.single['id'], 'mine');
    },
  );

  test('Merge adds new records and keeps the newer of each (BAK-3)', () async {
    final other = helperAt('other.db');
    for (final t in [
      tx('shared', title: 'There', updated: DateTime.utc(2026, 9, 5)),
      tx('newer-here', title: 'There', updated: DateTime.utc(2026, 9, 2)),
      tx(
        'gone',
        updated: DateTime.utc(2026, 9, 6),
        deleted: DateTime.utc(2026, 9, 6),
      ),
      tx('backup-only'),
    ]) {
      await other.insertTransaction(t);
    }
    final backup = await testBackupService(other)
        .create(await testSettings({'currency_code': 'EUR'}));

    final device = helperAt('device.db');
    for (final t in [
      tx('shared', title: 'Here'),
      tx('newer-here', title: 'Here', updated: DateTime.utc(2026, 9, 10)),
      tx('gone'),
      tx('local-only'),
    ]) {
      await device.insertTransaction(t);
    }
    final settings = await testSettings({'currency_code': 'GBP'});
    final service = testBackupService(device);

    final result = await service.restore(
      await service.read(encode(backup)),
      RestoreMode.merge,
      settings,
    );

    // Built-in categories and Cash match by ID and content, so they're
    // unchanged along with newer-here: 15 + 1 + 1.
    expect((result.added, result.updated, result.unchanged), (1, 2, 17));
    final byId = {
      for (final t in [
        ...await device.fetchTransactions(),
        ...await device.fetchDeletedTransactions(),
      ])
        t.id: t,
    };
    expect(byId['shared']!.title, 'There');
    expect(byId['newer-here']!.title, 'Here');
    expect(byId['gone']!.deletedAt, isNotNull);
    expect(byId.keys, containsAll(['local-only', 'backup-only']));
    expect(settings.currencyCode, 'GBP');
  });

  test('Merge treats notes like every other record (NOTE-8)', () async {
    final other = helperAt('other-notes.db');
    await other.insertNote(
      testNote('shared', 'There').copyWith(
        doneAt: DateTime.utc(2026, 9, 5),
        updatedAt: DateTime.utc(2026, 9, 5),
      ),
    );
    await other.insertNote(testNote('backup-only', 'New note'));
    final backup = await testBackupService(other).create(await testSettings());

    final device = helperAt('device-notes.db');
    await device.insertNote(
      testNote('shared', 'Here').copyWith(updatedAt: DateTime.utc(2026, 9, 1)),
    );
    await device.insertNote(testNote('local-only', 'Mine'));
    final service = testBackupService(device);

    await service.restore(
      await service.read(encode(backup)),
      RestoreMode.merge,
      await testSettings(),
    );

    final byId = {for (final n in await device.fetchNotes()) n.id: n};
    expect(byId['shared']!.doneAt, isNotNull);
    expect(byId.keys, containsAll(['local-only', 'backup-only']));
  });

  test('Merge never posts a recurring occurrence twice (RCR-4)', () async {
    final rule = testRule('rent', 900, DateTime(2026, 9));
    final other = helperAt('other.db');
    await other.insertRecurringRule(rule);
    await other.postOccurrence(
      tx('other-sep'),
      posted('other-sep', DateTime(2026, 9)),
    );
    await other.postOccurrence(
      tx('other-oct'),
      posted('other-oct', DateTime(2026, 10)),
    );
    final settings = await testSettings();
    final backup = await testBackupService(other).create(settings);

    final device = helperAt('device.db');
    await device.insertRecurringRule(rule);
    await device.postOccurrence(
      tx('device-sep'),
      posted('device-sep', DateTime(2026, 9)),
    );
    final service = testBackupService(device);

    await service.restore(
      await service.read(encode(backup)),
      RestoreMode.merge,
      settings,
    );

    expect([for (final t in await device.fetchTransactions()) t.id]..sort(), [
      'device-sep',
      'other-oct',
    ]);
    expect(
      {
        for (final o in await device.fetchOccurrences())
          o.date.month: o.transactionId,
      },
      {9: 'device-sep', 10: 'other-oct'},
    );
  });

  test('a backup from before colours comes back with them (CAT-6)', () async {
    final service = testBackupService(helperAt('app.db'));

    final restored = await service.read(
      encode(
        BackupData(
          // The schema as 1.21.0 wrote it: categories, but no colour column.
          schemaVersion: 9,
          createdAt: DateTime.utc(2026, 9),
          tables: {
            'categories': [
              Category(
                id: 'cat-coffee',
                type: expense,
                name: 'Coffee',
                icon: '☕',
                sortOrder: 0,
                createdAt: DateTime.utc(2026),
                updatedAt: DateTime.utc(2026),
              ).toMap()..remove('color'),
            ],
          },
        ),
      ),
    );

    final categories = restored.tables['categories']!;
    expect(categories, hasLength(1));
    // The user's own name and icon survive, and the step fills the colour in.
    expect(categories.single['name'], 'Coffee');
    expect(categories.single['icon'], '☕');
    expect(categories.single['color'], isNotNull);
  });

  test('a newer backup is refused; an older one is migrated (BAK-4)', () async {
    final service = testBackupService(helperAt('app.db'));
    final current = DBHelper().version;
    BackupData at(int version, BackupTables tables) => BackupData(
      schemaVersion: version,
      createdAt: DateTime.utc(2026, 9),
      tables: tables,
    );

    await expectLater(
      service.read(encode(at(current + 1, {}))),
      refusedAs(BackupProblem.tooNew),
    );

    // Version 6 had budgets but no recurring transactions yet.
    final migrated = await service.read(
      encode(
        at(6, {
          // A version 6 backup has no attachment columns (ATT-1).
          'transactions': [
            tx('lunch').toMap()
              ..remove('photo_file')
              ..remove('voice_file'),
          ],
          'budgets': [foodBudget().toMap()],
        }),
      ),
    );
    expect(migrated.schemaVersion, current);
    expect(migrated.transactionCount, 1);
    expect(migrated.tables['budgets'], hasLength(1));
    expect(migrated.tables['recurring_rules'], isEmpty);
    expect(migrated.tables['categories'], hasLength(15));

    await expectLater(
      service.read(
        encode(
          at(6, {
            'transactions': [
              {'id': 'broken'},
            ],
          }),
        ),
      ),
      refusedAs(BackupProblem.invalid),
    );
  });

  test('files that are not valid backups are refused', () async {
    final service = testBackupService(helperAt('app.db'));
    final valid = await service.create(await testSettings());
    BackupData withRows(String table, List<Map<String, Object?>> rows) =>
        valid.withTables({
          ...valid.tables,
          table: rows,
        }, schemaVersion: valid.schemaVersion);
    final lunch = tx('lunch').toMap();

    for (final bytes in [
      [0xff, 0xfe, 0x00],
      utf8.encode('[1, 2]'),
      utf8.encode('{"format": "something-else"}'),
      encode(withRows('accounts', [])),
      encode(
        withRows('transactions', [
          {'id': 'x'},
        ]),
      ),
      encode(withRows('transactions', [lunch, lunch])),
    ]) {
      await expectLater(service.read(bytes), refusedAs(BackupProblem.invalid));
    }
  });

  test('a failed replace leaves the data as it was', () async {
    final helper = helperAt('app.db');
    await helper.insertTransaction(tx('mine'));
    final lunch = tx('lunch').toMap();

    await expectLater(
      helper.replaceAllData({
        'transactions': [lunch, lunch],
      }),
      throwsA(isA<DatabaseException>()),
    );

    expect([for (final t in await helper.fetchTransactions()) t.id], ['mine']);
  });

  test('the device keeps the five newest automatic backups (BAK-2)', () async {
    var minutes = 0;
    final files = FakeBackupFiles();
    final service = testBackupService(
      helperAt('app.db'),
      files: files,
      clock: () => DateTime.utc(2026, 9).add(Duration(minutes: minutes++)),
    );
    final settings = await testSettings();

    for (var i = 0; i < 7; i++) {
      await service.keepCurrentData(settings);
    }
    files.kept['auto-99999999999999.json'] = 'not a backup';
    files.kept['notes.txt'] = 'not mine';

    final kept = await service.keptBackups();
    expect(
      files.kept.keys.where((name) => name.endsWith('.json')),
      hasLength(6),
    );
    expect(kept, hasLength(5));
    expect(
      kept.first.backup.createdAt.isAfter(kept.last.backup.createdAt),
      isTrue,
    );
  });

  test('a saved backup is recorded for the reminder (BAK-7)', () async {
    final files = FakeBackupFiles()..cancelSave = true;
    final service = testBackupService(
      helperAt('app.db'),
      files: files,
      clock: () => now,
    );
    final settings = await testSettings({}, () => now);

    expect(await service.saveBackup(settings), isFalse);
    expect(settings.lastBackupAt, isNull);

    files.cancelSave = false;
    expect(await service.saveBackup(settings), isTrue);
    expect(settings.lastBackupAt, now);
    expect(files.saved.keys, ['monthly-expenses-backup-2026-09-15.json']);

    expect(await service.openBackup(), isNull);
    files.toOpen = files.saved.values.single;
    expect((await service.openBackup())!.transactionCount, 0);
  });

  test('a picked file is read as text, whatever it was saved in '
      '(IMP-1)', () async {
    final files = FakeBackupFiles();
    final service = testBackupService(helperAt('app.db'), files: files);

    expect(await service.openText(), isNull);

    files.toOpen = utf8.encode('date,café\n');
    expect(await service.openText(), 'date,café\n');

    // The same line from a spreadsheet saved in the Windows code page: not
    // valid UTF-8, but everything that matters still reads.
    files.toOpen = Uint8List.fromList(latin1.encode('date,café\n'));
    expect(await service.openText(), 'date,café\n');
  });

  test('a CSV export is saved as UTF-8 with a byte order mark', () async {
    final files = FakeBackupFiles();
    final service = testBackupService(helperAt('app.db'), files: files);

    expect(await service.saveCsv('export.csv', '\uFEFFdate'), isTrue);

    expect(files.saved['export.csv']!.take(3), [0xef, 0xbb, 0xbf]);
  });

  test('a refusal names its problem', () {
    expect(
      const BackupException(BackupProblem.tooNew).toString(),
      'BackupException(tooNew)',
    );
  });

  group('Merge and the built-in defaults (BAK-3, REC-2, ACC-2)', () {
    // The defaults carry the install time, so a phone set up later has
    // "newer" untouched ones. An edit must still win, in either direction.
    final juneEdit = DateTime.utc(2026, 6, 15);

    Future<DBHelper> edited(String file) async {
      final db = helperAt(file);
      final cash = (await db.fetchAccounts()).firstWhere(
        (a) => a.id == Account.cashId,
      );
      await db.updateAccounts([
        cash.copyWith(
          name: 'Wallet',
          openingBalance: const Money(250000),
          updatedAt: juneEdit,
        ),
      ]);
      final food = (await db.fetchCategories()).firstWhere(
        (c) => c.id == 'cat-food',
      );
      await db.updateCategories([
        food.copyWith(name: 'Meals', updatedAt: juneEdit),
      ]);
      return db;
    }

    Future<void> mergeInto(DBHelper device, DBHelper from) async {
      final backup = await testBackupService(from).create(await testSettings());
      final service = testBackupService(device);
      await service.restore(
        await service.read(encode(backup)),
        RestoreMode.merge,
        await testSettings(),
      );
    }

    Future<(String?, Money, String?)> defaultsOf(DBHelper db) async {
      final cash = (await db.fetchAccounts()).firstWhere(
        (a) => a.id == Account.cashId,
      );
      final food = (await db.fetchCategories()).firstWhere(
        (c) => c.id == 'cat-food',
      );
      return (cash.name, cash.openingBalance, food.name);
    }

    test('a later phone\'s untouched defaults do not undo edits', () async {
      final old = await edited('old-phone.db');
      final fresh = helperAt('new-phone.db');

      await mergeInto(old, fresh);

      expect(await defaultsOf(old), ('Wallet', const Money(250000), 'Meals'));
    });

    test(
      'edits come across onto a later phone\'s untouched defaults',
      () async {
        final old = await edited('old-phone-2.db');
        final fresh = helperAt('new-phone-2.db');

        await mergeInto(fresh, old);

        expect(await defaultsOf(fresh), (
          'Wallet',
          const Money(250000),
          'Meals',
        ));
      },
    );
  });
}
