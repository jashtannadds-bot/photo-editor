// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0D0D), // Matches your collage background
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           "PHOTO EDITOR",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.5,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // CAMERA CONTAINER
//             _buildHomeTab(
//               context,
//               title: "CAMERA",
//               subtitle: "Capture a new moment",
//               icon: Icons.camera_alt_outlined,
//               color: Colors.blueAccent,
//               onTap: () {
//                 // Navigate to your Camera Screen
//               },
//             ),
            
//             const SizedBox(height: 25), // Space between tabs

//             // COLLAGE CONTAINER
//             _buildHomeTab(
//               context,
//               title: "COLLAGE",
//               subtitle: "Create beautiful layouts",
//               icon: Icons.grid_view_rounded,
//               color: Colors.purpleAccent,
//               onTap: () {
//                 // Navigate to your Heart/Pentagon Collage Screens
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHomeTab(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         height: 180,
//         decoration: BoxDecoration(
//           // Gradient gives it a modern, "Glassmorphism" look
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             // Decorative background icon
//             Positioned(
//               right: -20,
//               bottom: -20,
//               child: Icon(
//                 icon,
//                 size: 150,
//                 color: Colors.white.withOpacity(0.1),
//               ),
//             ),
//             // Text and Main Icon content
//             Padding(
//               padding: const EdgeInsets.all(25.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(icon, color: Colors.white, size: 50),
//                   const SizedBox(height: 15),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import 'package:photho_editor/collage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Logic to open the actual camera UI
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "PHOTO EDITIOR",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              
              // CAMERA BUTTON
              _buildLargeButton(
                title: "CAMERA",
                icon: Icons.camera_alt_rounded,
                color: Colors.blueAccent,
                onTap: () => _openCamera(context),
              ),

              const SizedBox(height: 20),

              // COLLAGE BUTTON
              _buildLargeButton(
                title: "COLLAGE",
                icon: Icons.grid_view_rounded,
                color: Colors.purpleAccent,
                onTap: () {
                 Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CollageListScreen()),
    );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 50),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
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
                          Navigator.pop(context, XFile(image.path));
                        } catch (e) {
                          print(e);
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