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

class DiagonalHeartClipper extends CustomClipper<Path> {
  final int index;
  DiagonalHeartClipper({required this.index});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    
    // Consistent heart shape parameters
    Path heartPath = PerfectHeartClipper().getClip(size);

    if (index == 2) {
      return heartPath;
    }

    Path triangle = Path();
    if (index == 0) {
      // Top-left triangle (split top-right to bottom-left)
      triangle.moveTo(0, 0);
      triangle.lineTo(w, 0);
      triangle.lineTo(0, h);
    } else {
      // Bottom-right triangle
      triangle.moveTo(w, h);
      triangle.lineTo(w, 0);
      triangle.lineTo(0, h);
    }
    triangle.close();

    return Path.combine(PathOperation.difference, triangle, heartPath);
  }

  @override
  bool shouldReclip(DiagonalHeartClipper old) => index != old.index;
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
  final int index;
  final int totalCount;
  CircleInsetClipper({required this.index, required this.totalCount});

  @override
  Path getClip(Size size) {
    double r = size.width * 0.30; // Slightly smaller to leave more room for segments
    double cx = size.width * 0.5;
    double cy = size.height * 0.5;
    
    Path circle = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    if (index == 0) return circle;

    Path segment = Path();
    if (totalCount == 5) {
      // Split background into 4 quadrants
      if (index == 1) segment.addRect(Rect.fromLTWH(0, 0, cx, cy)); // Top-Left
      else if (index == 2) segment.addRect(Rect.fromLTWH(cx, 0, cx, cy)); // Top-Right
      else if (index == 3) segment.addRect(Rect.fromLTWH(0, cy, cx, cy)); // Bottom-Left
      else if (index == 4) segment.addRect(Rect.fromLTWH(cx, cy, cx, cy)); // Bottom-Right
    } else {
      // Fallback for 2 images
      segment.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    return Path.combine(PathOperation.difference, segment, circle);
  }

  @override
  bool shouldReclip(CircleInsetClipper oldClipper) =>
      index != oldClipper.index || totalCount != oldClipper.totalCount;
}

class CircleInsetPainter extends CustomPainter {
  final Color color;
  final double width;
  final int totalCount;
  CircleInsetPainter({required this.color, required this.width, required this.totalCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double r = size.width * 0.30;
    double cx = size.width * 0.5;
    double cy = size.height * 0.5;

    // Draw central circle
    canvas.drawCircle(Offset(cx, cy), r, paint);

    if (totalCount == 5) {
      // Draw quadrant lines (stopping at the circle)
      // Horizontal
      canvas.drawLine(Offset(0, cy), Offset(cx - r, cy), paint); // Left
      canvas.drawLine(Offset(cx + r, cy), Offset(size.width, cy), paint); // Right
      // Vertical
      canvas.drawLine(Offset(cx, 0), Offset(cx, cy - r), paint); // Top
      canvas.drawLine(Offset(cx, cy + r), Offset(cx, size.height), paint); // Bottom
    }
  }

  @override
  bool shouldRepaint(CircleInsetPainter old) =>
      old.color != color || old.width != width || old.totalCount != totalCount;
}

class DiamondInsetClipper extends CustomClipper<Path> {
  final int index;
  final int totalCount;
  DiamondInsetClipper({required this.index, required this.totalCount});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w * 0.5;
    double cy = h * 0.5;

    Path diamond = Path()
      ..moveTo(cx, h * 0.2)
      ..lineTo(w * 0.8, cy)
      ..lineTo(cx, h * 0.8)
      ..lineTo(w * 0.2, cy)
      ..close();

    if (index == 0) return diamond;

    Path segment = Path();
    if (totalCount == 5) {
      // Split background into 4 non-overlapping segments that match the border lines
      if (index == 1) { // Top Triangle
        segment.moveTo(0, 0);
        segment.lineTo(w, 0);
        segment.lineTo(cx, h * 0.2);
        segment.close();
      } else if (index == 2) { // Right Side Pocket
        segment.moveTo(w, 0);
        segment.lineTo(w, h);
        segment.lineTo(cx, h * 0.8);
        segment.lineTo(w * 0.8, cy);
        segment.lineTo(cx, h * 0.2);
        segment.close();
      } else if (index == 3) { // Bottom Triangle
        segment.moveTo(w, h);
        segment.lineTo(0, h);
        segment.lineTo(cx, h * 0.8);
        segment.close();
      } else if (index == 4) { // Left Side Pocket
        segment.moveTo(0, h);
        segment.lineTo(0, 0);
        segment.lineTo(cx, h * 0.2);
        segment.lineTo(w * 0.2, cy);
        segment.lineTo(cx, h * 0.8);
        segment.close();
      }
    } else {
      segment.addRect(Rect.fromLTWH(0, 0, w, h));
    }

    return Path.combine(PathOperation.difference, segment, diamond);
  }

  @override
  bool shouldReclip(DiamondInsetClipper oldClipper) =>
      index != oldClipper.index || totalCount != oldClipper.totalCount;
}

class DiamondInsetPainter extends CustomPainter {
  final Color color;
  final double width;
  final int totalCount;
  DiamondInsetPainter({required this.color, required this.width, required this.totalCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    double w = size.width;
    double h = size.height;
    double cx = w * 0.5;
    double cy = h * 0.5;

    // Draw central diamond
    final diamond = Path()
      ..moveTo(cx, h * 0.2)
      ..lineTo(w * 0.8, cy)
      ..lineTo(cx, h * 0.8)
      ..lineTo(w * 0.2, cy)
      ..close();
    canvas.drawPath(diamond, paint);

    if (totalCount == 5) {
      // Draw diagonal lines to corners (stopping at diamond vertices)
      canvas.drawLine(Offset(0, 0), Offset(cx, h * 0.2), paint); // TL
      canvas.drawLine(Offset(w, 0), Offset(cx, h * 0.2), paint); // TR
      canvas.drawLine(Offset(w, h), Offset(cx, h * 0.8), paint); // BR
      canvas.drawLine(Offset(0, h), Offset(cx, h * 0.8), paint); // BL
    }
  }

  @override
  bool shouldRepaint(DiamondInsetPainter old) =>
      old.color != color || old.width != width || old.totalCount != totalCount;
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
    } else if (totalCount == 3) {
      // Triangle Trio - Partition into 3 stitched triangles
      if (index == 0) {
        // Top-Right Half
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h);
      } else if (index == 1) {
        // Bottom-Left Sub 1
        path.moveTo(0, 0);
        path.lineTo(0, h);
        path.lineTo(w * 0.5, h * 0.5);
      } else {
        // Bottom-Left Sub 2
        path.moveTo(w * 0.5, h * 0.5);
        path.lineTo(0, h);
        path.lineTo(w, h);
      }
      path.close();
    } else {
      // For 4+ images, unique triangles
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
    trapezoid.lineTo(w * 0.5, h * 0.15);
    trapezoid.lineTo(w * 0.5, h * 0.85);
    trapezoid.lineTo(0, h);
    trapezoid.close();

    if (index == 0) return trapezoid;

    path.addRect(Rect.fromLTWH(0, 0, w, h));
    return Path.combine(PathOperation.difference, path, trapezoid);
  }

  @override
  bool shouldReclip(TrapezoidClipper old) => old.index != index;
}

class HoneycombClipper extends CustomClipper<Path> {
  final int index;
  HoneycombClipper({required this.index});

  static Path getHexagonPath(int index, Size size) {
    double w = size.width, h = size.height;
    double cx = w / 2, cy = h / 2;
    
    double R = math.min(w, h) * 0.23;
    double W = math.sqrt(3) * R;

    List<Offset> centers = [
      Offset(-W/2, 0),       // 0: Left
      Offset(W/2, 0),        // 1: Right
      Offset(0, -1.5 * R),   // 2: Top
      Offset(0, 1.5 * R),    // 3: Bottom
    ];

    if (index < 0 || index > 3) return Path();

    Offset center = centers[index];
    
    Path path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = math.pi / 2 + i * math.pi / 3;
      double dx = math.cos(angle) * R;
      double dy = math.sin(angle) * R;
      
      if (i == 0) path.moveTo(cx + center.dx + dx, cy + center.dy + dy);
      else path.lineTo(cx + center.dx + dx, cy + center.dy + dy);
    }
    path.close();
    
    return path;
  }

  @override
  Path getClip(Size size) => getHexagonPath(index, size);

  @override
  bool shouldReclip(HoneycombClipper old) => old.index != index;
}

class HoneycombPainter extends CustomPainter {
  final Color color;
  final double width;
  HoneycombPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;

    for (int i = 0; i < 4; i++) {
      canvas.drawPath(HoneycombClipper.getHexagonPath(i, size), paint);
    }
  }

  @override
  bool shouldRepaint(HoneycombPainter old) => old.color != color || old.width != width;
}

class Crest5Clipper extends CustomClipper<Path> {
  final int index;
  Crest5Clipper({required this.index});

  static Path getShieldPath(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double sw = w * 0.42; // Sleeker shield width
    final double sh = h * 0.50; // Sleeker shield height
    final double peakOffset = sh * 0.12;

    Path path = Path();
    // Peak Top
    path.moveTo(cx, cy - sh/2);
    path.lineTo(cx + sw/2, cy - sh/2 + peakOffset);
    // Vertical side
    path.lineTo(cx + sw/2, cy + sh/6);
    // Pointed Bottom
    path.quadraticBezierTo(cx + sw/2, cy + sh/3, cx, cy + sh/2);
    path.quadraticBezierTo(cx - sw/2, cy + sh/3, cx - sw/2, cy + sh/6);
    // Vertical side
    path.lineTo(cx - sw/2, cy - sh/2 + peakOffset);
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    // Index 4 is the central crest shield
    if (index == 4) return getShieldPath(size);

    final Path wedge = Path();
    switch (index) {
      case 0: wedge.addRect(Rect.fromLTRB(0, 0, cx, cy)); break; // TL
      case 1: wedge.addRect(Rect.fromLTRB(cx, 0, w, cy)); break; // TR
      case 2: wedge.addRect(Rect.fromLTRB(cx, cy, w, h)); break; // BR
      case 3: wedge.addRect(Rect.fromLTRB(0, cy, cx, h)); break; // BL
    }

    // Clip against central shield
    return Path.combine(PathOperation.difference, wedge, getShieldPath(size));
  }

  @override
  bool shouldReclip(Crest5Clipper old) => old.index != index;
}

class Crest5Painter extends CustomPainter {
  final Color color;
  final double width;
  Crest5Painter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final double w = size.width;
    final double h = size.height;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    // 1. Draw the outer boundary (canvas frame)
    path.addRect(Rect.fromLTWH(0, 0, w, h));

    // 2. Draw the central crest shape
    canvas.drawPath(Crest5Clipper.getShieldPath(size), paint);

    // 3. Draw the quadrant dividers, clipped so they don't cross the shield
    canvas.save();
    canvas.clipPath(Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, w, h)),
      Crest5Clipper.getShieldPath(size),
    ));

    // Vertical divider
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), paint);
    // Horizontal divider
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), paint);

    canvas.restore();
    
    // Draw the collected path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(Crest5Painter old) => old.color != color || old.width != width;
}

// ═══════════════════════════════════════════════════════════════════════════════
// GEO CREST 5 — Diamond Star (center diamond + 4 corner triangles)
// ═══════════════════════════════════════════════════════════════════════════════

class GeoCrest5Clipper extends CustomClipper<Path> {
  final int index;
  GeoCrest5Clipper({required this.index});

  // Diamond vertices — pushed close to edges for maximum coverage
  static Offset _top(Size s)    => Offset(s.width * 0.5,  s.height * 0.13);
  static Offset _right(Size s)  => Offset(s.width * 0.87, s.height * 0.5);
  static Offset _bottom(Size s) => Offset(s.width * 0.5,  s.height * 0.87);
  static Offset _left(Size s)   => Offset(s.width * 0.13, s.height * 0.5);

  static Path getDiamondPath(Size s) {
    return Path()
      ..moveTo(_top(s).dx,    _top(s).dy)
      ..lineTo(_right(s).dx,  _right(s).dy)
      ..lineTo(_bottom(s).dx, _bottom(s).dy)
      ..lineTo(_left(s).dx,   _left(s).dy)
      ..close();
  }

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    switch (index) {
      case 0: // Center diamond
        return getDiamondPath(size);
      case 1: // Top-Left triangle: corner (0,0) between _top and _left
        return Path()
          ..moveTo(0, 0)
          ..lineTo(_top(size).dx,  _top(size).dy)
          ..lineTo(_left(size).dx, _left(size).dy)
          ..close();
      case 2: // Top-Right triangle: corner (w,0) between _top and _right
        return Path()
          ..moveTo(w, 0)
          ..lineTo(_top(size).dx,   _top(size).dy)
          ..lineTo(_right(size).dx, _right(size).dy)
          ..close();
      case 3: // Bottom-Right triangle: corner (w,h) between _right and _bottom
        return Path()
          ..moveTo(w, h)
          ..lineTo(_right(size).dx,  _right(size).dy)
          ..lineTo(_bottom(size).dx, _bottom(size).dy)
          ..close();
      case 4: // Bottom-Left triangle: corner (0,h) between _bottom and _left
        return Path()
          ..moveTo(0, h)
          ..lineTo(_bottom(size).dx, _bottom(size).dy)
          ..lineTo(_left(size).dx,   _left(size).dy)
          ..close();
      default:
        return Path()..addRect(Rect.fromLTWH(0, 0, w, h));
    }
  }

  @override
  bool shouldReclip(GeoCrest5Clipper old) => old.index != index;
}

class GeoCrest5Painter extends CustomPainter {
  final Color color;
  final double width;
  GeoCrest5Painter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final double w = size.width;
    final double h = size.height;

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.butt;

    final top    = GeoCrest5Clipper._top(size);
    final right  = GeoCrest5Clipper._right(size);
    final bottom = GeoCrest5Clipper._bottom(size);
    final left   = GeoCrest5Clipper._left(size);

    // Draw the central diamond border
    canvas.drawPath(GeoCrest5Clipper.getDiamondPath(size), paint);

