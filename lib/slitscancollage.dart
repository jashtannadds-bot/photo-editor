// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:photho_editor/collageimagehelper.dart';

// class SlitScanCollage extends StatefulWidget {
//   const SlitScanCollage({super.key});

//   @override
//   State<SlitScanCollage> createState() => _SlitScanCollageState();
// }

// class _SlitScanCollageState extends State<SlitScanCollage> {
//   final ImagePicker picker = ImagePicker();
//   // Updated to 5 images
//   List<File?> images = List.filled(5, null);
//   final GlobalKey _slitKey = GlobalKey();

//   Color accentColor = Colors.white;
//   double borderWidth = 2.0;
//   double internalSpacing = 4.0;

//   Future<void> pickImage(int index) async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) setState(() => images[index] = File(picked.path));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0A),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 110.0), // Above control panel
//         child: FloatingActionButton.extended(
//           backgroundColor: Colors.pinkAccent,
//           onPressed: () => CollageHelper.saveCollage(_slitKey, context),
//           label: const Text("Save", style: TextStyle(color: Colors.white)),
//           icon: const Icon(Icons.download_rounded, color: Colors.white),
//         ),
//       ),
//       appBar: AppBar(
//         title: const Text(
//           "EDITORIAL 5-SLIT",
//           style: TextStyle(
//             fontSize: 10,
//             letterSpacing: 4,
//             color: Colors.white70,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: const BackButton(color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: RepaintBoundary(
//                 key: _slitKey,
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   color: const Color(0xFF0A0A0A), // Export Background
//                   child: AspectRatio(
//                     aspectRatio: 0.85,
//                     child: Row(
//                       children: [
//                         _buildSlit(0, flex: 2),
//                         SizedBox(width: internalSpacing),
//                         _buildSlit(1, flex: 3),
//                         SizedBox(width: internalSpacing),
//                         _buildSlit(2, flex: 4), // Center "Hero" Slit
//                         SizedBox(width: internalSpacing),
//                         _buildSlit(3, flex: 3),
//                         SizedBox(width: internalSpacing),
//                         _buildSlit(4, flex: 2),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           _buildControlPanel(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSlit(int index, {required int flex}) {
//     return Expanded(
//       flex: flex,
//       child: GestureDetector(
//         onTap: () => pickImage(index),
//         child: Container(
//           // BORDER LOGIC
//           decoration: BoxDecoration(
//             color: const Color(0xFF151515),
//             border: Border.all(color: accentColor, width: borderWidth),
//           ),
//           child: images[index] == null
//               ? Center(
//                   child: Icon(
//                     Icons.add_photo_alternate_outlined,
//                     color: accentColor.withOpacity(0.3),
//                     size: 20,
//                   ),
//                 )
//               : ClipRect(
//                   // Ensures zoom doesn't bleed out of the slit
//                   child: InteractiveViewer(
//                     clipBehavior: Clip.hardEdge,
//                     boundaryMargin: const EdgeInsets.all(double.infinity),
//                     minScale: 0.5,
//                     maxScale: 4.0,
//                     child: Image.file(
//                       images[index]!,
//                       fit: BoxFit.cover,
//                       height: double.infinity,
//                       width: double.infinity,
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget _buildControlPanel() {
//     final List<Color> palette = [
//       Colors.white,
//       Colors.redAccent,
//       Colors.yellowAccent,
//       Colors.cyanAccent,
//       Colors.purpleAccent,
//     ];
//     return Container(
//       padding: const EdgeInsets.all(20),
//       color: Colors.black,
//       child: SafeArea(
//         top: false,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // BORDER WIDTH SLIDER
//             Row(
//               children: [
//                 const Icon(Icons.line_weight, color: Colors.white54, size: 18),
//                 Expanded(
//                   child: Slider(
//                     value: borderWidth,
//                     min: 0.0,
//                     max: 10.0,
//                     activeColor: Colors.white,
//                     onChanged: (v) => setState(() => borderWidth = v),
//                   ),
//                 ),
//               ],
//             ),
//             // COLOR PALETTE
//             SizedBox(
//               height: 45,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: palette.length,
//                 itemBuilder: (context, i) => GestureDetector(
//                   onTap: () => setState(() => accentColor = palette[i]),
//                   child: Container(
//                     width: 40,
//                     margin: const EdgeInsets.only(right: 15),
//                     decoration: BoxDecoration(
//                       color: palette[i],
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: accentColor == palette[i]
//                             ? Colors.white
//                             : Colors.transparent,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collagecontrol.dart';
import 'package:photho_editor/collageimagehelper.dart'; // Ensure correct path
import 'package:photho_editor/sharedstyle.dart';      // Ensure correct path

class SlitScanCollage extends StatefulWidget {
  const SlitScanCollage({super.key});

  @override
  State<SlitScanCollage> createState() => _SlitScanCollageState();
}

class _SlitScanCollageState extends State<SlitScanCollage> {
  final ImagePicker picker = ImagePicker();
  List<File?> images = List.filled(5, null);
  final GlobalKey _slitKey = GlobalKey();

  // 1. Initialize our shared style object
  late CollageStyle myStyle;

  @override
  void initState() {
  super.initState();
  // Initialize immediately with the first item from your global list
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

  void resetCollage() {
    setState(() {
      images = List.filled(5, null);
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
        title: const Text("EDITORIAL 5-SLIT", 
          style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
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
                key: _slitKey,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  // 2. Dynamic Background from common class
                  decoration: myStyle.activeBackground?.decoration ?? const BoxDecoration(color: Colors.black),
                  child: AspectRatio(
                    aspectRatio: 0.85,
                    child: Row(
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
                  ),
                ),
              ),
            ),
          ),
          
          // 3. Floating Save Button integrated before the control panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () => CollageHelper.saveCollage(_slitKey, context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("SAVE COLLAGE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 4. THE COMMON CONTROL PANEL
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

  Widget _buildSlit(int index, {required int flex}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => pickImage(index),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515).withOpacity(0.5),
            // 5. Dynamic Border from common class
            border: Border.all(color: myStyle.borderColor, width: myStyle.borderWidth),
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
                    boundaryMargin: const EdgeInsets.all(double.infinity),
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