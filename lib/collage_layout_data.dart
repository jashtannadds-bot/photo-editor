import 'package:flutter/material.dart';

/// Normalized cell rectangle (all values 0.0 – 1.0)
class CellRect {
  final double left, top, width, height;
  const CellRect(this.left, this.top, this.width, this.height);
}

/// A single collage layout definition.
class CollageLayoutDef {
  final String name;
  final IconData icon;
  final int imageCount;

  /// If true, uses a custom clipper (only for 2-image fancy splits).
  final bool isClipBased;

  /// Clip type key for clip-based 2-image layouts (e.g. 'side', 'diagonal').
  final String? clipType;

  /// Normalized cell rects for grid-based layouts.
  final List<CellRect>? cells;

  const CollageLayoutDef({
    required this.name,
    required this.icon,
    required this.imageCount,
    this.isClipBased = false,
    this.clipType,
    this.cells,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2-IMAGE LAYOUTS (20)
// ═══════════════════════════════════════════════════════════════════════════════

final List<CollageLayoutDef> layouts2 = [
  // ── Clip-based (fancy) ──────────────────────────────────────────────────
  const CollageLayoutDef(
    name: 'Symmetric Mirror',
    icon: Icons.view_column_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'side',
  ),
  const CollageLayoutDef(
    name: 'Horizon Split',
    icon: Icons.view_stream_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'top',
  ),
  const CollageLayoutDef(
    name: 'Elysian Cross',
    icon: Icons.crop_rotate_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'diagonal',
  ),
  const CollageLayoutDef(
    name: 'Silk Curve',
    icon: Icons.gesture_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'scurve',
  ),
  const CollageLayoutDef(
    name: 'Heart Duo',
    icon: Icons.favorite_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'heart',
  ),
  const CollageLayoutDef(
    name: 'Double Heart',
    icon: Icons.favorite_border_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'double_heart',
  ),
  const CollageLayoutDef(
    name: 'Say HI',
    icon: Icons.text_fields_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'hi_shape',
  ),
  const CollageLayoutDef(
    name: 'Torn Strip',
    icon: Icons.auto_awesome_motion,
    imageCount: 2,
    isClipBased: true,
    clipType: 'torn_diagonal',
  ),
  const CollageLayoutDef(
    name: 'Reverse Cross',
    icon: Icons.crop_rotate_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'reverse_diagonal',
  ),
  const CollageLayoutDef(
    name: 'Zigzag Cut',
    icon: Icons.show_chart_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'zigzag',
  ),
  const CollageLayoutDef(
    name: 'Wave Flow',
    icon: Icons.waves_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'wave',
  ),
  const CollageLayoutDef(
    name: 'V-Cut',
    icon: Icons.change_history_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'vcut',
  ),
  const CollageLayoutDef(
    name: 'Circle Inset',
    icon: Icons.circle_outlined,
    imageCount: 2,
    isClipBased: true,
    clipType: 'circle_inset',
  ),
  const CollageLayoutDef(
    name: 'Diamond Inset',
    icon: Icons.diamond_outlined,
    imageCount: 2,
    isClipBased: true,
    clipType: 'diamond_inset',
  ),
  const CollageLayoutDef(
    name: 'January',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_january',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'February',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_february',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'March',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_march',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'April',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_april',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'May',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_may',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'June',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_june',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'July',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_july',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'August',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_august',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'September',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_september',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'October',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_october',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'November',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_november',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'December',
    icon: Icons.calendar_month_rounded,
    isClipBased: true,
    clipType: 'month_december',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Current Year',
    icon: Icons.numbers_rounded,
    isClipBased: true,
    clipType: 'year_dynamic',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Today\'s Date',
    icon: Icons.today_rounded,
    isClipBased: true,
    clipType: 'date_dynamic',
    imageCount: 2,
  ),

  // ── Grid-based (simple splits) ──────────────────────────────────────────
  const CollageLayoutDef(
    name: 'Left Focus',
    icon: Icons.vertical_split_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 0.65, 1.0), CellRect(0.65, 0.0, 0.35, 1.0)],
  ),
  const CollageLayoutDef(
    name: 'Right Focus',
    icon: Icons.vertical_split_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 0.35, 1.0), CellRect(0.35, 0.0, 0.65, 1.0)],
  ),
  const CollageLayoutDef(
    name: 'Top Heavy',
    icon: Icons.horizontal_split_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 1.0, 0.65), CellRect(0.0, 0.65, 1.0, 0.35)],
  ),
  const CollageLayoutDef(
    name: 'Bottom Heavy',
    icon: Icons.horizontal_split_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 1.0, 0.35), CellRect(0.0, 0.35, 1.0, 0.65)],
  ),
  const CollageLayoutDef(
    name: 'Narrow Left',
    icon: Icons.view_column_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 0.3, 1.0), CellRect(0.3, 0.0, 0.7, 1.0)],
  ),
  const CollageLayoutDef(
    name: 'Narrow Right',
    icon: Icons.view_column_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 0.7, 1.0), CellRect(0.7, 0.0, 0.3, 1.0)],
  ),
  const CollageLayoutDef(
    name: 'Top Slim',
    icon: Icons.view_stream_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 1.0, 0.3), CellRect(0.0, 0.3, 1.0, 0.7)],
  ),
  const CollageLayoutDef(
    name: 'Bottom Slim',
    icon: Icons.view_stream_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 1.0, 0.7), CellRect(0.0, 0.7, 1.0, 0.3)],
  ),
  const CollageLayoutDef(
    name: 'Golden Left',
    icon: Icons.view_column_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 0.618, 1.0), CellRect(0.618, 0.0, 0.382, 1.0)],
  ),
  const CollageLayoutDef(
    name: 'Golden Top',
    icon: Icons.view_stream_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 1.0, 0.618), CellRect(0.0, 0.618, 1.0, 0.382)],
  ),
  const CollageLayoutDef(
    name: 'Triangle Duo',
    icon: Icons.change_history_rounded,
    imageCount: 2,
    isClipBased: true,
    clipType: 'triangle_duo',
  ),
  const CollageLayoutDef(
    name: 'Trapezoid Fusion',
    icon: Icons.layers_rounded,
    isClipBased: true,
    clipType: 'trapezoid_duo',
    imageCount: 2,
  ),
  // 10 Pinteresty Layouts for 2 Images
  const CollageLayoutDef(
    name: 'Story Split',
    icon: Icons.auto_stories_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 0.3, 1.0), CellRect(0.3, 0.0, 0.7, 1.0)],
  ),
  const CollageLayoutDef(
    name: 'Film Strip',
    icon: Icons.movie_rounded,
    imageCount: 2,
    cells: [CellRect(0.1, 0.05, 0.8, 0.4), CellRect(0.1, 0.55, 0.8, 0.4)],
  ),
  const CollageLayoutDef(
    name: 'Modern Slant',
    icon: Icons.text_rotation_none_rounded,
    isClipBased: true,
    clipType: 'slanted',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Parallel View',
    icon: Icons.view_headline_rounded,
    isClipBased: true,
    clipType: 'parallelogram',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Pill Concept',
    icon: Icons.rectangle_rounded,
    isClipBased: true,
    clipType: 'capsule',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'The Arch',
    icon: Icons.account_balance_rounded,
    isClipBased: true,
    clipType: 'arch',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Organic Pair',
    icon: Icons.bubble_chart_rounded,
    isClipBased: true,
    clipType: 'blob0',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Floating Duo',
    icon: Icons.filter_none_rounded,
    imageCount: 2,
    cells: [CellRect(0.1, 0.1, 0.5, 0.5), CellRect(0.4, 0.4, 0.5, 0.5)],
  ),
  const CollageLayoutDef(
    name: 'Symmetry X',
    icon: Icons.unfold_more_rounded,
    imageCount: 2,
    cells: [CellRect(0.0, 0.0, 0.5, 0.5), CellRect(0.5, 0.5, 0.5, 0.5)],
  ),
  const CollageLayoutDef(
    name: 'Magazine Dual',
    icon: Icons.newspaper_rounded,
    imageCount: 2,
    cells: [CellRect(0.05, 0.05, 0.9, 0.6), CellRect(0.05, 0.7, 0.9, 0.25)],
  ),
  const CollageLayoutDef(
    name: 'Hearts Flower',
    icon: Icons.filter_vintage_rounded,
    isClipBased: true,
    clipType: 'hearts_flower',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Hearts Balloon',
    icon: Icons.bubble_chart_rounded,
    isClipBased: true,
    clipType: 'hearts_balloon',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Random Hearts',
    icon: Icons.favorite_border_rounded,
    isClipBased: true,
    clipType: 'random_hearts',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Leaf Fusion',
    icon: Icons.eco_rounded,
    isClipBased: true,
    clipType: 'leaf_fusion',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Artistic Hands',
    icon: Icons.gesture_rounded,
    isClipBased: true,
    clipType: 'artistic_hands_2',
    imageCount: 2,
  ),
  const CollageLayoutDef(
    name: 'Interlocking Locks',
    icon: Icons.lock_outline_rounded,
    isClipBased: true,
    clipType: 'interlocking_locks_2',
    imageCount: 2,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 3-IMAGE LAYOUTS (20)
// ═══════════════════════════════════════════════════════════════════════════════

final List<CollageLayoutDef> layouts3 = [
  const CollageLayoutDef(
    name: 'Torn Paper',
    icon: Icons.texture_rounded,
    isClipBased: true,
    clipType: 'torn_paper',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Zigzag Bands',
    icon: Icons.show_chart_rounded,
    isClipBased: true,
    clipType: 'zigzag_band',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Spiky Zigzag',
    icon: Icons.show_chart_rounded,
    isClipBased: true,
    clipType: 'spiky_zigzag',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Diagonal Heart',
    icon: Icons.favorite_border_rounded,
    isClipBased: true,
    clipType: 'diagonal_heart',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Film Strip',
    icon: Icons.movie_rounded,
    isClipBased: true,
    clipType: 'film_strip',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'I Love U',
    icon: Icons.favorite_rounded,
    isClipBased: true,
    clipType: 'i_love_u',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Artistic Columns',
    icon: Icons.view_column_rounded,
    isClipBased: true,
    clipType: 'floating_cols',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Hexagon Prism',
    icon: Icons.hexagon_rounded,
    isClipBased: true,
    clipType: 'hexagon_split',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Slanted Rows',
    icon: Icons.splitscreen_rounded,
    isClipBased: true,
    clipType: 'slanted_rows',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Stamp Trio',
    icon: Icons.confirmation_number_rounded,
    isClipBased: true,
    clipType: 'stamp_trio',
    imageCount: 3,
  ),
  // 1. 1 top + 2 bottom equal
  const CollageLayoutDef(
    name: 'Top Banner',
    icon: Icons.view_quilt_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.5),
      CellRect(0.0, 0.5, 0.5, 0.5),
      CellRect(0.5, 0.5, 0.5, 0.5),
    ],
  ),
  // 2. 2 top + 1 bottom
  const CollageLayoutDef(
    name: 'Bottom Banner',
    icon: Icons.view_quilt_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.5),
      CellRect(0.5, 0.0, 0.5, 0.5),
      CellRect(0.0, 0.5, 1.0, 0.5),
    ],
  ),
  // 3. 1 left tall + 2 right stacked
  const CollageLayoutDef(
    name: 'Left Hero',
    icon: Icons.view_sidebar_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.5, 1.0),
      CellRect(0.5, 0.0, 0.5, 0.5),
      CellRect(0.5, 0.5, 0.5, 0.5),
    ],
  ),
  // 4. 2 left stacked + 1 right tall
  const CollageLayoutDef(
    name: 'Right Hero',
    icon: Icons.view_sidebar_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.5),
      CellRect(0.0, 0.5, 0.5, 0.5),
      CellRect(0.5, 0.0, 0.5, 1.0),
    ],
  ),
  // 5. 3 vertical strips
  const CollageLayoutDef(
    name: 'Three Columns',
    icon: Icons.view_column_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.333, 1.0),
      CellRect(0.333, 0.0, 0.334, 1.0),
      CellRect(0.667, 0.0, 0.333, 1.0),
    ],
  ),
  // 6. 3 horizontal strips
  const CollageLayoutDef(
    name: 'Three Rows',
    icon: Icons.view_stream_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.333),
      CellRect(0.0, 0.333, 1.0, 0.334),
      CellRect(0.0, 0.667, 1.0, 0.333),
    ],
  ),
  // 7. Big left (60%) + 2 small right stacked
  const CollageLayoutDef(
    name: 'Left Dominant',
    icon: Icons.view_sidebar_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.6, 1.0),
      CellRect(0.6, 0.0, 0.4, 0.5),
      CellRect(0.6, 0.5, 0.4, 0.5),
    ],
  ),
  // 8. Big right (60%) + 2 small left stacked
  const CollageLayoutDef(
    name: 'Right Dominant',
    icon: Icons.view_sidebar_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.4, 0.5),
      CellRect(0.0, 0.5, 0.4, 0.5),
      CellRect(0.4, 0.0, 0.6, 1.0),
    ],
  ),
  // 9. Big top (65%) + 2 bottom
  const CollageLayoutDef(
    name: 'Top Focus',
    icon: Icons.view_quilt_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.65),
      CellRect(0.0, 0.65, 0.5, 0.35),
      CellRect(0.5, 0.65, 0.5, 0.35),
    ],
  ),
  // 10. 2 top small + big bottom (65%)
  const CollageLayoutDef(
    name: 'Bottom Focus',
    icon: Icons.view_quilt_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.35),
      CellRect(0.5, 0.0, 0.5, 0.35),
      CellRect(0.0, 0.35, 1.0, 0.65),
    ],
  ),
  // 11. T-shape: big top + 2 bottom
  const CollageLayoutDef(
    name: 'T-Shape',
    icon: Icons.view_compact_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.55),
      CellRect(0.0, 0.55, 0.4, 0.45),
      CellRect(0.4, 0.55, 0.6, 0.45),
    ],
  ),
  // 12. Inverted T
  const CollageLayoutDef(
    name: 'Inverted T',
    icon: Icons.view_compact_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.6, 0.45),
      CellRect(0.6, 0.0, 0.4, 0.45),
      CellRect(0.0, 0.45, 1.0, 0.55),
    ],
  ),
  // 13. L-shape
  const CollageLayoutDef(
    name: 'L-Shape',
    icon: Icons.crop_5_4_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.6, 0.6),
      CellRect(0.6, 0.0, 0.4, 0.6),
      CellRect(0.0, 0.6, 1.0, 0.4),
    ],
  ),
  // 14. Big center + top strip + bottom strip
  const CollageLayoutDef(
    name: 'Sandwich',
    icon: Icons.view_day_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.25),
      CellRect(0.0, 0.25, 1.0, 0.5),
      CellRect(0.0, 0.75, 1.0, 0.25),
    ],
  ),
  // 15. Left strip + big center + right strip
  const CollageLayoutDef(
    name: 'Side Panels',
    icon: Icons.view_week_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.25, 1.0),
      CellRect(0.25, 0.0, 0.5, 1.0),
      CellRect(0.75, 0.0, 0.25, 1.0),
    ],
  ),
  // 16. Staircase 3
  const CollageLayoutDef(
    name: 'Staircase',
    icon: Icons.stairs_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.4),
      CellRect(0.25, 0.35, 0.5, 0.35),
      CellRect(0.5, 0.6, 0.5, 0.4),
    ],
  ),
  // 17. Wide center column
  const CollageLayoutDef(
    name: 'Wide Center',
    icon: Icons.view_column_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.25, 1.0),
      CellRect(0.25, 0.0, 0.55, 1.0),
      CellRect(0.8, 0.0, 0.2, 1.0),
    ],
  ),
  // 18. Big left top + small right top + full bottom
  const CollageLayoutDef(
    name: 'Corner Focus',
    icon: Icons.dashboard_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.65, 0.55),
      CellRect(0.65, 0.0, 0.35, 0.55),
      CellRect(0.0, 0.55, 1.0, 0.45),
    ],
  ),
  // 19. Full left + small top-right + small bottom-right
  const CollageLayoutDef(
    name: 'Sidebar Stack',
    icon: Icons.view_sidebar_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.55, 1.0),
      CellRect(0.55, 0.0, 0.45, 0.4),
      CellRect(0.55, 0.4, 0.45, 0.6),
    ],
  ),
  // 20. Golden mix
  const CollageLayoutDef(
    name: 'Golden Frame',
    icon: Icons.auto_awesome_mosaic_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.618, 0.618),
      CellRect(0.618, 0.0, 0.382, 0.618),
      CellRect(0.0, 0.618, 1.0, 0.382),
    ],
  ),
  const CollageLayoutDef(
    name: 'Triangle Trio',
    icon: Icons.details_rounded,
    imageCount: 3,
    isClipBased: true,
    clipType: 'triangle_trio',
  ),
  // 10 Pinteresty Layouts for 3 Images
  const CollageLayoutDef(
    name: 'Vertical Trio',
    icon: Icons.view_column_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.4, 1.0),
      CellRect(0.4, 0.0, 0.3, 1.0),
      CellRect(0.7, 0.0, 0.3, 1.0),
    ],
  ),
  const CollageLayoutDef(
    name: 'Hero Focus',
    icon: Icons.person_pin_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.7),
      CellRect(0.0, 0.7, 0.5, 0.3),
      CellRect(0.5, 0.7, 0.5, 0.3),
    ],
  ),
  const CollageLayoutDef(
    name: 'Side Banner',
    icon: Icons.view_sidebar_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.6, 1.0),
      CellRect(0.6, 0.0, 0.4, 0.5),
      CellRect(0.6, 0.5, 0.4, 0.5),
    ],
  ),
  const CollageLayoutDef(
    name: 'Offset Triple',
    icon: Icons.dashboard_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.5),
      CellRect(0.5, 0.15, 0.4, 0.4),
      CellRect(0.1, 0.55, 0.8, 0.35),
    ],
  ),
  const CollageLayoutDef(
    name: 'Minimal Row',
    icon: Icons.reorder_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.05, 0.05, 0.9, 0.25),
      CellRect(0.05, 0.35, 0.9, 0.25),
      CellRect(0.05, 0.65, 0.9, 0.3),
    ],
  ),
  const CollageLayoutDef(
    name: 'Geometric Mix',
    icon: Icons.category_rounded,
    isClipBased: true,
    clipType: 'triangle_duo',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Capsule Stack',
    icon: Icons.vertical_distribute_rounded,
    isClipBased: true,
    clipType: 'capsule',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Blob Flow',
    icon: Icons.grain_rounded,
    isClipBased: true,
    clipType: 'blob1',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Abstract Stairs',
    icon: Icons.stairs_rounded,
    imageCount: 3,
    cells: [
      CellRect(0.0, 0.0, 0.4, 0.4),
      CellRect(0.3, 0.3, 0.4, 0.4),
      CellRect(0.6, 0.6, 0.4, 0.4),
    ],
  ),
  const CollageLayoutDef(
    name: 'Split Arch',
    icon: Icons.door_front_door_rounded,
    isClipBased: true,
    clipType: 'arch',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Hearts Flower',
    icon: Icons.filter_vintage_rounded,
    isClipBased: true,
    clipType: 'hearts_flower',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Hearts Balloon',
    icon: Icons.bubble_chart_rounded,
    isClipBased: true,
    clipType: 'hearts_balloon',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Random Hearts',
    icon: Icons.favorite_border_rounded,
    isClipBased: true,
    clipType: 'random_hearts',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Leaf Fusion',
    icon: Icons.eco_rounded,
    isClipBased: true,
    clipType: 'leaf_fusion',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Heart Trio',
    icon: Icons.favorite_rounded,
    isClipBased: true,
    clipType: 'heart3',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Lotus Trio',
    icon: Icons.local_florist_rounded,
    isClipBased: true,
    clipType: 'lotus',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Maple Trio',
    icon: Icons.park_rounded,
    isClipBased: true,
    clipType: 'maple_trio',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Arc Trio',
    icon: Icons.incomplete_circle_rounded,
    isClipBased: true,
    clipType: 'arc_trio',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Christmas Magic',
    icon: Icons.park_rounded,
    isClipBased: true,
    clipType: 'christmas_star',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Puzzle Trio',
    icon: Icons.extension_rounded,
    isClipBased: true,
    clipType: 'puzzle_trio',
    imageCount: 3,
  ),
  const CollageLayoutDef(
    name: 'Cat Hearts',
    icon: Icons.pets,
    isClipBased: true,
    clipType: 'cat_hearts',
    imageCount: 3,
  ),
];






