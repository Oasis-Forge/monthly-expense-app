// Basic smoke test for the Monthly Expense app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/services/home_widget_service.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// Starts the whole app over [values]. Deliberately not the device's
  /// services: no test should reach the platform.
  Future<void> startApp(
    WidgetTester tester, [
    Map<String, Object> values = const {},
  ]) async {
    await tester.pumpWidget(
      MonthlyExpenseApp(
        settings: await testSettings(values),
        homeWidget: const NoopHomeWidgetService(),
      ),
    );
    await tester.pump();
  }

  testWidgets('App starts and shows the home screen', (
    WidgetTester tester,
  ) async {
    await startApp(tester, {'setup_done': true, 'walkthrough_seen': true});

    expect(find.text('Monthly Expenses'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('A first launch starts at setup instead (RUN-3)', (
    WidgetTester tester,
  ) async {
    await startApp(tester);

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });
}
