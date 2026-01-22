import 'package:flutter/material.dart';
// Import your other screens here
// import 'star_collage_screen.dart';
// import 'heart_collage_screen.dart';
// import 'curved_grid_screen.dart';

class CollageListScreen extends StatelessWidget {
  const CollageListScreen({super.key});

  final List<Map<String, dynamic>> layouts = const [
    {
      "name": "Classic Heart",
      "icon": Icons.favorite,
      "color": Colors.pinkAccent,
      "route": "heart"
    },
    {
      "name": "Shining Star",
      "icon": Icons.star,
      "color": Colors.amber,
      "route": "star"
    },
    {
      "name": "Curved Circle",
      "icon": Icons.tonality,
      "color": Colors.blueAccent,
      "route": "curved"
    },
    {
      "name": "Square Grid",
      "icon": Icons.grid_view,
      "color": Colors.greenAccent,
      "route": "grid"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Select Layout", style: TextStyle(fontWeight: FontWeight.bold)),
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
                   // Navigator.push(context, MaterialPageRoute(builder: (context) => const StarCollageScreen()));
                } else if (layout['route'] == 'heart') {
                   // Navigator.push(context, MaterialPageRoute(builder: (context) => const CenterHeartCollageScreen()));
                } else if (layout['route'] == 'curved') {
                   // Navigator.push(context, MaterialPageRoute(builder: (context) => const CurvedGridCollageScreen()));
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