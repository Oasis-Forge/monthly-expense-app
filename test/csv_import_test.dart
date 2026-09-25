import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/csv_export.dart';
import 'package:monthly_expense_app/models/csv_import.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';

import 'helpers.dart';

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

    test('comma wins a tie with another delimiter', () {
      // One comma, one semicolon: comma should win, so the semicolon stays
      // inside the second cell rather than becoming the separator.
      final table = parseCsv('date,amount;note\n2026-09-01,5;paid\n');

      expect(table.header, ['date', 'amount;note']);
      expect(table.rows.single, ['2026-09-01', '5;paid']);
    });

    test('a lone \\r (old Mac line endings) still separates rows', () {
      final table = parseCsv('date,amount\r2026-09-01,5\r');

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

    test('a column claimed by one field is not also given to another', () {
      // "To Account" loosely contains the word "account", but it must stay
      // toAccount's column alone, not double as the plain account column.
      final matched = matchColumns(['To Account']);

      expect(matched.keys, {ImportField.toAccount});
      expect(matched.containsKey(ImportField.account), isFalse);
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

    test('a short alias only matches whole words, not a substring of another '
        'word (IMP-3, IMP-6)', () {
      // "Counterparty" contains the letters "art", the type alias, only
      // as part of "party" -- it must not be read as the type column.
      final matched = matchColumns(['Date', 'Amount', 'Counterparty']);

      expect(matched.containsKey(ImportField.type), isFalse);
    });

    test('a bank statement "Value Dt" column is not guessed as the amount '
        '(IMP-3, IMP-6, IMP-5)', () {
      // The common Indian bank-statement layout: withdrawal and deposit
      // are separate columns, neither of which is a recognised amount
      // alias, and "Value Dt" reads as both the amount alias "value" and
      // the date alias "dt". Guessing either would plan nonsense (a date
      // read as a numeric amount, or a random column as the type); IMP-3
      // says an unconfident column is left out, not guessed at.
      final header = [
        'Date',
        'Narration',
        'Chq./Ref.No.',
        'Value Dt',
        'Withdrawal Amt.',
        'Deposit Amt.',
        'Closing Balance',
      ];

      final matched = matchColumns(header);

      expect(matched.containsKey(ImportField.amount), isFalse);
      expect(matched[ImportField.date], 0);
    });

    test('a compound word is matched by the alias it ends with, and camelCase '
        'is split before folding (IMP-3, IMP-6)', () {
      // DKB and Sparkasse (German banks) run the field name straight into a
      // longer compound word; ABN AMRO (Dutch) runs two English words
      // together in lower case; a CSV written by a spreadsheet may instead
      // camelCase the header. None of these are a whole-word match on their
      // own, but the date reads out of every one of them.
      final dkb = matchColumns([
        'Buchungsdatum',
        'Verwendungszweck',
        'Betrag (EUR)',
      ]);
      expect(dkb[ImportField.date], 0, reason: 'Buchungsdatum');
      expect(dkb[ImportField.amount], 2, reason: 'Betrag (EUR)');

      final sparkasse = matchColumns(['Valutadatum', 'Buchungstext', 'Betrag']);
      expect(sparkasse[ImportField.date], 0, reason: 'Valutadatum');

      final abnAmro = matchColumns([
        'transactiondate',
        'amount',
        'counterparty',
      ]);
      expect(abnAmro[ImportField.date], 0, reason: 'transactiondate');

      final camelCase = matchColumns(['TransactionDate', 'Amount']);
      expect(camelCase[ImportField.date], 0, reason: 'TransactionDate');
    });

    test('a CJK or Hangul alias of two characters is trusted as a whole '
        'word, unlike a short Latin alias (IMP-3, IMP-6)', () {
      // The 3-letter rule that keeps "art" from claiming "Counterparty"
      // makes no sense for scripts with no letter-by-letter fragments: a
      // two-character CJK or Hangul word is a whole word, not a fragment.
      final chinese = matchColumns(['日期', '金额(元)', '分类']);
      expect(chinese[ImportField.date], 0, reason: '日期');
      expect(chinese[ImportField.amount], 1, reason: '金额(元)');

      final japanese = matchColumns(['日付', '金額(円)', 'カテゴリ']);
      expect(japanese[ImportField.date], 0, reason: '日付');
      expect(japanese[ImportField.amount], 1, reason: '金額(円)');

      final korean = matchColumns(['날짜', '금액(원)', '카테고리']);
      expect(korean[ImportField.date], 0, reason: '날짜');
      expect(korean[ImportField.amount], 1, reason: '금액(원)');
    });

    test('an unspaced CJK, Hangul or Thai compound header still matches its '
        'alias inside it (IMP-3, IMP-6)', () {
      // Banks in these scripts write "transaction date" as one word with no
      // space for a whole-word match to find.
      final chinese = matchColumns(['交易日期', '交易金额', '分类']);
      expect(chinese[ImportField.date], 0, reason: '交易日期');
      expect(chinese[ImportField.amount], 1, reason: '交易金额');

      final japanese = matchColumns(['取引日付', '取引金額']);
      expect(japanese[ImportField.date], 0, reason: '取引日付');
      expect(japanese[ImportField.amount], 1, reason: '取引金額');

      final korean = matchColumns(['거래날짜', '거래금액']);
      expect(korean[ImportField.date], 0, reason: '거래날짜');
      expect(korean[ImportField.amount], 1, reason: '거래금액');

      final thai = matchColumns(['วันที่ทำรายการ', 'จำนวนเงินบาท']);
      expect(thai[ImportField.date], 0, reason: 'วันที่ทำรายการ');
      expect(thai[ImportField.amount], 1, reason: 'จำนวนเงินบาท');
    });

    test('an alias with accents or vowel signs matches a header that folding '
        'stripped of them (IMP-3, IMP-6)', () {
      final vietnamese = matchColumns(['Ngày giao dịch', 'Số tiền']);
      expect(vietnamese[ImportField.date], 0, reason: 'Ngày giao dịch');
      expect(vietnamese[ImportField.amount], 1, reason: 'Số tiền');

      final greek = matchColumns(['Ημερομηνία', 'Ποσό']);
      expect(greek[ImportField.date], 0, reason: 'Ημερομηνία');
      expect(greek[ImportField.amount], 1, reason: 'Ποσό');

      final hindi = matchColumns(['दिनांक', 'राशि']);
      expect(hindi[ImportField.date], 0, reason: 'दिनांक');
      expect(hindi[ImportField.amount], 1, reason: 'राशि');

      final thai = matchColumns(['วันที่', 'จำนวนเงิน']);
      expect(thai[ImportField.date], 0, reason: 'วันที่');
      expect(thai[ImportField.amount], 1, reason: 'จำนวนเงิน');
    });

    test(
      'the cross-field veto only blocks the amount/date collision, not '
      'every column that also names another field loosely (IMP-3, IMP-6)',
      () {
        // Spendee names its category column "Category name" and Mint names
        // its account column "Account Name": the generic title alias "name"
        // must not veto either just because it also appears in the header.
        final spendee = matchColumns([
          'Date',
          'Wallet',
          'Type',
          'Category name',
          'Amount',
        ]);
        expect(spendee[ImportField.category], 3, reason: 'Category name');
        expect(spendee[ImportField.amount], 4, reason: 'Amount');

        final mint = matchColumns(['Date', 'Account Name', 'Amount']);
        expect(mint[ImportField.account], 1, reason: 'Account Name');

        // "Tip Amount" also contains the type alias "tip", but the veto is
        // for the amount/date collision alone ("Value Dt"), not every field.
        final tip = matchColumns(['Tip Amount', 'Date']);
        expect(tip[ImportField.amount], 0, reason: 'Tip Amount');

        // The amount/date collision itself must still be refused.
        final valueDt = matchColumns(['Value Dt', 'Narration']);
        expect(valueDt.containsKey(ImportField.amount), isFalse);
      },
    );
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

    test('a single stray bracket is not a negative on its own', () {
      // Only a matched pair of brackets means a negative (IMP-6); one lone
      // ")" left over from a currency symbol must not flip the sign.
      expect(read('12.50)').isNegative, isFalse);
      expect(read('(12.50').isNegative, isFalse);
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

    test('the same date, amount, and title but a different type is not a '
        'repeat (IMP-8)', () {
      final expenseIdentity = importIdentity(
        date: DateTime(2026, 9, 1),
        amount: const Money(12500),
        type: ImportedType.expense,
        title: 'Lunch',
      );
      final result = plan(
        'date,type,amount,title\n2026-09-01,income,12.50,Lunch\n',
        existing: {expenseIdentity},
      );

      expect(result.importCount, 1);
      expect(result.rows.single.skipped, isNull);
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
      // 70 is the cutoff itself: it must still read as 1970, not 2070.
      expect(parseImportedDate('01/02/70'), DateTime(1970, 2, 1));
    });

    test('a date that never happened is not a date', () {
      expect(parseImportedDate('2026-02-31'), isNull);
      expect(parseImportedDate('2026-13-01'), isNull);
      expect(parseImportedDate(''), isNull);
      expect(parseImportedDate('sometime'), isNull);
    });
  });

  group('importing a plan (IMP-1, IMP-6, IMP-7)', () {
    const cash = Account.cashId;
    final today = DateTime(2026, 9, 15, 10);

    Future<TransactionProvider> loaded(FakeDB db) async {
      final provider = TransactionProvider(db: db, clock: () => today);
      await provider.load();
      return provider;
    }

    FakeDB twoAccounts() =>
        FakeDB(accounts: [testAccount(cash), testAccount('acc-bank')]);

    ImportPlan planOf(String csv, {Map<String, String> known = const {}}) =>
        planImport(
          table: parseCsv(csv),
          categoryIdFor: (name) => known[name],
          accountIdFor: (name) => known[name],
        );

    test('writes what the plan said, stamped like any other record', () async {
      final db = FakeDB();
      final provider = await loaded(db);

      final written = await provider.applyImport(
        planOf(
          'date,amount,type,title,note\n'
          '2026-09-01,12.50,expense,Coffee,black\n'
          '2026-09-02,900,income,Pay,\n',
        ),
      );

      expect(written, 2);
      expect(db.rows, hasLength(2));
      final coffee = provider.transactions.firstWhere(
        (tx) => tx.title == 'Coffee',
      );
      expect(coffee.amount, const Money(12500));
      expect(coffee.type, TransactionType.expense);
      expect(coffee.date, DateTime(2026, 9, 1));
      expect(coffee.note, 'black');
      expect(coffee.createdAt, today.toUtc());
      expect(coffee.updatedAt, today.toUtc());
      expect(coffee.deletedAt, isNull);
      expect({for (final tx in provider.transactions) tx.id}, hasLength(2));
    });

    test('a name the app has not got becomes Other and the default '
        'account (IMP-7)', () async {
      final provider = await loaded(FakeDB());

      await provider.applyImport(
        planOf(
          'date,amount,type,category,account\n2026-09-01,5,expense,'
          'Yachts,Offshore\n',
        ),
      );

      final tx = provider.transactions.single;
      expect(provider.categoryById(tx.categoryId)!.defaultKey, 'other');
      expect(tx.accountId, cash);
      expect(provider.categories.where((c) => c.name == 'Yachts'), isEmpty);
      expect(provider.accounts.where((a) => a.name == 'Offshore'), isEmpty);
    });

    test('the names the user mapped on the preview are used', () async {
      final db = twoAccounts();
      final provider = await loaded(db);

      await provider.applyImport(
        planOf(
          'date,amount,type,category,account\n2026-09-01,5,expense,'
          'Eating out,Savings\n',
        ),
        categoryIds: {'Eating out': 'cat-food'},
        accountIds: {'Savings': 'acc-bank'},
      );

      final tx = provider.transactions.single;
      expect(tx.categoryId, 'cat-food');
      expect(tx.accountId, 'acc-bank');
    });

    test('a category of the wrong type falls back to Other of the right '
        'one', () async {
      final provider = await loaded(FakeDB());

      await provider.applyImport(
        planOf('date,amount,type,category\n2026-09-01,900,income,Rent\n'),
        categoryIds: {'Rent': 'cat-rent'},
      );

      final tx = provider.transactions.single;
      expect(tx.type, TransactionType.income);
      expect(tx.categoryId, 'cat-income-other');
    });

    test('a transfer row becomes a transfer between both accounts', () async {
      final db = twoAccounts();
      final provider = await loaded(db);

      final written = await provider.applyImport(
        planOf(
          'date,amount,type,account,to account,title,note\n'
          '2026-09-01,100,transfer,Wallet,Savings,Top up,by card\n',
        ),
        accountIds: {'Wallet': cash, 'Savings': 'acc-bank'},
      );

      expect(written, 1);
      expect(provider.transactions, isEmpty);
      final transfer = provider.transfers.single;
      expect(transfer.fromAccountId, cash);
      expect(transfer.toAccountId, 'acc-bank');
      expect(transfer.amount, const Money(100000));
      // A transfer has no title of its own, so both parts go in the note.
      expect(transfer.note, 'Top up — by card');
    });

    test('a transfer with both sides on one account is not written', () async {
      final provider = await loaded(FakeDB());

      final written = await provider.applyImport(
        planOf(
          'date,amount,type,account,to account\n'
          '2026-09-01,100,transfer,Wallet,Savings\n'
          '2026-09-02,7,expense,Wallet,\n',
        ),
      );

      expect(written, 1);
      expect(provider.transfers, isEmpty);
      expect(provider.transactions.single.amount, const Money(7000));
    });

    test('a failed write leaves nothing behind', () async {
      final db = FakeDB()..failWrites = true;
      final provider = await loaded(db);

      await expectLater(
        provider.applyImport(
          planOf('date,amount,type\n2026-09-01,5,expense\n'),
        ),
        throwsStateError,
      );
      expect(provider.transactions, isEmpty);
      expect(db.rows, isEmpty);
    });

    test('a plan with nothing to import writes nothing', () async {
      final db = FakeDB();
      final provider = await loaded(db);
      var notified = 0;
      provider.addListener(() => notified++);

      final written = await provider.applyImport(
        planOf('date,amount\nsometime,nothing\n'),
      );

      expect(written, 0);
      expect(db.rows, isEmpty);
      expect(notified, 0);
    });

    test('with no Other category, the first of its kind is used', () async {
      final provider = await loaded(
        FakeDB(
          categories: [
            for (final category in testCategories())
              if (category.defaultKey != 'other') category,
          ],
        ),
      );

      await provider.applyImport(
        planOf('date,amount,type,category\n2026-09-01,5,expense,Yachts\n'),
      );

      expect(provider.transactions.single.categoryId, 'cat-food');
      expect(provider.otherCategoryId(TransactionType.income), 'cat-salary');
    });

    test('with no categories at all, nothing can be imported', () async {
      final provider = await loaded(FakeDB(categories: []));

      final written = await provider.applyImport(
        planOf('date,amount,type\n2026-09-01,5,expense\n'),
      );

      expect(written, 0);
      expect(provider.otherCategoryId(TransactionType.expense), isNull);
    });

    test('with no account at all, nothing can be imported', () async {
      final provider = await loaded(FakeDB(accounts: []));

      final written = await provider.applyImport(
        planOf('date,amount,type\n2026-09-01,5,expense\n'),
      );

      expect(written, 0);
      expect(provider.transactions, isEmpty);
    });
  });

  group('what the app already has (IMP-8)', () {
    final today = DateTime(2026, 9, 15, 10);

    Future<TransactionProvider> loaded(FakeDB db) async {
      final provider = TransactionProvider(db: db, clock: () => today);
      await provider.load();
      return provider;
    }

    test('identities cover transactions and transfers', () async {
      final provider = await loaded(
        FakeDB(
          transactions: [
            testTx(
              'a',
              TransactionType.expense,
              12.5,
              DateTime(2026, 9, 1),
              title: 'Coffee',
            ),
          ],
          transfers: [
            testTransfer(
              't',
              Account.cashId,
              'acc-bank',
              100,
              DateTime(2026, 9, 2),
            ),
          ],
          accounts: [testAccount(Account.cashId), testAccount('acc-bank')],
        ),
      );

      expect(provider.importIdentities, {
        importIdentity(
          date: DateTime(2026, 9, 1),
          amount: const Money(12500),
          type: ImportedType.expense,
          title: 'Coffee',
        ),
        importIdentity(
          date: DateTime(2026, 9, 2),
          amount: const Money(100000),
          type: ImportedType.transfer,
          title: '',
        ),
      });
    });

    test('importing the same file twice adds it once', () async {
      final db = FakeDB();
      final provider = await loaded(db);
      const csv =
          'date,amount,type,title\n'
          '2026-09-01,12.50,expense,Coffee\n'
          '2026-09-02,900,income,Pay\n';

      await provider.applyImport(
        planImport(
          table: parseCsv(csv),
          existingIdentities: provider.importIdentities,
        ),
      );
      final again = planImport(
        table: parseCsv(csv),
        existingIdentities: provider.importIdentities,
      );

      expect(again.importCount, 0);
      expect(again.skipCounts[SkipReason.alreadyThere], 2);
      expect(await provider.applyImport(again), 0);
      expect(provider.transactions, hasLength(2));
    });

    test('a trashed row can be imported again', () async {
      final db = FakeDB(
        transactions: [
          testTx(
            'a',
            TransactionType.expense,
            5,
            DateTime(2026, 9, 1),
            title: 'Coffee',
          ),
        ],
      );
      final provider = await loaded(db);
      await provider.deleteTransaction('a');

      expect(provider.importIdentities, isEmpty);
    });
  });

  group('this app\'s own export reads back exactly (IMP-2)', () {
    for (final amount in const [12345, 375, 2125, 1234567]) {
      test('${Money(amount).toInputString()} at three decimals', () {
        final tx = testTx(
          't1',
          TransactionType.expense,
          0,
          DateTime(2026, 9, 1),
        ).copyWith(amount: Money(amount));
        final csv = buildCsv(
          transactions: [tx],
          currencyCode: 'KWD',
          categoryName: (_) => 'Food',
          accountName: (_) => 'Cash',
        );

        final plan = planImport(
          table: parseCsv(csv),
          categoryIdFor: (_) => 'cat-food',
          accountIdFor: (_) => Account.cashId,
        );

        expect(plan.rows.single.amount, Money(amount));
      });
    }

    test('another file\'s "1,234" is still grouped thousands', () {
      final plan = planImport(
        table: parseCsv('date,amount\n2026-09-01,"1,234"\n'),
        categoryIdFor: (_) => 'cat-food',
        accountIdFor: (_) => Account.cashId,
      );

      expect(plan.rows.single.amount, const Money(1234000));
    });
  });
}
