import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/db/db_helper.dart';
import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/note_form_screen.dart';
import 'package:monthly_expense_app/screens/notes_screen.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets(
    'a tapped note reminder that arrives before the database load finishes '
    'waits for it, so the tapped note opens rather than the notes list '
    '(NOTE-6, pr59#8)',
    (tester) async {
      addTearDown(() => tappedNoteId.value = null);

      // A note already on the device, as it would be for a reminder that
      // fires while the app is dead and the tap relaunches it. The real
      // write needs the zone `runAsync` gives it: a plain `await` here
      // never returns under the test binding's fake clock.
      // An in-memory database of its own, so nothing lingers on disk for
      // other tests to see, and nothing left there can change this one.
      final db = DBHelper(path: inMemoryDatabasePath);
      final id = 'reminder-note-${DateTime.now().microsecondsSinceEpoch}';
      final text = 'Pay the $id bill';
      await tester.runAsync(() => db.insertNote(Note(id: id, text: text)));

      await tester.pumpWidget(
        MonthlyExpenseApp(
          db: db,
          settings: await testSettings({
            'setup_done': true,
            'walkthrough_seen': true,
          }),
          homeWidget: const NoopHomeWidgetService(),
          reviews: FakeReviews(supported: false),
          updates: FakeUpdates(supported: false),
          shortcuts: FakeShortcuts(),
          ads: FakeAdService(),
          purchases: FakePurchases(),
          reminders: FakeReminderService(),
        ),
      );
      await tester.pump();

      final transactions = tester
          .element(find.byType(MaterialApp))
          .read<TransactionProvider>();
      // The process is dead, as it usually is for a reminder tap: the real
      // database load is still in flight when the tap arrives.
      expect(
        transactions.isLoaded,
        isFalse,
        reason: 'the probe needs the load still pending when the tap fires',
      );

      tappedNoteId.value = id;
      await tester.pump();
      // The push waits for the load, so nothing has opened yet.
      expect(find.byType(NoteFormScreen, skipOffstage: false), findsNothing);
      expect(find.byType(NotesScreen, skipOffstage: false), findsNothing);

      for (var i = 0; i < 200 && !transactions.isLoaded; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      expect(
        transactions.isLoaded,
        isTrue,
        reason: 'the database never loaded',
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(NoteFormScreen),
        findsOneWidget,
        reason:
            'NOTE-6/pr59#8: the tapped note should open once the load '
            'finishes, not the notes list',
      );
      expect(find.text(text), findsWidgets);
      expect(find.byType(NotesScreen), findsNothing);
    },
  );
}
