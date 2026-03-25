import 'dart:typed_data';
import 'dart:ui' show Offset, Size;
import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'package:dio/dio.dart';

class OnnxInpainter {
  final OnnxRuntime _runtime = OnnxRuntime();
  OrtSession? _session;
  bool _isInitialized = false;

  final String _modelUrl =
      'https://huggingface.co/Carve/LaMa-ONNX/resolve/main/lama_fp32.onnx';

  Future<void> initialize(String path) async {
    try {
      debugPrint('[OnnxInpainter] Initializing with model: $path');
      final sessionOptions = OrtSessionOptions();
      _session = await _runtime.createSession(path, options: sessionOptions);
      _isInitialized = true;
      debugPrint('[OnnxInpainter] Session created successfully.');
    } catch (e) {
      debugPrint('[OnnxInpainter] Initialization error: $e');
      rethrow;
    }
  }

  Future<void> downloadModel(
    String savePath, {
    required Function(double) onProgress,
  }) async {
    try {
      final dio = Dio();
      await dio.download(
        _modelUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
    } catch (e) {
      debugPrint('[OnnxInpainter] Download error: $e');
      rethrow;
    }
  }

  Future<Uint8List?> inpaint(
    Uint8List imageBytes,
    List<List<Offset>> strokes,
    double brushSize, {
    required Size containerSize,
    required Function(String) onStatus,
  }) async {
    if (!_isInitialized || _session == null) {
      throw Exception('OnnxInpainter not initialized');
    }

    onStatus("Preparing images...");

    // 1. Decode original image
    final original = img.decodeImage(imageBytes);
    if (original == null) return null;

    final int origW = original.width;
    final int origH = original.height;

    // 2. Create Mask
    onStatus("Creating mask...");
    final mask = img.Image(width: origW, height: origH, numChannels: 1);
    mask.clear(img.ColorUint8.rgb(0, 0, 0));

    // Calculate mapping from container to original image (BoxFit.contain logic)
    final double containerAspect = containerSize.width / containerSize.height;
    final double imageAspect = origW / origH;

    double drawW, drawH, left, top;
    if (containerAspect > imageAspect) {
      drawH = containerSize.height;
      drawW = drawH * imageAspect;
      left = (containerSize.width - drawW) / 2;
      top = 0;
    } else {
      drawW = containerSize.width;
      drawH = drawW / imageAspect;
      left = 0;
      top = (containerSize.height - drawH) / 2;
    }

    // Function to map screen point to image point
    Offset mapPoint(Offset p) {
      double x = (p.dx - left) * (origW / drawW);
      double y = (p.dy - top) * (origH / drawH);
      return Offset(x, y);
    }

    double scaledBrushSize = brushSize * (origW / drawW);

    // Draw strokes on mask
    for (var stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        final p1 = mapPoint(stroke[i]);
        final p2 = mapPoint(stroke[i + 1]);
        _drawLine(mask, p1, p2, scaledBrushSize, origW, origH);
      }
    }

    // 3. Resize to 512x512 (LaMa input size) with Aspect Ratio Preservation
    onStatus("Presizing...");

    // Determine target square size for padding (max of width or height)
    final int padSize = origW > origH ? origW : origH;
    final int padX = (padSize - origW) ~/ 2;
    final int padY = (padSize - origH) ~/ 2;

    // Create padded versions of image and mask
    final paddedImg = img.Image(width: padSize, height: padSize);
    img.compositeImage(paddedImg, original, dstX: padX, dstY: padY);

    // DILATE MASK: Scale dilation based on resolution
    onStatus("Expanding mask...");
    // Resolution-aware dilation: ~1.2% of the larger dimension
    final int dilateRadius = (padSize * 0.012).clamp(4.0, 30.0).toInt();
    final dilatedMask = _dilate(mask, dilateRadius);

    // Soften mask for blending: ~0.6% of larger dimension
    final double blurSigma = (padSize * 0.006).clamp(2.0, 15.0);
    final softMask = img.gaussianBlur(dilatedMask, radius: blurSigma.toInt());

    final paddedMask = img.Image(
      width: padSize,
      height: padSize,
      numChannels: 1,
    );
    img.compositeImage(paddedMask, softMask, dstX: padX, dstY: padY);

    // Now resize the PADDED versions to 512x512
    final resizedImg = img.copyResize(paddedImg, width: 512, height: 512);
    final resizedMask = img.copyResize(paddedMask, width: 512, height: 512);

    // 4. Prepare Tensors
    onStatus("Preparing tensors...");
    final inputImgData = Float32List(1 * 3 * 512 * 512);
    final inputMaskData = Float32List(1 * 1 * 512 * 512);

    for (int y = 0; y < 512; y++) {
      for (int x = 0; x < 512; x++) {
        final p = resizedImg.getPixel(x, y);
        // Normalize image [0, 1] and CHW format
        inputImgData[0 * 512 * 512 + y * 512 + x] = p.r / 255.0;
        inputImgData[1 * 512 * 512 + y * 512 + x] = p.g / 255.0;
        inputImgData[2 * 512 * 512 + y * 512 + x] = p.b / 255.0;

        // Mask [0, 1] - use threshold for AI input
        final m = resizedMask.getPixel(x, y).r;
        inputMaskData[y * 512 + x] = m > 128 ? 1.0 : 0.0;
      }
    }

    // 5. Run Inference
    onStatus("AI is erasing...");
    final imgOrtValue = await OrtValue.fromList(inputImgData, [1, 3, 512, 512]);
    final maskOrtValue = await OrtValue.fromList(inputMaskData, [
      1,
      1,
      512,
      512,
    ]);

    final Map<String, OrtValue> inputs = {
      'image': imgOrtValue,
      'mask': maskOrtValue,
    };

    final Map<String, OrtValue> outputs = await _session!.run(inputs);

    if (outputs.isEmpty || !outputs.containsKey('output')) {
      imgOrtValue.dispose();
      maskOrtValue.dispose();
      throw Exception('Inference failed: output not found');
    }

    // 6. Post-process result
    onStatus("Finalizing...");
    final outputValue = outputs['output']!;
    final List<dynamic> outputRaw = await outputValue.asFlattenedList();
    final Float32List outputData = Float32List.fromList(
      outputRaw.map((e) => (e as num).toDouble()).toList(),
    );

    // Detect if output is 0-1 or 0-255 to prevent "white image" issue
    double maxValue = 0;
    for (
      int i = 0;
      i < outputData.length;
      i += (outputData.length ~/ 100).clamp(1, 1000)
    ) {
      if (outputData[i] > maxValue) maxValue = outputData[i];
    }
    final double multiplier = maxValue > 1.2 ? 1.0 : 255.0;

    final result512 = img.Image(width: 512, height: 512, numChannels: 3);
    for (int y = 0; y < 512; y++) {
      for (int x = 0; x < 512; x++) {
        final r = (outputData[0 * 512 * 512 + y * 512 + x] * multiplier)
            .clamp(0, 255)
            .toInt();
        final g = (outputData[1 * 512 * 512 + y * 512 + x] * multiplier)
            .clamp(0, 255)
            .toInt();
        final b = (outputData[2 * 512 * 512 + y * 512 + x] * multiplier)
            .clamp(0, 255)
            .toInt();
        result512.setPixelRgb(x, y, r, g, b);
      }
    }

    // Selective Replacement logic:
    // Upscale the 512x512 RESULT back to the padded square size
    final upscaledPaddedResult = img.copyResize(
      result512,
      width: padSize,
      height: padSize,
      interpolation: img.Interpolation.linear,
    );

    // Now crop the padded result back to original image bounds
    final upscaledResult = img.copyCrop(
      upscaledPaddedResult,
      x: padX,
      y: padY,
      width: origW,
      height: origH,
    );

    // Create the final image by blending original and upscaledResult using the softMask
    final finalImage = img.Image.from(original);

    for (int y = 0; y < origH; y++) {
      for (int x = 0; x < origW; x++) {
        final m = softMask.getPixel(x, y).r;
        if (m > 0) {
          // If masked, use the AI result. We could do alpha blending here for smoother edges
          final pixelResult = upscaledResult.getPixel(x, y);
          if (m == 255) {
            finalImage.setPixelRgb(
              x,
              y,
              pixelResult.r,
              pixelResult.g,
              pixelResult.b,
            );
          } else {
            // Feathered edge blending for seamless look
            final pOrig = original.getPixel(x, y);
            final double alpha = m / 255.0;
            final int r = (pixelResult.r * alpha + pOrig.r * (1 - alpha))
                .toInt();
            final int g = (pixelResult.g * alpha + pOrig.g * (1 - alpha))
                .toInt();
            final int b = (pixelResult.b * alpha + pOrig.b * (1 - alpha))
                .toInt();
            finalImage.setPixelRgb(x, y, r, g, b);
          }
        }
      }
    }

    // Clean up
    await imgOrtValue.dispose();
    await maskOrtValue.dispose();
    for (var out in outputs.values) {
      await out.dispose();
    }

    return Uint8List.fromList(img.encodePng(finalImage));
  }