// ═══════════════════════════════════════════════════════════════════════════════
// 4-IMAGE LAYOUTS (20)
// ═══════════════════════════════════════════════════════════════════════════════

final List<CollageLayoutDef> layouts4 = [
  const CollageLayoutDef(
    name: 'Year 2x2 (Dynamic)',
    icon: Icons.calendar_today_rounded,
    isClipBased: true,
    clipType: 'year_grid_4',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Asymmetric Arch',
    icon: Icons.dashboard_customize_rounded,
    isClipBased: true,
    clipType: 'asymmetric_arch_4',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Slanted Gallery',
    icon: Icons.view_sidebar_rounded,
    isClipBased: true,
    clipType: 'slanted_gallery_4',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Diamond Grid',
    icon: Icons.grid_view_rounded,
    isClipBased: true,
    clipType: 'diamond_grid_4',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Slanted Film',
    icon: Icons.movie_filter_rounded,
    isClipBased: true,
    clipType: 'slanted_film_4',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Ghost Air',
    icon: Icons.air_rounded,
    isClipBased: true,
    clipType: 'ghost_air',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Artistic Columns',
    icon: Icons.view_column_rounded,
    isClipBased: true,
    clipType: 'floating_cols',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Hexagon Quad',
    icon: Icons.hexagon_outlined,
    isClipBased: true,
    clipType: 'hexagon_split',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Shape Grid',
    icon: Icons.auto_awesome_rounded,
    isClipBased: true,
    clipType: 'shape_grid_4',
    imageCount: 4,
  ),
  // 1. Classic 2x2
  const CollageLayoutDef(
    name: 'Classic Grid',
    icon: Icons.grid_view_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.5),
      CellRect(0.5, 0.0, 0.5, 0.5),
      CellRect(0.0, 0.5, 0.5, 0.5),
      CellRect(0.5, 0.5, 0.5, 0.5),
    ],
  ),
  // 2. 4 vertical strips
  const CollageLayoutDef(
    name: 'Film Strip',
    icon: Icons.view_column_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.25, 1.0),
      CellRect(0.25, 0.0, 0.25, 1.0),
      CellRect(0.5, 0.0, 0.25, 1.0),
      CellRect(0.75, 0.0, 0.25, 1.0),
    ],
  ),
  // 3. 4 horizontal strips
  const CollageLayoutDef(
    name: 'Stack Rows',
    icon: Icons.view_stream_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.25),
      CellRect(0.0, 0.25, 1.0, 0.25),
      CellRect(0.0, 0.5, 1.0, 0.25),
      CellRect(0.0, 0.75, 1.0, 0.25),
    ],
  ),
  // 4. 1 big left + 3 right stacked
  const CollageLayoutDef(
    name: 'Left Gallery',
    icon: Icons.view_sidebar_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.55, 1.0),
      CellRect(0.55, 0.0, 0.45, 0.333),
      CellRect(0.55, 0.333, 0.45, 0.334),
      CellRect(0.55, 0.667, 0.45, 0.333),
    ],
  ),
  // 5. 3 left stacked + 1 big right
  const CollageLayoutDef(
    name: 'Right Gallery',
    icon: Icons.view_sidebar_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.45, 0.333),
      CellRect(0.0, 0.333, 0.45, 0.334),
      CellRect(0.0, 0.667, 0.45, 0.333),
      CellRect(0.45, 0.0, 0.55, 1.0),
    ],
  ),
  // 6. 1 big top + 3 bottom
  const CollageLayoutDef(
    name: 'Top Gallery',
    icon: Icons.view_quilt_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.55),
      CellRect(0.0, 0.55, 0.333, 0.45),
      CellRect(0.333, 0.55, 0.334, 0.45),
      CellRect(0.667, 0.55, 0.333, 0.45),
    ],
  ),
  // 7. 3 top + 1 big bottom
  const CollageLayoutDef(
    name: 'Bottom Gallery',
    icon: Icons.view_quilt_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.333, 0.45),
      CellRect(0.333, 0.0, 0.334, 0.45),
      CellRect(0.667, 0.0, 0.333, 0.45),
      CellRect(0.0, 0.45, 1.0, 0.55),
    ],
  ),
  // 8. Big top-left + small top-right + 2 bottom
  const CollageLayoutDef(
    name: 'Corner Hero',
    icon: Icons.dashboard_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.65, 0.55),
      CellRect(0.65, 0.0, 0.35, 0.55),
      CellRect(0.0, 0.55, 0.5, 0.45),
      CellRect(0.5, 0.55, 0.5, 0.45),
    ],
  ),
  // 9. 2 top + big bottom-left + small bottom-right
  const CollageLayoutDef(
    name: 'Offset Grid',
    icon: Icons.dashboard_customize_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.45),
      CellRect(0.5, 0.0, 0.5, 0.45),
      CellRect(0.0, 0.45, 0.65, 0.55),
      CellRect(0.65, 0.45, 0.35, 0.55),
    ],
  ),
  // 10. Center cross
  const CollageLayoutDef(
    name: 'Cross Layout',
    icon: Icons.add_box_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.45, 0.45),
      CellRect(0.55, 0.0, 0.45, 0.45),
      CellRect(0.0, 0.55, 0.45, 0.45),
      CellRect(0.55, 0.55, 0.45, 0.45),
    ],
  ),
  // 11. Tall left pair + wide right pair
  const CollageLayoutDef(
    name: 'Mixed Pair',
    icon: Icons.view_compact_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.4, 0.5),
      CellRect(0.0, 0.5, 0.4, 0.5),
      CellRect(0.4, 0.0, 0.6, 0.5),
      CellRect(0.4, 0.5, 0.6, 0.5),
    ],
  ),
  // 12. Asymmetric 2x2
  const CollageLayoutDef(
    name: 'Asymmetric',
    icon: Icons.view_compact_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.6, 0.4),
      CellRect(0.6, 0.0, 0.4, 0.4),
      CellRect(0.0, 0.4, 0.4, 0.6),
      CellRect(0.4, 0.4, 0.6, 0.6),
    ],
  ),
  // 13. Big center + 3 edges
  const CollageLayoutDef(
    name: 'Center Stage',
    icon: Icons.center_focus_strong_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.15, 0.15, 0.7, 0.7),
      CellRect(0.0, 0.0, 0.5, 0.15),
      CellRect(0.5, 0.0, 0.5, 0.15),
      CellRect(0.0, 0.85, 1.0, 0.15),
    ],
  ),
  // 14. L-shape big + 3 small
  const CollageLayoutDef(
    name: 'L-Block',
    icon: Icons.crop_5_4_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.6, 0.6),
      CellRect(0.6, 0.0, 0.4, 0.3),
      CellRect(0.6, 0.3, 0.4, 0.3),
      CellRect(0.0, 0.6, 1.0, 0.4),
    ],
  ),
  // 15. Reverse L
  const CollageLayoutDef(
    name: 'Reverse L',
    icon: Icons.crop_5_4_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.4),
      CellRect(0.0, 0.4, 0.4, 0.3),
      CellRect(0.0, 0.7, 0.4, 0.3),
      CellRect(0.4, 0.4, 0.6, 0.6),
    ],
  ),
  // 16. Wide top + 3 bottom equal
  const CollageLayoutDef(
    name: 'Showcase',
    icon: Icons.view_day_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.6),
      CellRect(0.0, 0.6, 0.333, 0.4),
      CellRect(0.333, 0.6, 0.334, 0.4),
      CellRect(0.667, 0.6, 0.333, 0.4),
    ],
  ),
  // 17. 3 top + wide bottom
  const CollageLayoutDef(
    name: 'Top Trio',
    icon: Icons.view_day_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.333, 0.4),
      CellRect(0.333, 0.0, 0.334, 0.4),
      CellRect(0.667, 0.0, 0.333, 0.4),
      CellRect(0.0, 0.4, 1.0, 0.6),
    ],
  ),
  // 18. Vertical sandwich: big center + top/bottom strips + right strip
  const CollageLayoutDef(
    name: 'Panel Mix',
    icon: Icons.view_week_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.7, 0.5),
      CellRect(0.0, 0.5, 0.7, 0.5),
      CellRect(0.7, 0.0, 0.3, 0.5),
      CellRect(0.7, 0.5, 0.3, 0.5),
    ],
  ),
  // 19. Diagonal blocks
  const CollageLayoutDef(
    name: 'Checker',
    icon: Icons.apps_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.55, 0.45),
      CellRect(0.55, 0.0, 0.45, 0.55),
      CellRect(0.0, 0.45, 0.45, 0.55),
      CellRect(0.45, 0.55, 0.55, 0.45),
    ],
  ),
  // 20. Golden ratio grid
  const CollageLayoutDef(
    name: 'Golden Grid',
    icon: Icons.auto_awesome_mosaic_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.618, 0.618),
      CellRect(0.618, 0.0, 0.382, 0.618),
      CellRect(0.0, 0.618, 0.382, 0.382),
      CellRect(0.382, 0.618, 0.618, 0.382),
    ],
  ),
  const CollageLayoutDef(
    name: 'Honeycomb Hub',
    icon: Icons.hive_rounded,
    imageCount: 4,
    isClipBased: true,
    clipType: 'honeycomb4',
  ),
  // 10 Pinteresty Layouts for 4 Images
  const CollageLayoutDef(
    name: 'Asymmetric Quad',
    icon: Icons.grid_view_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.4, 0.4),
      CellRect(0.4, 0.0, 0.6, 0.6),
      CellRect(0.0, 0.4, 0.4, 0.6),
      CellRect(0.4, 0.6, 0.6, 0.4),
    ],
  ),
  const CollageLayoutDef(
    name: 'Editorial Grid',
    icon: Icons.article_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.7, 0.4),
      CellRect(0.7, 0.0, 0.3, 0.4),
      CellRect(0.0, 0.4, 0.3, 0.6),
      CellRect(0.3, 0.4, 0.7, 0.6),
    ],
  ),
  const CollageLayoutDef(
    name: 'Columns 4',
    icon: Icons.view_column_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 0.2, 1.0),
      CellRect(0.2, 0.0, 0.3, 1.0),
      CellRect(0.5, 0.0, 0.3, 1.0),
      CellRect(0.8, 0.0, 0.2, 1.0),
    ],
  ),
  const CollageLayoutDef(
    name: 'Banner Stack',
    icon: Icons.view_day_rounded,
    imageCount: 4,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.4),
      CellRect(0.0, 0.4, 0.33, 0.6),
      CellRect(0.33, 0.4, 0.34, 0.6),
      CellRect(0.67, 0.4, 0.33, 0.6),
    ],
  ),

  const CollageLayoutDef(
    name: 'Diagonal Star',
    icon: Icons.filter_tilt_shift_rounded,
    isClipBased: true,
    clipType: 'diagonal_star',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Slanted Rows',
    icon: Icons.text_rotation_down_rounded,
    isClipBased: true,
    clipType: 'slanted_rows',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Capsule Group',
    icon: Icons.auto_awesome_rounded,
    isClipBased: true,
    clipType: 'capsule',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Art Arch',
    icon: Icons.door_sliding_rounded,
    isClipBased: true,
    clipType: 'arch',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Abstract Blob',
    icon: Icons.gesture_rounded,
    isClipBased: true,
    clipType: 'blob0',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Hearts Flower',
    icon: Icons.filter_vintage_rounded,
    isClipBased: true,
    clipType: 'hearts_flower',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Hearts Balloon',
    icon: Icons.bubble_chart_rounded,
    isClipBased: true,
    clipType: 'hearts_balloon',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Random Hearts',
    icon: Icons.favorite_border_rounded,
    isClipBased: true,
    clipType: 'random_hearts',
    imageCount: 4,
  ),
  const CollageLayoutDef(
    name: 'Leaf Fusion',
    icon: Icons.eco_rounded,
    isClipBased: true,
    clipType: 'leaf_fusion',
    imageCount: 4,
  ),
];



