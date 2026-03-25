import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/collage_models.dart';
import 'package:photho_editor/sharedstyle.dart';

class RoundedQuartersCollageScreen extends StatefulWidget {
  final List<File>? initialImages;
  const RoundedQuartersCollageScreen({super.key, this.initialImages});

  @override
  State<RoundedQuartersCollageScreen> createState() => _RoundedQuartersCollageScreenState();
}

class _RoundedQuartersCollageScreenState extends State<RoundedQuartersCollageScreen> {
  final ImagePicker picker = ImagePicker();
  late List<File?> images;
  final GlobalKey _collageKey = GlobalKey();

  List<TextProperties> textItems = [];
  late CollageStyle myStyle;
  bool isDraggingText = false;

  @override
  void initState() {
    super.initState();
    images = List.filled(4, null);
    if (widget.initialImages != null) {
      for (int i = 0; i < widget.initialImages!.length && i < 4; i++) {
        images[i] = widget.initialImages![i];
      }
    }

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
          "ROUNDED QUARTERS",
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
            onPressed: () => CollageHelper.saveCollage(_collageKey, context),
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
                    key: _collageKey,
                    child: Container(
                      decoration: myStyle.activeBackground.decoration,
                      width: size.width,
                      height: size.width, // Make it square for perfect quarters
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildItem(0, topLeft: const Radius.circular(250)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildItem(1, topRight: const Radius.circular(250)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildItem(2, bottomLeft: const Radius.circular(250)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildItem(3, bottomRight: const Radius.circular(250)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

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
              const SizedBox(height: 100),
            ],
          ),

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
                  child: CollageControlPanel(
                    style: myStyle,
                    onColorChanged: (newColor) =>
                        setState(() => myStyle.borderColor = newColor),
                    onWidthChanged: (newWidth) =>
                        setState(() => myStyle.borderWidth = newWidth),
                    onBackgroundChanged: (newBg) =>
                        setState(() => myStyle.activeBackground = newBg),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    int index, {
    Radius topLeft = Radius.zero,
    Radius topRight = Radius.zero,
    Radius bottomLeft = Radius.zero,
    Radius bottomRight = Radius.zero,
  }) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151515).withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight,
          ),
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
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight,
          ),
          child: images[index] == null
              ? Icon(
                  Icons.add_photo_alternate,
                  color: myStyle.borderColor.withOpacity(0.3),
                  size: 50,
                )
              : InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.file(
                    images[index]!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}

// Ensure we have DraggableTextWidget and TextProperties by including this or they will be undefined if we didn't import them.
// Wait! In circlecollage.dart, they are defined AT THE BOTTOM OF THE FILE. 
// They are not exported! So my import 'package:photho_editor/circlecollage.dart' would be needed, or I redefine them.
// OR move them to commontext.dart. But I shouldn't mess up too much, let's redefine them for now as it's quicker and safer.
// Wait! Let me check commontext.dart. It has CollageTextHandler... but does it have DraggableTextWidget?
