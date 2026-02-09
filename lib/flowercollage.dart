import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/sharedstyle.dart';

class FlowerCollageScreen extends StatefulWidget {
  const FlowerCollageScreen({super.key});

  @override
  State<FlowerCollageScreen> createState() => _FlowerCollageScreenState();
}

class _FlowerCollageScreenState extends State<FlowerCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(6, null);
  final GlobalKey _flowerKey = GlobalKey();

  // Shared state for Text and UI behavior
  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

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
    if (picked != null) setState(() => images[index] = File(picked.path));
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
      images = List.filled(6, null);
      textItems.clear();
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 3.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * 0.95;
    final double centerSize = size * 0.35;
    final double petalSize = size * 0.32;
    final double radius = size * 0.28;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "FLORAL FUSION",
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 4,
            color: Colors.white70,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () => _handleTextAction(),
          ),
          TextButton(
            onPressed: () => CollageHelper.saveCollage(_flowerKey, context),
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
                    key: _flowerKey,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: myStyle.activeBackground.decoration,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Petals (Indices 1-5)
                          ...List.generate(5, (index) {
                            double angle = (index * 72) * (math.pi / 180);
                            return Positioned(
                              left:
                                  (size / 2) +
                                  radius * math.cos(angle) -
                                  (petalSize / 2),
                              top:
                                  (size / 2) +
                                  radius * math.sin(angle) -
                                  (petalSize / 2),
                              child: _buildCircle(index + 1, petalSize),
                            );
                          }),

                          // Center Core (Index 0)
                          _buildCircle(0, centerSize),

                          // Dynamic Border Overlay
                          IgnorePointer(
                            child: CustomPaint(
                              size: Size(size, size),
                              painter: FlowerBorderPainter(
                                radius: radius,
                                centerSize: centerSize,
                                petalSize: petalSize,
                                color: myStyle.borderColor,
                                width: myStyle.borderWidth,
                              ),
                            ),
                          ),

                          // Floating Text Layer
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

  Widget _buildCircle(int index, double d) {
    return GestureDetector(
      onTap: images[index] == null ? () => pickImage(index) : null,
      onDoubleTap: () => pickImage(index),
      child: ClipOval(
        child: Container(
          width: d,
          height: d,
          color: const Color(0xFF151515).withOpacity(0.5),
          child: images[index] == null
              ? Icon(
                  Icons.add,
                  color: myStyle.borderColor.withOpacity(0.3),
                  size: 20,
                )
              : InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(d * 0.5),
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.file(
                    images[index]!,
                    fit: BoxFit.cover,
                    width: d,
                    height: d,
                  ),
                ),
        ),
      ),
    );
  }
}

// --- SHARED CLASSES (Ensure these are in your commontext.dart or at bottom) ---
class TextProperties {
  final String text;
  final Color color;
  final String font;
  TextProperties({required this.text, required this.color, required this.font});
  TextProperties copyWith({String? text, Color? color, String? font}) {
    return TextProperties(
      text: text ?? this.text,
      color: color ?? this.color,
      font: font ?? this.font,
    );
  }
}

class DraggableTextWidget extends StatefulWidget {
  final TextProperties properties;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(bool) onDragStatusChanged;
  const DraggableTextWidget({
    super.key,
    required this.properties,
    required this.onTap,
    required this.onDelete,
    required this.onDragStatusChanged,
  });
  @override
  State<DraggableTextWidget> createState() => _DraggableTextWidgetState();
}

class _DraggableTextWidgetState extends State<DraggableTextWidget> {
  Offset position = const Offset(120, 150);
  double scale = 1.0;
  double rotation = 0.0;
  double baseScale = 1.0;
  double baseRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onScaleStart: (details) {
          baseScale = scale;
          baseRotation = rotation;
          widget.onDragStatusChanged(true);
        },
        onScaleUpdate: (details) {
          setState(() {
            position += details.focalPointDelta;
            scale = (baseScale * details.scale).clamp(0.5, 5.0);
            rotation = baseRotation + details.rotation;
          });
        },
        onScaleEnd: (details) {
          widget.onDragStatusChanged(false);
          if (position.dy > MediaQuery.of(context).size.height * 0.6)
            widget.onDelete();
        },
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(rotation)
            ..scale(scale),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.properties.text,
              style: TextStyle(
                color: widget.properties.color,
                fontFamily: widget.properties.font,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                shadows: const [Shadow(blurRadius: 10, color: Colors.black54)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlowerBorderPainter extends CustomPainter {
  final double radius, centerSize, petalSize;
  final Color color;
  final double width;

  FlowerBorderPainter({
    required this.radius,
    required this.centerSize,
    required this.petalSize,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    final Offset center = Offset(size.width / 2, size.height / 2);
    path.addOval(Rect.fromCircle(center: center, radius: centerSize / 2));
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72) * (math.pi / 180);
      Offset petalCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      path.addOval(Rect.fromCircle(center: petalCenter, radius: petalSize / 2));
    }
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(FlowerBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}
