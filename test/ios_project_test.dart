import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:monthly_expense_app/l10n/languages.dart';

/// The iOS project is not Dart, nothing here can build it, and CI's unsigned
/// iOS build only proves it compiles. What it cannot prove is what App Store
/// Connect checks on upload and what a person sees on the phone: a privacy
/// manifest that is missing or not copied into the bundle, an ad network
/// missing from SKAdNetworkItems, or a system prompt left in English because
/// its translation never made it into the target. So this reads the files.

const _runner = 'Runner';
const _widget = 'MonthlyExpensesWidgetExtension';

/// Each target's folder under ios/, where its Swift and resources live.
const _folders = {_runner: 'Runner', _widget: 'MonthlyExpensesWidget'};

/// iOS names a localization by Apple's own ID, which for Simplified Chinese
/// is zh-Hans; everything else matches the app's language codes.
const _iosLocalization = {'zh': 'zh-Hans'};

String _ios(String code) => _iosLocalization[code] ?? code;

final _iosLanguages = [for (final code in appLanguages.keys) _ios(code)];

/// Android reads Indonesian from values-in (see widget_strings_l10n_test).
const _androidQualifier = {'id': 'in'};

/// Apple's required-reason API categories, what in Swift falls under each,
/// and the reasons Apple documents for them
/// (developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype).
final _requiredReasonApis = {
  'NSPrivacyAccessedAPICategoryUserDefaults': (
    uses: RegExp(r'\b(NS)?UserDefaults\b|@AppStorage'),
    reasons: {'CA92.1', '1C8F.1', 'C56D.1', 'AC6B.1'},
  ),
  'NSPrivacyAccessedAPICategoryFileTimestamp': (
    uses: RegExp(
      r'\b(creationDate|modificationDate|fileModificationDate'
      r'|contentModificationDate|creationDateKey|contentModificationDateKey'
      r'|attributesOfItem|getattrlist|getattrlistbulk|getattrlistat'
      r'|fgetattrlist|setattrlist|setattrlistat'
      r'|NSFileCreationDate|NSFileModificationDate)\b'
      r'|\b(f|l)?stat(at)?\(',
    ),
    reasons: {'DDA9.1', 'C617.1', '3B52.1', '0A2A.1'},
  ),
  'NSPrivacyAccessedAPICategorySystemBootTime': (
    uses: RegExp(r'\b(systemUptime|mach_absolute_time)\b'),
    reasons: {'35F9.1', '8FFB.1', '3D61.1'},
  ),
  'NSPrivacyAccessedAPICategoryDiskSpace': (
    uses: RegExp(
      r'\b(volumeAvailableCapacity\w*|volumeTotalCapacity\w*|systemFreeSize'
      r'|systemSize|attributesOfFileSystem)\b|\bf?statv?fs\(',
    ),
    reasons: {'85F4.1', 'E174.1', '7D9E.1', 'B728.1'},
  ),
  'NSPrivacyAccessedAPICategoryActiveKeyboards': (
    uses: RegExp(r'\bactiveInputModes\b'),
    reasons: {'3EC4.1', '54BD.1'},
  ),
};

/// Required-reason APIs that native code bundled into a target calls, where
/// that code ships no manifest of its own, so the target's manifest has to
/// declare them: per target, each category, the reasons it needs, and the
/// package in pubspec.lock whose build puts the code into the bundle.
const _bundledNativeApis = {
  _runner: {
    // sqlite3's build hook downloads a prebuilt SQLite for iOS and bundles
    // it (sqflite_common_ffi brings it in on every platform). SQLite's file
    // layer calls stat, fstat and lstat on the database files, which live
    // in the app's container.
    'NSPrivacyAccessedAPICategoryFileTimestamp': (
      package: 'sqlite3',
      reasons: {'C617.1'},
    ),
  },
};

/// The target's own Swift, without its comments, which may name an API
/// without calling it.
String _swiftOf(String target) {
  final files =
      Directory('ios/${_folders[target]}')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.swift'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  expect(files, isNotEmpty);
  return files
      .map((file) => file.readAsStringSync())
      .join('\n')
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'//[^\n]*'), '');
}

