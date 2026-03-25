import 'package:flutter/material.dart';
import 'dart:math' as math;

/// --- HEART ---
class PerfectHeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w * 0.5;
    double cy = h * 0.4; // Shifted up slightly
    double s = w * 0.75; // Balanced size

    final path = Path();
    path.moveTo(cx, cy + s * 0.2);
    path.cubicTo(
      cx,
      cy - s * 0.15,
      cx + s * 0.5,
      cy - s * 0.15,
      cx + s * 0.5,
      cy + s * 0.3,
    );
    path.cubicTo(
      cx + s * 0.5,
      cy + s * 0.55,
      cx,
      cy + s * 0.75,
      cx,
      cy + s * 0.95,
    );
    path.cubicTo(
      cx,
      cy + s * 0.75,
      cx - s * 0.5,
      cy + s * 0.55,
      cx - s * 0.5,
      cy + s * 0.3,
    );
    path.cubicTo(
      cx - s * 0.5,
      cy - s * 0.15,
      cx,
      cy - s * 0.15,
      cx,
      cy + s * 0.2,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PerfectHeartPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  PerfectHeartPainter({required this.color, required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(PerfectHeartClipper().getClip(size), paint);
  }

  @override
  bool shouldRepaint(PerfectHeartPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// --- STAR ---
class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = (height / 2) + (height * 0.02);
    final double outerRadius = width / 2;
    final double innerRadius = outerRadius * 0.45;
    const int points = 5;
    double angle = -math.pi / 2;
    const double angleStep = math.pi / points;
    for (int i = 0; i < points * 2; i++) {
      double radius = i.isEven ? outerRadius : innerRadius;
      double x = centerX + math.cos(angle) * radius;
      double y = centerY + math.sin(angle) * radius;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
      angle += angleStep;
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class StarBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  StarBorderPainter({required this.color, required this.width});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(StarClipper().getClip(size), paint);
  }

  @override
  bool shouldRepaint(StarBorderPainter oldDelegate) => true;
}

/// --- PENTAGON ---
class PentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.38);
    path.lineTo(w * 0.81, h);
    path.lineTo(w * 0.19, h);
    path.lineTo(0, h * 0.38);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PentagonBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  PentagonBorderPainter({required this.color, required this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawPath(PentagonClipper().getClip(size), paint);
  }

  @override
  bool shouldRepaint(PentagonBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// --- HEXAGON ---
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.2);
    path.lineTo(w, h * 0.8);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.8);
    path.lineTo(0, h * 0.2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// --- S-CURVE (FLOAT) ---
class SCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    path.moveTo(0, h * 0.3);
    path.quadraticBezierTo(w * 0.25, h * 0.1, w * 0.5, h * 0.3);
    path.quadraticBezierTo(w * 0.75, h * 0.5, w, h * 0.3);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// --- GRID SPLITS (2 IMAGES) ---

class SideSplitClipper extends CustomClipper<Path> {
  final bool isLeft;
  SideSplitClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (isLeft) {
      path.addRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height));
    } else {
      path.addRect(
        Rect.fromLTWH(size.width * 0.5, 0, size.width * 0.5, size.height),
      );
    }
    return path;
  }

  @override
  bool shouldReclip(SideSplitClipper oldClipper) => isLeft != oldClipper.isLeft;
}

class TopBottomSplitClipper extends CustomClipper<Path> {
  final bool isTop;
  TopBottomSplitClipper({required this.isTop});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (isTop) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));
    } else {
      path.addRect(
        Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      );
    }
    return path;
  }

  @override
  bool shouldReclip(TopBottomSplitClipper oldClipper) =>
      isTop != oldClipper.isTop;
}

class DiagonalSplitClipper extends CustomClipper<Path> {
  final int index;
  DiagonalSplitClipper({required this.index});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    final split = Path();
    split.moveTo(0, 0);
    split.lineTo(w, 0);
    split.lineTo(0, h);
    split.close();

    if (index == 0) return split;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, split);
  }

  @override
  bool shouldReclip(DiagonalSplitClipper old) => index != old.index;
}

class SCurveSplitClipper extends CustomClipper<Path> {
  final int index;
  SCurveSplitClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    final path = Path();

    final split = Path();
    split.moveTo(0, 0);
    split.lineTo(w, 0);
    split.lineTo(w, h * 0.3);
    split.quadraticBezierTo(w * 0.75, h * 0.5, w * 0.5, h * 0.3);
    split.quadraticBezierTo(w * 0.25, h * 0.1, 0, h * 0.3);
    split.close();

    if (index == 0) return split;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, split);
  }

  @override
  bool shouldReclip(SCurveSplitClipper old) => index != old.index;
}

class HeartSplitClipper extends CustomClipper<Path> {
  final bool isInside;
  HeartSplitClipper({required this.isInside});

  @override
  Path getClip(Size size) {
    Path heartPath = PerfectHeartClipper().getClip(size);
    if (isInside) {
      return heartPath;
    } else {
      Path path = Path();
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return Path.combine(PathOperation.difference, path, heartPath);
    }
  }

  @override
  bool shouldReclip(HeartSplitClipper oldClipper) =>
      isInside != oldClipper.isInside;
}

class DoubleHeartClipper extends CustomClipper<Path> {
  final int index;
  DoubleHeartClipper({required this.index});

  Path _getHeartPath(double cx, double cy, double s) {
    final path = Path();
    path.moveTo(cx, cy + s * 0.2);
    path.cubicTo(
      cx,
      cy - s * 0.15,
      cx + s * 0.5,
      cy - s * 0.15,
      cx + s * 0.5,
      cy + s * 0.3,
    );
    path.cubicTo(
      cx + s * 0.5,
      cy + s * 0.55,
      cx,
      cy + s * 0.75,
      cx,
      cy + s * 0.95,
    );
    path.cubicTo(
      cx,
      cy + s * 0.75,
      cx - s * 0.5,
      cy + s * 0.55,
      cx - s * 0.5,
      cy + s * 0.3,
    );
    path.cubicTo(
      cx - s * 0.5,
      cy - s * 0.15,
      cx,
      cy - s * 0.15,
      cx,
      cy + s * 0.2,
    );
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    
    // We want the two hearts to overlap to match the reference image.
    double s = w * 0.55;
    
    // Center vertically
    double cy = (h * 0.5) - (s * 0.4);

    double leftCx = w * 0.30;
    double rightCx = w * 0.70;

    Path leftHeart = _getHeartPath(leftCx, cy, s);
    Path rightHeart = _getHeartPath(rightCx, cy, s);

    if (index == 0) {
      // Left Heart - cut by the Right Heart plus a padding gap
      // To ensure perfectly uniform padding between the shapes, 
      // we translate the right heart to the left slightly instead of scaling it.
      
      double gap = w * 0.025; // 2.5% uniform lateral gap
      
      final Matrix4 matrix = Matrix4.identity()
        ..translate(-gap, 0.0);
        
      Path rightHeartExpanded = rightHeart.transform(matrix.storage);
      
      // Subtract the translated right heart from the left heart
      return Path.combine(PathOperation.difference, leftHeart, rightHeartExpanded);
    } else {
      // Right Heart
      return rightHeart;
    }
  }

  @override
  bool shouldReclip(DoubleHeartClipper oldClipper) => index != oldClipper.index;
}

class HIClipper extends CustomClipper<Path> {
  final int index;
  HIClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    
    double barW = w * 0.24;
    double midW = w * 0.05;
    double gap = w * 0.05;
    double ch = h * 0.65;
    
    double totalW = (barW * 3) + midW + gap;
    double startX = (w - totalW) / 2;
    double startY = (h - ch) / 2;
    
    double radius = w * 0.03; // Match the rounding in the reference image

    Path path = Path();

    if (index == 0) {
      // The "H"
      // Left vertical
      final p1 = Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, startY, barW, ch),
        Radius.circular(radius),
      ));
      // Right vertical
      final p2 = Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(startX + barW + midW, startY, barW, ch),
        Radius.circular(radius),
      ));
      // Middle connective bar
      double midH = w * 0.12;
      final p3 = Path()..addRect(Rect.fromLTWH(
        startX + (barW * 0.5), 
        startY + (ch - midH) / 2, 
        barW + midW, 
        midH
      ));
      
      return Path.combine(PathOperation.union, p1, Path.combine(PathOperation.union, p2, p3));
    } else {
      // The "I"
      double iStartX = startX + barW * 2 + midW + gap;
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(iStartX, startY, barW, ch),
        Radius.circular(radius),
      ));
    }

    return path;
  }

  @override
  bool shouldReclip(HIClipper oldClipper) => index != oldClipper.index;
}

class Heart3SplitClipper extends CustomClipper<Path> {
  final int index;
  Heart3SplitClipper({required this.index});

  @override
  Path getClip(Size size) {
    Path heartPath = PerfectHeartClipper().getClip(size);
    if (index == 2) {
      return heartPath;
    } else {
      Path path = Path();
      if (index == 0) {
        // Top half
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));
      } else {
        // Bottom half
        path.addRect(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5));
      }
      return Path.combine(PathOperation.difference, path, heartPath);
    }
  }

  @override
  bool shouldReclip(Heart3SplitClipper oldClipper) => index != oldClipper.index;
}

