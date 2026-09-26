import 'package:sqflite/sqflite.dart';

// Schema steps listed in `DBHelper.schemaMigrations`. A step is frozen once it
// merges, so steps use literal SQL and data, never model classes that can
// change later.

/// Version 2: integer amounts in thousandths (MONEY-1), optional title
/// (ADD-1), timestamps (REC-1), and soft delete (DEL-1).
Future<void> migrateToVersion2(DatabaseExecutor db) async {
  final now = DateTime.now().toUtc().toIso8601String();
  await db.execute('''
    CREATE TABLE transactions_v2 (
      id TEXT PRIMARY KEY,
      title TEXT,
      amount INTEGER NOT NULL,
      category TEXT NOT NULL,
      type TEXT NOT NULL,
      date TEXT NOT NULL,
      note TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    )
  ''');
  await db.execute(
    '''
    INSERT INTO transactions_v2
      (id, title, amount, category, type, date, note, created_at, updated_at)
    SELECT id, NULLIF(TRIM(title), ''), CAST(ROUND(amount * 1000) AS INTEGER),
      category, type, date, NULLIF(TRIM(note), ''), ?, ?
    FROM transactions
    ''',
    [now, now],
  );
  await db.execute('DROP TABLE transactions');
  await db.execute('ALTER TABLE transactions_v2 RENAME TO transactions');
}

/// Version 3: a categories table with 15 built-in defaults (CAT-1, CAT-2).
/// Transactions reference a category ID; version 1 names map to the defaults.
Future<void> migrateToVersion3(DatabaseExecutor db) async {
  final now = DateTime.now().toUtc().toIso8601String();
  await db.execute('''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      default_key TEXT,
      name TEXT,
      icon TEXT NOT NULL,
      sort_order INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      archived_at TEXT,
      deleted_at TEXT
    )
  ''');

  // Built-in defaults use fixed IDs so they match across devices (REC-2).
  const defaults = [
    ('cat-food', 'expense', 'food', '🍔'),
    ('cat-groceries', 'expense', 'groceries', '🛒'),
    ('cat-transport', 'expense', 'transport', '🚗'),
    ('cat-shopping', 'expense', 'shopping', '🛍️'),
    ('cat-bills', 'expense', 'bills', '💡'),
    ('cat-rent', 'expense', 'rent', '🏠'),
    ('cat-health', 'expense', 'health', '💊'),
    ('cat-education', 'expense', 'education', '📚'),
    ('cat-entertainment', 'expense', 'entertainment', '🎬'),
    ('cat-other', 'expense', 'other', '📦'),
    ('cat-salary', 'income', 'salary', '💼'),
    ('cat-business', 'income', 'business', '🏢'),
    ('cat-investment', 'income', 'investment', '📈'),
    ('cat-gift', 'income', 'gift', '🎁'),
    ('cat-income-other', 'income', 'other', '📦'),
  ];
  for (var i = 0; i < defaults.length; i++) {
    final (id, type, key, icon) = defaults[i];
    await db.insert('categories', {
      'id': id,
      'type': type,
      'default_key': key,
      'icon': icon,
      'sort_order': i,
      'created_at': now,
      'updated_at': now,
    });
  }

  await db.execute('''
    CREATE TABLE transactions_v3 (
      id TEXT PRIMARY KEY,
      title TEXT,
      amount INTEGER NOT NULL,
      category_id TEXT NOT NULL,
      type TEXT NOT NULL,
      date TEXT NOT NULL,
      note TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    )
  ''');
  await db.execute('''
    INSERT INTO transactions_v3
    SELECT id, title, amount,
      CASE type WHEN 'income' THEN 'cat-income-other' ELSE 'cat-other' END,
      type, date, note, created_at, updated_at, deleted_at
    FROM transactions
  ''');

  // Version 1 category names; any other name stays Other.
  const renames = [
    ('expense', 'Food', 'cat-food'),
    ('expense', 'Groceries', 'cat-groceries'),
    ('expense', 'Transport', 'cat-transport'),
    ('expense', 'Shopping', 'cat-shopping'),
    ('expense', 'Bills', 'cat-bills'),
    ('expense', 'Rent', 'cat-rent'),
    ('expense', 'Health', 'cat-health'),
    ('expense', 'Education', 'cat-education'),
    ('expense', 'Entertainment', 'cat-entertainment'),
    ('income', 'Salary', 'cat-salary'),
    ('income', 'Business', 'cat-business'),
    ('income', 'Freelance', 'cat-business'),
    ('income', 'Investment', 'cat-investment'),
    ('income', 'Gift', 'cat-gift'),
  ];
  for (final (type, name, categoryId) in renames) {
    await db.execute(
      'UPDATE transactions_v3 SET category_id = ? WHERE id IN '
      '(SELECT id FROM transactions WHERE type = ? AND category = ?)',
      [categoryId, type, name],
    );
  }

  await db.execute('DROP TABLE transactions');
  await db.execute('ALTER TABLE transactions_v3 RENAME TO transactions');
}

