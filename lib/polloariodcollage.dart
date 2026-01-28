import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collageimagehelper.dart';
// import 'collage_helper.dart'; // Ensure your helper file exists

class HangingBulbCollage extends StatefulWidget {
  const HangingBulbCollage({super.key});

  @override
  State<HangingBulbCollage> createState() => _HangingBulbCollageState();
}

class _HangingBulbCollageState extends State<HangingBulbCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _saveKey = GlobalKey();

  // Customization State
  Color frameColor = Colors.white;
  double borderWidth = 5.0;

  final List<Color> palette = [
    Colors.white,
    const Color(0xFFF4EBD0), // Cream
    const Color(0xFFD6D2C4), // Grey
    const Color(0xFFA28972), // Kraft
    const Color(0xFFE5D1D0), // Rose
    const Color(0xFF1A1A1A), // Matte Black
  ];

  void resetCollage() {
    setState(() {
      images = List.filled(5, null);
      frameColor = Colors.white;
      borderWidth = 5.0;
    });
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => images[index] = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        tooltip: 'Save Collage',
        onPressed: () => CollageHelper.saveCollage(_saveKey, context),
        label: const Text("Save"),
        icon: const Icon(Icons.download_rounded),
      ),
      appBar: AppBar(
        title: const Text("BOUTIQUE CUSTOM", style: TextStyle(fontSize: 10, letterSpacing: 5, color: Colors.amber)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download_for_offline_rounded, color: Colors.amber),
          //   onPressed: () => CollageHelper.saveCollage(_saveKey, context),
          // )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _saveKey,
              child: Container(
                color: const Color(0xFF080808),
                child: Stack(
                  children: [
                    // This calls the Painter class defined below
                    CustomPaint(
                      size: Size(size.width, size.height), 
                      painter: BulbStringPainter(),
                    ),
                    _hangingPhoto(0, top: 100, left: size.width * 0.04, angle: -0.06),
                    _hangingPhoto(1, top: 125, left: size.width * 0.36, angle: 0.04),
                    _hangingPhoto(2, top: 100, left: size.width * 0.68, angle: -0.04),
                    _hangingPhoto(3, top: 400, left: size.width * 0.12, angle: 0.05),
                    _hangingPhoto(4, top: 410, left: size.width * 0.55, angle: -0.06),
                  ],
                ),
              ),
            ),
          ),
          
          // CONTROL PANEL
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF151515),
            child: Column(
              children: [
                Slider(
                  value: borderWidth,
                  min: 2.0,
                  max: 15.0,
                  activeColor: Colors.amber,
                  onChanged: (val) => setState(() => borderWidth = val),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: palette.length,
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => setState(() => frameColor = palette[i]),
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: palette[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: frameColor == palette[i] ? Colors.amber : Colors.white12,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hangingPhoto(int index, {required double top, required double left, double angle = 0}) {
    return Positioned(
      top: top, left: left,
      child: Transform.rotate(
        angle: angle,
        child: Column(
          children: [
            Container(width: 8, height: 18, decoration: BoxDecoration(color: Colors.brown[400], borderRadius: BorderRadius.circular(2))),
            Container(
              width: 115,
              padding: EdgeInsets.fromLTRB(borderWidth, borderWidth, borderWidth, 30),
              decoration: BoxDecoration(
                color: frameColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(4, 4))],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: const Color(0xFFEFEFEF),
                  child: images[index] == null
                      ? InkWell(
                          onTap: () => pickImage(index),
                          child: Icon(Icons.filter_frames_outlined, color: Colors.amber.withOpacity(0.3), size: 30),
                        )
                      : InteractiveViewer(
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(images[index]!, fit: BoxFit.cover),
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

// --- THE MISSING PAINTER CLASS ---
class BulbStringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bulbGlow = Paint()
      ..color = Colors.amber.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final bulbCore = Paint()..color = Colors.amberAccent;

    // Draw Row 1 Strings and Bulbs
    _drawRow(canvas, size, 90, 150, [0.34, 0.66], bulbGlow, bulbCore, stringPaint);
    // Draw Row 2 Strings and Bulbs
    _drawRow(canvas, size, 390, 450, [0.48], bulbGlow, bulbCore, stringPaint);
  }

  void _drawRow(Canvas canvas, Size size, double startY, double ctrlY, List<double> bulbPositions, Paint glow, Paint core, Paint string) {
    Path path = Path();
    path.moveTo(0, startY);
    path.quadraticBezierTo(size.width / 2, ctrlY, size.width, startY);
    canvas.drawPath(path, string);

    for (double t in bulbPositions) {
      double x = size.width * t;
      double y = (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * ctrlY + t * t * startY;
      canvas.drawLine(Offset(x, y), Offset(x, y + 20), Paint()..color = Colors.white24);
      canvas.drawCircle(Offset(x, y + 28), 10, glow);
      canvas.drawCircle(Offset(x, y + 28), 3, core);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}