class LotusSplitClipper extends CustomClipper<Path> {
  final int index;
  LotusSplitClipper({required this.index});

  static Path getLotusPath(double w, double h, int index) {
    if (index == 0) {
      // Center lotus petal + stem
      Path p = Path();
      p.moveTo(w * 0.5, h * 0.2);
      p.quadraticBezierTo(w * 0.85, h * 0.45, w * 0.55, h * 0.75);
      p.lineTo(w * 0.55, h * 0.95);
      p.lineTo(w * 0.45, h * 0.95);
      p.lineTo(w * 0.45, h * 0.75);
      p.quadraticBezierTo(w * 0.15, h * 0.45, w * 0.5, h * 0.2);
      p.close();
      return p;
    } else if (index == 1) {
      // Left 3-pointed shape
      Path p = Path();
      p.moveTo(w * 0.44, h * 0.25); // Top inner
      p.quadraticBezierTo(w * 0.25, h * 0.23, w * 0.06, h * 0.3); // Top outer
      p.quadraticBezierTo(w * -0.02, h * 0.6, w * 0.38, h * 0.72); // Bottom tip
      p.quadraticBezierTo(w * 0.1, h * 0.45, w * 0.44, h * 0.25); // Inner edge
      p.close();
      return p;
    } else {
      // Right 3-pointed shape
      Path p = Path();
      p.moveTo(w * 0.56, h * 0.25); // Top inner
      p.quadraticBezierTo(w * 0.9, h * 0.45, w * 0.62, h * 0.72); // Inner edge down
      p.quadraticBezierTo(w * 1.02, h * 0.6, w * 0.94, h * 0.3); // Outer edge up
      p.quadraticBezierTo(w * 0.75, h * 0.23, w * 0.56, h * 0.25); // Top edge left
      p.close();
      return p;
    }
  }

  @override
  Path getClip(Size size) {
    return getLotusPath(size.width, size.height, index);
  }

  @override
  bool shouldReclip(LotusSplitClipper old) => index != old.index;
}

/// --- FILM STRIP ---
class FilmStripPainter extends CustomPainter {
  final Color accentColor;
  final double strokeWidth;
  FilmStripPainter({required this.accentColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint holePaint = Paint()..color = Colors.black.withOpacity(0.8);
    final Paint borderPaint = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double holeWidth = 10;
    double holeHeight = 14;
    double padding = 20;

    for (double i = 10; i < size.height; i += 28) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(padding, i, holeWidth, holeHeight),
          const Radius.circular(2),
        ),
        holePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width - padding - holeWidth,
            i,
            holeWidth,
            holeHeight,
          ),
          const Radius.circular(2),
        ),
        holePaint,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(45, 0, size.width - 90, size.height),
      borderPaint..color = accentColor.withOpacity(1.0),
    );
  }

  @override
  bool shouldRepaint(FilmStripPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// --- BULB STRING (BOUTIQUE) ---
class BulbStringPainter extends CustomPainter {
  final Color accentColor;
  BulbStringPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final bulbCore = Paint()..color = Colors.amberAccent.withOpacity(0.8);

    _drawRow(
      canvas,
      size,
      90,
      150,
      [0.34, 0.66],
      bulbCore,
      stringPaint,
    );
    _drawRow(canvas, size, 390, 450, [0.48], bulbCore, stringPaint);
  }

  void _drawRow(
    Canvas canvas,
    Size size,
    double startY,
    double ctrlY,
    List<double> bulbPositions,
    Paint core,
    Paint string,
  ) {
    Path path = Path();
    path.moveTo(0, startY);
    path.quadraticBezierTo(size.width / 2, ctrlY, size.width, startY);
    canvas.drawPath(path, string);

    for (double t in bulbPositions) {
      double x = size.width * t;
      double y =
          (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * ctrlY + t * t * startY;
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 20),
        Paint()..color = Colors.white10,
      );
      canvas.drawCircle(Offset(x, y + 28), 3.5, core);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// --- MICKEY FUSED BORDER ---
class MickeyFusedBorderPainter extends CustomPainter {
  final Rect headRect;
  final Rect leftEarRect;
  final Rect rightEarRect;
  final Color color;
  final double strokeWidth;

  MickeyFusedBorderPainter({
    required this.headRect,
    required this.leftEarRect,
    required this.rightEarRect,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path fusedPath = Path()
      ..addOval(headRect)
      ..addOval(leftEarRect)
      ..addOval(rightEarRect);

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fusedPath, borderPaint);
  }

  @override
  bool shouldRepaint(MickeyFusedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// --- FLOWER BORDER ---
class FlowerBorderPainter extends CustomPainter {
  final double radius, centerSize, petalSize;
  final Color color;
  final double width;

  FlowerBorderPainter({
    required this.radius,
    required this.centerSize,
    required this.petalSize,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    final Offset center = Offset(size.width / 2, size.height / 2);
    path.addOval(Rect.fromCircle(center: center, radius: centerSize / 2));
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72) * (math.pi / 180);
      Offset petalCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      path.addOval(Rect.fromCircle(center: petalCenter, radius: petalSize / 2));
    }

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(FlowerBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}

// ═══════════════════════════════════════════════════════════════════════════════
// NEW 2-IMAGE SPLIT CLIPPERS
// ═══════════════════════════════════════════════════════════════════════════════

class ReverseDiagonalSplitClipper extends CustomClipper<Path> {
  final int index;
  ReverseDiagonalSplitClipper({required this.index});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    final split = Path();
    split.moveTo(w, 0);
    split.lineTo(0, 0);
    split.lineTo(w, h);
    split.close();

    if (index == 0) return split;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, split);
  }

  @override
  bool shouldReclip(ReverseDiagonalSplitClipper old) => index != old.index;
}

class ZigzagSplitClipper extends CustomClipper<Path> {
  final int index;
  ZigzagSplitClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    final path = Path();

    final split = Path();
    int zigs = 6;
    double stepY = h / zigs;
    split.moveTo(0, 0);
    for (int i = 0; i <= zigs; i++) {
      double xBase = w * 0.5;
      double xOffset = i % 2 == 0 ? w * 0.1 : -w * 0.1;
      split.lineTo(xBase + xOffset, i * stepY);
    }
    split.lineTo(0, h);
    split.close();

    if (index == 0) return split;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, split);
  }

  @override
  bool shouldReclip(ZigzagSplitClipper old) => index != old.index;
}

class WaveSplitClipper extends CustomClipper<Path> {
  final int index;
  WaveSplitClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double midY = h * 0.5;
    final path = Path();

    final split = Path();
    split.moveTo(0, 0);
    split.lineTo(w, 0);
    split.lineTo(w, midY);
    split.cubicTo(
      w * 0.75,
      midY + h * 0.15,
      w * 0.25,
      midY - h * 0.15,
      0,
      midY,
    );
    split.close();

    if (index == 0) return split;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, split);
  }

  @override
  bool shouldReclip(WaveSplitClipper old) => index != old.index;
}

class VCutSplitClipper extends CustomClipper<Path> {
  final int index;
  VCutSplitClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    final path = Path();

    final split = Path();
    split.moveTo(0, 0);
    split.lineTo(w, 0);
    split.lineTo(w, h * 0.3);
    split.lineTo(w * 0.5, h * 0.65);
    split.lineTo(0, h * 0.3);
    split.close();

    if (index == 0) return split;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, split);
  }

  @override
  bool shouldReclip(VCutSplitClipper old) => index != old.index;
}

class CircleInsetClipper extends CustomClipper<Path> {
  final bool isInside;
  CircleInsetClipper({required this.isInside});

  @override
  Path getClip(Size size) {
    double r = size.width * 0.35;
    Path circle = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.5),
          radius: r,
        ),
      );

    if (isInside) return circle;

    Path full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(PathOperation.difference, full, circle);
  }

  @override
  bool shouldReclip(CircleInsetClipper oldClipper) =>
      isInside != oldClipper.isInside;
}

class DiamondInsetClipper extends CustomClipper<Path> {
  final bool isInside;
  DiamondInsetClipper({required this.isInside});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path diamond = Path()
      ..moveTo(w * 0.5, h * 0.2)
      ..lineTo(w * 0.85, h * 0.5)
      ..lineTo(w * 0.5, h * 0.8)
      ..lineTo(w * 0.15, h * 0.5)
      ..close();

    if (isInside) return diamond;

    Path full = Path()..addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, full, diamond);
  }

  @override
  bool shouldReclip(DiamondInsetClipper oldClipper) =>
      isInside != oldClipper.isInside;
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONCEPTUAL CLIPPERS
// ═══════════════════════════════════════════════════════════════════════════════

class TriangleClipper extends CustomClipper<Path> {
  final int index;
  final int totalCount;

  TriangleClipper({this.index = 0, this.totalCount = 2});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    final path = Path();