    // Draw the 4 seam lines from corners to diamond vertices
    canvas.drawLine(const Offset(0, 0), top,    paint); // TL corner → top vertex
    canvas.drawLine(const Offset(0, 0), left,   paint); // TL corner → left vertex
    canvas.drawLine(Offset(w, 0),       top,    paint); // TR corner → top vertex
    canvas.drawLine(Offset(w, 0),       right,  paint); // TR corner → right vertex
    canvas.drawLine(Offset(w, h),       right,  paint); // BR corner → right vertex
    canvas.drawLine(Offset(w, h),       bottom, paint); // BR corner → bottom vertex
    canvas.drawLine(Offset(0, h),       bottom, paint); // BL corner → bottom vertex
    canvas.drawLine(Offset(0, h),       left,   paint); // BL corner → left vertex

    // Outer canvas frame
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
  }

  @override
  bool shouldRepaint(GeoCrest5Painter old) =>
      old.color != color || old.width != width;
}

// ═══════════════════════════════════════════════════════════════════════════════

// PINTERESTY / ORGANIC CLIPPERS
// ═══════════════════════════════════════════════════════════════════════════════


class SlantedClipper extends CustomClipper<Path> {
  final double slant;
  final int index;
  final int totalCount;
  SlantedClipper({required this.slant, required this.index, this.totalCount = 2});

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;
    double offset = slant * w;

    if (totalCount == 5) {
      // 5-image row of slanted bars for a "Mosaic" look
      double unitW = w / 5;
      double x0 = index * unitW;
      double x1 = (index + 1) * unitW;
      
      // We apply slant to the internal dividers
      path.moveTo(x0 + (index == 0 ? 0 : offset), 0);
      path.lineTo(x1 + (index == 4 ? 0 : offset), 0);
      path.lineTo(x1 - (index == 4 ? 0 : offset), h);
      path.lineTo(x0 - (index == 0 ? 0 : offset), h);
      path.close();
      return path;
    }

    // Classic 2v1 split
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
      old.slant != slant || old.index != index || old.totalCount != totalCount;
}

class ParallelogramClipper extends CustomClipper<Path> {
  final double? shift;
  final int index;
  final int totalCount;
  final double inset;
  ParallelogramClipper({this.shift = 0.15, required this.index, this.totalCount = 2, this.inset = 0.0});

  static Path getParallelogramPath(int index, Size size, int totalCount, {double? shiftRatio, double inset = 0.0}) {
    final double w = size.width;
    final double h = size.height;
    final path = Path();
    
    // Slanted dividers cutting the canvas from top to bottom
    double s = w * (shiftRatio ?? 0.15); 
    
    // Calculate the top and bottom x-coordinates of the slanted dividers
    double getXTop(int idx) => (w / totalCount) * idx + s / 2;
    double getXBot(int idx) => (w / totalCount) * idx - s / 2;

    // Apply exact inset. 
    // Horizontal inset along slanted line = inset * sec(slant angle)
    double length = math.sqrt(s * s + h * h);
    double slantInsetX = inset * length / h;
    double vertInsetX = inset;
    
    double topY = inset;
    double botY = h - inset;

    // Left edge
    double xTopLeft = index == 0 ? vertInsetX : getXTop(index) + slantInsetX;
    double xBotLeft = index == 0 ? vertInsetX : getXBot(index) + slantInsetX;
    
    // Right edge
    double xTopRight = index == totalCount - 1 ? w - vertInsetX : getXTop(index + 1) - slantInsetX;
    double xBotRight = index == totalCount - 1 ? w - vertInsetX : getXBot(index + 1) - slantInsetX;

    path.moveTo(xTopLeft, topY);
    path.lineTo(xTopRight, topY);
    path.lineTo(xBotRight, botY);
    path.lineTo(xBotLeft, botY);
    path.close();
    
    return path;
  }

  @override
  Path getClip(Size size) {
    return getParallelogramPath(index, size, totalCount, shiftRatio: shift, inset: inset);
  }

  @override
  bool shouldReclip(ParallelogramClipper old) =>
      old.shift != shift || old.index != index || old.totalCount != totalCount || old.inset != inset;
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
    double archW, archH, archTop, left;

