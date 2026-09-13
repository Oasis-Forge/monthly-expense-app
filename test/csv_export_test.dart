import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/csv_export.dart';
import 'package:monthly_expense_app/models/transaction.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;

  String csvOf(List<ExpenseTransaction> transactions) => buildCsv(
    transactions: transactions,
    currencyCode: 'USD',
    categoryName: (_) => 'Food',
    accountName: (_) => 'Cash',
  );

  /// The data lines, without the byte order mark and the header.
  List<String> lines(String csv) => csv.substring(1).split('\r\n').sublist(1);

  test('rows are oldest first with ISO dates and plain amounts (BAK-5)', () {
    final csv = buildCsv(
      transactions: [
        testTx('b', expense, 12.5, DateTime(2026, 9, 10, 18), title: 'Lunch'),
        testTx(
          'a',
          TransactionType.income,
          2000,
          DateTime(2026, 9, 1),
          title: 'Salary',
          note: 'September',
        ),
      ],
      transfers: [
        testTransfer('t', Account.cashId, 'bank', 50, DateTime(2026, 9, 5)),
      ],
      currencyCode: 'USD',
      categoryName: (id) => id == 'cat-food' ? 'Food' : 'Salary',
      accountName: (id) => id == Account.cashId ? 'Cash' : 'Bank',
    );

    expect(csv, startsWith('\uFEFF'));
    expect(csv.substring(1).split('\r\n'), [
      'date,type,amount,currency,category,account,to_account,title,note',
      '2026-09-01,income,2000,USD,Salary,Cash,,Salary,September',
      '2026-09-05,transfer,50,USD,,Cash,Bank,,',
      '2026-09-10,expense,12.5,USD,Food,Cash,,Lunch,',
      '',
    ]);
  });

  test('text with commas, quotes, or line breaks is quoted', () {
    final csv = csvOf([
      testTx(
        'a',
        expense,
        3,
        DateTime(2026, 9, 1),
        title: 'Dinner, "Luigi\'s"',
        note: 'two\nlines',
      ),
    ]);

    expect(
      csv,
      contains(
        '2026-09-01,expense,3,USD,Food,Cash,,"Dinner, ""Luigi\'s""","two\nlines"',
      ),
    );
  });

  test('text a spreadsheet would run as a formula gets an apostrophe', () {
    final csv = csvOf([
      testTx('a', expense, 1, DateTime(2026, 9, 1), title: '=SUM(A1)'),
      testTx('b', expense, 1, DateTime(2026, 9, 2), title: '-5 refund'),
      testTx('c', expense, 1, DateTime(2026, 9, 3), title: '@home'),
      testTx('d', expense, 1, DateTime(2026, 9, 4), title: '+1 extra'),
    ]);

    expect(
      [for (final line in lines(csv)) line.split(',').elementAtOrNull(7)],
      ["'=SUM(A1)", "'-5 refund", "'@home", "'+1 extra", null],
    );
  });
}
