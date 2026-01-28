import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collageimagehelper.dart';
// Ensure this matches the filename where you put the save logic
// import 'collage_helper.dart'; 

class CollageEditorScreen extends StatefulWidget {
  const CollageEditorScreen({super.key});

  @override
  State<CollageEditorScreen> createState() => _CollageEditorScreenState();
}

class _CollageEditorScreenState extends State<CollageEditorScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> gridImages = List.filled(4, null);
  File? overlayImage;

  // 1. Define the GlobalKey for capturing the image
  final GlobalKey _collageKey = GlobalKey();

  Future<void> pickImage(int index, bool isOverlay) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isOverlay) {
          overlayImage = File(picked.path);
        } else {
          gridImages[index] = File(picked.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double starSize = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.black,
       floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        tooltip: 'Save Collage',
        onPressed: () => CollageHelper.saveCollage(_collageKey, context),
        label: const Text("Save"),
        icon: const Icon(Icons.download_rounded),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // 2. Add the Save Button here
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download_rounded, color: Colors.white),
          //   tooltip: 'Save Collage',
          //   onPressed: () => CollageHelper.saveCollage(_collageKey, context),
          // ),
          const SizedBox(width: 10),
        ],
      ),
      extendBodyBehindAppBar: true,
      // 3. Wrap everything in RepaintBoundary to capture the full screen
      body: RepaintBoundary(
        key: _collageKey,
        child: Stack(
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

            /// 2. CENTERED STAR
            Center(
              child: SizedBox(
                width: starSize,
                height: starSize,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: StarClipper(),
                      child: Container(
                        width: starSize,
                        height: starSize,
                        color: Colors.white.withOpacity(0.15),
                        child: overlayImage == null
                            ? GestureDetector(
                                onTap: () => pickImage(0, true),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_circle_outline,
                                    size: 50,
                                    color: Colors.white54,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onDoubleTap: () => pickImage(0, true),
                                child: InteractiveViewer(
                                  clipBehavior: Clip.hardEdge,
                                  boundaryMargin: const EdgeInsets.all(double.infinity),
                                  minScale: 0.5,
                                  maxScale: 5,
                                  child: Image.file(
                                    overlayImage!,
                                    fit: BoxFit.cover,
                                    width: starSize,
                                    height: starSize,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    IgnorePointer(
                      child: CustomPaint(
                        size: Size(starSize, starSize),
                        painter: StarBorderPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              color: Colors.white.withOpacity(0.4),
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
                  child: Image.file(
                    gridImages[index]!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }
}

// --- STAR PATH LOGIC ---
Path _getStarPath(Size size) {
  final path = Path();
  final double width = size.width;
  final double height = size.height;
  final double centerX = width / 2;
  final double centerY = (height / 2) + (height * 0.05);
  final double outerRadius = width / 2;
  final double innerRadius = outerRadius * 0.4;
  const int points = 5;
  double angle = -math.pi / 2;
  const double angleStep = math.pi / points;
  for (int i = 0; i < points * 2; i++) {
    double radius = i.isEven ? outerRadius : innerRadius;
    double x = centerX + math.cos(angle) * radius;
    double y = centerY + math.sin(angle) * radius;
    if (i == 0) path.moveTo(x, y);
    else path.lineTo(x, y);
    angle += angleStep;
  }
  path.close();
  return path;
}

class StarClipper extends CustomClipper<Path> {
  @override Path getClip(Size size) => _getStarPath(size);
  @override bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class StarBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_getStarPath(size), paint);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}