import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/form_fields.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  final amountField = find.widgetWithText(TextFormField, 'Amount');

  // Fixed rather than DateTime.now(): a run that happens to cross midnight
  // between opening the form and reading this back must not flip a
  // day-of comparison against the real clock (test-quality#10).
  final today = DateTime(2026, 9, 15, 10);

  setUp(() async {
    fake = FakeDB();
    provider = TransactionProvider(db: fake, clock: () => today);
    await provider.load();
    settings = await testSettings();
  });

  /// Opens the add/edit screen from a placeholder page on a phone screen.
  Future<void> open(
    WidgetTester tester, {
    ExpenseTransaction? editing,
    Note? recordingNote,
    TransactionType? startAs,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    editing: editing,
                    recordingNote: recordingNote,
                    startAs: startAs,
                    clock: () => today,
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> enterAmount(WidgetTester tester, String amount) async {
    await revealInForm(tester, amountField);
    await tester.enterText(amountField, amount);
  }

  Future<void> tapInForm(WidgetTester tester, Finder finder) async {
    await revealInForm(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapButton(WidgetTester tester, String label) =>
      tapInForm(tester, find.widgetWithText(FilledButton, label));

  /// Expects exactly one [text] somewhere in the form.
  Future<void> expectInForm(WidgetTester tester, String text) async {
    await revealInForm(tester, find.text(text));
    expect(find.text(text), findsOneWidget);
  }

  /// Stores a lunch expense in [fake] and reloads [provider].
  Future<ExpenseTransaction> addLunch() async {
    final lunch = testTx(
      'a',
      TransactionType.expense,
      12.5,
      DateTime(2026, 9, 13),
      note: 'with team',
    );
    fake.rows.add(lunch);
    await provider.load();
    return lunch;
  }

  DateTime dayOf(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);

  testWidgets('saving without a title adds the transaction and closes', (
    tester,
  ) async {
    await open(tester);
    await enterAmount(tester, '12.50');
    await tapButton(tester, 'Add Transaction');

    final saved = provider.transactions.single;
    expect(saved.amount, const Money(12500));
    expect(saved.title, isNull);
    expect(saved.categoryId, 'cat-food');
    expect(saved.accountId, Account.cashId);
    expect(find.byType(AddTransactionScreen), findsNothing);
  });

  testWidgets(
    "the amount field's symbol side matches the locale's display side "
    '(CUR-5, LANG-5, pr61#11)',
    (tester) async {
      // English (USD): intl leads with the symbol.
      await open(tester);
      final enField = tester.widget<TextField>(
        find.descendant(of: amountField, matching: find.byType(TextField)),
      );
      expect(enField.decoration?.prefixText, contains('\$'));
      expect(enField.decoration?.suffixText, isNull);
    },
  );

  testWidgets(
    "the amount field's symbol side matches the locale's display side, "
    'in German (CUR-5, LANG-5, pr61#11)',
    (tester) async {
      // German writes the symbol after the figures ('12,50 €'), unlike
      // English; the field used to lead with it regardless. The label is
      // German too ('Betrag'), so find the field by its currency affix
      // rather than by the English label text.
      settings = await testSettings({'language': 'de'});
      await open(tester);
      final deField = tester
          .widgetList<TextField>(find.byType(TextField))
          .firstWhere(
            (f) =>
                f.decoration?.prefixText != null ||
                f.decoration?.suffixText != null,
          );
      expect(deField.decoration?.prefixText, isNull);
      expect(deField.decoration?.suffixText, contains('\$'));
    },
  );

  /// The amount field, whichever affix carries the currency symbol — the
  /// built [TextField], not the [TextFormField] wrapping it, which carries
  /// no `decoration` of its own.
  Finder rtlAmountField() => find.byWidgetPredicate(
    (widget) =>
        widget is TextField &&
        (widget.decoration?.prefixText != null ||
            widget.decoration?.suffixText != null),
  );

  for (final language in ['ar', 'ur']) {
    testWidgets(
      "the amount field's symbol renders on the left in $language, not "
      "wherever InputDecorator's start/end happens to fall in a "
      'right-to-left layout (CUR-5, LANG-5, pr61#11)',
      (tester) async {
        settings = await testSettings({'language': language});
        await open(tester);

        final field = tester.widget<TextField>(rtlAmountField());
        final symbol =
            field.decoration!.prefixText ?? field.decoration!.suffixText!;
        // Urdu's own pattern leads with the symbol, so before the fix this
        // became prefixText — which InputDecorator places at the field's
        // *start*, the right edge in this right-to-left layout.
        await tester.enterText(rtlAmountField(), '12.5');
        await tester.pump();

        final symbolX = tester.getCenter(find.text(symbol)).dx;
        final inputX = tester.getCenter(find.text('12.5')).dx;
        expect(symbolX, lessThan(inputX));
      },
    );
  }

  testWidgets('the keypad adds up amounts and saves the result (ADD-2)', (
    tester,
  ) async {
    await open(tester);
    expect(find.byType(AmountKeypad), findsOneWidget);

    for (final key in ['1', '2', '.', '5', '+', '3']) {
      await tester.tap(find.widgetWithText(TextButton, key));
    }
    await tester.tap(find.byTooltip('Backspace'));
    await tester.tap(find.widgetWithText(TextButton, '4'));
    await tester.pump();
    expect(find.text('= \$16.50'), findsOneWidget);

    await tapButton(tester, 'Add Transaction');

    expect(provider.transactions.single.amount, const Money(16500));
  });

  testWidgets('hiding the keypad keeps the amount', (tester) async {
    await open(tester);
    await tester.tap(find.widgetWithText(TextButton, '8'));
    await tester.tap(find.byTooltip('Hide keypad'));
    await tester.pumpAndSettle();

    expect(find.byType(AmountKeypad), findsNothing);
    expect(tester.widget<TextFormField>(amountField).controller!.text, '8');
  });

  testWidgets('switching to income picks an income category', (tester) async {
    await open(tester);
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    await expectInForm(tester, '💼 Salary');

    await enterAmount(tester, '1000');
    await tapButton(tester, 'Add Transaction');

    final saved = provider.transactions.single;
    expect(saved.type, TransactionType.income);
    expect(saved.categoryId, 'cat-salary');
  });

  testWidgets("the widget's Add income button opens on income (WID-3)", (
    tester,
  ) async {
    await open(tester, startAs: TransactionType.income);
    // Its category came with it, so ADD-3 still applies (WID-3).
    await expectInForm(tester, '💼 Salary');

    await enterAmount(tester, '1000');
    await tapButton(tester, 'Add Transaction');

    expect(provider.transactions.single.type, TransactionType.income);
  });

  testWidgets(
    'save & add another keeps the choices, date, and account; clears the '
    'amount, title, and note; and focuses the amount (ADD-4)',
    (tester) async {
      fake = FakeDB(
        accounts: [testAccount(Account.cashId), testAccount('bank')],
      );
      provider = TransactionProvider(db: fake);
      await provider.load();

      await open(tester);
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      await tapInForm(tester, find.byTooltip('Previous day'));

      final accountDropdown = find.byType(DropdownButtonFormField<String>).last;
      await tapInForm(tester, accountDropdown);
      await tester.tap(find.text('bank').last);
      await tester.pumpAndSettle();

      final titleField = find.widgetWithText(TextFormField, 'Title (optional)');
      await revealInForm(tester, titleField);
      await tester.enterText(titleField, 'Groceries');
      final noteField = find.widgetWithText(TextFormField, 'Note (optional)');
      await revealInForm(tester, noteField);
      await tester.enterText(noteField, 'weekly run');
      await enterAmount(tester, '100');

      await tapInForm(
        tester,
        find.widgetWithText(OutlinedButton, 'Save & add another'),
      );

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.text('Transaction added'), findsOneWidget);
      // ADD-4: the amount is refocused, which docks the keypad back in.
      expect(find.byType(AmountKeypad), findsOneWidget);
      await revealInForm(tester, amountField);
      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        isEmpty,
      );
      await revealInForm(tester, titleField);
      expect(
        tester.widget<TextFormField>(titleField).controller!.text,
        isEmpty,
      );
      await revealInForm(tester, noteField);
      expect(tester.widget<TextFormField>(noteField).controller!.text, isEmpty);
      await expectInForm(tester, 'bank');

      await enterAmount(tester, '50');
      await tapButton(tester, 'Add Transaction');

      expect(provider.transactions, hasLength(2));
      final yesterday = dayOf(DateTime.now().subtract(const Duration(days: 1)));
      expect(
        {for (final t in provider.transactions) dayOf(t.date)},
        {yesterday},
      );
      expect({for (final t in provider.transactions) t.accountId}, {'bank'});
      expect(
        {for (final t in provider.transactions) (t.type, t.categoryId)},
        {(TransactionType.income, 'cat-salary')},
      );
      final first = provider.transactions.firstWhere(
        (t) => t.amount == const Money(100000),
      );
      expect(first.title, 'Groceries');
      expect(first.note, 'weekly run');
      final second = provider.transactions.firstWhere(
        (t) => t.amount == const Money(50000),
      );
      expect(second.title, isNull);
      expect(second.note, isNull);
    },
  );

  testWidgets('two saves through the form get distinct UUID v4 IDs (REC-2)', (
    tester,
  ) async {
    await open(tester);
    await enterAmount(tester, '10');
    await tapInForm(
      tester,
      find.widgetWithText(OutlinedButton, 'Save & add another'),
    );
    await enterAmount(tester, '20');
    await tapButton(tester, 'Add Transaction');

    expect(provider.transactions, hasLength(2));
    final ids = provider.transactions.map((t) => t.id).toList();
    expect(
      ids.toSet(),
      hasLength(2),
      reason: 'record IDs must not collide across saves (REC-2, BAK-3)',
    );
    for (final id in ids) {
      expect(uuidV4.hasMatch(id), isTrue, reason: '$id is not a UUID v4');
    }
  });

  testWidgets('recent categories are one tap away (ADD-5)', (tester) async {
    fake.rows.addAll([
      testTx(
        'r',
        TransactionType.expense,
        900,
        DateTime(2026, 9, 1),
        categoryId: 'cat-rent',
      ).copyWith(createdAt: DateTime.utc(2026, 9, 1)),
      testTx(
        'o',
        TransactionType.expense,
        3,
        DateTime(2026, 9, 2),
        categoryId: 'cat-other',
      ).copyWith(createdAt: DateTime.utc(2026, 9, 2)),
    ]);
    await provider.load();

    await open(tester);
    final rentChip = find.widgetWithText(ChoiceChip, '🏠 Rent');
    await revealInForm(tester, rentChip);
    expect(find.widgetWithText(ChoiceChip, '📦 Other'), findsOneWidget);
    await tester.tap(rentChip);
    await tester.pumpAndSettle();
    await enterAmount(tester, '900');
    await tapButton(tester, 'Add Transaction');

    final added = provider.transactions.firstWhere(
      (t) => t.id != 'r' && t.id != 'o',
    );
    expect(added.categoryId, 'cat-rent');
  });

  testWidgets('the date arrows move a day either way (ADD-6)', (tester) async {
    await open(tester);
    final previous = find.byTooltip('Previous day');
    await tapInForm(tester, previous);
    await tapInForm(tester, previous);
    await tapInForm(tester, find.byTooltip('Next day'));

    await enterAmount(tester, '5');
    await tapButton(tester, 'Add Transaction');

    expect(
      dayOf(provider.transactions.single.date),
      DateTime(today.year, today.month, today.day - 1),
    );
  });

  testWidgets('the date picker sets the date', (tester) async {
    await open(tester);
    await tapInForm(
      tester,
      find.descendant(
        of: find.byType(DateField),
        matching: find.byType(TextButton),
      ),
    );
    await tester.tap(find.text('10'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await enterAmount(tester, '5');
    await tapButton(tester, 'Add Transaction');

    expect(provider.transactions.single.date.day, 10);
  });

  testWidgets('a transaction from before 2015 can still open the date picker '
      '(rules-1-5#12)', (tester) async {
    final old = testTx('old', TransactionType.expense, 5, DateTime(2012, 3, 4));
    await open(tester, editing: old);

    await tapInForm(
      tester,
      find.descendant(
        of: find.byType(DateField),
        matching: find.byType(TextButton),
      ),
    );

    // showDatePicker asserts initialDate is within firstDate/lastDate; a
    // fixed firstDate of 2015 would fail that assertion here and this tap
    // would throw instead of opening the calendar.
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('with two accounts the last used one is preselected (ADD-3)', (
    tester,
  ) async {
    fake = FakeDB(
      accounts: [testAccount(Account.cashId), testAccount('bank')],
      transactions: [
        testTx(
          'b',
          TransactionType.expense,
          3,
          DateTime(2026, 9, 1),
        ).copyWith(accountId: 'bank'),
      ],
    );
    provider = TransactionProvider(db: fake);
    await provider.load();

    await open(tester);
    await expectInForm(tester, 'bank');
    await enterAmount(tester, '7');
    await tapButton(tester, 'Add Transaction');

    expect(
      provider.transactions.firstWhere((t) => t.id != 'b').accountId,
      'bank',
    );
  });

  testWidgets('an empty amount asks for one', (tester) async {
    await open(tester);
    await tapButton(tester, 'Add Transaction');

    await expectInForm(tester, 'Enter an amount');
    expect(provider.transactions, isEmpty);
  });

  testWidgets('amounts allow only the currency decimals (CUR-2)', (
    tester,
  ) async {
    await open(tester);
    await enterAmount(tester, '12.345');
    await tapButton(tester, 'Add Transaction');

    await expectInForm(tester, 'Enter a valid amount');
    expect(provider.transactions, isEmpty);
  });

  testWidgets('a result of zero is rejected (MONEY-2)', (tester) async {
    await open(tester);
    await enterAmount(tester, '5-5');
    await tapButton(tester, 'Add Transaction');

    await expectInForm(tester, 'Enter a valid amount');
    expect(provider.transactions, isEmpty);
  });

  testWidgets('a yen amount must be whole', (tester) async {
    settings = await testSettings({'currency_code': 'JPY'});

    await open(tester);
    expect(find.text('¥ '), findsOneWidget);
    await enterAmount(tester, '12.5');
    await tapButton(tester, 'Add Transaction');

    await expectInForm(tester, 'Enter a valid amount');
  });

  // review-money-4: AmountEntry.parsedAmount passes the currency's decimal
  // mark to evaluateAmount (form_fields.dart). Without it, evaluateAmount
  // falls back to '.', and "1,500" is ambiguous for a 3-decimal currency
  // (CUR-2), so it would be rejected instead of read as 1.5 TND.
  testWidgets(
    'a comma decimal amount is read for a 3-decimal currency in French '
    '(CUR-2, review-money-4)',
    (tester) async {
      settings = await testSettings({'currency_code': 'TND', 'language': 'fr'});

      await open(tester);
      final montant = find.widgetWithText(TextFormField, 'Montant');
      await revealInForm(tester, montant);
      await tester.enterText(montant, '1,500');
      await tapInForm(
        tester,
        find.widgetWithText(FilledButton, 'Ajouter la transaction'),
      );

      expect(provider.transactions.single.amount, const Money(1500));
    },
  );

  testWidgets('a failed save keeps the screen open and shows an error', (
    tester,
  ) async {
    fake.failWrites = true;

    await open(tester);
    await enterAmount(tester, '12.50');
    await tapButton(tester, 'Add Transaction');

    expect(provider.transactions, isEmpty);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(
      find.text("Couldn't save the transaction. Try again."),
      findsOneWidget,
    );
  });

  testWidgets('editing can clear the note', (tester) async {
    final lunch = await addLunch();

    await open(tester, editing: lunch);
    expect(find.byType(AmountKeypad), findsNothing);
    final note = find.widgetWithText(TextFormField, 'Note (optional)');
    await revealInForm(tester, note);
    await tester.enterText(note, '');
    await tapButton(tester, 'Save Changes');

    final saved = provider.transactions.single;
    expect(saved.note, isNull);
    expect(saved.amount, const Money(12500));
    expect(find.byType(AddTransactionScreen), findsNothing);
  });

  testWidgets('a new entry counts towards RATE-1, but editing one does not '
      '(pr57#10)', (tester) async {
    final lunch = await addLunch();
    expect(settings.manualEntriesRecorded, 0);

    await open(tester, editing: lunch);
    await tapButton(tester, 'Save Changes');
    expect(
      settings.manualEntriesRecorded,
      0,
      reason: "editing an entry already recorded isn't a new one",
    );

    await open(tester);
    await enterAmount(tester, '12.50');
    await tapButton(tester, 'Add Transaction');
    expect(settings.manualEntriesRecorded, 1);
  });

  testWidgets(
    'tapping Amount on the edit form opens the keypad, since autofocus is '
    'off there (ADD-2, LANG-5, test-quality#12)',
    (tester) async {
      final lunch = await addLunch();

      await open(tester, editing: lunch);
      expect(find.byType(AmountKeypad), findsNothing);

      await tester.tap(amountField);
      await tester.pump();

      expect(find.byType(AmountKeypad), findsOneWidget);
    },
  );

  testWidgets('duplicate opens an unsaved copy dated today (ADD-7)', (
    tester,
  ) async {
    final lunch = await addLunch();

    await open(tester, editing: lunch);
    await tester.tap(find.byTooltip('Duplicate'));
    await tester.pumpAndSettle();
    expect(provider.transactions, hasLength(1));

    await tapButton(tester, 'Add Transaction');

    final copy = provider.transactions.firstWhere((t) => t.id != 'a');
    expect(
      (copy.amount, copy.note, copy.categoryId),
      (lunch.amount, lunch.note, lunch.categoryId),
    );
    expect(dayOf(copy.date), dayOf(today));
  });

  testWidgets('duplicate also carries the title, type, and account (ADD-7)', (
    tester,
  ) async {
    fake = FakeDB(
      accounts: [testAccount(Account.cashId), testAccount('bank')],
      transactions: [
        testTx(
          'p',
          TransactionType.income,
          900,
          DateTime(2026, 9, 1),
          title: 'Paycheck',
          accountId: 'bank',
        ),
      ],
    );
    provider = TransactionProvider(db: fake);
    await provider.load();
    final pay = provider.transactions.single;

    await open(tester, editing: pay);
    await tester.tap(find.byTooltip('Duplicate'));
    await tester.pumpAndSettle();

    await tapButton(tester, 'Add Transaction');

    final copy = provider.transactions.firstWhere((t) => t.id != 'p');
    expect(
      (copy.title, copy.type, copy.accountId),
      ('Paycheck', TransactionType.income, 'bank'),
    );
  });

  testWidgets('a transaction in an archived category keeps that category', (
    tester,
  ) async {
    final categories = testCategories();
    categories[0] = categories[0].copyWith(archivedAt: DateTime.utc(2026, 9));
    fake = FakeDB(categories: categories);
    provider = TransactionProvider(db: fake);
    final lunch = await addLunch();

    await open(tester, editing: lunch);
    await expectInForm(tester, '🍔 Food');
    await enterAmount(tester, '20');
    await tapButton(tester, 'Save Changes');

    final saved = provider.transactions.single;
    expect(saved.categoryId, 'cat-food');
    expect(saved.amount, const Money(20000));
  });

  testWidgets('the delete button moves the transaction to the trash', (
    tester,
  ) async {
    final lunch = await addLunch();

    await open(tester, editing: lunch);
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(provider.deletedTransactions.single.id, 'a');
    expect(find.text('Transaction deleted'), findsOneWidget);
  });

  testWidgets('a failed delete keeps the screen open and shows an error', (
    tester,
  ) async {
    final lunch = await addLunch();

    await open(tester, editing: lunch);
    fake.failWrites = true;
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(
      find.text("Couldn't delete the transaction. Try again."),
      findsOneWidget,
    );
  });

  testWidgets(
    'recording a note prefills it, dates it today, and links it (NOTE-4)',
    (tester) async {
      final note = testNote('n', 'Buy milk', amount: 5, categoryId: 'cat-food');
      await provider.addNote(
        note,
        appLockOn: false,
        locale: const Locale('en'),
      );

      await open(tester, recordingNote: note);
      await expectInForm(tester, 'Buy milk');
      await tapButton(tester, 'Record as transaction');

      final saved = provider.transactions.single;
      expect(saved.title, 'Buy milk');
      expect(saved.amount, const Money(5000));
      expect(dayOf(saved.date), dayOf(today));
      expect(provider.noteById('n')!.isDone, isTrue);
      expect(provider.noteById('n')!.transactionId, saved.id);
    },
  );

  group('the day a new entry starts on (ADD-3, DAY-9)', () {
    /// A provider whose today is fixed, so the day Home shows is known.
    Future<void> onDay(DateTime? day) async {
      provider = TransactionProvider(db: fake, clock: () => today);
      await provider.load();
      if (day == null) {
        provider.clearSelectedDay();
      } else {
        provider.selectDay(day);
      }
    }

    testWidgets('it is the day Home is showing', (tester) async {
      await onDay(DateTime(2026, 9, 12));

      await open(tester);
      await enterAmount(tester, '20');
      await tapButton(tester, 'Add Transaction');

      final added = provider.transactions.single;
      expect(added.date.month, 9);
      expect(added.date.day, 12);
    });

    testWidgets('with the whole period shown it is today', (tester) async {
      await onDay(null);

      await open(tester);
      await enterAmount(tester, '20');
      await tapButton(tester, 'Add Transaction');

      expect(provider.transactions.single.date.day, 15);
    });
  });

  group('leaving a form with edits (ADD-9)', () {
    testWidgets('the first Back closes the keypad and the form stays', (
      tester,
    ) async {
      await open(tester);
      expect(find.byType(AmountKeypad), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.byType(AmountKeypad), findsNothing);
    });

    testWidgets('a form nothing was typed into leaves without a word', (
      tester,
    ) async {
      await open(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(find.byType(AddTransactionScreen), findsNothing);
    });

    testWidgets('edits are asked about, and Keep editing stays on the form', (
      tester,
    ) async {
      await open(tester);
      await enterAmount(tester, '12');

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.text('12'), findsWidgets);
    });

    testWidgets('Discard leaves, and writes nothing', (tester) async {
      await open(tester);
      await enterAmount(tester, '12');

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(AddTransactionScreen), findsNothing);
      expect(provider.transactions, isEmpty);
    });

    testWidgets('a title typed on its own still counts as an edit', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title (optional)'),
        'Lunch',
      );
      await tester.pumpAndSettle();

      // Typing in the title moved focus off the amount, so the keypad has
      // already gone and one Back reaches the question.
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
    });
  });

  group('what the phone says back (HAP-1, HAP-2)', () {
    testWidgets('every keypad key that changes the amount ticks', (
      tester,
    ) async {
      final haptics = captureHaptics();
      await open(tester);

      await tester.tap(find.widgetWithText(TextButton, '7'));
      await tester.pump();
      expect(haptics, ['HapticFeedbackType.selectionClick']);

      // Backspace takes the 7 away, and then has nothing left to take.
      haptics.clear();
      await tester.tap(find.byTooltip('Backspace'));
      await tester.pump();
      await tester.tap(find.byTooltip('Backspace'));
      await tester.pump();
      expect(haptics, ['HapticFeedbackType.selectionClick']);
    });

    testWidgets('saving knocks once, and only once it is written', (
      tester,
    ) async {
      final haptics = captureHaptics();
      await open(tester);
      await enterAmount(tester, '12');
      haptics.clear();

      await tapButton(tester, 'Add Transaction');
      await tester.pumpAndSettle();

      expect(provider.transactions, hasLength(1));
      expect(haptics, ['HapticFeedbackType.mediumImpact']);
    });

    testWidgets('a save that fails says nothing', (tester) async {
      final haptics = captureHaptics();
      await open(tester);
      await enterAmount(tester, '12');
      fake.failWrites = true;
      haptics.clear();

      await tapButton(tester, 'Add Transaction');
      await tester.pumpAndSettle();

      expect(provider.transactions, isEmpty);
      expect(haptics, isEmpty);
    });
  });
}
