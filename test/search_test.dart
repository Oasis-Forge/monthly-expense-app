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

  test('foldForSearch lowercases and strips accents (SRCH-1, LANG-4)', () {
    expect(foldForSearch('Café Crème'), 'cafe creme');
    expect(foldForSearch('ŁÓDŹ'), 'lodz');
    // Turkish dotted and dotless i.
    expect(foldForSearch('İstanbul'), 'istanbul');
    expect(foldForSearch('ILIK'), foldForSearch('ılık'));
    expect(foldForSearch('Şişli Ağaç'), 'sisli agac');
    // Arabic with a vowel mark and a tatweel, and alef with hamza.
    final damma = String.fromCharCode(0x064F);
    final tatweel = String.fromCharCode(0x0640);
    expect(foldForSearch('م$damma$tatweelحمد'), 'محمد');
    expect(foldForSearch('أحمد'), foldForSearch('احمد'));
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
            // Trashed, so it counts nowhere: not in results, not in totals
            // (BAL-5).
            testTx(
              'trashed',
              expense,
              5000,
              DateTime(2026, 9, 11),
              title: 'Café gone',
            ).copyWith(deletedAt: DateTime.utc(2026, 9, 12)),
          ],
        ),
        clock: () => DateTime(2026, 9, 15),
      );
      await provider.load();
    });

    SearchResult run(TransactionFilter filter, {String decimalMark = '.'}) =>
        provider.search(
          filter,
          categoryName: (category) =>
              category.defaultKey ?? category.name ?? '',
          accountName: (account) => account.name ?? '',
          decimalMark: decimalMark,
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

    test('a trashed transaction counts nowhere: not in results, not in '
        'totals (BAL-5)', () {
      // Even a query that would otherwise match it by title.
      expect(ids(const TransactionFilter(query: 'cafe gone')), isEmpty);

      final result = run(const TransactionFilter());
      expect(result.transactions.map((t) => t.id), isNot(contains('trashed')));
      // Its 5000 expense is not folded into the total.
      expect(result.expense, const Money(952500));
    });
  });

  group(
    'the decimal mark an amount query is read with (CUR-2, review-money-1)',
    () {
      // "1,500" is the ambiguous case Money.tryParse guards: a 3-decimal
      // fraction (1.5) under a comma-decimal language, or a thousands
      // separator (1500) under everything else. decimalMark has no default
      // here, so a caller that forgot it (as report_screen.dart once did)
      // silently read every amount query as '.', missing a comma-decimal
      // language's own amounts entirely.
      late TransactionProvider provider;

      setUp(() async {
        provider = TransactionProvider(
          db: FakeDB(
            transactions: [testTx('tnd', expense, 1.5, DateTime(2026, 9, 10))],
          ),
          clock: () => DateTime(2026, 9, 15),
        );
        await provider.load();
      });

      List<String> idsWith(String decimalMark) => [
        for (final tx
            in provider
                .search(
                  const TransactionFilter(query: '1,500'),
                  categoryName: (category) => category.name ?? '',
                  accountName: (account) => account.name ?? '',
                  decimalMark: decimalMark,
                )
                .transactions)
          tx.id,
      ];

      test('a comma-decimal language matches the 1.5 entry', () {
        expect(idsWith(','), ['tnd']);
      });

      test('everything else does not, rather than guessing 1500x too much', () {
        expect(idsWith('.'), isEmpty);
      });
    },
  );
}