Map<String, Object?> _manifestOf(String target) => _parsePlist(
  File('ios/${_folders[target]}/PrivacyInfo.xcprivacy').readAsStringSync(),
) as Map<String, Object?>;

Map<String, Object?> _catalog(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

Map<String, Object?> _entries(Map<String, Object?> catalog) =>
    catalog['strings']! as Map<String, Object?>;

/// Every language's value for [key] in [catalog].
Map<String, String> _values(Map<String, Object?> catalog, String key) {
  final localizations =
      (_entries(catalog)[key]! as Map<String, Object?>)['localizations']!
          as Map<String, Object?>;
  return {
    for (final MapEntry(key: language, value: unit) in localizations.entries)
      language:
          ((unit! as Map<String, Object?>)['stringUnit']!
                  as Map<String, Object?>)['value']!
              as String,
  };
}

void main() {
  final project = _Project.read();
  final infoPlist = _parsePlist(
    File('ios/Runner/Info.plist').readAsStringSync(),
  ) as Map<String, Object?>;

  test('the project file parses, with no object ID used twice', () {
    // _Project.read throws on a duplicate key, which is how a copied or
    // colliding ID shows itself.
    expect(project.objects, isNotEmpty);
    expect(project.target(_runner), isNotNull);
    expect(project.target(_widget), isNotNull);
  });

  test('the readers reject what Xcode and App Store Connect would', () {
    // So "is a well-formed plist" below means something.
    for (final broken in [
      '<plist version="1.0"><dict><key>a</key></dict></plist>',
      '<plist version="1.0"><dict><key>a</key><string>b</dict></plist>',
      '<plist version="1.0"><dict><key>a</key><true/><key>a</key><true/>'
          '</dict></plist>',
      '<plist version="1.0"><dict>stray<key>a</key><true/></dict></plist>',
      '<plist version="1.0"><string>a & b</string></plist>',
      '<!-- a -- b --><plist version="1.0"><true/></plist>',
      '<plist version="1.0"><true/></plist><true/>',
    ]) {
      expect(() => _parsePlist(broken), throwsFormatException, reason: broken);
    }
    expect(
      _parsePlist(
        '<?xml version="1.0"?><!-- ok --><plist version="1.0"><dict>'
        '<key>k</key><array><string>a &amp; b</string><false/></array>'
        '</dict></plist>',
      ),
      {
        'k': ['a & b', false],
      },
    );
    for (final broken in ['{ a = 1; a = 2; }', '{ a = 1 }', '( a, b']) {
      expect(
        () => _OpenStepParser(broken).parse(),
        throwsFormatException,
        reason: broken,
      );
    }
    expect(_OpenStepParser('{ a = ( "x-y", z, ); /* c */ }').parse(), {
      'a': ['x-y', 'z'],
    });
  });

  group('privacy manifests (privacy-ios-desktop_1, ADS-6, ADS-7, WID-5)', () {
    for (final target in _folders.keys) {
      final folder = _folders[target]!;

      test('$folder/PrivacyInfo.xcprivacy is a well-formed plist', () {
        final manifest = _manifestOf(target);
        expect(manifest['NSPrivacyTracking'], isA<bool>());
        expect(manifest['NSPrivacyTrackingDomains'], isA<List<Object?>>());
        expect(manifest['NSPrivacyCollectedDataTypes'], isA<List<Object?>>());
        expect(manifest['NSPrivacyAccessedAPITypes'], isA<List<Object?>>());
      });

      test('$folder tracks no one and collects nothing itself: the ads SDK '
          'declares its own', () {
        final manifest = _manifestOf(target);
        expect(manifest['NSPrivacyTracking'], isFalse);
        expect(manifest['NSPrivacyTrackingDomains'], isEmpty);
        expect(manifest['NSPrivacyCollectedDataTypes'], isEmpty);
      });

      test('$folder declares exactly the required-reason APIs its Swift and '
          'its bundled native code call, each with a reason Apple '
          'documents', () {
        final swift = _swiftOf(target);
        final bundled = _bundledNativeApis[target] ?? const {};
        final used = {
          for (final MapEntry(key: category, value: api)
              in _requiredReasonApis.entries)
            if (api.uses.hasMatch(swift)) category,
          ...bundled.keys,
        };
        final declared = <String, List<String>>{
          for (final entry
              in (_manifestOf(target)['NSPrivacyAccessedAPITypes']! as List)
                  .cast<Map<String, Object?>>())
            entry['NSPrivacyAccessedAPIType']!
                as String: (entry['NSPrivacyAccessedAPITypeReasons']! as List)
                .cast<String>(),
        };

        expect(declared.keys.toSet(), used);
        for (final MapEntry(key: category, value: reasons)
            in declared.entries) {
          expect(reasons, isNotEmpty, reason: category);
          expect(
            _requiredReasonApis[category]!.reasons,
            containsAll(reasons),
            reason: '$category: only Apple\'s own reason codes',
          );
        }
        for (final MapEntry(key: category, value: code) in bundled.entries) {
          expect(
            declared[category],
            containsAll(code.reasons),
            reason: '$category, for what ${code.package} bundles',
          );
        }

        // The App Group suite the app and the widget share is 1C8F.1; the
        // app's own defaults would be CA92.1.
        if (swift.contains('UserDefaults(suiteName:')) {
          expect(
            declared['NSPrivacyAccessedAPICategoryUserDefaults'],
            contains('1C8F.1'),
          );
        }
        if (swift.contains('UserDefaults.standard')) {
          expect(
            declared['NSPrivacyAccessedAPICategoryUserDefaults'],
            contains('CA92.1'),
          );
        }
      });

      test('$folder copies its own manifest into its bundle', () {
        final path = '$folder/PrivacyInfo.xcprivacy';
        expect(project.resources(target), contains(path));
        expect(project.fileType(path), 'text.xml');
        expect(File('ios/$path').existsSync(), isTrue);
        for (final other in _folders.keys.where((t) => t != target)) {
          expect(
            project.resources(other),
            isNot(contains(path)),
            reason: 'each bundle carries its own manifest',
          );
        }
      });
    }

    test('every package whose native code a manifest declares for is still '
        'in pubspec.lock', () {
      // When a package listed in _bundledNativeApis leaves pubspec.lock, its
      // declarations have to be looked at again rather than linger.
      final lock = File('pubspec.lock').readAsStringSync();
      for (final apis in _bundledNativeApis.values) {
        for (final MapEntry(key: category, value: code) in apis.entries) {
          expect(
            lock,
            contains(
              RegExp('^  ${RegExp.escape(code.package)}:\$', multiLine: true),
            ),
            reason: '$category is declared for ${code.package}',
          );
        }
      }
    });

    test('the app itself declares the App Group defaults it writes for the '
        'widget', () {
      // A guard on the guard: the scan above has to find something here.
      expect(
        _requiredReasonApis['NSPrivacyAccessedAPICategoryUserDefaults']!.uses
            .hasMatch(_swiftOf(_runner)),
        isTrue,
      );
    });
  });

  group('SKAdNetwork (privacy-ios-desktop_11, ADS-6)', () {
    List<String> identifiers() => [
      for (final item
          in (infoPlist['SKAdNetworkItems']! as List)
              .cast<Map<String, Object?>>())
        item['SKAdNetworkIdentifier']! as String,
    ];

    test('Info.plist lists Google\'s own network', () {
      expect(identifiers(), contains('cstr6suwn9.skadnetwork'));
    });

    test('and the third-party buyers Google lists, each once and '
        'well-formed', () {
      final ids = identifiers();
      // Google's list had 50 on 2026-09-24; it grows and shrinks, so this
      // only checks it was not cut down to Google's own.
      expect(ids.length, greaterThan(40));
      expect(ids.toSet(), hasLength(ids.length));
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[a-z0-9]+\.skadnetwork$')));
      }
    });
  });

  group('languages (LANG-1, LANG-2)', () {
    test('Info.plist names every app language, and only those', () {
      expect(
        (infoPlist['CFBundleLocalizations']! as List).cast<String>(),
        unorderedEquals(_iosLanguages),
      );
      expect(
        infoPlist['CFBundleDevelopmentRegion'],
        r'$(DEVELOPMENT_LANGUAGE)',
      );
    });

    test('the project knows every app language as a region', () {
      expect(project.knownRegions, containsAll(_iosLanguages));
      expect(project.knownRegions, contains('Base'));
    });
  });

  group('String Catalogs (LANG-2, LANG-6, WID-6)', () {
    const catalogs = {
      'Runner/InfoPlist.xcstrings': _runner,
      'MonthlyExpensesWidget/Localizable.xcstrings': _widget,
    };

    for (final MapEntry(key: path, value: target) in catalogs.entries) {
      test('$path is a String Catalog in English first', () {
        final catalog = _catalog('ios/$path');
        expect(catalog['sourceLanguage'], 'en');
        expect(catalog['version'], isA<String>());
        expect(_entries(catalog), isNotEmpty);
      });

      test('$path is in $target\'s resources, and only there', () {
        expect(project.resources(target), contains(path));
        expect(project.fileType(path), 'text.json.xcstrings');
        for (final other in _folders.keys.where((t) => t != target)) {
          expect(project.resources(other), isNot(contains(path)));
        }
      });

      test('$path has every app language for every key', () {
        final catalog = _catalog('ios/$path');
        for (final key in _entries(catalog).keys) {
          final values = _values(catalog, key);
          expect(
            values.keys,
            unorderedEquals(_iosLanguages),
            reason: '$key is missing languages or has extra ones',
          );
          for (final MapEntry(key: language, value: value) in values.entries) {
            expect(value.trim(), isNotEmpty, reason: '$key in $language');
          }
        }
      });
    }

    test('every system prompt in Info.plist is translated, from its own '
        'English', () {
      final catalog = _catalog('ios/Runner/InfoPlist.xcstrings');
      final prompts = [
        for (final key in infoPlist.keys)
          if (key.startsWith('NS') && key.endsWith('UsageDescription')) key,
      ];
      expect(
        prompts,
        containsAll([
          'NSFaceIDUsageDescription',
          'NSUserTrackingUsageDescription',
        ]),
      );
      for (final key in prompts) {
        expect(_entries(catalog), contains(key));
      }
    });

    test('the catalog\'s English is Info.plist\'s for every key in it, the '
        'app name too', () {
      // Each language's compiled InfoPlist.strings overrides Info.plist on
      // the phone, English included, so a change made only in Info.plist
      // (a new app name, a reworded prompt) would never show.
      final catalog = _catalog('ios/Runner/InfoPlist.xcstrings');
      expect(
        _entries(catalog).keys,
        containsAll(['CFBundleDisplayName', 'CFBundleName']),
      );
      for (final key in _entries(catalog).keys) {
        expect(infoPlist, contains(key), reason: 'not in Info.plist: $key');
        expect(_values(catalog, key)['en'], infoPlist[key], reason: key);
      }
    });

    test('the widget gallery says what the Android widget picker says', () {
      final catalog = _catalog(
        'ios/MonthlyExpensesWidget/Localizable.xcstrings',
      );
      final descriptions = _values(catalog, 'widget_description');
      final names = _values(catalog, 'widget_name');
      for (final code in appLanguages.keys) {
        final folder = code == 'en'
            ? 'values'
            : 'values-${_androidQualifier[code] ?? code}';
        final android =
            RegExp(r'<string name="widget_medium_description">([^<]*)</string>')
                .firstMatch(
                  File('android/app/src/main/res/$folder/widget_strings.xml')
                      .readAsStringSync(),
                )!
                .group(1)!
                .replaceAll(r"\'", "'")
                .replaceAll(r'\"', '"');
        expect(descriptions[_ios(code)], android, reason: code);

        final appTitle = (jsonDecode(
          File('lib/l10n/app_$code.arb').readAsStringSync(),
        ) as Map<String, Object?>)['appTitle'];
        expect(names[_ios(code)], appTitle, reason: code);
      }
    });

    test('the widget names itself from the catalog, not from English in the '
        'Swift', () {
      final swift = _swiftOf(_widget);
      final catalog = _catalog(
        'ios/MonthlyExpensesWidget/Localizable.xcstrings',
      );
      for (final modifier in ['configurationDisplayName', 'description']) {
        expect(
          swift,
          isNot(contains(RegExp('\\.$modifier\\(\\s*"'))),
          reason: '.$modifier("…") would be an English literal',
        );
        final key = RegExp(
          '\\.$modifier\\(\\s*Text\\(\\s*"([^"]+)"\\s*\\)\\s*\\)',
        ).firstMatch(swift);
        expect(key, isNotNull, reason: '.$modifier(Text("key"))');
        expect(_entries(catalog), contains(key!.group(1)));
      }
    });
  });
}

