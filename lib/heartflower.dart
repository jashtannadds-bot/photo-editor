import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PerfectHeartClover extends StatefulWidget {
  const PerfectHeartClover({super.key});

  @override
  State<PerfectHeartClover> createState() => _PerfectHeartCloverState();
}

class _PerfectHeartCloverState extends State<PerfectHeartClover> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(4, null);
  List<ui.Image?> decodedImages = List.filled(4, null);

  // Pick and decode image to use with CustomPainter
  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final data = await picked.readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      setState(() {
        images[index] = File(picked.path);
        decodedImages[index] = frame.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double size = math.min(constraints.maxWidth, constraints.maxHeight);
          final double petalSize = size * 0.40;

          return Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                children: [
                  _buildPetal(0, petalSize, -math.pi / 4, const Offset(-0.45, -0.45)),
                  _buildPetal(1, petalSize, math.pi / 4, const Offset(0.45, -0.45)),
                  _buildPetal(2, petalSize, -3 * math.pi / 4, const Offset(-0.45, 0.45)),
                  _buildPetal(3, petalSize, 3 * math.pi / 4, const Offset(0.45, 0.45)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetal(int index, double size, double angle, Offset offset) {
    return Align(
      alignment: Alignment(offset.dx, offset.dy),
      child: GestureDetector(
        onTap: () => pickImage(index),
        child: SizedBox(
          width: size,
          height: size,
          child: Transform.rotate(
            angle: angle,
            child: CustomPaint(
              painter: HeartPetalPainter(
                image: decodedImages[index],
                rotationAngle: angle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeartPetalPainter extends CustomPainter {
  final ui.Image? image;
  final double rotationAngle;

  HeartPetalPainter({this.image, required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _getHeartPath(size);
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()..color = Colors.grey.shade900;

    // 1. Draw Background
    canvas.drawPath(path, fillPaint);

    // 2. Clip and Draw Image
    if (image != null) {
      canvas.save();
      canvas.clipPath(path);
      
      // Un-rotate the canvas so the image draws upright
      final center = Offset(size.width / 2, size.height / 2);
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-rotationAngle);
      canvas.translate(-center.dx, -center.dy);

      // Draw the image to fit the heart
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: image!,
        fit: BoxFit.cover,
      );
      canvas.restore();
    }

    // 3. Draw Border LAST (Ensures it's always on top and matches exactly)
    canvas.drawPath(path, borderPaint);
  }

  Path _getHeartPath(Size size) {
    final double w = size.width;
    final double h = size.height;
    Path path = Path();
    path.moveTo(w / 2, h * 0.9);
    path.cubicTo(w * 0.05, h * 0.6, w * -0.1, h * 0.15, w / 2, h * 0.28);
    path.cubicTo(w * 1.1, h * 0.15, w * 0.95, h * 0.6, w / 2, h * 0.9);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant HeartPetalPainter oldDelegate) => 
      oldDelegate.image != image;
}