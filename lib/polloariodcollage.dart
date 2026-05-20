import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/flowercollage.dart';
import 'package:photho_editor/sharedstyle.dart';

class HangingBulbCollage extends StatefulWidget {
  final List<File>? initialImages;
  const HangingBulbCollage({super.key, this.initialImages});

  @override
  State<HangingBulbCollage> createState() => _HangingBulbCollageState();
}

class _HangingBulbCollageState extends State<HangingBulbCollage> {
  final ImagePicker picker = ImagePicker();
  late List<File?> images;
  final GlobalKey _saveKey = GlobalKey();

  // Shared state for Text and UI behavior
  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

  @override
  void initState() {
    super.initState();

    // Initialize with passed images or empty slots
    images = List.filled(5, null);
    if (widget.initialImages != null) {
      for (int i = 0; i < widget.initialImages!.length && i < 5; i++) {
        images[i] = widget.initialImages![i];
      }
    }

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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double w = constraints.maxWidth;
                        final double h = constraints.maxHeight;

                        // Dynamic photo width
                        final double photoWidth = (w * 0.28).clamp(100.0, 160.0);

                        // Row 1 parameters
                        final double r1StartY = h * 0.12;
                        final double r1CtrlY = h * 0.20;
                        final List<double> r1Bulbs = [0.18, 0.50, 0.82];

                        // Row 2 parameters
                        final double r2StartY = h * 0.52;
                        final double r2CtrlY = h * 0.60;
                        final List<double> r2Bulbs = [0.32, 0.68];

                        // Helper to calculate Bezier Y position at t
                        double getBezierY(double t, double startY, double ctrlY) {
                          return (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * ctrlY + t * t * startY;
                        }

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Lighting and String Painter
                            CustomPaint(
                              size: Size(w, h),
                              painter: BulbStringPainter(
                                accentColor: myStyle.borderColor,
                                width: w,
                                height: h,
                                row1StartY: r1StartY,
                                row1CtrlY: r1CtrlY,
                                row1Bulbs: r1Bulbs,
                                row2StartY: r2StartY,
                                row2CtrlY: r2CtrlY,
                                row2Bulbs: r2Bulbs,
                              ),
                            ),

                            // Row 1 Photos
                            _hangingPhoto(
                              0,
                              top: getBezierY(0.18, r1StartY, r1CtrlY),
                              left: w * 0.18 - photoWidth / 2,
                              photoWidth: photoWidth,
                              angle: -0.06,
                            ),
                            _hangingPhoto(
                              1,
                              top: getBezierY(0.50, r1StartY, r1CtrlY),
                              left: w * 0.50 - photoWidth / 2,
                              photoWidth: photoWidth,
                              angle: 0.04,
                            ),
                            _hangingPhoto(
                              2,
                              top: getBezierY(0.82, r1StartY, r1CtrlY),
                              left: w * 0.82 - photoWidth / 2,
                              photoWidth: photoWidth,
                              angle: -0.04,
                            ),

                            // Row 2 Photos
                            _hangingPhoto(
                              3,
                              top: getBezierY(0.32, r2StartY, r2CtrlY),
                              left: w * 0.32 - photoWidth / 2,
                              photoWidth: photoWidth,
                              angle: 0.05,
                            ),
                            _hangingPhoto(
                              4,
                              top: getBezierY(0.68, r2StartY, r2CtrlY),
                              left: w * 0.68 - photoWidth / 2,
                              photoWidth: photoWidth,
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
                        );
                      },
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
    required double photoWidth,
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
              width: photoWidth,
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
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(4, 8),
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
  final double width;
  final double height;
  final double row1StartY;
  final double row1CtrlY;
  final List<double> row1Bulbs;
  final double row2StartY;
  final double row2CtrlY;
  final List<double> row2Bulbs;

  BulbStringPainter({
    required this.accentColor,
    required this.width,
    required this.height,
    required this.row1StartY,
    required this.row1CtrlY,
    required this.row1Bulbs,
    required this.row2StartY,
    required this.row2CtrlY,
    required this.row2Bulbs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final bulbCore = Paint()
      ..color = Colors.amberAccent.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Glowing effect around the bulb
    final bulbGlow = Paint()
      ..color = Colors.amberAccent.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    _drawRow(
      canvas,
      row1StartY,
      row1CtrlY,
      row1Bulbs,
      bulbCore,
      bulbGlow,
      stringPaint,
    );
    _drawRow(
      canvas,
      row2StartY,
      row2CtrlY,
      row2Bulbs,
      bulbCore,
      bulbGlow,
      stringPaint,
    );
  }

  void _drawRow(
    Canvas canvas,
    double startY,
    double ctrlY,
    List<double> bulbPositions,
    Paint core,
    Paint glow,
    Paint string,
  ) {
    Path path = Path();
    path.moveTo(0, startY);
    path.quadraticBezierTo(width / 2, ctrlY, width, startY);
    canvas.drawPath(path, string);

    for (double t in bulbPositions) {
      double x = width * t;
      double y =
          (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * ctrlY + t * t * startY;
      
      // Draw wire hanging the bulb
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 20),
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..strokeWidth = 1.0,
      );
      
      // Draw glowing aura
      canvas.drawCircle(Offset(x, y + 28), 7, glow);
      // Draw inner bulb
      canvas.drawCircle(Offset(x, y + 28), 3.5, core);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