/// The objects in ios/Runner.xcodeproj/project.pbxproj, read with a small
/// parser for its old-style (OpenStep) plist format.
class _Project {
  _Project(this.root) : objects = root['objects']! as Map<String, Object?>;

  factory _Project.read() => _Project(
    _OpenStepParser(
          File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync(),
        ).parse()
        as Map<String, Object?>,
  );

  final Map<String, Object?> root;
  final Map<String, Object?> objects;

  Map<String, Object?> _object(String id) {
    final object = objects[id];
    expect(object, isNotNull, reason: 'no object $id');
    return object! as Map<String, Object?>;
  }

  Map<String, Object?> target(String name) => objects.values
      .cast<Map<String, Object?>>()
      .singleWhere((o) => o['isa'] == 'PBXNativeTarget' && o['name'] == name);

  List<String> get knownRegions {
    final project = objects.values.cast<Map<String, Object?>>().singleWhere(
      (o) => o['isa'] == 'PBXProject',
    );
    return (project['knownRegions']! as List).cast<String>();
  }

  /// The paths, under ios/, of what [targetName]'s Copy Bundle Resources
  /// phase copies.
  List<String> resources(String targetName) => [
    for (final phaseId
        in (target(targetName)['buildPhases']! as List).cast<String>())
      if (_object(phaseId)['isa'] == 'PBXResourcesBuildPhase')
        for (final buildFile
            in (_object(phaseId)['files']! as List).cast<String>())
          _pathOf(_object(buildFile)['fileRef']! as String),
  ];

