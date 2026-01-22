import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SafeHeartCollage extends StatefulWidget {
  const SafeHeartCollage({super.key});

  @override
  State<SafeHeartCollage> createState() => _SafeHeartCollageState();
}

class _SafeHeartCollageState extends State<SafeHeartCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() { images[index] = File(picked.path); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenW = constraints.maxWidth;
            final double centerSize = screenW * 0.70;
            final double cornerSize = screenW * 0.40;

            return Stack(
              children: [
                // Corner Hearts
                Positioned(top: 10, left: 10, child: _buildHeartCell(1, cornerSize, math.pi / 4)),
                Positioned(top: 10, right: 10, child: _buildHeartCell(2, cornerSize, -math.pi / 4)),
                Positioned(bottom: 10, left: 10, child: _buildHeartCell(3, cornerSize, 3 * math.pi / 4)),
                Positioned(bottom: 10, right: 10, child: _buildHeartCell(4, cornerSize, -3 * math.pi / 4)),
                
                // Big Center Heart
                Center(child: _buildHeartCell(0, centerSize, 0, isHero: true)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeartCell(int index, double size, double angle, {bool isHero = false}) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // THE MASK: Using ClipPath here locks the image inside
            ClipPath(
              clipper: ClassicHeartClipper(),
              child: Container(
                width: size,
                height: size,
                color: Colors.white10,
                child: images[index] == null
                    ? GestureDetector(
                        onTap: () => pickImage(index),
                        child: Center(
                          child: Transform.rotate(
                            angle: -angle, // Keep '+' icon upright
                            child: const Icon(Icons.add, color: Colors.white, size: 40),
                          ),
                        ),
                      )
                    : InteractiveViewer(
                        // CLIP BEHAVIOR IS KEY: Set to hardEdge to prevent bleeding
                        clipBehavior: Clip.hardEdge,
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        minScale: 0.1,
                        maxScale: 5.0,
                        child: Transform.rotate(
                          angle: -angle, // Keep the photo upright
                          child: Image.file(
                            images[index]!,
                            fit: BoxFit.cover,
                            width: size,
                            height: size,
                          ),
                        ),
                      ),
              ),
            ),
            // THE BORDER: Matches the ClipPath exactly
            IgnorePointer(
              child: CustomPaint(
                size: Size(size, size),
                painter: HeartBorderPainter(thickness: isHero ? 4.0 : 2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CLIPPING & BORDER LOGIC ---

Path _getClassicHeartPath(Size size) {
  Path path = Path();
  final double w = size.width;
  final double h = size.height;
  path.moveTo(w * 0.5, h * 0.9);
  path.cubicTo(w * -0.05, h * 0.60, w * 0.05, h * 0.15, w * 0.5, h * 0.35);
  path.cubicTo(w * 0.95, h * 0.15, w * 1.05, h * 0.60, w * 0.5, h * 0.9);
  path.close();
  return path;
}

class ClassicHeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getClassicHeartPath(size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeartBorderPainter extends CustomPainter {
  final double thickness;
  HeartBorderPainter({required this.thickness});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _getClassicHeartPath(size),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round,
    );
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
  
}