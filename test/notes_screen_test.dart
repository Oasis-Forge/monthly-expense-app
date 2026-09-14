import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/note_form_screen.dart';
import 'package:monthly_expense_app/screens/notes_screen.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

import 'helpers.dart';

void main() {
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
      final reminders = FakeReminderService();
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
}
