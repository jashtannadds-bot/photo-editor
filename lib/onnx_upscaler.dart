import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

class OnnxUpscaler {
  final OnnxRuntime _runtime = OnnxRuntime();
  OrtSession? _session;
  bool _isInitialized = false;

  Future<void> initializeModelFromFile(String path) async {
    try {
      debugPrint('[OnnxUpscaler] Initializing with model: $path');
      final sessionOptions = OrtSessionOptions();
      _session = await _runtime.createSession(path, options: sessionOptions);
      _isInitialized = true;
      debugPrint('[OnnxUpscaler] Session created successfully.');
    } catch (e) {
      debugPrint('[OnnxUpscaler] Initialization error: $e');
      rethrow;
    }
  }

  Future<ui.Image?> upscaleImage(
    ui.Image inputImage,
    int scale, {
    Function(double, String?)? onProgress,
  }) async {
    if (!_isInitialized || _session == null) {
      throw Exception('OnnxUpscaler not initialized');
    }

    onProgress?.call(0.1, "Preprocessing image...");

    // 1. Convert ui.Image to img.Image (from 'image' package)
    final byteData = await inputImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return null;

    final rawImage = img.Image.fromBytes(
      width: inputImage.width,
      height: inputImage.height,
      bytes: byteData.buffer,
      order: img.ChannelOrder.rgba,
      numChannels: 4,
    );

    // 2. Resize to 224x224 (required by super-resolution-10.onnx)
    final resized = img.copyResize(
      rawImage,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    // 3. Convert to YCbCr and extract Y channel
    // super-resolution-10.onnx takes Y channel as input [1, 1, 224, 224]
    final Float32List inputTensorData = Float32List(224 * 224);
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        // RGB to Y (Luminance) formula
        final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
        inputTensorData[y * 224 + x] = luminance.toDouble();
      }
    }

    onProgress?.call(0.4, "AI is upscaling...");

    // 4. Run Inference
    final inputShape = [1, 1, 224, 224];
    final inputOrtValue = await OrtValue.fromList(inputTensorData, inputShape);

    final Map<String, OrtValue> inputs = {'input': inputOrtValue};
    final Map<String, OrtValue> outputs = await _session!.run(inputs);

    if (outputs.isEmpty || !outputs.containsKey('output')) {
      inputOrtValue.dispose();
      throw Exception('Inference failed: output not found');
    }

    onProgress?.call(0.7, "Post-processing image...");

    // 5. Extract Output Y channel [1, 1, 672, 672]
    final outputValue = outputs['output']!;
    final List<dynamic> outputYRaw = await outputValue.asFlattenedList();
    final Float32List outputY = Float32List.fromList(
      outputYRaw.map((e) => (e as num).toDouble()).toList(),
    );

    final int outW = 672;
    final int outH = 672;

    // 6. Upscale original image to 672x672 using linear for Color (CbCr) channels
    final colorUpscaled = img.copyResize(
      rawImage,
      width: outW,
      height: outH,
      interpolation: img.Interpolation.linear,
    );
    final finalImage = img.Image(width: outW, height: outH, numChannels: 4);

    // 7. Combine AI-upscaled Y with Bicubic-upscaled CbCr
    for (int y = 0; y < outH; y++) {
      for (int x = 0; x < outW; x++) {
        final colorPixel = colorUpscaled.getPixel(x, y);
        final r = colorPixel.r;
        final g = colorPixel.g;
        final b = colorPixel.b;

        // Convert RGB to YCbCr to get Cb and Cr
        // final double currentY = (0.299 * r + 0.587 * g + 0.114 * b); // unused
        final double cb = 128 + (-0.168736 * r - 0.331264 * g + 0.5 * b);
        final double cr = 128 + (0.5 * r - 0.418688 * g - 0.081312 * b);

        // Use AI-enhanced Y
        final double aiY = outputY[y * outW + x] * 255.0;

        // Convert back to RGB
        final double finalR = aiY + 1.402 * (cr - 128);
        final double finalG =
            aiY - 0.344136 * (cb - 128) - 0.714136 * (cr - 128);
        final double finalB = aiY + 1.772 * (cb - 128);

        finalImage.setPixelRgba(
          x,
          y,
          finalR.round().clamp(0, 255),
          finalG.round().clamp(0, 255),
          finalB.round().clamp(0, 255),
          255,
        );
      }
    }

    // Clean up
    await inputOrtValue.dispose();
    for (var out in outputs.values) {
      await out.dispose();
    }

    onProgress?.call(0.9, "Finalizing...");

    // 8. Convert img.Image back to ui.Image
    final Uint8List finalBytes = img.encodePng(finalImage);
    final ui.Codec codec = await ui.instantiateImageCodec(finalBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    return frameInfo.image;
  }

  Future<void> dispose() async {
    await _session?.close();
    _isInitialized = false;
  }
}
