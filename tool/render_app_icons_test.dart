// Draws the app icon and splash images into assets/icon/. After changing the
// design, run:
//   flutter test tool/render_app_icons_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
// It lives outside test/ so the regular test run doesn't rewrite the assets.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The app's seed color.
const _purple = Color(0xFF6C5CE7);

/// A calendar page with a small bar chart: a month of spending at a glance.
/// Shapes are laid out on a 1024-unit square around its center.
class _IconPainter extends CustomPainter {
  const _IconPainter({
    required this.scale,
    this.background = false,
    this.rounded = false,
    this.monochrome = false,
  });

  /// The glyph's size relative to the canvas; 1 fills about half of it.
  final double scale;

  /// Paints the purple gradient behind the glyph, for icons that can't be
  /// transparent.
  final bool background;

  /// Rounds the background's corners, for desktops that don't mask icons.
  final bool rounded;

  /// A single-color glyph with cut-out details, for Android themed icons.
  final bool monochrome;

  @override
  void paint(Canvas canvas, Size size) {
    if (background) {
      final area = Offset.zero & size;
      final paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8472F2), Color(0xFF5B4BD9)],
        ).createShader(area);
      if (rounded) {
        final inset = area.deflate(size.width * 0.04);
        canvas.drawRRect(
          RRect.fromRectAndRadius(inset, Radius.circular(size.width * 0.2)),
          paint,
        );
      } else {
        canvas.drawRect(area, paint);
      }
    }
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(size.width / 1024 * scale)
      ..translate(-512, -512);
    _paintGlyph(canvas);
    canvas.restore();
  }

  void _paintGlyph(Canvas canvas) {
    // Details are colored, or cut out of a monochrome glyph.
    Paint detail(Color color) => monochrome
        ? (Paint()..blendMode = BlendMode.clear)
        : (Paint()..color = color);
    final card = RRect.fromLTRBR(272, 300, 752, 780, const Radius.circular(72));

    canvas
      ..saveLayer(const Rect.fromLTRB(0, 0, 1024, 1024), Paint())
      ..drawRRect(card, Paint()..color = Colors.white)
      ..save()
      ..clipRRect(card)
      ..drawRect(
        monochrome
            ? const Rect.fromLTRB(272, 404, 752, 428)
            : const Rect.fromLTRB(272, 300, 752, 420),
        detail(const Color(0xFFDAD4FF)),
      )
      ..restore();
    for (final (left, top) in const [
      (350.0, 580.0),
      (474.0, 500.0),
      (598.0, 540.0),
    ]) {
      canvas.drawRRect(
        RRect.fromLTRBR(left, top, left + 76, 712, const Radius.circular(18)),
        detail(_purple),
      );
    }
    canvas.restore();

    // The binder rings over the top edge.
    for (final left in const [382.0, 594.0]) {
      canvas.drawRRect(
        RRect.fromLTRBR(left, 244, left + 48, 356, const Radius.circular(24)),
        Paint()..color = monochrome ? Colors.white : const Color(0xFF3F32B5),
      );
    }
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) => false;
}

void main() {
  // File name → (square size in pixels, painter).
  const outputs = {
    // Launchers that mask a full square: iOS, macOS, Windows, older Android.
    'icon.png': (1024, _IconPainter(scale: 1.1, background: true)),
    // Linux desktops show icons as they are, so the corners are rounded.
    'icon_linux.png': (
      512,
      _IconPainter(scale: 1.05, background: true, rounded: true),
    ),
    // Android adaptive and themed icons keep the glyph inside the safe zone.
    'icon_foreground.png': (1024, _IconPainter(scale: 0.72)),
    'icon_monochrome.png': (1024, _IconPainter(scale: 0.72, monochrome: true)),
    'splash.png': (768, _IconPainter(scale: 0.9)),
    // Android 12 shows the splash icon inside a circle of two thirds.
    'splash_android12.png': (1152, _IconPainter(scale: 0.6)),
  };

  testWidgets('renders the app icon and splash images', (tester) async {
    addTearDown(tester.view.reset);
    Directory('assets/icon').createSync(recursive: true);

    for (final MapEntry(key: name, value: (pixels, painter))
        in outputs.entries) {
      final size = Size.square(pixels.toDouble());
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: CustomPaint(painter: painter, size: size),
        ),
      );

      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('assets/icon/$name').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  });
}