    // For 2-image split, we want complementary triangles
    if (totalCount == 2) {
      if (index == 0) {
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h);
        path.lineTo(0, h);
        path.close();
      } else {
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        final mask = Path();
        mask.moveTo(w * 0.5, 0);
        mask.lineTo(w, h);
        mask.lineTo(0, h);
        mask.close();
        return Path.combine(PathOperation.difference, path, mask);
      }
    } else {
      // For 3+ images, unique triangles
      double unitW = w / (totalCount > 1 ? 2 : 1);
      double unitH = h / ((totalCount + 1) ~/ 2);
      double left = (index % 2) * unitW;
      double top = (index ~/ 2) * unitH;

      path.moveTo(left + unitW * 0.5, top);
      path.lineTo(left + unitW, top + unitH);
      path.lineTo(left, top + unitH);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper old) =>
      old.index != index || old.totalCount != totalCount;
}

class TrapezoidClipper extends CustomClipper<Path> {
  final int index;
  TrapezoidClipper({required this.index});

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;

    final trapezoid = Path();
    trapezoid.moveTo(0, 0);
    trapezoid.lineTo(w, 0);
    trapezoid.lineTo(w * 0.8, h);
    trapezoid.lineTo(w * 0.2, h);
    trapezoid.close();

    if (index == 0) return trapezoid;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, trapezoid);
  }

  @override
  bool shouldReclip(TrapezoidClipper old) => old.index != index;
}

class HoneycombClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PINTERESTY / ORGANIC CLIPPERS
// ═══════════════════════════════════════════════════════════════════════════════

class SlantedClipper extends CustomClipper<Path> {
  final double slant;
  final int index;
  SlantedClipper({required this.slant, required this.index});

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;
    double offset = slant * w;

    final split = Path();
    split.moveTo(0, 0);
    split.lineTo(w, 0);
    split.lineTo(w - offset, h);
    split.lineTo(offset, h);
    split.close();

    if (index == 0) return split;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, split);
  }

  @override
  bool shouldReclip(SlantedClipper old) =>
      old.slant != slant || old.index != index;
}

class ParallelogramClipper extends CustomClipper<Path> {
  final double shift;
  final int index;
  ParallelogramClipper({this.shift = 0.2, required this.index});

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;
    double s = shift * w;

    final split = Path();
    split.moveTo(s, 0);
    split.lineTo(w, 0);
    split.lineTo(w - s, h);
    split.lineTo(0, h);
    split.close();

    if (index == 0) return split;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, split);
  }

  @override
  bool shouldReclip(ParallelogramClipper old) =>
      old.shift != shift || old.index != index;
}

class CapsuleClipper extends CustomClipper<Path> {
  final int index;
  final int totalCount;
  CapsuleClipper({this.index = 0, this.totalCount = 1});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    // Calculate a unique capsule per index
    double unitH = h / (totalCount > 0 ? totalCount : 1);
    double top = index * unitH + (unitH * 0.1);
    double capsuleH = unitH * 0.8;

    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, top, w * 0.8, capsuleH),
        Radius.circular(capsuleH / 2),
      ),
    );
  }

  @override
  bool shouldReclip(CapsuleClipper old) =>
      old.index != index || old.totalCount != totalCount;
}

class ArchClipper extends CustomClipper<Path> {
  final int index;
  final int totalCount;
  ArchClipper({this.index = 0, this.totalCount = 1});

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;

    // Unique arch positioning/sizing
    double unitW = w / (totalCount > 0 ? totalCount : 1);
    double left = index * unitW + (unitW * 0.05);
    double archW = unitW * 0.9;
    double archH = h * 0.7;
    double archTop = h * 0.15;

    path.moveTo(left, archTop + archH);
    path.lineTo(left, archTop + archW * 0.5);
    path.arcToPoint(
      Offset(left + archW, archTop + archW * 0.5),
      radius: Radius.circular(archW * 0.5),
      clockwise: true,
    );
    path.lineTo(left + archW, archTop + archH);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(ArchClipper old) =>
      old.index != index || old.totalCount != totalCount;
}

class OrganicBlobClipper extends CustomClipper<Path> {
  final int seed;
  final int index;
  final int totalCount;
  OrganicBlobClipper(this.seed, {this.index = 0, this.totalCount = 1});

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;

    // Scale and offset based on index to ensure visibility
    double scale = 1.0 / (totalCount > 1 ? 1.5 : 1.0);
    double effectiveW = w * scale;
    double effectiveH = h * scale;

    double xOffset = 0;
    double yOffset = 0;

    if (totalCount > 1) {
      // Simple grid-ish offset for multi-blobs
      int cols = (totalCount > 2) ? 2 : 1;
      xOffset = (index % cols) * (w / cols) * 0.5;
      yOffset = (index ~/ cols) * (h / ((totalCount + 1) ~/ 2)) * 0.5;
    }

