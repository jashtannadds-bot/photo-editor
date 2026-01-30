import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart'; // Shared UI
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';    // Shared Model

class CollageEditorScreen extends StatefulWidget {
  const CollageEditorScreen({super.key});

  @override
  State<CollageEditorScreen> createState() => _CollageEditorScreenState();
}

class _CollageEditorScreenState extends State<CollageEditorScreen> {
  final ImagePicker picker = ImagePicker();
  final GlobalKey _collageKey = GlobalKey();
  
  List<File?> gridImages = List.filled(4, null);
  File? overlayImage;

  // 1. Use the shared CollageStyle
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 2.0,
      activeBackground: appBackgrounds[0], 
    );
  }

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

  void resetCollage() {
    setState(() {
      gridImages = List.filled(4, null);
      overlayImage = null;
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 2.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double starSize = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("EDITORIAL STAR", 
          style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white60),
            onPressed: resetCollage,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _collageKey,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  // 2. Background from shared style
                  decoration: myStyle.activeBackground.decoration,
                  child: AspectRatio(
                    aspectRatio: 0.85,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Background Grid
                        Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _buildInteractiveTile(0),
                                  const SizedBox(width: 4),
                                  _buildInteractiveTile(1),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Row(
                                children: [
                                  _buildInteractiveTile(2),
                                  const SizedBox(width: 4),
                                  _buildInteractiveTile(3),
                                ],
                              ),
                            ),
                          ],
                        ),

                        /// The Center Star
                        Center(
                          child: SizedBox(
                            width: starSize,
                            height: starSize,
                            child: Stack(
                              children: [
                                ClipPath(
                                  clipper: StarClipper(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    child: overlayImage == null
                                        ? GestureDetector(
                                            onTap: () => pickImage(0, true),
                                            child: Center(
                                              child: Icon(
                                                Icons.stars,
                                                size: 50,
                                                color: myStyle.borderColor.withOpacity(0.5),
                                              ),
                                            ),
                                          )
                                        : InteractiveViewer(
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.file(overlayImage!, fit: BoxFit.cover),
                                          ),
                                  ),
                                ),
                                IgnorePointer(
                                  child: CustomPaint(
                                    size: Size(starSize, starSize),
                                    painter: StarBorderPainter(
                                      color: myStyle.borderColor,
                                      width: myStyle.borderWidth * 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Integrated Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_collageKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("SAVE COLLAGE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 4. Shared Control Panel
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

  Widget _buildInteractiveTile(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => pickImage(index, false),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withOpacity(0.5),
            border: Border.all(
              color: myStyle.borderColor.withOpacity(0.4),
              width: myStyle.borderWidth / 2,
            ),
          ),
          child: gridImages[index] == null
              ? Center(
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: myStyle.borderColor.withOpacity(0.3),
                    size: 24,
                  ),
                )
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(gridImages[index]!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

// --- KEEP STAR PATH LOGIC ---
Path _getStarPath(Size size) {
  final path = Path();
  final double width = size.width;
  final double height = size.height;
  final double centerX = width / 2;
  final double centerY = (height / 2) + (height * 0.02);
  final double outerRadius = width / 2;
  final double innerRadius = outerRadius * 0.45;
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
  @override
  Path getClip(Size size) => _getStarPath(size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class StarBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  StarBorderPainter({required this.color, required this.width});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_getStarPath(size), paint);
  }
  @override
  bool shouldRepaint(StarBorderPainter oldDelegate) => true;
}