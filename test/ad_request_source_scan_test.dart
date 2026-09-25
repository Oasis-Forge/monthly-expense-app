import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ADS-7: "The ad SDK is handed nothing from the app: no amounts, titles,
/// notes, categories, accounts, attachments, or search terms, and no
/// keywords derived from them." ADS-15 extends the same guarantee to the
/// full-screen ad.
///
/// The only thing enforcing that today is `const AdRequest()` at the two
/// call sites in ad_service.dart, plus a comment. DeviceAdService.loadBanner
/// and loadInterstitial never run for real anywhere else in the suite
/// (Windows/Linux take the NoAdService path, and every AdsProvider test uses
/// a fake), so a later change that slipped `keywords:` or `contentUrl:` onto
/// either request would pass every other test. This scans the actual
/// source instead: every `AdRequest(` in lib/ must be the literal,
/// argument-free `const AdRequest()`, and the SDK's own package is imported
/// nowhere but the one service built around it.
void main() {
  test('every AdRequest in lib/ is const and carries no targeting (ADS-7, '
      'ADS-15, rules-22-25-31-35#4)', () {
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final contents = entity.readAsStringSync();
      for (final match in RegExp(
        r'(const\s+)?AdRequest\(([^)]*)\)',
      ).allMatches(contents)) {
        final isConst = match.group(1) != null;
        final args = match.group(2)!.trim();
        if (!isConst || args.isNotEmpty) {
          offenders.add('${entity.path}: "${match.group(0)}"');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Found AdRequest construction(s) that are not the plain '
          '`const AdRequest()`, which would hand the SDK targeting data '
          '(ADS-7, ADS-15):\n${offenders.join('\n')}',
    );
  });

  test('only ad_service.dart talks to package:google_mobile_ads, and it '
      "imports nothing that could hand the SDK the user's own records "
      '(ADS-7, ADS-15, rules-22-25-31-35#4)', () {
    const allowedImporter = 'lib/services/ad_service.dart';
    final sdkImporters = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll('\\', '/');
      final contents = entity.readAsStringSync();
      if (contents.contains('package:google_mobile_ads') &&
          path != allowedImporter) {
        sdkImporters.add(path);
      }
      if (path == allowedImporter) {
        for (final forbidden in ['models/', 'db/', 'providers/']) {
          expect(
            contents.contains("import '../$forbidden"),
            isFalse,
            reason:
                '$allowedImporter must not import from lib/$forbidden, '
                'the shortest path a later change could use to hand the '
                "SDK the user's own records (ADS-7)",
          );
        }
      }
    }
    expect(
      sdkImporters,
      isEmpty,
      reason:
          'Only $allowedImporter should import package:google_mobile_ads; '
          'found it in: ${sdkImporters.join(', ')}',
    );
  });
}
