import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/amount_expression.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/note.dart';
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

    test('rejects a comma thousands separator instead of reading it as a '
        '3-decimal fraction (CUR-2, MONEY-1, pr61#6)', () {
      // For a 3-decimal currency (KWD, BHD, JOD, TND), '1,500' is
      // ambiguous: comma-as-decimal-mark reads 1.5, comma-as-thousands-
      // separator reads 1500. Guessing the decimal reading is silently off
      // by 1000x, so this is rejected rather than guessed.
      expect(Money.tryParse('1,500', maxDecimals: 3), isNull);
      // Fewer than 3 digits after the comma isn't the ambiguous case.
      expect(Money.tryParse('12,50', maxDecimals: 3), const Money(12500));
      // A period stays an unambiguous decimal point: it's what editing an
      // existing amount round-trips through (Money.toInputString).
      expect(Money.tryParse('1.500', maxDecimals: 3), const Money(1500));
    });

    test('reads the comma as the decimal mark for a language that writes it '
        'that way (CUR-2, review#money-setup-snackbar)', () {
      // fr, de, tr and the other comma-decimal languages show 1.5 TND as
      // "1,500" (intl's own formatting), so the same text typed back in is
      // no longer ambiguous once the caller says which mark is decimal.
      expect(
        Money.tryParse('1,500', maxDecimals: 3, decimalMark: ','),
        const Money(1500),
      );
      // Where the caller says the comma is a grouping mark instead (the
      // default, matching en and the other comma-grouping languages), the
      // same text stays rejected rather than guessed.
      expect(Money.tryParse('1,500', maxDecimals: 3, decimalMark: '.'), isNull);
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

    test('formats a fraction under 0.01 with its leading zeros (MONEY-2)', () {
      // The fraction is padded to 3 digits before trailing zeros are
      // stripped, so a thousandths value under 100 still reads as
      // thousandths, not as hundredths or tenths.
      expect(const Money(12005).toInputString(), '12.005');
      expect(const Money(5).toInputString(), '0.005');
    });
  });

  group('signedMoney on a zero amount (CUR-5, LANG-5)', () {
    test('en: zero income and zero expense are both signed', () {
      final usd = NumberFormat.currency(
        locale: 'en_US',
        symbol: r'$',
        decimalDigits: 2,
      );
      expect(usd.signedMoney(Money.zero, isIncome: true), '+\$0');
      expect(usd.signedMoney(Money.zero, isIncome: false), '-\$0');
    });

    test('ar: the plus on a zero income stays inside the isolate, not '
        'pasted in front of it', () {
      final ar = NumberFormat.currency(locale: 'ar', name: 'USD');
      final zeroIncome = ar.signedMoney(Money.zero, isIncome: true);
      final zeroExpense = ar.signedMoney(Money.zero, isIncome: false);
      // A bare '+' pasted on afterwards would be the first character; the
      // fix keeps it wherever the locale's own negative pattern places a
      // sign, alongside the direction mark that protects it (LANG-5).
      expect(zeroIncome, isNot(startsWith('+')));
      expect(zeroIncome, contains('+'));
      expect(zeroExpense, contains('-'));
    });

    test('ur: zero income and zero expense are still signed', () {
      final ur = NumberFormat.currency(locale: 'ur', name: 'USD');
      expect(ur.signedMoney(Money.zero, isIncome: true), contains('+'));
      expect(ur.signedMoney(Money.zero, isIncome: false), contains('-'));
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

    // review-money-4: this passthrough had no test at all — removing it (or
    // the one in AmountEntry.parsedAmount / provider.matchesSearch) fell back
    // to '.', silently rejecting "1,500" for a comma-decimal language with a
    // 3-decimal currency (TND/KWD/BHD/JOD/OMR), and no test would fail.
    test(
      'passes decimalMark through to each operand (CUR-2, review-money-4)',
      () {
        expect(
          evaluateAmount('1,500+3', maxDecimals: 3, decimalMark: ','),
          const Money(4500),
        );
        // The default stays '.': the same text is ambiguous (a 3-decimal
        // fraction or a thousands separator) and stays rejected.
        expect(
          evaluateAmount('1,500+3', maxDecimals: 3, decimalMark: '.'),
          isNull,
        );
        // The comma amount as a later operand: dropping decimalMark from
        // the second Money.tryParse call (amount_expression.dart) still
        // passes the case above, because '3' parses the same under either
        // mark — this covers the operand that a regression there would
        // actually break.
        expect(
          evaluateAmount('3+1,500', maxDecimals: 3, decimalMark: ','),
          const Money(4500),
        );
        expect(
          evaluateAmount('3+1,500', maxDecimals: 3, decimalMark: '.'),
          isNull,
        );
      },
    );
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

    Category withColor(int? color) => category.copyWith(color: color);

    test('nextCategoryColor skips colours already worn by a live category '
        '(CAT-6)', () {
      expect(
        nextCategoryColor([withColor(categoryPalette[0])]),
        categoryPalette[1],
      );
      // Order of use doesn't matter, only which colours are taken.
      expect(
        nextCategoryColor([
          withColor(categoryPalette[1]),
          withColor(categoryPalette[0]),
        ]),
        categoryPalette[2],
      );
      // A category that predates colours (null) doesn't block any colour.
      expect(nextCategoryColor([withColor(null)]), categoryPalette[0]);
      // No categories: the first colour.
      expect(nextCategoryColor(const []), categoryPalette[0]);
    });

    test('nextCategoryColor wraps once every colour is taken (CAT-6)', () {
      final allTaken = [for (final c in categoryPalette) withColor(c)];
      expect(nextCategoryColor(allTaken), categoryPalette[0]);
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

    test('copyWith takes a new updatedAt, so a merge sees the later edit '
        '(BAK-3)', () {
      final edited = account.copyWith(updatedAt: DateTime.utc(2026, 5));
      expect(edited.updatedAt, DateTime.utc(2026, 5));
    });
  });

  group('Note (NOTE-1)', () {
    final full = Note(
      id: 'n',
      text: 'Pay rent',
      dueDate: DateTime(2026, 9, 30),
      reminderAt: DateTime(2026, 9, 30, 9),
      amount: const Money(900000),
      categoryId: 'cat-rent',
      transactionId: 'tx-1',
      doneAt: DateTime.utc(2026, 9, 29),
      createdAt: DateTime.utc(2026, 9, 1),
      updatedAt: DateTime.utc(2026, 9, 2),
      deletedAt: DateTime.utc(2026, 9, 3),
    );

    test('round-trips through maps', () {
      expect(Note.fromMap(full.toMap()).toMap(), full.toMap());
    });

    test('isDone follows doneAt', () {
      expect(full.isDone, isTrue);
      expect(full.copyWith(doneAt: null).isDone, isFalse);
    });

    test('copyWith clears nullable fields only when given null', () {
      final kept = full.copyWith(text: 'Pay rent early');
      expect(
        (kept.dueDate, kept.reminderAt, kept.amount, kept.categoryId),
        (full.dueDate, full.reminderAt, full.amount, full.categoryId),
      );
      expect(
        (kept.transactionId, kept.doneAt),
        (full.transactionId, full.doneAt),
      );

      final cleared = full.copyWith(
        dueDate: null,
        reminderAt: null,
        amount: null,
        categoryId: null,
        transactionId: null,
        doneAt: null,
        deletedAt: null,
      );
      expect(
        (
          cleared.dueDate,
          cleared.reminderAt,
          cleared.amount,
          cleared.categoryId,
          cleared.transactionId,
          cleared.doneAt,
          cleared.deletedAt,
        ),
        (null, null, null, null, null, null, null),
      );
      expect(cleared.text, full.text);
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

    test('periods that start together but end apart are different '
        '(PER-1, PER-2)', () {
      // In March 2026 a start day of 28 and the last day of the month both
      // begin on 28 February, but end on 28 and 31 March.
      final on28 = Period.containing(DateTime(2026, 3, 10), startDay: 28);
      final onLast = Period.containing(
        DateTime(2026, 3, 10),
        startDay: Period.lastDayOfMonth,
      );

      expect(on28.start, onLast.start);
      expect(on28, isNot(onLast));
    });
  });

  group('the week a day sits in (DAY-2, DAY-3)', () {
    // 15 September 2026 is a Tuesday.
    final tuesday = DateTime(2026, 9, 15);

    test('a week starts on the chosen first day', () {
      expect(startOfWeek(tuesday, 0), DateTime(2026, 9, 13));
      expect(startOfWeek(tuesday, 1), DateTime(2026, 9, 14));
      expect(startOfWeek(tuesday, 6), DateTime(2026, 9, 12));
    });

    test('a day that already starts its week stays where it is', () {
      expect(startOfWeek(DateTime(2026, 9, 13), 0), DateTime(2026, 9, 13));
    });

    test('weeks run across a month end', () {
      expect(startOfWeek(DateTime(2026, 10, 1), 1), DateTime(2026, 9, 28));
    });

    test('days are counted on the calendar, either way', () {
      expect(daysBetween(DateTime(2026, 9, 28), DateTime(2026, 10, 5)), 7);
      expect(daysBetween(DateTime(2026, 10, 5), DateTime(2026, 9, 28)), -7);
      // The clock inside a day never adds or drops one.
      expect(
        daysBetween(DateTime(2026, 9, 15, 23), DateTime(2026, 9, 16, 1)),
        1,
      );
    });
  });
}
