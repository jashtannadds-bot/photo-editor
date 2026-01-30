import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class MoodboardMuseCollage extends StatefulWidget {
  const MoodboardMuseCollage({super.key});

  @override
  State<MoodboardMuseCollage> createState() => _MoodboardMuseCollageState();
}

class _MoodboardMuseCollageState extends State<MoodboardMuseCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _moodboardKey = GlobalKey();

  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 1.5,
      activeBackground: appBackgrounds[0],
    );
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => images[index] = File(picked.path));
  }

  void resetCollage() {
    setState(() {
      images = List.filled(5, null);
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 1.5;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "MOODBOARD MUSE",
          style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white70),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white60),
            onPressed: resetCollage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _moodboardKey,
                child: Container(
                  decoration: myStyle.activeBackground.decoration,
                  width: w * 0.95,
                  height: w * 1.3,
                  child: Stack(
                    children: [
                      _buildFrame(0, top: 40, left: 10, width: w * 0.5, height: w * 0.8),
                      _buildFrame(1, top: 0, right: 10, width: w * 0.4, height: w * 0.4),
                      _buildFrame(2, top: w * 0.45, right: 0, width: w * 0.45, height: w * 0.3),
                      _buildFrame(3, bottom: 20, left: 0, width: w * 0.6, height: w * 0.35),
                      _buildFrame(4, bottom: 0, right: 20, width: w * 0.35, height: w * 0.45, isHero: true),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Action Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => CollageHelper.saveCollage(_moodboardKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("EXPORT ASSET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          // Shared Style Controls
          CollageControlPanel(
            style: myStyle,
            onColorChanged: (newColor) => setState(() => myStyle.borderColor = newColor),
            onWidthChanged: (newWidth) => setState(() => myStyle.borderWidth = newWidth),
            onBackgroundChanged: (newBg) => setState(() => myStyle.activeBackground = newBg),
          ),
        ],
      ),
    );
  }

  Widget _buildFrame(
    int index, {
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double width,
    required double height,
    bool isHero = false,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: myStyle.borderColor,
            width: isHero ? myStyle.borderWidth * 1.8 : myStyle.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: isHero ? 4 : 0,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => pickImage(index),
          child: images[index] == null
              ? Icon(Icons.add, color: myStyle.borderColor.withOpacity(0.3))
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(images[index]!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}