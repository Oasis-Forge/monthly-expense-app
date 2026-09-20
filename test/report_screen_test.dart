import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/report.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/models/transaction_filter.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/providers/ads_provider.dart';
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

  /// Pumps until [finder] matches, or gives up. The preview never settles in
  /// a widget test — PdfPreview keeps a spinner going, because rasterising a
  /// PDF needs the platform — so pumpAndSettle can't be used past it.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int frames = 100,
  }) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

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

  testWidgets('in a language with no face it explains instead of offering a '
      'report (PDF-7)', (tester) async {
    settings = await testSettings({'language': 'ja'});

    await showReport(tester);

    expect(find.text('この言語はまだ利用できません'), findsOneWidget);
    // None of the choosing is there: there is nothing to choose.
    expect(find.byType(SegmentedButton<ReportRange>), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
  });

  testWidgets('a language with a face still gets the form (PDF-7)', (
    tester,
  ) async {
    settings = await testSettings({'language': 'hi'});

    await showReport(tester);

    expect(find.byType(SegmentedButton<ReportRange>), findsOneWidget);
  });

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

  testWidgets('creating shows progress, then the preview (PDF-4, PDF-6)', (
    tester,
  ) async {
    await showReport(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pump();

    expect(find.text('Building the report'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // PDF-4: nothing to share or print until the report exists.
    expect(find.byIcon(Icons.share), findsNothing);

    await pumpUntil(tester, find.text('Report'));

    expect(find.text('Building the report'), findsNothing);
    expect(find.text('Report'), findsOneWidget);
  });

  testWidgets('closing the preview is a seam for the full-screen ad '
      '(ADS-11)', (tester) async {
    // A seam shows one to someone who has done ten things today and did
    // not install the app on this run (ADS-12).
    provider = TransactionProvider(
      db: FakeDB(
        transactions: [
          for (var i = 0; i < 12; i++)
            testTx('t$i', TransactionType.expense, 5, DateTime(2026, 9, 4)),
        ],
      ),
      clock: () => DateTime(2026, 9, 15),
    );
    await provider.load();
    settings = await testSettings({
      'setup_done': true,
      'walkthrough_seen': true,
      'first_opened_at': DateTime(2026, 1, 1).toUtc().toIso8601String(),
      'ad_activity': SettingsProvider.adActivityThreshold,
      'ad_activity_day': DateTime.now().toUtc().toIso8601String(),
    });
    final ads = FakeAdService(canStart: true, interstitialFills: true);
    usePhoneScreen(tester);
    await tester.pumpWidget(
      testApp(provider, settings, const ReportScreen(), ads: ads),
    );
    await tester.pumpAndSettle();
    // In the app the SDK started long ago; here the provider is built on
    // its first read, so this is what a running app already has (ADS-4).
    Provider.of<AdsProvider>(
      tester.element(find.byType(ReportScreen)),
      listen: false,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pump();
    await pumpUntil(tester, find.text('Report'));
    expect(ads.interstitialsShown, 0, reason: 'not over the report itself');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(ads.interstitialsShown, 1);
  });

  testWidgets('cancelling leaves you on the options, with no report '
      '(PDF-6)', (tester) async {
    await showReport(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Building the report'), findsNothing);
    expect(find.text('Report'), findsNothing);
    expect(find.text('Create the report'), findsOneWidget);
  });

  testWidgets('a report can still be created after one is cancelled', (
    tester,
  ) async {
    await showReport(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create the report'));
    await pumpUntil(tester, find.text('Report'));

    expect(find.text('Report'), findsOneWidget);
  });
}
