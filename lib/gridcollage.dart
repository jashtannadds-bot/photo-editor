import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collageimagehelper.dart';
// import 'collage_helper.dart'; // Import your helper file

class DynamicGridCollageScreen extends StatefulWidget {
  const DynamicGridCollageScreen({super.key});

  @override
  State<DynamicGridCollageScreen> createState() => _DynamicGridCollageScreenState();
}

class _DynamicGridCollageScreenState extends State<DynamicGridCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);

  // 1. Define the GlobalKey
  final GlobalKey _gridKey = GlobalKey();

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        images[index] = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        tooltip: 'Save Collage',
        onPressed: () => CollageHelper.saveCollage(_gridKey, context),
        label: const Text("Save"),
        icon: const Icon(Icons.download_rounded),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Asymmetric Layout", style: TextStyle(color: Colors.white, fontSize: 16)),
        // 2. Add the Save Button to AppBar
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download_rounded, color: Colors.white),
          //   onPressed: () => CollageHelper.saveCollage(_gridKey, context),
          // ),
          // const SizedBox(width: 8),
        ],
      ),
      // 3. Wrap everything in RepaintBoundary and a Container for background
      body: RepaintBoundary(
        key: _gridKey,
        child: Container(
          color: Colors.black, // Ensures background is black in the saved image
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              /// TOP SECTION: Dynamic Heights
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // 1. Large Portrait Rectangle
                    _buildInteractiveTile(0, flex: 1),
                    const SizedBox(width: 8),
                    // 2. Right Side Column
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildInteractiveTile(1, flex: 1),
                          const SizedBox(height: 8),
                          _buildInteractiveTile(2, flex: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              /// BOTTOM SECTION: Landscape Rectangles
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    _buildInteractiveTile(3, flex: 1),
                    const SizedBox(width: 8),
                    _buildInteractiveTile(4, flex: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveTile(int index, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: images[index] == null
            ? GestureDetector(
                onTap: () => pickImage(index),
                child: const Center(
                  child: Icon(Icons.add_photo_alternate_outlined, 
                      color: Colors.white30, size: 30),
                ),
              )
            : GestureDetector(
                onLongPress: () => pickImage(index),
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1,
                  maxScale: 5.0,
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(
                    images[index]!,
                    fit: BoxFit.contain, 
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
      ),
    );
  }
}