import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collageimagehelper.dart';
// import 'collage_helper.dart'; // Ensure your helper class is available

class MoodboardMuseCollage extends StatefulWidget {
  const MoodboardMuseCollage({super.key});

  @override
  State<MoodboardMuseCollage> createState() => _MoodboardMuseCollageState();
}

class _MoodboardMuseCollageState extends State<MoodboardMuseCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);

  // 1. Define the GlobalKey for capturing
  final GlobalKey _moodboardKey = GlobalKey();

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => images[index] = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        tooltip: 'Save Collage',
        onPressed: () => CollageHelper.saveCollage(_moodboardKey, context),
        label: const Text("Save"),
        icon: const Icon(Icons.download_rounded),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        title: const Text("MOODBOARD MUSE", 
          style: TextStyle(fontSize: 14, letterSpacing: 2, color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        // 2. Add Save Button
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download_rounded, color: Colors.white),
          //   onPressed: () => CollageHelper.saveCollage(_moodboardKey, context),
          // ),
          // const SizedBox(width: 8),
        ],
      ),
      body: Center(
        // 3. Wrap the stack in a RepaintBoundary
        child: RepaintBoundary(
          key: _moodboardKey,
          child: Container(
            color: const Color(0xFF0A0A0A), // Solid background for clean capture
            width: w * 0.95,
            height: w * 1.3,
            child: Stack(
              children: [
                // 1. Large Background Vertical
                _buildFrame(0, top: 40, left: 10, width: w * 0.5, height: w * 0.8),
                
                // 2. Mid-size Square (Top Right)
                _buildFrame(1, top: 0, right: 10, width: w * 0.4, height: w * 0.4),
                
                // 3. Small Accent Square (Middle Right Overlap)
                _buildFrame(2, top: w * 0.45, right: 0, width: w * 0.45, height: w * 0.3),
                
                // 4. Horizontal Wide (Bottom Left)
                _buildFrame(3, bottom: 20, left: 0, width: w * 0.6, height: w * 0.35),
                
                // 5. The "Hero" Square (Bottom Right - Floating on top)
                _buildFrame(4, bottom: 0, right: 20, width: w * 0.35, height: w * 0.45, isHero: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrame(int index, {double? top, double? left, double? right, double? bottom, required double width, required double height, bool isHero = false}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(4, 4),
            )
          ],
        ),
        child: GestureDetector(
          onTap: () => pickImage(index),
          child: Container(
            color: const Color(0xFF1A1A1A),
            child: images[index] == null
                ? const Icon(Icons.add, color: Colors.white24)
                : InteractiveViewer(
                    clipBehavior: Clip.hardEdge,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.1,
                    maxScale: 5.0,
                    child: Image.file(images[index]!, fit: BoxFit.cover),
                  ),
          ),
        ),
      ),
    );
  }
}