    if (seed == 0) {
      path.moveTo(xOffset + effectiveW * 0.2, yOffset + effectiveH * 0.1);
      path.quadraticBezierTo(
        xOffset + effectiveW * 0.8,
        yOffset,
        xOffset + effectiveW * 0.9,
        yOffset + effectiveH * 0.3,
      );
      path.quadraticBezierTo(
        xOffset + effectiveW,
        yOffset + effectiveH * 0.7,
        xOffset + effectiveW * 0.7,
        yOffset + effectiveH * 0.9,
      );
      path.quadraticBezierTo(
        xOffset + effectiveW * 0.3,
        yOffset + effectiveH,
        xOffset + effectiveW * 0.1,
        yOffset + effectiveH * 0.7,
      );
      path.quadraticBezierTo(
        xOffset,
        yOffset + effectiveH * 0.3,
        xOffset + effectiveW * 0.2,
        yOffset + effectiveH * 0.1,
      );
    } else {
      path.moveTo(xOffset + effectiveW * 0.1, yOffset + effectiveH * 0.4);
      path.quadraticBezierTo(
        xOffset + effectiveW * 0.2,
        yOffset,
        xOffset + effectiveW * 0.6,
        yOffset + effectiveH * 0.1,
      );
      path.quadraticBezierTo(
        xOffset + effectiveW,
        yOffset + effectiveH * 0.2,
        xOffset + effectiveW * 0.9,
        yOffset + effectiveH * 0.6,
      );
      path.quadraticBezierTo(
        xOffset + effectiveW * 0.8,
        yOffset + effectiveH,
        xOffset + effectiveW * 0.4,
        yOffset + effectiveH * 0.9,
      );
      path.quadraticBezierTo(
        xOffset,
        yOffset + effectiveH * 0.8,
        xOffset + effectiveW * 0.1,
        yOffset + effectiveH * 0.4,
      );
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(OrganicBlobClipper old) =>
      old.seed != seed || old.index != index || old.totalCount != totalCount;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ARTISTIC / NATURE CLIPPERS
// ═══════════════════════════════════════════════════════════════════════════════

class ArtisticNatureClipper extends CustomClipper<Path> {
  final String mode; // 'hearts_flower', 'hearts_balloon', 'random_hearts'
  final int index;
  final int totalCount;

  ArtisticNatureClipper({
    required this.mode,
    required this.index,
    required this.totalCount,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;

    if (mode == 'hearts_flower') {
      // Petal arrangement
      double centerX = w * 0.5;
      double centerY = h * 0.5;
      double radius = w * 0.3; // Increased
      double angle = (2 * math.pi / totalCount) * index;
      double px = centerX + radius * 0.95 * math.cos(angle);
      double py = centerY + radius * 0.95 * math.sin(angle);
      // Increased heart size drastically per user request
      return _getHeartPath(px, py, radius * 1.4, rotation: angle + math.pi / 2);
    } else if (mode == 'hearts_balloon') {
      // Larger balloons
      double bx = (w / (totalCount + 1)) * (index + 1);
      double by = h * 0.4 + (index % 2 == 0 ? -h * 0.18 : h * 0.12);
      double bSize = w * 0.45; // Even larger
      return _getHeartPath(bx, by, bSize);
    } else if (mode == 'random_hearts') {
      // Better distribution, larger hearts
      List<double> xPattern = [0.25, 0.7, 0.35, 0.85, 0.5];
      List<double> yPattern = [0.25, 0.25, 0.75, 0.7, 0.5];
      double rx = xPattern[index % xPattern.length] * w;
      double ry = yPattern[index % yPattern.length] * h;
      double rSize = (index % 2 == 0) ? w * 0.4 : w * 0.5;
      return _getHeartPath(rx, ry, rSize, rotation: index * 0.9);
    } else if (mode == 'leaf_fusion') {
      // Petiole-based organic leaf arrangement
      double centerX = w * 0.5;
      double centerY = h * 0.5;
      double radius = w * 0.32;
      double angle = (2 * math.pi / totalCount) * index;
      double lx = centerX + radius * math.cos(angle);
      double ly = centerY + radius * math.sin(angle);
      return _getLeafPath(lx, ly, radius * 1.5, rotation: angle + math.pi / 2);
    } else if (mode == 'maple_trio') {
      if (index == 0) {
        return _getMapleLeafPath(w * 0.5, h * 0.28, w * 0.35);
      } else if (index == 1) {
        return _getMapleLeafPath(w * 0.25, h * 0.74, w * 0.26);
      } else {
        return _getMapleLeafPath(w * 0.75, h * 0.74, w * 0.26);
      }
    }

    return path..addRect(Rect.fromLTWH(0, 0, w, h));
  }

  Path _getLeafPath(double x, double y, double size, {double rotation = 0}) {
    final path = Path();
    double s = size;

    // Organic leaf shape centered at x,y
    path.moveTo(x, y);
    // Left side of leaf
    path.quadraticBezierTo(x - s * 0.4, y + s * 0.3, x, y + s * 0.8);
    // Right side of leaf
    path.quadraticBezierTo(x + s * 0.4, y + s * 0.3, x, y);
    path.close();

    if (rotation != 0) {
      final matrix = Matrix4.identity()
        ..translate(x, y)
        ..rotateZ(rotation)
        ..translate(-x, -y);
      return path.transform(matrix.storage);
    }
    return path;
  }

  Path _getMapleLeafPath(double x, double y, double size, {double rotation = 0}) {
    final Path leaf = Path();
    double s = size;

    leaf.moveTo(-0.05 * s, 1.0 * s);
    leaf.lineTo(0.05 * s, 1.0 * s);
    leaf.lineTo(0.05 * s, 0.4 * s);
    // bottom right
    leaf.lineTo(0.4 * s, 0.6 * s);
    leaf.lineTo(0.6 * s, 0.7 * s);
    leaf.lineTo(0.55 * s, 0.3 * s);
    leaf.lineTo(0.9 * s, 0.2 * s);
    leaf.lineTo(0.6 * s, -0.1 * s);
    leaf.lineTo(0.7 * s, -0.4 * s);
    // top center
    leaf.lineTo(0.3 * s, -0.4 * s);
    leaf.lineTo(0.45 * s, -0.8 * s);
    leaf.lineTo(0.2 * s, -0.7 * s);
    leaf.lineTo(0.0, -1.0 * s); // Top Tip
    leaf.lineTo(-0.2 * s, -0.7 * s);
    leaf.lineTo(-0.45 * s, -0.8 * s);
    leaf.lineTo(-0.3 * s, -0.4 * s);
    // left side
    leaf.lineTo(-0.7 * s, -0.4 * s);
    leaf.lineTo(-0.6 * s, -0.1 * s);
    leaf.lineTo(-0.9 * s, 0.2 * s);
    leaf.lineTo(-0.55 * s, 0.3 * s);
    // bottom left
    leaf.lineTo(-0.6 * s, 0.7 * s);
    leaf.lineTo(-0.4 * s, 0.6 * s);
    leaf.lineTo(-0.05 * s, 0.4 * s);
    leaf.close();

    if (rotation != 0) {
      final matrix = Matrix4.identity()
        ..translate(x, y)
        ..rotateZ(rotation);
      return leaf.transform(matrix.storage);
    } else {
      final matrix = Matrix4.identity()
        ..translate(x, y);
      return leaf.transform(matrix.storage);
    }
  }

  Path _getHeartPath(double x, double y, double size, {double rotation = 0}) {
    final path = Path();
    double s = size;

    // Standardized perfect heart (Synchronized with painter)
    path.moveTo(x, y + s * 0.2);
    path.cubicTo(
      x,
      y - s * 0.15,
      x + s * 0.5,
      y - s * 0.15,
      x + s * 0.5,
      y + s * 0.3,
    );
    path.cubicTo(x + s * 0.5, y + s * 0.55, x, y + s * 0.75, x, y + s * 0.95);
    path.cubicTo(
      x,
      y + s * 0.75,
      x - s * 0.5,
      y + s * 0.55,
      x - s * 0.5,
      y + s * 0.3,
    );
    path.cubicTo(x - s * 0.5, y - s * 0.15, x, y - s * 0.15, x, y + s * 0.2);
    path.close();

    if (rotation != 0) {
      final matrix = Matrix4.identity()
        ..translate(x, y)
        ..rotateZ(rotation)
        ..translate(-x, -y);
      return path.transform(matrix.storage);
    }
    return path;
  }

  @override
  bool shouldReclip(ArtisticNatureClipper old) =>
      old.mode != mode || old.index != index || old.totalCount != totalCount;
}

class StampTrioClipper extends CustomClipper<Path> {
  final int index;
  final int totalCount;
  StampTrioClipper({required this.index, required this.totalCount});

  static Path getStampPath(Rect rect, {double scallopRadius = 6}) {
    final path = Path();
    final double left = rect.left;
    final double top = rect.top;
    final double right = rect.right;
    final double bottom = rect.bottom;
    final double width = rect.width;
    final double height = rect.height;

    path.moveTo(left, top);

    // Top edge
    int horizontalSteps = (width / (scallopRadius * 2)).floor();
    double hStepWidth = width / horizontalSteps;
    for (int i = 0; i < horizontalSteps; i++) {
      path.arcToPoint(
        Offset(left + (i + 1) * hStepWidth, top),
        radius: Radius.circular(scallopRadius),
        clockwise: false,
      );
    }

    // Right edge
    int verticalSteps = (height / (scallopRadius * 2)).floor();
    double vStepHeight = height / verticalSteps;
    for (int i = 0; i < verticalSteps; i++) {
      path.arcToPoint(
        Offset(right, top + (i + 1) * vStepHeight),
        radius: Radius.circular(scallopRadius),
        clockwise: false,
      );
    }

    // Bottom edge
    for (int i = 0; i < horizontalSteps; i++) {
      path.arcToPoint(
        Offset(right - (i + 1) * hStepWidth, bottom),
        radius: Radius.circular(scallopRadius),
        clockwise: false,
      );
    }

    // Left edge
    for (int i = 0; i < verticalSteps; i++) {
      path.arcToPoint(
        Offset(left, bottom - (i + 1) * vStepHeight),
        radius: Radius.circular(scallopRadius),
        clockwise: false,
      );
    }

    path.close();
    return path;
  }

  @override
  Path getClip(Size size) {
    if (totalCount == 3) {
      double w = size.width;
      double h = size.height;
      double s = w * 0.42; // Stamp container size
      double imgS = s * 0.82; // Image size (rounded rect)

      Offset center;
      if (index == 0)
        center = Offset(w * 0.28, h * 0.3);
      else if (index == 1)
        center = Offset(w * 0.72, h * 0.3);
      else
        center = Offset(w * 0.5, h * 0.74);

      return Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: imgS, height: imgS),
          Radius.circular(imgS * 0.12),
        ));
    }
    return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(StampTrioClipper old) =>
      old.index != index || old.totalCount != totalCount;
}

class SlantedRowClipper extends CustomClipper<Path> {
  final int index;
  final int totalCount;
  SlantedRowClipper({required this.index, required this.totalCount});

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double rowH = h / 3;
    final double slantW = w * 0.12;
    final double gap = 12.0;

    Path path = Path();
    double top = index * rowH;
    double bottom = (index + 1) * rowH;

    // Apply gaps for a premium look
    top += gap / 2;
    bottom -= gap / 2;

    if (index == 0) {
      path.moveTo(0, top);
      path.lineTo(w, top);
      path.lineTo(w - slantW, bottom);
      path.lineTo(0, bottom);
    } else if (index == 1) {
      path.moveTo(slantW, top);
      path.lineTo(w, top);
      path.lineTo(w - slantW, bottom);
      path.lineTo(0, bottom);
    } else {
      path.moveTo(slantW, top);
      path.lineTo(w, top);
      path.lineTo(w, bottom);
      path.lineTo(0, bottom);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SlantedRowClipper old) =>
      old.index != index || old.totalCount != totalCount;
}

class HexagonSplitClipper extends CustomClipper<Path> {
  final int index;
  final int totalCount;
  HexagonSplitClipper({required this.index, required this.totalCount});

  static Path getHexagonPath(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = math.min(w, h) * 0.46;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 - 90) * math.pi / 180;
      double x = cx + r * math.cos(angle);
      double y = cy + r * math.sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = math.min(w, h) * 0.46;

    Path hex = getHexagonPath(size);
    Path region = Path();

    List<Offset> v = [];
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 - 90) * math.pi / 180;
      v.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    if (totalCount == 3) {
      if (index == 0) {
        region.moveTo(cx, cy);
        region.lineTo(v[0].dx, v[0].dy);
        region.lineTo(v[5].dx, v[5].dy);
        region.lineTo(v[4].dx, v[4].dy);
      } else if (index == 1) {
        region.moveTo(cx, cy);
        region.lineTo(v[0].dx, v[0].dy);
        region.lineTo(v[1].dx, v[1].dy);
        region.lineTo(v[2].dx, v[2].dy);
      } else {
        region.moveTo(cx, cy);
        region.lineTo(v[2].dx, v[2].dy);
        region.lineTo(v[3].dx, v[3].dy);
        region.lineTo(v[4].dx, v[4].dy);
      }
      region.lineTo(cx, cy);
      region.close();
    } else if (totalCount == 4) {
      if (index == 0) {
        region.moveTo(cx, cy);
        region.lineTo(v[0].dx, v[0].dy);
        region.lineTo(v[5].dx, v[5].dy);
        region.lineTo(v[4].dx, v[4].dy);
      } else if (index == 1) {
        region.moveTo(cx, cy);
        region.lineTo(v[0].dx, v[0].dy);
        region.lineTo(v[1].dx, v[1].dy);
      } else if (index == 2) {
        region.moveTo(cx, cy);
        region.lineTo(v[1].dx, v[1].dy);
        region.lineTo(v[2].dx, v[2].dy);
        region.lineTo(v[3].dx, v[3].dy);
      } else {
        region.moveTo(cx, cy);
        region.lineTo(v[3].dx, v[3].dy);
        region.lineTo(v[4].dx, v[4].dy);
      }
      region.lineTo(cx, cy);
      region.close();
    } else {
      return hex;
    }

