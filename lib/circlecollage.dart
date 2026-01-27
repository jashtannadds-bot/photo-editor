import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BubbleCollageScreen extends StatefulWidget {
  const BubbleCollageScreen({super.key});

  @override
  State<BubbleCollageScreen> createState() => _BubbleCollageScreenState();
}

class _BubbleCollageScreenState extends State<BubbleCollageScreen> {
  final ImagePicker picker = ImagePicker();
  // We'll use 6 bubbles for this aesthetic cluster
  List<File?> images = List.filled(6, null);

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        images[index] = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Deep Gen-Z black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Aesthetic Bubbles", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Center(
        child: SizedBox(
          width: size.width,
          height: size.height * 0.7,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Large Center Bubble
              _buildBubble(0, size: 220, top: 120, left: size.width * 0.22),

              // 2. Medium Top-Right
              _buildBubble(1, size: 140, top: 40, left: size.width * 0.55),

              // 3. Small Top-Left
              _buildBubble(2, size: 100, top: 80, left: size.width * 0.08),

              // 4. Medium Bottom-Left
              _buildBubble(3, size: 150, top: 320, left: size.width * 0.05),

              // 5. Large Bottom-Right
              _buildBubble(4, size: 180, top: 280, left: size.width * 0.45),

              // 6. Tiny Accent Bubble
              _buildBubble(5, size: 80, top: 240, left: size.width * 0.12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(int index, {required double size, required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: images[index] == null ? () => pickImage(index) : null,
        onLongPress: images[index] != null ? () => pickImage(index) : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1E1E),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipOval(
            child: images[index] == null
                ? const Icon(Icons.add, color: Colors.white24, size: 30)
                : InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.1,
                    maxScale: 5,
                    child: Image.file(
                      images[index]!,
                      fit: BoxFit.contain, // Shows full image initially
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