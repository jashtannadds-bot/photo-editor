import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/flowercollage.dart';
import 'package:photho_editor/sharedstyle.dart';

class ProCameraLensCollage extends StatefulWidget {
  const ProCameraLensCollage({super.key});

  @override
  State<ProCameraLensCollage> createState() => _ProCameraLensCollageState();
}

class _ProCameraLensCollageState extends State<ProCameraLensCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.generate(5, (_) => null);
  final GlobalKey _lensKey = GlobalKey();

  // Shared state for Text and UI behavior
  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 1.0,
      activeBackground: appBackgrounds[0],
    );
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images[index] = File(picked.path));
    }
  }

  void _handleTextAction({TextProperties? existing, int? index}) {
    CollageTextHandler.showTextEditor(
      context: context,
      initialText: existing?.text,
      initialColor: existing?.color,
      initialFont: existing?.font,
      onComplete: (text, color, font) {
        setState(() {
          if (index != null) {
            textItems[index] = textItems[index].copyWith(
              text: text,
              color: color,
              font: font,
            );
          } else {
            textItems.add(TextProperties(text: text, color: color, font: font));
          }
        });
      },
    );
  }

  void resetCollage() {
    setState(() {
      images = List.generate(5, (_) => null);
      textItems.clear();
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 1.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "LENS COLLAGE",
          style: TextStyle(
            letterSpacing: 4,
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () => _handleTextAction(),
          ),
          TextButton(
            onPressed: () => CollageHelper.saveCollage(_lensKey, context),
            child: const Text(
              "SAVE",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _lensKey,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: myStyle.activeBackground.decoration,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Shutter Blades with Interactive Images
                          SizedBox(
                            width: size * 0.9,
                            height: size * 0.9,
                            child: ClipOval(
                              child: Stack(
                                children: List.generate(5, (index) {
                                  return ClipPath(
                                    clipper: MechanicalShutterClipper(index),
                                    child: GestureDetector(
                                      onTap: images[index] == null
                                          ? () => pickImage(index)
                                          : null,
                                      onDoubleTap: () => pickImage(index),
                                      child: Container(
                                        color: index % 2 == 0
                                            ? const Color(
                                                0xFF151515,
                                              ).withOpacity(0.5)
                                            : const Color(
                                                0xFF1A1A1A,
                                              ).withOpacity(0.5),
                                        child: images[index] == null
                                            ? Center(
                                                child: Icon(
                                                  Icons.add_a_photo_outlined,
                                                  color: myStyle.borderColor
                                                      .withOpacity(0.2),
                                                  size: 30,
                                                ),
                                              )
                                            : InteractiveViewer(
                                                boundaryMargin: EdgeInsets.all(
                                                  size * 0.5,
                                                ),
                                                minScale: 1.0,
                                                maxScale: 5.0,
                                                child: Image.file(
                                                  images[index]!,
                                                  fit: BoxFit.cover,
                                                  width: size * 0.9,
                                                  height: size * 0.9,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),

                          // 2. Blade Edges Painter
                          IgnorePointer(
                            child: CustomPaint(
                              size: Size(size * 0.9, size * 0.9),
                              painter: ShutterEdgePainter(
                                color: myStyle.borderColor,
                                width: myStyle.borderWidth,
                              ),
                            ),
                          ),

                          // 3. Lens Barrel Overlay
                          IgnorePointer(
                            child: CustomPaint(
                              size: Size(size, size),
                              painter: LensBarrelPainter(
                                accentColor: myStyle.borderColor,
                              ),
                            ),
                          ),

                          // 4. Glass Reflection Layer
                          IgnorePointer(
                            child: Container(
                              width: size * 0.9,
                              height: size * 0.9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.transparent,
                                    myStyle.borderColor.withOpacity(0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 5. Floating Text Layer
                          for (int i = 0; i < textItems.length; i++)
                            DraggableTextWidget(
                              properties: textItems[i],
                              onTap: () => _handleTextAction(
                                existing: textItems[i],
                                index: i,
                              ),
                              onDragStatusChanged: (dragging) =>
                                  setState(() => isDraggingText = dragging),
                              onDelete: () =>
                                  setState(() => textItems.removeAt(i)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),

          // THE DUSTBIN
          if (isDraggingText)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(130),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

          // DRAGGABLE CONTROL SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Container(
                      //   width: 40,
                      //   height: 4,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white24,
                      //     borderRadius: BorderRadius.circular(2),
                      //   ),
                      // ),
                      CollageControlPanel(
                        style: myStyle,
                        onColorChanged: (newColor) =>
                            setState(() => myStyle.borderColor = newColor),
                        onWidthChanged: (newWidth) =>
                            setState(() => myStyle.borderWidth = newWidth),
                        onBackgroundChanged: (newBg) =>
                            setState(() => myStyle.activeBackground = newBg),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- DATA CLASS & WIDGETS ---
// (Ensure TextProperties and DraggableTextWidget are present as in previous steps)

class ShutterEdgePainter extends CustomPainter {
  final Color color;
  final double width;
  ShutterEdgePainter({required this.color, required this.width});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint edgePaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72 - 90) * (math.pi / 180);
      final Path path = Path();
      Offset innerPoint = Offset(
        center.dx + 20 * math.cos(angle),
        center.dy + 20 * math.sin(angle),
      );
      path.moveTo(innerPoint.dx, innerPoint.dy);
      path.quadraticBezierTo(
        center.dx + r * 0.5 * math.cos(angle + 0.5),
        center.dy + r * 0.5 * math.sin(angle + 0.5),
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      canvas.drawPath(path, edgePaint);
    }
  }

  @override
  bool shouldRepaint(ShutterEdgePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}

class LensBarrelPainter extends CustomPainter {
  final Color accentColor;
  LensBarrelPainter({required this.accentColor});
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    final Paint metalPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF333333), Color(0xFF000000)],
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    canvas.drawCircle(center, r - 7, metalPaint);
    final Paint markingPaint = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..strokeWidth = 1.2;
    for (int i = 0; i < 360; i += 5) {
      double angle = i * (math.pi / 180);
      double lineLen = (i % 30 == 0) ? 10 : 4;
      canvas.drawLine(
        Offset(
          center.dx + (r - 14) * math.cos(angle),
          center.dy + (r - 14) * math.sin(angle),
        ),
        Offset(
          center.dx + (r - 14 - lineLen) * math.cos(angle),
          center.dy + (r - 14 - lineLen) * math.sin(angle),
        ),
        markingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LensBarrelPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}

class MechanicalShutterClipper extends CustomClipper<Path> {
  final int index;
  MechanicalShutterClipper(this.index);
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;
    double angleStart = (index * 72 - 90) * (math.pi / 180);
    double angleEnd = ((index + 1) * 72 - 90) * (math.pi / 180);
    double innerR = 20.0;
    Offset p1 = Offset(
      center.dx + r * math.cos(angleStart),
      center.dy + r * math.sin(angleStart),
    );
    Offset p2 = Offset(
      center.dx + r * math.cos(angleEnd),
      center.dy + r * math.sin(angleEnd),
    );
    Offset h1 = Offset(
      center.dx + innerR * math.cos(angleStart),
      center.dy + innerR * math.sin(angleStart),
    );
    path.moveTo(h1.dx, h1.dy);
    path.quadraticBezierTo(
      center.dx + r * 0.5 * math.cos(angleStart + 0.5),
      center.dy + r * 0.5 * math.sin(angleStart + 0.5),
      p1.dx,
      p1.dy,
    );
    path.lineTo(p2.dx, p2.dy);
    path.quadraticBezierTo(
      center.dx + r * 0.4 * math.cos(angleEnd - 0.5),
      center.dy + r * 0.4 * math.sin(angleEnd - 0.5),
      h1.dx,
      h1.dy,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