  /// The file type Xcode knows the file at [path] (under ios/) by.
  String? fileType(String path) {
    final id = objects.keys.singleWhere(
      (id) => _object(id)['isa'] == 'PBXFileReference' && _pathOf(id) == path,
    );
    return _object(id)['lastKnownFileType'] as String?;
  }

  /// A file's path under ios/, through the groups that hold it.
  String _pathOf(String id) {
    final object = _object(id);
    final own = (object['path'] ?? object['name'])! as String;
    final folder = _folderOf(_parentOf(id));
    return folder.isEmpty ? own : '$folder/$own';
  }

  /// The folder a group stands for: its own path under its parents', or
  /// just its parents' when it is only a name in the navigator.
  String _folderOf(String? groupId) {
    if (groupId == null) return '';
    final above = _folderOf(_parentOf(groupId));
    final own = _object(groupId)['path'] as String?;
    if (own == null) return above;
    return above.isEmpty ? own : '$above/$own';
  }

  String? _parentOf(String id) {
    final parents = [
      for (final MapEntry(key: groupId, value: group) in objects.entries)
        if (group
            case {'isa': 'PBXGroup', 'children': final List<Object?> children}
            when children.contains(id))
          groupId,
    ];
    expect(parents.length, lessThanOrEqualTo(1), reason: '$id is in $parents');
    return parents.isEmpty ? null : parents.single;
  }
}