/// Version 4: an accounts table with the built-in Cash account (ACC-1,
/// ACC-2); every transaction belongs to an account, Cash by default.
Future<void> migrateToVersion4(DatabaseExecutor db) async {
  final now = DateTime.now();
  final stamp = now.toUtc().toIso8601String();
  await db.execute('''
    CREATE TABLE accounts (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      default_key TEXT,
      name TEXT,
      opening_balance INTEGER NOT NULL,
      opening_date TEXT NOT NULL,
      sort_order INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      archived_at TEXT,
      deleted_at TEXT
    )
  ''');
  await db.insert('accounts', {
    'id': 'acc-cash',
    'type': 'cash',
    'default_key': 'cash',
    'opening_balance': 0,
    'opening_date': DateTime(now.year, now.month, now.day).toIso8601String(),
    'sort_order': 0,
    'created_at': stamp,
    'updated_at': stamp,
  });
  await db.execute(
    "ALTER TABLE transactions ADD COLUMN account_id TEXT NOT NULL DEFAULT 'acc-cash'",
  );
}

/// Version 5: transfers between accounts (ACC-3).
Future<void> migrateToVersion5(DatabaseExecutor db) async {
  await db.execute('''
    CREATE TABLE transfers (
      id TEXT PRIMARY KEY,
      from_account_id TEXT NOT NULL,
      to_account_id TEXT NOT NULL,
      amount INTEGER NOT NULL,
      date TEXT NOT NULL,
      note TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    )
  ''');
}

/// Version 6: budgets, versioned by the period each limit takes effect from
/// (BUD-1, BUD-5). A null amount removes the budget from that period on.
Future<void> migrateToVersion6(DatabaseExecutor db) async {
  await db.execute('''
    CREATE TABLE budgets (
      id TEXT PRIMARY KEY,
      category_id TEXT,
      amount INTEGER,
      effective_from TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    )
  ''');
}

/// Version 7: recurring rules, and the occurrences already posted or
/// skipped, stored once per rule and date (RCR-1, RCR-4).
Future<void> migrateToVersion7(DatabaseExecutor db) async {
  await db.execute('''
    CREATE TABLE recurring_rules (
      id TEXT PRIMARY KEY,
      title TEXT,
      amount INTEGER NOT NULL,
      category_id TEXT NOT NULL,
      account_id TEXT NOT NULL,
      type TEXT NOT NULL,
      note TEXT,
      frequency TEXT NOT NULL,
      interval INTEGER NOT NULL,
      start_date TEXT NOT NULL,
      end_type TEXT NOT NULL,
      end_count INTEGER,
      end_date TEXT,
      auto_post INTEGER NOT NULL,
      paused_at TEXT,
      active_from TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE recurring_occurrences (
      rule_id TEXT NOT NULL,
      date TEXT NOT NULL,
      status TEXT NOT NULL,
      transaction_id TEXT,
      created_at TEXT NOT NULL,
      PRIMARY KEY (rule_id, date)
    )
  ''');
}

/// Version 8: notes, with an optional due date, reminder, amount, category,
/// and a link to the transaction they were recorded as (NOTE-1, NOTE-4).
Future<void> migrateToVersion8(DatabaseExecutor db) async {
  await db.execute('''
    CREATE TABLE notes (
      id TEXT PRIMARY KEY,
      text TEXT NOT NULL,
      due_date TEXT,
      reminder_at TEXT,
      amount INTEGER,
      category_id TEXT,
      transaction_id TEXT,
      done_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    )
  ''');
}

