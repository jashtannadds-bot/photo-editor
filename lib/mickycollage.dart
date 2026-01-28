import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collageimagehelper.dart';
// import 'collage_helper.dart'; // Ensure your helper file is imported

class MickeyFinalDesign extends StatefulWidget {
  const MickeyFinalDesign({super.key});

  @override
  State<MickeyFinalDesign> createState() => _MickeyFinalDesignState();
}

class _MickeyFinalDesignState extends State<MickeyFinalDesign> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(3, null);

  // 1. Create the Key for capturing
  final GlobalKey _mickeyKey = GlobalKey();

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images[index] = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double canvasSize = MediaQuery.of(context).size.width * 0.95;
    
    final double headSize = canvasSize * 0.62;
    final double earSize = canvasSize * 0.35;
    
    final double headX = (canvasSize - headSize) / 2;
    final double headY = canvasSize * 0.32; 
    final double earY = headY - (earSize * 0.75); 

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        tooltip: 'Save Collage',
        onPressed: () => CollageHelper.saveCollage(_mickeyKey, context),
        label: const Text("Save"),
        icon: const Icon(Icons.download_rounded),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Fused Silhouette", style: TextStyle(color: Colors.white, fontSize: 16)),
        // 2. Add Save Button
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download_for_offline, color: Colors.white),
          //   onPressed: () => CollageHelper.saveCollage(_mickeyKey, context),
          // ),
          // const SizedBox(width: 10),
        ],
      ),
      body: Center(
        // 3. Wrap the specific collage area
        child: RepaintBoundary(
          key: _mickeyKey,
          child: Container(
            width: canvasSize,
            height: canvasSize,
            color: Colors.black, // Ensures the background is captured
            child: Stack(
              children: [
                /// 1. THE IMAGE TILES
                Positioned(
                  top: earY,
                  left: canvasSize * 0.05,
                  child: _buildCircle(1, earSize),
                ),
                Positioned(
                  top: earY,
                  right: canvasSize * 0.05,
                  child: _buildCircle(2, earSize),
                ),
                Positioned(
                  top: headY,
                  left: headX,
                  child: _buildCircle(0, headSize),
                ),

                /// 2. THE FUSED BORDER
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(canvasSize, canvasSize),
                    painter: MickeyFusedBorderPainter(
                      headRect: Rect.fromLTWH(headX, headY, headSize, headSize),
                      leftEarRect: Rect.fromLTWH(canvasSize * 0.05, earY, earSize, earSize),
                      rightEarRect: Rect.fromLTWH(canvasSize - earSize - (canvasSize * 0.05), earY, earSize, earSize),
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

  Widget _buildCircle(int index, double diameter) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: ClipOval(
        child: Container(
          width: diameter,
          height: diameter,
          color: const Color(0xFF121212),
          child: images[index] == null
              ? const Icon(Icons.add_a_photo_outlined, color: Colors.white24)
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1,
                  maxScale: 5.0,
                  child: Image.file(images[index]!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

class MickeyFusedBorderPainter extends CustomPainter {
  final Rect headRect;
  final Rect leftEarRect;
  final Rect rightEarRect;

  MickeyFusedBorderPainter({
    required this.headRect,
    required this.leftEarRect,
    required this.rightEarRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path fusedPath = Path()
      ..addOval(headRect)
      ..addOval(leftEarRect)
      ..addOval(rightEarRect);

    final Paint glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fusedPath, glowPaint);
    canvas.drawPath(fusedPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}