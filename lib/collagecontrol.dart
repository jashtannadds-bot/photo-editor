import 'package:flutter/material.dart';
import 'package:photho_editor/sharedstyle.dart'; 

class CollageControlPanel extends StatelessWidget {
  final CollageStyle style;
  final Function(Color) onColorChanged;
  final Function(double) onWidthChanged;
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      // We keep the decoration minimal as it's usually inside a DraggableSheet
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. DRAG HANDLE (For the DraggableSheet feel)
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // 2. BORDER WIDTH SECTION
          _buildSectionHeader("BORDER WIDTH"),
          Slider(
            value: style.borderWidth,
            min: 0,
            max: 20,
            onChanged: onWidthChanged,
            activeColor: Colors.amber,
            inactiveColor: Colors.white12,
          ),

          const SizedBox(height: 10),

          // 3. BORDER COLOR SECTION
          _buildSectionHeader("BORDER COLOR"),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => onColorChanged(colors[index]),
                child: Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: style.borderColor == colors[index]
                          ? Colors.amber
                          : Colors.white24,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 4. BACKGROUND GRADIENT SECTION
          _buildSectionHeader("BACKGROUND GRADIENT"),
          const SizedBox(height: 12),
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: appBackgrounds.length,
              itemBuilder: (context, index) {
                final bg = appBackgrounds[index];
                return GestureDetector(
                  onTap: () => onBackgroundChanged(bg),
                  child: Container(
                    width: 55,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: bg.decoration.copyWith(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: style.activeBackground.name == bg.name
                            ? Colors.amber
                            : Colors.white24,
                        width: 2.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }

  // Helper to keep the titles consistent and clean
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}