// ═══════════════════════════════════════════════════════════════════════════════
// 5-IMAGE LAYOUTS (20)
// ═══════════════════════════════════════════════════════════════════════════════

final List<CollageLayoutDef> layouts5 = [
  const CollageLayoutDef(
    name: 'Pinwheel',
    icon: Icons.wind_power_rounded,
    isClipBased: true,
    clipType: 'pinwheel_5',
    imageCount: 5,
  ),
  // 1. Classic 2-top + 3-bottom
  const CollageLayoutDef(
    name: 'Classic Five',
    icon: Icons.grid_view_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.5),
      CellRect(0.5, 0.0, 0.5, 0.5),
      CellRect(0.0, 0.5, 0.333, 0.5),
      CellRect(0.333, 0.5, 0.334, 0.5),
      CellRect(0.667, 0.5, 0.333, 0.5),
    ],
  ),
  // 2. 3-top + 2-bottom
  const CollageLayoutDef(
    name: 'Top Row',
    icon: Icons.grid_view_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.333, 0.5),
      CellRect(0.333, 0.0, 0.334, 0.5),
      CellRect(0.667, 0.0, 0.333, 0.5),
      CellRect(0.0, 0.5, 0.5, 0.5),
      CellRect(0.5, 0.5, 0.5, 0.5),
    ],
  ),
  // 3. Big left + 4 right grid
  const CollageLayoutDef(
    name: 'Left Feature',
    icon: Icons.view_sidebar_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.55, 1.0),
      CellRect(0.55, 0.0, 0.45, 0.25),
      CellRect(0.55, 0.25, 0.45, 0.25),
      CellRect(0.55, 0.5, 0.45, 0.25),
      CellRect(0.55, 0.75, 0.45, 0.25),
    ],
  ),
  // 4. 4 left grid + big right
  const CollageLayoutDef(
    name: 'Right Feature',
    icon: Icons.view_sidebar_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.45, 0.25),
      CellRect(0.0, 0.25, 0.45, 0.25),
      CellRect(0.0, 0.5, 0.45, 0.25),
      CellRect(0.0, 0.75, 0.45, 0.25),
      CellRect(0.45, 0.0, 0.55, 1.0),
    ],
  ),
  // 5. Magazine: hero top + 4 bottom
  const CollageLayoutDef(
    name: 'Magazine',
    icon: Icons.article_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.55),
      CellRect(0.0, 0.55, 0.25, 0.45),
      CellRect(0.25, 0.55, 0.25, 0.45),
      CellRect(0.5, 0.55, 0.25, 0.45),
      CellRect(0.75, 0.55, 0.25, 0.45),
    ],
  ),
  // 6. 4 top + hero bottom
  const CollageLayoutDef(
    name: 'Bottom Showcase',
    icon: Icons.article_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.25, 0.45),
      CellRect(0.25, 0.0, 0.25, 0.45),
      CellRect(0.5, 0.0, 0.25, 0.45),
      CellRect(0.75, 0.0, 0.25, 0.45),
      CellRect(0.0, 0.45, 1.0, 0.55),
    ],
  ),
  // 7. T-shape: 1 big left + 2 right + 2 bottom
  const CollageLayoutDef(
    name: 'T-Block',
    icon: Icons.dashboard_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.6, 0.6),
      CellRect(0.6, 0.0, 0.4, 0.3),
      CellRect(0.6, 0.3, 0.4, 0.3),
      CellRect(0.0, 0.6, 0.5, 0.4),
      CellRect(0.5, 0.6, 0.5, 0.4),
    ],
  ),
  // 8. Cross: center big + 4 corners
  const CollageLayoutDef(
    name: 'Cross Focus',
    icon: Icons.center_focus_strong_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.2, 0.2, 0.6, 0.6),
      CellRect(0.0, 0.0, 0.2, 0.5),
      CellRect(0.8, 0.0, 0.2, 0.5),
      CellRect(0.0, 0.5, 0.2, 0.5),
      CellRect(0.8, 0.5, 0.2, 0.5),
    ],
  ),
  // 9. 5 vertical strips
  const CollageLayoutDef(
    name: 'Five Columns',
    icon: Icons.view_column_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.2, 1.0),
      CellRect(0.2, 0.0, 0.2, 1.0),
      CellRect(0.4, 0.0, 0.2, 1.0),
      CellRect(0.6, 0.0, 0.2, 1.0),
      CellRect(0.8, 0.0, 0.2, 1.0),
    ],
  ),
  // 10. 5 horizontal strips
  const CollageLayoutDef(
    name: 'Five Rows',
    icon: Icons.view_stream_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 1.0, 0.2),
      CellRect(0.0, 0.2, 1.0, 0.2),
      CellRect(0.0, 0.4, 1.0, 0.2),
      CellRect(0.0, 0.6, 1.0, 0.2),
      CellRect(0.0, 0.8, 1.0, 0.2),
    ],
  ),
  // 11. Mosaic: 1 big + 2 medium + 2 small
  const CollageLayoutDef(
    name: 'Mosaic',
    icon: Icons.auto_awesome_mosaic_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.6, 0.6),
      CellRect(0.6, 0.0, 0.4, 0.35),
      CellRect(0.6, 0.35, 0.4, 0.25),
      CellRect(0.0, 0.6, 0.35, 0.4),
      CellRect(0.35, 0.6, 0.65, 0.4),
    ],
  ),
  // 12. Reverse mosaic
  const CollageLayoutDef(
    name: 'Reverse Mosaic',
    icon: Icons.auto_awesome_mosaic_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.4, 0.4, 0.6, 0.6),
      CellRect(0.0, 0.0, 0.4, 0.35),
      CellRect(0.0, 0.35, 0.4, 0.25),
      CellRect(0.4, 0.0, 0.35, 0.4),
      CellRect(0.75, 0.0, 0.25, 0.4),
    ],
  ),

  // 14. Big center row + 2 top + 2 bottom
  const CollageLayoutDef(
    name: 'Center Band',
    icon: Icons.view_day_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.3),
      CellRect(0.5, 0.0, 0.5, 0.3),
      CellRect(0.0, 0.3, 1.0, 0.4),
      CellRect(0.0, 0.7, 0.5, 0.3),
      CellRect(0.5, 0.7, 0.5, 0.3),
    ],
  ),
  // 15. 2 tall left + 3 stacked right
  const CollageLayoutDef(
    name: 'Duo Trio',
    icon: Icons.view_compact_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.5),
      CellRect(0.0, 0.5, 0.5, 0.5),
      CellRect(0.5, 0.0, 0.5, 0.333),
      CellRect(0.5, 0.333, 0.5, 0.334),
      CellRect(0.5, 0.667, 0.5, 0.333),
    ],
  ),
  // 16. 3 stacked left + 2 tall right
  const CollageLayoutDef(
    name: 'Trio Duo',
    icon: Icons.view_compact_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.333),
      CellRect(0.0, 0.333, 0.5, 0.334),
      CellRect(0.0, 0.667, 0.5, 0.333),
      CellRect(0.5, 0.0, 0.5, 0.5),
      CellRect(0.5, 0.5, 0.5, 0.5),
    ],
  ),
  // 17. Big top-left + 2 top-right stacked + 2 bottom
  const CollageLayoutDef(
    name: 'Feature Mix',
    icon: Icons.dashboard_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.6, 0.55),
      CellRect(0.6, 0.0, 0.4, 0.275),
      CellRect(0.6, 0.275, 0.4, 0.275),
      CellRect(0.0, 0.55, 0.5, 0.45),
      CellRect(0.5, 0.55, 0.5, 0.45),
    ],
  ),
  // 18. Checkerboard 5
  const CollageLayoutDef(
    name: 'Puzzle',
    icon: Icons.extension_rounded,
    imageCount: 5,
    isClipBased: true,
    clipType: 'puzzle_5',
  ),
  // 19. Frame layout: 4 border tiles + 1 center
  const CollageLayoutDef(
    name: 'Frame',
    icon: Icons.crop_free_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.15, 0.15, 0.7, 0.7),
      CellRect(0.0, 0.0, 1.0, 0.15),
      CellRect(0.0, 0.85, 1.0, 0.15),
      CellRect(0.0, 0.15, 0.15, 0.7),
      CellRect(0.85, 0.15, 0.15, 0.7),
    ],
  ),
  // 20. Golden five
  const CollageLayoutDef(
    name: 'Golden Five',
    icon: Icons.auto_awesome_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.618, 0.618),
      CellRect(0.618, 0.0, 0.382, 0.382),
      CellRect(0.618, 0.382, 0.382, 0.236),
      CellRect(0.0, 0.618, 0.382, 0.382),
      CellRect(0.382, 0.618, 0.618, 0.382),
    ],
  ),
  const CollageLayoutDef(
    name: 'Conceptual Crest',
    icon: Icons.shield_rounded,
    imageCount: 5,
    isClipBased: true,
    clipType: 'crest5',
  ),
  // 10 Pinteresty Layouts for 5 Images
  const CollageLayoutDef(
    name: 'Magazine Spread',
    icon: Icons.menu_book_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.65, 1.0),
      CellRect(0.65, 0.0, 0.35, 0.25),
      CellRect(0.65, 0.25, 0.35, 0.25),
      CellRect(0.65, 0.5, 0.35, 0.25),
      CellRect(0.65, 0.75, 0.35, 0.25),
    ],
  ),
  const CollageLayoutDef(
    name: 'Pinterest Grid',
    icon: Icons.grid_on_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.5, 0.4),
      CellRect(0.5, 0.0, 0.5, 0.6),
      CellRect(0.0, 0.4, 0.5, 0.6),
      CellRect(0.5, 0.6, 0.5, 0.4),
      CellRect(0.25, 0.3, 0.5, 0.4),
    ],
  ),
  const CollageLayoutDef(
    name: 'Staircase',
    icon: Icons.stairs_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0,  0.0,   0.3,  1.0),   // Full left pillar
      CellRect(0.3,  0.0,   0.35, 0.65),  // Middle stepped pillar
      CellRect(0.65, 0.0,   0.35, 0.325), // Top small step
      CellRect(0.65, 0.325, 0.35, 0.325), // Middle small step
      CellRect(0.3,  0.65,  0.7,  0.35),  // Large bottom base
    ],
  ),
  const CollageLayoutDef(
    name: 'DAD Heart',
    icon: Icons.favorite_rounded,
    isClipBased: true,
    clipType: 'dad_heart',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Vertical Strips',
    icon: Icons.view_headline_rounded,
    imageCount: 5,
    cells: [
      CellRect(0.0, 0.0, 0.15, 1.0),
      CellRect(0.15, 0.0, 0.25, 1.0),
      CellRect(0.4, 0.0, 0.2, 1.0),
      CellRect(0.6, 0.0, 0.25, 1.0),
      CellRect(0.85, 0.0, 0.15, 1.0),
    ],
  ),
  const CollageLayoutDef(
    name: 'Modern Circle',
    icon: Icons.circle_outlined,
    isClipBased: true,
    clipType: 'circle_inset',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Diamond Weave',
    icon: Icons.diamond_rounded,
    isClipBased: true,
    clipType: 'diamond_inset',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Organic Web',
    icon: Icons.bubble_chart_rounded,
    isClipBased: true,
    clipType: 'blob1',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Arch Trio+',
    icon: Icons.door_front_door_rounded,
    isClipBased: true,
    clipType: 'arch',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Geometric Crest',
    icon: Icons.security_rounded,
    isClipBased: true,
    clipType: 'crest5',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Slanted Mosaic',
    icon: Icons.text_rotate_vertical_rounded,
    isClipBased: true,
    clipType: 'slanted',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Hearts Flower',
    icon: Icons.filter_vintage_rounded,
    isClipBased: true,
    clipType: 'hearts_flower',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Hearts Balloon',
    icon: Icons.bubble_chart_rounded,
    isClipBased: true,
    clipType: 'hearts_balloon',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Random Hearts',
    icon: Icons.favorite_border_rounded,
    isClipBased: true,
    clipType: 'random_hearts',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Leaf Fusion',
    icon: Icons.eco_rounded,
    isClipBased: true,
    clipType: 'leaf_fusion',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Comic Burst',
    icon: Icons.auto_awesome_rounded,
    isClipBased: true,
    clipType: 'comic_burst_5',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Fan Burst',
    icon: Icons.filter_tilt_shift_rounded,
    isClipBased: true,
    clipType: 'fan_burst_5',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Radial 5',
    icon: Icons.track_changes_rounded,
    isClipBased: true,
    clipType: 'radial_5',
    imageCount: 5,
  ),
  const CollageLayoutDef(
    name: 'Star Burst',
    icon: Icons.star_border_rounded,
    isClipBased: true,
    clipType: 'star_burst_5',
    imageCount: 5,
  ),
];


final List<CollageLayoutDef> layouts6 = [
  const CollageLayoutDef(
    name: 'Slanted Six',
    icon: Icons.grid_view_rounded,
    isClipBased: true,
    clipType: 'slanted_6',
    imageCount: 6,
  ),
];

/// Returns all layouts for a given image count.
List<CollageLayoutDef> getLayoutsForCount(int imageCount) {
  switch (imageCount) {
    case 2:
      return layouts2;
    case 3:
      return layouts3;
    case 4:
      return layouts4;
    case 5:
      return layouts5;
    case 6:
      return layouts6;
    default:
      return layouts5;
  }
}

