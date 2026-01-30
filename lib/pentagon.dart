import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class PuzzleCollageScreen extends StatefulWidget {
  const PuzzleCollageScreen({super.key});

  @override
  State<PuzzleCollageScreen> createState() => _PuzzleCollageScreenState();
}

class _PuzzleCollageScreenState extends State<PuzzleCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _puzzleKey = GlobalKey();

  // 1. Unified Style Initialization
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 3.0,
      activeBackground: appBackgrounds[0],
    );
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images[index] = File(picked.path));
    }
  }

  void resetCollage() {
    setState(() {
      images = List.filled(5, null);
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 3.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "GEOMETRIC PUZZLE",
          style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white70),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white60),
            onPressed: resetCollage,
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          RepaintBoundary(
            key: _puzzleKey,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(10),
                // 2. Applying dynamic background to the main container
                decoration: myStyle.activeBackground.decoration.copyWith(
                  border: Border.all(
                    color: myStyle.borderColor,
                    width: myStyle.borderWidth,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double s = constraints.maxWidth;
                    return Stack(
                      children: [
                        _buildSlot(1, const Rect.fromLTWH(0, 0, 0.5, 0.5), s),
                        _buildSlot(2, const Rect.fromLTWH(0.5, 0, 0.5, 0.5), s),
                        _buildSlot(3, const Rect.fromLTWH(0, 0.5, 0.5, 0.5), s),
                        _buildSlot(4, const Rect.fromLTWH(0.5, 0.5, 0.5, 0.5), s),
                        Center(child: _buildPentagonCenter(0, s * 0.5)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const Spacer(),
          
          // 3. Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_puzzleKey, context),
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

  Widget _buildSlot(int index, Rect relativeRect, double totalSize) {
    return Positioned(
      top: relativeRect.top * totalSize,
      left: relativeRect.left * totalSize,
      width: (relativeRect.width * totalSize),
      height: (relativeRect.height * totalSize),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: myStyle.borderColor.withOpacity(0.5),
            width: myStyle.borderWidth / 2,
          ),
        ),
        child: images[index] == null
            ? GestureDetector(
                onTap: () => pickImage(index),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: myStyle.borderColor.withOpacity(0.2),
                    size: 30,
                  ),
                ),
              )
            : InteractiveViewer(
                clipBehavior: Clip.hardEdge,
                child: Image.file(images[index]!, fit: BoxFit.cover),
              ),
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
              color: const Color(0xFF151515).withOpacity(0.6),
              child: images[index] == null
                  ? GestureDetector(
                      onTap: () => pickImage(index),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: myStyle.borderColor.withOpacity(0.5),
                          size: 40,
                        ),
                      ),
                    )
                  : InteractiveViewer(
                      clipBehavior: Clip.hardEdge,
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
              painter: PentagonBorderPainter(
                color: myStyle.borderColor,
                width: myStyle.borderWidth + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- DYNAMIC PAINTERS ---
class PentagonBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  PentagonBorderPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    // Optional: Add a slight glow to the central pentagon
    Paint glow = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    Path path = _getPentagonPath(size);
    canvas.drawPath(path, glow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PentagonBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}

class PentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getPentagonPath(size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Path _getPentagonPath(Size size) {
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