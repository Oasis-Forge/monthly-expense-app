// Verifies rules-14-19#11: a reminder tap's note is pushed right away (so it
// is already on screen once the app unlocks), but that push must stay under
// the lock -- not hit-testable -- until the app is actually unlocked
// (NOTE-6, LOCK-2).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/l10n/languages.dart';
import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/models/note.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/note_form_screen.dart';
import 'package:monthly_expense_app/services/authenticator.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() => tappedNoteId.value = null);

  final locked = find.text('Monthly Expenses is locked');

  testWidgets(
    'a tapped reminder opens its note under the lock, and it only shows '
    'once unlocked',
    (tester) async {
      final authenticator = FakeAuthenticator(result: AuthResult.failed);

      await tester.pumpWidget(
        MonthlyExpenseApp(
          settings: await testSettings({
            'setup_done': true,
            'walkthrough_seen': true,
            'app_lock': true,
          }),
          homeWidget: const NoopHomeWidgetService(),
          authenticator: authenticator,
          reviews: FakeReviews(supported: false),
          updates: FakeUpdates(supported: false),
          shortcuts: FakeShortcuts(),
          ads: FakeAdService(),
          purchases: FakePurchases(),
        ),
      );
      await tester.pump();
      final transactions = tester
          .element(find.byType(MaterialApp))
          .read<TransactionProvider>();
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
      await tester.pump();

      // The lock is up from the first frame (app_lock is on and the
      // authenticator fails).
      expect(locked, findsOneWidget);

      // Unique so a note left behind by an earlier, interrupted run of this
      // test (the real, persistent app database, not a fake) never collides.
      final noteId = 'lock-test-${DateTime.now().microsecondsSinceEpoch}';

      // Real database I/O needs the real async zone, same as the load-wait
      // loop above.
      await tester.runAsync(
        () => transactions.addNote(
          Note(id: noteId, text: 'Pay rent'),
          appLockOn: true,
          locale: effectiveAppLocale(null),
        ),
      );
      addTearDown(() => tester.runAsync(() => transactions.deleteNote(noteId)));

      // A reminder tap, same as one that arrives while the app is already
      // running.
      tappedNoteId.value = noteId;
      // Not pumpAndSettle: the lock disabling TickerMode still leaves a
      // route-push transition that never fully quiesces here, and this only
      // needs the push itself to have landed, not its animation to finish.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The note is already pushed underneath the lock, so it appears the
      // moment the app unlocks rather than after another round trip.
      expect(locked, findsOneWidget);
      expect(tappedNoteId.value, isNull);
      expect(find.byType(NoteFormScreen), findsOneWidget);
      expect(find.byType(NoteFormScreen).hitTestable(), findsNothing);

      authenticator.result = AuthResult.success;
      await tester.tap(find.text('Unlock'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(locked, findsNothing);
      expect(find.byType(NoteFormScreen).hitTestable(), findsOneWidget);
    },
  );
}
