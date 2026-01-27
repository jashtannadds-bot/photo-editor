import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FlowerCollageScreen extends StatefulWidget {
  const FlowerCollageScreen({super.key});

  @override
  State<FlowerCollageScreen> createState() => _FlowerCollageScreenState();
}

class _FlowerCollageScreenState extends State<FlowerCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(6, null); // 0 = Center, 1-5 = Petals

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => images[index] = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.9;
    final double centerSize = size * 0.35;
    final double petalSize = size * 0.32;
    final double radius = size * 0.28; // Distance of petals from center

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Draw 5 Petals using Math (Sin/Cos for perfect placement)
              ...List.generate(5, (index) {
                double angle = (index * 72) * (math.pi / 180);
                return Positioned(
                  left: (size / 2) + radius * math.cos(angle) - (petalSize / 2),
                  top: (size / 2) + radius * math.sin(angle) - (petalSize / 2),
                  child: _buildCircle(index + 1, petalSize),
                );
              }),

              // Center Core
              _buildCircle(0, centerSize),

              // Seamless Border Overlay
              IgnorePointer(
                child: CustomPaint(
                  size: Size(size, size),
                  painter: FlowerBorderPainter(radius: radius, centerSize: centerSize, petalSize: petalSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(int index, double d) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: ClipOval(
        child: Container(
          width: d, height: d,
          color: const Color(0xFF1A1A1A),
          child: images[index] == null
              ? const Icon(Icons.add, color: Colors.white24, size: 20)
              : InteractiveViewer(child: Image.file(images[index]!, fit: BoxFit.cover)),
        ),
      ),
    );
  }
}

class FlowerBorderPainter extends CustomPainter {
  final double radius, centerSize, petalSize;
  FlowerBorderPainter({required this.radius, required this.centerSize, required this.petalSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Add Center
    path.addOval(Rect.fromCircle(center: center, radius: centerSize / 2));

    // Add Petals to the same path to fuse them
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72) * (math.pi / 180);
      Offset petalCenter = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      path.addOval(Rect.fromCircle(center: petalCenter, radius: petalSize / 2));
    }

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}