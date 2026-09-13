import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/l10n/languages.dart';

Map<String, Object?> _arb(String language) =>
    jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync())
        as Map<String, Object?>;

/// Matches `{name}` and the start of `{name, plural, …}`.
RegExp _uses(String name) => RegExp('${RegExp.escape('{$name')}[,}]');

RegExp _choice(String name, String kind) =>
    RegExp('${RegExp.escape('{$name')}, *$kind,');

void main() {
  final english = _arb('en');
  final messages = [
    for (final key in english.keys)
      if (!key.startsWith('@')) key,
  ];

  test('every app language has generated localizations (LANG-1)', () {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      unorderedEquals(appLanguages.keys),
    );
  });

  test('the device language is used when the app has it, else English '
      '(LANG-1)', () {
    expect(resolveAppLocale(const [Locale('tr', 'TR')]), const Locale('tr'));
    expect(
      resolveAppLocale(const [Locale('ja'), Locale('de', 'AT')]),
      const Locale('de'),
    );
    expect(resolveAppLocale(const [Locale('ja')]), const Locale('en'));
    expect(resolveAppLocale(null), const Locale('en'));
  });

  for (final language in appLanguages.keys.where((code) => code != 'en')) {
    test('$language has every message with the same placeholders (LANG-2)', () {
      final translated = _arb(language);
      expect(translated['@@locale'], language);
      expect(
        translated.keys.where((key) => !key.startsWith('@')),
        unorderedEquals(messages),
      );

      for (final key in messages) {
        final source = english[key]! as String;
        final target = translated[key]! as String;
        final metadata = english['@$key'] as Map<String, Object?>?;
        final placeholders =
            (metadata?['placeholders'] as Map<String, Object?>?)?.keys ??
            const <String>[];

        expect(target.trim(), isNotEmpty, reason: '$language $key is empty');
        expect(
          '{'.allMatches(target).length,
          '}'.allMatches(target).length,
          reason: '$language $key has unbalanced braces',
        );
        for (final name in placeholders) {
          expect(
            _uses(name).hasMatch(target),
            isTrue,
            reason: '$language $key misses {$name}',
          );
          for (final kind in const ['plural', 'select']) {
            expect(
              _choice(name, kind).hasMatch(target),
              _choice(name, kind).hasMatch(source),
              reason: '$language $key: {$name, $kind} differs from English',
            );
          }
        }
        if (RegExp(', *(plural|select),').hasMatch(source)) {
          expect(
            target,
            contains('other{'),
            reason: '$language $key needs an "other" case',
          );
        }
      }
    });
  }
}
