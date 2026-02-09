import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/flowercollage.dart';
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
      images = List.filled(5, null);
      textItems.clear();
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
            onPressed: () => CollageHelper.saveCollage(_puzzleKey, context),
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
              const Spacer(),
              RepaintBoundary(
                key: _puzzleKey,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10),
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
                          clipBehavior: Clip.none,
                          children: [
                            _buildSlot(
                              1,
                              const Rect.fromLTWH(0, 0, 0.5, 0.5),
                              s,
                            ),
                            _buildSlot(
                              2,
                              const Rect.fromLTWH(0.5, 0, 0.5, 0.5),
                              s,
                            ),
                            _buildSlot(
                              3,
                              const Rect.fromLTWH(0, 0.5, 0.5, 0.5),
                              s,
                            ),
                            _buildSlot(
                              4,
                              const Rect.fromLTWH(0.5, 0.5, 0.5, 0.5),
                              s,
                            ),
                            Center(child: _buildPentagonCenter(0, s * 0.5)),

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
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Spacer(),
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

          /// DRAGGABLE CONTROL SHEET
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

  Widget _buildSlot(int index, Rect relativeRect, double totalSize) {
    return Positioned(
      top: relativeRect.top * totalSize,
      left: relativeRect.left * totalSize,
      width: (relativeRect.width * totalSize),
      height: (relativeRect.height * totalSize),
      child: GestureDetector(
        onTap: images[index] == null ? () => pickImage(index) : null,
        onDoubleTap: () => pickImage(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: myStyle.borderColor.withOpacity(0.5),
              width: myStyle.borderWidth / 2,
            ),
          ),
          child: images[index] == null
              ? Center(
                  child: Icon(
                    Icons.add,
                    color: myStyle.borderColor.withOpacity(0.2),
                    size: 30,
                  ),
                )
              : InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(200),
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.file(
                    images[index]!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
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
          GestureDetector(
            onTap: images[index] == null ? () => pickImage(index) : null,
            onDoubleTap: () => pickImage(index),
            child: ClipPath(
              clipper: PentagonClipper(),
              child: Container(
                width: size,
                height: size,
                color: const Color(0xFF151515).withOpacity(0.6),
                child: images[index] == null
                    ? Center(
                        child: Icon(
                          Icons.add,
                          color: myStyle.borderColor.withOpacity(0.5),
                          size: 40,
                        ),
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

// --- DYNAMIC PAINTERS & CLIPPERS ---
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
    Path path = _getPentagonPath(size);
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
