import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PuzzleCollageScreen extends StatefulWidget {
  const PuzzleCollageScreen({super.key});

  @override
  State<PuzzleCollageScreen> createState() => _PuzzleCollageScreenState();
}

class _PuzzleCollageScreenState extends State<PuzzleCollageScreen> {
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
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
       
      ),
      body: Column(
        children: [
          const Spacer(),
          // MAIN COLLAGE AREA
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double s = constraints.maxWidth;
                  return Stack(
                    children: [
                      // Background Slots
                      _buildSlot(1, const Rect.fromLTWH(0, 0, 0.5, 0.5), s), // Top Left
                      _buildSlot(2, const Rect.fromLTWH(0.5, 0, 0.5, 0.5), s), // Top Right
                      _buildSlot(3, const Rect.fromLTWH(0, 0.5, 0.5, 0.5), s), // Bottom Left
                      _buildSlot(4, const Rect.fromLTWH(0.5, 0.5, 0.5, 0.5), s), // Bottom Right
                      
                      // CENTER PENTAGON (The hero piece)
                      Center(child: _buildPentagonCenter(0, s * 0.5)),
                    ],
                  );
                },
              ),
            ),
          ),
          const Spacer(),
          // Bottom Navigation Placeholder
         
        ],
      ),
    );
  }

  // Helper for the square background slots
  Widget _buildSlot(int index, Rect relativeRect, double totalSize) {
    return Positioned(
      top: relativeRect.top * totalSize,
      left: relativeRect.left * totalSize,
      width: (relativeRect.width * totalSize) - 2, // Tiny gap for border
      height: (relativeRect.height * totalSize) - 2,
      child: _buildImageCell(index),
    );
  }

  Widget _buildImageCell(int index) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
      child: images[index] == null
          ? GestureDetector(
              onTap: () => pickImage(index),
              child: const Center(child: Icon(Icons.add, color: Colors.white70, size: 30)),
            )
          : InteractiveViewer(
              clipBehavior: Clip.hardEdge,
              child: Image.file(images[index]!, fit: BoxFit.cover),
            ),
    );
  }

  Widget _buildPentagonCenter(int index, double size) {
  return SizedBox(
    width: size,
    height: size,
    child: Stack(
      children: [
        // 1. THE MASK (ClipPath) - This cuts the image into a Pentagon
        ClipPath(
          clipper: PentagonClipper(),
          child: Container(
            width: size,
            height: size,
            color: Colors.black, // Background color for empty slot
            child: images[index] == null
                ? GestureDetector(
                    onTap: () => pickImage(index),
                    child: const Center(
                      child: Icon(Icons.add, color: Colors.white, size: 40),
                    ),
                  )
                : InteractiveViewer(
                    // Important: hardEdge ensures the image is clipped while zooming
                    clipBehavior: Clip.hardEdge, 
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.1,
                    maxScale: 5.0,
                    child: Image.file(
                      images[index]!,
                      fit: BoxFit.cover,
                      width: size,
                      height: size,
                    ),
                  ),
          ),
        ),
        
        // 2. THE BORDER - This draws the white frame on top
        IgnorePointer(
          child: CustomPaint(
            size: Size(size, size),
            painter: PentagonBorderPainter(),
          ),
        ),
      ],
    ),
  );
}
 
}

// --- GEOMETRY FOR PENTAGON ---

class PentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    path.moveTo(w * 0.5, 0); // Top Point
    path.lineTo(w, h * 0.38); // Top Right
    path.lineTo(w * 0.81, h); // Bottom Right
    path.lineTo(w * 0.19, h); // Bottom Left
    path.lineTo(0, h * 0.38); // Top Left
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PentagonBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    Path path = Path();
    double w = size.width;
    double h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.38);
    path.lineTo(w * 0.81, h);
    path.lineTo(w * 0.19, h);
    path.lineTo(0, h * 0.38);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}