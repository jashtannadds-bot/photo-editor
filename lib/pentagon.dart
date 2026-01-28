import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collageimagehelper.dart';
// import 'collage_helper.dart'; // Ensure your helper file is imported

class PuzzleCollageScreen extends StatefulWidget {
  const PuzzleCollageScreen({super.key});

  @override
  State<PuzzleCollageScreen> createState() => _PuzzleCollageScreenState();
}

class _PuzzleCollageScreenState extends State<PuzzleCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);

  // 1. Define the GlobalKey for capturing
  final GlobalKey _puzzleKey = GlobalKey();

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
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.pinkAccent,
          tooltip: 'Save Collage',
          onPressed: () => CollageHelper.saveCollage(_puzzleKey, context),
          label: const Text("Save"),
          icon: const Icon(Icons.download_rounded),
        ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Geometric Puzzle", style: TextStyle(color: Colors.white, fontSize: 16)),
        // 2. Add Save Button to Actions
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download_done_rounded, color: Colors.white),
          //   onPressed: () => CollageHelper.saveCollage(_puzzleKey, context),
          // ),
          // const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          
          // 3. Wrap the main collage area with RepaintBoundary
          RepaintBoundary(
            key: _puzzleKey,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), // Ensures background is saved
                  border: Border.all(color: Colors.white, width: 2),
                ),
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
                        
                        // CENTER PENTAGON
                        Center(child: _buildPentagonCenter(0, s * 0.5)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSlot(int index, Rect relativeRect, double totalSize) {
    return Positioned(
      top: relativeRect.top * totalSize,
      left: relativeRect.left * totalSize,
      width: (relativeRect.width * totalSize) - 2, 
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
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
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
          ClipPath(
            clipper: PentagonClipper(),
            child: Container(
              width: size,
              height: size,
              color: Colors.black,
              child: images[index] == null
                  ? GestureDetector(
                      onTap: () => pickImage(index),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.white, size: 40),
                      ),
                    )
                  : InteractiveViewer(
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

// --- GEOMETRY CLASSES REMAIN THE SAME ---

class PentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    path.moveTo(w * 0.5, 0); 
    path.lineTo(w, h * 0.38); 
    path.lineTo(w * 0.81, h); 
    path.lineTo(w * 0.19, h); 
    path.lineTo(0, h * 0.38); 
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