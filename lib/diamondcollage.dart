import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collageimagehelper.dart';
// import 'collage_helper.dart'; // Ensure this file exists in your project

class ProCameraLensCollage extends StatefulWidget {
  const ProCameraLensCollage({super.key});

  @override
  State<ProCameraLensCollage> createState() => _ProCameraLensCollageState();
}

class _ProCameraLensCollageState extends State<ProCameraLensCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.generate(5, (_) => null);
  final GlobalKey _lensKey = GlobalKey();

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images[index] = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        tooltip: 'Save Collage',
        onPressed: () => CollageHelper.saveCollage(_lensKey, context),
        label: const Text("Save"),
        icon: const Icon(Icons.download_rounded),
      ),
      appBar: AppBar(
        title: const Text("LENS COLLAGE", 
          style: TextStyle(letterSpacing: 4, fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download_rounded, color: Colors.white),
          //   onPressed: () {
          //     // CollageHelper.saveCollage(_lensKey, context);
          //   },
          // ),
          // const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _lensKey,
          child: Container(
            width: size,
            height: size,
            color: const Color(0xFF0A0A0A),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size * 0.9,
                  height: size * 0.9,
                  child: ClipOval(
                    child: Stack(
                      children: List.generate(5, (index) {
                        return ClipPath(
                          clipper: MechanicalShutterClipper(index),
                          child: GestureDetector(
                            onLongPress: () => pickImage(index),
                            child: Container(
                              color: index % 2 == 0 ? const Color(0xFF151515) : const Color(0xFF1A1A1A),
                              child: images[index] == null
                                  ? InkWell(
                                      onTap: () => pickImage(index),
                                      child: const Center(
                                        child: Icon(Icons.add_a_photo_outlined, color: Colors.white24, size: 30),
                                      ),
                                    )
                                  : InteractiveViewer(
                                      clipBehavior: Clip.none,
                                      boundaryMargin: const EdgeInsets.all(double.infinity),
                                      minScale: 0.1,
                                      maxScale: 5.0,
                                      child: Image.file(
                                        images[index]!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(size * 0.9, size * 0.9),
                    painter: ShutterEdgePainter(),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: LensBarrelPainter(),
                  ),
                ),
                IgnorePointer(
                  child: Container(
                    width: size * 0.9,
                    height: size * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.cyanAccent.withOpacity(0.05),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- THE MISSING CLASSES ---

class MechanicalShutterClipper extends CustomClipper<Path> {
  final int index;
  MechanicalShutterClipper(this.index);

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    double angleStart = (index * 72 - 90) * (math.pi / 180);
    double angleEnd = ((index + 1) * 72 - 90) * (math.pi / 180);
    double innerR = 20.0;
    Offset p1 = Offset(center.dx + r * math.cos(angleStart), center.dy + r * math.sin(angleStart));
    Offset p2 = Offset(center.dx + r * math.cos(angleEnd), center.dy + r * math.sin(angleEnd));
    Offset h1 = Offset(center.dx + innerR * math.cos(angleStart), center.dy + innerR * math.sin(angleStart));
    path.moveTo(h1.dx, h1.dy);
    path.quadraticBezierTo(
      center.dx + r * 0.5 * math.cos(angleStart + 0.5), 
      center.dy + r * 0.5 * math.sin(angleStart + 0.5), 
      p1.dx, p1.dy
    );
    path.lineTo(p2.dx, p2.dy);
    path.quadraticBezierTo(
      center.dx + r * 0.4 * math.cos(angleEnd - 0.5), 
      center.dy + r * 0.4 * math.sin(angleEnd - 0.5), 
      h1.dx, h1.dy
    );
    path.close();
    return path;
  }
  @override bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LensBarrelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    final Paint metalPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF444444), Color(0xFF111111)],
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;
    canvas.drawCircle(center, r - 6, metalPaint);
    final Paint markingPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5;
    for (int i = 0; i < 360; i += 5) {
      double angle = i * (math.pi / 180);
      double lineLen = (i % 30 == 0) ? 12 : 5;
      canvas.drawLine(
        Offset(center.dx + (r - 15) * math.cos(angle), center.dy + (r - 15) * math.sin(angle)),
        Offset(center.dx + (r - 15 - lineLen) * math.cos(angle), center.dy + (r - 15 - lineLen) * math.sin(angle)),
        markingPaint,
      );
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ShutterEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint edgePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72 - 90) * (math.pi / 180);
      final Path path = Path();
      Offset innerPoint = Offset(center.dx + 20 * math.cos(angle), center.dy + 20 * math.sin(angle));
      path.moveTo(innerPoint.dx, innerPoint.dy);
      path.quadraticBezierTo(
        center.dx + r * 0.5 * math.cos(angle + 0.5), 
        center.dy + r * 0.5 * math.sin(angle + 0.5), 
        center.dx + r * math.cos(angle), 
        center.dy + r * math.sin(angle)
      );
      canvas.drawPath(path, edgePaint);
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}