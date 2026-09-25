import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/amount_style.dart';
import 'package:monthly_expense_app/screens/budget_progress.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/theme.dart';

import 'helpers.dart';

void main() {
  const black = Color(0xFF000000);

  /// The contrast between two colours, the way WCAG works it out.
  double contrast(Color a, Color b) {
    final pair = [a.computeLuminance(), b.computeLuminance()]..sort();
    return (pair.last + 0.05) / (pair.first + 0.05);
  }

  group('appTheme (THEME-1, THEME-2)', () {
    test('the app own colour where the phone offers no palette', () {
      final light = appTheme(brightness: Brightness.light);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(
        light.colorScheme.primary,
        ColorScheme.fromSeed(seedColor: appSeed).primary,
      );
    });

    test('the phone palette is used where it is offered', () {
      final fromPhone = ColorScheme.fromSeed(
        seedColor: const Color(0xFF00897B),
      );
      final theme = appTheme(
        fromPhone: fromPhone,
        brightness: Brightness.light,
      );
      expect(theme.colorScheme.primary, fromPhone.primary);
      expect(theme.colorScheme.primary, isNot(appSeed));
    });

    test('black puts true black behind dark', () {
      final theme = appTheme(brightness: Brightness.dark, black: true);
      expect(theme.colorScheme.surface, black);
      expect(theme.scaffoldBackgroundColor, black);
      expect(theme.canvasColor, black);
    });

    test('dark on its own keeps the surface the scheme chose', () {
      final theme = appTheme(brightness: Brightness.dark);
      expect(theme.colorScheme.surface, isNot(black));
      expect(theme.scaffoldBackgroundColor, isNot(black));
    });

    test('black does nothing at all to light', () {
      final theme = appTheme(brightness: Brightness.light, black: true);
      expect(theme.colorScheme.surface, isNot(black));
      expect(theme.scaffoldBackgroundColor, isNot(black));
    });
  });

  group('the amount colours survive every choice (THEME-4, A11Y-3)', () {
    // A wallpaper may repaint the app. It may not make income or expense
    // harder to read than 4.5:1 on the surface they sit on.
    final palettes = <String, ColorScheme?>{
      'the app own seed': null,
      'a teal wallpaper': ColorScheme.fromSeed(
        seedColor: const Color(0xFF00897B),
        brightness: Brightness.dark,
      ),
      'a red wallpaper': ColorScheme.fromSeed(
        seedColor: const Color(0xFFD32F2F),
        brightness: Brightness.dark,
      ),
    };

    for (final entry in palettes.entries) {
      test('on black, under ${entry.key}', () {
        final theme = appTheme(
          fromPhone: entry.value,
          brightness: Brightness.dark,
          black: true,
        );
        final surface = theme.colorScheme.surface;
        expect(surface, black);
        expect(
          contrast(const Color(incomeInkDark), surface),
          greaterThanOrEqualTo(4.5),
          reason: 'income must stay readable on black',
        );
        expect(
          contrast(const Color(expenseInkDark), surface),
          greaterThanOrEqualTo(4.5),
          reason: 'expense must stay readable on black',
        );
      });
    }

    test('colour alone never separates income from expense (A11Y-4)', () {
      // The two inks are all but the same brightness, so a greyscale screen,
      // or an eye that cannot tell red from green, cannot tell them apart.
      // That is allowed only because the sign carries the meaning and is
      // always in front of the figure (CUR-5).
      expect(
        contrast(const Color(incomeInkDark), const Color(expenseInkDark)),
        lessThan(1.5),
        reason: 'if the two inks ever do differ in brightness, say so here',
      );
      final currency = NumberFormat.currency(
        locale: 'en_US',
        symbol: r'$',
        decimalDigits: 2,
      );
      expect(
        signedAmount(currency, const Money(10000), isIncome: true),
        startsWith('+'),
      );
      expect(
        signedAmount(currency, const Money(10000), isIncome: false),
        startsWith('-'),
      );
    });
  });

  group('budget bar colours (THEME-4, A11Y-3, BUD-8)', () {
    final seeds = <String, Color?>{
      'the app own seed': null,
      'a red wallpaper': const Color(0xFFD32F2F),
      'an orange wallpaper': const Color(0xFFE65100),
    };

    for (final brightness in Brightness.values) {
      for (final entry in seeds.entries) {
        test('ok and warning clear 4.5:1 under ${entry.key}, '
            '${brightness.name}', () {
          final fromPhone = entry.value == null
              ? null
              : ColorScheme.fromSeed(
                  seedColor: entry.value!,
                  brightness: brightness,
                );
          final theme = appTheme(fromPhone: fromPhone, brightness: brightness);
          final dark = brightness == Brightness.dark;
          final ok = Color(dark ? budgetOkDark : budgetOkLight);
          final warning = Color(dark ? budgetWarningDark : budgetWarningLight);
          for (final bg in [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerLow,
          ]) {
            expect(
              contrast(ok, bg),
              greaterThanOrEqualTo(4.5),
              reason: 'an OK budget must stay readable on $bg',
            );
            expect(
              contrast(warning, bg),
              greaterThanOrEqualTo(4.5),
              reason: 'a warning budget must stay readable on $bg',
            );
          }
        });
      }
    }

    testWidgets('an OK budget keeps its own colour whatever the wallpaper '
        'is (THEME-4)', (tester) async {
      Future<Color> okColorUnder(ColorScheme? fromPhone) async {
        late Color result;
        await tester.pumpWidget(
          MaterialApp(
            theme: appTheme(fromPhone: fromPhone, brightness: Brightness.light),
            home: Builder(
              builder: (context) {
                result = budgetLevelColor(context, BudgetLevel.ok);
                return const SizedBox();
              },
            ),
          ),
        );
        return result;
      }

      final appOwn = await okColorUnder(null);
      final redWallpaper = await okColorUnder(
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          brightness: Brightness.light,
        ),
      );

      expect(appOwn, const Color(budgetOkLight));
      expect(
        redWallpaper,
        appOwn,
        reason:
            'an OK budget must keep its own hue whatever the wallpaper is '
            '(THEME-4); it must not follow colorScheme.primary',
      );
    });

    for (final brightness in Brightness.values) {
      testWidgets('a warning budget draws the darkened warning colour, '
          '${brightness.name} (A11Y-3, pr58_4)', (tester) async {
        late Color result;
        await tester.pumpWidget(
          MaterialApp(
            theme: appTheme(brightness: brightness),
            home: Builder(
              builder: (context) {
                result = budgetLevelColor(context, BudgetLevel.warning);
                return const SizedBox();
              },
            ),
          ),
        );

        final dark = brightness == Brightness.dark;
        expect(
          result,
          Color(dark ? budgetWarningDark : budgetWarningLight),
          reason:
              'putting Colors.orange back in the warning branch must fail '
              'this test',
        );
      });
    }
  });

  group('day header colour (A11Y-3, DAY-7)', () {
    final seeds = <String, Color?>{
      'the app own seed': null,
      'a red wallpaper': const Color(0xFFD32F2F),
      'an orange wallpaper': const Color(0xFFE65100),
    };

    for (final brightness in Brightness.values) {
      for (final entry in seeds.entries) {
        test('clears 4.5:1 under ${entry.key}, ${brightness.name}', () {
          final fromPhone = entry.value == null
              ? null
              : ColorScheme.fromSeed(
                  seedColor: entry.value!,
                  brightness: brightness,
                );
          final theme = appTheme(fromPhone: fromPhone, brightness: brightness);
          final dark = brightness == Brightness.dark;
          final ink = Color(dark ? dayHeaderInkDark : dayHeaderInkLight);
          for (final bg in [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerLow,
          ]) {
            expect(
              contrast(ink, bg),
              greaterThanOrEqualTo(4.5),
              reason: 'a day header must stay readable on $bg',
            );
          }
        });
      }
    }

    for (final brightness in Brightness.values) {
      testWidgets(
        'Home draws the day header in dayHeaderColor, ${brightness.name} '
        '(A11Y-3, DAY-7, pr58_4)',
        (tester) async {
          final today = DateTime(2026, 9, 15, 10);
          final fake = FakeDB(
            transactions: [
              testTx(
                'a',
                TransactionType.expense,
                12.5,
                DateTime(2026, 9, 15),
                title: 'Lunch',
              ),
            ],
          );
          final provider = TransactionProvider(db: fake, clock: () => today);
          await provider.load();
          final settings = await testSettings();

          await tester.pumpWidget(
            testApp(
              provider,
              settings,
              Theme(
                data: appTheme(brightness: brightness),
                child: const HomeScreen(),
              ),
            ),
          );
          await tester.pump();

          // Sep 16 holds nothing, unlike Sep 15 (DAY-7).
          await tester.tap(find.text('16'));
          await tester.pumpAndSettle();

          final dark = brightness == Brightness.dark;
          final expected = Color(dark ? dayHeaderInkDark : dayHeaderInkLight);

          final dateText = tester.widget<Text>(find.text('Sep 16, 2026'));
          expect(
            dateText.style?.color,
            expected,
            reason:
                'putting Colors.grey.shade600 back in _DaySection must fail '
                'this test',
          );

          final emptyText = tester.widget<Text>(
            find.text('Nothing on this day.'),
          );
          expect(emptyText.style?.color, expected);
        },
      );
    }
  });
}
