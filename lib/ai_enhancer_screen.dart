import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_super_resolution/flutter_super_resolution.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'dart:ui' as ui;
import 'package:photho_editor/onnx_upscaler.dart';

class AiEnhancerScreen extends StatefulWidget {
  final ImageSource? initialSource;
  const AiEnhancerScreen({super.key, this.initialSource});

  @override
  State<AiEnhancerScreen> createState() => _AiEnhancerScreenState();
}

class _AiEnhancerScreenState extends State<AiEnhancerScreen> {
  final ImagePicker _picker = ImagePicker();
  final OnnxUpscaler _upscaler = OnnxUpscaler();

  File? _originalImage;
  Uint8List? _enhancedImageBytes;

  bool _isProcessing = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  bool _modelLoaded = false;
  bool _showOriginal = false;
  String _processingStatus = "";

  final String _modelUrl =
      'https://huggingface.co/onnxmodelzoo/super-resolution-10/resolve/main/super-resolution-10.onnx';
  late String _modelPath;

  @override
  void initState() {
    super.initState();
    _prepareModel();
    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage(widget.initialSource!);
      });
    }
  }

  @override
  void dispose() {
    _upscaler.dispose();
    super.dispose();
  }

  Future<void> _prepareModel() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      // Assign this IMMEDIATELY so other functions have access to the path
      _modelPath = path.join(docDir.path, 'super_resolution_model.onnx');

      if (await File(_modelPath).exists()) {
        await _initializeUpscaler();
      }
    } catch (e) {
      debugPrint('Error preparing model: $e');
    }
  }

  Future<void> _initializeUpscaler() async {
    try {
      // The package uses .initializeModelFromFile(modelPath) for loading from files
      await _upscaler.initializeModelFromFile(_modelPath);
      setState(() {
        _modelLoaded = true;
      });
    } catch (e) {
      _showErrorDialog('Failed to initialize AI engine: $e');
    }
  }

  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dio = Dio();
      await dio.download(
        _modelUrl,
        _modelPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
      await _initializeUpscaler();
    } catch (e) {
      _showErrorDialog('Failed to download AI model: $e');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null && mounted) {
        setState(() {
          _originalImage = File(pickedFile.path);
          _enhancedImageBytes = null;
          _showOriginal = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to pick image: $e');
      }
    }
  }

  Future<void> _enhanceImage() async {
    if (_originalImage == null) return;

    if (!_modelLoaded) {
      await _downloadModel();
      if (!_modelLoaded) return;
    }

    setState(() {
      _isProcessing = true;
      _processingStatus = "Preparing images...";
    });

    try {
      final bytes = await _originalImage!.readAsBytes();

      if (mounted) {
        setState(() => _processingStatus = "Decoding photo...");
      }

      // Decode bytes to ui.Image
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image inputImage = frameInfo.image;

      if (mounted) {
        setState(() => _processingStatus = "AI is thinking...");
      }

      // AI Enhancement using Super Resolution
      final ui.Image? resultImage = await _upscaler.upscaleImage(
        inputImage,
        3, // super-resolution-10 is a 3x upscaler
        onProgress: (progress, message) {
          if (mounted) {
            setState(() {
              _processingStatus = message ?? "Enhancing details...";
            });
          }
        },
      );

      if (resultImage == null)
        throw Exception('AI Enhancement returned no image');

      // Convert ui.Image back to Uint8List
      final ByteData? byteData = await resultImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) throw Exception('Failed to encode enhanced image');
      final result = byteData.buffer.asUint8List();

      setState(() {
        _enhancedImageBytes = result;
        _isProcessing = false;
        _showOriginal = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('AI Enhancement failed: $e');
    }
  }

  Future<void> _saveImage() async {
    if (_enhancedImageBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(tempDir.path, 'ai_enhanced_$timestamp.png');

      final file = File(filePath);
      await file.writeAsBytes(_enhancedImageBytes!);

      await Gal.putImage(filePath);

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Enhanced image saved to gallery'),
            backgroundColor: Colors.deepPurple,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Failed to save image: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('AI Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.deepPurpleAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'AI Enhancer',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_enhancedImageBytes != null && !_isProcessing)
            IconButton(
              icon: const Icon(
                Icons.download_rounded,
                color: Colors.deepPurpleAccent,
              ),
              onPressed: _saveImage,
            ),
        ],
      ),
      body: _originalImage == null ? _buildEmptyState() : _buildEditorView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.deepPurpleAccent,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI Image Enhancer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Boost resolution and clarify details\nusing on-device AI',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Select Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorView() {
    return Column(
      children: [
        // Before/After Toggle
        if (_enhancedImageBytes != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showOriginal = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _showOriginal
                              ? Colors.deepPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Original',
                          style: TextStyle(
                            color: _showOriginal
                                ? Colors.white
                                : Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showOriginal = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_showOriginal
                              ? Colors.deepPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'AI Enhanced',
                          style: TextStyle(
                            color: !_showOriginal
                                ? Colors.white
                                : Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Image Display
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: _isProcessing
                ? _buildProcessingState()
                : (_showOriginal || _enhancedImageBytes == null)
                ? Image.file(_originalImage!, fit: BoxFit.contain)
                : Image.memory(_enhancedImageBytes!, fit: BoxFit.contain),
          ),
        ),

        // Action Area
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (_enhancedImageBytes == null && !_isProcessing)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _enhanceImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'ENHANCE NOW ✨',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (_enhancedImageBytes != null && !_isProcessing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepPurple),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Try Another',
                          style: TextStyle(color: Colors.deepPurpleAccent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Save to Gallery',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_isDownloading) _buildDownloadProgress(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.deepPurpleAccent),
          const SizedBox(height: 20),
          const Text(
            'AI is working its magic...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _processingStatus.isEmpty
                ? 'Upscaling details & removing noise'
                : _processingStatus,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgress() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Downloading AI Model (One-time setup)',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _downloadProgress,
          backgroundColor: Colors.white10,
          color: Colors.deepPurpleAccent,
        ),
        const SizedBox(height: 4),
        Text(
          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}
