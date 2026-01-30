import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class MickeyFinalDesign extends StatefulWidget {
  const MickeyFinalDesign({super.key});

  @override
  State<MickeyFinalDesign> createState() => _MickeyFinalDesignState();
}

class _MickeyFinalDesignState extends State<MickeyFinalDesign> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(3, null);
  final GlobalKey _mickeyKey = GlobalKey();

  // 1. Unified Style Initialization
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 3.5,
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
      images = List.filled(3, null);
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 3.5;
      myStyle.activeBackground = appBackgrounds[0];
    });
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "FUSED SILHOUETTE",
          style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white70),
        ),
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
                key: _mickeyKey,
                child: Container(
                  width: canvasSize,
                  height: canvasSize,
                  // 2. Applying dynamic background to the canvas
                  decoration: myStyle.activeBackground.decoration,
                  child: Stack(
                    children: [
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

                      /// 3. Updated Fused Border Painter with myStyle params
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(canvasSize, canvasSize),
                          painter: MickeyFusedBorderPainter(
                            headRect: Rect.fromLTWH(headX, headY, headSize, headSize),
                            leftEarRect: Rect.fromLTWH(canvasSize * 0.05, earY, earSize, earSize),
                            rightEarRect: Rect.fromLTWH(canvasSize - earSize - (canvasSize * 0.05), earY, earSize, earSize),
                            color: myStyle.borderColor,
                            strokeWidth: myStyle.borderWidth,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_mickeyKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("SAVE COLLAGE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 5. Shared Control Panel
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

  Widget _buildCircle(int index, double diameter) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: ClipOval(
        child: Container(
          width: diameter,
          height: diameter,
          color: const Color(0xFF151515).withOpacity(0.4),
          child: images[index] == null
              ? Icon(
                  Icons.add_a_photo_outlined,
                  color: myStyle.borderColor.withOpacity(0.3),
                  size: 20,
                )
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(images[index]!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

// --- UPDATED PAINTER ---
class MickeyFusedBorderPainter extends CustomPainter {
  final Rect headRect;
  final Rect leftEarRect;
  final Rect rightEarRect;
  final Color color;
  final double strokeWidth;

  MickeyFusedBorderPainter({
    required this.headRect,
    required this.leftEarRect,
    required this.rightEarRect,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path fusedPath = Path()
      ..addOval(headRect)
      ..addOval(leftEarRect)
      ..addOval(rightEarRect);

    // Dynamic glow based on selected color
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fusedPath, glowPaint);
    canvas.drawPath(fusedPath, borderPaint);
  }

  @override
  bool shouldRepaint(MickeyFusedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}