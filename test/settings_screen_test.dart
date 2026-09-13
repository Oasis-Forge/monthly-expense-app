import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/accounts_screen.dart';
import 'package:monthly_expense_app/screens/categories_screen.dart';
import 'package:monthly_expense_app/screens/settings_screen.dart';
import 'package:monthly_expense_app/screens/trash_screen.dart';

import 'helpers.dart';

void main() {
  late SettingsProvider settings;
  late TransactionProvider provider;

  setUp(() async {
    settings = await testSettings();
    provider = TransactionProvider(
      db: FakeDB(),
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
  });

  Future<void> showSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      testApp(provider, settings, const SettingsScreen()),
    );
    await tester.pump();
  }

  Future<void> chooseEuro(WidgetTester tester) async {
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'euro');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Euro'));
    await tester.pumpAndSettle();
  }

  testWidgets('changing the currency asks first, then applies (CUR-3)', (
    tester,
  ) async {
    await showSettings(tester);
    expect(find.text('USD · US Dollar'), findsOneWidget);

    await chooseEuro(tester);
    expect(find.text('Change currency to EUR?'), findsOneWidget);
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();

    expect(settings.currencyCode, 'EUR');
    expect(find.text('EUR · Euro'), findsOneWidget);
  });

  testWidgets('cancelling keeps the current currency', (tester) async {
    await showSettings(tester);

    await chooseEuro(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(settings.currencyCode, 'USD');
  });

  testWidgets('a device currency missing from the list is still offered', (
    tester,
  ) async {
    settings = await testSettings({'currency_code': 'XOF'});
    await showSettings(tester);
    expect(find.text('XOF'), findsOneWidget);

    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();

    expect(find.widgetWithIcon(ListTile, Icons.check), findsOneWidget);
  });

  testWidgets('the theme can be switched to dark', (tester) async {
    await showSettings(tester);

    await tester.tap(find.byType(DropdownButton<ThemeMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(settings.themeMode, ThemeMode.dark);
  });

  testWidgets('the month start day moves the selected period (PER-2)', (
    tester,
  ) async {
    await showSettings(tester);

    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();

    expect(settings.startDay, 2);
    expect(provider.period.start, DateTime(2026, 9, 2));
  });

  testWidgets('carrying the balance forward can be turned off (BAL-3)', (
    tester,
  ) async {
    await showSettings(tester);

    await tester.tap(find.text('Carry balance forward'));
    await tester.pumpAndSettle();

    expect(settings.showCarriedForward, isFalse);
  });

  testWidgets('Accounts, Categories, and Trash open their screens', (
    tester,
  ) async {
    await showSettings(tester);

    for (final (label, screen) in [
      ('Accounts', AccountsScreen),
      ('Categories', CategoriesScreen),
      ('Trash', TrashScreen),
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget, reason: label);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
