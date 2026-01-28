import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collageimagehelper.dart';
// import 'collage_helper.dart'; // Ensure your helper is in your project

class AuraCollageScreen extends StatefulWidget {
  const AuraCollageScreen({super.key});

  @override
  State<AuraCollageScreen> createState() => _AuraCollageScreenState();
}

class _AuraCollageScreenState extends State<AuraCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  
  // 1. Define the GlobalKey for capturing
  final GlobalKey _auraKey = GlobalKey();

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images[index] = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        tooltip: 'Save Collage',  
        onPressed: () => CollageHelper.saveCollage(_auraKey, context),
        label: const Text("Save"),
        icon: const Icon(Icons.download_rounded),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          // 2. Save Button
          // IconButton(
          //   icon: const Icon(Icons.save_alt_rounded, color: Colors.orangeAccent),
          //   onPressed: () => CollageHelper.saveCollage(_auraKey, context),
          // ),
          // const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        // 3. Wrap the content in RepaintBoundary for full-length capture
        child: SingleChildScrollView(
          child: RepaintBoundary(
            key: _auraKey,
            child: Container(
              color: const Color(0xFF050505), // Background for the export
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "NEGATIVE // ISO 400",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        letterSpacing: 4,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Build all 5 frames in a Column instead of ListView 
                  // to ensure the RepaintBoundary captures everything.
                  ...List.generate(5, (index) => _buildFilmFrame(index)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilmFrame(int index) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
      child: Stack(
        children: [
          // 1. THE IMAGE LAYER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: images[index] == null
                  ? GestureDetector(
                      onTap: () => pickImage(index),
                      child: const Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white10,
                          size: 40,
                        ),
                      ),
                    )
                  : InteractiveViewer(
                      clipBehavior: Clip.hardEdge,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: 0.1,
                      maxScale: 5.0,
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

          // 2. THE FILM STRIP BORDER
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: FilmStripPainter(),
            ),
          ),

          // 3. FRAME NUMBERING
          Positioned(
            left: 10,
            bottom: 10,
            child: Text(
              "0${index + 1}A",
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// --- FILM STRIP PAINTER (Same as your original) ---
class FilmStripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint holePaint = Paint()..color = Colors.black;
    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double holeWidth = 12;
    double holeHeight = 8;
    double padding = 15;

    for (double i = 10; i < size.height; i += 25) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(padding, i, holeWidth, holeHeight),
          const Radius.circular(2),
        ),
        holePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - padding - holeWidth, i, holeWidth, holeHeight),
          const Radius.circular(2),
        ),
        holePaint,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(40, 0, size.width - 80, size.height),
      borderPaint,
    );
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}