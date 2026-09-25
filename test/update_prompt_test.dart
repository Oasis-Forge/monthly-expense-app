import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/rating.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/after_save.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 24, 10);
  final amountField = find.widgetWithText(TextFormField, 'Amount');

  /// A device old enough and busy enough that the rating is due as well, so
  /// every test here is also a test of which ask wins (UPD-3).
  Future<(TransactionProvider, SettingsProvider)> established({
    String? askedOn,
  }) async {
    final provider = TransactionProvider(db: FakeDB(), clock: () => today);
    await provider.load();
    final settings = await testSettings({
      'first_opened_at': DateTime(2026, 9, 10).toIso8601String(),
      'update_asked_on': ?askedOn,
      // RATE-1 counts entries saved by hand, not the list's length
      // (pr57#10); this device has crossed both of its lines.
      'manual_entries_recorded': ratingEntries,
    });
    return (provider, settings);
  }

  /// The real seam: an entry saved on the form, which is the only place
  /// [afterSave] is called from (UPD-2).
  Future<void> saveAnEntry(
    WidgetTester tester,
    TransactionProvider provider,
    SettingsProvider settings, {
    required FakeUpdates updates,
    required FakeReviews reviews,
    ValueListenable<bool>? locked,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        const AddTransactionScreen(),
        reviews: reviews,
        updates: updates,
        locked: locked,
      ),
    );
    await tester.pump();
    await revealInForm(tester, amountField);
    await tester.enterText(amountField, '12');
    await revealInForm(
      tester,
      find.widgetWithText(FilledButton, 'Add Transaction'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add Transaction'));
    await tester.pumpAndSettle();
  }

  /// The same seam on a screen that stays put. Saving on the form pops it,
  /// which leaves no Scaffold to hold a snack bar, so what the snack bar
  /// says and does is checked here instead.
  Future<void> runSeam(
    WidgetTester tester,
    TransactionProvider provider,
    SettingsProvider settings, {
    required FakeUpdates updates,
  }) async {
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => afterSave(context),
              child: const Text('save'),
            ),
          ),
        ),
        reviews: FakeReviews(supported: false),
        updates: updates,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
  }

  testWidgets('a saved entry offers the update and the rating waits '
      '(UPD-2, UPD-3)', (tester) async {
    final (provider, settings) = await established();
    final updates = FakeUpdates(offered: true);
    final reviews = FakeReviews(appVersion: '1.26.0+38');

    await saveAnEntry(
      tester,
      provider,
      settings,
      updates: updates,
      reviews: reviews,
    );

    expect(updates.checked, 1);
    expect(updates.started, 1);
    // UPD-3: the star waits for another day.
    expect(reviews.asked, 0);
    expect(settings.ratingAskedVersion, isNull);
    // UPD-4: spent before Play was given the chance to decline.
    expect(settings.updateAskedOn, isNotNull);
  });

  testWidgets('a failed save asks Play nothing, even with an update due '
      '(UPD-2, rules-22-25-31-35#10)', (tester) async {
    final fake = FakeDB();
    final provider = TransactionProvider(db: fake, clock: () => today);
    await provider.load();
    final settings = await testSettings({
      'first_opened_at': DateTime(2026, 9, 10).toIso8601String(),
      'manual_entries_recorded': ratingEntries,
    });
    final updates = FakeUpdates(offered: true);
    final reviews = FakeReviews(appVersion: '1.26.0+38');
    // Due on the line above, but the write itself fails.
    fake.failWrites = true;

    await saveAnEntry(
      tester,
      provider,
      settings,
      updates: updates,
      reviews: reviews,
    );

    expect(
      find.text("Couldn't save the transaction. Try again."),
      findsOneWidget,
    );
    expect(updates.checked, 0);
    expect(settings.updateAskedOn, isNull);
  });

  testWidgets('never while the app is locked, even with an update due '
      '(UPD-2, LOCK-1, rules-22-25-31-35#10)', (tester) async {
    final (provider, settings) = await established();
    final updates = FakeUpdates(offered: true);
    final reviews = FakeReviews(appVersion: '1.26.0+38');

    await saveAnEntry(
      tester,
      provider,
      settings,
      updates: updates,
      reviews: reviews,
      locked: ValueNotifier(true),
    );

    expect(updates.checked, 0);
    expect(settings.updateAskedOn, isNull);
  });

  testWidgets(
    'a later save the same day still holds the rating, not just the save '
    'the update was offered on (UPD-3, rules-22-25-31-35#7)',
    (tester) async {
      final (provider, settings) = await established();
      final updates = FakeUpdates(offered: true);
      final reviews = FakeReviews(appVersion: '1.26.0+38');

      await saveAnEntry(
        tester,
        provider,
        settings,
        updates: updates,
        reviews: reviews,
      );
      expect(updates.started, 1);
      expect(reviews.asked, 0);

      // A second save the same day: Play is not asked about the update
      // again (UPD-4), but UPD-3 says the rating still waits for another
      // day, not just for the save the update was offered on.
      await saveAnEntry(
        tester,
        provider,
        settings,
        updates: updates,
        reviews: reviews,
      );

      expect(reviews.asked, 0);
    },
  );

  testWidgets(
    "with 'Save & add another', the ask waits for the form to actually "
    'close instead of landing over the next entry (UPD-2, pr58#7)',
    (tester) async {
      final (provider, settings) = await established();
      final updates = FakeUpdates(offered: true);
      final reviews = FakeReviews(appVersion: '1.26.0+38');

      usePhoneScreen(tester);
      await tester.pumpWidget(
        testApp(
          provider,
          settings,
          const AddTransactionScreen(),
          reviews: reviews,
          updates: updates,
        ),
      );
      await tester.pump();
      await revealInForm(tester, amountField);
      await tester.enterText(amountField, '12');
      await revealInForm(
        tester,
        find.widgetWithText(OutlinedButton, 'Save & add another'),
      );
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Save & add another'),
      );
      await tester.pumpAndSettle();

      // ADD-4 keeps the form open on the cleared entry: nothing may have
      // asked yet, or the update sheet would land over the keypad (UPD-2).
      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(updates.checked, 0);
      expect(reviews.asked, 0);

      // Only closing the form for good lets the seam finally run.
      await revealInForm(tester, amountField);
      await tester.enterText(amountField, '9');
      await revealInForm(
        tester,
        find.widgetWithText(FilledButton, 'Add Transaction'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Add Transaction'));
      await tester.pumpAndSettle();

      expect(updates.checked, 1);
      expect(updates.started, 1);
    },
  );

  testWidgets('a downloaded update offers the restart, and Play does it '
      '(UPD-1)', (tester) async {
    final (provider, settings) = await established();
    final updates = FakeUpdates(offered: true);

    await runSeam(tester, provider, settings, updates: updates);

    expect(find.text('An update has been downloaded.'), findsOneWidget);
    await tester.tap(find.text('Restart'));
    await tester.pump();
    expect(updates.installed, 1);
  });

  testWidgets('a later message still gets through after the restart offer '
      '(UPD-1, pr58#3)', (tester) async {
    final (provider, settings) = await established();
    final updates = FakeUpdates(offered: true);

    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        Builder(
          builder: (context) => Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => afterSave(context),
                  child: const Text('save'),
                ),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not save.')),
                  ),
                  child: const Text('fail'),
                ),
              ],
            ),
          ),
        ),
        reviews: FakeReviews(supported: false),
        updates: updates,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
    expect(find.text('An update has been downloaded.'), findsOneWidget);

    await tester.tap(find.text('fail'));
    await tester.pump();
    // Comfortably longer than the restart bar's own 10 second duration, so a
    // message that isn't stuck behind it would have had its turn by now.
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Could not save.'), findsOneWidget);
  });

  testWidgets(
    "Restart asks before discarding a form's unsaved edits, rather than "
    'taking them down with it (ADD-9, UPD-2, pr58#7)',
    (tester) async {
      final (provider, settings) = await established();
      final updates = FakeUpdates(offered: true);

      await tester.pumpWidget(
        testApp(
          provider,
          settings,
          Builder(
            builder: (context) => Scaffold(
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => afterSave(context),
                    child: const Text('save'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(),
                      ),
                    ),
                    child: const Text('open'),
                  ),
                ],
              ),
            ),
          ),
          reviews: FakeReviews(supported: false),
          updates: updates,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('save'));
      await tester.pumpAndSettle();
      expect(find.text('An update has been downloaded.'), findsOneWidget);

      // A new form opens -- and gets something typed into it -- while the
      // Restart bar is still up.
      usePhoneScreen(tester);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await revealInForm(tester, amountField);
      await tester.enterText(amountField, '12');

      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();

      // Restart asks the same "Discard changes?" question Back would
      // (ADD-9), rather than throw the unsaved entry away.
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(updates.installed, 0);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(updates.installed, 1);
    },
  );

  testWidgets(
    'a download Play already finished offers the restart without starting '
    'another (UPD-1)',
    (tester) async {
      final (provider, settings) = await established();
      final updates = FakeUpdates(downloaded: true);

      await runSeam(tester, provider, settings, updates: updates);

      expect(find.text('An update has been downloaded.'), findsOneWidget);
      expect(updates.started, 0);
      expect(settings.updateAskedOn, isNotNull);
    },
  );

  testWidgets('a download that never finished says nothing (UPD-1)', (
    tester,
  ) async {
    final (provider, settings) = await established();
    final updates = FakeUpdates(offered: true, downloads: false);

    await runSeam(tester, provider, settings, updates: updates);

    expect(updates.started, 1);
    expect(find.text('An update has been downloaded.'), findsNothing);
    expect(updates.installed, 0);
  });

  testWidgets('a declined download still counts as having asked today '
      '(UPD-3, UPD-4)', (tester) async {
    final (provider, settings) = await established();
    final updates = FakeUpdates(offered: true, downloads: false);
    final reviews = FakeReviews(appVersion: '1.26.0+38');

    await saveAnEntry(
      tester,
      provider,
      settings,
      updates: updates,
      reviews: reviews,
    );

    expect(settings.updateAskedOn, isNotNull);
    expect(reviews.asked, 0);
  });

  testWidgets('with nothing waiting at Play, the rating has its turn '
      '(UPD-3)', (tester) async {
    final (provider, settings) = await established();
    final updates = FakeUpdates();
    final reviews = FakeReviews(appVersion: '1.26.0+38');

    await saveAnEntry(
      tester,
      provider,
      settings,
      updates: updates,
      reviews: reviews,
    );

    expect(updates.checked, 1);
    expect(updates.started, 0);
    expect(reviews.asked, 1);
    // Nothing was offered, so nothing was spent (UPD-4).
    expect(settings.updateAskedOn, isNull);
  });

  testWidgets(
    'a second entry the same day asks Play nothing, and the rating still '
    'waits for another day, not just for the save the update was offered '
    'on (UPD-3, UPD-4, rules-22-25-31-35#7)',
    (tester) async {
      final (provider, settings) = await established(
        askedOn: today.toUtc().toIso8601String(),
      );
      final updates = FakeUpdates(offered: true);
      final reviews = FakeReviews(appVersion: '1.26.0+38');

      await saveAnEntry(
        tester,
        provider,
        settings,
        updates: updates,
        reviews: reviews,
      );

      expect(updates.checked, 0);
      expect(updates.started, 0);
      expect(reviews.asked, 0);

      // A third save, still the same day: the rating still waits.
      await saveAnEntry(
        tester,
        provider,
        settings,
        updates: updates,
        reviews: reviews,
      );

      expect(reviews.asked, 0);
    },
  );

  testWidgets('a build with no Play behind it asks nothing (UPD-5)', (
    tester,
  ) async {
    final (provider, settings) = await established();
    final updates = FakeUpdates(supported: false, offered: true);
    final reviews = FakeReviews(appVersion: '1.26.0+38');

    await saveAnEntry(
      tester,
      provider,
      settings,
      updates: updates,
      reviews: reviews,
    );

    expect(updates.checked, 0);
    // The rating is not held up by an update that was never possible.
    expect(reviews.asked, 1);
  });
}
