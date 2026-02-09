import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/flowercollage.dart';
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

  // Shared state for Text and UI behavior
  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

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
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 4,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () => _handleTextAction(),
          ),
          TextButton(
            onPressed: () => CollageHelper.saveCollage(_moodboardKey, context),
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
                child: Center(
                  child: RepaintBoundary(
                    key: _moodboardKey,
                    child: Container(
                      decoration: myStyle.activeBackground.decoration,
                      width: w * 0.95,
                      height: w * 1.3,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildFrame(
                            0,
                            top: 40,
                            left: 10,
                            width: w * 0.5,
                            height: w * 0.8,
                          ),
                          _buildFrame(
                            1,
                            top: 0,
                            right: 10,
                            width: w * 0.4,
                            height: w * 0.4,
                          ),
                          _buildFrame(
                            2,
                            top: w * 0.45,
                            right: 0,
                            width: w * 0.45,
                            height: w * 0.3,
                          ),
                          _buildFrame(
                            3,
                            bottom: 20,
                            left: 0,
                            width: w * 0.6,
                            height: w * 0.35,
                          ),
                          _buildFrame(
                            4,
                            bottom: 0,
                            right: 20,
                            width: w * 0.35,
                            height: w * 0.45,
                            isHero: true,
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
                      ),
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
          onTap: images[index] == null ? () => pickImage(index) : null,
          onDoubleTap: () => pickImage(index),
          child: images[index] == null
              ? Icon(Icons.add, color: myStyle.borderColor.withOpacity(0.3))
              : InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(400),
                  minScale: 1.0,
                  maxScale: 5.0,
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
