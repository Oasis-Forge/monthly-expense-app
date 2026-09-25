import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/rating.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';

import 'helpers.dart';

void main() {
  final today = DateTime(2026, 9, 24, 10);
  final amountField = find.widgetWithText(TextFormField, 'Amount');

  /// A device that opened the app a fortnight ago and has saved [entries] by
  /// hand, which is both of RATE-1's lines crossed unless [entries] says
  /// otherwise (pr57#10: RATE-1 counts only entries typed in and saved
  /// through the form, not the transaction list's length).
  Future<(TransactionProvider, SettingsProvider)> established({
    int entries = ratingEntries,
    String? askedVersion,
  }) async {
    final provider = TransactionProvider(db: FakeDB(), clock: () => today);
    await provider.load();
    final settings = await testSettings({
      'first_opened_at': DateTime(2026, 9, 10).toIso8601String(),
      'rating_asked_version': ?askedVersion,
      'manual_entries_recorded': entries,
    });
    return (provider, settings);
  }

  Future<void> saveAnEntry(
    WidgetTester tester,
    TransactionProvider provider,
    SettingsProvider settings,
    FakeReviews reviews, {
    ValueListenable<bool>? locked,
  }) async {
    usePhoneScreen(tester);
    // A saved entry closes the form, so each save starts from a fresh tree
    // rather than the popped one the last save left behind.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        const AddTransactionScreen(),
        reviews: reviews,
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

  testWidgets('a saved entry asks, once, and the version is spent (RATE-3, '
      'RATE-4)', (tester) async {
    final (provider, settings) = await established();
    final reviews = FakeReviews(appVersion: '1.25.0+37');

    await saveAnEntry(tester, provider, settings, reviews);

    expect(reviews.asked, 1);
    // RATE-4: written before the store was asked, and whatever it did.
    expect(settings.ratingAskedVersion, '1.25.0+37');

    // A second entry in the same version says nothing more.
    await saveAnEntry(tester, provider, settings, reviews);
    expect(reviews.asked, 1);
  });

  testWidgets('someone with three entries is not asked (RATE-1)', (
    tester,
  ) async {
    final (provider, settings) = await established(entries: 3);
    final reviews = FakeReviews(appVersion: '1.25.0+37');

    await saveAnEntry(tester, provider, settings, reviews);

    expect(reviews.asked, 0);
    expect(settings.ratingAskedVersion, isNull);
  });

  testWidgets('a build with no store asks nothing (RATE-5)', (tester) async {
    final (provider, settings) = await established();
    final reviews = FakeReviews(supported: false);

    await saveAnEntry(tester, provider, settings, reviews);

    expect(reviews.asked, 0);
    expect(settings.ratingAskedVersion, isNull);
  });

  testWidgets(
    'imported, recurring, and restored rows are not entries typed in by '
    'hand (RATE-1, pr57#10)',
    (tester) async {
      final provider = TransactionProvider(
        db: FakeDB(
          transactions: [
            // A history far past RATE-1's fifteen -- but none of it typed
            // in by hand, so it must not read as an opinion (pr57#10).
            for (var i = 0; i < ratingEntries * 3; i++)
              testTx('t$i', TransactionType.expense, 5, DateTime(2026, 9, 10)),
          ],
        ),
        clock: () => today,
      );
      await provider.load();
      final settings = await testSettings({
        'first_opened_at': DateTime(2026, 9, 10).toIso8601String(),
        'manual_entries_recorded': 1,
      });
      final reviews = FakeReviews(appVersion: '1.25.0+37');

      await saveAnEntry(tester, provider, settings, reviews);

      expect(reviews.asked, 0);
      expect(settings.ratingAskedVersion, isNull);
    },
  );

  testWidgets('never over a lock screen, even with everything else due '
      '(RATE-3)', (tester) async {
    final (provider, settings) = await established();
    final reviews = FakeReviews(appVersion: '1.25.0+37');

    await saveAnEntry(
      tester,
      provider,
      settings,
      reviews,
      locked: ValueNotifier(true),
    );

    expect(reviews.asked, 0);
    expect(settings.ratingAskedVersion, isNull);
  });
}
