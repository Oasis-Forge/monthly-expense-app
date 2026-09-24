// Draws the app icon and splash images into assets/icon/. After changing the
// design, run:
//   flutter test tool/render_app_icons_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
// It lives outside test/ so the regular test run doesn't rewrite the assets.
// The store icon and feature graphics come from the same painter, through
// integration_test/store_screenshots_test.dart.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The purple behind the glyph, lighter at the top left.
const _backgroundColors = [Color(0xFF7457FF), Color(0xFF3F22C0)];

/// The ring runs from green, plenty left, to amber, getting close.
const _green = Color(0xFF2EE6A8);
const _amber = Color(0xFFFFC83D);

/// A budget ring three quarters used, around a small bar chart: how much of
/// the month's money is gone, at a glance. It needs no currency sign, so it
/// reads the same in every language. Shapes are laid out on a 1024-unit
/// square around its center.
class AppIconPainter extends CustomPainter {
  const AppIconPainter({
    required this.scale,
    this.background = false,
    this.rounded = false,
    this.monochrome = false,
    this.glyph = true,
    this.notification = false,
  });

  /// The glyph's size relative to the canvas; 1 makes the ring about three
  /// fifths of it across.
  final double scale;

  /// Paints the purple gradient behind the glyph, for icons that can't be
  /// transparent.
  final bool background;

  /// Rounds the background's corners, for desktops that don't mask icons.
  final bool rounded;

  /// One color with the track faded, for Android themed icons, which tint
  /// whatever is drawn.
  final bool monochrome;

  /// False for the background alone, behind Android's adaptive icon.
  final bool glyph;

  /// The status bar's small icon, which Android draws from the alpha channel
  /// alone and tints itself: solid white, no faded track, and no shadow,
  /// because at 24dp a half-lit ring is a smudge and a shadow is noise.
  final bool notification;

  @override
  void paint(Canvas canvas, Size size) {
    if (background) {
      final area = Offset.zero & size;
      final paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _backgroundColors,
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
    if (!glyph) return;
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..scale(size.width / 1024 * scale)
      ..translate(-512, -512);
    _paintGlyph(canvas);
    canvas.restore();
  }

  void _paintGlyph(Canvas canvas) {
    const center = Offset(512, 512);
    const radius = 262.0;
    const width = 108.0;
    // Three quarters gone: the gap left at the top is the quarter still to
    // spend.
    const start = -math.pi / 2;
    const sweep = 2 * math.pi * 0.75;
    final ring = Rect.fromCircle(center: center, radius: radius);
    Paint stroke() => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    if (!notification) {
      canvas.drawCircle(
        center,
        radius,
        stroke()..color = Color(monochrome ? 0x66FFFFFF : 0x30FFFFFF),
      );
    }
    if (!monochrome && !notification) {
      canvas.drawArc(
        ring.shift(const Offset(0, 14)),
        start,
        sweep,
        false,
        stroke()
          ..color = const Color(0x40000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
    canvas.drawArc(
      ring,
      start,
      sweep,
      false,
      monochrome || notification
          ? (stroke()..color = Colors.white)
          // Green where the ring starts, amber where it ends. The start's
          // rounded cap reaches back past the top, so the color wraps to
          // green again before it gets there.
          : (stroke()
              ..shader = const SweepGradient(
                colors: [_green, _amber, _amber, _green],
                stops: [0, 0.75, 0.85, 1],
                transform: GradientRotation(start),
              ).createShader(ring)),
    );

    // The bar chart in the middle.
    for (final (left, top) in const [
      (402.0, 520.0),
      (482.0, 418.0),
      (562.0, 470.0),
    ]) {
      canvas.drawRRect(
        RRect.fromLTRBR(left, top, left + 60, 610, const Radius.circular(18)),
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(AppIconPainter oldDelegate) => false;
}

void main() {
  // File name → (square size in pixels, painter).
  const outputs = {
    // Launchers that mask a full square: iOS, macOS, Windows, older Android.
    'icon.png': (1024, AppIconPainter(scale: 1, background: true)),
    // Linux desktops show icons as they are, so the corners are rounded.
    'icon_linux.png': (
      512,
      AppIconPainter(scale: 0.95, background: true, rounded: true),
    ),
    // Android adaptive and themed icons keep the glyph inside the safe zone,
    // over the same gradient. Launchers show the middle two thirds, so at
    // 0.64 the ring fills about three fifths of the visible icon; the
    // generator adds no inset of its own (flutter_launcher_icons.yaml).
    'icon_background.png': (
      1024,
      AppIconPainter(scale: 1, background: true, glyph: false),
    ),
    'icon_foreground.png': (1024, AppIconPainter(scale: 0.64)),
    'icon_monochrome.png': (
      1024,
      AppIconPainter(scale: 0.64, monochrome: true),
    ),
    'splash.png': (768, AppIconPainter(scale: 0.9)),
    // Android 12 shows the splash icon inside a circle of two thirds.
    'splash_android12.png': (1152, AppIconPainter(scale: 0.6)),
    // The status bar's small icon, one per density. It goes straight into the
    // Android resources because flutter_launcher_icons does not make this
    // one, and the launcher icon cannot stand in: Android keeps only the
    // alpha of a small icon, so a full-colour square arrives as a blob. There
    // is no safe zone to respect here, so the glyph fills the square.
    'android/app/src/main/res/drawable-mdpi/ic_notification.png': (
      24,
      AppIconPainter(scale: 1, notification: true),
    ),
    'android/app/src/main/res/drawable-hdpi/ic_notification.png': (
      36,
      AppIconPainter(scale: 1, notification: true),
    ),
    'android/app/src/main/res/drawable-xhdpi/ic_notification.png': (
      48,
      AppIconPainter(scale: 1, notification: true),
    ),
    'android/app/src/main/res/drawable-xxhdpi/ic_notification.png': (
      72,
      AppIconPainter(scale: 1, notification: true),
    ),
    'android/app/src/main/res/drawable-xxxhdpi/ic_notification.png': (
      96,
      AppIconPainter(scale: 1, notification: true),
    ),
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
        // A name with a path in it is written where it says; the rest are
        // assets the icon generators read.
        final path = name.contains('/') ? name : 'assets/icon/$name';
        File(path)
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  });
}
