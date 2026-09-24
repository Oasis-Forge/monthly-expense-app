import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/screens/amount_style.dart';

void main() {
  final currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  /// The contrast between two colours, the way WCAG works it out.
  double contrast(Color a, Color b) {
    final one = a.computeLuminance();
    final two = b.computeLuminance();
    return (([one, two]..sort()).last + 0.05) /
        (([one, two]..sort()).first + 0.05);
  }

  Future<BuildContext> themed(
    WidgetTester tester,
    Brightness brightness,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    // MaterialApp fades between themes, so the first frames after a switch
    // still carry the old one.
    await tester.pumpAndSettle();
    return captured;
  }

  group('one way of writing money (CUR-4, CUR-5)', () {
    testWidgets('the two colours are the app own pair, and answer the theme', (
      tester,
    ) async {
      final light = await themed(tester, Brightness.light);
      final lightIncome = incomeColor(light);
      final lightExpense = expenseColor(light);
      expect(lightIncome, isNot(Colors.green));
      expect(lightExpense, isNot(Colors.red));

      final dark = await themed(tester, Brightness.dark);
      expect(incomeColor(dark), isNot(lightIncome));
      expect(expenseColor(dark), isNot(lightExpense));
    });

    testWidgets('each clears 4.5:1 against the surface behind it', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        final context = await themed(tester, brightness);
        final surface = Theme.of(context).colorScheme.surface;
        expect(
          contrast(incomeColor(context), surface),
          greaterThanOrEqualTo(4.5),
          reason: 'income on $brightness',
        );
        expect(
          contrast(expenseColor(context), surface),
          greaterThanOrEqualTo(4.5),
          reason: 'expense on $brightness',
        );
      }
    });

    testWidgets(
      'a figure that can fall either way is coloured below zero only',
      (tester) async {
        final context = await themed(tester, Brightness.light);
        expect(balanceColor(context, const Money(1)), isNull);
        expect(balanceColor(context, Money.zero), isNull);
        expect(balanceColor(context, const Money(-1)), expenseColor(context));
      },
    );

    test('money in takes a plus, money out a minus', () {
      expect(
        signedAmount(currency, const Money(12500), isIncome: true),
        r'+$12.50',
      );
      expect(
        signedAmount(currency, const Money(12500), isIncome: false),
        r'-$12.50',
      );
    });

    test('amounts are set in figures of one width, keeping the rest', () {
      expect(
        amountStyle().fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      final kept = amountStyle(const TextStyle(fontSize: 20));
      expect(kept.fontSize, 20);
      expect(kept.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });

  group('the figure counts to its new value (BAL-10)', () {
    Future<void> show(
      WidgetTester tester,
      Money amount, {
      bool still = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: still),
            child: RollingAmount(amount: amount, currency: currency),
          ),
        ),
      );
    }

    testWidgets('it is right from the first frame', (tester) async {
      await show(tester, const Money(12500));

      expect(find.text(r'$12.50'), findsOneWidget);
    });

    testWidgets('a new value is counted to rather than cut to', (tester) async {
      await show(tester, const Money(12500));
      await show(tester, const Money(20000));
      await tester.pump(const Duration(milliseconds: 40));

      // On the way: neither where it was nor where it is going.
      expect(find.text(r'$12.50'), findsNothing);
      expect(find.text(r'$20.00'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text(r'$20.00'), findsOneWidget);
    });

    testWidgets('a phone asking for less motion is given it at once', (
      tester,
    ) async {
      await show(tester, const Money(12500), still: true);
      await show(tester, const Money(20000), still: true);
      await tester.pump();

      expect(find.text(r'$20.00'), findsOneWidget);
    });
  });
}