/// Version 9: one photo and one voice note per transaction (ATT-1). Only the
/// file names are stored; the files live in the app's own storage (ATT-2).
Future<void> migrateToVersion9(DatabaseExecutor db) async {
  await db.execute('ALTER TABLE transactions ADD COLUMN photo_file TEXT');
  await db.execute('ALTER TABLE transactions ADD COLUMN voice_file TEXT');
}

/// Version 10: a colour per category (CAT-6). Every category that already
/// exists is given one, by its place in the list, so an upgraded database
/// looks chosen rather than half-filled. The column stays nullable: a backup
/// written before this step restores without one, and the fallback in
/// `labels.dart` covers it.
///
/// The sixteen values are written out here rather than read from
/// `categoryPalette`: a merged step is frozen, and the palette the app offers
/// is free to change without rewriting what this one did.
Future<void> migrateToVersion10(DatabaseExecutor db) async {
  const palette = [
    0xFF6C5CE7,
    0xFF00897B,
    0xFFD84315,
    0xFF1E88E5,
    0xFFC2185B,
    0xFF2E7D32,
    0xFF8E24AA,
    0xFF00838F,
    0xFF5D4037,
    0xFF3949AB,
    0xFFE53935,
    0xFF546E7A,
    0xFFEF6C00,
    0xFF00695C,
    0xFF4527A0,
    0xFFAD1457,
  ];
  await db.execute('ALTER TABLE categories ADD COLUMN color INTEGER');
  final rows = await db.query(
    'categories',
    columns: ['id'],
    orderBy: 'sort_order, id',
  );
  for (var i = 0; i < rows.length; i++) {
    await db.update(
      'categories',
      {'color': palette[i % palette.length]},
      where: 'id = ?',
      whereArgs: [rows[i]['id']],
    );
  }
}

/// Version 11: a record of every ID ever purged from the trash (DEL-3), so a
/// later merge of an older backup never brings a deletion back once its
/// tombstone is gone (BAK-3, rules-1-5#7). Local only: it never travels in a
/// backup, since it says what this device has already thrown away, not
/// anything about the record itself. `updated_at` is the purged row's own
/// stamp (when it was last touched, deletion included), not when the purge
/// ran, so a merge can still tell whether a backup's edit came after it.
Future<void> migrateToVersion11(DatabaseExecutor db) async {
  await db.execute('''
    CREATE TABLE purged_records (
      id TEXT PRIMARY KEY,
      updated_at TEXT NOT NULL
    )
  ''');
}

/// Version 12: `migrateToVersion10` coloured every category from its own
/// frozen snapshot of the palette, which is right for that merged step, but
/// the live `categoryPalette` has since moved seven of those sixteen values
/// to clear WCAG's 3:1 non-text bar (CAT-6, THEME-4, pr58#9) and nothing
/// carried that into rows a device already coloured -- including the
/// fifteen default categories `migrateToVersion3` seeds on every fresh
/// install, since a fresh install runs every step in order and inherits
/// `migrateToVersion10`'s values before this one runs. Remaps each retired
/// value to its replacement in place, so an upgraded install and a fresh one
/// end up drawing the same, currently-readable sixteen colours.
Future<void> migrateToVersion12(DatabaseExecutor db) async {
  const remap = {
    0xFF8E24AA: 0xFFA028BF,
    0xFF5D4037: 0xFF835A4E,
    0xFF3949AB: 0xFF4A5BC3,
    0xFF00695C: 0xFF007365,
    0xFF4527A0: 0xFF6C4BD3,
    0xFFAD1457: 0xFFBF1660,
    // Cleared the dark and black surfaces but not the light theme's own,
    // much paler one (pr58#9's own re-check).
    0xFFEF6C00: 0xFFE65100,
  };
  final now = DateTime.now().toUtc().toIso8601String();
  for (final entry in remap.entries) {
    await db.update(
      'categories',
      {'color': entry.value, 'updated_at': now},
      where: 'color = ?',
      whereArgs: [entry.key],
    );
  }
}
