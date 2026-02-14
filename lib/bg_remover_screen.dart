import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class BgRemoverScreen extends StatefulWidget {
  final ImageSource? initialSource;
  const BgRemoverScreen({super.key, this.initialSource});

  @override
  State<BgRemoverScreen> createState() => _BgRemoverScreenState();
}

class _BgRemoverScreenState extends State<BgRemoverScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _originalImage;
  ui.Image? _processedImage;

  bool _isProcessing = false;
  bool _showOriginal = false;
  Color _backgroundColor = Colors.transparent;

  final List<Color> _backgroundOptions = [
    Colors.transparent,
    Colors.white,
    Colors.black,
    const Color(0xFF1A1A1A),
    const Color(0xFF2D2D2D),
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.teal,
    Colors.green,
    Colors.amber,
    Colors.orange,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _initializeBackgroundRemover();
    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage(widget.initialSource!);
      });
    }
  }

  bool _isOrtInitialized = false;

  Future<bool> _initializeBackgroundRemover() async {
    if (_isOrtInitialized) return true;

    setState(() {
      _isProcessing = true;
    });

    try {
      debugPrint('[BackgroundRemover] Initializing ONNX session...');
      await BackgroundRemover.instance.initializeOrt();
      _isOrtInitialized = true;
      debugPrint('[BackgroundRemover] ONNX session initialized successfully.');
      return true;
    } catch (e) {
      debugPrint('[BackgroundRemover] Failed to initialize ONNX session: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorDialog(
          'AI Engine failed to start: $e\n\nThis can happen if native components are missing or conflicting.',
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    // Dispose ONNX Runtime session
    BackgroundRemover.instance.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('[BackgroundRemover] Picking image from $source...');
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null && mounted) {
        debugPrint('[BackgroundRemover] Image picked: ${pickedFile.path}');
        setState(() {
          _originalImage = File(pickedFile.path);
          _processedImage = null;
          _backgroundColor = Colors.transparent;
          _showOriginal = false;
        });

        // Automatically start processing
        await _processImage();
      } else {
        debugPrint('[BackgroundRemover] No image picked.');
      }
    } catch (e) {
      debugPrint('[BackgroundRemover] Error picking image: $e');
      if (mounted) {
        _showErrorDialog(
          'Failed to pick image: $e\n\nThis can happen if permissions are denied or if the platform system is unstable.',
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_originalImage == null) return;

    // Lazy initialization of ONNX
    if (!_isOrtInitialized) {
      final success = await _initializeBackgroundRemover();
      if (!success) return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Read the image bytes
      final imageBytes = await _originalImage!.readAsBytes();

      debugPrint('[BackgroundRemover] Processing image...');
      // Remove background using BackgroundRemover instance
      final resultImage = await BackgroundRemover.instance.removeBg(imageBytes);
      debugPrint('[BackgroundRemover] Processing complete.');

      setState(() {
        _processedImage = resultImage;
        _isProcessing = false;
        _showOriginal = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        _showErrorDialog('Failed to remove background: $e');
      }
    }
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create a temporary file to save the processed image with full background
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(tempDir.path, 'bg_removed_$timestamp.png');

      // We need to render the image WITH the selected background color if not transparent
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final size = Size(
        _processedImage!.width.toDouble(),
        _processedImage!.height.toDouble(),
      );

      if (_backgroundColor != Colors.transparent) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = _backgroundColor,
        );
      }

      final paint = Paint();
      canvas.drawImage(_processedImage!, Offset.zero, paint);

      final ui.Image finalImage = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) throw Exception('Failed to convert image');
      final imageBytes = byteData.buffer.asUint8List();

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Save to gallery
      await Gal.putImage(filePath);

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Image saved to gallery'),
            backgroundColor: Colors.deepPurple,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        _showErrorDialog('Failed to save image: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Error', style: TextStyle(color: Colors.white)),
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Image Source',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSourceOption(
                icon: Icons.photo_library_rounded,
                title: 'Gallery',
                subtitle: 'Choose from your photos',
                color: Colors.deepPurpleAccent,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              _buildSourceOption(
                icon: Icons.camera_alt_rounded,
                title: 'Camera',
                subtitle: 'Take a new photo',
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'BG Remover',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_processedImage != null && !_isProcessing)
            IconButton(
              icon: const Icon(
                Icons.download_rounded,
                color: Colors.deepPurpleAccent,
              ),
              onPressed: _saveImage,
            ),
        ],
      ),
      body: _originalImage == null ? _buildEmptyState() : _buildImageView(),
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
              Icons.layers_clear_rounded,
              size: 80,
              color: Colors.deepPurpleAccent,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Remove Background',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Clean cuts in seconds using\non-device AI technology',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _showImageSourceDialog,
            icon: const Icon(Icons.add_photo_alternate_rounded),
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

  Widget _buildImageView() {
    return Column(
      children: [
        // Toggle and Background Options
        if (_processedImage != null) ...[
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
                          'Before',
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
                          'After',
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

          // Background Color Options
          if (!_showOriginal)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _backgroundOptions.length,
                  itemBuilder: (context, index) {
                    final color = _backgroundOptions[index];
                    final isSelected = _backgroundColor == color;

                    return GestureDetector(
                      onTap: () => setState(() => _backgroundColor = color),
                      child: Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: color == Colors.transparent
                              ? Colors.white
                              : color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepPurpleAccent
                                : Colors.white.withOpacity(0.1),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.deepPurpleAccent.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: color == Colors.transparent
                            ? ClipOval(
                                child: CustomPaint(
                                  painter: CheckerboardPainter(),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],

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
                ? _buildLoadingIndicator()
                : _buildImageDisplay(),
          ),
        ),

        // Action Buttons
        if (_processedImage != null && !_isProcessing)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showImageSourceDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurpleAccent,
                      side: const BorderSide(color: Colors.deepPurple),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Try Another',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded),
                        SizedBox(width: 8),
                        Text(
                          'Save Result',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.deepPurpleAccent),
          const SizedBox(height: 20),
          const Text(
            'Removing Background...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Isolating subject from background',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _showOriginal || _processedImage == null
            ? Image.file(_originalImage!, fit: BoxFit.contain)
            : Stack(
                alignment: Alignment.center,
                children: [
                  // Checkerboard pattern for transparent background
                  if (_backgroundColor == Colors.transparent)
                    Positioned.fill(
                      child: CustomPaint(painter: CheckerboardPainter()),
                    ),
                  // Solid color background for other colors
                  if (_backgroundColor != Colors.transparent)
                    Positioned.fill(child: Container(color: _backgroundColor)),
                  // Processed image on top
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _processedImage!.width.toDouble(),
                          height: _processedImage!.height.toDouble(),
                          child: CustomPaint(
                            painter: _UiImagePainter(_processedImage!),
                            size: Size(
                              _processedImage!.width.toDouble(),
                              _processedImage!.height.toDouble(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

// Custom painter to display ui.Image
class _UiImagePainter extends CustomPainter {
  final ui.Image image;

  _UiImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(_UiImagePainter oldDelegate) => oldDelegate.image != image;
}

// Custom painter for checkerboard pattern (transparent background indicator)
class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 12.0;
    final paint1 = Paint()..color = const Color(0xFF222222);
    final paint2 = Paint()..color = const Color(0xFF111111);

    for (var i = 0; i < size.width / squareSize; i++) {
      for (var j = 0; j < size.height / squareSize; j++) {
        final isEven = (i + j) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(i * squareSize, j * squareSize, squareSize, squareSize),
          isEven ? paint1 : paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
