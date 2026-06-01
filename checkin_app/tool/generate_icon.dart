// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Fill with white background
  img.fill(image, color: img.ColorRgb8(255, 255, 255));

  // Draw rounded square background (subtle shadow effect)
  _drawRoundedRect(image, 0, 0, size, size, 200, img.ColorRgb8(255, 255, 255));

  // Draw gradient circle (blue #4A90D9 to purple #6C63FF)
  const cx = size ~/ 2;
  const cy = size ~/ 2;
  const radius = 360;

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist <= radius) {
        // Gradient from top-left to bottom-right
        final t = ((dx + dy) / (2 * radius)).clamp(-1.0, 1.0) * 0.5 + 0.5;

        // Blue #4A90D9 to Purple #6C63FF
        final r = (0x4A + (0x6C - 0x4A) * t).round();
        final g = (0x90 + (0x63 - 0x90) * t).round();
        final b = (0xD9 + (0xFF - 0xD9) * t).round();

        // Anti-aliasing at the edge
        final alpha = dist > radius - 2
            ? ((radius - dist) / 2 * 255).clamp(0, 255).round()
            : 255;

        final pixel = image.getPixel(x, y);
        pixel.r = r;
        pixel.g = g;
        pixel.b = b;
        pixel.a = alpha;
      }
    }
  }

  // Draw white checkmark
  _drawCheckmark(image, cx, cy, 200, 50);

  // Save
  final outputDir = Directory('assets/icons');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  final pngBytes = img.encodePng(image);
  File('assets/icons/app_icon.png').writeAsBytesSync(pngBytes);
  print('Icon generated: assets/icons/app_icon.png');
}

void _drawRoundedRect(
    img.Image image, int x, int y, int w, int h, int radius, img.Color color) {
  for (int py = y; py < y + h; py++) {
    for (int px = x; px < x + w; px++) {
      // Check if pixel is inside rounded rect
      final dx = max(0, max(x + radius - px, px - (x + w - radius)));
      final dy = max(0, max(y + radius - py, py - (y + h - radius)));
      final dist = sqrt(dx * dx + dy * dy);

      if (dist <= radius) {
        final pixel = image.getPixel(px, py);
        pixel.r = color.r.toInt();
        pixel.g = color.g.toInt();
        pixel.b = color.b.toInt();
        pixel.a = 255;
      }
    }
  }
}

void _drawCheckmark(img.Image image, int cx, int cy, int size, int thickness) {
  // Checkmark points (relative to center)
  // Left point, bottom point, right point
  final points = [
    [-size * 0.35, 0.0],
    [-size * 0.08, size * 0.3],
    [size * 0.4, -size * 0.25],
  ];

  // Draw thick line segments
  _drawThickLine(image, cx + points[0][0].round(), cy + points[0][1].round(),
      cx + points[1][0].round(), cy + points[1][1].round(), thickness);
  _drawThickLine(image, cx + points[1][0].round(), cy + points[1][1].round(),
      cx + points[2][0].round(), cy + points[2][1].round(), thickness);
}

void _drawThickLine(
    img.Image image, int x1, int y1, int x2, int y2, int thickness) {
  final halfThick = thickness / 2;

  final minX = min(x1, x2) - thickness;
  final maxX = max(x1, x2) + thickness;
  final minY = min(y1, y2) - thickness;
  final maxY = max(y1, y2) + thickness;

  for (int py = minY; py <= maxY; py++) {
    for (int px = minX; px <= maxX; px++) {
      final dist = _pointToLineDistance(px.toDouble(), py.toDouble(),
          x1.toDouble(), y1.toDouble(), x2.toDouble(), y2.toDouble());

      if (dist <= halfThick) {
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          final alpha = dist > halfThick - 1.5
              ? ((halfThick - dist) / 1.5 * 255).clamp(0, 255).round()
              : 255;
          final pixel = image.getPixel(px, py);
          pixel.r = 255;
          pixel.g = 255;
          pixel.b = 255;
          pixel.a = alpha;
        }
      }
    }
  }
}

double _pointToLineDistance(
    double px, double py, double x1, double y1, double x2, double y2) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  final lenSq = dx * dx + dy * dy;

  if (lenSq == 0) return sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));

  var t = ((px - x1) * dx + (py - y1) * dy) / lenSq;
  t = t.clamp(0.0, 1.0);

  final projX = x1 + t * dx;
  final projY = y1 + t * dy;

  return sqrt((px - projX) * (px - projX) + (py - projY) * (py - projY));
}
