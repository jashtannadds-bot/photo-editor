import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:photho_editor/onnx_inpainter.dart';

class MagicEraserScreen extends StatefulWidget {
  final ImageSource? initialSource;
  const MagicEraserScreen({super.key, this.initialSource});

  @override
  State<MagicEraserScreen> createState() => _MagicEraserScreenState();
}

class _MagicEraserScreenState extends State<MagicEraserScreen> {
  final ImagePicker _picker = ImagePicker();
  final OnnxInpainter _inpainter = OnnxInpainter();

  File? _originalImage;
  Uint8List? _processedImageBytes;

  List<List<Offset>> _strokes = [];
  double _brushSize = 25.0;
  Size _canvasSize = Size.zero;

  bool _isProcessing = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  bool _modelLoaded = false;
  bool _showOriginal = false;
  String _processingStatus = "";

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
    _inpainter.dispose();
    super.dispose();
  }

  Future<void> _prepareModel() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final modelPath = path.join(docDir.path, 'lama_inpainting.onnx');

      if (await File(modelPath).exists()) {
        await _initializeInpainter(modelPath);
      }
    } catch (e) {
      debugPrint('Error preparing model: $e');
    }
  }

  Future<void> _initializeInpainter(String modelPath) async {
    try {
      await _inpainter.initialize(modelPath);
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
      final docDir = await getApplicationDocumentsDirectory();
      final modelPath = path.join(docDir.path, 'lama_inpainting.onnx');

      await _inpainter.downloadModel(
        modelPath,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );
      await _initializeInpainter(modelPath);
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
          _processedImageBytes = null;
          _strokes = [];
          _showOriginal = false;
        });
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _processInpainting() async {
    if (_originalImage == null || _strokes.isEmpty) return;

    if (!_modelLoaded) {
      await _downloadModel();
      if (!_modelLoaded) return;
    }

    setState(() {
      _isProcessing = true;
      _processingStatus = "Processing...";
    });

    try {
      final imageBytes = await _originalImage!.readAsBytes();

      // We need to pass the strokes to the inpainter
      // The inpainter will create the mask based on these strokes
      // We also need the size of the container where the user drew the strokes
      // to correctly map them to the image resolution.

      final result = await _inpainter.inpaint(
        imageBytes,
        _strokes,
        _brushSize,
        containerSize: _canvasSize,
        onStatus: (status) {
          if (mounted) setState(() => _processingStatus = status);
        },
      );

      if (result != null) {
        setState(() {
          _processedImageBytes = result;
          _isProcessing = false;
          _strokes = []; // Clear strokes after success
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorDialog('Inpainting failed: $e');
    }
  }

  Future<void> _saveImage() async {
    if (_processedImageBytes == null) return;
    setState(() => _isProcessing = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(tempDir.path, 'magic_eraser_$timestamp.png');

      final file = File(filePath);
      await file.writeAsBytes(_processedImageBytes!);
      await Gal.putImage(filePath);

      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Image saved to gallery'),
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
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
            child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
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
        title: const Text(
          'Magic Eraser',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_strokes.isNotEmpty && !_isProcessing)
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              onPressed: () => setState(() => _strokes.removeLast()),
            ),
          if (_processedImageBytes != null && !_isProcessing)
            IconButton(
              icon: const Icon(
                Icons.download_rounded,
                color: Colors.blueAccent,
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
              color: Colors.blueAccent.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.auto_fix_normal_rounded,
              size: 80,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Magic Eraser',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Remove unwanted objects\nfrom your photos instantly',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Select Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
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
        // Top options (Brush Size)
        if (_processedImageBytes == null && !_isProcessing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.brush_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                Expanded(
                  child: Slider(
                    value: _brushSize,
                    min: 10,
                    max: 80,
                    activeColor: Colors.blueAccent,
                    onChanged: (v) => setState(() => _brushSize = v),
                  ),
                ),
                Text(
                  '${_brushSize.toInt()}px',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

        // Image Canvas
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base Image
                    _showOriginal || _processedImageBytes == null
                        ? Image.file(_originalImage!, fit: BoxFit.contain)
                        : Image.memory(
                            _processedImageBytes!,
                            fit: BoxFit.contain,
                          ),

                    // Mask Layer (only when not processed)
                    if (_processedImageBytes == null && !_isProcessing)
                      GestureDetector(
                        onPanStart: (details) {
                          setState(() {
                            _strokes.add([details.localPosition]);
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            _strokes.last.add(details.localPosition);
                          });
                        },
                        child: CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: MaskPainter(
                            strokes: _strokes,
                            brushSize: _brushSize,
                          ),
                        ),
                      ),

                    if (_isProcessing) _buildProcessingOverlay(),
                    if (_isDownloading) _buildDownloadOverlay(),
                  ],
                );
              },
            ),
          ),
        ),

        // Before/After Toggle
        if (_processedImageBytes != null && !_isProcessing)
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
                              ? Colors.blueAccent
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
                              ? Colors.blueAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Erased',
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

        // Bottom Actions
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (_processedImageBytes == null && !_isProcessing)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _strokes.isEmpty ? null : _processInpainting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      disabledBackgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _strokes.isEmpty ? 'DRAW OVER OBJECT' : 'ERASE OBJECT ✨',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (_processedImageBytes != null && !_isProcessing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _processedImageBytes = null;
                          _strokes = [];
                          _showOriginal = false;
                        }),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blueAccent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Save Result',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 20),
            Text(
              _processingStatus,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadOverlay() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.download_rounded,
            color: Colors.blueAccent,
            size: 48,
          ),
          const SizedBox(height: 20),
          const Text(
            'Downloading AI Model',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'This is a one-time download (~50MB)',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 30),
          LinearProgressIndicator(
            value: _downloadProgress,
            backgroundColor: Colors.white10,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 10),
          Text(
            '${(_downloadProgress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class MaskPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final double brushSize;

  MaskPainter({required this.strokes, required this.brushSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brushSize
      ..style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (var point in stroke) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MaskPainter oldDelegate) => true;
}