    if (totalCount == 5) {
      // Grand Colonnade - Symmetrical Non-Overlapping Cascade
      // 0.15 (S) + 0.20 (M) + 0.30 (C) + 0.20 (M) + 0.15 (S) = 1.00
      if (index == 0) { // Grand Center
        archW = w * 0.30; archH = h * 0.75; archTop = h * 0.12; left = w * 0.35;
      } else if (index == 1) { // Medium Left
        archW = w * 0.20; archH = h * 0.60; archTop = h * 0.20; left = w * 0.15;
      } else if (index == 2) { // Medium Right
        archW = w * 0.20; archH = h * 0.60; archTop = h * 0.20; left = w * 0.65;
      } else if (index == 3) { // Small Outer Left
        archW = w * 0.15; archH = h * 0.45; archTop = h * 0.28; left = 0.0;
      } else { // Small Outer Right
        archW = w * 0.15; archH = h * 0.45; archTop = h * 0.28; left = w * 0.85;
      }
    } else {
      double unitW = w / (totalCount > 0 ? totalCount : 1);
      left = index * unitW + (unitW * 0.05);
      archW = unitW * 0.9;
      archH = h * 0.7;
      archTop = h * 0.15;
    }

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
  final double inset;
  OrganicBlobClipper(this.seed, {this.index = 0, this.totalCount = 1, this.inset = 0.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;

    // We define a cleaner set of coordinates for 4 balanced blobs
    double effectiveW = w * 0.48;
    double effectiveH = h * 0.48;
    double xOffset = 0, yOffset = 0;
    double rotation = 0;

    if (totalCount == 4) {
      // Balanced "Liquid Bloom" arrangement
      switch (index) {
        case 0: xOffset = w * 0.04; yOffset = h * 0.04; rotation = 0.05; break;
        case 1: xOffset = w * 0.48; yOffset = h * 0.08; rotation = -0.05; break;
        case 2: xOffset = w * 0.08; yOffset = h * 0.48; rotation = -0.08; break;
        case 3: xOffset = w * 0.45; yOffset = h * 0.45; rotation = 0.1; break;
      }
    } else if (totalCount == 3) {
      if (index == 0) {
        effectiveW = w * 0.5; effectiveH = h * 0.5; xOffset = w * 0.05; yOffset = h * 0.05; rotation = 0.1;
      } else if (index == 1) {
        effectiveW = w * 0.55; effectiveH = h * 0.55; xOffset = w * 0.25; yOffset = h * 0.25; rotation = -0.1;
      } else {
        effectiveW = w * 0.5; effectiveH = h * 0.5; xOffset = w * 0.45; yOffset = h * 0.45; rotation = 0.15;
      }
    } else if (totalCount == 5) {
      // Modern 'Liquid Cluster' — central hero + 4 smaller orbiting satellites
      if (index == 0) { // Center Hero
        effectiveW = w * 0.38; effectiveH = h * 0.38;
        xOffset = w * 0.31; yOffset = h * 0.31; rotation = 0.05;
      } else if (index == 1) { // TL Satellite
        effectiveW = w * 0.35; effectiveH = h * 0.35;
        xOffset = w * 0.08; yOffset = h * 0.08; rotation = -0.15;
      } else if (index == 2) { // TR Satellite
        effectiveW = w * 0.35; effectiveH = h * 0.35;
        xOffset = w * 0.57; yOffset = h * 0.08; rotation = 0.12;
      } else if (index == 3) { // BL Satellite
        effectiveW = w * 0.35; effectiveH = h * 0.35;
        xOffset = w * 0.08; yOffset = h * 0.57; rotation = 0.08;
      } else if (index == 4) { // BR Satellite
        effectiveW = w * 0.35; effectiveH = h * 0.35;
        xOffset = w * 0.57; yOffset = h * 0.57; rotation = -0.05;
      }
    } else if (totalCount == 2) {
      // Perfect "Yin & Yang" balance for Organic Pair
      if (index == 0) {
        effectiveW = w * 0.55; effectiveH = h * 0.55;
        xOffset = w * 0.05; yOffset = h * 0.05; rotation = 0.08;
      } else {
        effectiveW = w * 0.55; effectiveH = h * 0.55;
        xOffset = w * 0.4; yOffset = h * 0.4; rotation = -0.1;
      }
    } else if (totalCount > 1) {
      int cols = (totalCount > 2) ? 2 : 1;
      xOffset = (index % cols) * (w / cols) * 0.45;
      yOffset = (index ~/ cols) * (h / ((totalCount + 1) ~/ 2)) * 0.45;
    }

    // High-quality Organic Silhouettes (varied per index)
    final List<List<double>> silhouettes = [
      [0.20, 0.10, 0.85, 0.05, 0.95, 0.35, 1.00, 0.75, 0.75, 0.95, 0.35, 1.00, 0.05, 0.80, 0.05, 0.35],
      [0.15, 0.30, 0.40, 0.00, 0.85, 0.15, 1.00, 0.50, 0.90, 0.95, 0.40, 1.00, 0.00, 0.85, 0.10, 0.55],
      [0.35, 0.05, 0.95, 0.20, 0.80, 0.65, 0.95, 0.95, 0.50, 0.85, 0.15, 0.95, 0.25, 0.50, 0.05, 0.25],
      [0.25, 0.20, 0.75, 0.05, 0.95, 0.40, 0.85, 0.85, 0.55, 1.00, 0.15, 0.90, 0.05, 0.60, 0.20, 0.40],
    ];

    final s = silhouettes[index % silhouettes.length];
    
    // Apply inset to scale and center
    double finalW = effectiveW - inset * 2;
    double finalH = effectiveH - inset * 2;
    double finalX = xOffset + inset;
    double finalY = yOffset + inset;

    path.moveTo(finalX + finalW * s[0], finalY + finalH * s[1]);
    path.quadraticBezierTo(finalX + finalW * s[2], finalY + finalH * s[3], finalX + finalW * s[4], finalY + finalH * s[5]);
    path.quadraticBezierTo(finalX + finalW * s[6], finalY + finalH * s[7], finalX + finalW * s[8], finalY + finalH * s[9]);
    path.quadraticBezierTo(finalX + finalW * s[10], finalY + finalH * s[11], finalX + finalW * s[12], finalY + finalH * s[13]);
    path.quadraticBezierTo(finalX + finalW * s[14], finalY + finalH * s[15], finalX + finalW * s[0], finalY + finalH * s[1]);
    path.close();

    if (rotation != 0) {
      final cx = finalX + finalW / 2;
      final cy = finalY + finalH / 2;
      final matrix = Matrix4.identity()
        ..translate(cx, cy)
        ..rotateZ(rotation)
        ..translate(-cx, -cy);
      return path.transform(matrix.storage);
    }
    
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

  /// Centralized source of truth for Random Hearts positioning and sizing.
  static Map<String, double> getHeartParams(int index, int totalCount, double w, double h) {
    double x = 0.5, y = 0.5, size = 0.5, rotation = 0.0;

    if (totalCount == 2) {
      if (index == 0) { x = 0.35; y = 0.60; size = 0.50; rotation = -0.15; }
      else { x = 0.65; y = 0.30; size = 0.45; rotation = 0.20; }
    } else if (totalCount == 3) {
      if (index == 0) { x = 0.28; y = 0.25; size = 0.42; rotation = -0.20; }
      else if (index == 1) { x = 0.70; y = 0.50; size = 0.45; rotation = 0.15; }
      else { x = 0.35; y = 0.75; size = 0.40; rotation = -0.10; }
    } else if (totalCount == 4) {
      if (index == 0) { x = 0.25; y = 0.25; size = 0.42; rotation = -0.18; }
      else if (index == 1) { x = 0.75; y = 0.28; size = 0.40; rotation = 0.22; }
      else if (index == 2) { x = 0.28; y = 0.72; size = 0.42; rotation = 0.12; }
      else { x = 0.72; y = 0.75; size = 0.38; rotation = -0.15; }
    } else if (totalCount == 5) {
      if (index == 0) { x = 0.50; y = 0.50; size = 0.30; rotation = 0.08; }
      else if (index == 1) { x = 0.18; y = 0.18; size = 0.28; rotation = -0.15; }
      else if (index == 2) { x = 0.82; y = 0.18; size = 0.28; rotation = 0.20; }
      else if (index == 3) { x = 0.18; y = 0.82; size = 0.28; rotation = 0.15; }
      else { x = 0.82; y = 0.82; size = 0.28; rotation = -0.10; }
    } else {
      // Dynamic fallback for >5 images
      x = (0.2 + (index * 0.33)) % 0.7 + 0.15;
      y = (0.2 + (index * 0.41)) % 0.7 + 0.15;
      size = 0.35 + (index % 2 == 0 ? 0.05 : 0.0);
      rotation = (index * 0.6) % 1.2 - 0.6;
    }

    return {
      'x': x * w,
      'y': y * h,
      'size': size * w,
      'rotation': rotation,
    };
  }

  /// Centralized source of truth for Leaf Fusion positioning and radiating design.
  static Map<String, double> getLeafParams(int index, int totalCount, double w, double h) {
    // All petals originate from the exact center for a perfect bloom
    double x = 0.5;
    double y = 0.5;
    double size = 0.50;
    double rotation = 0.0;

    if (totalCount == 2) {
      size = 0.55;
      rotation = (index * math.pi) + math.pi / 2;
    } else if (totalCount == 3) {
      size = 0.52;
      rotation = (index * 2 * math.pi / 3) + math.pi;
    } else if (totalCount == 4) {
      size = 0.50;
      rotation = (index * math.pi / 2) + math.pi / 4;
    } else if (totalCount == 5) {
      size = 0.50;
      rotation = (index * 2 * math.pi / 5) + math.pi;
    } else {
      size = 0.45;
      rotation = index * 2 * math.pi / totalCount;
    }

    return {
      'x': x * w,
      'y': y * h,
      'size': size * w,
      'rotation': rotation,
    };
  }

  /// Centralized source of truth for Heart Balloon bouquet positioning.
  static Map<String, double> getBalloonParams(int index, int totalCount, double w, double h) {
    double x = 0.5, y = 0.5, size = 0.35, rotation = 0.0;

    // A clustered "Bouquet" composition near the top center
    if (totalCount == 2) {
      if (index == 0) { x = 0.32; y = 0.25; size = 0.38; rotation = -0.15; }
      else { x = 0.68; y = 0.35; size = 0.38; rotation = 0.15; }
    } else if (totalCount == 3) {
      if (index == 0) { x = 0.50; y = 0.12; size = 0.36; rotation = 0.00; }
      else if (index == 1) { x = 0.22; y = 0.38; size = 0.34; rotation = -0.18; }
      else { x = 0.78; y = 0.38; size = 0.34; rotation = 0.18; }
    } else if (totalCount == 4) {
      if (index == 0) { x = 0.28; y = 0.15; size = 0.32; rotation = -0.15; }
      else if (index == 1) { x = 0.72; y = 0.15; size = 0.32; rotation = 0.15; }
      else if (index == 2) { x = 0.28; y = 0.55; size = 0.32; rotation = -0.05; }
      else { x = 0.72; y = 0.55; size = 0.32; rotation = 0.05; }
    } else if (totalCount == 5) {
      // Clean non-overlapping geometrical burst structure
      if (index == 0) { x = 0.50; y = 0.08; size = 0.30; rotation = 0.00; }
      else if (index == 1) { x = 0.18; y = 0.28; size = 0.28; rotation = -0.22; }
      else if (index == 2) { x = 0.82; y = 0.28; size = 0.28; rotation = 0.22; }
      else if (index == 3) { x = 0.32; y = 0.58; size = 0.28; rotation = -0.10; }
      else { x = 0.68; y = 0.58; size = 0.28; rotation = 0.10; }
    } else {
      // Fallback
      x = (0.2 + (index * 0.15)) % 0.6 + 0.2;
      y = (0.15 + (index * 0.15)) % 0.5 + 0.15;
      size = 0.30;
      rotation = (index * 0.15) - 0.3;
    }

    return {
      'x': x * w,
      'y': y * h,
      'size': size * w,
      'rotation': rotation,
    };
  }

  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width;
    double h = size.height;

    if (mode == 'hearts_flower') {
      if (totalCount == 5) {
        // Geometric Heart Flower: 5 petals overlapping beautifully in the center
        final double s = w * 0.40; // Larger petals to create a full flower
        final double R = s * 0.88; // Reduced distance so the tips overlap at the center
        final double cx = w * 0.5;
        final double cy = h * 0.5;
        final double theta = -math.pi / 2 + (2 * math.pi / 5) * index;
        final double px = cx + R * math.cos(theta);
        final double py = cy + R * math.sin(theta);
        // Rotate heart so bottom tip points precisely to center
        return _getHeartPath(px, py, s, rotation: theta + math.pi / 2);
      } else {
        // Fallback for 2-image structure
        final double s = w * 0.45;
        final double cx = w * 0.5;
        final double cy = h * 0.5;
        if (index == 0) {
          return _getHeartPath(cx - s * 0.55, cy - s * 0.45, s);
        } else {
          return _getHeartPath(cx + s * 0.55, cy - s * 0.45, s);
        }
      }
    } else if (mode == 'hearts_balloon') {
      final params = getBalloonParams(index, totalCount, w, h);
      return _getHeartPath(
        params['x']!,
        params['y']!,
        params['size']!,
        rotation: params['rotation']!,
      );
    } else if (mode == 'random_hearts') {
      final params = getHeartParams(index, totalCount, w, h);
      return _getHeartPath(
        params['x']!,
        params['y']!,
        params['size']!,
        rotation: params['rotation']!,
      );
    } else if (mode == 'leaf_fusion') {
      final params = getLeafParams(index, totalCount, w, h);
      return _getLeafPath(
        params['x']!,
        params['y']!,
        params['size']!,
        rotation: params['rotation']!,
      );
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

    // Beautiful rounded teardrop/petal shape for the "leaf flower"
    path.moveTo(x, y);
    // Left plump curve
    path.cubicTo(x - s * 0.7, y + s * 0.25, x - s * 0.5, y + s * 0.75, x, y + s * 0.90);
    // Right plump curve
    path.cubicTo(x + s * 0.5, y + s * 0.75, x + s * 0.7, y + s * 0.25, x, y);
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

  static Path getRowPath(int index, int totalCount, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double rowH = h / (totalCount > 0 ? totalCount : 1);
    final double slantW = w * 0.10;

    double top = index * rowH;
    double bottom = (index + 1) * rowH;

    Path path = Path();

    // Use alternating slant directions for a more premium zigzag effect
    if (index % 2 == 0) {
      // Slant: / \ (Top wider or shifted)
      double topLeft = (index == 0) ? 0 : slantW;
      double topRight = w;
      double bottomLeft = 0;
      double bottomRight = w - slantW;

      path.moveTo(topLeft, top);
      path.lineTo(topRight, top);
      path.lineTo(bottomRight, bottom);
      path.lineTo(bottomLeft, bottom);
    } else {
      // Slant: \ /
      double topLeft = 0;
      double topRight = w - slantW;
      double bottomLeft = slantW;
      double bottomRight = w;

      path.moveTo(topLeft, top);
      path.lineTo(topRight, top);
      path.lineTo(bottomRight, bottom);
      path.lineTo(bottomLeft, bottom);
    }

    path.close();
    return path;
  }

  @override
  Path getClip(Size size) => getRowPath(index, totalCount, size);

  @override
  bool shouldReclip(SlantedRowClipper old) =>
      old.index != index || old.totalCount != totalCount;
}

class SlantedRowPainter extends CustomPainter {
  final Color color;
  final double width;
  final int totalCount;
  SlantedRowPainter({
    required this.color,
    required this.width,
    required this.totalCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final int n = totalCount;
    for (int i = 0; i < n; i++) {
      // To "remove from canvas" top/bottom but "do border side of shapes":
      // We draw the full path but we can also just draw specific segments.
      // Actually, drawing the full path for each shape works well, 
      // but if we want to BE EXPLICIT about removing the very top and very bottom:
      
      final double rowH = size.height / (n > 0 ? n : 1);
      final double w = size.width;
      final double slantW = w * 0.10;
      double topY = i * rowH;
      double botY = (i + 1) * rowH;

      if (i % 2 == 0) {
        // Row 0, 2...
        double tL = (i == 0) ? 0 : slantW;
        double tR = w;
        double bL = 0;
        double bR = w - slantW;

        // Left Side
        canvas.drawLine(Offset(bL, botY), Offset(tL, topY), paint);
        // Right Side
        canvas.drawLine(Offset(tR, topY), Offset(bR, botY), paint);
        // Bottom divider (all rows)
        if (i < n - 1) {
          canvas.drawLine(Offset(bR, botY), Offset(bL, botY), paint);
        }
        // Top divider (only if NOT the very top of canvas)
        if (i > 0) {
          canvas.drawLine(Offset(tL, topY), Offset(tR, topY), paint);
        }
      } else {
        // Row 1, 3...
        double tL = 0;
        double tR = w - slantW;
        double bL = slantW;
        double bR = w;

        // Left Side
        canvas.drawLine(Offset(bL, botY), Offset(tL, topY), paint);
        // Right Side
        canvas.drawLine(Offset(tR, topY), Offset(bR, botY), paint);
        // Bottom divider
        if (i < n - 1) {
          canvas.drawLine(Offset(bR, botY), Offset(bL, botY), paint);
        }
        // Top divider
        if (i > 0) {
          canvas.drawLine(Offset(tL, topY), Offset(tR, topY), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(SlantedRowPainter old) =>
      old.color != color || old.width != width || old.totalCount != totalCount;
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

    // Standardize Height for all shapes
    final double charH = h * 0.65;
    final double charW = w * 0.23; 

    // Centers for even spacing
    final double x1 = w * 0.18;
    final double x2 = cx;
    final double x3 = w * 0.82;

    if (index == 0) {
      // Shape "I" (Capsule)
      return Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(x1, cy), width: charW, height: charH),
          Radius.circular(charW * 0.5),
        ));
    } else if (index == 1) {
      // Shape "Heart" (❤️)
      final path = Path();
      // Scale heart to match charH. 
      // Visual height is approx 0.75 * size
      double hs = charH / 0.75;
      double hx = x2;
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
      // Shape "U" (Solid Cup, no cutout)
      final path = Path();
      double ux = x3;
      double uy = cy;
      double ur = charW * 0.5;

      // Solid U shape from standardized charW/charH
      path.moveTo(ux - charW / 2, uy - charH / 2);
      path.lineTo(ux - charW / 2, uy + charH / 2 - ur);
      path.arcToPoint(Offset(ux + charW / 2, uy + charH / 2 - ur),
          radius: Radius.circular(ur), clockwise: false);
      path.lineTo(ux + charW / 2, uy - charH / 2);
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
  final int totalCount;
  FilmStripClipper({required this.index, this.totalCount = 2});

  static Path getFilmStripPath(int index, Size size, int totalCount) {
    final double w = size.width;
    final double h = size.height;
    final path = Path();

    // High-fidelity Vertical Cinematic Strip (Dynamic Images)
    double frameW = w * 0.70;
    double startX = w * 0.15;
    
    // We reserve space at top (8%) and bottom (8%)
    double topPadding = h * 0.08;
    double bottomPadding = h * 0.08;
    double availableHeight = h - topPadding - bottomPadding;
    
    // Consistent spacing between frames
    double gapRatio = 0.08; // Total gap space as a ratio of available height
    double totalGap = availableHeight * gapRatio;
    double frameH = (availableHeight - totalGap) / totalCount;
    double spacing = totalCount > 1 ? totalGap / (totalCount - 1) : 0;
    
    double startY = topPadding + (index * (frameH + spacing));

    path.addRect(Rect.fromLTWH(startX, startY, frameW, frameH));

    return path;
  }

  @override
  Path getClip(Size size) {
    return getFilmStripPath(index, size, totalCount);
  }

  @override
  bool shouldReclip(FilmStripClipper old) => index != old.index || totalCount != old.totalCount;
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
    final double w = size.width;
    final double h = size.height;

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

    if (index == 1) return closedStrip;

    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(PathOperation.difference, path, closedStrip);
  }

  @override
  bool shouldReclip(TornDiagonalClipper old) => old.index != index;
}

// ─────────────────────────────────────────────────────────────────────────────
// ZIGZAG BAND CLIPPER — 3 horizontal bands with wide chevron/zigzag seams
// Matches the reference collage: top image / middle / bottom split by spiky
// full-width zigzag dividers.
// ─────────────────────────────────────────────────────────────────────────────
class ZigzagBandClipper extends CustomClipper<Path> {
  final int index;

  /// Number of zigzag teeth across the full width.
  static const int _teeth = 8;

  ZigzagBandClipper({required this.index});

  /// Build a zigzag line y-profile across [0, w] centred at [midY].
  /// Each tooth spans [toothW] wide and peaks/troughs [amp] above/below midY.
  /// [upFirst] decides whether the first tooth points up or down.
  static List<Offset> _zigzagLine(
      double w, double midY, double amp, bool upFirst) {
    final pts = <Offset>[];
    final toothW = w / _teeth;
    for (int i = 0; i <= _teeth; i++) {
      final x = i * toothW;
      // Alternate peak and trough
      final y = midY + ((i % 2 == 0) == upFirst ? -amp : amp);
      pts.add(Offset(x, y));
    }
    return pts;
  }

  static Path getZigzagBandPath(int index, Size size) {
    final w = size.width;
    final h = size.height;

    // Two seam positions (as fraction of height)
    const double seam1Frac = 0.35;
    const double seam2Frac = 0.67;

    final double seam1 = h * seam1Frac;
    final double seam2 = h * seam2Frac;
    final double amp = h * 0.045; // tooth amplitude

    // Top seam line: peaks point downward (into the top band) for a classic
    // "torn" look where the gap opens between band 0 and band 1.
    final List<Offset> topSeam =
        _zigzagLine(w, seam1, amp, false); // first point goes DOWN

    // Bottom seam line: peaks point upward (into the middle band).
    final List<Offset> bottomSeam =
        _zigzagLine(w, seam2, amp, true); // first point goes UP

    final path = Path();

    if (index == 0) {
      // TOP BAND: from top edge down to topSeam
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      // Walk topSeam right-to-left so the closing is natural
      for (int i = topSeam.length - 1; i >= 0; i--) {
        path.lineTo(topSeam[i].dx, topSeam[i].dy);
      }
      path.close();
    } else if (index == 1) {
      // MIDDLE BAND: from topSeam down to bottomSeam
      // Start at the left end of upper seam
      path.moveTo(topSeam.first.dx, topSeam.first.dy);
      for (final p in topSeam) {
        path.lineTo(p.dx, p.dy);
      }
      // Go to bottom seam right side then walk back left
      for (int i = bottomSeam.length - 1; i >= 0; i--) {
        path.lineTo(bottomSeam[i].dx, bottomSeam[i].dy);
      }
      path.close();
    } else {
      // BOTTOM BAND: from bottomSeam to bottom edge
      path.moveTo(bottomSeam.first.dx, bottomSeam.first.dy);
      for (final p in bottomSeam) {
        path.lineTo(p.dx, p.dy);
      }
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.close();
    }

    return path;
  }

  @override
  Path getClip(Size size) => getZigzagBandPath(index, size);

  @override
  bool shouldReclip(ZigzagBandClipper old) => old.index != index;
}

// ─────────────────────────────────────────────────────────────────────────────
// SPIKY ZIGZAG CLIPPER — More aggressive zigzag for 3 horizontal bands
// ─────────────────────────────────────────────────────────────────────────────
class SpikyZigzagClipper extends CustomClipper<Path> {
  final int index;
  static const int _teeth = 12;

  SpikyZigzagClipper({required this.index});

  static List<Offset> _spikyZigzagLine(double w, double midY, double amp, bool upFirst) {
    final pts = <Offset>[];
    final toothW = w / _teeth;
    for (int i = 0; i <= _teeth; i++) {
      final x = i * toothW;
      final y = midY + ((i % 2 == 0) == upFirst ? -amp : amp);
      pts.add(Offset(x, y));
    }
    return pts;
  }

  static Path getSpikyZigzagBandPath(int index, Size size) {
    final w = size.width;
    final h = size.height;
    const double seam1Frac = 0.33;
    const double seam2Frac = 0.66;
    final double seam1 = h * seam1Frac;
    final double seam2 = h * seam2Frac;
    final double amp = h * 0.06;

    final List<Offset> topSeam = _spikyZigzagLine(w, seam1, amp, false);
    final List<Offset> bottomSeam = _spikyZigzagLine(w, seam2, amp, true);

    final path = Path();
    if (index == 0) {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      for (int i = topSeam.length - 1; i >= 0; i--) path.lineTo(topSeam[i].dx, topSeam[i].dy);
      path.close();
    } else if (index == 1) {
      path.moveTo(topSeam.first.dx, topSeam.first.dy);
      for (final p in topSeam) path.lineTo(p.dx, p.dy);
      for (int i = bottomSeam.length - 1; i >= 0; i--) path.lineTo(bottomSeam[i].dx, bottomSeam[i].dy);
      path.close();
    } else {
      path.moveTo(bottomSeam.first.dx, bottomSeam.first.dy);
      for (final p in bottomSeam) path.lineTo(p.dx, p.dy);
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.close();
    }
    return path;
  }

  @override
  Path getClip(Size size) => getSpikyZigzagBandPath(index, size);

  @override
  bool shouldReclip(SpikyZigzagClipper old) => old.index != index;
}

// ─────────────────────────────────────────────────────────────────────────────
// ARTISTIC SHAPE GRID CLIPPER — 4 unique shapes in a 2x2 grid
// ─────────────────────────────────────────────────────────────────────────────
class ArtisticShapeGridClipper extends CustomClipper<Path> {
  final int index;
  ArtisticShapeGridClipper({required this.index});

  static Path getShapePath(int index, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w * (index % 2 == 0 ? 0.25 : 0.75);
    final double cy = h * (index < 2 ? 0.25 : 0.75);
    final double r = math.min(w, h) * 0.30;

    switch (index) {
      case 0: // Top-Left: 4-pointed shuriken/butterfly
        return _getGeneralizedPetalPath(cx, cy, r, segments: 4, pointed: true, innerRadiusFrac: 0.35);
      case 1: // Top-Right: 8-pointed star flower
        return _getGeneralizedPetalPath(cx, cy, r, segments: 8, pointed: true, innerRadiusFrac: 0.5);
      case 2: // Bottom-Left: 6-rounded-petal flower
        return _getGeneralizedPetalPath(cx, cy, r, segments: 6, pointed: false, innerRadiusFrac: 0.4);
      case 3: // Bottom-Right: 4-rounded-petal clover
        return _getGeneralizedPetalPath(cx, cy, r, segments: 4, pointed: false, innerRadiusFrac: 0.4);
      default:
        return Path()..addRect(Rect.fromLTWH(0, 0, w, h));
    }
  }

  static Path _getGeneralizedPetalPath(double cx, double cy, double r, 
      {required int segments, required bool pointed, required double innerRadiusFrac}) {
    final path = Path();
    final double innerR = r * innerRadiusFrac;
    final double angleStep = (2 * math.pi) / segments;

    for (int i = 0; i < segments; i++) {
      double angle = i * angleStep - math.pi / 2;
      double nextAngle = (i + 1) * angleStep - math.pi / 2;
      double midAngle = (angle + nextAngle) / 2;

      double xTip = cx + math.cos(midAngle) * r;
      double yTip = cy + math.sin(midAngle) * r;
      
      double x1 = cx + math.cos(angle) * innerR;
      double y1 = cy + math.sin(angle) * innerR;
      
      double x2 = cx + math.cos(nextAngle) * innerR;
      double y2 = cy + math.sin(nextAngle) * innerR;

      if (i == 0) path.moveTo(x1, y1);

      if (pointed) {
        // Pointed tips - sharper inward curvature
        double ctrlDist = r * 0.6;
        double cx1 = cx + math.cos(angle + angleStep * 0.25) * ctrlDist;
        double cy1 = cy + math.sin(angle + angleStep * 0.25) * ctrlDist;
        double cx2 = cx + math.cos(midAngle - angleStep * 0.25) * ctrlDist;
        double cy2 = cy + math.sin(midAngle - angleStep * 0.25) * ctrlDist;
        
        path.cubicTo(cx1, cy1, cx2, cy2, xTip, yTip);
        
        double cx3 = cx + math.cos(midAngle + angleStep * 0.25) * ctrlDist;
        double cy3 = cy + math.sin(midAngle + angleStep * 0.25) * ctrlDist;
        double cx4 = cx + math.cos(nextAngle - angleStep * 0.25) * ctrlDist;
        double cy4 = cy + math.sin(nextAngle - angleStep * 0.25) * ctrlDist;
        
        path.cubicTo(cx3, cy3, cx4, cy4, x2, y2);
      } else {
        // Rounded tips - smoother petals
        double ctrlDist = r * 1.25; // Bulky petals
        double cx1 = cx + math.cos(angle + angleStep * 0.3) * ctrlDist;
        double cy1 = cy + math.sin(angle + angleStep * 0.3) * ctrlDist;
        double cx2 = cx + math.cos(nextAngle - angleStep * 0.3) * ctrlDist;
        double cy2 = cy + math.sin(nextAngle - angleStep * 0.3) * ctrlDist;
        
        path.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
      }
    }
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) => getShapePath(index, size);

  @override
  bool shouldReclip(ArtisticShapeGridClipper old) => old.index != index;
}

// ─────────────────────────────────────────────────────────────────────────────
// DAD HEART CLIPPER — 5 images: Rect, Heart, D, A, D
// ─────────────────────────────────────────────────────────────────────────────
class DadHeartClipper extends CustomClipper<Path> {
  final int index;
  DadHeartClipper({required this.index});

  static Path getDadHeartPath(int index, Size size) {
    final double w = size.width;
    final double h = size.height;

    final double charW = w * 0.24;
    final double charH = h * 0.24;
    final double charY = h * 0.72;

    switch (index) {
      case 0: // Top Left: Vertical Rectangle (Matching Letter Width)
        return Path()..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(w * 0.22, h * 0.25), width: charW, height: h * 0.4),
          Radius.circular(w * 0.02),
        ));
      case 1: // Top Right: Heart
        return _getHeartPath(w * 0.7, h * 0.25, w * 0.45);
      case 2: // Bottom Left: D
        return _getLetterDPath(w * 0.18, charY, charW, charH);
      case 3: // Bottom Mid: A
        return _getLetterAPath(w * 0.5, charY, charW, charH);
      case 4: // Bottom Right: D
        return _getLetterDPath(w * 0.82, charY, charW, charH);
      default:
        return Path()..addRect(Rect.fromLTWH(0, 0, w, h));
    }
  }

  static Path _getHeartPath(double cx, double cy, double s) {
    final path = Path();
    double hx = cx;
    double hy = cy - s * 0.45;
    path.moveTo(hx, hy + s * 0.2);
    path.cubicTo(hx, hy - s * 0.15, hx + s * 0.5, hy - s * 0.15, hx + s * 0.5, hy + s * 0.3);
    path.cubicTo(hx + s * 0.5, hy + s * 0.55, hx, hy + s * 0.75, hx, hy + s * 0.95);
    path.cubicTo(hx, hy + s * 0.75, hx - s * 0.5, hy + s * 0.55, hx - s * 0.5, hy + s * 0.3);
    path.cubicTo(hx - s * 0.5, hy - s * 0.15, hx, hy - s * 0.15, hx, hy + s * 0.2);
    path.close();
    return path;
  }

  static Path _getLetterDPath(double cx, double cy, double w, double h) {
    final double x = cx - w / 2;
    final double y = cy - h / 2;
    final double r = h * 0.5;

    final outer = Path();
    outer.moveTo(x, y);
    outer.lineTo(x, y + h);
    outer.lineTo(x + w - r, y + h);
    outer.arcToPoint(Offset(x + w - r, y), radius: Radius.circular(r), clockwise: false);
    outer.lineTo(x, y);
    outer.close();

    return outer;
  }

  static Path _getLetterAPath(double cx, double cy, double w, double h) {
    final double x = cx - w / 2;
    final double y = cy - h / 2;

    final outer = Path();
    // Solid Block Trapezoid - remove the bottom cutout to maximize space
    outer.moveTo(cx - w * 0.12, y); // Top Center
    outer.lineTo(cx + w * 0.12, y); // Top Right
    outer.lineTo(x + w, y + h); // Bottom Right
    outer.lineTo(x, y + h); // Bottom Left
    outer.close();
    
    // Crossbar: solid slab
    final bar = Path()..addRect(Rect.fromLTWH(x + w * 0.1, y + h * 0.5, w * 0.8, h * 0.2));
    final fullA = Path.combine(PathOperation.union, outer, bar);

    return fullA;
  }

  @override
  Path getClip(Size size) => getDadHeartPath(index, size);

  @override
  bool shouldReclip(DadHeartClipper old) => old.index != index;
}

// ─────────────────────────────────────────────────────────────────────────────
// YEAR GRID CLIPPER — 4 images representing the current year (e.g., 2 0 2 6)
// Arranged in a 2x2 grid. Bubbly/bold font style.
// ─────────────────────────────────────────────────────────────────────────────
class YearGridClipper extends CustomClipper<Path> {
  final String year;
  final int index;
  YearGridClipper({required this.year, required this.index});

  @override
  Path getClip(Size size) {
    if (year.length < 4 || index >= 4) return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final double w = size.width;
    final double h = size.height;
    
    // Position in 2x2 grid
    final double cx = w * (index % 2 == 0 ? 0.25 : 0.75);
    final double cy = h * (index < 2 ? 0.25 : 0.75);
    final double charW = w * 0.44;
    final double charH = h * 0.44;
    
    final Rect charRect = Rect.fromCenter(center: Offset(cx, cy), width: charW, height: charH);
    final String digit = year[index];
    
    return _getDigitPath(digit, charRect);
  }

  static Path _getDigitPath(String digit, Rect rect) {
    switch (digit) {
      case '0': return _getDigit0Path(rect);
      case '1': return _getDigit1Path(rect);
      case '2': return _getDigit2Path(rect);
      case '3': return _getDigit3Path(rect);
      case '4': return _getDigit4Path(rect);
      case '5': return _getDigit5Path(rect);
      case '6': return _getDigit6Path(rect);
      case '7': return _getDigit7Path(rect);
      case '8': return _getDigit8Path(rect);
      case '9': return _getDigit9Path(rect);
      default: return Path()..addRect(rect);
    }
  }

  static Path _getDigit0Path(Rect r) {
    // Large Oval body
    Path path = Path()..addOval(r);
    
    // Two vertical "eyes" capsules
    double eyeW = r.width * 0.16;
    double eyeH = r.height * 0.3;
    double eyeGap = r.width * 0.1;
    
    Path eye1 = Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(r.center.dx - eyeGap, r.center.dy - r.height * 0.05), width: eyeW, height: eyeH),
      Radius.circular(eyeW * 0.5),
    ));
    Path eye2 = Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(r.center.dx + eyeGap, r.center.dy - r.height * 0.05), width: eyeW, height: eyeH),
      Radius.circular(eyeW * 0.5),
    ));
    
    Path holes = Path.combine(PathOperation.union, eye1, eye2);
    return Path.combine(PathOperation.difference, path, holes);
  }

  static Path _getDigit1Path(Rect r) {
    final double bw = r.width * 0.38;
    // Tapered vertical bar with rounded top
    final path = Path();
    path.moveTo(r.center.dx - bw * 0.4, r.bottom);
    path.lineTo(r.center.dx + bw * 0.4, r.bottom);
    path.lineTo(r.center.dx + bw * 0.5, r.top + bw);
    path.arcToPoint(Offset(r.center.dx - bw * 0.5, r.top + bw), radius: Radius.circular(bw * 0.5));
    path.close();
    return path;
  }

  static Path _getDigit2Path(Rect r) {
    final double w = r.width;
    final double h = r.height;
    final double bw = w * 0.35;
    
    // 1. The bubbly head hook
    final head = Path();
    head.moveTo(r.left, r.top + h * 0.4);
    head.cubicTo(r.left, r.top - h * 0.1, r.right, r.top - h * 0.1, r.right, r.top + h * 0.3);
    head.lineTo(r.right, r.top + h * 0.45);
    head.lineTo(r.right - bw, r.top + h * 0.45);
    head.lineTo(r.right - bw, r.top + h * 0.3);
    head.cubicTo(r.right - bw, r.top + bw * 0.2, r.left + bw, r.top + bw * 0.2, r.left + bw, r.top + h * 0.4);
    head.close();
    
    // 2. The curved neck (connecting right of head to left of base)
    final neck = Path();
    neck.moveTo(r.right, r.top + h * 0.4);
    neck.quadraticBezierTo(r.right, r.bottom - bw, r.left + bw * 1.2, r.bottom - bw);
    neck.lineTo(r.left, r.bottom - bw);
    neck.quadraticBezierTo(r.right - bw, r.bottom - bw, r.right - bw, r.top + h * 0.4);
    neck.close();
    
    // 3. The flat horizontal base
    final base = Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(r.left, r.bottom - bw, w, bw),
      Radius.circular(bw * 0.3),
    ));
    
    Path two = Path.combine(PathOperation.union, head, neck);
    two = Path.combine(PathOperation.union, two, base);
    
    // 4. The internal "eye" comma (positioned in the head)
    double cw = w * 0.12;
    double ch = h * 0.2;
    Path comma = Path()..addOval(Rect.fromLTWH(r.center.dx - cw * 0.5, r.top + h * 0.2, cw, ch));
    
    return Path.combine(PathOperation.difference, two, comma);
  }

  static Path _getDigit3Path(Rect r) {
    final double w = r.width;
    final double h = r.height;
    
    // Two very bubbly, almost circular loops
    Path top = Path()..addOval(Rect.fromLTWH(r.left + w * 0.05, r.top, w * 0.9, h * 0.55));
    Path bottom = Path()..addOval(Rect.fromLTWH(r.left, r.top + h * 0.4, w, h * 0.6));
    Path union = Path.combine(PathOperation.union, top, bottom);
    
    // Characterful holes (not centered)
    Path hole1 = Path()..addOval(Rect.fromCenter(center: Offset(r.center.dx + w * 0.05, r.top + h * 0.28), width: w * 0.3, height: h * 0.18));
    Path hole2 = Path()..addOval(Rect.fromCenter(center: Offset(r.center.dx + w * 0.05, r.bottom - h * 0.3), width: w * 0.35, height: h * 0.22));
    
    Path combined = Path.combine(PathOperation.difference, union, hole1);
    combined = Path.combine(PathOperation.difference, combined, hole2);
    
    // Cut out the left side with a curved notch
    Path cut = Path();
    cut.moveTo(r.left - 10, r.top);
    cut.quadraticBezierTo(r.left + w * 0.4, r.center.dy, r.left - 10, r.bottom);
    cut.lineTo(r.left - 10, r.top);
    cut.close();
    
    return Path.combine(PathOperation.difference, combined, cut);
  }

  static Path _getDigit4Path(Rect r) {
    final double w = r.width;
    final double h = r.height;
    final double bw = w * 0.35;
    
    // Vertical Bar (Thick and Tapered)
    Path vBar = Path();
    vBar.moveTo(r.right - bw * 1.2, r.top);
    vBar.lineTo(r.right - bw * 0.2, r.top);
    vBar.lineTo(r.right, r.bottom);
    vBar.lineTo(r.right - bw, r.bottom);
    vBar.close();
    
    // Horizontal Bar (Thick)
    Path hBar = Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(r.left, r.top + h * 0.45, w, bw),
      Radius.circular(bw * 0.2),
    ));
    
    // Slanted part (Curved)
    Path slant = Path();
    slant.moveTo(r.left, r.top + h * 0.55);
    slant.quadraticBezierTo(r.left, r.top, r.right - bw * 0.5, r.top);
    slant.lineTo(r.right - bw, r.top + bw * 0.5);
    slant.quadraticBezierTo(r.left + bw, r.top + bw, r.left + bw, r.top + h * 0.55);
    slant.close();
    
    Path four = Path.combine(PathOperation.union, vBar, hBar);
    four = Path.combine(PathOperation.union, four, slant);
    return four;
  }

  static Path _getDigit5Path(Rect r) {
    final double w = r.width;
    final double h = r.height;
    final double bw = w * 0.35;
    
    final path = Path();
    // 1. Curved Top Bar
    path.moveTo(r.left, r.top + bw * 0.5);
    path.quadraticBezierTo(r.left, r.top, r.center.dx, r.top);
    path.quadraticBezierTo(r.right, r.top, r.right, r.top + bw * 0.5);
    path.lineTo(r.right, r.top + bw);
    path.quadraticBezierTo(r.right, r.top + bw * 0.5, r.center.dx, r.top + bw * 0.5);
    path.quadraticBezierTo(r.left + bw, r.top + bw * 0.5, r.left + bw, r.top + bw * 1.2);
    path.close();
    
    // 2. Neck and Belly
    final belly = Path();
    belly.moveTo(r.left + bw, r.top + bw);
    belly.lineTo(r.left + bw, r.top + h * 0.45);
    belly.arcTo(Rect.fromLTWH(r.left, r.top + h * 0.3, w, h * 0.7), -1.2 * math.pi, 1.9 * math.pi, false);
    belly.close();
    
    Path five = Path.combine(PathOperation.union, path, belly);
    
    // 3. Belly hole
    Path hole = Path()..addOval(Rect.fromCenter(center: Offset(r.center.dx, r.bottom - h * 0.28), width: w * 0.3, height: h * 0.25));
    
    return Path.combine(PathOperation.difference, five, hole);
  }

  static Path _getDigit6Path(Rect r) {
    final double w = r.width;
    final double h = r.height;
    final double bw = w * 0.35;
    
    final path = Path();
    // Belly circle
    path.addOval(Rect.fromLTWH(r.left, r.top + h * 0.35, w, h * 0.65));
    
    // Neck coming from top-right
    final neck = Path();
    neck.moveTo(r.right - bw * 0.2, r.top);
    neck.quadraticBezierTo(r.left, r.top, r.left, r.top + h * 0.6);
    neck.lineTo(r.left + bw, r.top + h * 0.6);
    neck.quadraticBezierTo(r.left + bw, r.top + bw, r.right - bw * 0.2, r.top + bw);
    neck.close();
    
    final combined = Path.combine(PathOperation.union, path, neck);
    
    // Belly hole
    Path hole = Path()..addOval(Rect.fromCenter(center: Offset(r.center.dx, r.bottom - h * 0.28), width: w * 0.35, height: h * 0.25));
    return Path.combine(PathOperation.difference, combined, hole);
  }

  static Path _getDigit7Path(Rect r) {
    final double w = r.width;
    final double h = r.height;
    final double bw = w * 0.38;
    
    // Thick Top Bar
    Path path = Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(r.left, r.top, w, bw),
      Radius.circular(bw * 0.2),
    ));
    
    // Thick Curved Leg
    Path slant = Path();
    slant.moveTo(r.right, r.top);
    // Use h to define the bottom point relative to the rect
    slant.quadraticBezierTo(r.right, r.top + h, r.left + bw * 0.5, r.top + h);
    slant.lineTo(r.left - w * 0.05, r.top + h);
    slant.quadraticBezierTo(r.right - bw, r.top + h, r.right - bw, r.top + bw);
    slant.close();
    
    return Path.combine(PathOperation.union, path, slant);
  }

  static Path _getDigit8Path(Rect r) {
    final double w = r.width;
    final double h = r.height;
    
    // Two stacked ovals
    Path top = Path()..addOval(Rect.fromLTWH(r.left + w * 0.05, r.top, w * 0.9, h * 0.55));
    Path bottom = Path()..addOval(Rect.fromLTWH(r.left, r.top + h * 0.4, w, h * 0.6));
    Path union = Path.combine(PathOperation.union, top, bottom);
    
    // Internal holes (characterful)
    Path hole1 = Path()..addOval(Rect.fromCenter(center: Offset(r.center.dx, r.top + h * 0.28), width: w * 0.25, height: h * 0.15));
    Path hole2 = Path()..addOval(Rect.fromCenter(center: Offset(r.center.dx, r.bottom - h * 0.28), width: w * 0.3, height: h * 0.2));
    
    Path combined = Path.combine(PathOperation.difference, union, hole1);
    return Path.combine(PathOperation.difference, combined, hole2);
  }

  static Path _getDigit9Path(Rect r) {
    final double w = r.width;
    final double h = r.height;
    final double bw = w * 0.35;
    
    Path body = Path()..addOval(Rect.fromLTWH(r.left, r.top, w, h * 0.65));
    Path tail = Path();
    tail.moveTo(r.right, r.top + h * 0.4);
    tail.quadraticBezierTo(r.right, r.bottom, r.left + bw * 0.5, r.bottom);
    tail.lineTo(r.left, r.bottom);
    tail.lineTo(r.left, r.bottom - bw);
    tail.quadraticBezierTo(r.right - bw, r.bottom - bw, r.right - bw, r.top + h * 0.4);
    tail.close();
    
    Path combined = Path.combine(PathOperation.union, body, tail);
    Path hole = Path()..addOval(Rect.fromCenter(center: Offset(r.center.dx, r.top + h * 0.28), width: w * 0.3, height: h * 0.25));
    return Path.combine(PathOperation.difference, combined, hole);
  }

  @override
  bool shouldReclip(YearGridClipper old) => old.year != year || old.index != index;
}