    return Path.combine(PathOperation.intersect, hex, region);
  }

  @override
  bool shouldReclip(HexagonSplitClipper old) =>
      old.index != index || old.totalCount != totalCount;
}

class FloatingColumnClipper extends CustomClipper<Path> {
  final int index;
  final int totalCount;
  FloatingColumnClipper({required this.index, required this.totalCount});

  static Rect getColumnRect(int index, int totalCount, Size size) {
    final double w = size.width;
    final double h = size.height;
    if (totalCount == 3) {
      if (index == 0)
        return Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.28, h * 0.9); // Big
      if (index == 1)
        return Rect.fromLTWH(w * 0.36, h * 0.15, w * 0.28, h * 0.7); // Medium
      return Rect.fromLTWH(w * 0.67, h * 0.25, w * 0.28, h * 0.5); // Small
    } else if (totalCount == 4) {
      if (index == 0)
        return Rect.fromLTWH(w * 0.03, h * 0.05, w * 0.21, h * 0.9);
      if (index == 1)
        return Rect.fromLTWH(w * 0.27, h * 0.13, w * 0.21, h * 0.74);
      if (index == 2)
        return Rect.fromLTWH(w * 0.52, h * 0.21, w * 0.21, h * 0.58);
      return Rect.fromLTWH(w * 0.76, h * 0.29, w * 0.21, h * 0.42);
    }
    return Rect.fromLTWH(0, 0, w, h);
  }


  @override
  Path getClip(Size size) {
    final rect = getColumnRect(index, totalCount, size);
    final radius = Radius.circular(size.width * 0.08);
    return Path()..addRRect(RRect.fromRectAndRadius(rect, radius));
  }

  @override
  bool shouldReclip(FloatingColumnClipper old) =>
      old.index != index || old.totalCount != totalCount;
}

class ILoveUClipper extends CustomClipper<Path> {
  final int index;
  ILoveUClipper({required this.index});

  static Path getILoveUPath(int index, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final double ch = h * 0.75;

    if (index == 0) {
      // Shape "I" (Capsule)
      double uw = w * 0.2;
      return Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(w * 0.16, cy), width: uw, height: ch),
          Radius.circular(uw * 0.5),
        ));
    } else if (index == 1) {
      // Shape "Heart" (❤️)
      final path = Path();
      double hs = w * 0.38;
      double hx = cx;
      double hy = cy - hs * 0.45;

      path.moveTo(hx, hy + hs * 0.2);
      path.cubicTo(hx, hy - hs * 0.15, hx + hs * 0.5, hy - hs * 0.15, hx + hs * 0.5,
          hy + hs * 0.3);
      path.cubicTo(
          hx + hs * 0.5, hy + hs * 0.55, hx, hy + hs * 0.75, hx, hy + hs * 0.95);
      path.cubicTo(
          hx, hy + hs * 0.75, hx - hs * 0.5, hy + hs * 0.55, hx - hs * 0.5, hy + hs * 0.3);
      path.cubicTo(hx - hs * 0.5, hy - hs * 0.15, hx, hy - hs * 0.15, hx, hy + hs * 0.2);
      path.close();
      return path;
    } else {
      // Shape "U"
      final path = Path();
      double uw = w * 0.26;
      double ux = w * 0.84;
      double uy = cy;
      double uh = ch;
      double ur = uw * 0.5;

      // Outer U
      path.moveTo(ux - uw / 2, uy - uh / 2);
      path.lineTo(ux - uw / 2, uy + uh / 2 - ur);
      path.arcToPoint(Offset(ux + uw / 2, uy + uh / 2 - ur),
          radius: Radius.circular(ur), clockwise: false);
      path.lineTo(ux + uw / 2, uy - uh / 2);

      // Inner U (hole) - narrowed gap, thicker columns
      double holeW = uw * 0.35;
      path.lineTo(ux + holeW / 2, uy - uh / 2);
      path.lineTo(ux + holeW / 2, uy + uh / 2 - ur);
      path.arcToPoint(Offset(ux - holeW / 2, uy + uh / 2 - ur),
          radius: Radius.circular(ur * 0.2), clockwise: true);
      path.lineTo(ux - holeW / 2, uy - uh / 2);

      path.close();
      return path;
    }
  }

  @override
  Path getClip(Size size) {
    return getILoveUPath(index, size);
  }

  @override
  bool shouldReclip(ILoveUClipper old) => old.index != index;
}

class FilmStripClipper extends CustomClipper<Path> {
  final int index;
  FilmStripClipper({required this.index});

  static Path getFilmStripPath(int index, Size size) {
    final double w = size.width;
    final double h = size.height;

    Rect rect;
    if (index == 0) {
      rect = Rect.fromLTRB(w * 0.05, h * 0.08, w * 0.6, h * 0.45);
    } else if (index == 1) {
      rect = Rect.fromLTRB(w * 0.4, h * 0.28, w * 0.95, h * 0.65);
    } else {
      rect = Rect.fromLTRB(w * 0.05, h * 0.52, w * 0.6, h * 0.9);
    }

    Path path = Path()..addRect(rect);

    // Perforations
    double perfW = rect.width * 0.045;
    double perfH = rect.height * 0.07;
    double spacing = rect.width * 0.09;

    Path perfs = Path();
    for (double x = rect.left + spacing / 2.5; x < (rect.right - perfW); x += spacing) {
      // Top perfs
      perfs.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x, rect.top + rect.height * 0.06, perfW, perfH),
        const Radius.circular(2),
      ));
      // Bottom perfs
      perfs.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x, rect.bottom - rect.height * 0.06 - perfH, perfW, perfH),
        const Radius.circular(2),
      ));
    }

    return Path.combine(PathOperation.difference, path, perfs);
  }

  @override
  Path getClip(Size size) {
    return getFilmStripPath(index, size);
  }

  @override
  bool shouldReclip(FilmStripClipper old) => old.index != index;
}

class TornPaperClipper extends CustomClipper<Path> {
  final int index;
  TornPaperClipper({required this.index});

  static List<Offset> _getJaggedPoints(Offset start, Offset end, int segments, double variance, double seed) {
    final List<Offset> points = [start];
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) return points;
    final double nx = -dy / length;
    final double ny = dx / length;

    for (int i = 1; i < segments; i++) {
        double t = i / segments;
        // Natural ease-in/ease-out for the tear
        double ease = 1.0 - (2 * t - 1.0).abs();
        double px = start.dx + dx * t;
        double py = start.dy + dy * t;
        // Multi-frequency noise-like jitter
        double offset = math.sin(i * seed * 1.7) * variance * ease +
                       math.cos(i * seed * 3.1) * (variance * 0.4) +
                       math.sin(i * 0.5) * (variance * 0.2);
        points.add(Offset(px + nx * offset, py + ny * offset));
    }
    points.add(end);
    return points;
  }

  static Path getTornPath(int index, Size size) {
    const double inset = 4.0;
    final double availW = size.width - inset * 2;
    final double availH = size.height - inset * 2;
    final double splitV = availW * 0.46;
    final double splitH = availH * 0.52;
    
    final j = Offset(splitV, splitH);

    final vTop = _getJaggedPoints(Offset(splitV, 0), j, 20, 10.0, 1.12);
    final vBottom = _getJaggedPoints(j, Offset(splitV, availH), 20, 10.0, 1.45);
    final hRight = _getJaggedPoints(j, Offset(availW, splitH), 22, 12.0, 5.67);

    final path = Path();
    if (index == 0) {
      path.moveTo(0, 0);
      for (var p in vTop) path.lineTo(p.dx, p.dy);
      // Small "corner tear" detail at cross cut
      path.lineTo(j.dx - 6, j.dy + 10);
      for (var p in vBottom) path.lineTo(p.dx, p.dy);
      path.lineTo(0, availH);
      path.lineTo(0, 0);
      path.close();
    } else if (index == 1) {
      path.moveTo(splitV, 0);
      for (var p in vTop) path.lineTo(p.dx, p.dy);
      // Intentional slight overlap for aesthetic cross cut
      path.lineTo(j.dx + 6, j.dy + 4);
      for (var p in hRight) path.lineTo(p.dx, p.dy);
      path.lineTo(availW, 0);
      path.lineTo(splitV, 0);
      path.close();
    } else {
      path.moveTo(j.dx + 6, j.dy + 4);
      for (var p in hRight) path.lineTo(p.dx, p.dy);
      path.lineTo(availW, availH);
      path.lineTo(splitV, availH);
      for (var p in vBottom.reversed) path.lineTo(p.dx, p.dy);
      // Close the loop back at the cross cut detail
      path.lineTo(j.dx - 6, j.dy + 10);
      path.close();
    }

    return path.shift(const Offset(inset, inset));
  }

  @override
  Path getClip(Size size) => getTornPath(index, size);

  @override
  bool shouldReclip(TornPaperClipper old) => old.index != index;
}

