// Basic smoke test for the Monthly Expense app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:monthly_expense_app/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App starts and shows the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MonthlyExpenseApp());
    await tester.pump();

    expect(find.text('Monthly Expenses'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
