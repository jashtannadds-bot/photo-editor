import 'package:flutter/material.dart';
import 'package:photho_editor/circlecollage.dart';
import 'package:photho_editor/diamondcollage.dart';
import 'package:photho_editor/flowercollage.dart';
import 'package:photho_editor/gridcollage.dart';
import 'package:photho_editor/heartcollage.dart';
import 'package:photho_editor/mickycollage.dart';
import 'package:photho_editor/moodboardcollage.dart';
import 'package:photho_editor/pentagon.dart';
import 'package:photho_editor/filmcollage.dart';
import 'package:photho_editor/polloariodcollage.dart';
import 'package:photho_editor/slitscancollage.dart';
import 'package:photho_editor/starcollage.dart';
// Import your other screens here
// import 'star_collage_screen.dart';
// import 'heart_collage_screen.dart';
// import 'curved_grid_screen.dart';

class CollageListScreen extends StatelessWidget {
  const CollageListScreen({super.key});

  final List<Map<String, dynamic>> layouts = const [
    {
      "name": "Heart",
      "icon": Icons.favorite,
      "color": Colors.pinkAccent,
      "route": "heart",
    },
    {
      "name": "Star",
      "icon": Icons.star,
      "color": Colors.amber,
      "route": "star",
    },
    {
      "name": "Bubble",
      "icon": Icons.tonality,
      "color": Colors.blueAccent,
      "route": "curved",
    },
    {
      "name": "Square Grid",
      "icon": Icons.grid_view,
      "color": Colors.greenAccent,
      "route": "grid",
    },
    {
      "name": "Mickey Mouse",
      "icon": Icons.face, // Or use a custom SVG if you have one
      "color": Colors.redAccent,
      "route": "mickey",
    },
    {
      "name": "Flower Bloom",
      "icon": Icons.local_florist,
      "color": Colors.orangeAccent,
      "route": "flower",
    },
    {
      "name": "Pentagon", // New name for the Pentagon
      "icon": Icons.pentagon_outlined,
      "color": Colors.deepPurpleAccent,
      "route": "pentagon",
    },
    {
      "name": "Aura Diamond",
      "icon": Icons.blur_on, // Gives a "shutter" vibe
      "color": Colors.cyanAccent,
      "route": "diamond",
    },
    {
      "name": "Moodboard Muse",
      "icon": Icons.auto_awesome_mosaic_rounded,
      "color": Colors.white,
      "route": "moodboard",
    },
    {
      "name": "Flim Strip",
      "icon": Icons.movie,
      "color": Colors.pinkAccent,
      "route": "Flim",
    },
    {
      "name": "polloariod",
      "icon": Icons.filter_frames_outlined,
      "color": Colors.limeAccent,
      "route": "polloariod",
    },
    {
      "name": "slit scan",
      "icon": Icons.view_column_rounded,
      "color": Colors.brown,
      "route": "scan",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Select Layout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: layouts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // Makes the cards slightly tall
          ),
          itemBuilder: (context, index) {
            final layout = layouts[index];
            return GestureDetector(
              onTap: () {
                // NAVIGATION LOGIC
                if (layout['route'] == 'star') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CollageEditorScreen(),
                    ),
                  );
                } else if (layout['route'] == 'heart') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CenterHeartCollageScreen(),
                    ),
                  );
                } else if (layout['route'] == 'grid') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DynamicGridCollageScreen(),
                    ),
                  );
                } else if (layout['route'] == 'mickey') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MickeyFinalDesign(),
                    ),
                  );
                } else if (layout['route'] == 'curved') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BubbleCollageScreen(),
                    ),
                  );
                } else if (layout['route'] == 'flower') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FlowerCollageScreen(),
                    ),
                  );
                } else if (layout['route'] == 'pentagon') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PuzzleCollageScreen(),
                    ),
                  );
                } else if (layout['route'] == 'diamond') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProCameraLensCollage(),
                    ),
                  );
                } else if (layout['route'] == 'moodboard') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MoodboardMuseCollage(),
                    ),
                  );
                } else if (layout['route'] == 'Flim') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuraCollageScreen(),
                    ),
                  );
                } else if (layout['route'] == 'polloariod') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HangingBulbCollage(),
                    ),
                  );
                } else if (layout['route'] == 'scan') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SlitScanCollage(),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: layout['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        layout['icon'],
                        size: 50,
                        color: layout['color'],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      layout['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "5 Photos",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
