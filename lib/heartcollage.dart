import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart'; 
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/sharedstyle.dart';

class CenterHeartCollageScreen extends StatefulWidget {
  const CenterHeartCollageScreen({super.key});

  @override
  State<CenterHeartCollageScreen> createState() => _CenterHeartCollageScreenState();
}

class _CenterHeartCollageScreenState extends State<CenterHeartCollageScreen> {
  final ImagePicker picker = ImagePicker();
  final GlobalKey _boundaryKey = GlobalKey();
  
  List<File?> gridImages = List.filled(4, null);
  File? heartImage;
  
  // Storage for text items added to the collage
  List<Widget> textWidgets = [];

  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 2.0,
      activeBackground: appBackgrounds[0],
    );
  }

  Future<void> pickImage(int index, bool isHeart) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isHeart) {
          heartImage = File(picked.path);
        } else {
          gridImages[index] = File(picked.path);
        }
      });
    }
  }

  void resetCollage() {
    setState(() {
      gridImages = List.filled(4, null);
      heartImage = null;
      textWidgets.clear(); 
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 2.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  void _addNewText() {
    // Calling the common text handler we discussed
    CollageTextHandler.showTextEditor(
      context: context,
      onComplete: (text, color, font) {
        setState(() {
          textWidgets.add(
             DraggableTextWidget(text: text, color: color, font: font),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double heartSize = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("EDITORIAL HEART", 
          style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.text_fields), onPressed: _addNewText),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: resetCollage)
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _boundaryKey,
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

                            /// The Center Heart
                            SizedBox(
                              width: heartSize,
                              height: heartSize,
                              child: Stack(
                                children: [
                                  ClipPath(
                                    clipper: PerfectHeartClipper(),
                                    child: Container(
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                                      child: heartImage == null
                                          ? GestureDetector(
                                              onTap: () => pickImage(0, true),
                                              child: Center(
                                                child: Icon(Icons.favorite, 
                                                  color: myStyle.borderColor.withOpacity(0.5), size: 40),
                                              ),
                                            )
                                          : InteractiveViewer(
                                              clipBehavior: Clip.hardEdge,
                                              child: Image.file(heartImage!, fit: BoxFit.cover),
                                            ),
                                    ),
                                  ),
                                  IgnorePointer(
                                    child: CustomPaint(
                                      size: Size(heartSize, heartSize),
                                      painter: PerfectHeartPainter(
                                        color: myStyle.borderColor,
                                        strokeWidth: myStyle.borderWidth * 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Floating Text Layer
                            ...textWidgets,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Save Button (Adjusted for DraggableSheet)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                    onPressed: () => CollageHelper.saveCollage(_boundaryKey, context),
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: const Text("SAVE COLLAGE", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),

          /// DRAGGABLE CONTROL PANEL
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: CollageControlPanel(
                    style: myStyle,
                    onColorChanged: (newColor) => setState(() => myStyle.borderColor = newColor),
                    onWidthChanged: (newWidth) => setState(() => myStyle.borderWidth = newWidth),
                    onBackgroundChanged: (newBg) => setState(() => myStyle.activeBackground = newBg),
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
        onTap: () => pickImage(index, false),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withOpacity(0.5),
            border: Border.all(color: myStyle.borderColor, width: myStyle.borderWidth / 2),
          ),
          child: gridImages[index] == null
              ? Center(
                  child: Icon(Icons.add_a_photo_outlined, 
                    color: myStyle.borderColor.withOpacity(0.3), size: 24),
                )
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(gridImages[index]!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

// --- HELPER CLASSES (Place these outside the State class) ---

class PerfectHeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w / 2, h * 0.3);
    path.cubicTo(w * 0.2, h * 0.1, -w * 0.05, h * 0.45, w / 2, h * 0.92);
    path.cubicTo(w * 1.05, h * 0.45, w * 0.8, h * 0.1, w / 2, h * 0.3);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PerfectHeartPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  PerfectHeartPainter({required this.color, required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w / 2, h * 0.3);
    path.cubicTo(w * 0.2, h * 0.1, -w * 0.05, h * 0.45, w / 2, h * 0.92);
    path.cubicTo(w * 1.05, h * 0.45, w * 0.8, h * 0.1, w / 2, h * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(PerfectHeartPainter oldDelegate) => true;
}

class DraggableTextWidget extends StatefulWidget {
  final String text;
  final Color color;
  final String font;
  const DraggableTextWidget({super.key, required this.text, required this.color, required this.font});

  @override
  State<DraggableTextWidget> createState() => _DraggableTextWidgetState();
}

class _DraggableTextWidgetState extends State<DraggableTextWidget> {
  Offset position = const Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => position += details.delta),
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.color,
            fontFamily: widget.font,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(blurRadius: 10, color: Colors.black54)],
          ),
        ),
      ),
    );
  }
}