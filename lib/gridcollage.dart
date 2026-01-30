import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/sharedstyle.dart';

class DynamicGridCollageScreen extends StatefulWidget {
  const DynamicGridCollageScreen({super.key});

  @override
  State<DynamicGridCollageScreen> createState() =>
      _DynamicGridCollageScreenState();
}

class _DynamicGridCollageScreenState extends State<DynamicGridCollageScreen> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _gridKey = GlobalKey();

  // 1. Unified Style initialization
  late CollageStyle myStyle;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 4.0,
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
      images = List.filled(5, null);
      myStyle.borderColor = Colors.white;
      myStyle.borderWidth = 4.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use the shared borderWidth to drive the spacing between tiles
    final double gap = myStyle.borderWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "ASYMMETRIC GRID",
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
                key: _gridKey,
                child: Container(
                  // 2. Dynamic Background logic applied here
                  decoration: myStyle.activeBackground.decoration,
                  padding: EdgeInsets.all(gap),
                  child: AspectRatio(
                    aspectRatio: 0.8, // Fixed ratio for clean export
                    child: Column(
                      children: [
                        /// TOP SECTION: Large Portrait + 2 Small Squares
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              _buildInteractiveTile(0, flex: 1),
                              SizedBox(width: gap),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildInteractiveTile(1, flex: 1),
                                    SizedBox(height: gap),
                                    _buildInteractiveTile(2, flex: 1),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: gap),

                        /// BOTTOM SECTION: 2 Landscape Rectangles
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              _buildInteractiveTile(3, flex: 1),
                              SizedBox(width: gap),
                              _buildInteractiveTile(4, flex: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Integrated Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_gridKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("SAVE COLLAGE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 4. Shared Control Panel (Handles colors, widths, and backgrounds)
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

  Widget _buildInteractiveTile(int index, {required int flex}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => pickImage(index),
        onLongPress: () => pickImage(index),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withOpacity(0.5),
            border: Border.all(
              color: myStyle.borderColor.withOpacity(0.5),
              width: 0.5, // Thin inner divider look
            ),
          ),
          child: images[index] == null
              ? Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: myStyle.borderColor.withOpacity(0.3),
                    size: 24,
                  ),
                )
              : InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(
                    images[index]!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }
}