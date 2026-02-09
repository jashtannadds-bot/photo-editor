import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/heartcollage.dart';
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

  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

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
      myStyle.borderWidth = 4.0;
      myStyle.activeBackground = appBackgrounds[0];
    });
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 4,
            color: Colors.white70,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: () => _handleTextAction(),
          ),
          TextButton(
            onPressed: () => CollageHelper.saveCollage(_gridKey, context),
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
                    key: _gridKey,
                    child: Container(
                      decoration: myStyle.activeBackground.decoration,
                      padding: EdgeInsets.all(gap),
                      child: AspectRatio(
                        aspectRatio: 0.8,
                        child: Stack(
                          children: [
                            /// THE GRID
                            Column(
                              children: [
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

                            /// FLOATING TEXT
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
              const SizedBox(height: 100),
            ],
          ),

          /// THE DUSTBIN
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

          /// DRAGGABLE BOTTOM SHEET (Matching previous screens)
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

  Widget _buildInteractiveTile(int index, {required int flex}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: images[index] == null ? () => pickImage(index) : null,
        onDoubleTap: () => pickImage(index),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withOpacity(0.5),
            border: Border.all(
              color: myStyle.borderColor.withOpacity(0.3),
              width: 0.5,
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
                  boundaryMargin: const EdgeInsets.all(200),
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

// Ensure TextProperties and DraggableTextWidget classes are defined below...
