import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/rating.dart';
import 'package:monthly_expense_app/models/transaction.dart';
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
    final provider = TransactionProvider(
      db: FakeDB(
        transactions: [
          for (var i = 0; i < ratingEntries; i++)
            testTx('t$i', TransactionType.expense, 5, DateTime(2026, 9, 10)),
        ],
      ),
      clock: () => today,
    );
    await provider.load();
    final settings = await testSettings({
      'first_opened_at': DateTime(2026, 9, 10).toIso8601String(),
      'update_asked_on': ?askedOn,
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

  testWidgets('a second entry the same day asks Play nothing (UPD-4)', (
    tester,
  ) async {
    final (provider, settings) = await established(
      askedOn: today.toUtc().toIso8601String(),
    );
    final updates = FakeUpdates(offered: true);

    await saveAnEntry(
      tester,
      provider,
      settings,
      updates: updates,
      reviews: FakeReviews(supported: false),
    );

    expect(updates.checked, 0);
    expect(updates.started, 0);
  });

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
