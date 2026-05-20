import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:photho_editor/collage_models.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:photho_editor/commontext.dart';
import 'package:photho_editor/sharedstyle.dart';
import 'package:photho_editor/special_layouts_registry.dart';
import 'dart:math' as math;
import 'package:photho_editor/collage_layout_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class DynamicCollageEditor extends StatefulWidget {
  final List<File> initialImages;
  final int initialLayoutIndex;
  const DynamicCollageEditor({
    super.key,
    required this.initialImages,
    this.initialLayoutIndex = 0,
  });

  @override
  State<DynamicCollageEditor> createState() => _DynamicCollageEditorState();
}

class _DynamicCollageEditorState extends State<DynamicCollageEditor>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();
  late List<File> images;
  final ImagePicker _picker = ImagePicker();

  // General State
  double _aspectRatio = 0.8;
  double _borderWidth = 4.0;
  Color _borderColor = Colors.white;
  int _currentLayoutIndex = 0;
  BackgroundStyle _activeBackground =
      appBackgrounds[3]; // Default: Glacier Blue

  // Per-image state
  late List<Offset> _imageOffsets;
  late List<double> _imageRotations;
  late List<double> _imageScales;

  // Base states for gesture start
  late List<double> _baseScales;
  late List<double> _baseRotations;

  // Text State
  List<TextProperties> _textItems = [];
  bool _isDraggingItem = false;

  // Layout Definitions
  late List<CollageLayoutDef> _layouts;

  // ── Animation for the subtle canvas glow ──────────────────────────────
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    images = widget.initialImages;
    _initializeLayouts();
    _applyLayout(widget.initialLayoutIndex);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _initializeLayouts() {
    _layouts = getLayoutsForCount(images.length);
  }

  void _applyLayout(int index) {
    setState(() {
      _currentLayoutIndex = index;
      _imageOffsets = List<Offset>.filled(images.length, Offset.zero);
      _imageRotations = List<double>.filled(images.length, 0.0);
      _imageScales = List<double>.filled(images.length, 1.0);
      _baseScales = List<double>.filled(images.length, 1.0);
      _baseRotations = List<double>.filled(images.length, 0.0);
    });
  }

  void _handleTextAction({TextProperties? existing, int? index}) {
    CollageTextHandler.showTextEditor(
      context: context,
      initialText: existing?.text,
      initialColor: existing?.color,
      initialFont: existing?.font,
      onComplete: (text, color, font) {
        setState(() {
          if (index != null) {
            _textItems[index] = _textItems[index].copyWith(
              text: text,
              color: color,
              font: font,
            );
          } else {
            _textItems.add(
              TextProperties(text: text, color: color, font: font),
            );
          }
        });
      },
    );
  }

  Future<void> _pickNewImageForIndex(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        images[index] = File(pickedFile.path);
        // Reset transforms so the newly picked image is centered properly
        _imageOffsets[index] = Offset.zero;
        _imageRotations[index] = 0.0;
        _imageScales[index] = 1.0;
        _baseScales[index] = 1.0;
        _baseRotations[index] = 0.0;
      });
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Animated background gradient
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (ctx, _) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.6),
                    radius: 1.2,
                    colors: [
                      _activeBackground.color1.withOpacity(
                        _glowAnimation.value,
                      ),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 24),
              Expanded(child: Center(child: _buildCanvas())),
              _buildToolbar(),
            ],
          ),

          // Drag-to-delete trash bin
          if (_isDraggingItem)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 100),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Colors.redAccent, Color(0xFFB71C1C)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.6),
                      blurRadius: 25,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      title: const Text(
        "Create Collage",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => CollageHelper.saveCollage(_boundaryKey, context),
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 8, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0072FF).withOpacity(0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "SAVE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Canvas ──────────────────────────────────────────────────────────────
  Widget _buildCanvas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RepaintBoundary(
        key: _boundaryKey,
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Container(
            decoration: _activeBackground.decoration.copyWith(
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Images
                ...List.generate(images.length, (i) => _buildDraggableImage(i)),

                // Text layers
                for (int i = 0; i < _textItems.length; i++)
                  DraggableTextWidget(
                    properties: _textItems[i],
                    onTap: () =>
                        _handleTextAction(existing: _textItems[i], index: i),
                    onDragStatusChanged: (d) =>
                        setState(() => _isDraggingItem = d),
                    onDelete: () => setState(() => _textItems.removeAt(i)),
                  ),

                // Global overlays for special layouts
                _buildGlobalSpecialOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Draggable Image ──────────────────────────────────────────────────────
  Widget _buildDraggableImage(int index) {
    final layout = _layouts[_currentLayoutIndex];

    // The base image with manual manipulation transforms
    Widget imageContent = Transform.translate(
      offset: _imageOffsets[index],
      child: Transform.rotate(
        angle: _imageRotations[index],
        child: Transform.scale(
          scale: _imageScales[index],
          child: GestureDetector(
            onDoubleTap: () => _pickNewImageForIndex(index),
            onScaleStart: (details) {
              setState(() {
                _isDraggingItem = true;
                _baseScales[index] = _imageScales[index];
                _baseRotations[index] = _imageRotations[index];
              });
            },
            onScaleUpdate: (details) {
              setState(() {
                _imageOffsets[index] += details.focalPointDelta;
                if (details.scale != 1.0) {
                  _imageScales[index] = _baseScales[index] * details.scale;
                }
                if (details.rotation != 0.0) {
                  _imageRotations[index] =
                      _baseRotations[index] + details.rotation;
                }
              });
            },

            onScaleEnd: (_) => setState(() => _isDraggingItem = false),
            child: Image.file(
              images[index],
              fit: BoxFit.cover,
              // Make sure the image exceeds its frame so it can be panned
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );

    if (layout.isClipBased) {
      return _applyGridClip(index, layout, imageContent);
    } else if (layout.cells != null && index < layout.cells!.length) {
      return _applyCellClip(index, layout.cells![index], imageContent);
    } else {
      // Fallback/Legacy logic
      return Container(
        width: 160,
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor, width: _borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: imageContent,
      );
    }
  }

  Widget _applyCellClip(int index, CellRect cell, Widget child) {
    final layout = _layouts[_currentLayoutIndex];
    return ClipPath(
      clipper: CellRectClipper(
        cell: cell,
        cornerRadius: layout.cornerRadius,
      ),
      child: child,
    );
  }

  // ── Grid Clip (2-image split layouts) ────────────────────────────────────
  Widget _applyGridClip(int index, CollageLayoutDef layout, Widget child) {
    final String clipType = layout.clipType ?? 'side';

    CustomClipper<Path>? clipper;
    switch (clipType) {
      case 'side':
        clipper = SideSplitClipper(isLeft: index == 0);
        break;
      case 'top':
        clipper = TopBottomSplitClipper(isTop: index == 0);
        break;
      case 'diagonal':
        clipper = DiagonalSplitClipper(index: index);
        break;
      case 'diagonal_star':
        clipper = DiagonalStarClipper(index: index);
        break;
      case 'reverse_diagonal':
        clipper = ReverseDiagonalSplitClipper(index: index);
        break;
      case 'scurve':
        clipper = SCurveSplitClipper(index: index);
        break;
      case 'heart':
        clipper = HeartSplitClipper(isInside: index == 0);
        break;
      case 'double_heart':
        clipper = DoubleHeartClipper(index: index);
        break;
      case 'heart3':
        clipper = Heart3SplitClipper(index: index);
        break;
      case 'lotus':
        clipper = LotusSplitClipper(index: index);
        break;
      case 'zigzag':
        clipper = ZigzagSplitClipper(index: index);
        break;
      case 'wave':
        clipper = WaveSplitClipper(index: index);
        break;
      case 'vcut':
        clipper = VCutSplitClipper(index: index);
        break;
      case 'circle_inset':
        clipper = CircleInsetClipper(index: index, totalCount: images.length);
        break;
      case 'diamond_inset':
        clipper = DiamondInsetClipper(index: index, totalCount: images.length);
        break;
      case 'triangle_duo':
        clipper = TriangleClipper(index: index, totalCount: 2);
        break;
      case 'trapezoid_duo':
        clipper = TrapezoidClipper(index: index);
        break;
      case 'triangle_trio':
        clipper = TriangleClipper(index: index, totalCount: 3);
        break;
      case 'honeycomb4':
        clipper = HoneycombClipper(index: index);
        break;
      case 'crest5':
        clipper = Crest5Clipper(index: index);
        break;
      case 'geo_crest5':
        clipper = GeoCrest5Clipper(index: index);
        break;
      case 'slanted':
        clipper = SlantedClipper(
          slant: 0.15,
          index: index,
          totalCount: images.length,
        );
        break;
      case 'slanted_rows':
        clipper = SlantedRowClipper(index: index, totalCount: images.length);
        break;
      case 'parallelogram':
        clipper = ParallelogramClipper(
          index: index,
          totalCount: images.length,
          inset: _borderWidth / 2,
        );
        break;
      case 'capsule':
        clipper = CapsuleClipper(index: index, totalCount: images.length);
        break;
      case 'arch':
        clipper = ArchClipper(index: index, totalCount: images.length);
        break;
      case 'blob0':
        clipper = OrganicBlobClipper(
          0,
          index: index,
          totalCount: images.length,
          inset: _borderWidth / 2,
        );
        break;
      case 'blob1':
        clipper = OrganicBlobClipper(
          1,
          index: index,
          totalCount: images.length,
          inset: _borderWidth / 2,
        );
        break;
      case 'hearts_flower':
      case 'hearts_balloon':
      case 'random_hearts':
      case 'leaf_fusion':
      case 'maple_trio':
        clipper = ArtisticNatureClipper(
          mode: clipType,
          index: index,
          totalCount: images.length,
        );
        break;
      case 'stamp_trio':
        clipper = StampTrioClipper(index: index, totalCount: images.length);
        break;

      case 'hexagon_split':
        clipper = HexagonSplitClipper(index: index, totalCount: images.length);
        break;
      case 'floating_cols':
        clipper = FloatingColumnClipper(
          index: index,
          totalCount: images.length,
        );
        break;
      case 'hi_shape':
        clipper = HIClipper(index: index);
        break;
      case 'i_love_u':
        clipper = ILoveUClipper(index: index);
        break;
      case 'film_strip':
        clipper = FilmStripClipper(index: index, totalCount: images.length);
        break;
      case 'torn_paper':
        clipper = TornPaperClipper(index: index);
        break;
      case 'zigzag_band':
        clipper = ZigzagBandClipper(index: index);
        break;

      case 'sandwich':
        clipper = SandwichClipper(index: index);
        break;

      case 'staircase':
        clipper = StaircaseClipper(index: index, totalCount: images.length);
        break;

      case 'shape_grid_4':
        clipper = ArtisticShapeGridClipper(index: index);
        break;
      case 'dad_heart':
        clipper = DadHeartClipper(index: index);
        break;
      case 'torn_diagonal':
        clipper = TornDiagonalClipper(index: index);
        break;
      case 'ghost_air':
        clipper = GhostClipper(index: index);
        break;
      case 'christmas_star':
        clipper = ChristmasStarClipper(index: index);
        break;
      case 'puzzle_trio':
        clipper = PuzzleTrioClipper(index: index);
        break;
      case 'cat_hearts':
        clipper = CatHeartsClipper(index: index);
        break;
      case 'love_story':
        clipper = LoveStoryClipper(index: index);
        break;
      case 'radial_5':
        clipper = Radial5Clipper(index: index);
        break;
      case 'fan_burst_5':
        clipper = FanBurst5Clipper(index: index);
        break;
      case 'star_burst_5':
        clipper = StarBurst5Clipper(index: index);
        break;
      case 'comic_burst_5':
        clipper = ComicBurst5Clipper(index: index);
        break;
      case 'month_january':
      case 'month_february':
      case 'month_march':
      case 'month_april':
      case 'month_may':
      case 'month_june':
      case 'month_july':
      case 'month_august':
      case 'month_september':
      case 'month_october':
      case 'month_november':
      case 'month_december':
        clipper = MonthClipper(index: index);
        break;
      case 'magazine_spread':
        clipper = MagazineSpreadClipper(index: index, inset: _borderWidth / 2);
        break;
      case 'book_3d':
        clipper = Book3DClipper(index: index);
        break;
      case 'prism_3d':
        clipper = PrismClipper(index: index);
        break;
      case 'year_dynamic':
      case 'date_dynamic':
        clipper = DynamicTextClipper(index: index);
        break;
      case 'pinwheel_5':
        clipper = PinwheelClipper(index: index);
        break;
      case 'asymmetric_arch_4':
        clipper = AsymmetricArch4Clipper(index: index);
        break;
      case 'arc_trio':
        clipper = ArcTrio3Clipper(index: index);
        break;
      case 'diamond_grid_4':
        clipper = DiamondGrid4Clipper(index: index);
        break;
      case 'slanted_film_4':
        clipper = SlantedFilmStrip4Clipper(index: index);
        break;
      case 'diagonal_heart':
        clipper = DiagonalHeartClipper(index: index);
        break;
      case 'puzzle_5':
        clipper = Puzzle5Clipper(index: index);
        break;

      case 'year_grid_4':
        clipper = YearGridClipper(
          year: DateTime.now().year.toString(),
          index: index,
        );
        break;
      case 'slanted_gallery_4':
        clipper = SlantedGallery4Clipper(index: index);
        break;

      case 'interlocking_locks_2':
        clipper = InterlockingLocks2Clipper(index: index);
        break;
      case 'slanted_6':
        clipper = SlantedSixClipper(index: index);
        break;
    }

    if (clipper == null) return child;

    return Stack(
      fit: StackFit.expand,
      children: [ClipPath(clipper: clipper, child: child)],
    );
  }

  // Helper widget to avoid naming collision and draw all boundaries
  Widget _buildSplitLine({
    required String clipType,
    required Color lineColor,
    required double lineWidth,
    required int imageCount,
  }) {
    return CustomPaint(
      painter: GlassSplitLinePainter(
        clipType: clipType,
        lineColor: lineColor,
        lineWidth: lineWidth,
        imageCount: imageCount,
      ),
      size: Size.infinite,
    );
  }

  // ── Special Global Overlay ── ─────────────────────────────────────────────

  Widget _buildGlobalSpecialOverlay() {
    final layout = _layouts[_currentLayoutIndex];
    if (!layout.isClipBased && layout.cells != null) {
      final double width = _borderWidth == 0.0 ? 0.0 : _borderWidth.clamp(1.0, 8.0);
      return IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Use a single unified painter to avoid double-borders where cells overlap
            CustomPaint(
              painter: AllCellsBorderPainter(
                cells: layout.cells!,
                color: _borderColor,
                width: width,
                cornerRadius: layout.cornerRadius,
              ),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: CanvasFramePainter(
                color: _borderColor,
                width: width,
              ),
            ),
          ],
        ),
      );
    } else if (layout.isClipBased) {
      if (layout.clipType == 'interlocking_locks_2') {
        return IgnorePointer(
          child: CustomPaint(
            painter: InterlockingLocks2Painter(
              color: _borderColor,
              width: _borderWidth.clamp(1.0, 8.0),
            ),
            size: Size.infinite,
          ),
        );
      }
      return IgnorePointer(
        child: _buildSplitLine(
          clipType: layout.clipType ?? 'side',
          lineColor: _borderColor,
          lineWidth: _borderWidth.clamp(1.0, 8.0),
          imageCount: images.length,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // ────────────────────────────────────────────────────────────────────────
  // TOOLBAR
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildToolbar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _toolBtn(
                    Icons.grid_view_rounded,
                    "Layout",
                    _showLayoutDialog,
                  ),
                  _toolBtn(
                    Icons.palette_rounded,
                    "Canvas",
                    _showBackgroundDialog,
                  ),
                  _toolBtn(
                    Icons.aspect_ratio_rounded,
                    "Ratio",
                    _showRatioDialog,
                  ),
                  _toolBtn(
                    Icons.border_all_rounded,
                    "Border",
                    _showBorderDialog,
                  ),
                  _toolBtn(
                    Icons.text_fields_rounded,
                    "Text",
                    () => _handleTextAction(),
                  ),
                  _toolBtn(Icons.auto_awesome_rounded, "Enhance", () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // DIALOGS  (all glassmorphism)
  // ────────────────────────────────────────────────────────────────────────

  void _showLayoutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DraggableScrollableSheet(
          initialChildSize: 0.52,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scroll) => _glassSheet(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "CHOOSE LAYOUT",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final r = math.Random();
                        _applyLayout(r.nextInt(_layouts.length));
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "SHUFFLE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    controller: scroll,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: _layouts.length,
                    itemBuilder: (_, i) {
                      final selected = _currentLayoutIndex == i;
                      return GestureDetector(
                        onTap: () {
                          _applyLayout(i);
                          Navigator.pop(ctx);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF0072FF).withOpacity(0.25)
                                : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF00C6FF)
                                  : Colors.white12,
                              width: selected ? 1.5 : 1,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00C6FF,
                                      ).withOpacity(0.3),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _layouts[i].icon,
                                size: 28,
                                color: selected
                                    ? const Color(0xFF00C6FF)
                                    : Colors.white38,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _layouts[i].name,
                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 10,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBackgroundDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: _glassSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "CANVAS STYLE",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: appBackgrounds.length,
                  itemBuilder: (_, i) {
                    final bg = appBackgrounds[i];
                    final selected = _activeBackground == bg;
                    return GestureDetector(
                      onTap: () => setState(() => _activeBackground = bg),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        margin: const EdgeInsets.only(right: 14),
                        decoration: bg.decoration.copyWith(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: bg.color1.withOpacity(0.5),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              child: Text(
                                bg.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showBorderDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: _glassSheet(
          child: StatefulBuilder(
            builder: (ctx, setModal) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  "SPLIT LINE STYLE",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      "Thickness",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(ctx).copyWith(
                          activeTrackColor: const Color(0xFF00C6FF),
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.white,
                          overlayColor: const Color(
                            0xFF00C6FF,
                          ).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _borderWidth,
                          min: 0,
                          max: 12,
                          onChanged: (v) {
                            setModal(() => _borderWidth = v);
                            setState(() => _borderWidth = v);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        _borderWidth.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Line Color",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        [
                              Colors.white,
                              Colors.black,
                              const Color(0xFF00C6FF),
                              const Color(0xFFFF6EC7),
                              const Color(0xFFFFD700),
                              const Color(0xFFADFF2F),
                              Colors.transparent,
                            ]
                            .map(
                              (c) => GestureDetector(
                                onTap: () {
                                  setModal(() => _borderColor = c);
                                  setState(() => _borderColor = c);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 42,
                                  height: 42,
                                  margin: const EdgeInsets.only(right: 14),
                                  decoration: BoxDecoration(
                                    color: c == Colors.transparent ? null : c,
                                    gradient: c == Colors.transparent
                                        ? const LinearGradient(
                                            colors: [
                                              Colors.white10,
                                              Colors.white10,
                                            ],
                                          )
                                        : null,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _borderColor == c
                                          ? const Color(0xFF00C6FF)
                                          : Colors.white24,
                                      width: _borderColor == c ? 2.5 : 1,
                                    ),
                                    boxShadow: _borderColor == c
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF00C6FF,
                                              ).withOpacity(0.5),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: c == Colors.transparent
                                      ? const Icon(
                                          Icons.block_rounded,
                                          color: Colors.white38,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatioDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: _glassSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "CANVAS RATIO",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ratioChip("1:1 Square", 1.0, ctx),
                  _ratioChip("4:5 Portrait", 0.8, ctx),
                  _ratioChip("9:16 Stories", 0.5625, ctx),
                  _ratioChip("3:4 Classic", 0.75, ctx),
                  _ratioChip("2:3 Film", 0.6667, ctx),
                  _ratioChip("16:9 Wide", 1.7778, ctx),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratioChip(String label, double ratio, BuildContext ctx) {
    final selected = (_aspectRatio - ratio).abs() < 0.01;
    return GestureDetector(
      onTap: () {
        setState(() => _aspectRatio = ratio);
        Navigator.pop(ctx);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                )
              : null,
          color: selected ? null : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white12,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withOpacity(0.35),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Shared glass sheet wrapper ───────────────────────────────────────────
  Widget _glassSheet({required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: child,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// GlassSplitLinePainter — draws a premium glowing line on the split seam
// ──────────────────────────────────────────────────────────────────────────────
class GlassSplitLinePainter extends CustomPainter {
  final String clipType;
  final Color lineColor;
  final double lineWidth;
  final int imageCount;

  GlassSplitLinePainter({
    required this.clipType,
    required this.lineColor,
    required this.lineWidth,
    this.imageCount = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lineWidth < 0.5) return;

    final paint = Paint()
      ..color = lineColor
          .withOpacity(1.0) // Solid color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width - lineWidth;
    final h = size.height - lineWidth;
    final double offset = lineWidth / 2;

    canvas.save();
    canvas.translate(offset, offset);
    final drawSize = Size(w, h);

    Path path = Path();

    switch (clipType) {
      case 'side':
      case 'top':
      case 'diagonal':
      case 'reverse_diagonal':
      case 'scurve':
        for (int i = 0; i < imageCount; i++) {
          CustomClipper<Path> clipper;
          if (clipType == 'side') {
            clipper = SideSplitClipper(isLeft: i == 0);
          } else if (clipType == 'top') {
            clipper = TopBottomSplitClipper(isTop: i == 0);
          } else if (clipType == 'diagonal') {
            clipper = DiagonalSplitClipper(index: i);
          } else if (clipType == 'reverse_diagonal') {
            clipper = ReverseDiagonalSplitClipper(index: i);
          } else {
            clipper = SCurveSplitClipper(index: i);
          }
          path.addPath(clipper.getClip(drawSize), Offset.zero);
        }
        break;
      case 'heart':
        // Standardized Heart Duo midline - outer border in translated space, heart outline in original size space
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        canvas.drawPath(PerfectHeartClipper().getClip(size), paint);
        canvas.restore();
        break;
      case 'double_heart':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        double s = size.width * 0.55;
        double cy = (size.height * 0.5) - (s * 0.4);

        Path leftHeart = _getHeartShape(size.width * 0.30, cy, s);
        Path rightHeart = _getHeartShape(size.width * 0.70, cy, s);

        // Calculate a 2.5% lateral gap for a uniform cutout
        double gap = size.width * 0.025;
        final Matrix4 matrix = Matrix4.identity()..translate(-gap, 0.0);

        Path rightHeartExpanded = rightHeart.transform(matrix.storage);
        Path cutLeftHeart = Path.combine(
          PathOperation.difference,
          leftHeart,
          rightHeartExpanded,
        );

        canvas.drawPath(cutLeftHeart, paint);
        canvas.drawPath(rightHeart, paint);
        canvas.restore();
        break;
      case 'heart3':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        final heartPath = PerfectHeartClipper().getClip(size);

        // Clip the horizontal line so it only draws outside the heart shape
        canvas.save();
        canvas.clipPath(
          Path.combine(
            PathOperation.difference,
            Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
            heartPath,
          ),
        );
        canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), paint);
        canvas.restore();

        // Draw the heart shape boundary
        canvas.drawPath(heartPath, paint);
        canvas.restore();
        break;
      case 'diagonal_heart':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        final heartPath = PerfectHeartClipper().getClip(size);

        // Clip the diagonal line so it doesn't cross the heart
        canvas.save();
        canvas.clipPath(
          Path.combine(
            PathOperation.difference,
            Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
            heartPath,
          ),
        );
        canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
        canvas.restore();

        // Draw the heart shape boundary
        canvas.drawPath(heartPath, paint);
        canvas.restore();
        break;
      case 'lotus':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        canvas.drawPath(LotusSplitClipper.getLotusPath(size.width, size.height, 0), paint);
        canvas.drawPath(LotusSplitClipper.getLotusPath(size.width, size.height, 1), paint);
        canvas.drawPath(LotusSplitClipper.getLotusPath(size.width, size.height, 2), paint);
        canvas.restore();
        break;
      case 'zigzag':
      case 'wave':
      case 'vcut':
        for (int i = 0; i < imageCount; i++) {
          CustomClipper<Path> clipper;
          if (clipType == 'zigzag') {
            clipper = ZigzagSplitClipper(index: i);
          } else if (clipType == 'wave') {
            clipper = WaveSplitClipper(index: i);
          } else {
            clipper = VCutSplitClipper(index: i);
          }
          path.addPath(clipper.getClip(drawSize), Offset.zero);
        }
        break;
      case 'parallelogram':
      case 'slanted':
      case 'capsule':
      case 'arch':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        for (int i = 0; i < imageCount; i++) {
          CustomClipper<Path>? tempClipper;
          if (clipType == 'slanted') {
            tempClipper = SlantedClipper(
              slant: 0.15,
              index: i,
              totalCount: imageCount,
            );
          } else if (clipType == 'parallelogram') {
            tempClipper = ParallelogramClipper(
              index: i,
              totalCount: imageCount,
              inset: lineWidth / 2,
            );
          } else if (clipType == 'capsule') {
            tempClipper = CapsuleClipper(index: i, totalCount: imageCount);
          } else if (clipType == 'arch') {
            tempClipper = ArchClipper(index: i, totalCount: imageCount);
          }
          if (tempClipper != null) {
            canvas.drawPath(tempClipper.getClip(size), paint);
          }
        }
        canvas.restore();
        break;
      case 'blob0':
      case 'blob1':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        for (int i = 0; i < imageCount; i++) {
          CustomClipper<Path>? tempClipper;
          if (clipType == 'blob0') {
            tempClipper = OrganicBlobClipper(
              0,
              index: i,
              totalCount: imageCount,
              inset: 0.0,
            );
          } else if (clipType == 'blob1') {
            tempClipper = OrganicBlobClipper(
              1,
              index: i,
              totalCount: imageCount,
              inset: 0.0,
            );
          }
          if (tempClipper != null) {
            canvas.drawPath(tempClipper.getClip(size), paint);
          }
        }
        canvas.restore();
        break;
      case 'magazine_spread':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        for (int i = 0; i < imageCount; i++) {
          final tempClipper = MagazineSpreadClipper(
            index: i,
            inset: lineWidth / 2,
          );
          canvas.drawPath(tempClipper.getClip(size), paint);
        }
        canvas.restore();

        // --- HIGH-FIDELITY MAG OVERLAYS ---
        // 1. Glossy Spread Shadow
        final shadowRect = Rect.fromLTWH(w * 0.5 - w * 0.08, 0, w * 0.16, h);
        final shadowPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(shadowRect.left, 0),
            Offset(shadowRect.right, 0),
            [
              Colors.black.withOpacity(0.0),
              Colors.black.withOpacity(0.45),
              Colors.black.withOpacity(0.0),
            ],
            [0.0, 0.5, 1.0],
          );
        canvas.drawRect(shadowRect, shadowPaint);

        // Bright Center Highlight
        canvas.drawLine(
          Offset(w * 0.5, 0),
          Offset(w * 0.5, h),
          Paint()
            ..color = Colors.white.withOpacity(0.2)
            ..strokeWidth = 1,
        );

        // 2. Bold V O G U E style Masthead & Background Plate
        final bgPaint = Paint()
          ..color = const Color(0xFFE63946); // Striking Magazine Red
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.12),
            width: w * 0.65,
            height: h * 0.15,
          ),
          bgPaint,
        );

        final TextPainter titlePainter = TextPainter(
          text: TextSpan(
            text: 'V O G U E',
            style: TextStyle(
              color: Colors.white,
              fontSize: w * 0.14,
              fontWeight: FontWeight.w900,
              letterSpacing: w * 0.02,
              fontFamily: 'serif',
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        titlePainter.layout();
        titlePainter.paint(
          canvas,
          Offset(
            (w - titlePainter.width) / 2,
            h * 0.12 - titlePainter.height / 2,
          ),
        );

        // 3. Ultra-realistic Barcode + Price
        double bx = w * 0.78;
        double by = h * 0.86;
        canvas.drawRect(
          Rect.fromLTWH(bx - 10, by - 15, w * 0.20, h * 0.12),
          Paint()..color = Colors.white,
        );

        final TextPainter pricePainter = TextPainter(
          text: const TextSpan(
            text: '\$6.99 \nUSA',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              height: 1.1,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        pricePainter.layout();
        pricePainter.paint(
          canvas,
          Offset(bx + w * 0.16 - pricePainter.width, by - 12),
        );

        final List<double> barWidths = [
          3,
          1,
          4,
          1.5,
          2,
          5,
          1,
          3,
          2,
          1,
          4,
          3,
          1,
          1,
          4,
        ];
        final barcodePaint = Paint()..color = Colors.black;
        double currentX = bx;
        for (double bw in barWidths) {
          canvas.drawRect(
            Rect.fromLTWH(currentX, by, bw, h * 0.06),
            barcodePaint,
          );
          currentX += bw + 1.5;
        }

        // 4. Stylish Vertical Margin Text
        canvas.save();
        canvas.translate(w * 0.05, h * 0.85);
        canvas.rotate(-math.pi / 2);
        final TextPainter marginPainter = TextPainter(
          text: TextSpan(
            text: 'COLLECTION 2026 // EDITION 04',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: w * 0.035,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        marginPainter.layout();
        marginPainter.paint(canvas, Offset(0, 0));
        canvas.restore();
        break;
      case 'circle_inset':
        double r = w * 0.30;
        double cx = w * 0.5;
        double cy = h * 0.5;
        // Outer frame for consistency on all sides
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        // Inner circle
        path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
        if (imageCount == 5) {
          // Cross dividers
          path.moveTo(0, cy);
          path.lineTo(cx - r, cy);
          path.moveTo(cx + r, cy);
          path.lineTo(w, cy);
          path.moveTo(cx, 0);
          path.lineTo(cx, cy - r);
          path.moveTo(cx, cy + r);
          path.lineTo(cx, h);
        }
        break;
      case 'diamond_inset':
        double cx = w * 0.5;
        double cy = h * 0.5;
        // Outer frame for consistency on all sides
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        // Inner diamond
        path.moveTo(cx, h * 0.2);
        path.lineTo(w * 0.8, cy);
        path.lineTo(cx, h * 0.8);
        path.lineTo(w * 0.2, cy);
        path.close();
        if (imageCount == 5) {
          // Diagonal corner lines
          path.moveTo(0, 0);
          path.lineTo(cx, h * 0.2);
          path.moveTo(w, 0);
          path.lineTo(cx, h * 0.2);
          path.moveTo(w, h);
          path.lineTo(cx, h * 0.8);
          path.moveTo(0, h);
          path.lineTo(cx, h * 0.8);
        }
        break;
      case 'triangle_duo':
        // Draw outer border and inner split lines
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h);
        path.moveTo(w * 0.5, 0);
        path.lineTo(0, h);
        break;
      case 'triangle_trio':
        // Ensure a solid outer canvas border
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        // Draw internal dividers precisely using clippers
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
            TriangleClipper(index: i, totalCount: imageCount).getClip(drawSize),
            Offset.zero,
          );
        }
        break;
      case 'trapezoid_duo':
        // Draw outer border and the mirrored 'Pinch' split line
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        path.moveTo(0, 0);
        path.lineTo(w * 0.5, h * 0.15);
        path.lineTo(w * 0.5, h * 0.85);
        path.lineTo(0, h);
        break;

      case 'stamp_trio':
        for (int i = 0; i < imageCount; i++) {
          double s = w * 0.42;
          double imgS = s * 0.82;
          Offset center;
          if (i == 0)
            center = Offset(w * 0.28, h * 0.3);
          else if (i == 1)
            center = Offset(w * 0.72, h * 0.3);
          else
            center = Offset(w * 0.5, h * 0.74);

          final stampRect = Rect.fromCenter(
            center: center,
            width: s,
            height: s,
          );
          final imgRect = Rect.fromCenter(
            center: center,
            width: imgS,
            height: imgS,
          );
          final imgPath = Path()
            ..addRRect(
              RRect.fromRectAndRadius(imgRect, Radius.circular(imgS * 0.12)),
            );
          final stampPath = StampTrioClipper.getStampPath(stampRect);

          // Draw filled white stamp background with hole for image
          final framePath = Path.combine(
            PathOperation.difference,
            stampPath,
            imgPath,
          );
          canvas.drawPath(
            framePath,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
          );

          // Add outlines to the main path for glowing borders
          path.addPath(stampPath, Offset.zero);
          path.addPath(imgPath, Offset.zero);
        }
        break;
      case 'hi_shape':
        double barW = w * 0.24;
        double midW = w * 0.05;
        double gap = w * 0.05;
        double ch = h * 0.65;
        double totalW = (barW * 3) + midW + gap;
        double startX = (w - totalW) / 2;
        double startY = (h - ch) / 2;
        double radius = w * 0.03;

        // H Left vertical
        final p1 = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(startX, startY, barW, ch),
              Radius.circular(radius),
            ),
          );
        // H Right vertical
        final p2 = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(startX + barW + midW, startY, barW, ch),
              Radius.circular(radius),
            ),
          );
        // H Middle bar
        double midH = w * 0.12;
        final p3 = Path()
          ..addRect(
            Rect.fromLTWH(
              startX + (barW * 0.5),
              startY + (ch - midH) / 2,
              barW + midW,
              midH,
            ),
          );

        final hPath = Path.combine(
          PathOperation.union,
          p1,
          Path.combine(PathOperation.union, p2, p3),
        );
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        path.addPath(hPath, Offset.zero);

        // I bar
        double iStartX = startX + barW * 2 + midW + gap;
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(iStartX, startY, barW, ch),
            Radius.circular(radius),
          ),
        );
        break;

      case 'hexagon_split':
        path.addPath(HexagonSplitClipper.getHexagonPath(drawSize), Offset.zero);
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
            HexagonSplitClipper(
              index: i,
              totalCount: imageCount,
            ).getClip(drawSize),
            Offset.zero,
          );
        }
        break;
      case 'floating_cols':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
            FloatingColumnClipper(
              index: i,
              totalCount: imageCount,
            ).getClip(drawSize),
            Offset.zero,
          );
        }
        break;
      case 'i_love_u':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(ILoveUClipper.getILoveUPath(i, size), Offset.zero);
        }
        break;

      case 'torn_paper':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
            TornPaperClipper(index: i).getClip(drawSize),
            Offset.zero,
          );
        }
        break;
      case 'zigzag_band':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
            ZigzagBandClipper(index: i).getClip(drawSize),
            Offset.zero,
          );
        }
        break;

      case 'shape_grid_4':
        final sgPaint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        for (int i = 0; i < imageCount; i++) {
          canvas.drawPath(
            ArtisticShapeGridClipper.getShapePath(i, size),
            sgPaint,
          );
        }
        break;
      case 'torn_diagonal':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
            TornDiagonalClipper(index: i).getClip(drawSize),
            Offset.zero,
          );
        }
        break;
      case 'ghost_air':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        GhostAirPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'christmas_star':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        ChristmasStarPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'pinwheel_5':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        PinwheelPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'slanted_film_4':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        SlantedFilmStrip4Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'puzzle_trio':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        PuzzleTrioPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'puzzle_5':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        Puzzle5Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'cat_hearts':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        CatHeartsPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'love_story':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        LoveStoryPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'asymmetric_arch_4':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        AsymmetricArch4Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'arc_trio':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        ArcTrio3Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'diamond_grid_4':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        DiamondGrid4Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'diagonal_star':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        DiagonalStarPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'honeycomb4':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        HoneycombPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'sandwich':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        for (int i = 0; i < imageCount; i++) {
          canvas.drawPath(
            SandwichClipper(index: i).getClip(size),
            paint,
          );
        }
        SandwichPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;

      case 'staircase':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
            StaircaseClipper(
              index: i,
              totalCount: imageCount,
            ).getClip(drawSize),
            Offset.zero,
          );
        }
        break;

      case 'dad_heart':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        for (int i = 0; i < imageCount; i++) {
          final isHeart = (i == 1);
          final dhPaint = Paint()
            ..color = isHeart ? const Color(0xFF00C6FF) : lineColor
            ..strokeWidth = isHeart ? lineWidth * 1.5 : lineWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;

          canvas.drawPath(
            DadHeartClipper.getDadHeartPath(i, size),
            dhPaint,
          );
        }
        canvas.restore();
        break;
      case 'year_grid_4':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        YearGridPainter(
          year: DateTime.now().year.toString(),
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'slanted_gallery_4':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        SlantedGallery4Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;

      case 'interlocking_locks_2':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        InterlockingLocks2Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'slanted_6':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        SlantedSixPainter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        canvas.restore();
        break;
      case 'slanted_rows':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        SlantedRowPainter(
          color: lineColor,
          width: lineWidth,
          totalCount: imageCount,
        ).paint(canvas, size);
        canvas.restore();
        break;

      case 'hearts_flower':
      case 'random_hearts':
      case 'leaf_fusion':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        for (int i = 0; i < imageCount; i++) {
          canvas.drawPath(
            _getArtisticPath(clipType, i, imageCount, size.width, size.height),
            paint,
          );
        }
        canvas.restore();
        break;
      case 'hearts_balloon':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        canvas.save();
        canvas.translate(-offset, -offset);
        for (int i = 0; i < imageCount; i++) {
          canvas.drawPath(
            _getArtisticPath(clipType, i, imageCount, size.width, size.height),
            paint,
          );
        }
        // Draw the hanging strings converging at a single knot
        final stringPaint = Paint()
          ..color = lineColor.withOpacity(0.55)
          ..strokeWidth = math.max(1.5, lineWidth * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final knotX = size.width * 0.5;
        final knotY = size.height * 0.96; // Clustered knot point (holding position)

        for (int i = 0; i < imageCount; i++) {
          final params = ArtisticNatureClipper.getBalloonParams(
            i,
            imageCount,
            size.width,
            size.height,
          );
          double px = params['x']!,
              py = params['y']!,
              s = params['size']!,
              rot = params['rotation']!;

          // Tip of the heart (bottom point)
          double tipX = px - s * 0.95 * math.sin(rot);
          double tipY = py + s * 0.95 * math.cos(rot);

          final StringPath = Path();
          StringPath.moveTo(tipX, tipY);

          // Curve strings elegantly outward so they drape around lower balloons
          double ctrlX;
          if (px < size.width * 0.45) {
            ctrlX = math.min(tipX, knotX) - size.width * 0.15;
          } else if (px > size.width * 0.55) {
            ctrlX = math.max(tipX, knotX) + size.width * 0.15;
          } else {
            // For the central top balloon, let the string drop straight down
            ctrlX = (tipX + knotX) / 2;
          }
          double ctrlY = (tipY + knotY) / 2 + size.height * 0.1;

          StringPath.quadraticBezierTo(ctrlX, ctrlY, knotX, knotY);
          canvas.drawPath(StringPath, stringPaint);
        }

        // Draw a small knot circle at the base
        canvas.drawCircle(
          Offset(knotX, knotY),
          4,
          Paint()..color = lineColor.withOpacity(0.8),
        );
        canvas.restore();
        break;
      case 'radial_5':
        path.addPath(Radial5Clipper.getRadial5Path(0, size), Offset.zero);
        for (int i = 1; i < 5; i++) {
          path.addPath(Radial5Clipper.getRadial5Path(i, size), Offset.zero);
        }
        break;
      case 'fan_burst_5':
        final double cx = w * 0.5;
        final double cy = h * 0.5;
        final double innerR = w * 0.015;
        final double outerR = math.sqrt(w * w + h * h) * 1.1;
        for (int i = 0; i < 5; i++) {
          double angle = (360.0 / 5) * i - 90.0;
          FanBurst5Clipper.addJaggedRadialLine(
            path,
            cx,
            cy,
            innerR,
            outerR,
            angle,
          );
        }
        break;
      case 'star_burst_5':
        StarBurst5Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        break;
      case 'crest5':
        Crest5Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'geo_crest5':
        GeoCrest5Painter(
          color: lineColor,
          width: lineWidth,
        ).paint(canvas, size);
        break;

      case 'comic_burst_5':
        // Professional Comic Red with bold thickness
        final comicBorderPaint = Paint()
          ..color =
              lineColor // Restored dynamic color support
          ..strokeWidth = lineWidth * 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        comicBorderPaint.style = PaintingStyle.stroke;

        // Draw individual borders for all 5 shapes (4 quadrants + 1 burst)
        // This ensures every edge has a border and they stack correctly at seams.
        for (int i = 0; i < 5; i++) {
          canvas.drawPath(
            ComicBurst5Clipper.getComicBurst5Path(i, size),
            comicBorderPaint,
          );
        }
        break;
      case 'month_january':
      case 'month_february':
      case 'month_march':
      case 'month_april':
      case 'month_may':
      case 'month_june':
      case 'month_july':
      case 'month_august':
      case 'month_september':
      case 'month_october':
      case 'month_november':
      case 'month_december':
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        final monthsMap = {
          'january': 'January',
          'february': 'February',
          'march': 'March',
          'april': 'April',
          'may': 'May',
          'june': 'June',
          'july': 'July',
          'august': 'August',
          'september': 'September',
          'october': 'October',
          'november': 'November',
          'december': 'December',
        };
        final rawKey = clipType.split('_').last.toLowerCase().trim();
        final monthName =
            monthsMap[rawKey] ??
            (rawKey.isNotEmpty
                ? rawKey[0].toUpperCase() + rawKey.substring(1)
                : '');
        final centerLineY = h / 2;

        // 1. Draw a clean white split line
        final splitPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = (lineWidth * 0.5).clamp(2.0, 4.0)
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(0, centerLineY),
          Offset(w, centerLineY),
          splitPaint,
        );

        // 2. Render the Month Name in the beautiful script font (as preferred)
        final textPainter = TextPainter(
          text: TextSpan(
            text: monthName,
            style: GoogleFonts.greatVibes(
              color: Colors.white,
              fontSize: w * 0.22,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();

        // Vertical offset adjustment: 'J' in GreatVibes has a large descender
        // We nudge it slightly to look more balanced like the other months.
        double verticalNudge = monthName.startsWith('J')
            ? -textPainter.height * 0.05
            : 0;

        // Center the text vertically and horizontally over the split
        textPainter.paint(
          canvas,
          Offset(
            (w - textPainter.width) / 2,
            centerLineY - textPainter.height / 2.2 + verticalNudge,
          ),
        );
        break;

      case 'year_dynamic':
      case 'date_dynamic':
        final now = DateTime.now();

        // Determine text for the diagonal seam label (large, centered)
        final dynamicText = clipType == 'year_dynamic'
            ? now.year.toString()
            : now.day.toString().padLeft(2, '0');

        // ── 1. Outer canvas border frame ─────────────────────────────────
        final framePaint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth.clamp(1.5, 6.0)
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.miter;

        // Outer rect inset by half the stroke so it doesn't get clipped
        final frameInset = lineWidth.clamp(1.5, 6.0) / 2;
        canvas.drawRect(
          Rect.fromLTWH(
            frameInset,
            frameInset,
            w - frameInset * 2,
            h - frameInset * 2,
          ),
          framePaint,
        );

        // Inner border line (thinner, at a small gap)
        final innerGap = lineWidth.clamp(1.5, 6.0) * 3.5;
        final innerPaint = Paint()
          ..color = lineColor.withOpacity(0.45)
          ..strokeWidth = lineWidth.clamp(0.8, 2.5) * 0.6
          ..style = PaintingStyle.stroke;
        canvas.drawRect(
          Rect.fromLTWH(innerGap, innerGap, w - innerGap * 2, h - innerGap * 2),
          innerPaint,
        );

        // ── 2. Corner diamond ornaments ───────────────────────────────────
        final List<Offset> corners = [
          Offset(frameInset, frameInset),
          Offset(w - frameInset, frameInset),
          Offset(w - frameInset, h - frameInset),
          Offset(frameInset, h - frameInset),
        ];
        final double dSize = lineWidth.clamp(1.5, 6.0) * 2.2;
        final cornerDiamondPaint = Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill;
        for (final corner in corners) {
          final diamondPath = Path()
            ..moveTo(corner.dx, corner.dy - dSize)
            ..lineTo(corner.dx + dSize, corner.dy)
            ..lineTo(corner.dx, corner.dy + dSize)
            ..lineTo(corner.dx - dSize, corner.dy)
            ..close();
          canvas.drawPath(diamondPath, cornerDiamondPaint);
        }

        // ── 3. Border text around the perimeter ──────────────────────────
        final String topBottomLabel;
        final String sideLabel;

        if (clipType == 'year_dynamic') {
          topBottomLabel = '✦  ${now.year}  ✦';
          sideLabel = now.year.toString();
        } else {
          // date_dynamic: full date on top/bottom, compact on sides
          const months = [
            'JAN',
            'FEB',
            'MAR',
            'APR',
            'MAY',
            'JUN',
            'JUL',
            'AUG',
            'SEP',
            'OCT',
            'NOV',
            'DEC',
          ];
          topBottomLabel =
              '${now.day.toString().padLeft(2, '0')}  ·  ${months[now.month - 1]}  ·  ${now.year}';
          sideLabel = '${now.day.toString().padLeft(2, '0')} · ${now.year}';
        }

        final double borderFontSize = lineWidth.clamp(1.5, 6.0) * 3.0;
        final borderTextStyle = GoogleFonts.montserrat(
          color: lineColor,
          fontSize: borderFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        );

        // Helper to paint border text at a position and rotation
        void paintBorderText(
          String text,
          Offset position,
          double rotation,
          TextAlign align,
        ) {
          final tp = TextPainter(
            text: TextSpan(text: text, style: borderTextStyle),
            textDirection: ui.TextDirection.ltr,
            textAlign: align,
          );
          tp.layout();
          canvas.save();
          canvas.translate(position.dx, position.dy);
          canvas.rotate(rotation);
          tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
          canvas.restore();
        }

        // Top edge — centered horizontally, just inside the inner border
        paintBorderText(
          topBottomLabel,
          Offset(w / 2, innerGap / 2 + borderFontSize * 0.3),
          0,
          TextAlign.center,
        );

        // Bottom edge
        paintBorderText(
          topBottomLabel,
          Offset(w / 2, h - innerGap / 2 - borderFontSize * 0.3),
          0,
          TextAlign.center,
        );

        // Left edge (rotated 90°)
        paintBorderText(
          sideLabel,
          Offset(innerGap / 2 + borderFontSize * 0.3, h / 2),
          -math.pi / 2,
          TextAlign.center,
        );

        // Right edge (rotated -90°)
        paintBorderText(
          sideLabel,
          Offset(w - innerGap / 2 - borderFontSize * 0.3, h / 2),
          math.pi / 2,
          TextAlign.center,
        );

        // ── 4. Draw the curved diagonal split seam ────────────────────────
        final dynSplitPaint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth.clamp(3.0, 6.0)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(
          DynamicTextClipper.getDynamicTextSplitPath(drawSize),
          dynSplitPaint,
        );

        // ── 5. Render the large year/date label centered on the split seam ─
        final dynTextPainter = TextPainter(
          text: TextSpan(
            text: dynamicText,
            style: GoogleFonts.greatVibes(
              color: lineColor,
              fontSize: w * 0.38,
              height: 1.0,
              shadows: [
                Shadow(
                  blurRadius: 15,
                  color: Colors.black.withOpacity(0.45),
                  offset: const Offset(4, 4),
                ),
              ],
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        dynTextPainter.layout();
        dynTextPainter.paint(
          canvas,
          Offset(
            (w - dynTextPainter.width) / 2,
            (h - dynTextPainter.height) / 2.3,
          ),
        );
        break;
      case 'book_3d':
        // Draw the main page outlines
        path.addPath(Book3DClipper.getPath(0, drawSize), Offset.zero);
        path.addPath(Book3DClipper.getPath(1, drawSize), Offset.zero);

        // Add elegant Spiral Binder rings along the spine
        final ringPaint = Paint()
          ..color = lineColor.withOpacity(0.6)
          ..strokeWidth = lineWidth * 0.6
          ..style = PaintingStyle.stroke;

        final double spineStart = h * 0.18;
        final double spineEnd = h * 0.82;
        final int ringCount = 10;
        for (int i = 0; i < ringCount; i++) {
          final double ry =
              spineStart + (spineEnd - spineStart) * (i / (ringCount - 1));
          // Draw a small "C" shape clasping the pages
          final ringRect = Rect.fromCenter(
            center: Offset(w * 0.5, ry),
            width: w * 0.05,
            height: h * 0.025,
          );
          canvas.drawArc(ringRect, 1.5, 3.2, false, ringPaint);

          // Add a tiny shadow dot for the punch hole
          canvas.drawCircle(
            Offset(w * 0.485, ry),
            lineWidth * 0.4,
            Paint()..color = Colors.black.withOpacity(0.3),
          );
          canvas.drawCircle(
            Offset(w * 0.515, ry),
            lineWidth * 0.4,
            Paint()..color = Colors.black.withOpacity(0.3),
          );
        }

        // Add Luxury Corner Rivets
        final rivetPaint = Paint()..color = lineColor.withOpacity(0.8);
        final double rd = w * 0.008; // small diameter
        canvas.drawCircle(Offset(w * 0.05, h * 0.08), rd, rivetPaint);
        canvas.drawCircle(Offset(w * 0.05, h * 0.92), rd, rivetPaint);
        canvas.drawCircle(Offset(w * 0.95, h * 0.08), rd, rivetPaint);
        canvas.drawCircle(Offset(w * 0.95, h * 0.92), rd, rivetPaint);
        break;
      case 'prism_3d':
        // 1. Draw solid "Caps" to complete the 3D box shape
        final capPaint = Paint()
          ..color = Colors.black.withOpacity(0.12)
          ..style = PaintingStyle.fill;

        final topCap = Path();
        topCap.moveTo(0, 0);
        topCap.lineTo(w, 0);
        topCap.lineTo(w * 0.65, h * 0.08);
        topCap.close();
        canvas.drawPath(topCap, capPaint);

        final bottomCap = Path();
        bottomCap.moveTo(0, h);
        bottomCap.lineTo(w * 0.65, h * 0.92);
        bottomCap.lineTo(w, h);
        bottomCap.close();
        canvas.drawPath(bottomCap, capPaint);

        // 2. Add subtle shadow to the receding (right) facet to enhance depth
        final sideShadowPaint = Paint()..color = Colors.black.withOpacity(0.06);
        canvas.drawPath(PrismClipper.getPath(1, drawSize), sideShadowPaint);

        // 3. Draw the faceted outlines with the "Side Angle" perspective
        path.addPath(PrismClipper.getPath(0, drawSize), Offset.zero);
        path.addPath(PrismClipper.getPath(1, drawSize), Offset.zero);

        // 4. Highlight the asymmetric central "ridge" line
        final ridgePaint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth * 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(w * 0.65, h * 0.08),
          Offset(w * 0.65, h * 0.92),
          ridgePaint,
        );
        break;

      case 'film_strip':
        // 1. Draw the Cinematic Negative Strip background with frame "holes"
        Path stripPath = Path()..addRect(Rect.fromLTWH(0, 0, w, h));
        Path framesPath = Path();
        for (int i = 0; i < imageCount; i++) {
          Path frame = FilmStripClipper.getFilmStripPath(
            i,
            drawSize,
            imageCount,
          );
          framesPath.addPath(frame, Offset.zero);
          // Add box outline to the cumulative path for consistent border rendering
          path.addPath(frame, Offset.zero);
        }

        // Use a consistent dark cinematic background
        final stripPaint = Paint()
          ..color = const Color(0xFF141414)
          ..style = PaintingStyle.fill;
        // Subtract frames from the background so images behind are visible
        canvas.drawPath(
          Path.combine(PathOperation.difference, stripPath, framesPath),
          stripPaint,
        );

        // 2. Draw high-fidelity sprocket holes (Rounded Rects)
        final sprocketPaint = Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.fill;
        double sprocketW = w * 0.045;
        double sprocketH = h * 0.025;
        double cRadius = 2.0;

        // Dynamic sprocket count based on total height and image count
        int sprocketCount = (12 * imageCount).clamp(12, 40);
        double stepY = h / (sprocketCount + 1);

        for (int i = 1; i <= sprocketCount; i++) {
          double yPos = (i * stepY) - (sprocketH / 2);
          // Left Column
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * 0.05, yPos, sprocketW, sprocketH),
              Radius.circular(cRadius),
            ),
            sprocketPaint,
          );
          // Right Column
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * 0.905, yPos, sprocketW, sprocketH),
              Radius.circular(cRadius),
            ),
            sprocketPaint,
          );
        }

        // 3. Draw frame borders for all images (Standardized to match other collages)
        final frameBorderPaint = Paint()
          ..color =
              lineColor // Full opacity matching other collages
          ..strokeWidth =
              lineWidth // Standard width matching other collages
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        for (int i = 0; i < imageCount; i++) {
          canvas.drawPath(
            FilmStripClipper.getFilmStripPath(i, drawSize, imageCount),
            frameBorderPaint,
          );
        }

        // 4. Add Professional Cinematic Branding
        final textPainter = TextPainter(textDirection: TextDirection.ltr);

        void drawBrandText(
          String text,
          Offset offset,
          double fontSize, {
          double opacity = 0.8,
          double rotation = 0,
        }) {
          textPainter.text = TextSpan(
            text: text,
            style: TextStyle(
              color: lineColor.withOpacity(opacity),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: 'Courier',
            ),
          );
          textPainter.layout();
          if (rotation != 0) {
            canvas.save();
            canvas.translate(offset.dx, offset.dy);
            canvas.rotate(rotation);
            textPainter.paint(canvas, Offset.zero);
            canvas.restore();
          } else {
            textPainter.paint(canvas, offset);
          }
        }

        // Header Labels (Slightly adjusted for better 3-image clearance)
        drawBrandText("KODAK 400", Offset(w * 0.15, h * 0.025), 11);
        drawBrandText("SAFETY FILM", Offset(w * 0.58, h * 0.025), 11);

        // Sidebar Frame Numbers (Adaptive positioning based on frame density)
        for (int i = 0; i < imageCount; i++) {
          // Find approximately the middle-left of each frame
          double topPadding = h * 0.08;
          double availableH = h * 0.84;
          double frameMidY = topPadding + (availableH / imageCount) * (i + 0.5);
          drawBrandText(
            "${24 + i}",
            Offset(w * 0.04, frameMidY),
            9,
            rotation: -math.pi / 2,
          );
        }
        break;
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Path _getArtisticPath(
    String mode,
    int index,
    int totalCount,
    double w,
    double h,
  ) {
    if (mode == 'hearts_flower') {
      final double cx = w * 0.5;
      final double cy = h * 0.5;

      final double angleStep = 2 * math.pi / totalCount;
      final double theta = -math.pi / 2 + (angleStep * index);

      double s;
      double R;
      if (totalCount == 2) {
        s = w * 0.40;
        R = s * 0.85;
      } else if (totalCount == 3) {
        s = w * 0.38;
        R = s * 0.88;
      } else if (totalCount == 4) {
        s = w * 0.34;
        R = s * 0.95;
      } else if (totalCount == 5) {
        s = w * 0.30;
        R = s * 1.02;
      } else {
        s = w * 0.26;
        R = s * 1.10;
      }

      final double px = cx + R * math.cos(theta);
      final double py = cy + R * math.sin(theta);

      return _getHeartShape(px, py, s, rotation: theta + math.pi / 2);
    } else if (mode == 'leaf_fusion') {
      final params = ArtisticNatureClipper.getLeafParams(
        index,
        totalCount,
        w,
        h,
      );
      return _getLeafShape(
        params['x']!,
        params['y']!,
        params['size']!,
        rotation: params['rotation']!,
        index: index,
        totalCount: totalCount,
      );
    } else if (mode == 'hearts_balloon') {
      final params = ArtisticNatureClipper.getBalloonParams(
        index,
        totalCount,
        w,
        h,
      );
      return _getHeartShape(
        params['x']!,
        params['y']!,
        params['size']!,
        rotation: params['rotation']!,
      );
    } else {
      final params = ArtisticNatureClipper.getHeartParams(
        index,
        totalCount,
        w,
        h,
      );
      return _getHeartShape(
        params['x']!,
        params['y']!,
        params['size']!,
        rotation: params['rotation']!,
      );
    }
  }

  Path _getLeafShape(
    double x,
    double y,
    double size, {
    double rotation = 0,
    int index = -1,
    int totalCount = -1,
  }) {
    final path = Path();
    double s = size;

    if (totalCount == 2) {
      // MODERN FLUID FUSION (Redesign) - Synchronized
      final double topY = y - s * 0.45;
      final double botY = y + s * 0.45;

      path.moveTo(x, topY);
      if (index == 0) {
        // Left Outer Boundary
        path.cubicTo(
          x - s * 0.65,
          y - s * 0.45,
          x - s * 0.65,
          y + s * 0.45,
          x,
          botY,
        );
        // S-Curve Divider back to top
        path.cubicTo(
          x - s * 0.15,
          y + s * 0.15,
          x + s * 0.15,
          y - s * 0.15,
          x,
          topY,
        );
      } else {
        // Right Outer Boundary
        path.cubicTo(
          x + s * 0.65,
          y - s * 0.45,
          x + s * 0.65,
          y + s * 0.45,
          x,
          botY,
        );
        // S-Curve Divider back to top
        path.cubicTo(
          x - s * 0.15,
          y + s * 0.15,
          x + s * 0.15,
          y - s * 0.15,
          x,
          topY,
        );
      }
      path.close();
    } else {
      path.moveTo(x, y);
      path.cubicTo(
        x - s * 0.45,
        y + s * 0.2,
        x - s * 0.35,
        y + s * 0.8,
        x,
        y + s,
      );
      path.cubicTo(x + s * 0.35, y + s * 0.8, x + s * 0.45, y + s * 0.2, x, y);
      path.close();
    }

    if (rotation != 0) {
      final matrix = Matrix4.identity()
        ..translate(x, y)
        ..rotateZ(rotation)
        ..translate(-x, -y);
      return path.transform(matrix.storage);
    }
    return path;
  }

  Path _getHeartShape(double x, double y, double size, {double rotation = 0}) {
    final path = Path();
    double s = size;
    // Standardized perfect heart
    path.moveTo(x, y + s * 0.2);
    path.cubicTo(
      x,
      y - s * 0.15,
      x + s * 0.5,
      y - s * 0.15,
      x + s * 0.5,
      y + s * 0.3,
    );
    path.cubicTo(x + s * 0.5, y + s * 0.55, x, y + s * 0.75, x, y + s * 0.95);
    path.cubicTo(
      x,
      y + s * 0.75,
      x - s * 0.5,
      y + s * 0.55,
      x - s * 0.5,
      y + s * 0.3,
    );
    path.cubicTo(x - s * 0.5, y - s * 0.15, x, y - s * 0.15, x, y + s * 0.2);
    path.close();
    if (rotation != 0) {
      final matrix = Matrix4.identity()
        ..translate(x, y)
        ..rotateZ(rotation)
        ..translate(-x, -y);
      return path.transform(matrix.storage);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant GlassSplitLinePainter oldDelegate) =>
      oldDelegate.clipType != clipType ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.lineWidth != lineWidth;
}

// ──────────────────────────────────────────────────────────────────────────────
// CellRectClipper — cuts an image to fit a normalized grid cell
// ──────────────────────────────────────────────────────────────────────────────
class CellRectClipper extends CustomClipper<Path> {
  final CellRect cell;
  final double cornerRadius;
  CellRectClipper({required this.cell, this.cornerRadius = 0.0});

  @override
  Path getClip(Size size) {
    final rect = Rect.fromLTWH(
      size.width * cell.left,
      size.height * cell.top,
      size.width * cell.width,
      size.height * cell.height,
    );
    if (cornerRadius > 0) {
      return Path()..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
      );
    }
    return Path()..addRect(rect);
  }

  @override
  bool shouldReclip(CellRectClipper oldClipper) =>
      oldClipper.cell != cell || oldClipper.cornerRadius != cornerRadius;
}

// ──────────────────────────────────────────────────────────────────────────────
// AllCellsBorderPainter — draws borders for ALL cells in a single paint pass.
// This prevents double-border artifacts where cells overlap each other
// (e.g. the Pinterest Grid center overlay cell sitting on top of the 4 corner cells).
// ──────────────────────────────────────────────────────────────────────────────
class AllCellsBorderPainter extends CustomPainter {
  final List<CellRect> cells;
  final Color color;
  final double width;
  final double cornerRadius;

  AllCellsBorderPainter({
    required this.cells,
    required this.color,
    required this.width,
    this.cornerRadius = 0.0,
  });

  // Compute a Rect from a CellRect + canvas size
  Rect _toRect(CellRect cell, Size size) => Rect.fromLTWH(
        size.width * cell.left,
        size.height * cell.top,
        size.width * cell.width,
        size.height * cell.height,
      );

  // Build the path for a cell rect (rounded or plain)
  Path _cellPath(Rect rect) {
    if (cornerRadius > 0) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)));
    }
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;

    // Detect overlapping cells: any cell whose rect intersects another
    // We draw each cell's border clipped to exclude regions covered by
    // later (higher-index) cells, then draw the later cell's border on top.
    // This prevents double-width strokes at intersection edges.
    final List<Rect> rects = cells.map((c) => _toRect(c, size)).toList();

    for (int i = 0; i < cells.length; i++) {
      final Rect myRect = rects[i];

      // Collect all higher-index cells that overlap this cell
      Path? coverPath;
      for (int j = i + 1; j < cells.length; j++) {
        if (myRect.overlaps(rects[j])) {
          final overlap = myRect.intersect(rects[j]);
          // Expand the cover by half the stroke width so the shared edge
          // of the background cell is fully hidden under the overlay border
          final expandedOverlap = overlap.inflate(width * 0.5);
          final overlapPath = _cellPath(expandedOverlap);
          coverPath = coverPath == null
              ? overlapPath
              : Path.combine(PathOperation.union, coverPath, overlapPath);
        }
      }

      if (coverPath != null) {
        // Draw this cell's border clipped to exclude covered areas
        final fullBorderPath = _cellPath(myRect);
        canvas.save();
        // Create an inverse clip: paint everywhere EXCEPT the covered region
        final clipPath = Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          coverPath,
        );
        canvas.clipPath(clipPath);
        canvas.drawPath(fullBorderPath, paint);
        canvas.restore();
      } else {
        // No overlap — draw border normally
        canvas.drawPath(_cellPath(myRect), paint);
      }
    }
  }

  @override
  bool shouldRepaint(AllCellsBorderPainter old) =>
      old.cells != cells ||
      old.color != color ||
      old.width != width ||
      old.cornerRadius != cornerRadius;
}

// CellBorderPainter — draws the border for a single cell (kept for compatibility)
// ──────────────────────────────────────────────────────────────────────────────
class CellBorderPainter extends CustomPainter {
  final CellRect cell;
  final Color color;
  final double width;
  final double cornerRadius;

  CellBorderPainter({
    required this.cell,
    required this.color,
    required this.width,
    this.cornerRadius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      size.width * cell.left,
      size.height * cell.top,
      size.width * cell.width,
      size.height * cell.height,
    );
    if (cornerRadius > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
        paint,
      );
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CellBorderPainter old) =>
      old.cell != cell ||
      old.color != color ||
      old.width != width ||
      old.cornerRadius != cornerRadius;
}

// ──────────────────────────────────────────────────────────────────────────────
// CanvasFramePainter — draws the outer border of the entire canvas
// ──────────────────────────────────────────────────────────────────────────────
class CanvasFramePainter extends CustomPainter {
  final Color color;
  final double width;

  CanvasFramePainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (width < 0.5) return;
    // We draw the frame INSET by half the width so it perfectly aligns with
    // the inner borders of individual cells (which are clipped by the container edge).
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      width / 2,
      width / 2,
      size.width - width,
      size.height - width,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CanvasFramePainter old) =>
      old.color != color || old.width != width;
}
