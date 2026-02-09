import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart'; // Ensure this has our updated handler
import 'package:photho_editor/sharedstyle.dart';

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

  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

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
      gridImages = List.filled(4, null);
      overlayImage = null;
      textItems.clear();
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
        title: const Text(
          "EDITORIAL STAR",
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 4,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () => _handleTextAction(),
          ),
          TextButton(
            onPressed: () => CollageHelper.saveCollage(_collageKey, context),
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
                    key: _collageKey,
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
                            SizedBox(
                              width: starSize,
                              height: starSize,
                              child: Stack(
                                children: [
                                  ClipPath(
                                    clipper: StarClipper(),
                                    child: GestureDetector(
                                      onTap: overlayImage == null
                                          ? () => pickImage(0, true)
                                          : null,
                                      onDoubleTap: () => pickImage(0, true),
                                      child: Container(
                                        color: Colors.black.withOpacity(0.3),
                                        child: overlayImage == null
                                            ? Center(
                                                child: Icon(
                                                  Icons.stars,
                                                  size: 50,
                                                  color: myStyle.borderColor
                                                      .withOpacity(0.5),
                                                ),
                                              )
                                            : InteractiveViewer(
                                                boundaryMargin: EdgeInsets.all(
                                                  starSize * 0.5,
                                                ),
                                                minScale: 1.0,
                                                maxScale: 5.0,
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
                                      painter: StarBorderPainter(
                                        color: myStyle.borderColor,
                                        width: myStyle.borderWidth * 2,
                                      ),
                                    ),
                                  ),
                                ],
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
              ),
              const SizedBox(height: 100),
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

  Widget _buildInteractiveTile(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: gridImages[index] == null ? () => pickImage(index, false) : null,
        onDoubleTap: () => pickImage(index, false),
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
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 1.0,
                  maxScale: 4.0,
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

// --- DATA CLASS & DRAGGABLE TEXT (Paste here from Heart code) ---
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
  Offset position = const Offset(150, 200);
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
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;
          if (position.dy > screenHeight * 0.6 &&
              position.dx > screenWidth * 0.2 &&
              position.dx < screenWidth * 0.8) {
            widget.onDelete();
          }
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
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.properties.color,
                fontFamily: widget.properties.font,
                fontSize: 28,
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

// --- STAR PATH LOGIC ---
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
    if (i == 0)
      path.moveTo(x, y);
    else
      path.lineTo(x, y);
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
