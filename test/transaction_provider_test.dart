import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'fake_db.dart';

void main() {
  late DBHelper db;
  late TransactionProvider provider;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    db = DBHelper(path: inMemoryDatabasePath);
    provider = TransactionProvider(db: db);
  });

  tearDown(() => db.close());

  ExpenseTransaction tx(
    String id,
    TransactionType type,
    double amount,
    DateTime date, {
    String category = 'Food',
  }) {
    return ExpenseTransaction(
      id: id,
      title: id,
      amount: amount,
      category: category,
      type: type,
      date: date,
    );
  }

  test('add, update, and delete persist to the injected database', () async {
    await provider.addTransaction(
      tx('a', TransactionType.expense, 10, DateTime(2026, 9, 1)),
    );
    await provider.updateTransaction(
      tx('a', TransactionType.expense, 12.5, DateTime(2026, 9, 1)),
    );
    await provider.addTransaction(
      tx('b', TransactionType.income, 100, DateTime(2026, 9, 2)),
    );
    await provider.deleteTransaction('b');

    final reloaded = TransactionProvider(db: db);
    await reloaded.load();

    expect(reloaded.transactions.map((t) => (t.id, t.amount)).toList(), [
      ('a', 12.5),
    ]);
  });

  test('totals, categories, and day groups cover the selected month', () async {
    for (final t in [
      tx(
        's1',
        TransactionType.income,
        1000,
        DateTime(2026, 9, 5),
        category: 'Salary',
      ),
      tx('s2', TransactionType.expense, 20, DateTime(2026, 9, 5)),
      tx('s3', TransactionType.expense, 10, DateTime(2026, 9, 20)),
      tx(
        's4',
        TransactionType.expense,
        15,
        DateTime(2026, 9, 20),
        category: 'Rent',
      ),
      tx('a1', TransactionType.expense, 7, DateTime(2026, 8, 31)),
    ]) {
      await provider.addTransaction(t);
    }

    provider.setSelectedMonth(DateTime(2026, 9, 13));
    expect(provider.selectedMonth, DateTime(2026, 9));
    expect(provider.monthlyIncome, 1000.0);
    expect(provider.monthlyExpense, 45.0);
    expect(provider.monthlyBalance, 955.0);
    expect(provider.expenseByCategory, {'Food': 30.0, 'Rent': 15.0});
    expect(provider.groupedBySelectedDay.keys.toList(), [
      DateTime(2026, 9, 20),
      DateTime(2026, 9, 5),
    ]);

    provider.previousMonth();
    expect(provider.selectedMonth, DateTime(2026, 8));
    expect(provider.monthlyExpense, 7.0);

    provider.nextMonth();
    provider.nextMonth();
    expect(provider.transactionsForSelectedMonth, isEmpty);
  });

  group('when a database write fails', () {
    late FakeDB fake;
    late TransactionProvider failing;
    late int notifications;

    setUp(() async {
      fake = FakeDB([
        tx('keep', TransactionType.expense, 5, DateTime(2026, 9, 2)),
        tx('x', TransactionType.expense, 10, DateTime(2026, 9, 1)),
      ]);
      failing = TransactionProvider(db: fake);
      await failing.load();
      fake.failWrites = true;
      notifications = 0;
      failing.addListener(() => notifications++);
    });

    List<String> ids() => [for (final t in failing.transactions) t.id];

    test('add rethrows and leaves the list unchanged', () async {
      await expectLater(
        failing.addTransaction(
          tx('new', TransactionType.income, 1, DateTime(2026, 9, 3)),
        ),
        throwsStateError,
      );
      expect(ids(), ['keep', 'x']);
      expect(notifications, 0);
    });

    test('update rethrows and keeps the old values', () async {
      await expectLater(
        failing.updateTransaction(
          tx('x', TransactionType.expense, 99, DateTime(2026, 9, 1)),
        ),
        throwsStateError,
      );
      expect(failing.transactions.last.amount, 10);
      expect(notifications, 0);
    });

    test('delete rethrows and leaves the list unchanged', () async {
      await expectLater(failing.deleteTransaction('keep'), throwsStateError);
      expect(ids(), ['keep', 'x']);
      expect(notifications, 0);
    });
  });
}
