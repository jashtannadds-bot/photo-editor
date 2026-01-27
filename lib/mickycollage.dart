import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MickeyFinalDesign extends StatefulWidget {
  const MickeyFinalDesign({super.key});

  @override
  State<MickeyFinalDesign> createState() => _MickeyFinalDesignState();
}

class _MickeyFinalDesignState extends State<MickeyFinalDesign> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(3, null);

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images[index] = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double canvasSize = MediaQuery.of(context).size.width * 0.95;
    
    // Proportions for the "Classic" look
    final double headSize = canvasSize * 0.62;
    final double earSize = canvasSize * 0.35;
    
    // Positioning the head
    final double headX = (canvasSize - headSize) / 2;
    final double headY = canvasSize * 0.32; 

    // Positioning ears to just "kiss" the head without deep overlap
    final double earY = headY - (earSize * 0.75); 

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: canvasSize,
          height: canvasSize,
          child: Stack(
            children: [
              /// 1. THE IMAGE TILES (No Individual Borders)
              // Left Ear
              Positioned(
                top: earY,
                left: canvasSize * 0.05,
                child: _buildCircle(1, earSize),
              ),
              // Right Ear
              Positioned(
                top: earY,
                right: canvasSize * 0.05,
                child: _buildCircle(2, earSize),
              ),
              // Head
              Positioned(
                top: headY,
                left: headX,
                child: _buildCircle(0, headSize),
              ),

              /// 2. THE FUSED BORDER (Removes the internal intersection lines)
              IgnorePointer(
                child: CustomPaint(
                  size: Size(canvasSize, canvasSize),
                  painter: MickeyFusedBorderPainter(
                    headRect: Rect.fromLTWH(headX, headY, headSize, headSize),
                    leftEarRect: Rect.fromLTWH(canvasSize * 0.05, earY, earSize, earSize),
                    rightEarRect: Rect.fromLTWH(canvasSize - earSize - (canvasSize * 0.05), earY, earSize, earSize),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(int index, double diameter) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: ClipOval(
        child: Container(
          width: diameter,
          height: diameter,
          color: const Color(0xFF121212),
          child: images[index] == null
              ? const Icon(Icons.add_a_photo_outlined, color: Colors.white24)
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1,
                  child: Image.file(images[index]!, fit: BoxFit.contain),
                ),
        ),
      ),
    );
  }
}

class MickeyFusedBorderPainter extends CustomPainter {
  final Rect headRect;
  final Rect leftEarRect;
  final Rect rightEarRect;

  MickeyFusedBorderPainter({
    required this.headRect,
    required this.leftEarRect,
    required this.rightEarRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // We combine all ovals into ONE path
    final Path fusedPath = Path()
      ..addOval(headRect)
      ..addOval(leftEarRect)
      ..addOval(rightEarRect);

    // DRAWING THE GLOW
    final Paint glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // DRAWING THE SHARP BORDER
    // Because we draw the 'fusedPath' as a single stroke, 
    // any lines INSIDE the shape are automatically ignored by Flutter.
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fusedPath, glowPaint);
    canvas.drawPath(fusedPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}