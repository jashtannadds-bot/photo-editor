import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/collage.dart';
import 'package:photho_editor/filter_editor.dart';
import 'package:photho_editor/freestylecollage.dart';
import 'package:photho_editor/bg_remover_screen.dart';
import 'package:photho_editor/ai_enhancer_screen.dart';
import 'package:photho_editor/theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  // New function to handle Single Photo Editing
  Future<void> _pickAndEditPhoto(
    BuildContext context,
    ImageSource source,
  ) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FilterEditorScreen(initialImage: File(pickedFile.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("PHOTO EDITOR"), centerTitle: true),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Photo Editor Pro",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: theme.colorScheme.primary,
              ),
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  ThemeManager().toggleTheme();
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text("About"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Photo Editor Pro",
                  applicationVersion: "1.0.0",
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PHOTO\nEDITOR",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Unleash your creativity",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // 1. PHOTO EDITOR TAB
                _buildHomeTab(
                  context,
                  title: "EDIT PHOTO",
                  subtitle: "Pro filters & tuning tools",
                  icon: Icons.tune_rounded,
                  color: Colors.lime,
                  onTap: () => _showSourceDialog(
                    context,
                    (source) => _pickAndEditPhoto(context, source),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. BG REMOVER TAB
                _buildHomeTab(
                  context,
                  title: "BG REMOVER",
                  subtitle: "Remove backgrounds instantly",
                  icon: Icons.layers_clear_rounded,
                  color: Colors.tealAccent,
                  isNew: true,
                  onTap: () => _showSourceDialog(
                    context,
                    (source) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BgRemoverScreen(initialSource: source),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. AI ENHANCER TAB
                _buildHomeTab(
                  context,
                  title: "AI ENHANCER",
                  subtitle: "AI Auto-Boost Quality",
                  icon: Icons.auto_awesome,
                  color: Colors.deepPurpleAccent,
                  isNew: true,
                  onTap: () => _showSourceDialog(
                    context,
                    (source) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AiEnhancerScreen(initialSource: source),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. GRID COLLAGE TAB
                _buildHomeTab(
                  context,
                  title: "LAYOUTS",
                  subtitle: "Structured photo grids",
                  icon: Icons.grid_view_rounded,
                  color: Colors.purpleAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CollageListScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 5. FREESTYLE COLLAGE TAB
                _buildHomeTab(
                  context,
                  title: "FREESTYLE",
                  subtitle: "Drag, rotate & stack freely",
                  icon: Icons.auto_fix_high_rounded,
                  color: Colors.orangeAccent,
                  onTap: () => _showSourceDialog(
                    context,
                    (source) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FreestyleCustomScreen(initialSource: source),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SOURCE SELECTION DIALOG ---
  void _showSourceDialog(
    BuildContext context,
    Function(ImageSource) onSourceSelected,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Image Source",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceButton(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSource.camera);
                  },
                ),
                _buildSourceButton(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  color: Colors.purpleAccent,
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB BUILDER HELPER ---
  Widget _buildHomeTab(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -15,
                child: Icon(icon, color: color.withOpacity(0.1), size: 120),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isNew) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "PRO",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ACTUAL CAMERA CAPTURE SCREEN ---
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({super.key, required this.camera});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(child: CameraPreview(_controller)),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        try {
                          await _initializeControllerFuture;
                          final image = await _controller.takePicture();
                          if (!mounted) return;
                          Navigator.pop(context, image); // Return the XFile
                        } catch (e) {
                          debugPrint("Camera error: $e");
                        }
                      },
                      child: const Icon(
                        Icons.camera,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