class YearGridPainter extends CustomPainter {
  final String year;
  final Color color;
  final double width;
  YearGridPainter({required this.year, required this.color, required this.width});

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
        canvas.drawPath(YearGridClipper(year: year, index: i).getClip(size), paint);
    }
  }

  @override
  bool shouldRepaint(YearGridPainter old) =>
      old.year != year || old.color != color || old.width != width;
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

class Puzzle5Clipper extends CustomClipper<Path> {
  final int index;
  Puzzle5Clipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double cw = w / 3;
    double ch = h / 3;
    double tr = w * 0.055; // Tab radius

    // Helper for bulbous puzzle piece
    Path buildPiece(Rect rect, {int t = 0, int r = 0, int b = 0, int l = 0}) {
      Path path = Path()..addRect(rect);
      // Tabs (Convex)
      if (t == 1) path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.center.dx, rect.top), radius: tr)));
      if (r == 1) path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.right, rect.center.dy), radius: tr)));
      if (b == 1) path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.center.dx, rect.bottom), radius: tr)));
      if (l == 1) path = Path.combine(PathOperation.union, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.left, rect.center.dy), radius: tr)));
      // Blanks (Concave)
      if (t == -1) path = Path.combine(PathOperation.difference, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.center.dx, rect.top), radius: tr)));
      if (r == -1) path = Path.combine(PathOperation.difference, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.right, rect.center.dy), radius: tr)));
      if (b == -1) path = Path.combine(PathOperation.difference, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.center.dx, rect.bottom), radius: tr)));
      if (l == -1) path = Path.combine(PathOperation.difference, path, Path()..addOval(Rect.fromCircle(center: Offset(rect.left, rect.center.dy), radius: tr)));
      return path;
    }

    // Grid Layout (Virtual 3x3):
    // [0][0][1]
    // [2][3][3]
    // [2][4][4]

    if (index == 0) {
      // Piece 0: Top-Left + Top-Mid (Horizontal)
      Path p1 = buildPiece(Rect.fromLTWH(0, 0, cw, ch), r: 1, b: 1); // TL pieza
      Path p2 = buildPiece(Rect.fromLTWH(cw, 0, cw, ch), l: -1, r: -1, b: 1); // TM pieza
      return Path.combine(PathOperation.union, p1, p2);
    } else if (index == 1) {
      // Piece 1: Top-Right
      return buildPiece(Rect.fromLTWH(cw * 2, 0, cw, ch), l: 1, b: -1);
    } else if (index == 2) {
      // Piece 2: Mid-Left + Bot-Left (Vertical)
      Path p1 = buildPiece(Rect.fromLTWH(0, ch, cw, ch), t: -1, r: 1, b: 1);
      Path p2 = buildPiece(Rect.fromLTWH(0, ch * 2, cw, ch), t: -1, r: 1);
      return Path.combine(PathOperation.union, p1, p2);
    } else if (index == 3) {
      // Piece 3: Mid-Mid + Mid-Right
      Path p1 = buildPiece(Rect.fromLTWH(cw, ch, cw, ch), t: -1, l: -1, r: 1, b: 1);
      Path p2 = buildPiece(Rect.fromLTWH(cw * 2, ch, cw, ch), t: 1, l: -1, b: -1);
      return Path.combine(PathOperation.union, p1, p2);
    } else {
      // Piece 4: Bot-Mid + Bot-Right
      Path p1 = buildPiece(Rect.fromLTWH(cw, ch * 2, cw, ch), t: -1, l: -1, r: 1);
      Path p2 = buildPiece(Rect.fromLTWH(cw * 2, ch * 2, cw, ch), t: 1, l: -1);
      return Path.combine(PathOperation.union, p1, p2);
    }
  }

  @override
  bool shouldReclip(Puzzle5Clipper oldClipper) => oldClipper.index != index;
}

