import 'package:flutter/material.dart';
import 'package:photho_editor/sharedstyle.dart'; // Ensure BackgroundStyle is defined here

class CollageControlPanel extends StatelessWidget {
  final CollageStyle style;
  final Function(Color) onColorChanged;
  final Function(double) onWidthChanged;
  // NEW: Callback for background changes
  final Function(BackgroundStyle) onBackgroundChanged;

  const CollageControlPanel({
    super.key,
    required this.style,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onBackgroundChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.amber,
      Colors.green,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Border Width",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          Slider(
            value: style.borderWidth,
            min: 0,
            max: 20,
            onChanged: onWidthChanged,
            activeColor: Colors.amber,
          ),

          const Text(
            "Border Color",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 8),
          // Horizontal list for Color Palette
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => onColorChanged(colors[index]),
                child: Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: style.borderColor == colors[index]
                          ? Colors.amber
                          : Colors.white24,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            "Background Gradient",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 8),

          // NEW: Horizontal list for Background Gradients
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: appBackgrounds
                  .length, // appBackgrounds list defined in sharedstyle
              itemBuilder: (context, index) {
                final bg = appBackgrounds[index];
                return GestureDetector(
                  onTap: () => onBackgroundChanged(bg),
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: bg.decoration.copyWith(
                      // This now uses the 2-color LinearGradient
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: style.activeBackground?.name == bg.name
                            ? Colors.amber
                            : Colors.white24,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