class TornDiagonalClipper extends CustomClipper<Path> {
  final int index;
  TornDiagonalClipper({required this.index});

  @override
  Path getClip(Size size) {
    const double inset = 5.0;
    final double w = size.width - inset * 2;
    final double h = size.height - inset * 2;

    // Define the jagged strip path
    final topPoints = TornPaperClipper._getJaggedPoints(
      Offset(0, h * 0.35),
      Offset(w, h * 0.52),
      35,
      18.0,
      2.1,
    );
    final bottomPoints = TornPaperClipper._getJaggedPoints(
      Offset(w, h * 0.88),
      Offset(0, h * 0.7),
      35,
      18.0,
      4.7,
    );

    final closedStrip = Path();
    closedStrip.moveTo(topPoints.first.dx, topPoints.first.dy);
    for (var p in topPoints) closedStrip.lineTo(p.dx, p.dy);
    for (var p in bottomPoints) closedStrip.lineTo(p.dx, p.dy);
    closedStrip.close();

    final shiftedStrip = closedStrip.shift(const Offset(inset, inset));

    if (index == 1) return shiftedStrip;

    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(PathOperation.difference, path, shiftedStrip);
  }

  @override
  bool shouldReclip(TornDiagonalClipper old) => old.index != index;
}


class TornDiagonalPainter extends CustomPainter {
  final Color color;
  final double width;
  TornDiagonalPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(TornDiagonalClipper(index: 1).getClip(size), paint);
  }

  @override
  bool shouldRepaint(TornDiagonalPainter old) =>
      old.color != color || old.width != width;
}

class GhostClipper extends CustomClipper<Path> {
  final int index;
  GhostClipper({required this.index});

  static Path getGhostPath(Rect rect, bool flipX, Size totalSize) {
    final double w = rect.width;
    final double h = rect.height;
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    final path = Path();
    
    // Ghost body/head
    if (!flipX) {
      path.moveTo(rect.left, cy);
      // Top circular head
      path.arcTo(Rect.fromLTWH(rect.left, rect.top, w, h * 0.7), math.pi, math.pi, false);
      // Swoosh tail
      path.quadraticBezierTo(rect.right, rect.bottom, rect.left + w * 0.2, rect.bottom);
      path.quadraticBezierTo(rect.left + w * 0.5, rect.bottom - h * 0.1, rect.left, cy);
    } else {
      path.moveTo(rect.right, cy);
      path.arcTo(Rect.fromLTWH(rect.left, rect.top, w, h * 0.7), 0, -math.pi, false);
      // Swoosh tail
      path.quadraticBezierTo(rect.left, rect.bottom, rect.right - w * 0.2, rect.bottom);
      path.quadraticBezierTo(rect.right - w * 0.5, rect.bottom - h * 0.1, rect.right, cy);
    }
    path.close();

    // Eyes
    final eyeW = w * 0.12;
    final eyeH = h * 0.18;
    final eyeY = rect.top + h * 0.25;
    final double eyeOffset = flipX ? -w * 0.1 : w * 0.1;
    
    final eyeLeft = Path()..addOval(Rect.fromCenter(
      center: Offset(cx + eyeOffset - eyeW * 0.7, eyeY),
      width: eyeW,
      height: eyeH,
    ));
    final eyeRight = Path()..addOval(Rect.fromCenter(
      center: Offset(cx + eyeOffset + eyeW * 0.7, eyeY),
      width: eyeW,
      height: eyeH,
    ));

    Path finalPath = Path.combine(PathOperation.difference, path, eyeLeft);
    finalPath = Path.combine(PathOperation.difference, finalPath, eyeRight);
    
    return finalPath;
  }

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    
    if (index == 0) {
      return getGhostPath(Rect.fromLTWH(w * 0.1, h * 0.08, w * 0.42, h * 0.42), false, size);
    } else if (index == 1) {
      return getGhostPath(Rect.fromLTWH(w * 0.58, h * 0.05, w * 0.35, h * 0.35), true, size);
    } else if (index == 2) {
      return getGhostPath(Rect.fromLTWH(w * 0.05, h * 0.52, w * 0.38, h * 0.38), false, size);
    } else {
      return getGhostPath(Rect.fromLTWH(w * 0.48, h * 0.48, w * 0.48, h * 0.5), true, size);
    }
  }

  @override
  bool shouldReclip(GhostClipper old) => old.index != index;
}

class GhostAirPainter extends CustomPainter {
  final Color color;
  final double width;
  GhostAirPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 4; i++) {
      canvas.drawPath(GhostClipper(index: i).getClip(size), paint);
    }
  }

  @override
  bool shouldRepaint(GhostAirPainter old) =>
      old.color != color || old.width != width;
}

class ChristmasStarClipper extends CustomClipper<Path> {
  final int index;
  ChristmasStarClipper({required this.index});

  static Path getTreePath(Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w * 0.5;

    // Helper to create a rounded trapezoid/triangle tier
    Path createTier(double topY, double bottomY, double topW, double bottomW, double radius) {
      final path = Path();
      double leftTop = cx - (topW / 2);
      double rightTop = cx + (topW / 2);
      double leftBottom = cx - (bottomW / 2);
      double rightBottom = cx + (bottomW / 2);

      path.moveTo(leftTop + radius, topY);
      path.lineTo(rightTop - radius, topY);
      path.quadraticBezierTo(rightTop, topY, rightTop + (rightBottom - rightTop) * 0.1, topY + (bottomY - topY) * 0.1);
      path.lineTo(rightBottom - radius, bottomY);
      path.quadraticBezierTo(rightBottom, bottomY, rightBottom - radius, bottomY); // simplified rounding
      path.lineTo(leftBottom + radius, bottomY);
      path.quadraticBezierTo(leftBottom, bottomY, leftBottom - (leftBottom - leftTop) * 0.1, bottomY - (bottomY - topY) * 0.1);
      path.lineTo(leftTop, topY + radius);
      path.quadraticBezierTo(leftTop, topY, leftTop + radius, topY);
      path.close();
      return path;
    }

    // Proportions matched to reference image
    Path t1 = createTier(h * 0.05, h * 0.38, w * 0.05, w * 0.52, 8);
    Path t2 = createTier(h * 0.32, h * 0.68, w * 0.35, w * 0.78, 8);
    Path t3 = createTier(h * 0.62, h * 0.92, w * 0.55, w * 0.98, 8);

    Path trunk = Path();
    trunk.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.1, h * 0.92, w * 0.2, h * 0.08),
      const Radius.circular(4),
    ));

    // Combine them all using union to remove internal edges
    Path combined = Path.combine(PathOperation.union, t1, t2);
    combined = Path.combine(PathOperation.union, combined, t3);
    combined = Path.combine(PathOperation.union, combined, trunk);

    return combined;
  }

  static Path getStarPath(Size size, Offset center, double starSize) {
    final path = Path();
    const int points = 5;
    double outerRadius = starSize;
    double innerRadius = starSize * 0.42;
    double angle = -math.pi / 2;
    double step = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      double r = i.isEven ? outerRadius : innerRadius;
      double x = center.dx + math.cos(angle) * r;
      double y = center.dy + math.sin(angle) * r;
      if (i == 0)
        path.moveTo(x, y);
      else {
        // Soft rounded corners at tips
        path.quadraticBezierTo(center.dx + math.cos(angle - step * 0.5) * r * 1.05, 
                               center.dy + math.sin(angle - step * 0.5) * r * 1.05, 
                               x, y);
      }
      angle += step;
    }
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) {
    if (index == 0) return getTreePath(size);
    if (index == 1)
      return getStarPath(
        size,
        Offset(size.width * 0.22, size.height * 0.31),
        size.width * 0.22,
      );
    return getStarPath(
      size,
      Offset(size.width * 0.75, size.height * 0.69),
      size.width * 0.22,
    );
  }

  @override
  bool shouldReclip(ChristmasStarClipper oldClipper) =>
      oldClipper.index != index;
}

class ChristmasStarPainter extends CustomPainter {
  final Color color;
  final double width;
  ChristmasStarPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final w = size.width;
    final h = size.height;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s1Center = Offset(w * 0.22, h * 0.31);
    final s2Center = Offset(w * 0.75, h * 0.69);

    // --- Main Silhouette Borders ---
    canvas.drawPath(ChristmasStarClipper.getTreePath(size), paint);
    canvas.drawPath(
      ChristmasStarClipper.getStarPath(size, s1Center, w * 0.22),
      paint,
    );
    canvas.drawPath(
      ChristmasStarClipper.getStarPath(size, s2Center, w * 0.22),
      paint,
    );
  }

  @override
  bool shouldRepaint(ChristmasStarPainter old) =>
      old.color != color || old.width != width;
}

