import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CenterHeartCollageScreen extends StatefulWidget {
  const CenterHeartCollageScreen({super.key});

  @override
  State<CenterHeartCollageScreen> createState() =>
      _CenterHeartCollageScreenState();
}

class _CenterHeartCollageScreenState extends State<CenterHeartCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> gridImages = List.filled(4, null);
  File? heartImage;

  Future<void> pickImage(int index, bool isHeart) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isHeart) {
          heartImage = File(picked.path);
        } else {
          gridImages[index] = File(picked.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double heartSize = MediaQuery.of(context).size.width * 0.92;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// 1. FULL SCREEN BACKGROUND GRID
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildInteractiveTile(0),
                    _buildInteractiveTile(1),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    _buildInteractiveTile(2),
                    _buildInteractiveTile(3),
                  ],
                ),
              ),
            ],
          ),

          /// 2. THE CLASSIC HEART (Sharp & Sleek)
          Center(
            child: SizedBox(
              width: heartSize,
              height: heartSize,
              child: Stack(
                children: [
                  // THE CLIPPED IMAGE
                  ClipPath(
                    clipper: PerfectHeartClipper(),
                    child: Container(
                      width: heartSize,
                      height: heartSize,
                      color: Colors.white.withOpacity(0.15),
                      child: heartImage == null
                          ? GestureDetector(
                              onTap: () => pickImage(0, true),
                              child: const Center(
                                child: Icon(
                                  Icons.favorite,
                                  size: 50,
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onDoubleTap: () => pickImage(0, true),
                              child: InteractiveViewer(
                                clipBehavior: Clip.hardEdge,
                                boundaryMargin: const EdgeInsets.all(
                                  double.infinity,
                                ),
                                minScale: 0.5,
                                maxScale: 5,
                                child: Image.file(
                                  heartImage!,
                                  fit: BoxFit.cover,
                                  width: heartSize,
                                  height: heartSize,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // THE STICKER BORDER
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size(heartSize, heartSize),
                      painter: PerfectHeartPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTile(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: gridImages[index] == null ? () => pickImage(index, false) : null,
        onLongPress: gridImages[index] != null
            ? () => pickImage(index, false)
            : null,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.0,
            ),
            color: Colors.grey.shade900,
          ),
          child: gridImages[index] == null
              ? const Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.white24,
                    size: 40,
                  ),
                )
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.5,
                  maxScale: 5,
                  child: SizedBox.expand(
                    child: Image.file(gridImages[index]!, fit: BoxFit.cover),
                  ),
                ),
        ),
      ),
    );
  }
}

/// --- MATHEMATICALLY BALANCED CLASSIC HEART ---

Path _getClassicHeartPath(Size size) {
  Path path = Path();
  final double w = size.width;
  final double h = size.height;

  // Start at the top center dip
  path.moveTo(w / 2, h * 0.3);

  // Left Lobe
  path.cubicTo(w * 0.2, h * 0.1, -w * 0.05, h * 0.45, w / 2, h * 0.92);

  // Right Lobe (Mirroring the left)
  path.cubicTo(w * 1.05, h * 0.45, w * 0.8, h * 0.1, w / 2, h * 0.3);

  path.close();
  return path;
}

class PerfectHeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getClassicHeartPath(size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PerfectHeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeJoin = StrokeJoin
          .round // Smooths the joint at the top dip
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_getClassicHeartPath(size), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