  // Simple morphological dilation to expand mask
  img.Image _dilate(img.Image src, int radius) {
    if (radius <= 0) return src;
    final dst = img.Image.from(src);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        if (src.getPixel(x, y).r > 0) continue;

        bool found = false;
        // Optimization: check a simple cross pattern first or small neighborhood
        for (int dy = -radius; dy <= radius; dy++) {
          for (int dx = -radius; dx <= radius; dx++) {
            // Circle-like radius check for better quality
            if (dx * dx + dy * dy > radius * radius) continue;

            int nx = x + dx;
            int ny = y + dy;
            if (nx >= 0 && nx < src.width && ny >= 0 && ny < src.height) {
              if (src.getPixel(nx, ny).r > 0) {
                dst.setPixelRgb(x, y, 255, 255, 255);
                found = true;
                break;
              }
            }
          }
          if (found) break;
        }
      }
    }
    return dst;
  }

  // Helper to draw lines on img.Image for mask creation
  void _drawLine(
    img.Image image,
    Offset p1,
    Offset p2,
    double width,
    int imgW,
    int imgH,
  ) {
    // This is a very basic implementation.
    // Ideally, we'd translate screen-space Offsets to image-space coordinates.
    // For now, assuming direct mapping or providing a TODO for refinement.

    // Simple line drawing logic:
    int x1 = p1.dx.toInt();
    int y1 = p1.dy.toInt();
    int x2 = p2.dx.toInt();
    int y2 = p2.dy.toInt();

    img.drawLine(
      image,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      thickness: width.toInt(),
      color: img.ColorUint8.rgb(255, 255, 255),
    );
  }

  Future<void> dispose() async {
    await _session?.close();
    _isInitialized = false;
  }
}