class Puzzle5Painter extends CustomPainter {
  final Color color;
  final double width;
  Puzzle5Painter({required this.color, required this.width});

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
      canvas.drawPath(Puzzle5Clipper(index: i).getClip(size), paint);
    }
  }

  @override
  bool shouldRepaint(Puzzle5Painter old) =>
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
    final double w = size.width;
    final double h = size.height;
    final double cx = w * 0.5;
    final double cy = h * 0.5;

    final double outerR = math.sqrt(w * w + h * h) * 1.1;
    const double totalSlices = 5;
    final double sliceAngle = 360.0 / totalSlices;
    
    double degToRad(double deg) => deg * math.pi / 180.0;

    final double startAngle = sliceAngle * index - 90.0;
    final double endAngle = startAngle + sliceAngle;

    final path = Path();
    final double innerR = w * 0.015;

    // Trace the jagged "Left" side
    addJaggedRadialLine(path, cx, cy, innerR, outerR, startAngle);

    // Arc at the very far edge
    path.arcTo(
      Rect.fromCircle(center: Offset(cx, cy), radius: outerR),
      degToRad(startAngle),
      degToRad(endAngle - startAngle),
      false,
    );

    // Trace the jagged "Right" side back to center
    addJaggedRadialLine(path, cx, cy, innerR, outerR, endAngle, reverse: true);

    path.close();
    return path;
  }

  static void addJaggedRadialLine(Path p, double cx, double cy, double radius1, double radius2, double angleDeg, {bool reverse = false}) {
    const int steps = 12; 
    const double amplitude = 6.0; 
    
    // Convert degrees to radians
    double degToRad(double deg) => deg * math.pi / 180.0;
    
    List<Offset> pts = [];
    for (int i = 0; i <= steps; i++) {
      double t = i / steps;
      double r = radius1 + (radius2 - radius1) * t;
      double offset = math.sin(t * math.pi * 5) * amplitude; 
      double angle = degToRad(angleDeg);
      double perpAngle = angle + math.pi / 2;
      
      pts.add(Offset(
        cx + r * math.cos(angle) + offset * math.cos(perpAngle),
        cy + r * math.sin(angle) + offset * math.sin(perpAngle),
      ));
    }
    
    if (reverse) pts = pts.reversed.toList();
    for (int i = 0; i < pts.length; i++) {
      if (i == 0 && !reverse) p.moveTo(pts[i].dx, pts[i].dy);
      else p.lineTo(pts[i].dx, pts[i].dy);
    }
  }

  @override
  bool shouldReclip(FanBurst5Clipper oldClipper) => index != oldClipper.index;
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
    
    // Deterministic "Action Burst" for professional comic look
    Path getBurst(double scale) {
      Path p = Path();
      int points = 28; // Increased for a richer, more detailed burst
      double innerR = side * 0.22 * scale;
      double outerR = side * 0.46 * scale;
      
      for (int i = 0; i < points; i++) {
        double angle = (2 * math.pi / points) * i - (math.pi / 2);
        double r;
        
        if (i % 2 == 0) {
          // Anchors (Inner points)
          r = innerR * 0.95;
        } else {
          // Spikes (Outer points)
          // Use a combination of frequencies for that irregular "Boom" look
          double h1 = math.sin(i * 1.5) * 0.35;
          double h2 = math.cos(i * 0.8) * 0.2;
          double variance = 1.0 + h1 + h2;
          
          if (i % 4 == 1) {
            // "Major" spikes are longer
            r = outerR * 1.15 * variance;
          } else {
            // "Minor" spikes are shorter
            r = outerR * 0.85 * variance;
          }
        }
        
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

    // Background quadrants (2x2 grid) - JOINED SEAMLESSLY
    Rect qRect;
    switch (index) {
        case 1: qRect = Rect.fromLTRB(0, 0, cx, cy); break;
        case 2: qRect = Rect.fromLTRB(cx, 0, w, cy); break;
        case 3: qRect = Rect.fromLTRB(cx, cy, w, h); break;
        case 4: qRect = Rect.fromLTRB(0, cy, cx, h); break;
        default: return Path();
    }
    
    Path quad = Path()..addRect(qRect);
    // Subtract the exact burst shape for a perfect, seamless "punch out" effect
    return Path.combine(PathOperation.difference, quad, getBurst(1.0));
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

class StarBurst5Clipper extends CustomClipper<Path> {
  final int index;
  StarBurst5Clipper({required this.index});

  @override
  Path getClip(Size size) => getStarKitePath(index, size);

  static Path getStarKitePath(int index, Size size) {
    double w = size.width, h = size.height;
    double cx = w / 2, cy = h / 2;
    double outerR = math.min(w, h) * 0.5;
    double innerR = outerR * 0.4;

    double baseAngle = -math.pi / 2 + (index * 2 * math.pi / 5);
    double leftAngle = baseAngle - math.pi / 5;
    double rightAngle = baseAngle + math.pi / 5;

    Path p = Path();
    p.moveTo(cx, cy);
    p.lineTo(cx + innerR * math.cos(leftAngle), cy + innerR * math.sin(leftAngle));
    p.lineTo(cx + outerR * math.cos(baseAngle), cy + outerR * math.sin(baseAngle));
    p.lineTo(cx + innerR * math.cos(rightAngle), cy + innerR * math.sin(rightAngle));
    p.close();

    return p;
  }

  @override
  bool shouldReclip(StarBurst5Clipper oldClipper) => index != oldClipper.index;
}

class StarBurst5Painter extends CustomPainter {
  final Color color;
  final double width;
  StarBurst5Painter({required this.color, required this.width});

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
      canvas.drawPath(StarBurst5Clipper.getStarKitePath(i, size), paint);
    }
  }

  @override
  bool shouldRepaint(StarBurst5Painter oldDelegate) => 
      color != oldDelegate.color || width != oldDelegate.width;
}

