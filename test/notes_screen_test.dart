import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/note_form_screen.dart';
import 'package:monthly_expense_app/screens/notes_screen.dart';
import 'package:monthly_expense_app/screens/transaction_detail_screen.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  const locale = Locale('en');

  setUp(() async {
    fake = FakeDB();
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings();
  });

  Future<void> showNotes(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(testApp(provider, settings, const NotesScreen()));
    await tester.pumpAndSettle();
  }

  /// Opens the note form from a placeholder page, on a phone screen.
  Future<void> openForm(
    WidgetTester tester, {
    Note? editing,
    ReminderService? reminders,
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
                  builder: (_) => NoteFormScreen(editing: editing),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        reminders: reminders,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapInForm(WidgetTester tester, Finder finder) async {
    await revealInForm(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('the empty state offers one clear action (NOTE-2)', (
    tester,
  ) async {
    await showNotes(tester);
    expect(find.text('Nothing here yet'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add a note'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteFormScreen), findsOneWidget);
  });

  testWidgets('open notes list above done notes, in sections (NOTE-2)', (
    tester,
  ) async {
    await provider.addNote(
      testNote('a', 'Open one'),
      appLockOn: false,
      locale: locale,
    );
    await provider.addNote(
      testNote('b', 'Done one', doneAt: DateTime.utc(2026, 9, 1)),
      appLockOn: false,
      locale: locale,
    );

    await showNotes(tester);

    expect(find.text('Open (1)'), findsOneWidget);
    expect(find.text('Done (1)'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Open one')).dy,
      lessThan(tester.getTopLeft(find.text('Done one')).dy),
    );
  });

  testWidgets('adding a note through the form saves it', (tester) async {
    await showNotes(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Note'),
      'Pay rent',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add a note'));
    await tester.pumpAndSettle();

    expect(provider.notes.single.text, 'Pay rent');
    expect(find.byType(NoteFormScreen), findsNothing);
  });

  testWidgets('two notes get distinct UUID v4 IDs (REC-2)', (tester) async {
    Future<void> addNote(String text) async {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Note'), text);
      await tester.tap(find.widgetWithText(FilledButton, 'Add a note'));
      await tester.pumpAndSettle();
    }

    await showNotes(tester);
    await addNote('First');
    await addNote('Second');

    expect(provider.notes, hasLength(2));
    final ids = provider.notes.map((n) => n.id).toList();
    expect(
      ids.toSet(),
      hasLength(2),
      reason: 'record IDs must not collide across saves (REC-2, BAK-3)',
    );
    for (final id in ids) {
      expect(uuidV4.hasMatch(id), isTrue, reason: '$id is not a UUID v4');
    }
  });

  testWidgets('the checkbox marks a note done and moves it to Done', (
    tester,
  ) async {
    await provider.addNote(
      testNote('a', 'Open one'),
      appLockOn: false,
      locale: locale,
    );
    await showNotes(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(provider.noteById('a')!.isDone, isTrue);
    expect(find.text('Done (1)'), findsOneWidget);
  });

  testWidgets('swiping deletes a note, with Undo (NOTE-7)', (tester) async {
    await provider.addNote(
      testNote('a', 'Open one'),
      appLockOn: false,
      locale: locale,
    );
    await showNotes(tester);

    await tester.drag(find.text('Open one'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(provider.notes, isEmpty);
    expect(find.text('Note deleted.'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(provider.notes.single.id, 'a');
  });

  testWidgets('search and the due-date filter combine (NOTE-3)', (
    tester,
  ) async {
    await provider.addNote(
      testNote('a', 'Buy milk', dueDate: DateTime(2026, 9, 1)),
      appLockOn: false,
      locale: locale,
    );
    await provider.addNote(
      testNote('b', 'Buy bread'),
      appLockOn: false,
      locale: locale,
    );
    await showNotes(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search notes'),
      'buy',
    );
    await tester.pumpAndSettle();
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('Buy bread'), findsOneWidget);

    final overdueChip = find.widgetWithText(ChoiceChip, 'Overdue');
    await tester.scrollUntilVisible(
      overdueChip,
      100,
      scrollable: find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(overdueChip);
    await tester.pumpAndSettle();
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('Buy bread'), findsNothing);
  });

  testWidgets('editing a note updates its text', (tester) async {
    await provider.addNote(
      testNote('a', 'Old text'),
      appLockOn: false,
      locale: locale,
    );
    await openForm(tester, editing: provider.noteById('a'));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Note'),
      'New text',
    );
    await tapInForm(tester, find.widgetWithText(FilledButton, 'Save Changes'));

    expect(provider.noteById('a')!.text, 'New text');
  });

  testWidgets(
    'a due date and reminder are saved and scheduled (NOTE-1, NOTE-6)',
    (tester) async {
      // Toggling the due date on sets it to the real wall-clock "now"
      // (_toggleDueDate), so the note's default 9am reminder is derived
      // from whatever day and hour this happens to run on -- on any day's
      // last date, "tomorrow" wraps into next month, and on a run any time
      // after 11am today's default 9am reminder is already more than two
      // hours past (NOTE-6). Rather than drive the date picker to a
      // fixed offset (which itself broke on a month's last day: tapping
      // tomorrow's day-of-month number in a picker still showing this
      // month selects that day THIS month instead, pr59#9), the fake's own
      // clock is pinned far in the past so today's real date is always in
      // its future, independent of the day or hour this test happens to
      // run on.
      final reminders = FakeReminderService(now: () => DateTime(2000));
      // The same fake schedules for both the provider and the permission
      // request, so this exercises the whole path (NOTE-6).
      provider = TransactionProvider(
        db: fake,
        clock: () => DateTime(2026, 9, 15),
        reminders: reminders,
      );
      await provider.load();
      await openForm(tester, reminders: reminders);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Note'),
        'Pay rent',
      );
      await tapInForm(
        tester,
        find.widgetWithText(SwitchListTile, 'Set a due date'),
      );
      await tapInForm(tester, find.widgetWithText(SwitchListTile, 'Remind me'));
      expect(reminders.permissionRequests, 1);

      await tapInForm(tester, find.widgetWithText(FilledButton, 'Add a note'));

      final note = provider.notes.single;
      expect(note.dueDate, isNotNull);
      expect(note.reminderAt, isNotNull);
      expect(reminders.scheduled[note.id], false);
    },
  );

  testWidgets(
    'a refused reminder permission still saves, with a notice (NOTE-6)',
    (tester) async {
      await openForm(
        tester,
        reminders: FakeReminderService(permissionGranted: false),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Note'),
        'Pay rent',
      );
      await tapInForm(
        tester,
        find.widgetWithText(SwitchListTile, 'Set a due date'),
      );
      await tapInForm(tester, find.widgetWithText(SwitchListTile, 'Remind me'));

      expect(
        find.text(
          'Turn on notifications in system settings to get reminders for '
          'notes.',
        ),
        findsOneWidget,
      );

      await tapInForm(tester, find.widgetWithText(FilledButton, 'Add a note'));
      expect(provider.notes.single.reminderAt, isNotNull);
    },
  );

  testWidgets('deleting a note from the form is undoable (NOTE-7)', (
    tester,
  ) async {
    await provider.addNote(
      testNote('a', 'Delete me'),
      appLockOn: false,
      locale: locale,
    );
    await openForm(tester, editing: provider.noteById('a'));

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteFormScreen), findsNothing);
    expect(provider.notes, isEmpty);
    expect(find.text('Note deleted.'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(provider.notes.single.id, 'a');
  });

  testWidgets(
    'the record button opens the add form for an open note (NOTE-4)',
    (tester) async {
      await provider.addNote(
        testNote('a', 'Buy milk'),
        appLockOn: false,
        locale: locale,
      );
      await openForm(tester, editing: provider.noteById('a'));

      await tapInForm(
        tester,
        find.widgetWithText(OutlinedButton, 'Record as transaction'),
      );
      expect(find.byType(AddTransactionScreen), findsOneWidget);
    },
  );

  testWidgets('a done note has no record button', (tester) async {
    await provider.addNote(
      testNote('a', 'Done already', doneAt: DateTime.utc(2026, 9, 1)),
      appLockOn: false,
      locale: locale,
    );
    await openForm(tester, editing: provider.noteById('a'));

    expect(
      find.widgetWithText(OutlinedButton, 'Record as transaction'),
      findsNothing,
    );
  });

  testWidgets('a recorded note links to its transaction, which opens to read '
      '(NOTE-4, DET-1)', (tester) async {
    await provider.addNote(
      testNote('a', 'Buy milk'),
      appLockOn: false,
      locale: locale,
    );
    await provider.addTransaction(
      testTx('tx-1', TransactionType.expense, 5, DateTime(2026, 9, 15)),
    );
    await provider.recordNote('a', 'tx-1', appLockOn: false, locale: locale);
    await openForm(tester, editing: provider.noteById('a'));

    await tapInForm(
      tester,
      find.widgetWithText(ListTile, 'Recorded as a transaction'),
    );

    expect(find.byType(TransactionDetailScreen), findsOneWidget);
  });

  testWidgets('an amount and a category round-trip through the form '
      '(NOTE-1)', (tester) async {
    await openForm(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Note'),
      'Buy milk',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount (optional)'),
      '12.50',
    );
    await revealInForm(
      tester,
      find.widgetWithText(DropdownButtonFormField<String?>, 'None'),
    );
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String?>, 'None'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('🍔 Food').last);
    await tester.pumpAndSettle();
    await tapInForm(tester, find.widgetWithText(FilledButton, 'Add a note'));

    final note = provider.notes.single;
    expect(note.amount!.toDouble(), 12.5);
    expect(note.categoryId, 'cat-food');

    // Editing it shows both again; the amount drops its trailing zero.
    await openForm(tester, editing: note);
    expect(find.widgetWithText(TextFormField, '12.5'), findsOneWidget);
    expect(find.text('🍔 Food'), findsWidgets);
  });

  testWidgets('the form rejects empty text and an unparseable amount', (
    tester,
  ) async {
    await openForm(tester);

    await tapInForm(tester, find.widgetWithText(FilledButton, 'Add a note'));
    expect(find.text('Enter some text'), findsOneWidget);
    expect(provider.notes, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Note'),
      'Buy milk',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount (optional)'),
      'abc',
    );
    await tapInForm(tester, find.widgetWithText(FilledButton, 'Add a note'));
    expect(find.text('Enter a valid amount'), findsOneWidget);
    expect(provider.notes, isEmpty);
  });

  testWidgets('turning the due date off drops the reminder with it (NOTE-6)', (
    tester,
  ) async {
    final reminders = FakeReminderService();
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
      reminders: reminders,
    );
    await provider.load();
    await openForm(tester, reminders: reminders);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Note'),
      'Pay rent',
    );
    await tapInForm(
      tester,
      find.widgetWithText(SwitchListTile, 'Set a due date'),
    );
    await tapInForm(tester, find.widgetWithText(SwitchListTile, 'Remind me'));
    expect(find.widgetWithText(SwitchListTile, 'Remind me'), findsOneWidget);

    await tapInForm(
      tester,
      find.widgetWithText(SwitchListTile, 'Set a due date'),
    );
    await tapInForm(tester, find.widgetWithText(FilledButton, 'Add a note'));

    final note = provider.notes.single;
    expect(note.dueDate, isNull);
    expect(note.reminderAt, isNull);
    expect(reminders.scheduled.containsKey(note.id), isFalse);
  });

  testWidgets('the due date and reminder time can be picked (NOTE-1, NOTE-6)', (
    tester,
  ) async {
    await provider.addNote(
      testNote(
        'a',
        'Pay rent',
        dueDate: DateTime(2026, 9, 20),
        reminderAt: DateTime(2026, 9, 20, 9),
      ),
      appLockOn: false,
      locale: locale,
    );
    await openForm(tester, editing: provider.noteById('a'));

    await revealInForm(tester, find.text('Due date'));
    await tester.tap(find.text('Sun, Sep 20, 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tapInForm(tester, find.widgetWithText(FilledButton, 'Save Changes'));

    final note = provider.noteById('a')!;
    expect(note.dueDate!.day, 25);
    // The reminder follows the new date, keeping its time (NOTE-6).
    expect(note.reminderAt, DateTime(2026, 9, 25, 9));
  });

  testWidgets('a note that fails to save says so and stays unsaved', (
    tester,
  ) async {
    await openForm(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Note'),
      'Buy milk',
    );
    fake.failWrites = true;

    await tapInForm(tester, find.widgetWithText(FilledButton, 'Add a note'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't save the note. Try again."), findsOneWidget);
    expect(provider.notes, isEmpty);
  });

  testWidgets(
    'the reminder toggle survives a reminder plugin that throws, through '
    "the real app's own wiring, not just testApp's (NOTE-6, pr59#9)",
    (tester) async {
      final realSettings = await testSettings({
        'setup_done': true,
        'walkthrough_seen': true,
        'language': 'en',
      });
      usePhoneScreen(tester);

      await tester.pumpWidget(
        MonthlyExpenseApp(
          settings: realSettings,
          homeWidget: const NoopHomeWidgetService(),
          reviews: FakeReviews(supported: false),
          updates: FakeUpdates(supported: false),
          shortcuts: FakeShortcuts(),
          // Without these the real ad SDK is built and leaves a timer
          // running long after the test.
          ads: FakeAdService(),
          purchases: FakePurchases(),
          reminders: ThrowingReminderService(),
        ),
      );
      await tester.pump();
      await waitForRealLoad(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Add a note'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Note'),
        'Pay rent',
      );
      await tapInForm(
        tester,
        find.widgetWithText(SwitchListTile, 'Set a due date'),
      );
      await tapInForm(tester, find.widgetWithText(SwitchListTile, 'Remind me'));

      // A plugin failure is treated like a refusal, never a crash: this
      // only holds because main.dart wraps `reminders` in SafeReminderService
      // before handing it to the widget tree -- testApp() does not.
      expect(tester.takeException(), isNull);
      expect(
        find.text(
          'Turn on notifications in system settings to get reminders for '
          'notes.',
        ),
        findsOneWidget,
      );
    },
  );
}