/// Reads an old-style (OpenStep) property list such as project.pbxproj.
/// Throws on anything it does not understand, and on a key repeated within
/// one dictionary.
class _OpenStepParser {
  _OpenStepParser(this.source);

  final String source;
  int _at = 0;

  Object parse() {
    _skip();
    final value = _value();
    _skip();
    if (_at != source.length) _fail('text after the root value');
    return value;
  }

  Never _fail(String what) {
    final line = '\n'.allMatches(source.substring(0, _at)).length + 1;
    throw FormatException('project.pbxproj line $line: $what');
  }

  void _skip() {
    while (_at < source.length) {
      if (' \t\r\n'.contains(source[_at])) {
        _at++;
      } else if (source.startsWith('/*', _at)) {
        final end = source.indexOf('*/', _at + 2);
        if (end < 0) _fail('unclosed comment');
        _at = end + 2;
      } else if (source.startsWith('//', _at)) {
        final end = source.indexOf('\n', _at);
        _at = end < 0 ? source.length : end + 1;
      } else {
        return;
      }
    }
  }

  void _expect(String char) {
    _skip();
    if (_at >= source.length || source[_at] != char) _fail('expected $char');
    _at++;
  }

  bool _next(String char) {
    _skip();
    if (_at < source.length && source[_at] == char) {
      _at++;
      return true;
    }
    return false;
  }