// ── Staircase 5 ──────────────────────────────────────────────────────────────
// Layout (all coords are fractions of canvas W×H):
//
//  +--1/3--+--1/3--+--1/3--+
//  |  [0]  |       |       |  0→40%
//  +  top  | [2]   | [4]   |
//  |  left | mid   | right |  40→60%
//  +--left-+       +       |
//  |  [1]  | [3]   |       |  60→100%
//  | bot   | bot   |       |
//  | left  | mid   + right +
//  +-------+-------+-------+
//
// img0: left col,  rows 0–40%
// img1: left col,  rows 40–100%
// img2: mid col,   rows 0–60%
// img3: mid col,   rows 60–100%
// img4: right col, rows 0–100%
//
// Internal seams (painted once each):
//   V1: x=1/3, full height
//   V2: x=2/3, full height
//   H1: y=0.4, x=0 → x=1/3       (between img0 and img1)
//   H2: y=0.6, x=1/3 → x=2/3     (between img2 and img3)
// ─────────────────────────────────────────────────────────────────────────────


class MonthClipper extends CustomClipper<Path> {

  final int index;
  MonthClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width, h = size.height;
    if (index == 0) {
      // Top half
      return Path()..addRect(Rect.fromLTRB(0, 0, w, h * 0.5));
    } else {
      // Bottom half
      return Path()..addRect(Rect.fromLTRB(0, h * 0.5, w, h));
    }
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class DynamicTextClipper extends CustomClipper<Path> {
  final int index;
  DynamicTextClipper({required this.index});

  @override
  Path getClip(Size size) {
    double w = size.width, h = size.height;
    Path path = Path();
    
    // Curved diagonal split from bottom-left region to top-right region
    // Matches the reference "2025" image style
    if (index == 0) {
      // Top-left part
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.lineTo(w, h * 0.15); // Slight drop at top-right
      path.quadraticBezierTo(w * 0.5, h * 0.5, 0, h * 0.85); // Curve to lower-left
      path.lineTo(0, 0);
    } else {
      // Bottom-right part
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.lineTo(w, h * 0.15); 
      path.quadraticBezierTo(w * 0.5, h * 0.5, 0, h * 0.85);
      path.lineTo(0, h);
    }
    return path;
  }
  
  static Path getDynamicTextSplitPath(Size size) {
    double w = size.width, h = size.height;
    return Path()
      ..moveTo(w, h * 0.15)
      ..quadraticBezierTo(w * 0.5, h * 0.5, 0, h * 0.85);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class PinwheelClipper extends CustomClipper<Path> {
  final int index;
  PinwheelClipper({required this.index});

  @override
  Path getClip(Size size) {
    if (index == 4) return getCenterCirclePath(size);
    return getPetalPath(index, size);
  }

  static Path getCenterCirclePath(Size size) {
    double w = size.width, h = size.height;
    double cx = w * 0.5, cy = h * 0.5;
    double r = math.min(w, h) * 0.20; // Increased center circle radius
    return Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
  }

  /// Returns 4 sweeping curved petals that perfectly tile the background.
  static Path getPetalPath(int index, Size size) {
    double w = size.width, h = size.height;
    double cx = w * 0.5, cy = h * 0.5;

    // Relative to center coordinates
    double swoopX = w * 0.35;
    double swoopY = h * 0.35;

    Offset M0 = Offset(0, -h/2);
    Offset M1 = Offset(w/2, 0);
    Offset M2 = Offset(0, h/2);
    Offset M3 = Offset(-w/2, 0);

    Offset C0 = Offset(w/2, -h/2);
    Offset C1 = Offset(w/2, h/2);
    Offset C2 = Offset(-w/2, h/2);
    Offset C3 = Offset(-w/2, -h/2);

    Offset CP_M0 = Offset(-swoopX, -swoopY);
    Offset CP_M1 = Offset(swoopX, -swoopY);
    Offset CP_M2 = Offset(swoopX, swoopY);
    Offset CP_M3 = Offset(-swoopX, swoopY);

    Path p = Path();
    p.moveTo(0, 0);

    if (index == 0) { // Top-Right Petal
      p.quadraticBezierTo(CP_M0.dx, CP_M0.dy, M0.dx, M0.dy);
      p.lineTo(C0.dx, C0.dy);
      p.lineTo(M1.dx, M1.dy);
      p.quadraticBezierTo(CP_M1.dx, CP_M1.dy, 0, 0);
    } else if (index == 1) { // Bottom-Right Petal
      p.quadraticBezierTo(CP_M1.dx, CP_M1.dy, M1.dx, M1.dy);
      p.lineTo(C1.dx, C1.dy);
      p.lineTo(M2.dx, M2.dy);
      p.quadraticBezierTo(CP_M2.dx, CP_M2.dy, 0, 0);
    } else if (index == 2) { // Bottom-Left Petal
      p.quadraticBezierTo(CP_M2.dx, CP_M2.dy, M2.dx, M2.dy);
      p.lineTo(C2.dx, C2.dy);
      p.lineTo(M3.dx, M3.dy);
      p.quadraticBezierTo(CP_M3.dx, CP_M3.dy, 0, 0);
    } else if (index == 3) { // Top-Left Petal
      p.quadraticBezierTo(CP_M3.dx, CP_M3.dy, M3.dx, M3.dy);
      p.lineTo(C3.dx, C3.dy);
      p.lineTo(M0.dx, M0.dy);
      p.quadraticBezierTo(CP_M0.dx, CP_M0.dy, 0, 0);
    }
    p.close();

    Path rawPetal = p.shift(Offset(cx, cy));
    Path centerCircle = getCenterCirclePath(size);

    return Path.combine(PathOperation.difference, rawPetal, centerCircle);
  }

  @override
  bool shouldReclip(PinwheelClipper old) => index != old.index;
}

class PinwheelPainter extends CustomPainter {
  final Color color;
  final double width;
  PinwheelPainter({required this.color, required this.width});

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
      canvas.drawPath(PinwheelClipper.getPetalPath(i, size), paint);
    }
    canvas.drawPath(PinwheelClipper.getCenterCirclePath(size), paint);
  }

  @override
  bool shouldRepaint(PinwheelPainter old) =>
      old.color != color || old.width != width;
}

class DiamondGrid4Clipper extends CustomClipper<Path> {
  final int index;
  DiamondGrid4Clipper({required this.index});

  static Path _getRoundedTriangle(double cX, double cY, double side, double signX, double signY, double r) {
    Path path = Path();
    double rSharp = r * 1.8;

    double startX = cX;
    double startY = cY + r * signY;
    path.moveTo(startX, startY);
    path.quadraticBezierTo(cX, cY, cX + r * signX, cY);

    double lX = cX + side * signX;
    double lY = cY;
    path.lineTo(lX - rSharp * signX, lY);
    
    double hx = -signX / math.sqrt2;
    double hy = signY / math.sqrt2;
    
    path.quadraticBezierTo(lX, lY, lX + rSharp * hx, lY + rSharp * hy);

    double tX = cX;
    double tY = cY + side * signY;
    path.lineTo(tX - rSharp * hx, tY - rSharp * hy);
    path.quadraticBezierTo(tX, tY, tX, tY - rSharp * signY);

    path.close();
    return path;
  }

  static Path getPath(int index, Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w / 2;
    double cy = h / 2;
    // We use a small gap so the rounded corners look visually pleasing without
    // overlapping paths in the center, leaving room for the editor's stroke line.
    double g = w * 0.015; 
    double S = math.min(w, h) / 2 - g * 1.5;
    double r = w * 0.06;

    if (index == 0) return _getRoundedTriangle(cx - g, cy - g, S, -1, -1, r);
    if (index == 1) return _getRoundedTriangle(cx + g, cy - g, S, 1, -1, r);
    if (index == 2) return _getRoundedTriangle(cx - g, cy + g, S, -1, 1, r);
    return _getRoundedTriangle(cx + g, cy + g, S, 1, 1, r);
  }

  @override
  Path getClip(Size size) => getPath(index, size);

  @override
  bool shouldReclip(DiamondGrid4Clipper oldClipper) => index != oldClipper.index;
}

class SlantedFilmStrip4Clipper extends CustomClipper<Path> {
  final int index;
  SlantedFilmStrip4Clipper({required this.index});

  static Path getWindowPath(int index, Size size) {
    double w = size.width;
    double h = size.height;
    if (index == 0) return Path()..addRect(Rect.fromLTWH(0, 0, w, h));

    double cx = w / 2;
    double cy = h / 2;
    double ws = w * 0.62;
    double ww = ws * 0.82;
    double hw = ww * 0.85;
    double gapY = ws * 0.1;

    double yCenter = 0;
    if (index == 1) yCenter = -(hw + gapY);
    if (index == 3) yCenter = (hw + gapY);

    Rect rect = Rect.fromCenter(center: Offset(0, yCenter), width: ww, height: hw);
    Path p = Path()..addRect(rect);

    Matrix4 m = Matrix4.identity()
      ..translate(cx, cy)
      ..rotateZ(math.pi / 14);
    
    return p.transform(m.storage);
  }

  @override
  Path getClip(Size size) => getWindowPath(index, size);

  @override
  bool shouldReclip(SlantedFilmStrip4Clipper oldClipper) => index != oldClipper.index;
}

class SlantedFilmStrip4Painter extends CustomPainter {
  final Color color;
  final double width;
  SlantedFilmStrip4Painter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w / 2;
    double cy = h / 2;
    
    double ws = w * 0.62;
    double ww = ws * 0.82;
    double hw = ww * 0.85;
    double gapY = ws * 0.1;

    Path strip = Path()..addRect(Rect.fromCenter(center: Offset.zero, width: ws, height: h * 2.5));
    
    // Punch out the 3 windows
    Path windows = Path();
    windows.addRect(Rect.fromCenter(center: Offset(0, -(hw + gapY)), width: ww, height: hw));
    windows.addRect(Rect.fromCenter(center: Offset.zero, width: ww, height: hw));
    windows.addRect(Rect.fromCenter(center: Offset(0, (hw + gapY)), width: ww, height: hw));

    strip = Path.combine(PathOperation.difference, strip, windows);

    // Punch out the perforations
    double ps = ws * 0.055;
    double padding = ws * 0.035;
    double pSpace = ps * 2.0;
    
    Path perfs = Path();
    double leftX = -ws/2 + padding + ps/2;
    double rightX = ws/2 - padding - ps/2;
    
    for (double y = -h * 1.5; y < h * 1.5; y += pSpace) {
      perfs.addRect(Rect.fromCenter(center: Offset(leftX, y), width: ps, height: ps));
      perfs.addRect(Rect.fromCenter(center: Offset(rightX, y), width: ps, height: ps));
    }

    strip = Path.combine(PathOperation.difference, strip, perfs);

    // Apply transformation
    Matrix4 m = Matrix4.identity()
      ..translate(cx, cy)
      ..rotateZ(math.pi / 14);
      
    strip = strip.transform(m.storage);

