import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/remove_ads_screen.dart';
import 'package:monthly_expense_app/services/purchase_service.dart';

import 'helpers.dart';

void main() {
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    provider = TransactionProvider(db: FakeDB());
    await provider.load();
    settings = await testSettings();
  });

  Future<FakePurchases> show(
    WidgetTester tester, {
    PurchaseStage stage = PurchaseStage.offered,
    String? price = 'US\$2.99',
    String? error,
  }) async {
    usePhoneScreen(tester);
    final purchases = FakePurchases(stage: stage, price: price, error: error);
    await tester.pumpWidget(
      testApp(
        provider,
        settings,
        const RemoveAdsScreen(),
        purchases: purchases,
      ),
    );
    // Not pumpAndSettle: the pending and checking stages keep a spinner
    // turning, which never settles.
    await tester.pump();
    await tester.pump();
    return purchases;
  }

  Finder buyButton() =>
      find.widgetWithText(FilledButton, 'Remove ads for US\$2.99');

  group('the price (PAY-6)', () {
    testWidgets('comes from the store, word for word', (tester) async {
      // The app's own currency is euros, and it has nothing to do with this.
      settings = await testSettings({'currency_code': 'EUR'});

      await show(tester);

      expect(buyButton(), findsOneWidget);
      expect(find.textContaining('€'), findsNothing);
    });

    testWidgets('a store that gave no price still offers the purchase', (
      tester,
    ) async {
      await show(tester, price: null);

      expect(find.widgetWithText(FilledButton, 'Remove ads'), findsOneWidget);
    });
  });

  group('what each answer from the store looks like', () {
    testWidgets('offered: a price, and Restore beside it (PAY-5)', (
      tester,
    ) async {
      await show(tester);

      expect(buyButton(), findsOneWidget);
      expect(
        find.widgetWithText(TextButton, 'Restore purchases'),
        findsOneWidget,
      );
    });

    testWidgets('owned: no price, no button, and thanks (PAY-1)', (
      tester,
    ) async {
      await show(tester, stage: PurchaseStage.owned);

      expect(find.text('Ads are off. Thank you.'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      // Nothing left to restore either.
      expect(find.text('Restore purchases'), findsNothing);
    });

    testWidgets('nothing to sell: it says so and offers no button (PAY-3)', (
      tester,
    ) async {
      await show(tester, stage: PurchaseStage.unavailable, price: null);

      expect(
        find.text(
          'The store has nothing to sell here yet. '
          'Please try again later.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FilledButton), findsNothing);
      // Restore stays: the purchase may exist on this account already.
      expect(find.text('Restore purchases'), findsOneWidget);
    });

    testWidgets('pending: waiting, and nothing has changed yet (PAY-8)', (
      tester,
    ) async {
      await show(tester, stage: PurchaseStage.pending);

      expect(find.text('Waiting for the store…'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('a failure says you have not been charged (PAY-8)', (
      tester,
    ) async {
      await show(tester, error: 'BillingResponse.error');

      expect(
        find.text("That didn't go through, and you haven't been charged."),
        findsOneWidget,
      );
      // The purchase is still there to try again.
      expect(buyButton(), findsOneWidget);
    });
  });

  group('buying', () {
    testWidgets('the button goes to the store', (tester) async {
      final purchases = await show(tester);

      await tester.tap(buyButton());
      await tester.pump();

      expect(purchases.buys, 1);
    });

    testWidgets('Restore purchases asks the store what is owned (PAY-5)', (
      tester,
    ) async {
      final purchases = await show(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Restore purchases'));
      await tester.pump();

      expect(purchases.restores, 1);
    });

    testWidgets('a purchase that lands turns the screen over without a '
        'reopen', (tester) async {
      final purchases = await show(tester);

      purchases.settle(PurchaseStage.owned);
      await tester.pumpAndSettle();

      expect(find.text('Ads are off. Thank you.'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('Plus (PAY-3, PAY-4)', () {
    testWidgets('is named and described, with no price and no button', (
      tester,
    ) async {
      await show(tester);

      expect(find.text('Plus'), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
      expect(find.textContaining('A bank connection'), findsOneWidget);
      // The only button on the screen is the one for Remove ads.
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('the screen promises nothing is taken away', (tester) async {
      await show(tester);

      expect(
        find.text('Every feature stays free, with or without ads.'),
        findsOneWidget,
      );
    });
  });
}
