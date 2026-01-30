import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class HangingBulbCollage extends StatefulWidget {
  const HangingBulbCollage({super.key});

  @override
  State<HangingBulbCollage> createState() => _HangingBulbCollageState();
}

class _HangingBulbCollageState extends State<HangingBulbCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _saveKey = GlobalKey();

  // 1. Unified Style Initialization
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: const Color(0xFFF4EBD0), // Vintage Cream default
      borderWidth: 6.0,
      activeBackground: appBackgrounds[0],
    );
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => images[index] = File(picked.path));
  }

  void resetCollage() {
    setState(() {
      images = List.filled(5, null);
      myStyle.borderColor = const Color(0xFFF4EBD0);
      myStyle.borderWidth = 6.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "BOUTIQUE CUSTOM",
          style: TextStyle(fontSize: 10, letterSpacing: 5, color: Colors.amberAccent),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: resetCollage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _saveKey,
              child: Container(
                // 2. Applying Shared Background (The "Wall")
                decoration: myStyle.activeBackground.decoration,
                child: Stack(
                  children: [
                    // Lighting and String Painter
                    CustomPaint(
                      size: Size(size.width, size.height),
                      painter: BulbStringPainter(accentColor: myStyle.borderColor),
                    ),
                    
                    // The Hanging Photos
                    _hangingPhoto(0, top: 100, left: size.width * 0.04, angle: -0.06),
                    _hangingPhoto(1, top: 125, left: size.width * 0.36, angle: 0.04),
                    _hangingPhoto(2, top: 100, left: size.width * 0.68, angle: -0.04),
                    _hangingPhoto(3, top: 400, left: size.width * 0.12, angle: 0.05),
                    _hangingPhoto(4, top: 410, left: size.width * 0.55, angle: -0.06),
                  ],
                ),
              ),
            ),
          ),

          // 3. Shared Control Panel
          CollageControlPanel(
            style: myStyle,
            onColorChanged: (newColor) => setState(() => myStyle.borderColor = newColor),
            onWidthChanged: (newWidth) => setState(() => myStyle.borderWidth = newWidth),
            onBackgroundChanged: (newBg) => setState(() => myStyle.activeBackground = newBg),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => CollageHelper.saveCollage(_saveKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("EXPORT BOUTIQUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hangingPhoto(int index, {required double top, required double left, double angle = 0}) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: angle,
        child: Column(
          children: [
            // The Wooden Clip
            Container(
              width: 8,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF795548),
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
            // The Polaroid Frame
            Container(
              width: 115,
              padding: EdgeInsets.fromLTRB(
                myStyle.borderWidth,
                myStyle.borderWidth,
                myStyle.borderWidth,
                myStyle.borderWidth * 4.5, // Dynamic bottom margin for Polaroid effect
              ),
              decoration: BoxDecoration(
                color: myStyle.borderColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(6, 6),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: const Color(0xFF0A0A0A),
                  child: images[index] == null
                      ? InkWell(
                          onTap: () => pickImage(index),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.amber.withOpacity(0.2),
                            size: 30,
                          ),
                        )
                      : InteractiveViewer(
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(images[index]!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BulbStringPainter extends CustomPainter {
  final Color accentColor;
  BulbStringPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final bulbGlow = Paint()
      ..color = Colors.amber.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final bulbCore = Paint()..color = Colors.amberAccent.withOpacity(0.8);

    _drawRow(canvas, size, 90, 150, [0.34, 0.66], bulbGlow, bulbCore, stringPaint);
    _drawRow(canvas, size, 390, 450, [0.48], bulbGlow, bulbCore, stringPaint);
  }

  void _drawRow(Canvas canvas, Size size, double startY, double ctrlY, List<double> bulbPositions, Paint glow, Paint core, Paint string) {
    Path path = Path();
    path.moveTo(0, startY);
    path.quadraticBezierTo(size.width / 2, ctrlY, size.width, startY);
    canvas.drawPath(path, string);

    for (double t in bulbPositions) {
      double x = size.width * t;
      double y = (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * ctrlY + t * t * startY;

      canvas.drawLine(Offset(x, y), Offset(x, y + 20), Paint()..color = Colors.white10);
      canvas.drawCircle(Offset(x, y + 28), 14, glow);
      canvas.drawCircle(Offset(x, y + 28), 3.5, core);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}