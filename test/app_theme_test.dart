import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/models/app_theme.dart';

void main() {
  group('AppTheme (THEME-1)', () {
    test('black asks Flutter for dark, because that is what it is', () {
      expect(AppTheme.black.themeMode, ThemeMode.dark);
      expect(AppTheme.black.isBlack, isTrue);
    });

    test('the other three ask for their own brightness and are not black', () {
      expect(AppTheme.system.themeMode, ThemeMode.system);
      expect(AppTheme.light.themeMode, ThemeMode.light);
      expect(AppTheme.dark.themeMode, ThemeMode.dark);
      for (final theme in [AppTheme.system, AppTheme.light, AppTheme.dark]) {
        expect(theme.isBlack, isFalse, reason: '${theme.name} is not black');
      }
    });

    test('the three values older versions stored carry over unchanged', () {
      for (final name in ['system', 'light', 'dark']) {
        expect(AppTheme.named(name).name, name);
      }
    });

    test('a missing or unknown value follows the phone', () {
      expect(AppTheme.named(null), AppTheme.system);
      expect(AppTheme.named('midnight'), AppTheme.system);
    });
  });
}
