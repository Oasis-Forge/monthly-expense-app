import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/amount_expression.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/period.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transfer.dart';

void main() {
  group('Money (MONEY-1, MONEY-2)', () {
    test('parses whole and decimal input exactly', () {
      expect(Money.tryParse('12'), const Money(12000));
      expect(Money.tryParse(' 12.5 '), const Money(12500));
      expect(Money.tryParse('19.99'), const Money(19990));
      expect(Money.tryParse('0.125'), const Money(125));
      expect(Money.tryParse('12,5'), const Money(12500));
    });

    test('rejects anything else', () {
      for (final input in ['', 'abc', '-1', '1.2345', '1,234.50', '.5']) {
        expect(Money.tryParse(input), isNull, reason: input);
      }
    });

    test('rejects more decimals than the currency allows (CUR-2)', () {
      expect(Money.tryParse('12', maxDecimals: 0), const Money(12000));
      expect(Money.tryParse('12.5', maxDecimals: 0), isNull);
      expect(Money.tryParse('12.34', maxDecimals: 2), const Money(12340));
      expect(Money.tryParse('12.345', maxDecimals: 2), isNull);
    });

    test('adds, negates, and formats for editing', () {
      expect(const Money(12500) + const Money(500), const Money(13000));
      expect(const Money(500) - const Money(1500), const Money(-1000));
      expect(-const Money(500), const Money(-500));
      expect(const Money(12500).toInputString(), '12.5');
      expect(const Money(12000).toInputString(), '12');
      expect(const Money(125).toInputString(), '0.125');
      expect(const Money(19990).toDouble(), 19.99);
    });
  });

  group('evaluateAmount (ADD-2)', () {
    test('adds and subtracts exactly', () {
      expect(evaluateAmount('12.5+3'), const Money(15500));
      expect(evaluateAmount('20-2.25+0.25'), const Money(18000));
      expect(evaluateAmount('10−4'), const Money(6000));
      expect(evaluateAmount(' 7 '), const Money(7000));
      expect(evaluateAmount('5-8'), const Money(-3000));
    });

    test('rejects incomplete or invalid input', () {
      for (final input in [
        '',
        '+',
        '12+',
        '-5',
        '1..2+3',
        '12+abc',
        '1.234+1',
      ]) {
        expect(evaluateAmount(input, maxDecimals: 2), isNull, reason: input);
      }
    });

    test('knows when there is a result worth showing', () {
      expect(isAmountExpression('12.5'), isFalse);
      expect(isAmountExpression('12.5+3'), isTrue);
      expect(isAmountExpression('12−3'), isTrue);
    });
  });

  group('ExpenseTransaction', () {
    final full = ExpenseTransaction(
      id: 'a',
      title: 'Lunch',
      amount: const Money(12500),
      categoryId: 'cat-food',
      accountId: Account.cashId,
      type: TransactionType.expense,
      date: DateTime(2026, 9, 13, 12, 30),
      note: 'with team',
      createdAt: DateTime.utc(2026, 9, 13, 9),
      updatedAt: DateTime.utc(2026, 9, 14, 9),
      deletedAt: DateTime.utc(2026, 9, 15, 9),
    );

    test('toMap and fromMap round-trip every field', () {
      final copy = ExpenseTransaction.fromMap(full.toMap());
      expect(copy.toMap(), full.toMap());
      expect(copy.date, full.date);
      expect(copy.deletedAt, full.deletedAt);
    });

    test('copyWith clears nullable fields only when given null', () {
      final kept = full.copyWith(amount: const Money(1));
      expect(
        (kept.title, kept.note, kept.deletedAt),
        (full.title, full.note, full.deletedAt),
      );

      final cleared = full.copyWith(title: null, note: null, deletedAt: null);
      expect(
        (cleared.title, cleared.note, cleared.deletedAt),
        (null, null, null),
      );
      expect(cleared.amount, full.amount);
    });
  });

  group('Transfer', () {
    final transfer = Transfer(
      id: 't',
      fromAccountId: Account.cashId,
      toAccountId: 'bank',
      amount: const Money(50000),
      date: DateTime(2026, 9, 3, 8),
      note: 'savings',
      createdAt: DateTime.utc(2026, 9, 3),
      updatedAt: DateTime.utc(2026, 9, 4),
      deletedAt: DateTime.utc(2026, 9, 5),
    );

    test('round-trips through maps', () {
      expect(Transfer.fromMap(transfer.toMap()).toMap(), transfer.toMap());
    });

    test('copyWith clears note and deletedAt only when given null', () {
      final kept = transfer.copyWith(amount: const Money(1));
      expect((kept.note, kept.deletedAt), (transfer.note, transfer.deletedAt));

      final cleared = transfer.copyWith(note: null, deletedAt: null);
      expect(
        (cleared.note, cleared.deletedAt, cleared.amount),
        (null, null, transfer.amount),
      );
    });
  });

  group('Category', () {
    final category = Category(
      id: 'c',
      type: TransactionType.income,
      name: 'Tips',
      icon: '💵',
      sortOrder: 3,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026, 2),
      archivedAt: DateTime.utc(2026, 3),
    );

    test('round-trips through maps', () {
      expect(Category.fromMap(category.toMap()).toMap(), category.toMap());
    });

    test('copyWith clears name and archivedAt only when given null', () {
      final kept = category.copyWith(icon: '💰');
      expect(
        (kept.name, kept.archivedAt, kept.icon),
        ('Tips', DateTime.utc(2026, 3), '💰'),
      );

      final cleared = category.copyWith(name: null, archivedAt: null);
      expect((cleared.name, cleared.archivedAt), (null, null));
      expect(cleared.id, category.id);
    });
  });

  group('Account', () {
    final account = Account(
      id: 'b',
      type: AccountType.bank,
      name: 'Bank',
      openingBalance: const Money(250000),
      openingDate: DateTime(2026, 9),
      sortOrder: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026, 2),
      archivedAt: DateTime.utc(2026, 3),
    );

    test('round-trips through maps', () {
      expect(Account.fromMap(account.toMap()).toMap(), account.toMap());
    });

    test('copyWith clears name and archivedAt only when given null', () {
      final kept = account.copyWith(openingBalance: const Money(-1000));
      expect(
        (kept.name, kept.archivedAt, kept.openingBalance),
        ('Bank', DateTime.utc(2026, 3), const Money(-1000)),
      );

      final cleared = account.copyWith(name: null, archivedAt: null);
      expect((cleared.name, cleared.archivedAt), (null, null));
    });
  });

  group('Period (PER-1, PER-2)', () {
    test('a start day of 1 gives calendar months', () {
      final period = Period.containing(DateTime(2026, 9, 13, 18));
      expect(period.start, DateTime(2026, 9));
      expect(period.end, DateTime(2026, 10));
      expect(period.lastDay, DateTime(2026, 9, 30));
      expect(period.isCalendarMonth, isTrue);
      expect(period.next.start, DateTime(2026, 10));
      expect(period.previous.start, DateTime(2026, 8));
    });

    test('a start day of 25 runs from the 25th to the 24th', () {
      final before = Period.containing(DateTime(2026, 9, 13), startDay: 25);
      expect(before.start, DateTime(2026, 8, 25));
      expect(before.end, DateTime(2026, 9, 25));
      expect(before.isCalendarMonth, isFalse);

      final onStart = Period.containing(DateTime(2026, 9, 25), startDay: 25);
      expect(onStart.start, DateTime(2026, 9, 25));
      expect(onStart.contains(DateTime(2026, 10, 24, 23, 59)), isTrue);
      expect(onStart.contains(DateTime(2026, 10, 25)), isFalse);
    });

    test('the last day of the month adapts to short months', () {
      const last = Period.lastDayOfMonth;
      final february = Period.containing(DateTime(2026, 2, 10), startDay: last);
      expect(february.start, DateTime(2026, 1, 31));
      expect(february.end, DateTime(2026, 2, 28));
      expect(february.next.end, DateTime(2026, 3, 31));
      expect(february.next.previous, february);
    });

    test('periods roll over the year', () {
      final december = Period.containing(DateTime(2026, 12, 31));
      expect(december.next.start, DateTime(2027, 1));
      expect(december.next.previous, december);
    });
  });
}
