import 'package:flutter/material.dart';
import 'dart:ui';

class CollageTextHandler {
  static void showTextEditor({
    required BuildContext context,
    String? initialText,
    Color? initialColor,
    String? initialFont,
    required Function(String text, Color color, String font) onComplete,
  }) {
    TextEditingController controller = TextEditingController(text: initialText ?? "");
    Color selectedColor = initialColor ?? Colors.white;
    String selectedFont = initialFont ?? 'Roboto';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setST) {
          double kbHeight = MediaQuery.of(context).viewInsets.bottom;
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.85),
              child: Column(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                          TextButton(
                            onPressed: () {
                              if (controller.text.isNotEmpty) {
                                onComplete(controller.text, selectedColor, selectedFont);
                              }
                              Navigator.pop(context);
                            },
                            child: const Text("DONE", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        maxLines: null,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: selectedColor, fontFamily: selectedFont, fontSize: 38, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: "TYPE...", hintStyle: TextStyle(color: Colors.white24)),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: kbHeight + 20, top: 20),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFontPicker(selectedFont, (f) => setST(() => selectedFont = f)),
                        const SizedBox(height: 20),
                        _buildColorPicker(selectedColor, (c) => setST(() => selectedColor = c)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildFontPicker(String current, Function(String) onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: ['Roboto', 'Serif', 'Monospace'].map((f) => GestureDetector(
          onTap: () => onSelect(f),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: current == f ? Colors.pinkAccent : Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(f, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )),
        ).toList(),
      ),
    );
  }

  static Widget _buildColorPicker(Color current, Function(Color) onSelect) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Colors.white, Colors.redAccent, Colors.yellowAccent, Colors.blueAccent, Colors.greenAccent].map((c) => GestureDetector(
        onTap: () => onSelect(c),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: c, 
            shape: BoxShape.circle, 
            border: Border.all(color: current == c ? Colors.white : Colors.transparent, width: 3)
          ),
        )),
      ).toList(),
    );
  }
}