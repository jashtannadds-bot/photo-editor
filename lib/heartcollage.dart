import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart'; // Same as Slit Scan
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class CenterHeartCollageScreen extends StatefulWidget {
  const CenterHeartCollageScreen({super.key});

  @override
  State<CenterHeartCollageScreen> createState() => _CenterHeartCollageScreenState();
}

class _CenterHeartCollageScreenState extends State<CenterHeartCollageScreen> {
  final ImagePicker picker = ImagePicker();
  final GlobalKey _boundaryKey = GlobalKey();
  
  List<File?> gridImages = List.filled(4, null);
  File? heartImage;

  // 1. Initialize using the same CollageStyle as Slit Scan
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

  void resetCollage() {
    setState(() {
      gridImages = List.filled(4, null);
      heartImage = null;
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 2.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double heartSize = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("EDITORIAL HEART", 
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
                key: _boundaryKey,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  // 2. Dynamic Background from shared class
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

                        /// The Center Heart
                        SizedBox(
                          width: heartSize,
                          height: heartSize,
                          child: Stack(
                            children: [
                              ClipPath(
                                clipper: PerfectHeartClipper(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  child: heartImage == null
                                      ? GestureDetector(
                                          onTap: () => pickImage(0, true),
                                          child: Center(
                                            child: Icon(Icons.favorite, 
                                              color: myStyle.borderColor.withOpacity(0.5), 
                                              size: 40),
                                          ),
                                        )
                                      : InteractiveViewer(
                                          clipBehavior: Clip.hardEdge,
                                          child: Image.file(heartImage!, fit: BoxFit.cover),
                                        ),
                                ),
                              ),
                              IgnorePointer(
                                child: CustomPaint(
                                  size: Size(heartSize, heartSize),
                                  painter: PerfectHeartPainter(
                                    color: myStyle.borderColor,
                                    strokeWidth: myStyle.borderWidth * 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Save Button (Same style as Slit Scan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_boundaryKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("SAVE COLLAGE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 4. THE COMMON CONTROL PANEL (Exactly the same)
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
            border: Border.all(color: myStyle.borderColor, width: myStyle.borderWidth / 2),
          ),
          child: gridImages[index] == null
              ? Center(
                  child: Icon(Icons.add_a_photo_outlined, 
                    color: myStyle.borderColor.withOpacity(0.3), size: 24),
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

// --- KEEP YOUR CLIPPER AND PAINTER CLASSES BELOW ---
class PerfectHeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w / 2, h * 0.3);
    path.cubicTo(w * 0.2, h * 0.1, -w * 0.05, h * 0.45, w / 2, h * 0.92);
    path.cubicTo(w * 1.05, h * 0.45, w * 0.8, h * 0.1, w / 2, h * 0.3);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PerfectHeartPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  PerfectHeartPainter({required this.color, required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w / 2, h * 0.3);
    path.cubicTo(w * 0.2, h * 0.1, -w * 0.05, h * 0.45, w / 2, h * 0.92);
    path.cubicTo(w * 1.05, h * 0.45, w * 0.8, h * 0.1, w / 2, h * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(PerfectHeartPainter oldDelegate) => true;
}