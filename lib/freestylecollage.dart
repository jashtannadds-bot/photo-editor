import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

enum PhotoShape { original, square, circle, rounded, hexagon, diamond }

// --- DATA MODELS ---

class SimplePhoto {
  final String id;
  File image;
  double x, y, scale, rotation;
  double startScale = 1.0;
  double startRotation = 0.0;
  PhotoShape shape = PhotoShape.original;

  SimplePhoto({
    required this.id,
    required this.image,
    this.x = 150,
    this.y = 250,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class SimpleText {
  final String id;
  String text;
  double x, y, scale, rotation;
  double startScale = 1.0;
  double startRotation = 0.0;
  Color color;
  String fontFamily;

  SimpleText({
    required this.id,
    required this.text,
    this.x = 200,
    this.y = 300,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.color = Colors.white,
    this.fontFamily = 'Roboto',
  });
}

// --- PERFECT BORDER PAINTER ---

class ShapeBorderPainter extends CustomPainter {
  final Path path;
  final Color color;
  final double width;

  ShapeBorderPainter({required this.path, required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width <= 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2 // Multiply by 2 because stroke is centered on the path
      ..strokeJoin = StrokeJoin.round;
    
    canvas.save();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ShapeBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width || oldDelegate.path != path;
}

class ShapeClipperDelegate extends CustomClipper<Path> {
  final Path path;
  ShapeClipperDelegate(this.path);
  @override
  Path getClip(Size size) => path;
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

// --- MAIN SCREEN ---

class FreestyleCustomScreen extends StatefulWidget {
  const FreestyleCustomScreen({super.key});
  @override
  State<FreestyleCustomScreen> createState() => _FreestyleCustomScreenState();
}

class _FreestyleCustomScreenState extends State<FreestyleCustomScreen> {
  final ImagePicker _picker = ImagePicker();
  List<SimplePhoto> photos = [];
  List<SimpleText> textItems = [];
  late CollageStyle myStyle;
  final GlobalKey _freeKey = GlobalKey();
  
  bool _isHoldingItem = false;
  Offset _currentFingerPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 4.0,
      activeBackground: appBackgrounds[0],
    );
  }

  // --- PATH GENERATOR ---
  Path _getShapePath(PhotoShape shape, Size size) {
    switch (shape) {
      case PhotoShape.hexagon:
        return Path()
          ..moveTo(size.width * 0.25, 0)
          ..lineTo(size.width * 0.75, 0)
          ..lineTo(size.width, size.height * 0.5)
          ..lineTo(size.width * 0.75, size.height)
          ..lineTo(size.width * 0.25, size.height)
          ..lineTo(0, size.height * 0.5)
          ..close();
      case PhotoShape.diamond:
        return Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
      case PhotoShape.circle:
        return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
      case PhotoShape.rounded:
        return Path()..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(25)));
      default:
        return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
  }

  void _addNewTextDialog({SimpleText? existingItem}) {
  TextEditingController textController = TextEditingController(text: existingItem?.text ?? "");
  String selectedFont = existingItem?.fontFamily ?? 'Roboto';
  Color selectedColor = existingItem?.color ?? Colors.white;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Crucial for keyboard handling
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        // We use MediaQuery to detect how much space the keyboard is taking
        double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return Container(
          height: MediaQuery.of(context).size.height, // Full screen overlay
          color: Colors.black.withOpacity(0.9),
          child: Column(
            children: [
              // 1. TOP BAR
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        onPressed: () {
                          if (textController.text.isNotEmpty) {
                            setState(() {
                              if (existingItem != null) {
                                existingItem.text = textController.text;
                                existingItem.fontFamily = selectedFont;
                                existingItem.color = selectedColor;
                              } else {
                                textItems.add(SimpleText(
                                  id: DateTime.now().toString(),
                                  text: textController.text,
                                  fontFamily: selectedFont,
                                  color: selectedColor,
                                ));
                              }
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: Text(
                          existingItem != null ? "UPDATE" : "DONE",
                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. SCROLLABLE TEXT AREA (Automatically lifts above keyboard)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      controller: textController,
                      autofocus: true,
                      maxLines: null,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        color: selectedColor,
                        fontFamily: selectedFont,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Type here...",
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. FONT & COLOR TOOLS (Stays pinned to the top of the keyboard)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Font Selection
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: ['Roboto', 'Serif', 'Monospace'].map((font) {
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedFont = font),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedFont == font ? Colors.white : Colors.white10,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(font, 
                                style: TextStyle(
                                  color: selectedFont == font ? Colors.black : Colors.white,
                                  fontFamily: font,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Color Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Colors.white, Colors.redAccent, Colors.yellow, Colors.blueAccent, Colors.greenAccent].map((color) {
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color ? Colors.white : Colors.transparent,
                                width: 3
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // This adds the keyboard spacing at the bottom
                    SizedBox(height: keyboardHeight > 0 ? keyboardHeight : 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black38,
        title: const Text("FREESTYLE", style: TextStyle(fontSize: 10, letterSpacing: 3, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.text_fields,color: Colors.white,), onPressed: () => _addNewTextDialog()),
          IconButton(icon: const Icon(Icons.save_alt, color: Colors.greenAccent), 
              onPressed: () => CollageHelper.saveCollage(_freeKey, context)),
          IconButton(icon: const Icon(Icons.add_photo_alternate,color: Colors.white,), onPressed: () async {
            final p = await _picker.pickImage(source: ImageSource.gallery);
            if (p != null) setState(() => photos.add(SimplePhoto(id: DateTime.now().toString(), image: File(p.path))));
          }),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              key: _freeKey,
              child: Container(
                decoration: myStyle.activeBackground.decoration,
                child: Stack(
                  children: [
                    if (photos.isEmpty && textItems.isEmpty)
                      const Center(child: Text("DRAG & DROP ITEMS", style: TextStyle(color: Colors.white10, fontSize: 12))),
                    for (var photo in photos) _buildMoveableItem(photo, _renderFramedImage(photo)),
                    for (var text in textItems) _buildMoveableItem(text, _buildTextCore(text)),
                  ],
                ),
              ),
            ),
          ),
          if (_isHoldingItem) _buildStaticDustbin(),
          _buildBottomControlPanel(),
        ],
      ),
    );
  }

Widget _buildMoveableItem(dynamic item, Widget content) {
  return Positioned(
    left: item.x,
    top: item.y,
    child: FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // Crucial for catching touches
        onScaleStart: (details) {
          setState(() {
            _isHoldingItem = true;
            // Bring to front
            if (item is SimplePhoto) {
              photos.remove(item);
              photos.add(item);
            } else {
              textItems.remove(item);
              textItems.add(item);
            }
            // Capture initial state
            item.startScale = item.scale;
            item.startRotation = item.rotation;
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            // Track finger for Dustbin
            _currentFingerPos = details.focalPoint;
            
            // 1. Move
            item.x += details.focalPointDelta.dx;
            item.y += details.focalPointDelta.dy;

            // 2. Zoom & Rotate (Only if 2 fingers are used)
            if (details.pointerCount > 1) {
              item.scale = (item.startScale * details.scale).clamp(0.2, 10.0);
              item.rotation = item.startRotation + details.rotation;
            }

            // 3. Check for deletion
            _checkDustbinLogic(item);
          });
        },
        onScaleEnd: (details) {
          setState(() => _isHoldingItem = false);
        },
        onTap: () {
          if (item is SimplePhoto) {
            setState(() {
              int nextIndex = (item.shape.index + 1) % PhotoShape.values.length;
              item.shape = PhotoShape.values[nextIndex];
            });
          } else if (item is SimpleText) {
            _addNewTextDialog(existingItem: item);
          }
        },
        child: Transform.rotate(
          angle: item.rotation,
          child: Transform.scale(
            scale: item.scale,
            child: content,
          ),
        ),
      ),
    ),
  );
} // --- REFINED IMAGE RENDERER (PERFECT BORDERS) ---
  Widget _renderFramedImage(SimplePhoto photo) {
    double sizeValue = 150.0;
    bool isOriginal = photo.shape == PhotoShape.original;
    
    // We use a square canvas for shapes to keep logic simple
    Size renderSize = isOriginal ? const Size(200, 200) : Size(sizeValue, sizeValue);
    Path shapePath = _getShapePath(photo.shape, renderSize);

    return CustomPaint(
      // Foreground painter ensures the border is on top and follows the path perfectly
      foregroundPainter: isOriginal ? null : ShapeBorderPainter(
        path: shapePath,
        color: myStyle.borderColor,
        width: myStyle.borderWidth,
      ),
      child: ClipPath(
        clipper: ShapeClipperDelegate(shapePath),
        child: Container(
          width: isOriginal ? null : sizeValue,
          height: isOriginal ? null : sizeValue,
          constraints: isOriginal ? const BoxConstraints(maxWidth: 200, maxHeight: 200) : null,
          child: Image.file(
            photo.image, 
            fit: isOriginal ? BoxFit.contain : BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTextCore(SimpleText item) {
  return Container(
    // Padding gives your fingers a surface to grab for zooming
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    // Transparent color makes the entire box "touchable"
    color: Colors.transparent, 
    child: Text(
      item.text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: item.color,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: item.fontFamily,
        shadows: const [Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(2, 2))],
      ),
    ),
  );
}

  // --- OTHER UI HELPERS ---
  void _checkDustbinLogic(dynamic item) {
  // Use 80% height as the trigger line
  double screenHeight = MediaQuery.of(context).size.height;
  double dustbinLine = screenHeight * 0.80; 

  if (_currentFingerPos.dy > dustbinLine) {
    if (item is SimplePhoto) {
      photos.remove(item);
    } else if (item is SimpleText) {
      textItems.remove(item);
    }
    _isHoldingItem = false;
  }
}

  Widget _buildStaticDustbin() {
    bool isHovering = _currentFingerPos.dy > MediaQuery.of(context).size.height * 0.82;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 140, width: double.infinity,
        color: isHovering ? Colors.redAccent.withOpacity(0.8) : Colors.black45,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildBottomControlPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.45,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900]!.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 4, width: 40,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                ),
                CollageControlPanel(
                  style: myStyle,
                  onColorChanged: (c) => setState(() => myStyle.borderColor = c),
                  onWidthChanged: (w) => setState(() => myStyle.borderWidth = w),
                  onBackgroundChanged: (b) => setState(() => myStyle.activeBackground = b),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}