  Object _value() {
    _skip();
    if (_at >= source.length) _fail('unexpected end');
    return switch (source[_at]) {
      '{' => _dictionary(),
      '(' => _array(),
      _ => _string(),
    };
  }

  Map<String, Object?> _dictionary() {
    _expect('{');
    final map = <String, Object?>{};
    while (!_next('}')) {
      final key = _string();
      _expect('=');
      final value = _value();
      _expect(';');
      if (map.containsKey(key)) _fail('$key appears twice');
      map[key] = value;
    }
    return map;
  }

  List<Object> _array() {
    _expect('(');
    final list = <Object>[];
    while (!_next(')')) {
      list.add(_value());
      if (!_next(',')) {
        _expect(')');
        break;
      }
    }
    return list;
  }

  static final _bare = RegExp(r'[A-Za-z0-9_$/:.\-]+');

  String _string() {
    _skip();
    if (_at < source.length && source[_at] == '"') {
      _at++;
      final out = StringBuffer();
      while (true) {
        if (_at >= source.length) _fail('unclosed string');
        final char = source[_at++];
        if (char == '"') return out.toString();
        if (char == r'\') {
          if (_at >= source.length) _fail('unclosed string');
          final escaped = source[_at++];
          out.write(switch (escaped) {
            'n' => '\n',
            't' => '\t',
            _ => escaped,
          });
        } else {
          out.write(char);
        }
      }
    }
    final match = _bare.matchAsPrefix(source, _at);
    if (match == null) _fail('expected a value');
    _at = match.end;
    return match.group(0)!;
  }
}

/// Reads an XML property list (Info.plist, PrivacyInfo.xcprivacy) into maps,
/// lists, strings, numbers and booleans. Throws FormatException on anything
/// that is not a well-formed plist: an unknown or unclosed element, text
/// where a value belongs, a repeated key, a bad entity, or an XML comment
/// holding "--".
Object _parsePlist(String xml) => _PlistParser(xml).parse();

class _Token {
  const _Token(this.kind, this.value);

  /// 'open', 'close', 'empty' (a self-closing element) or 'text'.
  final String kind;
  final String value;

  bool get isSpace => kind == 'text' && value.trim().isEmpty;

  @override
  String toString() => '$kind $value';
}

class _PlistParser {
  _PlistParser(String xml) : _tokens = _tokenize(xml);

  final List<_Token> _tokens;
  int _at = 0;

  static final _pieces = RegExp(
    r'<!--([\s\S]*?)-->'
    r'|<\?[\s\S]*?\?>'
    r'|<!DOCTYPE[^>]*>'
    r'|<(/?)([A-Za-z]+)((?:\s+[A-Za-z:]+="[^"]*")*)\s*(/?)>'
    r'|[^<]+',
  );

