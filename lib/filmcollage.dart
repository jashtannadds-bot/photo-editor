import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuraCollageScreen extends StatefulWidget {
  const AuraCollageScreen({super.key});

  @override
  State<AuraCollageScreen> createState() => _AuraCollageScreenState();
}

class _AuraCollageScreenState extends State<AuraCollageScreen> {
  final ImagePicker picker = ImagePicker();
  // 5 frames for a long film strip
  List<File?> images = List.filled(5, null);

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(
        () => images[index] = File(picked.path)
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                itemBuilder: (context, index) => _buildFilmFrame(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmFrame(int index) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 15),
      child: Stack(
        children: [
          // 1. THE IMAGE LAYER (Drag & Zoom enabled)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
            ), // Space for film holes
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

          // 2. THE FILM STRIP BORDER (Sprocket Holes)
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

/// --- PAINTS THE FILM PERFORATIONS ---
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

    // Draw sprocket holes on left and right sides
    for (double i = 10; i < size.height; i += 25) {
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
          Rect.fromLTWH(
            size.width - padding - holeWidth,
            i,
            holeWidth,
            holeHeight,
          ),
          const Radius.circular(2),
        ),
        holePaint,
      );
    }

    // Draw subtle frame border
    canvas.drawRect(
      Rect.fromLTWH(40, 0, size.width - 80, size.height),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
