import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/note_form_screen.dart';
import 'package:monthly_expense_app/screens/transaction_detail_screen.dart';
import 'package:monthly_expense_app/services/attachment_service.dart';

import 'helpers.dart';

void main() {
  const expense = TransactionType.expense;
  const income = TransactionType.income;
  final today = DateTime(2026, 9, 15, 10);
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    fake = FakeDB(
      transactions: [
        testTx(
          'a',
          expense,
          12.5,
          DateTime(2026, 9, 15),
          title: 'Lunch',
          note: 'with Ada',
        ),
        testTx('b', income, 3000, DateTime(2026, 9, 1), title: 'Salary'),
        testTx('later', expense, 80, DateTime(2026, 9, 20), title: 'Concert'),
      ],
    );
    provider = TransactionProvider(db: fake, clock: () => today);
    await provider.load();
    settings = await testSettings();
  });

  /// Opens the details of [id] on top of a screen to come back to, so a
  /// screen that closes itself has somewhere to go (DET-6).
  Future<void> openDetail(
    WidgetTester tester,
    String id, {
    AttachmentService? attachments,
  }) async {
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransactionDetailScreen(id: id),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        attachments: attachments,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('an expense is shown, not opened for editing (DET-1, DET-2)', (
    tester,
  ) async {
    await openDetail(tester, 'a');

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('-\$12.50'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('acc-cash'), findsOneWidget);
    expect(find.text('Tuesday, September 15, 2026'), findsOneWidget);
    expect(find.text('with Ada'), findsOneWidget);
    // Nothing on it can be typed into (DET-1).
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('income shows with a plus (DET-2)', (tester) async {
    await openDetail(tester, 'b');

    expect(find.text('+\$3,000'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
  });

  testWidgets('a date ahead is marked upcoming (DET-2)', (tester) async {
    await openDetail(tester, 'later');

    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('when it was added, and changed, are at the foot (DET-5)', (
    tester,
  ) async {
    fake.rows.add(
      ExpenseTransaction(
        id: 'edited',
        title: 'Coffee',
        amount: const Money(2500),
        categoryId: 'cat-food',
        accountId: Account.cashId,
        type: expense,
        date: DateTime(2026, 9, 14),
        createdAt: DateTime.utc(2026, 9, 14, 8),
        updatedAt: DateTime.utc(2026, 9, 16, 9),
      ),
    );
    await provider.load();

    await openDetail(tester, 'edited');

    expect(find.text('Added Sep 14, 2026'), findsOneWidget);
    expect(find.text('Last changed Sep 16, 2026'), findsOneWidget);
  });

  testWidgets('a change on the day it was added is not a line of its own '
      '(DET-5)', (tester) async {
    fake.rows.add(
      ExpenseTransaction(
        id: 'same-day',
        title: 'Coffee',
        amount: const Money(2500),
        categoryId: 'cat-food',
        accountId: Account.cashId,
        type: expense,
        date: DateTime(2026, 9, 14),
        // Saving a new transaction sets both, moments apart.
        createdAt: DateTime.utc(2026, 9, 14, 8),
        updatedAt: DateTime.utc(2026, 9, 14, 8, 0, 1),
      ),
    );
    await provider.load();

    await openDetail(tester, 'same-day');

    expect(find.text('Added Sep 14, 2026'), findsOneWidget);
    expect(find.textContaining('Last changed'), findsNothing);
  });

  testWidgets('the pencil opens the form, and the change shows on the way '
      'back (DET-3, DET-6)', (tester) async {
    await openDetail(tester, 'a');

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Transaction'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title (optional)'),
      'Dinner',
    );
    await revealInForm(tester, find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);
  });

  testWidgets('duplicate opens an unsaved copy (ADD-7)', (tester) async {
    await openDetail(tester, 'a');

    await tester.tap(find.byTooltip('Duplicate'));
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Title (optional)'), findsOne);
    expect(find.text('Lunch'), findsOneWidget);
    expect(provider.transactions, hasLength(3));
  });

  testWidgets('delete closes the screen, and Undo brings it back '
      '(DEL-2, DET-6)', (tester) async {
    await openDetail(tester, 'a');

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsNothing);
    expect(find.text('open'), findsOneWidget);
    expect(provider.deletedTransactions.single.id, 'a');
    expect(find.text('Transaction deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(provider.transactions.map((tx) => tx.id), contains('a'));
  });

  testWidgets('a failed delete keeps the screen and says so', (tester) async {
    await openDetail(tester, 'a');
    fake.failWrites = true;

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(
      find.text("Couldn't delete the transaction. Try again."),
      findsOneWidget,
    );
  });

  testWidgets('deleting it from elsewhere closes the screen (DET-6)', (
    tester,
  ) async {
    await openDetail(tester, 'a');

    await provider.deleteTransaction('a');
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a photo and a voice note can be looked at and played, not '
      'changed (DET-4)', (tester) async {
    final attachments = FakeAttachments();
    attachments.stored['voice.m4a'] = const [2];
    fake.rows.add(
      ExpenseTransaction(
        id: 'kept',
        title: 'Receipt',
        amount: const Money(5000),
        categoryId: 'cat-food',
        accountId: Account.cashId,
        type: expense,
        date: DateTime(2026, 9, 15),
        photoFile: 'photo.jpg',
        voiceFile: 'voice.m4a',
      ),
    );
    await provider.load();

    await openDetail(tester, 'kept', attachments: attachments);

    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Voice note'), findsOneWidget);
    // The form's own controls are not here (DET-4).
    expect(find.text('Add a photo'), findsNothing);
    expect(find.byTooltip('Remove the photo'), findsNothing);

    await tester.tap(find.byTooltip('Play'));
    await tester.pumpAndSettle();
    expect(attachments.played, ['voice.m4a']);

    // The same button stops it again (ATT-4).
    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Play'), findsOneWidget);
  });

  testWidgets('the photo opens full screen, and says so when it is gone '
      '(DET-4, ATT-7)', (tester) async {
    final attachments = FakeAttachments();
    fake.rows.add(
      ExpenseTransaction(
        id: 'kept',
        title: 'Receipt',
        amount: const Money(5000),
        categoryId: 'cat-food',
        accountId: Account.cashId,
        type: expense,
        date: DateTime(2026, 9, 15),
        photoFile: 'photo.jpg',
      ),
    );
    await provider.load();

    await openDetail(tester, 'kept', attachments: attachments);

    await tester.tap(find.text('Photo'));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('a missing voice note cannot be played (ATT-7)', (tester) async {
    final attachments = FakeAttachments();
    fake.rows.add(
      ExpenseTransaction(
        id: 'kept',
        title: 'Receipt',
        amount: const Money(5000),
        categoryId: 'cat-food',
        accountId: Account.cashId,
        type: expense,
        date: DateTime(2026, 9, 15),
        voiceFile: 'gone.m4a',
      ),
    );
    await provider.load();

    await openDetail(tester, 'kept', attachments: attachments);

    expect(find.text('This voice note is missing.'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byIcon(Icons.play_arrow),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('the note it was recorded from opens from here (NOTE-4)', (
    tester,
  ) async {
    await provider.addNote(
      testNote('n', 'Buy milk'),
      appLockOn: false,
      locale: const Locale('en'),
    );
    await provider.recordNote(
      'n',
      'a',
      appLockOn: false,
      locale: const Locale('en'),
    );

    await openDetail(tester, 'a');

    expect(find.text('From a note'), findsOneWidget);
    await tester.ensureVisible(find.text('From a note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('From a note'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteFormScreen), findsOneWidget);
  });

  testWidgets('every way in opens the details, not the form (DET-1)', (
    tester,
  ) async {
    await openDetail(tester, 'a');

    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    expect(find.byType(AddTransactionScreen), findsNothing);
  });
}
