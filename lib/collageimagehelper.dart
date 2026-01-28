import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart'; // Import gal instead
import 'package:path_provider/path_provider.dart';

class CollageHelper {
  /// Captures the widget and saves it using the 'gal' package.
  static Future<void> saveCollage(GlobalKey boundaryKey, BuildContext context) async {
    try {
      // 1. Capture the widget as an image
      RenderRepaintBoundary? boundary = 
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return;

      // Use a high pixel ratio for print-quality sharpness
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // 2. 'gal' requires a file path to save, so we save to temporary storage first
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/collage_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(imagePath);
        await file.writeAsBytes(pngBytes);

        // 3. Save to Gallery using gal
        // It automatically handles necessary permission checks internally
        await Gal.putImage(file.path);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✨ Saved to Gallery!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Save Error: $e");
      
      // Handle the case where the user denied permission
      if (e is GalException && e.type == GalExceptionType.accessDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied. Please allow gallery access.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
}