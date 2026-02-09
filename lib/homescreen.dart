// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:photho_editor/collage.dart'; // Your CollageListScreen
// import 'package:photho_editor/freestylecollage.dart'; // Your FreestyleCustomScreen

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   Future<void> _openCamera(BuildContext context) async {
//     final cameras = await availableCameras();
//     if (cameras.isEmpty) return;

//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TakePictureScreen(camera: cameras.first),
//       ),
//     );

//     if (result != null && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Picture saved to: ${result.path}")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0D0D),
//       body: SafeArea(
//         child: SingleChildScrollView( // Added scroll for smaller screens
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "PHOTO\nEDITOR",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 32,
//                     fontWeight: FontWeight.w700
//                     ,
//                     letterSpacing: 1.2,
//                     height: 1.1,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Unleash your creativity",
//                   style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
//                 ),
//                 const SizedBox(height: 40),

//                 // 1. CAMERA TAB
//                 _buildHomeTab(
//                   title: "CAMERA",
//                   subtitle: "Capture instant moments",
//                   icon: Icons.camera_alt_rounded,
//                   color: Colors.blueAccent,
//                   onTap: () => _openCamera(context),
//                 ),

//                 const SizedBox(height: 20),

//                 // 2. GRID COLLAGE TAB
//                 _buildHomeTab(
//                   title: "LAYOUTS",
//                   subtitle: "Structured photo grids",
//                   icon: Icons.grid_view_rounded,
//                   color: Colors.purpleAccent,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const CollageListScreen()),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // 3. FREESTYLE COLLAGE TAB (NEW)
//                 _buildHomeTab(
//                   title: "FREESTYLE",
//                   subtitle: "Drag, rotate & stack freely",
//                   icon: Icons.auto_fix_high_rounded,
//                   color: Colors.orangeAccent,
//                   isNew: true, // Special tag for the new feature
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const FreestyleCustomScreen()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHomeTab({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//     bool isNew = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 140,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(28),
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           border: Border.all(color: color.withOpacity(0.3), width: 1.5),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(28),
//           child: Stack(
//             children: [
//               // Ghost Icon Background
//               Positioned(
//                 right: -10,
//                 bottom: -15,
//                 child: Icon(icon, color: color.withOpacity(0.1), size: 120),
//               ),
              
//               Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: color.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(icon, color: color, size: 32),
//                     ),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 title,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               if (isNew) ...[
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange,
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: const Text("NEW", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
//                                 )
//                               ]
//                             ],
//                           ),
//                           Text(
//                             subtitle,
//                             style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 18),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- ACTUAL CAMERA CAPTURE SCREEN ---

// class TakePictureScreen extends StatefulWidget {
//   final CameraDescription camera;
//   const TakePictureScreen({super.key, required this.camera});

//   @override
//   TakePictureScreenState createState() => TakePictureScreenState();
// }

// class TakePictureScreenState extends State<TakePictureScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the camera controller
//     _controller = CameraController(widget.camera, ResolutionPreset.high);
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     // Always dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               children: [
//                 Center(child: CameraPreview(_controller)),
                
//                 // Back Button
//                 Positioned(
//                   top: 40,
//                   left: 20,
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),

//                 // Capture Button
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 40),
//                     child: FloatingActionButton(
//                       backgroundColor: Colors.white,
//                       onPressed: () async {
//                         try {
//                           await _initializeControllerFuture;
//                           final image = await _controller.takePicture();
//                           if (!mounted) return;
//                           // Return the image path to the home screen
//                           Navigator.pop(context, XFile(image.path));
//                         } catch (e) {
//                           debugPrint("Camera error: $e");
//                         }
//                       },
//                       child: const Icon(Icons.camera, color: Colors.black, size: 30),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
// // --- KEEP YOUR TakePictureScreen CLASSES BELOW ---

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart'; // Added for picking single photos
import 'package:photho_editor/collage.dart';
import 'package:photho_editor/filter_editor.dart'; 
import 'package:photho_editor/freestylecollage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera(BuildContext context) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: cameras.first),
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Picture saved to: ${result.path}")),
      );
    }
  }

  // New function to handle Single Photo Editing
  Future<void> _pickAndEditPhoto(BuildContext context) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilterEditorScreen(initialImage: File(pickedFile.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PHOTO\nEDITOR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Unleash your creativity",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                ),
                const SizedBox(height: 40),

                // 1. PHOTO EDITOR TAB (New feature for single photo filtering)
                _buildHomeTab(
                  title: "EDIT PHOTO",
                  subtitle: "Pro filters & tuning tools",
                  icon: Icons.tune_rounded, // Snapseed-style icon
                  color: Colors.greenAccent,
                  isNew: true,
                  onTap: () => _pickAndEditPhoto(context),
                ),

                const SizedBox(height: 20),

                // 2. CAMERA TAB
                _buildHomeTab(
                  title: "CAMERA",
                  subtitle: "Capture instant moments",
                  icon: Icons.camera_alt_rounded,
                  color: Colors.blueAccent,
                  onTap: () => _openCamera(context),
                ),

                const SizedBox(height: 20),

                // 3. GRID COLLAGE TAB
                _buildHomeTab(
                  title: "LAYOUTS",
                  subtitle: "Structured photo grids",
                  icon: Icons.grid_view_rounded,
                  color: Colors.purpleAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CollageListScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 4. FREESTYLE COLLAGE TAB
                _buildHomeTab(
                  title: "FREESTYLE",
                  subtitle: "Drag, rotate & stack freely",
                  icon: Icons.auto_fix_high_rounded,
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FreestyleCustomScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB BUILDER HELPER ---
  Widget _buildHomeTab({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
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
                padding: const EdgeInsets.all(24.0),
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
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isNew) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text("PRO", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ]
                            ],
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 18),
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
                      child: const Icon(Icons.camera, color: Colors.black, size: 30),
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