class PuzzleTrioClipper extends CustomClipper<Path> {
  final int index;
  PuzzleTrioClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double tr = w * 0.07; // tab radius
    double gap = w * 0.05; // gap between pieces

    // Helper for bulbous puzzle piece
    Path buildPerfectPiece(Rect rect, {int top = 0, int right = 0, int bottom = 0, int left = 0}) {
      Path path = Path()..addRect(rect);
      
      // Convex Tabs
      if (top == 1) path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.center.dx, rect.top), radius: tr)));
      if (right == 1) path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.right, rect.center.dy), radius: tr)));
      if (bottom == 1) path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.center.dx, rect.bottom), radius: tr)));
      if (left == 1) path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.left, rect.center.dy), radius: tr)));
      
      // Concave Blanks
      if (top == -1) path = Path.combine(PathOperation.difference, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.center.dx, rect.top), radius: tr)));
      if (right == -1) path = Path.combine(PathOperation.difference, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.right, rect.center.dy), radius: tr)));
      if (bottom == -1) path = Path.combine(PathOperation.difference, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.center.dx, rect.bottom), radius: tr)));
      if (left == -1) path = Path.combine(PathOperation.difference, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.left, rect.center.dy), radius: tr)));
      
      return path;
    }

    if (index == 0) {
      // Piece 0 (Left piece)
      Rect rect = Rect.fromLTWH(w * 0.06, h * 0.3, w * 0.38 - gap, h * 0.4);
      return buildPerfectPiece(rect, top: -1, right: 1, bottom: -1, left: -1);
    } else if (index == 1) {
      // Piece 1 (Top-right piece)
      Rect rect = Rect.fromLTWH(w * 0.06 + w * 0.38 + gap, h * 0.1, w * 0.44, h * 0.36 - gap);
      return buildPerfectPiece(rect, top: -1, left: -1, bottom: -1, right: 1);
    } else {
      // Piece 2 (Bottom-right piece)
      Rect rect = Rect.fromLTWH(w * 0.06 + w * 0.38 + gap, h * 0.1 + h * 0.36 + gap, w * 0.44, h * 0.44);
      return buildPerfectPiece(rect, top: 1, left: -1, bottom: -1, right: 1);
    }
  }

  @override
  bool shouldReclip(PuzzleTrioClipper oldClipper) => oldClipper.index != index;
}

class PuzzleTrioPainter extends CustomPainter {
  final Color color;
  final double width;
  PuzzleTrioPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 3; i++) {
      canvas.drawPath(PuzzleTrioClipper(index: i).getClip(size), paint);
    }
  }

  @override
  bool shouldRepaint(PuzzleTrioPainter old) =>
      old.color != color || old.width != width;
}

class CatHeartsClipper extends CustomClipper<Path> {
  final int index;
  CatHeartsClipper({required this.index});

  @override
  Path getClip(Size size) {
    if (index == 0) return getCatPath(size);
    if (index == 1) return getHeartPath(size, Offset(size.width * 0.35, size.height * 0.12), size.width * 0.18);
    return getHeartPath(size, Offset(size.width * 0.85, size.height * 0.1), size.width * 0.28);
  }

  static Path getCatPath(Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w * 0.52;
    
    // 1. Silhouette Logic (Head, Ears, Body, Tail)
    // Head top center
    double headR = w * 0.22;
    double headY = h * 0.45;
    double bodyW = w * 0.6;
    double bodyH = h * 0.45;
    
    // 1. Head (Circular base)
    Path head = Path();
    head.addOval(Rect.fromCircle(center: Offset(cx, headY), radius: headR));
    
    // 2. Ears (Sharp Pointy)
    Path ears = Path();
    // Right Ear
    ears.moveTo(cx + headR * 0.5, headY - headR * 0.8);
    ears.lineTo(cx + headR * 1.2, headY - headR * 1.5);
    ears.lineTo(cx + headR * 0.9, headY - headR * 0.2);
    ears.close();
    // Left Ear
    ears.moveTo(cx - headR * 0.5, headY - headR * 0.8);
    ears.lineTo(cx - headR * 1.2, headY - headR * 1.5);
    ears.lineTo(cx - headR * 0.9, headY - headR * 0.2);
    ears.close();

    // 3. Body (Wide Rounded Bottom)
    Path body = Path();
    body.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - bodyW / 2, headY + headR * 0.3, bodyW, bodyH),
      Radius.circular(w * 0.2),
    ));

    // 4. Tail (Thick S-curve, Shifted Outside)
    double tailStart = cx - bodyW / 2 - w * 0.05;
    Path tailPath = Path();
    tailPath.moveTo(tailStart + w * 0.05, h * 0.95);
    tailPath.cubicTo(tailStart - w * 0.55, h * 0.95, tailStart - w * 0.55, h * 0.4, tailStart, h * 0.5);
    tailPath.lineTo(tailStart + w * 0.12, h * 0.62);
    tailPath.cubicTo(tailStart - w * 0.35, h * 0.62, tailStart - w * 0.35, h * 0.82, tailStart + w * 0.1, h * 0.85);
    tailPath.close();

    // Combine
    Path cat = Path.combine(PathOperation.union, body, head);
    cat = Path.combine(PathOperation.union, cat, ears);
    cat = Path.combine(PathOperation.union, cat, tailPath);

    // 5. Cutout Details
    double eyY = headY + headR * 0.1;
    Path cutouts = Path();
    // Eyes (Vertical Ovals)
    cutouts.addOval(Rect.fromLTWH(cx - w * 0.1, eyY, w * 0.055, h * 0.055));
    cutouts.addOval(Rect.fromLTWH(cx + w * 0.045, eyY, w * 0.055, h * 0.055));
    // Nose (Small Heart)
    cutouts.addPath(getHeartPath(size, Offset(cx, eyY + h * 0.075), w * 0.015), Offset.zero);
    
    // Curved Whiskers
    for (int i = 0; i < 3; i++) {
        double yOff = (i - 1) * h * 0.025;
        double swX = cx - w * 0.15; // start whisker X
        double seX = cx + w * 0.15;
        double wY = eyY + h * 0.08 + yOff;
        
        // Left Whiskers (curved)
        Path lw = Path();
        lw.moveTo(swX, wY);
        lw.quadraticBezierTo(swX - w * 0.08, wY + h * 0.01, swX - w * 0.12, wY - h * 0.01);
        cutouts.addPath(lw, Offset.zero);
        
        // Right Whiskers (curved)
        Path rw = Path();
        rw.moveTo(seX, wY);
        rw.quadraticBezierTo(seX + w * 0.08, wY + h * 0.01, seX + w * 0.12, wY - h * 0.01);
        cutouts.addPath(rw, Offset.zero);
    }

    return Path.combine(PathOperation.difference, cat, cutouts);
  }

  static Path getHeartPath(Size size, Offset center, double radius) {
    final path = Path();
    final x = center.dx;
    final y = center.dy;
    final r = radius;
    
    path.moveTo(x, y + r * 0.4);
    path.cubicTo(x - r, y - r * 0.5, x - r * 1.5, y + r * 0.5, x, y + r * 1.25);
    path.cubicTo(x + r * 1.5, y + r * 0.5, x + r, y - r * 0.5, x, y + r * 0.4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CatHeartsClipper oldClipper) => oldClipper.index != index;
}

class CatHeartsPainter extends CustomPainter {
  final Color color;
  final double width;
  CatHeartsPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw main borders
    canvas.drawPath(CatHeartsClipper.getCatPath(size), paint);
    canvas.drawPath(CatHeartsClipper.getHeartPath(size, Offset(size.width * 0.35, size.height * 0.12), size.width * 0.18), paint);
    canvas.drawPath(CatHeartsClipper.getHeartPath(size, Offset(size.width * 0.85, size.height * 0.1), size.width * 0.28), paint);
  }

  @override
  bool shouldRepaint(CatHeartsPainter old) =>
      old.color != color || old.width != width;
}

class LoveStoryClipper extends CustomClipper<Path> {
  final int index;
  LoveStoryClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double lY = h * 0.58; // letters Y position
    double lH = h * 0.38; // letters height
    double lW = w * 0.22; // letters width
    double r = w * 0.04;  // corner radius

    if (index == 0) {
      // Large Heart
      return ChristmasStarClipper.getStarPath(size, Offset(w * 0.5, h * 0.28), w * 0.38);
    }
    
