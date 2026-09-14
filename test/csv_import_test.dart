import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/csv_export.dart';
import 'package:monthly_expense_app/models/csv_import.dart';
import 'package:monthly_expense_app/models/money.dart';

void main() {
  group('splitting a CSV (IMP-3)', () {
    test('reads a header and its rows', () {
      final table = parseCsv('date,amount\n2026-09-01,12.50\n2026-09-02,3\n');

      expect(table.header, ['date', 'amount']);
      expect(table.rows, [
        ['2026-09-01', '12.50'],
        ['2026-09-02', '3'],
      ]);
    });

    test('a quoted cell keeps its commas, quotes, and newlines', () {
      final table = parseCsv(
        'title,note\n'
        '"Coffee, black","He said ""thanks"""\n'
        '"Two\nlines",x\n',
      );

      expect(table.rows[0], ['Coffee, black', 'He said "thanks"']);
      expect(table.rows[1], ['Two\nlines', 'x']);
    });

    test('a byte order mark and CRLF endings are not part of the data', () {
      final table = parseCsv('﻿date,amount\r\n2026-09-01,5\r\n');

      expect(table.header, ['date', 'amount']);
      expect(table.rows.single, ['2026-09-01', '5']);
    });

    test('semicolons and tabs work where a locale uses them', () {
      for (final delimiter in [';', '\t']) {
        final table = parseCsv(
          'date${delimiter}amount\n2026-09-01${delimiter}12,50\n',
        );
        expect(table.header, ['date', 'amount'], reason: delimiter);
        expect(table.rows.single, ['2026-09-01', '12,50'], reason: delimiter);
      }
    });

    test('a comma inside quotes does not make it the separator', () {
      final table = parseCsv('title;amount\n"Coffee, black";5\n');

      expect(table.header, ['title', 'amount']);
      expect(table.rows.single, ['Coffee, black', '5']);
    });

    test('blank lines and a file of nothing are not rows', () {
      expect(parseCsv('').isEmpty, isTrue);
      expect(parseCsv('   \n\n').isEmpty, isTrue);
      expect(parseCsv('date,amount\n\n2026-09-01,5\n,,\n').rows, hasLength(1));
    });

    test('a last row without a trailing newline is still a row', () {
      expect(parseCsv('date,amount\n2026-09-01,5').rows, hasLength(1));
    });
  });

  group('matching columns to fields (IMP-3)', () {
    test('this app\'s own export maps completely (IMP-2)', () {
      final matched = matchColumns(csvColumns);

      expect(matched[ImportField.date], 0);
      expect(matched[ImportField.type], 1);
      expect(matched[ImportField.amount], 2);
      expect(matched[ImportField.category], 4);
      expect(matched[ImportField.account], 5);
      expect(matched[ImportField.toAccount], 6);
      expect(matched[ImportField.title], 7);
      expect(matched[ImportField.note], 8);
    });

    test('case, accents, and punctuation between words are ignored', () {
      final matched = matchColumns([
        'DATE',
        'To-Account',
        'Catégorie',
        'transaction_type',
      ]);

      expect(matched[ImportField.date], 0);
      expect(matched[ImportField.toAccount], 1);
      expect(matched[ImportField.category], 2);
      expect(matched[ImportField.type], 3);
    });

    test('a header in another of the app\'s languages is understood', () {
      final turkish = matchColumns(['Tarih', 'Tutar', 'Kategori', 'Hesap']);
      expect(turkish.keys, {
        ImportField.date,
        ImportField.amount,
        ImportField.category,
        ImportField.account,
      });

      final arabic = matchColumns(['التاريخ', 'المبلغ', 'الفئة', 'ملاحظة']);
      expect(arabic.keys, {
        ImportField.date,
        ImportField.amount,
        ImportField.category,
        ImportField.note,
      });

      final german = matchColumns(['Datum', 'Betrag', 'Kategorie', 'Konto']);
      expect(german.keys, {
        ImportField.date,
        ImportField.amount,
        ImportField.category,
        ImportField.account,
      });
    });

    test('the usual other names for a field are understood', () {
      final matched = matchColumns([
        'Posting Date',
        'Payee',
        'Value',
        'Memo',
        'Wallet',
      ]);

      expect(matched[ImportField.date], 0);
      expect(matched[ImportField.title], 1);
      expect(matched[ImportField.amount], 2);
      expect(matched[ImportField.note], 3);
      expect(matched[ImportField.account], 4);
    });

    test('"to account" is not swallowed by "account"', () {
      final matched = matchColumns(['Account', 'To Account']);

      expect(matched[ImportField.account], 0);
      expect(matched[ImportField.toAccount], 1);
    });

    test('a column matches only one field', () {
      final matched = matchColumns(['note', 'notes']);

      expect(matched[ImportField.note], 0);
      expect(matched.values.toSet(), hasLength(matched.length));
    });

    test('a header it cannot place is left out, not guessed', () {
      final matched = matchColumns(['date', 'amount', 'xyzzy', '']);

      expect(matched.keys, {ImportField.date, ImportField.amount});
    });
  });

  group('reading a type (IMP-3)', () {
    test('the words each language uses', () {
      for (final word in ['Income', 'CREDIT', 'gelir', 'Ingresos', 'دخل']) {
        expect(parseImportedType(word), ImportedType.income, reason: word);
      }
      for (final word in ['Expense', 'debit', 'Gider', 'Dépense', 'Ausgabe']) {
        expect(parseImportedType(word), ImportedType.expense, reason: word);
      }
      expect(parseImportedType('Transfer'), ImportedType.transfer);
    });

    test('a word inside a longer cell still counts', () {
      expect(parseImportedType('Expense (food)'), ImportedType.expense);
    });

    test('anything else says nothing', () {
      expect(parseImportedType(''), isNull);
      expect(parseImportedType('12.50'), isNull);
      expect(parseImportedType('groceries'), isNull);
    });
  });

  group('reading an amount (IMP-6)', () {
    ImportedAmount read(String value) => parseImportedAmount(value)!;

    test('plain decimals, with or without a currency around them', () {
      expect(read('12.50').amount, const Money(12500));
      expect(read(r'$12.50').amount, const Money(12500));
      expect(read('12,50 €').amount, const Money(12500));
      expect(read('  7 ').amount, const Money(7000));
    });

    test('grouped thousands, either convention', () {
      expect(read('1,234.56').amount, const Money(1234560));
      expect(read('1.234,56').amount, const Money(1234560));
      expect(read('1 234,56').amount, const Money(1234560));
      expect(read('1,234').amount, const Money(1234000));
    });

    test('a negative is reported, not folded into the amount', () {
      expect(read('-12.50').amount, const Money(12500));
      expect(read('-12.50').isNegative, isTrue);
      expect(read('(12.50)').isNegative, isTrue);
      expect(read('12.50').isNegative, isFalse);
    });

    test('a cell with no number in it is not an amount', () {
      expect(parseImportedAmount(''), isNull);
      expect(parseImportedAmount('n/a'), isNull);
      expect(parseImportedAmount('-'), isNull);
    });
  });

  group('planning an import (IMP-4, IMP-5, IMP-7, IMP-8)', () {
    ImportPlan plan(
      String csv, {
      Set<String> existing = const {},
      Set<String> categories = const {'food', 'salary'},
      Set<String> accounts = const {'cash', 'bank'},
      Map<ImportField, int>? columns,
    }) => planImport(
      table: parseCsv(csv),
      columns: columns,
      categoryIdFor: (name) =>
          categories.contains(name.toLowerCase()) ? 'cat-$name' : null,
      accountIdFor: (name) =>
          accounts.contains(name.toLowerCase()) ? 'acc-$name' : null,
      existingIdentities: existing,
    );

    test('a readable file plans every row', () {
      final result = plan(
        'date,type,amount,category,account,title\n'
        '2026-09-01,expense,12.50,food,cash,Lunch\n'
        '2026-09-02,income,2000,salary,bank,Pay\n',
      );

      expect(result.canImport, isTrue);
      expect(result.importCount, 2);
      expect(result.skipCount, 0);
      final lunch = result.rows.first;
      expect(lunch.line, 2);
      expect(lunch.date, DateTime(2026, 9, 1));
      expect(lunch.amount, const Money(12500));
      expect(lunch.type, ImportedType.expense);
      expect(lunch.title, 'Lunch');
    });

    test('a file with no date or no amount column is refused (IMP-4)', () {
      expect(
        plan('amount,title\n12.50,Lunch\n').refusal,
        ImportRefusal.noDateColumn,
      );
      expect(
        plan('date,title\n2026-09-01,Lunch\n').refusal,
        ImportRefusal.noAmountColumn,
      );
      expect(plan('').refusal, ImportRefusal.empty);
      expect(plan('date,amount\n').refusal, ImportRefusal.empty);
    });

    test('columns found but no row usable is also a refusal', () {
      final result = plan('date,amount\nsometime,n/a\nnever,-\n');

      expect(result.canImport, isFalse);
      expect(result.refusal, ImportRefusal.noUsableRows);
      // The rows survive the refusal, so the preview can say why each failed
      // rather than only that the file was no good (IMP-4).
      expect(result.rows, hasLength(2));
      expect(result.skipCounts[SkipReason.unreadableDate], 2);
    });

    test('a row the app cannot read is skipped and counted, not guessed', () {
      final result = plan(
        'date,amount,title\n'
        '2026-09-01,12.50,Good\n'
        'sometime,5,No date\n'
        '2026-09-02,n/a,No amount\n'
        '2026-09-03,0,Nothing\n',
      );

      expect(result.importCount, 1);
      expect(result.skipCounts, {
        SkipReason.unreadableDate: 1,
        SkipReason.unreadableAmount: 1,
        SkipReason.zeroAmount: 1,
      });
      // The skipped rows are still listed, so the preview can show them.
      expect(result.rows, hasLength(4));
      expect(result.rows[1].skipped, SkipReason.unreadableDate);
    });

    test('a row already in the app is skipped (IMP-8)', () {
      final already = importIdentity(
        date: DateTime(2026, 9, 1),
        amount: const Money(12500),
        type: ImportedType.expense,
        title: 'Lunch',
      );
      final result = plan(
        'date,type,amount,title\n'
        '2026-09-01,expense,12.50,Lunch\n'
        '2026-09-02,expense,4,Coffee\n',
        existing: {already},
      );

      expect(result.importCount, 1);
      expect(result.rows.first.skipped, SkipReason.alreadyThere);
      expect(result.importing.single.title, 'Coffee');
    });

    test('a file that lists the same row twice imports it once', () {
      final result = plan(
        'date,type,amount,title\n'
        '2026-09-01,expense,12.50,Lunch\n'
        '2026-09-01,expense,12.50,Lunch\n',
      );

      expect(result.importCount, 1);
      expect(result.skipCounts[SkipReason.alreadyThere], 1);
    });

    test('names the app does not have come back to be mapped (IMP-7)', () {
      final result = plan(
        'date,amount,category,account\n'
        '2026-09-01,12.50,Coffee,Revolut\n'
        '2026-09-02,3,Coffee,cash\n'
        '2026-09-03,4,food,Revolut\n',
      );

      // Each unknown name once, in the order it first appears.
      expect(result.unknownCategories, ['Coffee']);
      expect(result.unknownAccounts, ['Revolut']);
    });

    test('a skipped row does not ask for a mapping', () {
      final result = plan(
        'date,amount,category\n'
        '2026-09-01,12.50,food\n'
        'sometime,5,Coffee\n',
      );

      expect(result.unknownCategories, isEmpty);
    });

    group('working out the type', () {
      test('a type column is believed', () {
        final result = plan('date,type,amount\n2026-09-01,income,12\n');
        expect(result.rows.single.type, ImportedType.income);
      });

      test('without one, a minus sign means it went out', () {
        final out = plan('date,amount\n2026-09-01,-12.50\n');
        expect(out.rows.single.type, ImportedType.expense);
        expect(out.rows.single.amount, const Money(12500));

        final into = plan('date,amount\n2026-09-01,2000\n');
        expect(into.rows.single.type, ImportedType.income);
      });

      test('two accounts and no type column reads as a transfer', () {
        final result = plan(
          'date,amount,account,to account\n2026-09-01,50,cash,bank\n',
        );
        expect(result.rows.single.type, ImportedType.transfer);
      });

      test('a transfer missing an account is skipped (ACC-3)', () {
        final result = plan(
          'date,type,amount,account,to account\n'
          '2026-09-01,transfer,50,cash,\n',
        );
        expect(result.rows.single.skipped, SkipReason.incompleteTransfer);
      });
    });

    test('the mapping can be corrected before planning (IMP-3)', () {
      // A file whose headers say nothing useful.
      const csv = 'a,b,c\n2026-09-01,12.50,Lunch\n';
      expect(plan(csv).refusal, ImportRefusal.noDateColumn);

      final corrected = plan(
        csv,
        columns: {
          ImportField.date: 0,
          ImportField.amount: 1,
          ImportField.title: 2,
        },
      );
      expect(corrected.canImport, isTrue);
      expect(corrected.importing.single.title, 'Lunch');
    });
  });

  group('reading a date (IMP-6)', () {
    test('ISO, whatever it separates with', () {
      for (final text in ['2026-09-14', '2026/09/14', '2026.09.14']) {
        expect(parseImportedDate(text), DateTime(2026, 9, 14), reason: text);
      }
    });

    test('a time after the date is not part of it (DATE-1)', () {
      expect(parseImportedDate('2026-09-14 18:30'), DateTime(2026, 9, 14));
      expect(parseImportedDate('2026-09-14T18:30:00Z'), DateTime(2026, 9, 14));
    });

    test('day-first and month-first, as the user chose', () {
      expect(parseImportedDate('03/04/2026'), DateTime(2026, 4, 3));
      expect(
        parseImportedDate('03/04/2026', dayFirst: false),
        DateTime(2026, 3, 4),
      );
    });

    test('a number that cannot be a month settles the order itself', () {
      expect(parseImportedDate('25/12/2026'), DateTime(2026, 12, 25));
      expect(
        parseImportedDate('25/12/2026', dayFirst: false),
        DateTime(2026, 12, 25),
      );
    });

    test('two-digit years', () {
      expect(parseImportedDate('01/02/26'), DateTime(2026, 2, 1));
      expect(parseImportedDate('01/02/99'), DateTime(1999, 2, 1));
    });

    test('a date that never happened is not a date', () {
      expect(parseImportedDate('2026-02-31'), isNull);
      expect(parseImportedDate('2026-13-01'), isNull);
      expect(parseImportedDate(''), isNull);
      expect(parseImportedDate('sometime'), isNull);
    });
  });
}
