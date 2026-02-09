import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
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

  // New states for Text and Dragging
  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

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
      images = List.filled(3, null);
      textItems.clear();
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
            onPressed: () => CollageHelper.saveCollage(_mickeyKey, context),
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
                    key: _mickeyKey,
                    child: Container(
                      width: canvasSize,
                      height: canvasSize,
                      decoration: myStyle.activeBackground.decoration,
                      child: Stack(
                        clipBehavior: Clip.none,
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

                          /// Fused Border Painter
                          IgnorePointer(
                            child: CustomPaint(
                              size: Size(canvasSize, canvasSize),
                              painter: MickeyFusedBorderPainter(
                                headRect: Rect.fromLTWH(
                                  headX,
                                  headY,
                                  headSize,
                                  headSize,
                                ),
                                leftEarRect: Rect.fromLTWH(
                                  canvasSize * 0.05,
                                  earY,
                                  earSize,
                                  earSize,
                                ),
                                rightEarRect: Rect.fromLTWH(
                                  canvasSize - earSize - (canvasSize * 0.05),
                                  earY,
                                  earSize,
                                  earSize,
                                ),
                                color: myStyle.borderColor,
                                strokeWidth: myStyle.borderWidth,
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

          /// THE DUSTBIN
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

          /// DRAGGABLE BOTTOM SHEET
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
                  child: CollageControlPanel(
                    style: myStyle,
                    onColorChanged: (newColor) =>
                        setState(() => myStyle.borderColor = newColor),
                    onWidthChanged: (newWidth) =>
                        setState(() => myStyle.borderWidth = newWidth),
                    onBackgroundChanged: (newBg) =>
                        setState(() => myStyle.activeBackground = newBg),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(int index, double diameter) {
    return GestureDetector(
      onTap: images[index] == null ? () => pickImage(index) : null,
      onDoubleTap: () => pickImage(index),
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
                  boundaryMargin: EdgeInsets.all(diameter * 0.5),
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.file(
                    images[index]!,
                    fit: BoxFit.cover,
                    width: diameter,
                    height: diameter,
                  ),
                ),
        ),
      ),
    );
  }
}

// --- DATA CLASS & DRAGGABLE TEXT (Ensure these exist in your project) ---
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
  Offset position = const Offset(100, 100);
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
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.3)
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
