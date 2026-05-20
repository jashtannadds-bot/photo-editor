import 'dart:io';
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
import 'package:photho_editor/dynamic_collage_editor.dart';
import 'package:photho_editor/collage_layout_data.dart';
import 'package:photho_editor/four_image_rounded_collage.dart';

class CollageListScreen extends StatelessWidget {
  final List<File> images;
  const CollageListScreen({super.key, required this.images});

  List<Map<String, dynamic>> _getLayouts() {
    List<Map<String, dynamic>> allLayouts = [];

    // Add all dynamic layouts mapped from collage_layout_data.dart
    final dynamicDefs = getLayoutsForCount(images.length);
    for (int i = 0; i < dynamicDefs.length; i++) {
      allLayouts.add({
        "name": dynamicDefs[i].name,
        "icon": dynamicDefs[i].icon,
        "color": Colors.blueAccent,
        "route": "dynamic_$i",
      });
    }

    // Add legacy special screens if 4 images
    if (images.length == 4) {
      allLayouts.add({
        "name": "Rounded Quarters",
        "icon": Icons.rounded_corner_rounded,
        "color": Colors.purpleAccent,
        "route": "rounded_quarters",
      });
    }

    // Add legacy special screens if 5 images
    if (images.length == 5) {
      allLayouts.addAll([
        {
          "name": "Heart Shape",
          "icon": Icons.favorite,
          "color": Colors.pinkAccent,
          "route": "heart",
        },
        {
          "name": "Star Shape",
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
          "name": "Square Grid (Old)",
          "icon": Icons.grid_view,
          "color": Colors.greenAccent,
          "route": "grid",
        },
        {
          "name": "Mickey Mouse",
          "icon": Icons.face,
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
          "name": "Pentagon",
          "icon": Icons.pentagon_outlined,
          "color": Colors.deepPurpleAccent,
          "route": "pentagon",
        },
        {
          "name": "Aura Diamond",
          "icon": Icons.blur_on,
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
          "name": "Film Strip",
          "icon": Icons.movie,
          "color": Colors.pinkAccent,
          "route": "Flim",
        },
        {
          "name": "Polaroid",
          "icon": Icons.filter_frames_outlined,
          "color": Colors.limeAccent,
          "route": "polloariod",
        },
        {
          "name": "Slit Scan",
          "icon": Icons.view_column_rounded,
          "color": Colors.brown,
          "route": "scan",
        },
      ]);
    }


    return allLayouts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final layouts = _getLayouts();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Select Layout",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: layouts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final layout = layouts[index];
            return GestureDetector(
              onTap: () {
                final String route = layout['route'] as String;

                // Route to DynamicCollageEditor for new layout definitions
                if (route.startsWith('dynamic_')) {
                  final initialIdx = int.parse(route.split('_')[1]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DynamicCollageEditor(
                        initialImages: images,
                        initialLayoutIndex: initialIdx,
                      ),
                    ),
                  );
                  return;
                }

                // 5-IMAGE (OR DEFAULT) ORIGINAL SCREENS
                if (route == 'rounded_quarters') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RoundedQuartersCollageScreen(initialImages: images),
                    ),
                  );
                } else if (route == 'star') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CollageEditorScreen(initialImages: images),
                    ),
                  );
                } else if (route == 'heart') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CenterHeartCollageScreen(initialImages: images),
                    ),
                  );
                } else if (route == 'grid') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DynamicGridCollageScreen(initialImages: images),
                    ),
                  );
                } else if (route == 'mickey') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MickeyFinalDesign(initialImages: images),
                    ),
                  );
                } else if (route == 'curved') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BubbleCollageScreen(initialImages: images),
                    ),
                  );
                } else if (route == 'flower') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FlowerCollageScreen(initialImages: images),
                    ),
                  );
                } else if (route == 'pentagon') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PuzzleCollageScreen(initialImages: images),
                    ),
                  );
                } else if (route == 'diamond') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProCameraLensCollage(initialImages: images),
                    ),
                  );
                } else if (route == 'moodboard') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MoodboardMuseCollage(initialImages: images),
                    ),
                  );
                } else if (route == 'Flim') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AuraCollageScreen(initialImages: images),
                    ),
                  );
                } else if (route == 'polloariod') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HangingBulbCollage(initialImages: images),
                    ),
                  );
                } else if (route == 'scan') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SlitScanCollage(initialImages: images),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: layout['color'].withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        layout['icon'],
                        size: 48,
                        color: layout['color'],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      layout['name'],
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${images.length} Photos",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13,
                      ),
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
