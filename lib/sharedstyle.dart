import 'package:flutter/material.dart';

class BackgroundStyle {
  final String name;
  final Color color1; // First Color
  final Color color2; // Second Color
  final bool isGradient;

  BackgroundStyle({
    required this.name,
    required this.color1,
    required this.color2,
    this.isGradient = true,
  });

  BoxDecoration get decoration {
    if (isGradient) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2], // Strictly two colors
        ),
      );
    }
    return BoxDecoration(color: color1); // Fallback to solid color
  }
}
class CollageStyle {
  Color borderColor;
  double borderWidth;
  BackgroundStyle activeBackground; // Removed the '?' to make it non-nullable

  CollageStyle({
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    required this.activeBackground, // Force a background to be provided
  });
}
// Global list of clean 2-color background presets
final List<BackgroundStyle> appBackgrounds = [
  // 1. Cyberpunk Punch (Neon Pink to Deep Blue)
  BackgroundStyle(name: "Cyber Neon", color1: const Color(0xFFFF0080), color2: const Color(0xFF2E008B)),
  
  // 2. Electric Lime (Vivid Green to Midnight)
  BackgroundStyle(name: "Toxic Glow", color1: const Color(0xFFADFF2F), color2: const Color(0xFF002200)),
  
  // 3. Retro Sunset (Chunky Orange to Deep Violet)
  BackgroundStyle(name: "Vaporwave", color1: const Color(0xFFFF8C00), color2: const Color(0xFF4B0082)),
  
  // 4. Arctic Blaze (Electric Cyan to Royal Blue)
  BackgroundStyle(name: "Glacier Blue", color1: const Color(0xFF00F2FE), color2: const Color(0xFF4FACFE)),
  
  // 5. Acid Yellow (Bright Yellow to Forest Green)
  BackgroundStyle(name: "Acid Wash", color1: const Color(0xFFF7FF00), color2: const Color(0xFF134E5E)),
  
  // 6. Cherry Bomb (Vibrant Red to Onyx Black)
  BackgroundStyle(name: "Hard Red", color1: const Color(0xFFFF0000), color2: const Color(0xFF000000)),
];