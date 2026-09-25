import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/screens/amount_style.dart';
import 'package:monthly_expense_app/screens/budget_progress.dart';
import 'package:monthly_expense_app/screens/theme.dart';

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
        test('ok clears 4.5:1 under ${entry.key}, '
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
          for (final bg in [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerLow,
          ]) {
            expect(
              contrast(ok, bg),
              greaterThanOrEqualTo(4.5),
              reason: 'an OK budget must stay readable on $bg',
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
  });
}
