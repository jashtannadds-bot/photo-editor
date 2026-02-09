import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart'; // Ensure this matches our updated handler
import 'package:photho_editor/sharedstyle.dart';

class BubbleCollageScreen extends StatefulWidget {
  const BubbleCollageScreen({super.key});

  @override
  State<BubbleCollageScreen> createState() => _BubbleCollageScreenState();
}

class _BubbleCollageScreenState extends State<BubbleCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(6, null);
  final GlobalKey _bubbleKey = GlobalKey();

  // Shared state for text and drag-to-delete
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
    if (picked != null) {
      setState(() {
        images[index] = File(picked.path);
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
      images = List.filled(6, null);
      textItems.clear();
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 3.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "EDITORIAL BUBBLES",
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
            onPressed: () => CollageHelper.saveCollage(_bubbleKey, context),
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
                    key: _bubbleKey,
                    child: Container(
                      decoration: myStyle.activeBackground.decoration,
                      width: size.width,
                      height: size.height * 0.7,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildBubble(
                            0,
                            size: 210,
                            top: 100,
                            left: size.width * 0.2,
                          ),
                          _buildBubble(
                            1,
                            size: 130,
                            top: 30,
                            left: size.width * 0.58,
                          ),
                          _buildBubble(
                            2,
                            size: 90,
                            top: 70,
                            left: size.width * 0.05,
                          ),
                          _buildBubble(
                            3,
                            size: 140,
                            top: 310,
                            left: size.width * 0.05,
                          ),
                          _buildBubble(
                            4,
                            size: 170,
                            top: 270,
                            left: size.width * 0.45,
                          ),
                          _buildBubble(
                            5,
                            size: 80,
                            top: 230,
                            left: size.width * 0.1,
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
              const SizedBox(height: 100),
            ],
          ),

          /// THE DUSTBIN (Shows when text is dragging)
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

  Widget _buildBubble(
    int index, {
    required double size,
    required double top,
    required double left,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: images[index] == null ? () => pickImage(index) : null,
        onDoubleTap: () => pickImage(index),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF151515).withOpacity(0.5),
            border: Border.all(
              color: myStyle.borderColor,
              width: myStyle.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: myStyle.borderColor.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: images[index] == null
                ? Icon(
                    Icons.bubble_chart_outlined,
                    color: myStyle.borderColor.withOpacity(0.3),
                    size: size * 0.3,
                  )
                : InteractiveViewer(
                    boundaryMargin: EdgeInsets.all(size * 0.5),
                    minScale: 1.0,
                    maxScale: 5.0,
                    child: Image.file(
                      images[index]!,
                      fit: BoxFit.cover,
                      width: size,
                      height: size,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// --- DATA CLASS & DRAGGABLE TEXT WIDGET ---
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