    // Letters
    if (index == 1) { // L
      return getLPath(Rect.fromLTWH(w * 0.04, lY, lW, lH), r);
    } else if (index == 2) { // O
      return getOPath(Rect.fromLTWH(w * 0.28, lY, lW, lH), r);
    } else if (index == 3) { // V
      return getVPath(Rect.fromLTWH(w * 0.52, lY, lW, lH), r);
    } else { // E
      return getEPath(Rect.fromLTWH(w * 0.76, lY, lW, lH), r);
    }
  }

  static Path getLPath(Rect rect, double r) {
    double bw = rect.width * 0.38;
    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.top, bw, rect.height), Radius.circular(r)));
    path = Path.combine(PathOperation.union, path, 
      Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.bottom - bw, rect.width, bw), Radius.circular(r))));
    return path;
  }

  static Path getOPath(Rect rect, double r) {
    return Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.4)));
  }

  static Path getVPath(Rect rect, double r) {
    double bw = rect.width * 0.42;
    Path path = Path();
    // Left part
    path.moveTo(rect.left, rect.top);
    path.lineTo(rect.left + bw, rect.top);
    path.lineTo(rect.center.dx + bw/2, rect.bottom);
    path.lineTo(rect.center.dx - bw/2, rect.bottom);
    path.close();
    // Right part
    Path right = Path();
    right.moveTo(rect.right - bw, rect.top);
    right.lineTo(rect.right, rect.top);
    right.lineTo(rect.center.dx + bw/2, rect.bottom);
    right.lineTo(rect.center.dx - bw/2, rect.bottom);
    right.close();
    
    return Path.combine(PathOperation.union, path, right);
  }

  static Path getEPath(Rect rect, double r) {
    double bw = rect.width * 0.38;
    Path path = Path();
    // Vertical bar
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.top, bw, rect.height), Radius.circular(r)));
    // Top bar
    path = Path.combine(PathOperation.union, path, 
      Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.top, rect.width, bw), Radius.circular(r))));
    // Middle bar
    path = Path.combine(PathOperation.union, path, 
      Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.center.dy - bw/2, rect.width * 0.8, bw), Radius.circular(r))));
    // Bottom bar
    path = Path.combine(PathOperation.union, path, 
      Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.bottom - bw, rect.width, bw), Radius.circular(r))));
    return path;
  }

  @override
  bool shouldReclip(LoveStoryClipper oldClipper) => oldClipper.index != index;
}

class LoveStoryPainter extends CustomPainter {
  final Color color;
  final double width;
  LoveStoryPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 5; i++) {
        canvas.drawPath(LoveStoryClipper(index: i).getClip(size), paint);
    }
  }

  @override
  bool shouldRepaint(LoveStoryPainter old) =>
      old.color != color || old.width != width;
}

class Radial5Clipper extends CustomClipper<Path> {
  final int index;
  Radial5Clipper({required this.index});

  @override
  Path getClip(Size size) => getRadial5Path(index, size);

  static Path getRadial5Path(int index, Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w / 2;
    double cy = h / 2;
    double side = math.min(w, h);
    
    // In reference image the circle is about 1/3 of the width.
    double innerR = side * 0.17; 
    double outerR = side * 0.46; // A bit smaller than the edge for a nice look
    double gap = side * 0.04;    // Thicker gap like the reference

    if (index == 0) {
      return Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: innerR));
    }

    double halfGap = gap / 2;
    Rect qRect;
    switch (index) {
      case 1: qRect = Rect.fromLTRB(cx - outerR, cy - outerR, cx - halfGap, cy - halfGap); break; // TL
      case 2: qRect = Rect.fromLTRB(cx + halfGap, cy - outerR, cx + outerR, cy - halfGap); break; // TR
      case 3: qRect = Rect.fromLTRB(cx + halfGap, cy + halfGap, cx + outerR, cy + outerR); break; // BR
      case 4: qRect = Rect.fromLTRB(cx - outerR, cy + halfGap, cx - halfGap, cy + outerR); break; // BL
      default: return Path();
    }

    Path path = Path()..addRect(qRect);
    
    // Intersection with outer large circle
    Path outerCircle = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: outerR));
    path = Path.combine(PathOperation.intersect, path, outerCircle);
    
    // Subtract the inner circle + its gap
    Path innerCircleWithGap = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: innerR + halfGap));
    path = Path.combine(PathOperation.difference, path, innerCircleWithGap);

    return path;
  }

  @override
  bool shouldReclip(Radial5Clipper oldClipper) => index != oldClipper.index;
}

class Radial5Painter extends CustomPainter {
  final Color color;
  final double width;
  Radial5Painter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 5; i++) {
      canvas.drawPath(Radial5Clipper.getRadial5Path(i, size), paint);
    }
  }

  @override
  bool shouldRepaint(Radial5Painter old) =>
      old.color != color || old.width != width;
}

class FanBurst5Clipper extends CustomClipper<Path> {
  final int index;
  FanBurst5Clipper({required this.index});

  @override
  Path getClip(Size size) => getFanBurst5Path(index, size);

  static Path getFanBurst5Path(int index, Size size) {
    double w = size.width;
    double h = size.height;
    // Move vertex even further left to make the triangle cut smaller
    Offset v = Offset(w * 0.12, h * 0.46);

    List<List<Offset>> polygons = [
      [v, Offset(0, h * 0.2), Offset.zero, Offset(w * 0.85, 0)],   // TL/Top
      [v, Offset(w * 0.85, 0), Offset(w, 0), Offset(w, h * 0.65)], // TR/Right
      [v, Offset(w, h * 0.65), Offset(w, h), Offset(w * 0.42, h)], // BR/Bottom
      [v, Offset(w * 0.42, h), Offset(0, h), Offset(0, h * 0.72)], // BL
      [v, Offset(0, h * 0.72), Offset(0, h * 0.2)],               // L (Middle Left)
    ];

    if (index >= polygons.length) return Path();

    List<Offset> pts = polygons[index];
    
    // Calculate centroid to assist in uniform insetting
    double avgX = 0, avgY = 0;
    for (var p in pts) { avgX += p.dx; avgY += p.dy; }
    Offset centroid = Offset(avgX / pts.length, avgY / pts.length);

    double inset = w * 0.012; // Gap size
    Path path = Path();
    
    // Inset each point towards the centroid for a more uniform gap
    List<Offset> insetPts = pts.map((p) {
       Offset dir = p - centroid;
       double d = dir.distance;
       if (d < 1) return p;
       return p - dir * (inset / d);
    }).toList();

    path.moveTo(insetPts[0].dx, insetPts[0].dy);
    for (int i = 1; i < insetPts.length; i++) {
      path.lineTo(insetPts[i].dx, insetPts[i].dy);
    }
    path.close();

    return path;
  }

  @override
  bool shouldReclip(FanBurst5Clipper oldClipper) => index != oldClipper.index;
}

class FanBurst5Painter extends CustomPainter {
  final Color color;
  final double width;
  FanBurst5Painter({required this.color, required this.width});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 5; i++) {
      canvas.drawPath(FanBurst5Clipper.getFanBurst5Path(i, size), paint);
    }
  }
  @override
  bool shouldRepaint(FanBurst5Painter oldDelegate) => true;
}

class ComicBurst5Clipper extends CustomClipper<Path> {
  final int index;
  ComicBurst5Clipper({required this.index});

  @override
  Path getClip(Size size) => getComicBurst5Path(index, size);

  static Path getComicBurst5Path(int index, Size size) {
    double w = size.width, h = size.height;
    double cx = w / 2, cy = h / 2;
    double side = math.min(w, h);
    
    // Deterministic irregular burst
    Path getBurst(double scale) {
      Path p = Path();
      int points = 14; 
      double oR = side * 0.42 * scale;
      double iR = side * 0.22 * scale;
      // Irregular offsets for a hand-drawn "Boom" look
      List<double> offsets = [1.3, 0.6, 1.4, 0.7, 1.2, 1.5, 0.5, 1.3, 0.9, 1.6, 0.6, 1.2, 1.4, 0.8];
      
      for (int i = 0; i < points; i++) {
        double angle = (2 * math.pi / points) * i;
        double r = (i % 2 == 0 ? oR : iR) * offsets[i % offsets.length];
        double x = cx + r * math.cos(angle);
        double y = cy + r * math.sin(angle);
        if (i == 0) p.moveTo(x, y);
        else p.lineTo(x, y);
      }
      p.close();
      return p;
    }

    Path burst = getBurst(1.0);
    if (index == 0) return burst;

    // Background quadrants (2x2 grid)
    double gap = side * 0.04; // Thick red lines like reference
    double halfGap = gap / 2;
    Rect qRect;
    switch (index) {
        case 1: qRect = Rect.fromLTRB(0, 0, cx - halfGap, cy - halfGap); break;
        case 2: qRect = Rect.fromLTRB(cx + halfGap, 0, w, cy - halfGap); break;
        case 3: qRect = Rect.fromLTRB(cx + halfGap, cy + halfGap, w, h); break;
        case 4: qRect = Rect.fromLTRB(0, cy + halfGap, cx - halfGap, h); break;
        default: return Path();
    }
    
    Path quad = Path()..addRect(qRect);
    // Subtract the burst for the "punch out" effect
    return Path.combine(PathOperation.difference, quad, getBurst(1.02));
  }

  @override
  bool shouldReclip(ComicBurst5Clipper oldClipper) => index != oldClipper.index;
}

class ComicBurst5Painter extends CustomPainter {
  final Color color;
  final double width;
  ComicBurst5Painter({required this.color, required this.width});
  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 5; i++) {
      canvas.drawPath(ComicBurst5Clipper.getComicBurst5Path(i, size), paint);
    }
  }
  @override
  bool shouldRepaint(ComicBurst5Painter oldDelegate) => true;
}