    // Draw Drop Shadow
    canvas.drawShadow(strip, Colors.black, 15.0, true);

    // Draw strip body using the user's selected line color
    // Usually white looks best, but mapping to line color adds customization.
    // If line color is too dark, user can easily change it from Border tool.
    canvas.drawPath(strip, Paint()..color = color);
  }

  @override
  bool shouldRepaint(SlantedFilmStrip4Painter old) => 
    old.color != color || old.width != width;
}

class DiamondGrid4Painter extends CustomPainter {
  final Color color;
  final double width;
  DiamondGrid4Painter({required this.color, required this.width});

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
        canvas.drawPath(DiamondGrid4Clipper.getPath(i, size), paint);
    }
  }

  @override
  bool shouldRepaint(DiamondGrid4Painter old) =>
      old.color != color || old.width != width;
}

class AsymmetricArch4Clipper extends CustomClipper<Path> {
  final int index;
  AsymmetricArch4Clipper({required this.index});

  static Path getPath(int index, Size size) {
    double w = size.width;
    double h = size.height;
    double cx = w * 0.35;
    double cy = h * 0.65;
    double g = w * 0.02; // gap
    double r = w * 0.15; // corner radius

    if (index == 0) {
      return Path()..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTRB(0, 0, cx - g/2, cy - g/2),
        topLeft: Radius.circular(r),
        topRight: Radius.circular(r),
      ));
    } else if (index == 1) {
      double cellW = cx - g/2;
      double cellH = h - cy - g/2;
      double rad = math.min(cellW, cellH) / 2;
      return Path()..addOval(Rect.fromCircle(
        center: Offset(cellW / 2, cy + g/2 + cellH / 2),
        radius: rad,
      ));
    } else if (index == 2) {
      return Path()..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTRB(cx + g/2, 0, w, cy - g/2),
        topLeft: Radius.circular(r),
        topRight: Radius.circular(r),
      ));
    } else {
      return Path()..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTRB(cx + g/2, cy + g/2, w, h),
        bottomLeft: Radius.circular(r),
        bottomRight: Radius.circular(r),
      ));
    }
  }

  @override
  Path getClip(Size size) => getPath(index, size);

  @override
  bool shouldReclip(AsymmetricArch4Clipper oldClipper) => index != oldClipper.index;
}

class AsymmetricArch4Painter extends CustomPainter {
  final Color color;
  final double width;
  AsymmetricArch4Painter({required this.color, required this.width});

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
        canvas.drawPath(AsymmetricArch4Clipper.getPath(i, size), paint);
    }
  }

  @override
  bool shouldRepaint(AsymmetricArch4Painter old) =>
      old.color != color || old.width != width;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ARC TRIO — 3-image layout with two sweeping quarter-circle arc dividers
//   Reference: two large arcs, one from top-left corner, one from bottom-right.
//   Image 0: top-left region (inside Arc A's pie slice)
//   Image 1: middle band (between the two arcs)
//   Image 2: bottom-right region (inside Arc B's pie slice)
// ═══════════════════════════════════════════════════════════════════════════════

class ArcTrio3Clipper extends CustomClipper<Path> {
  final int index;
  ArcTrio3Clipper({required this.index});

  // Arc A: centre at (0,0), large radius sweeping from top edge to left edge.
  // Arc B: centre at (w,h), large radius sweeping from right edge to bottom edge.
  static Path getPath(int index, Size size) {
    final w = size.width;
    final h = size.height;

    // Radii tuned to match the reference image proportions.
    final double rA = w * 0.75;
    final double rB = w * 0.65;

    // Arc A endpoints (centre 0,0):
    //   top edge: (rA, 0)   left edge: (0, rA)
    final double axTop = math.min(rA, w);
    final double ayLeft = math.min(rA, h);

    // Arc B endpoints (centre w,h):
    //   right edge: (w, h - rB)   bottom edge: (w - rB, h)
    final double byRight = math.max(h - rB, 0);
    final double bxBottom = math.max(w - rB, 0);

    final path = Path();

    if (index == 0) {
      // TOP-LEFT region: pie slice bounded by Arc A.
      path.moveTo(0, 0);
      path.lineTo(axTop, 0);
      // Quarter-arc clockwise from (axTop, 0) to (0, ayLeft)
      path.arcToPoint(
        Offset(0, ayLeft),
        radius: Radius.circular(rA),
        clockwise: true,
      );
      path.close();
    } else if (index == 1) {
      // MIDDLE region: everything between Arc A and Arc B.
      // Trace: top edge right of Arc A → right edge down to Arc B → Arc B to bottom edge →
      //        bottom edge left → left edge up to Arc A → Arc A back to start.
      path.moveTo(axTop, 0);
      path.lineTo(w, 0);
      path.lineTo(w, byRight);
      // Arc B: counter-clockwise (short 90°) from (w, byRight) to (bxBottom, h)
      path.arcToPoint(
        Offset(bxBottom, h),
        radius: Radius.circular(rB),
        clockwise: false,
      );
      path.lineTo(0, h);
      path.lineTo(0, ayLeft);
      // Arc A: counter-clockwise (short 90°) from (0, ayLeft) to (axTop, 0)
      path.arcToPoint(
        Offset(axTop, 0),
        radius: Radius.circular(rA),
        clockwise: false,
      );
      path.close();
    } else {
      // BOTTOM-RIGHT region: pie slice bounded by Arc B.
      path.moveTo(w, byRight);
      path.lineTo(w, h);
      path.lineTo(bxBottom, h);
      // Quarter-arc counter-clockwise from (bxBottom, h) to (w, byRight)
      path.arcToPoint(
        Offset(w, byRight),
        radius: Radius.circular(rB),
        clockwise: true,
      );
      path.close();
    }
    return path;
  }

  @override
  Path getClip(Size size) => getPath(index, size);

  @override
  bool shouldReclip(ArcTrio3Clipper old) => index != old.index;
}

class ArcTrio3Painter extends CustomPainter {
  final Color color;
  final double width;
  ArcTrio3Painter({required this.color, required this.width});

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

    final double rA = w * 0.75;
    final double rB = w * 0.65;
    final double axTop = math.min(rA, w);
    final double ayLeft = math.min(rA, h);
    final double byRight = math.max(h - rB, 0);
    final double bxBottom = math.max(w - rB, 0);

    // Draw Arc A (top-left corner arc)
    final pathA = Path();
    pathA.moveTo(axTop, 0);
    pathA.arcToPoint(
      Offset(0, ayLeft),
      radius: Radius.circular(rA),
      clockwise: true,
    );
    canvas.drawPath(pathA, paint);

    // Draw Arc B (bottom-right corner arc)
    final pathB = Path();
    pathB.moveTo(w, byRight);
    pathB.arcToPoint(
      Offset(bxBottom, h),
      radius: Radius.circular(rB),
      clockwise: false,
    );
    canvas.drawPath(pathB, paint);
  }

  @override
  bool shouldRepaint(ArcTrio3Painter old) =>
      old.color != color || old.width != width;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLANTED GALLERY — 4-image layout with a slanted vertical divider and 3 stacked right images
//   Image 0: Large left image, slanted right edge (wider at top).
//   Images 1, 2, 3: Three right-side images stacked vertically.
// ═══════════════════════════════════════════════════════════════════════════════

class SlantedGallery4Clipper extends CustomClipper<Path> {
  final int index;
  SlantedGallery4Clipper({required this.index});

  static Path getPath(int index, Size size) {
    final w = size.width;
    final h = size.height;

    // Configuration
    const double xTop = 0.44;   // x-position at top (0.0 - 1.0)
    const double xBottom = 0.34; // x-position at bottom (0.0 - 1.0)
    final double gap = w * 0.025; // gap width
    final double radius = w * 0.05; // corner radius

    // Helper for x at a given y
    double xAt(double y) => xTop * w + (xBottom * w - xTop * w) * (y / h);

    final path = Path();

    if (index == 0) {
      // LEFT section
      // We want to draw a rounded path for the left section.
      // Top row: (gap, gap) to (xAt(gap) - gap/2, gap)
      // Bottom row: (gap, h - gap) to (xAt(h - gap) - gap/2, h - gap)
      double xt = xAt(gap) - gap / 2;
      double xb = xAt(h - gap) - gap / 2;

      path.moveTo(gap + radius, gap);
      path.lineTo(xt - radius, gap);
      path.quadraticBezierTo(xt, gap, xt - (xt - xb) * (radius / h), gap + radius);
      path.lineTo(xb + (xt - xb) * (radius / h), h - gap - radius);
      path.quadraticBezierTo(xb, h - gap, xb - radius, h - gap);
      path.lineTo(gap + radius, h - gap);
      path.quadraticBezierTo(gap, h - gap, gap, h - gap - radius);
      path.lineTo(gap, gap + radius);
      path.quadraticBezierTo(gap, gap, gap + radius, gap);
      path.close();
    } else {
      // RIGHT sections (1, 2, 3)
      int i = index - 1; // 0, 1, or 2
      double yStart = (i / 3) * h + (i == 0 ? gap : gap / 2);
      double yEnd = ((i + 1) / 3) * h - (i == 2 ? gap : gap / 2);

      double xt = xAt(yStart) + gap / 2;
      double xb = xAt(yEnd) + gap / 2;

      path.moveTo(xt + radius, yStart);
      path.lineTo(w - gap - radius, yStart);
      path.quadraticBezierTo(w - gap, yStart, w - gap, yStart + radius);
      path.lineTo(w - gap, yEnd - radius);
      path.quadraticBezierTo(w - gap, yEnd, w - gap - radius, yEnd);
      path.lineTo(xb + radius, yEnd);
      path.quadraticBezierTo(xb, yEnd, xb + (xt - xb) * (radius / (yEnd - yStart)), yEnd - radius);
      path.lineTo(xt - (xt - xb) * (radius / (yEnd - yStart)), yStart + radius);
      path.quadraticBezierTo(xt, yStart, xt + radius, yStart);
      path.close();
    }
    return path;
  }

  @override
  Path getClip(Size size) => getPath(index, size);

  @override
  bool shouldReclip(SlantedGallery4Clipper old) => index != old.index;
}

class SlantedGallery4Painter extends CustomPainter {
  final Color color;
  final double width;
  SlantedGallery4Painter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Instead of drawing the "ideal" split lines, we'll draw the boundaries of each section
    // to match the rounded-corners look in the reference image.
    for (int i = 0; i < 4; i++) {
      canvas.drawPath(SlantedGallery4Clipper.getPath(i, size), paint);
    }
  }

  @override
  bool shouldRepaint(SlantedGallery4Painter old) =>
      old.color != color || old.width != width;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ARTISTIC HANDS — 2-image layout with two stylized hands reaching toward each other
//   Reference: two hands from opposite sides, some fingers bent, some open.
//   Image 0: Clipped to the left hand silhouette.
//   Image 1: Clipped to the right hand silhouette.
// ═══════════════════════════════════════════════════════════════════════════════



// ═══════════════════════════════════════════════════════════════════════════════
// ARTISTIC HANDS — 2-image layout with two stylized hands interlocking
//   Reference: One background image, and two hand silhouettes containing the 2nd image.
//   Orchestration: Hands are placed diagonally (bottom-left and top-right).
//   Image 0: Background (Everything except the hand shapes).
//   Image 1: Inside the two hand shapes.
// ═══════════════════════════════════════════════════════════════════════════════

class ArtisticHands2Clipper extends CustomClipper<Path> {
  final int index;
  ArtisticHands2Clipper({required this.index});

  /// Returns the combined path of both interlocking hands.
  static Path getHandsPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // --- HAND 1 (From Bottom-Left / Grey Sleeve side) ---
    // Starting at the bottom-left corner area (the wrist/sleeve)
    path.moveTo(w * 0.0, h * 0.70); // Wrist start on left edge
    path.lineTo(w * 0.1, h * 1.0); // Wrist end on bottom edge
    path.lineTo(w * 0.2, h * 1.0); // Sleeve width
    
    // Palm and thumb reaching UP and RIGHT
    path.cubicTo(w * 0.25, h * 0.85, w * 0.30, h * 0.60, w * 0.40, h * 0.45); // Palm up
    
    // THUMB (Hand 1) - Pointing Up-Right
    path.cubicTo(w * 0.45, h * 0.35, w * 0.55, h * 0.25, w * 0.65, h * 0.35); 
    path.cubicTo(w * 0.60, h * 0.40, w * 0.50, h * 0.45, w * 0.45, h * 0.50);

    // FINGERS (Hand 1) - Interlacing
    // Finger 1 (Index)
    path.cubicTo(w * 0.55, h * 0.50, w * 0.70, h * 0.55, w * 0.85, h * 0.60);
    path.cubicTo(w * 0.80, h * 0.65, w * 0.65, h * 0.68, w * 0.55, h * 0.65);
    
    // Finger 2 (Middle)
    path.cubicTo(w * 0.60, h * 0.70, w * 0.75, h * 0.75, w * 0.80, h * 0.85);
    path.cubicTo(w * 0.70, h * 0.90, w * 0.60, h * 0.85, w * 0.50, h * 0.80);
    
    // Return to sleeve
    path.cubicTo(w * 0.35, h * 0.75, w * 0.20, h * 0.65, w * 0.0, h * 0.70);
    path.close();

    // --- HAND 2 (From Top-Right side) ---
    final path2 = Path();
    path2.moveTo(w * 0.75, h * 0.0); // Wrist start on top edge
    path2.lineTo(w * 1.0, h * 0.0); // Top-right corner
    path2.lineTo(w * 1.0, h * 0.30); // Wrist end on right edge
    
    // Palm and thumb reaching DOWN and LEFT
    path2.cubicTo(w * 0.85, h * 0.35, w * 0.75, h * 0.45, w * 0.60, h * 0.50); // Palm down
    
    // THUMB (Hand 2) - Pointing Down-Left
    path2.cubicTo(w * 0.50, h * 0.55, w * 0.40, h * 0.65, w * 0.35, h * 0.55);
    path2.cubicTo(w * 0.40, h * 0.50, w * 0.50, h * 0.45, w * 0.55, h * 0.40);

