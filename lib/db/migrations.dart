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
