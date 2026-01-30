import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class AuraCollageScreen extends StatefulWidget {
  const AuraCollageScreen({super.key});

  @override
  State<AuraCollageScreen> createState() => _AuraCollageScreenState();
}

class _AuraCollageScreenState extends State<AuraCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _auraKey = GlobalKey();

  // 1. Unified Style Initialization
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.orangeAccent, // Kodak Classic Default
      borderWidth: 1.0,
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
      myStyle.borderColor = Colors.orangeAccent;
      myStyle.borderWidth = 1.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "AURA FILM STRIP",
          style: TextStyle(
            fontSize: 10, 
            letterSpacing: 4, 
            color: myStyle.borderColor.withOpacity(0.7)
          ),
        ),
        centerTitle: true,
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: RepaintBoundary(
                key: _auraKey,
                child: Container(
                  // 2. Dynamic Background from Shared Style
                  decoration: myStyle.activeBackground.decoration,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        "NEGATIVE // ISO 400",
                        style: TextStyle(
                          color: myStyle.borderColor,
                          letterSpacing: 8,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(5, (index) => _buildFilmFrame(index)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Control Panel Integration
          CollageControlPanel(
            style: myStyle,
            onColorChanged: (newColor) => setState(() => myStyle.borderColor = newColor),
            onWidthChanged: (newWidth) => setState(() => myStyle.borderWidth = newWidth),
            onBackgroundChanged: (newBg) => setState(() => myStyle.activeBackground = newBg),
          ),
          
          // Save Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.pinkAccent,
              onPressed: () => CollageHelper.saveCollage(_auraKey, context),
              label: const Text("SAVE ROLL", style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.camera_roll, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmFrame(int index) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: Stack(
        children: [
          // The Image Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: myStyle.borderColor.withOpacity(0.2), width: 0.5),
              ),
              child: images[index] == null
                  ? GestureDetector(
                      onTap: () => pickImage(index),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: myStyle.borderColor.withOpacity(0.2),
                          size: 32,
                        ),
                      ),
                    )
                  : InteractiveViewer(
                      clipBehavior: Clip.hardEdge,
                      child: GestureDetector(
                        onDoubleTap: () => pickImage(index),
                        child: Image.file(
                          images[index]!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
            ),
          ),

          // 4. Custom Painter for Film Details
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: FilmStripPainter(
                accentColor: myStyle.borderColor,
                strokeWidth: myStyle.borderWidth,
              ),
            ),
          ),

          // Frame Numbering
          Positioned(
            left: 20,
            bottom: 12,
            child: Text(
              "0${index + 1}A",
              style: TextStyle(
                color: myStyle.borderColor.withOpacity(0.8), 
                fontSize: 8,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace'
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

    // Draw Sprocket Holes (Top and Bottom of the strip)
    for (double i = 10; i < size.height; i += 28) {
      // Left Holes
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(padding, i, holeWidth, holeHeight),
          const Radius.circular(2),
        ),
        holePaint,
      );
      // Right Holes
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - padding - holeWidth, i, holeWidth, holeHeight),
          const Radius.circular(2),
        ),
        holePaint,
      );
    }

    // Inner frame border (Around the image area)
    canvas.drawRect(
      Rect.fromLTWH(45, 0, size.width - 90, size.height),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(FilmStripPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strokeWidth != strokeWidth;
}