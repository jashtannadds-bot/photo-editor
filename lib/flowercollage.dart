import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class FlowerCollageScreen extends StatefulWidget {
  const FlowerCollageScreen({super.key});

  @override
  State<FlowerCollageScreen> createState() => _FlowerCollageScreenState();
}

class _FlowerCollageScreenState extends State<FlowerCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(6, null);
  final GlobalKey _flowerKey = GlobalKey();

  // 1. Unified Style Initialization
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 3.0,
      activeBackground: appBackgrounds[0],
    );
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => images[index] = File(picked.path));
  }

  void resetCollage() {
    setState(() {
      images = List.filled(6, null);
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 3.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.95;
    final double centerSize = size * 0.35;
    final double petalSize = size * 0.32;
    final double radius = size * 0.28;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "FLORAL FUSION",
          style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white70),
        ),
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
                key: _flowerKey,
                child: Container(
                  width: size,
                  height: size,
                  // 2. Applying dynamic background
                  decoration: myStyle.activeBackground.decoration,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Draw 5 Petals
                      ...List.generate(5, (index) {
                        double angle = (index * 72) * (math.pi / 180);
                        return Positioned(
                          left: (size / 2) +
                              radius * math.cos(angle) -
                              (petalSize / 2),
                          top: (size / 2) +
                              radius * math.sin(angle) -
                              (petalSize / 2),
                          child: _buildCircle(index + 1, petalSize),
                        );
                      }),

                      // Center Core
                      _buildCircle(0, centerSize),

                      // 3. Seamless Dynamic Border Overlay
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(size, size),
                          painter: FlowerBorderPainter(
                            radius: radius,
                            centerSize: centerSize,
                            petalSize: petalSize,
                            color: myStyle.borderColor,
                            width: myStyle.borderWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Integrated Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_flowerKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("SAVE COLLAGE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 5. Shared Control Panel
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

  Widget _buildCircle(int index, double d) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: ClipOval(
        child: Container(
          width: d,
          height: d,
          color: const Color(0xFF151515).withOpacity(0.5),
          child: images[index] == null
              ? Icon(
                  Icons.add,
                  color: myStyle.borderColor.withOpacity(0.3),
                  size: 20,
                )
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(images[index]!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

// --- UPDATED DYNAMIC PAINTER ---
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

    // Outer Glow for the floral path
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(FlowerBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}