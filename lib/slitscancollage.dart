import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/flowercollage.dart';
import 'package:photho_editor/sharedstyle.dart';

class SlitScanCollage extends StatefulWidget {
  const SlitScanCollage({super.key});

  @override
  State<SlitScanCollage> createState() => _SlitScanCollageState();
}

class _SlitScanCollageState extends State<SlitScanCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _slitKey = GlobalKey();

  // Shared state for Text and UI behavior
  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

  @override
  void initState() {
    super.initState();
    myStyle = CollageStyle(
      borderColor: Colors.white,
      borderWidth: 2.0,
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
      myStyle.borderWidth = 2.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "EDITORIAL 5-SLIT",
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 4,
            color: Colors.white70,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () => _handleTextAction(),
          ),
          TextButton(
            onPressed: () => CollageHelper.saveCollage(_slitKey, context),
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
                    key: _slitKey,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: myStyle.activeBackground.decoration,
                      child: AspectRatio(
                        aspectRatio: 0.85,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              children: [
                                _buildSlit(0, flex: 2),
                                const SizedBox(width: 4),
                                _buildSlit(1, flex: 3),
                                const SizedBox(width: 4),
                                _buildSlit(2, flex: 4),
                                const SizedBox(width: 4),
                                _buildSlit(3, flex: 3),
                                const SizedBox(width: 4),
                                _buildSlit(4, flex: 2),
                              ],
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

  Widget _buildSlit(int index, {required int flex}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: images[index] == null ? () => pickImage(index) : null,
        onDoubleTap: () => pickImage(index),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withOpacity(0.5),
            border: Border.all(
              color: myStyle.borderColor,
              width: myStyle.borderWidth,
            ),
          ),
          child: images[index] == null
              ? Center(
                  child: Icon(
                    Icons.filter_frames_outlined,
                    color: myStyle.borderColor.withOpacity(0.3),
                    size: 20,
                  ),
                )
              : ClipRect(
                  child: InteractiveViewer(
                    clipBehavior: Clip.hardEdge,
                    boundaryMargin: const EdgeInsets.all(500),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      images[index]!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
