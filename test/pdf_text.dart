/// Reads back the text a generated PDF actually draws, in the order it is
/// read on the page: top line first, and left to right within a line.
///
/// This exists because asserting that a report "is a valid PDF" says nothing
/// about whether it can be read. The pdf package draws one glyph at a time at
/// an explicit position, so a page that lays text out backwards produces the
/// same glyphs and the same byte count — only the coordinates give it away
/// (PDF-5, LANG-5).
///
/// The document must be built with `compress: false`, since this reads the
/// content stream as text.
library;

import 'dart:typed_data';

/// Every run of text drawn in [bytes] — in practice one per piece of text on
/// the page — each in the order it is read.
///
/// Spaces are not in the output: the package advances past them rather than
/// drawing them. Compare against [squashed] text.
List<String> pdfLines(Uint8List bytes) {
  final raw = String.fromCharCodes(bytes);
  final glyphs = _glyphMaps(raw);
  final objects = _objects(raw);

  // Follow each page's /Contents to its own stream. Pages reuse coordinates,
  // so reading them together would interleave their text — and the embedded
  // font files are streams too, whose bytes otherwise look like drawing.
  final lines = <String>[];
  for (final body in objects.values) {
    if (!body.contains('/Type/Page')) continue;
    final contents = RegExp(r'/Contents (\d+) 0 R').firstMatch(body);
    if (contents == null) continue;
    final stream = objects[int.parse(contents.group(1)!)];
    if (stream == null) continue;
    final content = RegExp(
      r'stream\r?\n(.*?)endstream',
      dotAll: true,
    ).firstMatch(stream);
    if (content == null) continue;
    lines.addAll(_pageLines(content.group(1)!, glyphs));
  }
  return lines;
}

/// One run per piece of text on the page, each read left to right.
///
/// Coordinates are local to whatever coordinate space is current, not to the
/// page: every piece of text is drawn inside its own, pushed with `q`/`cm`
/// and popped with `Q`. So a run ends at one of those markers, or when the
/// baseline moves. Sorting a run by x then gives the order it is read in —
/// which is the whole point, since reversed text has the same glyphs and the
/// same byte count, and differs only here.
List<String> _pageLines(String content, Map<String, Map<int, String>> glyphs) {
  final runs = <String>[];
  var run = <({double x, double y, String text})>[];
  void flush() {
    if (run.isEmpty) return;
    run.sort((a, b) => a.x.compareTo(b.x));
    runs.add(run.map((glyph) => glyph.text).join());
    run = [];
  }

  var font = '';
  // "/F10 12 Tf" picks the font, "x y Td [<0001>]TJ" draws at that spot, and
  // q / Q / cm start a new coordinate space.
  final pattern = RegExp(
    r'/(F\d+)\s+[\d.]+\s+Tf'
    r'|([-\d.]+)\s+([-\d.]+)\s+Td\s*\[<([0-9A-Fa-f]+)>\]\s*TJ'
    r'|(?<![A-Za-z])(q|Q|cm)(?![A-Za-z])',
  );
  for (final match in pattern.allMatches(content)) {
    if (match.group(5) != null) {
      flush();
      continue;
    }
    final picked = match.group(1);
    if (picked != null) {
      font = picked;
      continue;
    }
    final y = double.parse(match.group(3)!);
    if (run.isNotEmpty && (y - run.last.y).abs() > 0.01) flush();
    final codes = match.group(4)!;
    final buffer = StringBuffer();
    for (var i = 0; i + 4 <= codes.length; i += 4) {
      final glyph = int.parse(codes.substring(i, i + 4), radix: 16);
      buffer.write(glyphs[font]?[glyph] ?? '');
    }
    run.add((x: double.parse(match.group(2)!), y: y, text: buffer.toString()));
  }
  flush();
  return runs;
}

/// Everything drawn in [bytes], one line of the report per line.
String pdfText(Uint8List bytes) => pdfLines(bytes).join('\n');

/// [text] with the whitespace taken out, for comparing against what a PDF
/// draws — which has none in it.
String squashed(String text) => text.replaceAll(RegExp(r'\s+'), '');

Map<int, String> _objects(String raw) => {
  for (final match in RegExp(
    r'(\d+) 0 obj(.*?)endobj',
    dotAll: true,
  ).allMatches(raw))
    int.parse(match.group(1)!): match.group(2)!,
};

/// Glyph ID to character, per font resource name, from each font's
/// /ToUnicode map.
Map<String, Map<int, String>> _glyphMaps(String raw) {
  final objects = _objects(raw);
  final maps = <String, Map<int, String>>{};
  for (final body in objects.values) {
    if (!body.contains('/Type/Font') || !body.contains('/Subtype/Type0')) {
      continue;
    }
    final name = RegExp(r'/Name/(F\d+)').firstMatch(body)?.group(1);
    final toUnicode = RegExp(r'/ToUnicode (\d+) 0 R').firstMatch(body);
    if (name == null || toUnicode == null) continue;
    final cmap = objects[int.parse(toUnicode.group(1)!)];
    if (cmap == null) continue;
    maps[name] = _parseCmap(cmap);
  }
  return maps;
}

Map<int, String> _parseCmap(String cmap) {
  final map = <int, String>{};
  for (final block in RegExp(
    r'beginbfchar(.*?)endbfchar',
    dotAll: true,
  ).allMatches(cmap)) {
    final pairs = RegExp(r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>')
        .allMatches(block.group(1)!);
    for (final pair in pairs) {
      final glyph = int.parse(pair.group(1)!, radix: 16);
      final code = int.parse(pair.group(2)!, radix: 16);
      if (glyph != 0) map[glyph] = String.fromCharCode(code);
    }
  }
  return map;
}
