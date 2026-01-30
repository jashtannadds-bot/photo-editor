import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class BubbleCollageScreen extends StatefulWidget {
  const BubbleCollageScreen({super.key});

  @override
  State<BubbleCollageScreen> createState() => _BubbleCollageScreenState();
}

class _BubbleCollageScreenState extends State<BubbleCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(6, null);
  final GlobalKey _bubbleKey = GlobalKey();

  // 1. Initialize with the shared CollageStyle
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 3.0,
      activeBackground: appBackgrounds[0], 
    );
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        images[index] = File(picked.path);
      });
    }
  }

  void resetCollage() {
    setState(() {
      images = List.filled(6, null);
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 3.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "EDITORIAL BUBBLES",
          style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white70),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white60),
            onPressed: resetCollage,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _bubbleKey,
                child: Container(
                  // 2. Apply Dynamic Background from your shared class
                  decoration: myStyle.activeBackground.decoration,
                  width: size.width,
                  height: size.height * 0.7,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildBubble(0, size: 210, top: 100, left: size.width * 0.2),
                      _buildBubble(1, size: 130, top: 30, left: size.width * 0.58),
                      _buildBubble(2, size: 90, top: 70, left: size.width * 0.05),
                      _buildBubble(3, size: 140, top: 310, left: size.width * 0.05),
                      _buildBubble(4, size: 170, top: 270, left: size.width * 0.45),
                      _buildBubble(5, size: 80, top: 230, left: size.width * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Integrated Save Button (Matches Slit Scan & Heart)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_bubbleKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("SAVE COLLAGE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 4. Shared Control Panel
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

  Widget _buildBubble(
    int index, {
    required double size,
    required double top,
    required double left,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => pickImage(index),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF151515).withOpacity(0.5),
            // 5. Use Border logic from myStyle
            border: Border.all(
              color: myStyle.borderColor,
              width: myStyle.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: myStyle.borderColor.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: images[index] == null
                ? Icon(
                    Icons.bubble_chart_outlined,
                    color: myStyle.borderColor.withOpacity(0.3),
                    size: size * 0.3,
                  )
                : InteractiveViewer(
                    clipBehavior: Clip.hardEdge,
                    child: Image.file(
                      images[index]!,
                      fit: BoxFit.cover,
                      width: size,
                      height: size,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}