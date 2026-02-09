import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/flowercollage.dart';
import 'package:photho_editor/sharedstyle.dart';

class HangingBulbCollage extends StatefulWidget {
  const HangingBulbCollage({super.key});

  @override
  State<HangingBulbCollage> createState() => _HangingBulbCollageState();
}

class _HangingBulbCollageState extends State<HangingBulbCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _saveKey = GlobalKey();

  // Shared state for Text and UI behavior
  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: const Color(0xFFF4EBD0), // Vintage Cream default
      borderWidth: 6.0,
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
      myStyle.borderColor = const Color(0xFFF4EBD0);
      myStyle.borderWidth = 6.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "BOUTIQUE CUSTOM",
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 5,
            color: Colors.amberAccent,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () => _handleTextAction(),
          ),
          TextButton(
            onPressed: () => CollageHelper.saveCollage(_saveKey, context),
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
                child: RepaintBoundary(
                  key: _saveKey,
                  child: Container(
                    decoration: myStyle.activeBackground.decoration,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Lighting and String Painter
                        CustomPaint(
                          size: Size(size.width, size.height),
                          painter: BulbStringPainter(
                            accentColor: myStyle.borderColor,
                          ),
                        ),

                        // The Hanging Photos
                        _hangingPhoto(
                          0,
                          top: 100,
                          left: size.width * 0.04,
                          angle: -0.06,
                        ),
                        _hangingPhoto(
                          1,
                          top: 125,
                          left: size.width * 0.36,
                          angle: 0.04,
                        ),
                        _hangingPhoto(
                          2,
                          top: 100,
                          left: size.width * 0.68,
                          angle: -0.04,
                        ),
                        _hangingPhoto(
                          3,
                          top: 400,
                          left: size.width * 0.12,
                          angle: 0.05,
                        ),
                        _hangingPhoto(
                          4,
                          top: 410,
                          left: size.width * 0.55,
                          angle: -0.06,
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

  Widget _hangingPhoto(
    int index, {
    required double top,
    required double left,
    double angle = 0,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: angle,
        child: Column(
          children: [
            // The Wooden Clip
            Container(
              width: 8,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF795548),
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 2),
                ],
              ),
            ),
            // The Polaroid Frame
            Container(
              width: 115,
              padding: EdgeInsets.fromLTRB(
                myStyle.borderWidth,
                myStyle.borderWidth,
                myStyle.borderWidth,
                myStyle.borderWidth * 4.5,
              ),
              decoration: BoxDecoration(
                color: myStyle.borderColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(6, 6),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: const Color(0xFF0A0A0A),
                  child: images[index] == null
                      ? InkWell(
                          onTap: () => pickImage(index),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.amber.withOpacity(0.2),
                            size: 30,
                          ),
                        )
                      : InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(50),
                          minScale: 1.0,
                          maxScale: 5.0,
                          child: GestureDetector(
                            onDoubleTap: () => pickImage(index),
                            child: Image.file(
                              images[index]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BulbStringPainter extends CustomPainter {
  final Color accentColor;
  BulbStringPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final bulbGlow = Paint()
      ..color = Colors.amber.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final bulbCore = Paint()..color = Colors.amberAccent.withOpacity(0.8);

    _drawRow(
      canvas,
      size,
      90,
      150,
      [0.34, 0.66],
      bulbGlow,
      bulbCore,
      stringPaint,
    );
    _drawRow(canvas, size, 390, 450, [0.48], bulbGlow, bulbCore, stringPaint);
  }

  void _drawRow(
    Canvas canvas,
    Size size,
    double startY,
    double ctrlY,
    List<double> bulbPositions,
    Paint glow,
    Paint core,
    Paint string,
  ) {
    Path path = Path();
    path.moveTo(0, startY);
    path.quadraticBezierTo(size.width / 2, ctrlY, size.width, startY);
    canvas.drawPath(path, string);

    for (double t in bulbPositions) {
      double x = size.width * t;
      double y =
          (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * ctrlY + t * t * startY;
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 20),
        Paint()..color = Colors.white10,
      );
      canvas.drawCircle(Offset(x, y + 28), 14, glow);
      canvas.drawCircle(Offset(x, y + 28), 3.5, core);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
