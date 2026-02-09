import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/flowercollage.dart';
import 'package:photho_editor/sharedstyle.dart';

class AuraCollageScreen extends StatefulWidget {
  const AuraCollageScreen({super.key});

  @override
  State<AuraCollageScreen> createState() => _AuraCollageScreenState();
}

class _AuraCollageScreenState extends State<AuraCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _auraKey = GlobalKey();

  // Shared state for Text and UI behavior
  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.orangeAccent, // Kodak Classic Default
      borderWidth: 1.0,
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
      images = List.filled(5, null);
      textItems.clear();
      myStyle.borderColor = Colors.orangeAccent;
      myStyle.borderWidth = 1.0;
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
        title: Text(
          "AURA FILM STRIP",
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 4,
            color: myStyle.borderColor.withOpacity(0.7),
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () => _handleTextAction(),
          ),
          TextButton(
            onPressed: () => CollageHelper.saveCollage(_auraKey, context),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: RepaintBoundary(
                    key: _auraKey,
                    child: Container(
                      decoration: myStyle.activeBackground.decoration,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: [
                              Text(
                                "NEGATIVE // ISO 400",
                                style: TextStyle(
                                  color: myStyle.borderColor,
                                  letterSpacing: 8,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...List.generate(
                                5,
                                (index) => _buildFilmFrame(index),
                              ),
                              const SizedBox(height: 40),
                            ],
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

  Widget _buildFilmFrame(int index) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: myStyle.borderColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: images[index] == null
                  ? GestureDetector(
                      onTap: () => pickImage(index),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: myStyle.borderColor.withOpacity(0.2),
                          size: 32,
                        ),
                      ),
                    )
                  : InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 1.0,
                      maxScale: 5.0,
                      child: GestureDetector(
                        onDoubleTap: () => pickImage(index),
                        child: Image.file(
                          images[index]!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: FilmStripPainter(
                accentColor: myStyle.borderColor,
                strokeWidth: myStyle.borderWidth,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 12,
            child: Text(
              "0${index + 1}A",
              style: TextStyle(
                color: myStyle.borderColor.withOpacity(0.8),
                fontSize: 8,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilmStripPainter extends CustomPainter {
  final Color accentColor;
  final double strokeWidth;
  FilmStripPainter({required this.accentColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint holePaint = Paint()..color = Colors.black.withOpacity(0.8);
    final Paint borderPaint = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double holeWidth = 10;
    double holeHeight = 14;
    double padding = 20;

    for (double i = 10; i < size.height; i += 28) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(padding, i, holeWidth, holeHeight),
          const Radius.circular(2),
        ),
        holePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width - padding - holeWidth,
            i,
            holeWidth,
            holeHeight,
          ),
          const Radius.circular(2),
        ),
        holePaint,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(45, 0, size.width - 90, size.height),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(FilmStripPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
