import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class ProCameraLensCollage extends StatefulWidget {
  const ProCameraLensCollage({super.key});

  @override
  State<ProCameraLensCollage> createState() => _ProCameraLensCollageState();
}

class _ProCameraLensCollageState extends State<ProCameraLensCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.generate(5, (_) => null);
  final GlobalKey _lensKey = GlobalKey();

  // 1. Unified Style Initialization
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 1.0,
      activeBackground: appBackgrounds[0],
    );
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images[index] = File(picked.path));
    }
  }

  void resetCollage() {
    setState(() {
      images = List.generate(5, (_) => null);
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 1.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "LENS COLLAGE",
          style: TextStyle(letterSpacing: 4, fontSize: 10, color: Colors.white70),
        ),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white60),
            onPressed: resetCollage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _lensKey,
                child: Container(
                  width: size,
                  height: size,
                  // 2. Dynamic Background Decoration
                  decoration: myStyle.activeBackground.decoration,
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
                                  onTap: () => pickImage(index),
                                  child: Container(
                                    color: index % 2 == 0
                                        ? const Color(0xFF151515).withOpacity(0.5)
                                        : const Color(0xFF1A1A1A).withOpacity(0.5),
                                    child: images[index] == null
                                        ? Center(
                                            child: Icon(
                                              Icons.add_a_photo_outlined,
                                              color: myStyle.borderColor.withOpacity(0.2),
                                              size: 30,
                                            ),
                                          )
                                        : InteractiveViewer(
                                            clipBehavior: Clip.none,
                                            child: Image.file(
                                              images[index]!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      // 3. Shutter Blade Edges (Dynamic)
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(size * 0.9, size * 0.9),
                          painter: ShutterEdgePainter(
                            color: myStyle.borderColor,
                            width: myStyle.borderWidth,
                          ),
                        ),
                      ),

                      // 4. Lens Barrel (Dynamic Markings)
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(size, size),
                          painter: LensBarrelPainter(
                            accentColor: myStyle.borderColor,
                          ),
                        ),
                      ),

                      // 5. Glass Reflection Layer (Subtle Gradient)
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
                                myStyle.borderColor.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 6. Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_lensKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("SAVE LENS SHOT", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 7. Integrated Shared Control Panel
          CollageControlPanel(
            style: myStyle,
            onColorChanged: (newColor) => setState(() => myStyle.borderColor = newColor),
            onWidthChanged: (newWidth) => setState(() => myStyle.borderWidth = newWidth),
            onBackgroundChanged: (newBg) => setState(() => myStyle.activeBackground = newBg),
          ),
        ],
      ),
    );
  }
}

// --- UPDATED DYNAMIC PAINTERS ---

class ShutterEdgePainter extends CustomPainter {
  final Color color;
  final double width;
  ShutterEdgePainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint edgePaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;

    for (int i = 0; i < 5; i++) {
      double angle = (i * 72 - 90) * (math.pi / 180);
      final Path path = Path();
      Offset innerPoint = Offset(
        center.dx + 20 * math.cos(angle),
        center.dy + 20 * math.sin(angle),
      );
      path.moveTo(innerPoint.dx, innerPoint.dy);
      path.quadraticBezierTo(
        center.dx + r * 0.5 * math.cos(angle + 0.5),
        center.dy + r * 0.5 * math.sin(angle + 0.5),
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      canvas.drawPath(path, edgePaint);
    }
  }

  @override
  bool shouldRepaint(ShutterEdgePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}

class LensBarrelPainter extends CustomPainter {
  final Color accentColor;
  LensBarrelPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;

    final Paint metalPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF333333), Color(0xFF000000)],
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    
    canvas.drawCircle(center, r - 7, metalPaint);

    final Paint markingPaint = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 360; i += 5) {
      double angle = i * (math.pi / 180);
      double lineLen = (i % 30 == 0) ? 10 : 4;
      canvas.drawLine(
        Offset(center.dx + (r - 14) * math.cos(angle), center.dy + (r - 14) * math.sin(angle)),
        Offset(center.dx + (r - 14 - lineLen) * math.cos(angle), center.dy + (r - 14 - lineLen) * math.sin(angle)),
        markingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LensBarrelPainter oldDelegate) => oldDelegate.accentColor != accentColor;
}

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
    path.quadraticBezierTo(center.dx + r * 0.5 * math.cos(angleStart + 0.5), center.dy + r * 0.5 * math.sin(angleStart + 0.5), p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.quadraticBezierTo(center.dx + r * 0.4 * math.cos(angleEnd - 0.5), center.dy + r * 0.4 * math.sin(angleEnd - 0.5), h1.dx, h1.dy);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}