import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transaction_filter.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  const income = TransactionType.income;
  const cash = Account.cashId;

  test('foldForSearch lowercases and strips accents (SRCH-1)', () {
    expect(foldForSearch('Café Crème'), 'cafe creme');
    expect(foldForSearch('ŁÓDŹ'), 'lodz');
  });

  group('search (SRCH-1–SRCH-3)', () {
    late TransactionProvider provider;

    setUp(() async {
      provider = TransactionProvider(
        db: FakeDB(
          accounts: [testAccount(cash), testAccount('Bank')],
          transactions: [
            testTx(
              'lunch',
              expense,
              12.5,
              DateTime(2026, 9, 10),
              title: 'Café lunch',
            ),
            testTx(
              'rent',
              expense,
              900,
              DateTime(2026, 9, 1),
              title: 'Flat',
              note: 'September',
              categoryId: 'cat-rent',
            ),
            testTx(
              'pay',
              income,
              2000,
              DateTime(2026, 8, 30),
              title: 'Salary Aug',
            ),
            testTx(
              'books',
              expense,
              40,
              DateTime(2026, 9, 12),
              title: 'Books',
            ).copyWith(accountId: 'Bank'),
            testTx(
              'later',
              expense,
              12.5,
              DateTime(2026, 9, 20),
              title: 'Concert',
            ),
          ],
        ),
        clock: () => DateTime(2026, 9, 15),
      );
      await provider.load();
    });

    SearchResult run(TransactionFilter filter) => provider.search(
      filter,
      categoryName: (category) => category.defaultKey ?? category.name ?? '',
      accountName: (account) => account.name ?? '',
    );

    List<String> ids(TransactionFilter filter) => [
      for (final tx in run(filter).transactions) tx.id,
    ];

    test('text matches the title, note, category, and account', () {
      expect(ids(const TransactionFilter(query: 'CAFE')), ['lunch']);
      expect(ids(const TransactionFilter(query: 'sept')), ['rent']);
      expect(ids(const TransactionFilter(query: 'rent')), ['rent']);
      expect(ids(const TransactionFilter(query: 'bank')), ['books']);
    });

    test('an amount finds equal amounts however it is written', () {
      expect(ids(const TransactionFilter(query: '12.50')), ['later', 'lunch']);
      expect(ids(const TransactionFilter(query: '900')), ['rent']);
    });

    test('filters combine with AND, within an inclusive date range', () {
      expect(ids(const TransactionFilter(type: expense, accountId: cash)), [
        'later',
        'lunch',
        'rent',
      ]);
      expect(
        ids(const TransactionFilter(categoryId: 'cat-rent', query: 'flat')),
        ['rent'],
      );
      expect(
        ids(const TransactionFilter(categoryId: 'cat-rent', query: 'books')),
        isEmpty,
      );
      expect(
        ids(
          TransactionFilter(
            from: DateTime(2026, 9, 10),
            to: DateTime(2026, 9, 12),
          ),
        ),
        ['books', 'lunch'],
      );
    });

    test('an empty search lists everything; totals skip upcoming ones', () {
      final result = run(const TransactionFilter());

      expect(result.transactions, hasLength(5));
      expect(result.income, const Money(2000000));
      expect(result.expense, const Money(952500));
    });
  });
}
