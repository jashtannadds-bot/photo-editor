import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart'; // Modern saving library
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CenterHeartCollageScreen extends StatefulWidget {
  const CenterHeartCollageScreen({super.key});

  @override
  State<CenterHeartCollageScreen> createState() =>
      _CenterHeartCollageScreenState();
}

class _CenterHeartCollageScreenState extends State<CenterHeartCollageScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  final ImagePicker picker = ImagePicker();
  List<File?> gridImages = List.filled(4, null);
  File? heartImage;

  Future<void> _saveCollage() async {
    try {
      // 1. Check/Request Permissions
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // 2. Capture the Widget as an Image
      RenderRepaintBoundary? boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 3. Save to a temporary file first
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/heart_collage_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      // 4. Save to Gallery
      await Gal.putImage(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✨ Collage saved to Gallery!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Save Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final double heartSize = MediaQuery.of(context).size.width * 0.92;

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        onPressed: _saveCollage,
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
      ),
      extendBodyBehindAppBar: true,
      body: RepaintBoundary(
        key: _boundaryKey,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// 1. Background Grid
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

            /// 2. The Heart Lobe
            Center(
              child: SizedBox(
                width: heartSize,
                height: heartSize,
                child: Stack(
                  children: [
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
                            : InteractiveViewer(
                                clipBehavior: Clip.hardEdge,
                                boundaryMargin: const EdgeInsets.all(
                                  double.infinity,
                                ),
                                minScale: 0.5,
                                maxScale: 5,
                                child: Image.file(
                                  heartImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
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
      ),
    );
  }

  Widget _buildInteractiveTile(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: gridImages[index] == null ? () => pickImage(index, false) : null,
        onLongPress: () => pickImage(index, false),
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
                  minScale: 0.1,
                  maxScale: 5,
                  child: Image.file(gridImages[index]!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

/// --- MATH & PAINTERS ---

Path _getClassicHeartPath(Size size) {
  Path path = Path();
  final double w = size.width;
  final double h = size.height;
  path.moveTo(w / 2, h * 0.3);
  path.cubicTo(w * 0.2, h * 0.1, -w * 0.05, h * 0.45, w / 2, h * 0.92);
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
      ..strokeWidth = 10.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_getClassicHeartPath(size), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
