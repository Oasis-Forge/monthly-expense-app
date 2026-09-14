import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transaction_filter.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/report_screen.dart';

import 'helpers.dart';

void main() {
  late FakeDB fake;
  late TransactionProvider provider;
  late SettingsProvider settings;

  setUp(() async {
    fake = FakeDB(
      transactions: [
        testTx('a', TransactionType.expense, 25, DateTime(2026, 9, 4)),
        testTx('b', TransactionType.income, 900, DateTime(2026, 9, 2)),
        testTx('old', TransactionType.expense, 12, DateTime(2025, 4, 3)),
      ],
    );
    provider = TransactionProvider(
      db: fake,
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings();
  });

  Future<void> showReport(
    WidgetTester tester, {
    TransactionFilter? filter,
  }) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(provider, settings, ReportScreen(filter: filter)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it opens on this period, with the other ranges offered '
      '(PDF-1)', (tester) async {
    await showReport(tester);

    expect(find.text('This period'), findsOneWidget);
    expect(find.text('Dates'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    // No date fields until Dates is chosen.
    expect(find.text('From'), findsNothing);
  });

  testWidgets('choosing Dates reveals a from and a to (PDF-1)', (tester) async {
    await showReport(tester);

    await tester.tap(find.text('Dates'));
    await tester.pumpAndSettle();

    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
  });

  testWidgets('choosing Year offers the years there is data for (PDF-1)', (
    tester,
  ) async {
    await showReport(tester);

    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();

    expect(find.text('2026'), findsWidgets);
    expect(find.text('2025'), findsWidgets);
  });

  testWidgets('opened from Search, it starts on that search\'s dates '
      '(PDF-1)', (tester) async {
    await showReport(
      tester,
      filter: TransactionFilter(
        from: DateTime(2026, 9, 3),
        to: DateTime(2026, 9, 9),
      ),
    );

    // Dates is already chosen, so the fields are showing.
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
  });

  testWidgets('every account is offered, plus all of them together '
      '(PDF-1)', (tester) async {
    await showReport(tester);

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();

    expect(find.text('All accounts'), findsWidgets);
    // testAccount names each account after its ID.
    expect(find.text('acc-cash'), findsWidgets);
  });

  testWidgets('turning the transaction list off greys what it contains '
      '(PDF-3)', (tester) async {
    await showReport(tester);

    SwitchListTile tile(String label) => tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, label),
    );

    expect(tile('Titles and notes').onChanged, isNotNull);
    expect(tile('Account names').onChanged, isNotNull);

    await tester.tap(
      find.widgetWithText(SwitchListTile, 'The transaction list'),
    );
    await tester.pumpAndSettle();

    expect(tile('Titles and notes').onChanged, isNull);
    expect(tile('Account names').onChanged, isNull);
  });

  testWidgets('a backwards range is refused rather than built (PDF-1)', (
    tester,
  ) async {
    // Seeded backwards, which the screen has to catch before it builds.
    await showReport(
      tester,
      filter: TransactionFilter(
        from: DateTime(2026, 9, 20),
        to: DateTime(2026, 9, 1),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pumpAndSettle();

    expect(
      find.text('The first date has to come before the last.'),
      findsOneWidget,
    );
  });
}
