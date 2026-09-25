import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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
import 'package:monthly_expense_app/services/backup_service.dart';

import 'helpers.dart';

/// Replaces every non-overlapping occurrence of [from] in [bytes] with [to]
/// (same length, so no offset in the surrounding zip structure moves).
/// Stands in for a zip tool, unlike this app's own [ZipEncoder], that writes
/// a `\`-containing entry name byte for byte instead of rewriting it to `/`.
List<int> _spliceBytes(List<int> bytes, List<int> from, List<int> to) {
  assert(from.length == to.length);
  final out = List<int>.from(bytes);
  var hits = 0;
  for (var i = 0; i + from.length <= out.length; i++) {
    if (!from.indexed.every((e) => out[i + e.$1] == e.$2)) continue;
    out.setRange(i, i + to.length, to);
    hits++;
    i += from.length - 1;
  }
  expect(
    hits,
    2,
    reason:
        'expected the sentinel name in exactly the local and '
        'central-directory zip headers',
  );
  return out;
}

/// An [AttachmentService] whose writes always fail, like a full disk mid a
/// zip restore (ATT-6).
class _ThrowingAttachments extends FakeAttachments {
  @override
  Future<void> write(String name, List<int> bytes) async {
    throw Exception('disk full');
  }
}

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

  test('a purged deletion does not come back on merge (DEL-1, DEL-3, BAK-3, '
      'rules-1-5#7)', () async {
    // An older backup (a second phone, or an automatic backup made before
    // the deletion) still holds the live transaction.
    final other = helperAt('other-purge.db');
    await other.insertTransaction(tx('rent', title: 'Rent'));
    final backup = await testBackupService(other).create(await testSettings());

    final device = helperAt('device-purge.db');
    await device.insertTransaction(
      tx('rent', title: 'Rent', deleted: DateTime.utc(2026, 7, 1)),
    );
    // DEL-3: purged after 30 days in the trash, as load() does on start.
    await device.purgeDeletedBefore(DateTime.utc(2026, 8, 1));

    final service = testBackupService(device);
    await service.restore(
      await service.read(encode(backup)),
      RestoreMode.merge,
      await testSettings(),
    );

    // The purged deletion must win over the older backup, not come back
    // as a live transaction.
    expect(await device.fetchTransactions(), isEmpty);
  });

  test('an edit truly made after a purged deletion still wins the merge '
      '(DEL-3, BAK-3, rules-1-5#7)', () async {
    // A second phone edited this record after the deletion happened here,
    // and its backup is newer than the tombstone this device later purged.
    final other = helperAt('other-purge-edit.db');
    await other.insertTransaction(
      tx('rent', title: 'Rent', updated: DateTime.utc(2026, 9, 20)),
    );
    final backup = await testBackupService(other).create(await testSettings());

    final device = helperAt('device-purge-edit.db');
    await device.insertTransaction(
      tx('rent', title: 'Rent', deleted: DateTime.utc(2026, 7, 1)),
    );
    await device.purgeDeletedBefore(DateTime.utc(2026, 8, 1));

    final service = testBackupService(device);
    await service.restore(
      await service.read(encode(backup)),
      RestoreMode.merge,
      await testSettings(),
    );

    // The backup's edit came after the tombstone's own timestamp, so it is
    // not lost just because the tombstone has since been purged.
    expect((await device.fetchTransactions()).single.title, 'Rent');
  });

  test('a purged transfer and a purged note also do not come back on '
      'merge (DEL-3, BAK-3, rules-1-5#7)', () async {
    final other = helperAt('other-purge-more.db');
    await other.insertTransfer(
      testTransfer(
        'move',
        Account.cashId,
        'bank',
        5,
        DateTime(2026, 9, 3),
      ).copyWith(updatedAt: DateTime.utc(2026, 9)),
    );
    await other.insertNote(
      testNote(
        'rent-note',
        'Pay rent',
      ).copyWith(updatedAt: DateTime.utc(2026, 9)),
    );
    final backup = await testBackupService(other).create(await testSettings());

    final device = helperAt('device-purge-more.db');
    await device.insertTransfer(
      testTransfer(
        'move',
        Account.cashId,
        'bank',
        5,
        DateTime(2026, 9, 3),
      ).copyWith(
        updatedAt: DateTime.utc(2026, 9),
        deletedAt: DateTime.utc(2026, 7, 1),
      ),
    );
    await device.insertNote(
      testNote('rent-note', 'Pay rent').copyWith(
        updatedAt: DateTime.utc(2026, 9),
        deletedAt: DateTime.utc(2026, 7, 1),
      ),
    );
    await device.purgeDeletedBefore(DateTime.utc(2026, 8, 1));

    final service = testBackupService(device);
    await service.restore(
      await service.read(encode(backup)),
      RestoreMode.merge,
      await testSettings(),
    );

    expect(await device.fetchTransfers(), isEmpty);
    expect(await device.fetchNotes(), isEmpty);
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

  test('a file without the backup marker, or at schema 0, is refused as '
      'invalid (BAK-1, BAK-4)', () async {
    final service = testBackupService(helperAt('app.db'));
    final valid = jsonDecode(
      (await service.create(await testSettings())).toJson(),
    ) as Map<String, Object?>;

    for (final file in [
      {...valid, 'format': 'another-app-export'},
      // No tables, so nothing but the version itself can refuse it.
      {...valid, 'schemaVersion': 0, 'tables': <String, Object?>{}},
    ]) {
      await expectLater(
        service.read(utf8.encode(jsonEncode(file))),
        refusedAs(BackupProblem.invalid),
      );
    }
  });

  test('a record holding a list or an object is refused (BAK-1)', () async {
    final service = testBackupService(helperAt('app.db'));
    final valid = await service.create(await testSettings());

    final nested = valid.withTables({
      ...valid.tables,
      'transactions': [
        {
          ...tx('lunch').toMap(),
          'extra': {'x': 1},
        },
      ],
    }, schemaVersion: valid.schemaVersion);

    await expectLater(
      service.read(encode(nested)),
      refusedAs(BackupProblem.invalid),
    );
  });

  test('a backup whose accounts are all deleted is refused', () async {
    final service = testBackupService(helperAt('app.db'));
    final valid = await service.create(await testSettings());

    final noAccount = valid.withTables({
      ...valid.tables,
      'accounts': [
        for (final row in valid.tables['accounts']!)
          {...row, 'deleted_at': DateTime.utc(2026, 9, 2).toIso8601String()},
      ],
    }, schemaVersion: valid.schemaVersion);

    await expectLater(
      service.read(encode(noAccount)),
      refusedAs(BackupProblem.invalid),
    );
  });

  test('Merge updates a record only when the backup is newer and differs '
      '(BAK-3)', () {
    MergePlan merge(ExpenseTransaction mine, ExpenseTransaction theirs) =>
        planMerge(
          {
            'transactions': [mine.toMap()],
          },
          {
            'transactions': [theirs.toMap()],
          },
        );
    final sep5 = DateTime.utc(2026, 9, 5);

    // Saved at the same moment: neither is later, so this device keeps its own.
    final tie = merge(
      tx('shared', title: 'Here', updated: sep5),
      tx('shared', title: 'There', updated: sep5),
    );
    // Newer, but only the timestamps differ.
    final sameContent = merge(
      tx('shared', title: 'Lunch'),
      tx('shared', title: 'Lunch', updated: sep5),
    );

    for (final plan in [tie, sameContent]) {
      expect((plan.added, plan.updated, plan.unchanged), (0, 0, 1));
    }
  });

  test('Merge counts an occurrence handled on both sides, and the '
      'transaction it leaves out, as unchanged (BAK-3, RCR-4)', () {
    final sep = DateTime(2026, 9);

    final plan = planMerge(
      {
        'recurring_occurrences': [posted('device-sep', sep).toMap()],
        'transactions': [tx('device-sep').toMap()],
      },
      {
        'recurring_occurrences': [posted('other-sep', sep).toMap()],
        'transactions': [tx('other-sep').toMap()],
      },
    );

    expect((plan.added, plan.updated, plan.unchanged), (0, 0, 2));
  });

  test('a malicious photo_file/voice_file in a backup is dropped, never '
      'trusted as a path (ATT-2, data-integrity#10)', () async {
    final service = testBackupService(helperAt('sanitize.db'));
    final valid = await service.create(await testSettings());
    final malicious = tx('lunch').toMap()
      ..['photo_file'] = '../../databases/monthly_expense_app.db'
      ..['voice_file'] = 'sub\\evil.m4a';

    final read = await service.read(
      encode(
        valid.withTables({
          ...valid.tables,
          'transactions': [malicious],
        }, schemaVersion: valid.schemaVersion),
      ),
    );

    final restored = read.tables['transactions']!.single;
    expect(restored['photo_file'], isNull);
    expect(restored['voice_file'], isNull);
  });

  test('a malicious attachment name in a zip backup cannot escape the '
      'attachments folder (ATT-2, data-integrity#10)', () async {
    // Two levels down from dir, so the malicious name's two `..` segments
    // land back on dir itself rather than on dir's parent (the system temp
    // folder, which the test has no business asserting on).
    final attachmentsDir = Directory(
      p.join(dir.path, 'appdata', 'attachments'),
    );
    final attachments = testAttachments(attachmentsDir).service;
    final target = helperAt('zip-slip.db');
    final backupService = testBackupService(target, attachments: attachments);
    final settings = await testSettings();
    final validJson = (await backupService.create(settings)).toJson();

    // A crafted zip: a legitimate backup.json plus one attachment entry
    // whose name climbs out of the attachments folder with backslashes,
    // which `file.name.split('/').last` alone would not strip (it only
    // splits on '/'). Built with a same-length placeholder and spliced to
    // the real name so this app's own ZipEncoder (which rewrites '\' to
    // '/' on encode) never gets the chance to "fix" it, matching a zip
    // written by some other tool.
    const sentinelSuffix = 'XXXXXXXXXXXXXX';
    const maliciousSuffix = '..\\..\\evil.txt';
    expect(sentinelSuffix.length, maliciousSuffix.length);

    final archive = Archive()
      ..add(ArchiveFile.string(BackupService.backupEntry, validJson))
      ..add(
        ArchiveFile.bytes(
          '${BackupService.attachmentsEntry}/$sentinelSuffix',
          utf8.encode('planted by a malicious backup'),
        ),
      );
    final zipBytes = _spliceBytes(
      ZipEncoder().encodeBytes(archive),
      utf8.encode('${BackupService.attachmentsEntry}/$sentinelSuffix'),
      utf8.encode('${BackupService.attachmentsEntry}/$maliciousSuffix'),
    );

    final backup = await backupService.read(zipBytes);
    // The unsafe name never survives into BackupData.files.
    expect(backup.files.keys, isNot(contains('..\\..\\evil.txt')));

    await backupService.restore(backup, RestoreMode.replace, settings);

    // dir/appdata/attachments/..\..\evil.txt would resolve to dir/evil.txt:
    // two levels above the attachments folder the app is supposed to be
    // confined to.
    final escaped = File(p.join(dir.path, 'evil.txt'));
    expect(escaped.existsSync(), isFalse);
  });

  test('a Replace restore whose file write fails should not have already '
      'committed the database (BAK-2, ATT-6, data-integrity#8)', () async {
    final device = helperAt('restore-write-fail.db');
    await device.insertTransaction(tx('mine', title: 'Mine'));

    final other = helperAt('other-write-fail.db');
    await other.insertTransaction(tx('dinner', title: 'Dinner'));
    final settings = await testSettings();
    // The incoming backup carries an attachment, so `_writeFiles` has
    // something to write, and fail on.
    final backup = (await testBackupService(other).create(settings)).withFiles({
      'photo1.jpg': const [9],
    });

    final service = testBackupService(
      device,
      attachments: _ThrowingAttachments(),
    );

    await expectLater(
      service.restore(backup, RestoreMode.replace, settings),
      throwsException,
    );

    // The database should not hold the backup's data when writing its
    // files failed partway through: nothing should be committed yet.
    expect([for (final t in await device.fetchTransactions()) t.id], ['mine']);
  });

  test(
    'a Merge restore whose file write fails should not have already '
    'committed the database (BAK-2, ATT-6, data-integrity#8, review-data-5)',
    () async {
      final device = helperAt('merge-write-fail.db');
      await device.insertTransaction(tx('mine', title: 'Mine'));

      final other = helperAt('other-merge-write-fail.db');
      // Only in the backup, so Merge inserts it and its file must be
      // written.
      await other.insertTransaction(
        tx('dinner', title: 'Dinner').copyWith(photoFile: 'photo1.jpg'),
      );
      final settings = await testSettings();
      final backup = (await testBackupService(other).create(settings))
          .withFiles({
            'photo1.jpg': const [9],
          });

      final service = testBackupService(
        device,
        attachments: _ThrowingAttachments(),
      );

      await expectLater(
        service.restore(backup, RestoreMode.merge, settings),
        throwsException,
      );

      // Files are written before the merge is applied to the database
      // (review-data-5): reverting that order would let this pass with the
      // merge already committed despite the failed file write.
      expect(
        [for (final t in await device.fetchTransactions()) t.id],
        ['mine'],
      );
    },
  );

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
