import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/l10n/languages.dart';

/// Android resolves resources by its own (sometimes legacy) language
/// qualifier, not always the app's ISO code: `ResourcesImpl.adjustLanguageTag`
/// maps `id` to `in` and `he` to `iw` (and, if the app ever adds Yiddish,
/// `yi` to `ji`). A `values-id` folder is simply never read by the resource
/// system (rules-14-19_10).
const _androidResourceQualifier = {'id': 'in', 'he': 'iw', 'yi': 'ji'};

String _qualifierFor(String code) => _androidResourceQualifier[code] ?? code;

/// The Android widget picker's strings live outside the ARB files, in
/// per-locale `widget_strings.xml` resource files (LANG-2, WID-6). Nothing
/// generates or checks them the way `flutter gen-l10n` and test/l10n_test.dart
/// do for everything else, so a language could be added to the app (LANG-1)
/// without ever getting its own widget strings.
void main() {
  test('every app language has its own Android widget_strings.xml, under '
      "Android's own resource qualifier (LANG-2, WID-6, rules-14-19_10)", () {
    final missing = <String>[
      for (final code in appLanguages.keys)
        if (code != 'en' &&
            !File(
              'android/app/src/main/res/values-${_qualifierFor(code)}/'
              'widget_strings.xml',
            ).existsSync())
          code,
    ];

    expect(
      missing,
      isEmpty,
      reason:
          'These languages fall back to the English widget picker text: '
          '$missing',
    );
  });

  test('every widget_strings.xml has the same set of string names (LANG-2, '
      'WID-6)', () {
    final englishFile = File(
      'android/app/src/main/res/values/widget_strings.xml',
    );
    final nameRe = RegExp(r'<string name="([^"]+)">');
    final englishNames = nameRe
        .allMatches(englishFile.readAsStringSync())
        .map((m) => m.group(1))
        .toSet();
    expect(englishNames, isNotEmpty);

    for (final code in appLanguages.keys.where((c) => c != 'en')) {
      final file = File(
        'android/app/src/main/res/values-${_qualifierFor(code)}/'
        'widget_strings.xml',
      );
      final names = nameRe
          .allMatches(file.readAsStringSync())
          .map((m) => m.group(1))
          .toSet();
      expect(
        names,
        englishNames,
        reason:
            '${_qualifierFor(code)}/widget_strings.xml is missing or has '
            'extra strings',
      );
    }
  });
}
