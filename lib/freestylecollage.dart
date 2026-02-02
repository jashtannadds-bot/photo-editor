import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class SimplePhoto {
  File image;
  double x;
  double y;
  double scale;
  double rotation;

  SimplePhoto({
    required this.image,
    this.x = 50.0,
    this.y = 50.0,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class FreestyleCustomScreen extends StatefulWidget {
  const FreestyleCustomScreen({super.key});

  @override
  State<FreestyleCustomScreen> createState() => _FreestyleCustomScreenState();
}

class _FreestyleCustomScreenState extends State<FreestyleCustomScreen> {
  final ImagePicker _picker = ImagePicker();
  List<SimplePhoto> photos = [];
  final GlobalKey _saveKey = GlobalKey();
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 6.0,
      activeBackground: appBackgrounds[0],
    );
  }

  Future<void> _addPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        photos.add(SimplePhoto(image: File(picked.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("FREESTYLE CANVAS", style: TextStyle(fontSize: 10, letterSpacing: 3)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.add_photo_alternate, color: Colors.pinkAccent), onPressed: _addPhoto),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => photos.clear())),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _saveKey,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: myStyle.activeBackground.decoration,
                child: Stack(
                  children: [
                    if (photos.isEmpty)
                      const Center(child: Text("TAP + TO ADD PHOTOS", style: TextStyle(color: Colors.white24))),
                    
                    // Render each photo
                    for (int i = 0; i < photos.length; i++)
                      _buildPhotoItem(i),
                  ],
                ),
              ),
            ),
          ),
          
          CollageControlPanel(
            style: myStyle,
            onColorChanged: (c) => setState(() => myStyle.borderColor = c),
            onWidthChanged: (w) => setState(() => myStyle.borderWidth = w),
            onBackgroundChanged: (b) => setState(() => myStyle.activeBackground = b),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    final photo = photos[index];

    return Positioned(
      left: photo.x,
      top: photo.y,
      child: GestureDetector(
        onScaleStart: (_) {
          // Bring to front
          setState(() {
            final p = photos.removeAt(index);
            photos.add(p);
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            // 1. Handle Movement (Drag)
            photo.x += details.focalPointDelta.dx;
            photo.y += details.focalPointDelta.dy;

            // 2. Handle Zoom (Scale) - clamp to keep it visible
            photo.scale = (photo.scale * details.scale).clamp(0.2, 5.0);

            // 3. Handle Rotation
            photo.rotation += details.rotation;
          });
        },
        child: Transform.rotate(
          angle: photo.rotation,
          child: Transform.scale(
            scale: photo.scale,
            child: _photoFrame(photo.image),
          ),
        ),
      ),
    );
  }

  Widget _photoFrame(File file) {
    return Container(
      width: 180,
      padding: EdgeInsets.all(myStyle.borderWidth),
      decoration: BoxDecoration(
        color: myStyle.borderColor,
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(4, 4)),
        ],
      ),
      child: Image.file(file, fit: BoxFit.contain),
    );
  }
}