  static List<_Token> _tokenize(String xml) {
    final tokens = <_Token>[];
    var at = 0;
    while (at < xml.length) {
      final match = _pieces.matchAsPrefix(xml, at);
      if (match == null) {
        throw FormatException('not XML at offset $at', xml, at);
      }
      at = match.end;
      final text = match.group(0)!;
      if (text.startsWith('<!--')) {
        if (match.group(1)!.contains('--')) {
          throw FormatException('"--" inside an XML comment', xml, at);
        }
      } else if (text.startsWith('<?') || text.startsWith('<!')) {
        continue;
      } else if (text.startsWith('<')) {
        final name = match.group(3)!;
        final closing = match.group(2)!.isNotEmpty;
        final empty = match.group(5)!.isNotEmpty;
        if (closing && empty) throw FormatException('bad tag $text');
        tokens.add(
          _Token(closing ? 'close' : (empty ? 'empty' : 'open'), name),
        );
      } else {
        tokens.add(_Token('text', _decode(text)));
      }
    }
    return tokens;
  }

  static String _decode(String text) =>
      text.replaceAllMapped(RegExp(r'&([^;\s]*);?'), (match) {
        final entity = match.group(0)!;
        if (!entity.endsWith(';')) throw FormatException('bare &: $entity');
        final name = match.group(1)!;
        switch (name) {
          case 'lt':
            return '<';
          case 'gt':
            return '>';
          case 'amp':
            return '&';
          case 'quot':
            return '"';
          case 'apos':
            return "'";
        }
        if (name.startsWith('#x')) {
          return String.fromCharCode(int.parse(name.substring(2), radix: 16));
        }
        if (name.startsWith('#')) {
          return String.fromCharCode(int.parse(name.substring(1)));
        }
        throw FormatException('unknown entity $entity');
      });

  Object parse() {
    _open('plist');
    final value = _value();
    _close('plist');
    _skipSpace();
    if (_at != _tokens.length) {
      throw const FormatException('text after </plist>');
    }
    return value;
  }

  void _skipSpace() {
    while (_at < _tokens.length && _tokens[_at].isSpace) {
      _at++;
    }
  }

  _Token _take() {
    _skipSpace();
    if (_at >= _tokens.length) throw const FormatException('unexpected end');
    return _tokens[_at++];
  }

  bool _peek(String kind, String name) {
    _skipSpace();
    return _at < _tokens.length &&
        _tokens[_at].kind == kind &&
        _tokens[_at].value == name;
  }

  void _open(String name) {
    final token = _take();
    if (token.kind != 'open' || token.value != name) {
      throw FormatException('expected <$name>, found $token');
    }
  }

  void _close(String name) {
    final token = _take();
    if (token.kind != 'close' || token.value != name) {
      throw FormatException('expected </$name>, found $token');
    }
  }

  /// The text of an element whose opening tag was just read.
  String _text(String name) {
    if (_at < _tokens.length && _tokens[_at].kind == 'text') {
      final text = _tokens[_at++].value;
      _close(name);
      return text;
    }
    _close(name);
    return '';
  }

  Object _value() {
    final token = _take();
    if (token.kind == 'empty') {
      return switch (token.value) {
        'true' => true,
        'false' => false,
        'dict' => <String, Object?>{},
        'array' => <Object?>[],
        'string' => '',
        _ => throw FormatException('unexpected <${token.value}/>'),
      };
    }
    if (token.kind != 'open') throw FormatException('expected a value: $token');
    switch (token.value) {
      case 'dict':
        final map = <String, Object?>{};
        while (!_peek('close', 'dict')) {
          _open('key');
          final key = _text('key');
          if (map.containsKey(key)) throw FormatException('$key twice');
          map[key] = _value();
        }
        _take();
        return map;
      case 'array':
        final list = <Object?>[];
        while (!_peek('close', 'array')) {
          list.add(_value());
        }
        _take();
        return list;
      case 'string':
      case 'date':
      case 'data':
        return _text(token.value);
      case 'integer':
        return int.parse(_text('integer').trim());
      case 'real':
        return double.parse(_text('real').trim());
    }
    throw FormatException('unknown element <${token.value}>');
  }
}