    // FINGERS (Hand 2) - Interlacing
    // Finger 1 (Index) - Pointing Left/Up
    path2.cubicTo(w * 0.45, h * 0.35, w * 0.30, h * 0.30, w * 0.20, h * 0.35);
    path2.cubicTo(w * 0.25, h * 0.40, w * 0.35, h * 0.45, w * 0.45, h * 0.48);
    
    // Finger 2 (Middle)
    path2.cubicTo(w * 0.35, h * 0.55, w * 0.25, h * 0.65, w * 0.30, h * 0.75);
    path2.cubicTo(w * 0.40, h * 0.75, w * 0.50, h * 0.65, w * 0.55, h * 0.60);

    // Return to wrist
    path2.cubicTo(w * 0.75, h * 0.55, w * 0.80, h * 0.30, w * 0.75, h * 0.0);
    path2.close();

    path.addPath(path2, Offset.zero);
    return path;
  }

  @override
  Path getClip(Size size) {
    final handsPath = getHandsPath(size);
    if (index == 1) return handsPath;

    // Index 0: Background (Everything except the hands)
    final bgPath = Path();
    bgPath.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(PathOperation.difference, bgPath, handsPath);
  }

  @override
  bool shouldReclip(ArtisticHands2Clipper old) => index != old.index;
}

class ArtisticHands2Painter extends CustomPainter {
  final Color color;
  final double width;
  ArtisticHands2Painter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(ArtisticHands2Clipper.getHandsPath(size), paint);
  }

  @override
  bool shouldRepaint(ArtisticHands2Painter old) =>
      old.color != color || old.width != width;
}

// ═══════════════════════════════════════════════════════════════════════════════
// INTERLOCKING LOCKS — 2-image layout with two stylized padlocks
//   Image 0: Clipped to the left padlock silhouette.
//   Image 1: Clipped to the right padlock silhouette.
// ═══════════════════════════════════════════════════════════════════════════════

class InterlockingLocks2Clipper extends CustomClipper<Path> {
  final int index;
  InterlockingLocks2Clipper({required this.index});

  /// Returns the stylized path for one of the two padlocks.
  /// isLeft: true for the left lock, false for the right lock.
  static Path _getLockPath(Size size, bool isLeft) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Center of body
    final cx = isLeft ? w * 0.35 : w * 0.65;
    final cy = h * 0.65;
    final bw = w * 0.38; // body width
    final bh = h * 0.35; // body height
    
    // 1. Draw the Body (Rounded Rect)
    final bodyRect = Rect.fromCenter(center: Offset(cx, cy), width: bw, height: bh);
    path.addRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(bw * 0.2)));
    
    // 2. Draw the Shackle (closed loop)
    final sw = bw * 0.7; // shackle width
    final sh = h * 0.45; // shackle height
    final sy = cy - bh * 0.5; // start from top of body
    
    final shacklePath = Path();
    shacklePath.moveTo(cx - sw * 0.5, sy);
    shacklePath.lineTo(cx - sw * 0.5, sy - sh * 0.6);
    shacklePath.arcToPoint(
      Offset(cx + sw * 0.5, sy - sh * 0.6),
      radius: Radius.circular(sw * 0.5),
    );
    shacklePath.lineTo(cx + sw * 0.5, sy);
    
    // Outer outline of shackle
    final outerPath = Path();
    outerPath.moveTo(cx - sw * 0.5 - 2, sy);
    outerPath.lineTo(cx - sw * 0.5 - 2, sy - sh * 0.6);
    outerPath.arcToPoint(
      Offset(cx + sw * 0.5 + 2, sy - sh * 0.6),
      radius: Radius.circular(sw * 0.5 + 2),
    );
    outerPath.lineTo(cx + sw * 0.5 + 2, sy);
    
    // Create a closed path for the shackle by tracing back
    final combinedShackle = Path();
    combinedShackle.moveTo(cx - sw * 0.5, sy);
    combinedShackle.lineTo(cx - sw * 0.5, sy - sh * 0.6);
    combinedShackle.arcToPoint(
      Offset(cx + sw * 0.5, sy - sh * 0.6),
      radius: Radius.circular(sw * 0.5),
    );
    combinedShackle.lineTo(cx + sw * 0.5, sy);
    combinedShackle.lineTo(cx + sw * 0.35, sy); // inner top point
    combinedShackle.lineTo(cx + sw * 0.35, sy - sh * 0.55);
    combinedShackle.arcToPoint(
      Offset(cx - sw * 0.35, sy - sh * 0.55),
      radius: Radius.circular(sw * 0.35),
      clockwise: false,
    );
    combinedShackle.lineTo(cx - sw * 0.35, sy);
    combinedShackle.close();
    
    path.addPath(combinedShackle, Offset.zero);

    // Apply rotation for the entire lock
    final rotation = isLeft ? 0.15 : -0.15;
    final Matrix4 matrix = Matrix4.identity()
      ..translate(cx, cy)
      ..rotateZ(rotation)
      ..translate(-cx, -cy);
    
    return path.transform(matrix.storage);
  }

  @override
  Path getClip(Size size) {
    return _getLockPath(size, index == 0);
  }

  @override
  bool shouldReclip(InterlockingLocks2Clipper old) => index != old.index;
}

class InterlockingLocks2Painter extends CustomPainter {
  final Color color;
  final double width;
  InterlockingLocks2Painter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(InterlockingLocks2Clipper._getLockPath(size, true), paint);
    canvas.drawPath(InterlockingLocks2Clipper._getLockPath(size, false), paint);
  }

  @override
  bool shouldRepaint(InterlockingLocks2Painter old) =>
      old.color != color || old.width != width;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLANTED SIX — 6-image layout with staggered slanted columns
//   3 vertical slanted columns, each split into 2 rows (Top/Bottom).
//   Image indexing:
//     0: Col 1 Top, 1: Col 1 Bottom
//     2: Col 2 Top, 3: Col 2 Bottom
//     4: Col 3 Top, 5: Col 3 Bottom
// ═══════════════════════════════════════════════════════════════════════════════

class SlantedSixClipper extends CustomClipper<Path> {
  final int index;
  final double gap;
  final double radius;

  SlantedSixClipper({required this.index, this.gap = 8.0, this.radius = 16.0});

  static List<Path> _getPaths(Size size, double gap, double radius) {
    final w = size.width;
    final h = size.height;
    final List<Path> paths = [];

    // Vertical slanted dividers (Top x, Bottom x)
    final v1 = [0.36 * w, 0.30 * w];
    final v2 = [0.69 * w, 0.63 * w];

    // Horizontal slanted dividers (y at v0, y at v1, y at v2, y at v3)
    final hMid = [0.55 * h, 0.48 * h, 0.58 * h, 0.50 * h];

    Path createPart(List<double> tl, List<double> tr, List<double> bl, List<double> br) {
      final path = Path();
      // Apply gap inset
      // For simplicity, we'll just draw the quad and use some inset logic
      // In a real premium app, we calculate the normal insets.
      
      // Points for the segment
      final p1 = Offset(tl[0] + gap, tl[1] + gap);
      final p2 = Offset(tr[0] - gap, tr[1] + gap);
      final p3 = Offset(br[0] - gap, br[1] - gap);
      final p4 = Offset(bl[0] + gap, bl[1] - gap);

      path.moveTo(p1.dx + radius, p1.dy);
      path.lineTo(p2.dx - radius, p2.dy);
      path.quadraticBezierTo(p2.dx, p2.dy, p2.dx, p2.dy + radius);
      path.lineTo(p3.dx, p3.dy - radius);
      path.quadraticBezierTo(p3.dx, p3.dy, p3.dx - radius, p3.dy);
      path.lineTo(p4.dx + radius, p4.dy);
      path.quadraticBezierTo(p4.dx, p4.dy, p4.dx, p4.dy - radius);
      path.lineTo(p1.dx, p1.dy + radius);
      path.quadraticBezierTo(p1.dx, p1.dy, p1.dx + radius, p1.dy);
      path.close();
      return path;
    }

    // Col 1 Top
    paths.add(createPart([0, 0], [v1[0], 0], [0, hMid[0]], [v1[0], hMid[1]]));
    // Col 1 Bottom
    paths.add(createPart([0, hMid[0]], [v1[1], hMid[1]], [0, h], [v1[1], h]));

    // Col 2 Top
    paths.add(createPart([v1[0], 0], [v2[0], 0], [v1[0], hMid[1]], [v2[0], hMid[2]]));
    // Col 2 Bottom
    paths.add(createPart([v1[1], hMid[1]], [v2[1], hMid[2]], [v1[1], h], [v2[1], h]));

    // Col 3 Top
    paths.add(createPart([v2[0], 0], [w, 0], [v2[0], hMid[2]], [w, hMid[3]]));
    // Col 3 Bottom
    paths.add(createPart([v2[1], hMid[2]], [w, hMid[3]], [v2[1], h], [w, h]));

    return paths;
  }

  @override
  Path getClip(Size size) {
    final paths = _getPaths(size, gap / 2, radius);
    if (index >= 0 && index < paths.length) {
      return paths[index];
    }
    return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(SlantedSixClipper old) =>
      old.index != index || old.gap != gap || old.radius != radius;
}

class SlantedSixPainter extends CustomPainter {
  final Color color;
  final double width;
  final double gap;
  final double radius;

  SlantedSixPainter({
    required this.color,
    required this.width,
    this.gap = 8.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paths = SlantedSixClipper._getPaths(size, gap / 2, radius);
    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SlantedSixPainter old) =>
      old.color != color || old.width != width || old.gap != gap || old.radius != radius;
}

class DiagonalStarClipper extends CustomClipper<Path> {
  final int index;
  DiagonalStarClipper({required this.index});

  static Path getPath(int index, Size size) {
    double w = size.width, h = size.height;
    Path path = Path();
    
    switch (index) {
      case 0:
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w / 2, h / 2);
        break;
      case 1:
        path.moveTo(w, 0);
        path.lineTo(w, h);
        path.lineTo(w / 2, h / 2);
        break;
      case 2:
        path.moveTo(w, h);
        path.lineTo(0, h);
        path.lineTo(w / 2, h / 2);
        break;
      case 3:
        path.moveTo(0, h);
        path.lineTo(0, 0);
        path.lineTo(w / 2, h / 2);
        break;
      default:
        path.addRect(Rect.fromLTWH(0, 0, w, h));
    }
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) => getPath(index, size);

  @override
  bool shouldReclip(DiagonalStarClipper old) => old.index != index;
}

class DiagonalStarPainter extends CustomPainter {
  final Color color;
  final double width;
  DiagonalStarPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);

    // Add outer border with double thickness (so the visible half matches inner lines)
    final outerPaint = Paint()
      ..color = color
      ..strokeWidth = width * 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), outerPaint);
  }

  @override
  bool shouldRepaint(DiagonalStarPainter old) => old.color != color || old.width != width;
}

// ──────────────────────────────────────────────────────────────────────────────
// BOOK 3D — Perspective open book split
// ──────────────────────────────────────────────────────────────────────────────
class Book3DClipper extends CustomClipper<Path> {
  final int index;
  Book3DClipper({required this.index});

  static Path getPath(int index, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Perspective coordinates for "Folded Page" effect
    if (index == 0) {
      // Left Page (Tapering towards center)
      path.moveTo(w * 0.05, h * 0.08);
      path.lineTo(w * 0.485, h * 0.15);
      path.lineTo(w * 0.485, h * 0.85);
      path.lineTo(w * 0.05, h * 0.92);
      path.close();
    } else {
      // Right Page
      path.moveTo(w * 0.515, h * 0.15);
      path.lineTo(w * 0.95, h * 0.08);
      path.lineTo(w * 0.95, h * 0.92);
      path.lineTo(w * 0.515, h * 0.85);
      path.close();
    }
    return path;
  }

  @override
  Path getClip(Size size) => getPath(index, size);

  @override
  bool shouldReclip(Book3DClipper old) => old.index != index;
}

// ──────────────────────────────────────────────────────────────────────────────
// PRISM 3D — Dual-faceted perspective split
// ──────────────────────────────────────────────────────────────────────────────
class PrismClipper extends CustomClipper<Path> {
  final int index;
  PrismClipper({required this.index});

  static Path getPath(int index, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Perspective ridge shifted to 0.65w for a "side-view" look
    if (index == 0) {
      // Left/Front Facet (Prominent)
      path.moveTo(0, 0);
      path.lineTo(w * 0.65, h * 0.08);
      path.lineTo(w * 0.65, h * 0.92);
      path.lineTo(0, h);
      path.close();
    } else {
      // Right/Side Facet (Receding)
      path.moveTo(w * 0.65, h * 0.08);
      path.lineTo(w, 0);
      path.lineTo(w, h);
      path.lineTo(w * 0.65, h * 0.92);
      path.close();
    }
    return path;
  }

  @override
  Path getClip(Size size) => getPath(index, size);

  @override
  bool shouldReclip(PrismClipper old) => old.index != index;
}

// ──────────────────────────────────────────────────────────────────────────────
// MAGAZINE SPREAD — 2 Page dual split layout for magazine overlays
// ──────────────────────────────────────────────────────────────────────────────
class MagazineSpreadClipper extends CustomClipper<Path> {
  final int index;
  final double inset;
  MagazineSpreadClipper({required this.index, this.inset = 0.0});

  static Path getPath(int index, Size size, {double inset = 0.0}) {
    final double w = size.width;
    final double h = size.height;
    final path = Path();
    
    // Simple vertical split at w/2
    double topY = inset;
    double botY = h - inset;
    
    if (index == 0) {
      path.moveTo(inset, topY);
      path.lineTo(w * 0.5 - inset, topY);
      path.lineTo(w * 0.5 - inset, botY);
      path.lineTo(inset, botY);
    } else {
      path.moveTo(w * 0.5 + inset, topY);
      path.lineTo(w - inset, topY);
      path.lineTo(w - inset, botY);
      path.lineTo(w * 0.5 + inset, botY);
    }
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) => getPath(index, size, inset: inset);

  @override
  bool shouldReclip(MagazineSpreadClipper old) => old.index != index || old.inset != inset;
}
