import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/db/migrations.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  late Directory dir;
  final opened = <DBHelper>[];

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    dir = Directory.systemTemp.createTempSync('db_helper_test');
  });

  tearDown(() async {
    for (final helper in opened) {
      await helper.close();
    }
    opened.clear();
    dir.deleteSync(recursive: true);
  });

  /// A helper for [file] in the temp directory, using the app's schema steps
  /// unless [steps] is given.
  DBHelper helperAt(String file, [List<Migration>? steps]) {
    final helper = DBHelper(path: p.join(dir.path, file), migrations: steps);
    opened.add(helper);
    return helper;
  }

  Future<List<String>> columns(DBHelper helper, String table) async {
    final db = await helper.database;
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return [for (final row in rows) row['name']! as String];
  }

  group('migration scaffold', () {
    Future<void> addTags(DatabaseExecutor db) =>
        db.execute('CREATE TABLE tags (id TEXT PRIMARY KEY)');
    Future<void> addLabels(DatabaseExecutor db) =>
        db.execute('CREATE TABLE labels (id TEXT PRIMARY KEY)');

    test('version is 1 plus the number of steps', () {
      expect(DBHelper(migrations: []).version, 1);
      expect(DBHelper(migrations: [addTags, addLabels]).version, 3);
      expect(DBHelper().version, DBHelper.schemaMigrations.length + 1);
    });

    test(
      'upgrading from an intermediate version runs only newer steps',
      () async {
        final v2 = helperAt('app.db', [addTags]);
        await v2.database;
        await v2.close();

        // Re-running addTags would fail because the table already exists.
        final v3 = helperAt('app.db', [addTags, addLabels]);

        expect(await (await v3.database).getVersion(), 3);
        expect(await columns(v3, 'labels'), ['id']);
      },
    );

    test('a build with fewer migration steps refuses to open a database a '
        'newer build already upgraded, and never lowers its schema version '
        '(data-integrity#9)', () async {
      final current = DBHelper().version;
      final newer = helperAt('app.db');
      await newer.database;
      await newer.close();

      // An older build (fewer migration steps) opens the same file, as
      // TestFlight, `adb install -d`, or a desktop installer downgrade
      // allow. It must refuse rather than silently lower `user_version`.
      final older = helperAt(
        'app.db',
        DBHelper.schemaMigrations.sublist(
          0,
          DBHelper.schemaMigrations.length - 1,
        ),
      );
      await expectLater(older.database, throwsA(isA<StateError>()));
      await older.close();

      // The newer build is installed again: it must still open cleanly,
      // proving `user_version` was left as it was rather than lowered.
      final newerAgain = helperAt('app.db');
      expect(await (await newerAgain.database).getVersion(), current);
    });
  });

  group('app schema', () {
    test('upgrading version 1 data converts every row', () async {
      final v1 = helperAt('app.db', []);
      final raw = await v1.database;
      for (final row in [
        {
          'id': 'a',
          'title': 'Lunch',
          'amount': 19.99,
          'category': 'Food',
          'type': 'expense',
          'date': '2026-09-13T12:00:00.000',
          'note': 'with team',
        },
        {
          'id': 'b',
          'title': ' ',
          'amount': 500.0,
          'category': 'Freelance',
          'type': 'income',
          'date': '2026-09-01T00:00:00.000',
          'note': null,
        },
        {
          'id': 'c',
          'title': 'Coffee',
          'amount': 3.5,
          'category': 'Coffee',
          'type': 'expense',
          'date': '2026-09-02T08:30:00.000',
          'note': null,
        },
      ]) {
        await raw.insert('transactions', row);
      }
      await v1.close();

      final current = helperAt('app.db');
      final byId = {for (final t in await current.fetchTransactions()) t.id: t};

      expect(await (await current.database).getVersion(), current.version);
      expect(byId['a']!.amount, const Money(19990));
      expect(byId['a']!.categoryId, 'cat-food');
      expect(byId['a']!.note, 'with team');
      expect(byId['b']!.title, isNull);
      expect(byId['b']!.categoryId, 'cat-business');
      expect(byId['c']!.amount, const Money(3500));
      expect(byId['c']!.categoryId, 'cat-other');
      expect({for (final t in byId.values) t.accountId}, {Account.cashId});
    });

    test('upgrading version 1 rounds fractional cents instead of truncating '
        '(MONEY-1)', () async {
      // $2.01 as a double is 2.0099999999999998, so multiplying by 1000
      // and truncating (rather than rounding) loses a thousandth.
      final v1 = helperAt('app.db', []);
      final raw = await v1.database;
      await raw.insert('transactions', {
        'id': 'a',
        'title': 'Toll',
        'amount': 2.01,
        'category': 'Transport',
        'type': 'expense',
        'date': '2026-09-13T12:00:00.000',
        'note': null,
      });
      await v1.close();

      final current = helperAt('app.db');
      final stored = (await current.fetchTransactions()).single;

      expect(stored.amount, const Money(2010));
    });

    test(
      'a fresh install has the defaults and matches an upgraded install',
      () async {
        final old = helperAt('upgraded.db', []);
        await old.database;
        await old.close();
        final upgraded = helperAt('upgraded.db');
        final fresh = helperAt('fresh.db');

        final categories = await fresh.fetchCategories();
        expect(categories.where((c) => c.type == expense), hasLength(10));
        expect(
          categories.where((c) => c.type == TransactionType.income),
          hasLength(5),
        );
        expect((await fresh.fetchAccounts()).single.id, Account.cashId);
        expect(await fresh.fetchTransfers(), isEmpty);
        for (final table in [
          'transactions',
          'categories',
          'accounts',
          'transfers',
          'budgets',
          'recurring_rules',
          'recurring_occurrences',
          'notes',
        ]) {
          expect(await columns(fresh, table), await columns(upgraded, table));
        }
      },
    );

    test(
      "the built-in Cash account's opening date has no time of day (ACC-2)",
      () async {
        // Every other account is opened at midnight (see
        // account_edit_screen's default), and code elsewhere compares
        // openingDate directly against period boundaries, so Cash must match.
        final fresh = helperAt('fresh.db');

        final cash = (await fresh.fetchAccounts()).single;

        expect(
          cash.openingDate,
          DateTime(
            cash.openingDate.year,
            cash.openingDate.month,
            cash.openingDate.day,
          ),
        );
      },
    );

    test('soft-deleted rows move from the list to the trash', () async {
      final helper = helperAt('app.db');
      final lunch = testTx('a', expense, 12.5, DateTime(2026, 9, 13));
      await helper.insertTransaction(lunch);
      await helper.insertTransaction(
        testTx('b', expense, 3, DateTime(2026, 9, 12)),
      );
      await helper.updateTransaction(
        lunch.copyWith(deletedAt: DateTime.utc(2026, 9, 14)),
      );

      expect([for (final t in await helper.fetchTransactions()) t.id], ['b']);
      expect(
        [for (final t in await helper.fetchDeletedTransactions()) t.id],
        ['a'],
      );
    });

    test('inserting a transaction again replaces it, not fails', () async {
      // insertTransaction deliberately uses ConflictAlgorithm.replace, so an
      // id that already exists is an upsert rather than a thrown exception.
      final helper = helperAt('app.db');
      final original = testTx('dup', expense, 5, DateTime(2026, 9, 1));
      await helper.insertTransaction(original);

      await helper.insertTransaction(
        original.copyWith(title: 'Replaced', amount: const Money(9000)),
      );

      final stored = (await helper.fetchTransactions()).single;
      expect(stored.id, 'dup');
      expect(stored.title, 'Replaced');
      expect(stored.amount, const Money(9000));
    });

    test('purgeDeletedBefore removes only older trash (DEL-3)', () async {
      final helper = helperAt('app.db');
      await helper.insertTransaction(
        testTx('active', expense, 1, DateTime(2026, 9, 1)),
      );
      await helper.insertTransaction(
        testTx(
          'old',
          expense,
          1,
          DateTime(2026, 7, 1),
        ).copyWith(deletedAt: DateTime.utc(2026, 8, 1)),
      );
      await helper.insertTransaction(
        testTx(
          'recent',
          expense,
          1,
          DateTime(2026, 9, 1),
        ).copyWith(deletedAt: DateTime.utc(2026, 9, 10)),
      );
      await helper.insertTransfer(
        testTransfer(
          'old-transfer',
          Account.cashId,
          'bank',
          1,
          DateTime(2026, 7, 1),
        ).copyWith(deletedAt: DateTime.utc(2026, 8, 1)),
      );

      await helper.purgeDeletedBefore(DateTime.utc(2026, 9));

      expect(
        [for (final t in await helper.fetchDeletedTransactions()) t.id],
        ['recent'],
      );
      expect(
        [for (final t in await helper.fetchTransactions()) t.id],
        ['active'],
      );
      expect(await (await helper.database).query('transfers'), isEmpty);
    });

    test(
      'purgeDeletedBefore keeps a row deleted exactly at the cutoff (DEL-3)',
      () async {
        // DEL-3: 30 days in the trash, so a row deleted at the exact moment
        // of the cutoff has not yet finished its 30 days and must survive.
        final helper = helperAt('app.db');
        final cutoff = DateTime.utc(2026, 9, 10);
        await helper.insertTransaction(
          testTx(
            'on-cutoff',
            expense,
            1,
            DateTime(2026, 8, 10),
          ).copyWith(deletedAt: cutoff),
        );

        await helper.purgeDeletedBefore(cutoff);

        expect(
          [for (final t in await helper.fetchDeletedTransactions()) t.id],
          ['on-cutoff'],
        );
      },
    );

    test('purging the same id twice keeps the LATEST tombstone, not the first '
        '(BAK-3, review-data-1)', () async {
      final helper = helperAt('app.db');
      // Deleted and purged once already: the tombstone from this purge is
      // stale by the time it is challenged again below.
      await helper.insertTransaction(
        testTx('x', expense, 1, DateTime(2026, 6, 1)).copyWith(
          updatedAt: DateTime.utc(2026, 7, 1),
          deletedAt: DateTime.utc(2026, 7, 1),
        ),
      );
      await helper.purgeDeletedBefore(DateTime.utc(2026, 8, 1));
      expect(
        (await helper.fetchPurgedIds())['x'],
        DateTime.utc(2026, 7, 1).toIso8601String(),
      );

      // A merge brought it back with a later edit (Sep 20 beats the Jul 1
      // tombstone, per rules-1-5#7): not deleted.
      await helper.insertTransaction(
        testTx(
          'x',
          expense,
          1,
          DateTime(2026, 9, 20),
        ).copyWith(updatedAt: DateTime.utc(2026, 9, 20)),
      );
      // The user deletes it again on Oct 1 (updated_at Oct 1).
      await helper.insertTransaction(
        testTx('x', expense, 1, DateTime(2026, 9, 20)).copyWith(
          updatedAt: DateTime.utc(2026, 10, 1),
          deletedAt: DateTime.utc(2026, 10, 1),
        ),
      );
      await helper.purgeDeletedBefore(DateTime.utc(2026, 11, 1));

      // The tombstone must now be Oct 1, the LATEST updated_at purged for
      // this id — not the stale Jul 1 from the first purge. Otherwise a
      // later merge of a backup whose edit for 'x' falls between the two
      // deletions (after Jul 1 but before Oct 1, e.g. Sep 20) would pass
      // the tombstone check and bring 'x' back a second time.
      expect(
        (await helper.fetchPurgedIds())['x'],
        DateTime.utc(2026, 10, 1).toIso8601String(),
      );
    });

    test('categories can be added and updated', () async {
      final helper = helperAt('app.db');
      final coffee = Category(
        id: 'c1',
        type: expense,
        name: 'Coffee',
        icon: '☕',
        sortOrder: 10,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );

      await helper.insertCategory(coffee);
      await helper.updateCategories([
        coffee.copyWith(name: 'Café', archivedAt: DateTime.utc(2026, 9)),
      ]);

      final saved = (await helper.fetchCategories()).firstWhere(
        (c) => c.id == 'c1',
      );
      expect(saved.name, 'Café');
      expect(saved.archivedAt, DateTime.utc(2026, 9));
    });

    test('accounts can be added and updated', () async {
      final helper = helperAt('app.db');
      final bank = testAccount('bank', opening: 250);

      await helper.insertAccount(bank);
      await helper.updateAccounts([
        bank.copyWith(name: 'Savings', archivedAt: DateTime.utc(2026, 9)),
      ]);

      final saved = (await helper.fetchAccounts()).firstWhere(
        (a) => a.id == 'bank',
      );
      expect(
        (saved.name, saved.openingBalance, saved.archivedAt),
        ('Savings', const Money(250000), DateTime.utc(2026, 9)),
      );
    });

    test('transfers are saved, updated, and skipped once deleted', () async {
      final helper = helperAt('app.db');
      final transfer = testTransfer(
        't',
        Account.cashId,
        'bank',
        50,
        DateTime(2026, 9, 3),
      );
      await helper.insertTransfer(transfer);
      await helper.insertTransfer(
        testTransfer('u', 'bank', Account.cashId, 5, DateTime(2026, 9, 4)),
      );
      await helper.updateTransfer(
        transfer.copyWith(amount: const Money(60000)),
      );

      expect(
        [for (final t in await helper.fetchTransfers()) (t.id, t.amount)],
        [('u', const Money(5000)), ('t', const Money(60000))],
      );

      await helper.updateTransfer(
        transfer.copyWith(deletedAt: DateTime.utc(2026, 9, 5)),
      );
      expect([for (final t in await helper.fetchTransfers()) t.id], ['u']);
    });

    test('deleted transfers are kept and read back (DEL-5)', () async {
      final helper = helperAt('app.db');
      final kept = testTransfer(
        'keep',
        Account.cashId,
        'bank',
        5,
        DateTime(2026, 9, 4),
      );
      final gone = testTransfer(
        'gone',
        Account.cashId,
        'bank',
        50,
        DateTime(2026, 9, 3),
      );
      await helper.insertTransfer(kept);
      await helper.insertTransfer(gone);
      await helper.updateTransfer(
        gone.copyWith(deletedAt: DateTime.utc(2026, 9, 5)),
      );

      expect([for (final t in await helper.fetchTransfers()) t.id], ['keep']);
      expect(
        [for (final t in await helper.fetchDeletedTransfers()) t.id],
        ['gone'],
      );
    });
    test('an import is written whole or not at all (IMP-1)', () async {
      final helper = helperAt('app.db');

      await helper.insertImported(
        transactions: [
          testTx('i1', expense, 12.5, DateTime(2026, 9, 1)),
          testTx('i2', expense, 3, DateTime(2026, 9, 2)),
        ],
        transfers: [
          testTransfer('i3', Account.cashId, 'bank', 5, DateTime(2026, 9, 3)),
        ],
      );

      expect(
        [for (final t in await helper.fetchTransactions()) t.id],
        ['i2', 'i1'],
      );
      expect([for (final t in await helper.fetchTransfers()) t.id], ['i3']);

      // The second row repeats i1's primary key, so the batch fails and the
      // first row of it isn't left behind either.
      await expectLater(
        helper.insertImported(
          transactions: [
            testTx('i4', expense, 1, DateTime(2026, 9, 4)),
            testTx('i1', expense, 1, DateTime(2026, 9, 5)),
          ],
          transfers: const [],
        ),
        throwsA(anything),
      );
      expect([
        for (final t in await helper.fetchTransactions()) t.id,
      ], isNot(contains('i4')));
    });

    test('recurring rules are updated and skipped once deleted', () async {
      final helper = helperAt('app.db');
      final rule = testRule('rent', 900, DateTime(2026, 9));
      await helper.insertRecurringRule(rule);

      await helper.updateRecurringRule(
        rule.copyWith(pausedAt: DateTime.utc(2026, 9, 5)),
      );
      expect(
        (await helper.fetchRecurringRules()).single.pausedAt,
        DateTime.utc(2026, 9, 5),
      );

      await helper.updateRecurringRule(
        rule.copyWith(deletedAt: DateTime.utc(2026, 9, 6)),
      );
      expect(await helper.fetchRecurringRules(), isEmpty);
    });

    test('notes are saved, updated, and purged from the trash', () async {
      final helper = helperAt('app.db');
      final note = testNote('n', 'Pay rent', dueDate: DateTime(2026, 9, 1));
      await helper.insertNote(note);

      await helper.updateNote(note.copyWith(doneAt: DateTime.utc(2026, 9, 2)));
      expect(
        (await helper.fetchNotes()).single.doneAt,
        DateTime.utc(2026, 9, 2),
      );

      await helper.updateNote(
        note.copyWith(deletedAt: DateTime.utc(2026, 8, 1)),
      );
      expect(await helper.fetchNotes(), isEmpty);

      await helper.purgeDeletedBefore(DateTime.utc(2026, 9));
      expect(await (await helper.database).query('notes'), isEmpty);
    });

    test('deleted notes are kept and read back, most recent first (DEL-5, '
        'NOTE-7)', () async {
      final helper = helperAt('app.db');
      final kept = testNote('keep', 'Still open');
      final first = testNote('first', 'Deleted first');
      final second = testNote('second', 'Deleted second');
      await helper.insertNote(kept);
      await helper.insertNote(first);
      await helper.insertNote(second);

      await helper.updateNote(
        first.copyWith(deletedAt: DateTime.utc(2026, 9, 4)),
      );
      await helper.updateNote(
        second.copyWith(deletedAt: DateTime.utc(2026, 9, 5)),
      );

      expect([for (final n in await helper.fetchNotes()) n.id], ['keep']);
      final deleted = await helper.fetchDeletedNotes();
      expect([for (final n in deleted) n.id], ['second', 'first']);
      expect(deleted.first.deletedAt, DateTime.utc(2026, 9, 5));
      expect(deleted.last.deletedAt, DateTime.utc(2026, 9, 4));
    });

    test('a database from before the purge step upgrades and purges trash in '
        'every table (DEL-3, BAK-3, rules-1-5#7)', () async {
      final steps = DBHelper.schemaMigrations;
      // Everything before the purge-tombstone step, named rather than
      // counted back from the end for the same reason as the attachments
      // upgrade test above.
      final before = helperAt(
        'purge-upgrade.db',
        steps.sublist(0, steps.indexOf(migrateToVersion11)),
      );
      await before.insertTransaction(
        testTx(
          'old-tx',
          expense,
          5,
          DateTime(2026, 7, 1),
        ).copyWith(deletedAt: DateTime.utc(2026, 7, 1)),
      );
      await before.insertTransfer(
        testTransfer(
          'old-transfer',
          Account.cashId,
          'bank',
          5,
          DateTime(2026, 7, 1),
        ).copyWith(deletedAt: DateTime.utc(2026, 7, 1)),
      );
      await before.insertNote(
        testNote(
          'old-note',
          'Pay rent',
        ).copyWith(deletedAt: DateTime.utc(2026, 7, 1)),
      );
      await before.close();

      final upgraded = helperAt('purge-upgrade.db');
      await upgraded.purgeDeletedBefore(DateTime.utc(2026, 9, 1));

      expect((await upgraded.fetchPurgedIds()).keys, {
        'old-tx',
        'old-transfer',
        'old-note',
      });
    });
  });

  group('attachments (ATT-1, ATT-5)', () {
    test('a photo and a voice note survive a round trip', () async {
      final helper = helperAt('app.db');
      final lunch = testTx(
        'a',
        expense,
        12.5,
        DateTime(2026, 9, 16),
      ).copyWith(photoFile: 'a.jpg', voiceFile: 'a.m4a');

      await helper.insertTransaction(lunch);

      final stored = (await helper.fetchTransactions()).single;
      expect(stored.photoFile, 'a.jpg');
      expect(stored.voiceFile, 'a.m4a');
    });

    test('a database from before the step upgrades and keeps rows', () async {
      final steps = DBHelper.schemaMigrations;
      // Everything before the attachments step, named rather than counted
      // back from the end: appending a later step must not quietly turn this
      // into a test of that one instead.
      final before = helperAt(
        'upgraded.db',
        steps.sublist(0, steps.indexOf(migrateToVersion9)),
      );
      // The old schema has no attachment columns: write the row the way
      // that version would have.
      final old = await before.database;
      await old.insert(
        'transactions',
        testTx('a', expense, 5, DateTime(2026, 9, 16)).toMap()
          ..remove('photo_file')
          ..remove('voice_file'),
      );
      await before.close();

      final upgraded = helperAt('upgraded.db');
      final stored = (await upgraded.fetchTransactions()).single;
      expect(stored.photoFile, isNull);

      await upgraded.updateTransaction(stored.copyWith(photoFile: 'a.jpg'));

      expect((await upgraded.fetchTransactions()).single.photoFile, 'a.jpg');
    });

    test('the colour step leaves no category without one (CAT-6)', () async {
      final steps = DBHelper.schemaMigrations;
      final before = helperAt(
        'colours.db',
        steps.sublist(0, steps.indexOf(migrateToVersion10)),
      );
      await before.database;
      await before.close();

      final upgraded = helperAt('colours.db');
      final categories = await upgraded.fetchCategories();

      expect(categories, isNotEmpty);
      expect(categories.where((c) => c.color == null), isEmpty);
      // Only colours the app itself offers, so an upgraded database and a
      // fresh one are picking from the same sixteen.
      expect(
        categories.where((c) => !categoryPalette.contains(c.color)),
        isEmpty,
      );
      // Handed out in palette order, so the first screenful is not one
      // colour repeated.
      expect(categories.first.color, isNot(categories[1].color));
    });

    test(
      'the colour step wraps around once every colour is handed out (CAT-6)',
      () async {
        // The 15 built-in categories never reach the palette's 16 colours by
        // themselves, so this only shows up once the user has added enough
        // categories of their own to run past the end of the palette.
        final steps = DBHelper.schemaMigrations;
        final before = helperAt(
          'colours.db',
          steps.sublist(0, steps.indexOf(migrateToVersion10)),
        );
        final made = DateTime.utc(2026, 9, 1).toIso8601String();
        final raw = await before.database;
        // 15 defaults already exist at sort_order 0-14; two more make 17.
        for (var i = 0; i < 2; i++) {
          await raw.insert('categories', {
            'id': 'cat-extra-$i',
            'type': 'expense',
            'name': 'Extra $i',
            'icon': '⭐',
            'sort_order': 15 + i,
            'created_at': made,
            'updated_at': made,
          });
        }
        await before.close();

        final upgraded = helperAt('colours.db');
        final categories = await upgraded.fetchCategories();
        final seventeenth = categories.firstWhere((c) => c.id == 'cat-extra-1');

        expect(categories, hasLength(17));
        // The 17th category (index 16) wraps back to the first colour.
        expect(seventeenth.color, categoryPalette[0]);
      },
    );

    test('the colour step leaves everything else alone (CAT-6)', () async {
      final steps = DBHelper.schemaMigrations;
      final before = helperAt(
        'keeps.db',
        steps.sublist(0, steps.indexOf(migrateToVersion10)),
      );
      final made = DateTime.utc(2026, 9, 1);
      // A category the user made and named themselves, with spending on it —
      // an app that updates finds exactly this and must not disturb it.
      final old = await before.database;
      await old.insert('categories', {
        'id': 'cat-coffee',
        'type': 'expense',
        'name': 'Coffee',
        'icon': '☕',
        'sort_order': 42,
        'created_at': made.toIso8601String(),
        'updated_at': made.toIso8601String(),
      });
      await before.insertTransaction(
        testTx('t', expense, 7, DateTime(2026, 9, 2), categoryId: 'cat-coffee'),
      );
      final countBefore = (await before.fetchCategories()).length;
      await before.close();

      final upgraded = helperAt('keeps.db');
      final categories = await upgraded.fetchCategories();
      final coffee = categories.firstWhere((c) => c.id == 'cat-coffee');

      expect(categories, hasLength(countBefore));
      expect(coffee.name, 'Coffee');
      expect(coffee.icon, '☕');
      expect(coffee.sortOrder, 42);
      expect(coffee.createdAt, made);
      expect(coffee.color, isNotNull);
      // And what was spent on it still points at it.
      final stored = (await upgraded.fetchTransactions()).single;
      expect(stored.categoryId, 'cat-coffee');
      expect(stored.amount, const Money(7000));
    });

    test('a category keeps the colour it was given (CAT-6)', () async {
      final helper = helperAt('app.db');
      final now = DateTime.utc(2026, 9, 22);

      await helper.insertCategory(
        Category(
          id: 'cat-coffee',
          type: expense,
          name: 'Coffee',
          icon: '☕',
          color: categoryPalette[3],
          sortOrder: 99,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final stored = (await helper.fetchCategories()).firstWhere(
        (c) => c.id == 'cat-coffee',
      );
      expect(stored.color, categoryPalette[3]);
    });

    test('purging old trash hands back only its own files', () async {
      final helper = helperAt('app.db');
      final day = DateTime(2026, 9, 16);
      await helper.insertTransaction(
        testTx('old', expense, 5, day)
            .copyWith(photoFile: 'old.jpg', voiceFile: 'old.m4a')
            .copyWith(deletedAt: DateTime.utc(2026, 8, 1)),
      );
      await helper.insertTransaction(
        testTx('recent', expense, 6, day)
            .copyWith(photoFile: 'recent.jpg')
            .copyWith(deletedAt: DateTime.utc(2026, 9, 15)),
      );
      await helper.insertTransaction(
        testTx('live', expense, 7, day).copyWith(photoFile: 'live.jpg'),
      );

      final left = await helper.purgeDeletedBefore(DateTime.utc(2026, 9, 1));

      expect(left, ['old.jpg', 'old.m4a']);
      expect((await helper.fetchTransactions()).single.id, 'live');
    });
  });
}
