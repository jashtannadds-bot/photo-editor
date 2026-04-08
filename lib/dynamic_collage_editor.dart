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
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: CellRectClipper(
            cell: cell,
            cornerRadius: layout.cornerRadius,
          ),
          child: child,
        ),
        // Layered border that respects stacking (essential for Pinterest-style overlaps)
        IgnorePointer(
          child: CustomPaint(
            painter: CellBorderPainter(
              cell: cell,
              color: _borderColor,
              width: _borderWidth.clamp(1.0, 8.0),
              cornerRadius: layout.cornerRadius,
            ),
            size: Size.infinite,
          ),
        ),
      ],
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
        clipper = SlantedClipper(slant: 0.15, index: index, totalCount: images.length);
        break;
      case 'slanted_rows':
        clipper = SlantedRowClipper(index: index, totalCount: images.length);
        break;
      case 'parallelogram':
        clipper = ParallelogramClipper(index: index, totalCount: images.length);
        break;
      case 'capsule':
        clipper = CapsuleClipper(index: index, totalCount: images.length);
        break;
      case 'arch':
        clipper = ArchClipper(index: index, totalCount: images.length);
        break;
      case 'blob0':
        clipper = OrganicBlobClipper(0, index: index, totalCount: images.length, inset: _borderWidth / 2);
        break;
      case 'blob1':
        clipper = OrganicBlobClipper(1, index: index, totalCount: images.length, inset: _borderWidth / 2);
        break;
      case 'hearts_flower':
      case 'hearts_balloon':
      case 'random_hearts':
      case 'leaf_fusion':
      case 'maple_trio':
        clipper = ArtisticNatureClipper(mode: clipType, index: index, totalCount: images.length);
        break;
      case 'stamp_trio':
        clipper = StampTrioClipper(index: index, totalCount: images.length);
        break;

      case 'hexagon_split':
        clipper = HexagonSplitClipper(index: index, totalCount: images.length);
        break;
      case 'floating_cols':
        clipper = FloatingColumnClipper(index: index, totalCount: images.length);
        break;
      case 'hi_shape':
        clipper = HIClipper(index: index);
        break;
      case 'i_love_u':
        clipper = ILoveUClipper(index: index);
        break;
      case 'film_strip':
        clipper = FilmStripClipper(index: index);
        break;
      case 'torn_paper':
        clipper = TornPaperClipper(index: index);
        break;
      case 'zigzag_band':
        clipper = ZigzagBandClipper(index: index);
        break;
      case 'spiky_zigzag':
        clipper = SpikyZigzagClipper(index: index);
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
        clipper = YearGridClipper(year: DateTime.now().year.toString(), index: index);
        break;
      case 'slanted_gallery_4':
        clipper = SlantedGallery4Clipper(index: index);
        break;
      case 'artistic_hands_2':
        clipper = ArtisticHands2Clipper(index: index);
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
      children: [
        ClipPath(clipper: clipper, child: child),
        // Glass split line overlay (only rendered by index==0 to draw all boundaries)
        if (index == 0)
          IgnorePointer(
            child: _buildSplitLine(
              clipType: clipType,
              lineColor: _borderColor,
              lineWidth: _borderWidth.clamp(1.0, 8.0),
              imageCount: images.length,
            ),
          ),
      ],
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
      return IgnorePointer(
        child: CustomPaint(
          painter: CanvasFramePainter(
            color: _borderColor,
            width: _borderWidth.clamp(1.0, 8.0),
          ),
        ),
      );
    } else if (layout.isClipBased) {
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
      ..color = lineColor.withOpacity(1.0) // Solid color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    Path path = Path();

    switch (clipType) {
      case 'side':
        path.moveTo(w / 2, 0);
        path.lineTo(w / 2, h);
        break;
      case 'top':
        path.moveTo(0, h / 2);
        path.lineTo(w, h / 2);
        break;
      case 'diagonal':
        // Matches DiagonalSplitClipper: (w,0) to (0,h)
        path.moveTo(w, 0);
        path.lineTo(0, h);
        break;
      case 'reverse_diagonal':
        // Matches ReverseDiagonalSplitClipper: (0,0) to (w,h)
        path.moveTo(0, 0);
        path.lineTo(w, h);
        break;
      case 'scurve':
        // Standardized S-Curve divider
        path.moveTo(w, h * 0.3);
        path.quadraticBezierTo(w * 0.75, h * 0.5, w * 0.5, h * 0.3);
        path.quadraticBezierTo(w * 0.25, h * 0.1, 0, h * 0.3);
        break;
      case 'heart':
        // Standardized Heart Duo midline
        path.addPath(_getHeartShape(w * 0.5, h * 0.4, w * 0.75), Offset.zero);
        break;
      case 'double_heart':
        double s = w * 0.55;
        double cy = (h * 0.5) - (s * 0.4);
        
        // We draw the right heart first or the left heart? 
        // Order doesn't matter for Stroke. We draw both to get the outlines.
        // However, we only want the left heart where it's not cut by the expanded right heart.
        // Since this is a glowing stroke effect, drawing both creates the borders. 
        // We can just add both heart shapes, or use the clipped shape for the left.
        Path leftHeart = _getHeartShape(w * 0.30, cy, s);
        Path rightHeart = _getHeartShape(w * 0.70, cy, s);
        
        // Calculate a 2.5% lateral gap for a uniform cutout
        double gap = w * 0.025;
        final Matrix4 matrix = Matrix4.identity()
          ..translate(-gap, 0.0);
          
        Path rightHeartExpanded = rightHeart.transform(matrix.storage);
        Path cutLeftHeart = Path.combine(PathOperation.difference, leftHeart, rightHeartExpanded);
        
        path.addPath(cutLeftHeart, Offset.zero);
        path.addPath(rightHeart, Offset.zero);
        break;
      case 'heart3':
        path.moveTo(0, h * 0.5);
        path.lineTo(w, h * 0.5);
        path.addPath(_getHeartShape(w * 0.5, h * 0.4, w * 0.75), Offset.zero);
        break;
      case 'diagonal_heart':
        // Centered heart shape path
        Path heartPath = _getHeartShape(w * 0.5, h * 0.4, w * 0.75);
        
        // Clip the diagonal line so it doesn't cross the heart
        canvas.save();
        canvas.clipPath(Path.combine(
          PathOperation.difference,
          Path()..addRect(Rect.fromLTWH(0, 0, w, h)),
          heartPath,
        ));
        canvas.drawLine(Offset(w, 0), Offset(0, h), paint);
        canvas.restore();
        
        // Draw the heart shape boundary
        path.addPath(heartPath, Offset.zero);
        break;
      case 'lotus':
        path.addPath(LotusSplitClipper.getLotusPath(w, h, 0), Offset.zero);
        path.addPath(LotusSplitClipper.getLotusPath(w, h, 1), Offset.zero);
        path.addPath(LotusSplitClipper.getLotusPath(w, h, 2), Offset.zero);
        break;
      case 'zigzag':
        int zigs = 6;
        double stepY = h / zigs;
        for (int i = 0; i <= zigs; i++) {
          double xBase = w * 0.5;
          double xOffset = i % 2 == 0 ? w * 0.1 : -w * 0.1;
          if (i == 0)
            path.moveTo(xBase + xOffset, i * stepY);
          else
            path.lineTo(xBase + xOffset, i * stepY);
        }
        break;
      case 'wave':
        double midY = h * 0.5;
        // Matches WaveSplitClipper divider
        path.moveTo(w, midY);
        path.cubicTo(w * 0.75, midY + h * 0.15, w * 0.25, midY - h * 0.15, 0, midY);
        break;
      case 'vcut':
        path.moveTo(0, h * 0.3);
        path.lineTo(w * 0.5, h * 0.65);
        path.lineTo(w, h * 0.3);
        break;
      case 'slanted':
      case 'parallelogram':
      case 'capsule':
      case 'arch':
        for (int i = 0; i < imageCount; i++) {
          CustomClipper<Path>? tempClipper;
          if (clipType == 'slanted') {
            tempClipper = SlantedClipper(slant: 0.15, index: i, totalCount: imageCount);
          } else if (clipType == 'parallelogram') {
            tempClipper = ParallelogramClipper(index: i, totalCount: imageCount);
          } else if (clipType == 'capsule') {
            tempClipper = CapsuleClipper(index: i, totalCount: imageCount);
          } else if (clipType == 'arch') {
            tempClipper = ArchClipper(index: i, totalCount: imageCount);
          }
          if (tempClipper != null) {
            canvas.drawPath(tempClipper.getClip(size), paint);
          }
        }
        break;
      case 'blob0':
      case 'blob1':
        for (int i = 0; i < imageCount; i++) {
          CustomClipper<Path>? tempClipper;
          if (clipType == 'blob0') {
            tempClipper = OrganicBlobClipper(0, index: i, totalCount: imageCount, inset: 0.0);
          } else if (clipType == 'blob1') {
            tempClipper = OrganicBlobClipper(1, index: i, totalCount: imageCount, inset: 0.0);
          }
          if (tempClipper != null) {
            canvas.drawPath(tempClipper.getClip(size), paint);
          }
        }
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
          path.moveTo(0, cy); path.lineTo(cx - r, cy);
          path.moveTo(cx + r, cy); path.lineTo(w, cy);
          path.moveTo(cx, 0); path.lineTo(cx, cy - r);
          path.moveTo(cx, cy + r); path.lineTo(cx, h);
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
          path.moveTo(0, 0); path.lineTo(cx, h * 0.2);
          path.moveTo(w, 0); path.lineTo(cx, h * 0.2);
          path.moveTo(w, h); path.lineTo(cx, h * 0.8);
          path.moveTo(0, h); path.lineTo(cx, h * 0.8);
        }
        break;
      case 'triangle_duo':
        // Only draw inner split lines
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h);
        path.moveTo(w * 0.5, 0);
        path.lineTo(0, h);
        break;
      case 'triangle_trio':
        // Main diagonal split
        path.moveTo(0, 0);
        path.lineTo(w, h);
        // Sub split for the bottom-left half
        path.moveTo(0, h);
        path.lineTo(w * 0.5, h * 0.5);
        break;
      case 'trapezoid_duo':
        // Only draw inner split lines
        path.moveTo(0, 0);
        path.lineTo(w * 0.2, h * 0.5);
        path.lineTo(w * 0.8, h * 0.5);
        path.lineTo(w, 0);
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

          final stampRect = Rect.fromCenter(center: center, width: s, height: s);
          final imgRect =
              Rect.fromCenter(center: center, width: imgS, height: imgS);
          final imgPath = Path()
            ..addRRect(RRect.fromRectAndRadius(
                imgRect, Radius.circular(imgS * 0.12)));
          final stampPath = StampTrioClipper.getStampPath(stampRect);

          // Draw filled white stamp background with hole for image
          final framePath =
              Path.combine(PathOperation.difference, stampPath, imgPath);
          canvas.drawPath(
              framePath, Paint()..color = Colors.white..style = PaintingStyle.fill);

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
        final p1 = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(startX, startY, barW, ch), Radius.circular(radius)));
        // H Right vertical
        final p2 = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(startX + barW + midW, startY, barW, ch), Radius.circular(radius)));
        // H Middle bar
        double midH = w * 0.12;
        final p3 = Path()..addRect(Rect.fromLTWH(startX + (barW * 0.5), startY + (ch - midH) / 2, barW + midW, midH));
        
        final hPath = Path.combine(PathOperation.union, p1, Path.combine(PathOperation.union, p2, p3));
        path.addPath(hPath, Offset.zero);

        // I bar
        double iStartX = startX + barW * 2 + midW + gap;
        path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(iStartX, startY, barW, ch), Radius.circular(radius)));
        break;

      case 'hexagon_split':
        path.addPath(HexagonSplitClipper.getHexagonPath(size), Offset.zero);
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
              HexagonSplitClipper(index: i, totalCount: imageCount)
                  .getClip(size),
              Offset.zero);
        }
        break;
      case 'floating_cols':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
              FloatingColumnClipper(index: i, totalCount: imageCount)
                  .getClip(size),
              Offset.zero);
        }
        break;
      case 'i_love_u':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(ILoveUClipper.getILoveUPath(i, size), Offset.zero);
        }
        break;
      case 'film_strip':
        for (int i = 0; i < imageCount; i++) {
          final double w = size.width;
          final double h = size.height;
          double frameW = w * 0.88;
          double frameH = h * 0.28;
          double cx = w * 0.5;
          double cy;
          double angle;

          if (i == 0) {
            cy = h * 0.18;
            angle = 0.06;
          } else if (i == 1) {
            cy = h * 0.5;
            angle = -0.06;
          } else {
            cy = h * 0.82;
            angle = 0.06;
          }

          // Frame geometry
          final matrix = Matrix4.identity()
            ..translate(cx, cy)
            ..rotateZ(angle);

          double imgW = frameW * 0.8;
          double imgH = frameH * 0.9;
          Rect imgRect =
              Rect.fromCenter(center: Offset.zero, width: imgW, height: imgH);

          // Draw Black Frame
          Rect frameRect =
              Rect.fromCenter(center: Offset.zero, width: frameW, height: frameH);
          Path framePath = Path()..addRect(frameRect);
          Path windowPath = Path()..addRect(imgRect);
          Path cutoutFrame = Path.combine(PathOperation.difference, framePath, windowPath);

          Path transformedFrame = cutoutFrame.transform(matrix.storage);
          canvas.drawPath(transformedFrame, Paint()..color = Colors.black);

          // Draw White Perforations (Holes)
          double perfW = frameW * 0.04;
          double perfH = frameH * 0.06;
          double perfSpacing = frameH * 0.12;
          double perfPaddingH = frameW * 0.05;

          Paint perfPaint = Paint()..color = Colors.white;

          // Left side perfs
          for (double py = -frameH * 0.42; py < frameH * 0.45; py += perfSpacing) {
            Rect perfRect = Rect.fromCenter(
                center: Offset(-frameW * 0.5 + perfPaddingH, py),
                width: perfW,
                height: perfH);
            Path p = Path()..addRRect(RRect.fromRectAndRadius(perfRect, const Radius.circular(1)));
            canvas.drawPath(p.transform(matrix.storage), perfPaint);
          }
          // Right side perfs
          for (double py = -frameH * 0.42; py < frameH * 0.45; py += perfSpacing) {
            Rect perfRect = Rect.fromCenter(
                center: Offset(frameW * 0.5 - perfPaddingH, py),
                width: perfW,
                height: perfH);
            Path p = Path()..addRRect(RRect.fromRectAndRadius(perfRect, const Radius.circular(1)));
            canvas.drawPath(p.transform(matrix.storage), perfPaint);
          }

          // Draw image border (white thin line)
          Path imgPath = Path()..addRect(imgRect);
          canvas.drawPath(
              imgPath.transform(matrix.storage),
              Paint()
                ..color = Colors.white.withOpacity(0.3)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0);
        }
        break;
      case 'torn_paper':
        final borderPaint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        for (int i = 0; i < imageCount; i++) {
          final sectionPath = TornPaperClipper.getTornPath(i, size);
          canvas.drawPath(sectionPath, borderPaint);
        }
        break;
      case 'zigzag_band':
        // Draw the two seam zigzag lines (top divider + bottom divider)
        final zzPaint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter;
        // The seam paths are the outlines of the middle band (index=1),
        // which gives us both dividers in one path.
        canvas.drawPath(
          ZigzagBandClipper.getZigzagBandPath(1, size),
          zzPaint,
        );
        break;
      case 'spiky_zigzag':
        final szPaint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter;
        canvas.drawPath(
          SpikyZigzagClipper.getSpikyZigzagBandPath(1, size),
          szPaint,
        );
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
        const double inset = 5.0;
        final borderPaintTorn = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        
        final outerPath = Path()..addRect(
          Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
        );
        final stripPath = TornDiagonalClipper(index: 1).getClip(size);
        
        // Combine them into a single path to avoid double-drawing the vertical segments
        final combinedPath = Path.combine(PathOperation.union, outerPath, stripPath);
        canvas.drawPath(combinedPath, borderPaintTorn);
        break;
      case 'ghost_air':
        GhostAirPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'christmas_star':
        ChristmasStarPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'pinwheel_5':
        PinwheelPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'slanted_film_4':
        SlantedFilmStrip4Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'puzzle_trio':
        PuzzleTrioPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'puzzle_5':
        Puzzle5Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'cat_hearts':
        CatHeartsPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'love_story':
        LoveStoryPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'asymmetric_arch_4':
        AsymmetricArch4Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'arc_trio':
        ArcTrio3Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'diamond_grid_4':
        DiamondGrid4Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'diagonal_star':
        DiagonalStarPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'honeycomb4':
        HoneycombPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'dad_heart':
        // Draw the 5 shapes (Rect, Heart, D, A, D) outlines
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
        break;
      case 'year_grid_4':
        YearGridPainter(year: DateTime.now().year.toString(), color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'slanted_gallery_4':
        SlantedGallery4Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'artistic_hands_2':
        ArtisticHands2Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'interlocking_locks_2':
        InterlockingLocks2Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'slanted_6':
        SlantedSixPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'slanted_rows':
        SlantedRowPainter(color: lineColor, width: lineWidth, totalCount: imageCount).paint(canvas, size);
        break;

      case 'hearts_flower':
      case 'random_hearts':
      case 'leaf_fusion':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(_getArtisticPath(clipType, i, imageCount, w, h), Offset.zero);
        }
        break;
      case 'hearts_balloon':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(_getArtisticPath(clipType, i, imageCount, w, h), Offset.zero);
        }
        // Draw the hanging strings converging at a single knot
        final stringPaint = Paint()
          ..color = lineColor.withOpacity(0.55)
          ..strokeWidth = math.max(1.5, lineWidth * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        
        final knotX = w * 0.5;
        final knotY = h * 0.96; // Clustered knot point (holding position)
        
        for (int i = 0; i < imageCount; i++) {
          final params = ArtisticNatureClipper.getBalloonParams(i, imageCount, w, h);
          double px = params['x']!, py = params['y']!, s = params['size']!, rot = params['rotation']!;
          
          // Tip of the heart (bottom point)
          double tipX = px - s * 0.95 * math.sin(rot);
          double tipY = py + s * 0.95 * math.cos(rot);
          
          final StringPath = Path();
          StringPath.moveTo(tipX, tipY);
          // Artistic curved string leading to the knot
          double ctrlX = (tipX + knotX) / 2 + (i % 2 == 0 ? 20 : -20);
          double ctrlY = (tipY + knotY) / 2 - 10;
          StringPath.quadraticBezierTo(ctrlX, ctrlY, knotX, knotY);
          canvas.drawPath(StringPath, stringPaint);
        }
        
        // Draw a small knot circle at the base
        canvas.drawCircle(Offset(knotX, knotY), 4, Paint()..color = lineColor.withOpacity(0.8));
        break;
      case 'radial_5':
        path.addPath(Radial5Clipper.getRadial5Path(0, size), Offset.zero);
        for (int i = 1; i < 5; i++) {
          path.addPath(Radial5Clipper.getRadial5Path(i, size), Offset.zero);
        }
        break;
      case 'fan_burst_5':
        for (int i = 0; i < 5; i++) {
          canvas.drawPath(FanBurst5Clipper.getFanBurst5Path(i, size), paint);
        }
        break;
      case 'star_burst_5':
        StarBurst5Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'crest5':
        Crest5Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'geo_crest5':
        GeoCrest5Painter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;

      case 'comic_burst_5':
        // Professional Comic Red with bold thickness
        final comicBorderPaint = Paint()
          ..color = lineColor // Restored dynamic color support
          ..strokeWidth = lineWidth * 2.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        comicBorderPaint.style = PaintingStyle.stroke;

        // Draw individual borders for all 5 shapes (4 quadrants + 1 burst)
        // This ensures every edge has a border and they stack correctly at seams.
        for (int i = 0; i < 5; i++) {
          canvas.drawPath(
              ComicBurst5Clipper.getComicBurst5Path(i, size), comicBorderPaint);
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
        final monthsMap = {
          'january': 'January', 'february': 'February', 'march': 'March',
          'april': 'April', 'may': 'May', 'june': 'June',
          'july': 'July', 'august': 'August', 'september': 'September',
          'october': 'October', 'november': 'November', 'december': 'December',
        };
        final rawKey = clipType.split('_').last.toLowerCase().trim();
        final monthName = monthsMap[rawKey] ?? (rawKey.isNotEmpty ? rawKey[0].toUpperCase() + rawKey.substring(1) : '');
        final centerLineY = h / 2;
        
        // 1. Draw a clean white split line
        final splitPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = (lineWidth * 0.5).clamp(2.0, 4.0)
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(0, centerLineY), Offset(w, centerLineY), splitPaint);

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
        double verticalNudge = monthName.startsWith('J') ? -textPainter.height * 0.05 : 0;

        // Center the text vertically and horizontally over the split
        textPainter.paint(
          canvas, 
          Offset((w - textPainter.width) / 2, centerLineY - textPainter.height / 2.2 + verticalNudge)
        );
        break;

      case 'year_dynamic':
      case 'date_dynamic':
        final now = DateTime.now();
        final dynamicText = clipType == 'year_dynamic'
            ? now.year.toString()
            : now.day.toString().padLeft(2, '0');

        // 1. Draw the curved diagonal split line (matching reference image)
        final dynSplitPaint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth.clamp(3.0, 6.0)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(DynamicTextClipper.getDynamicTextSplitPath(size), dynSplitPaint);

        // 2. Render the year/date number in large Great Vibes script
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
          Offset((w - dynTextPainter.width) / 2, (h - dynTextPainter.height) / 2.3),
        );
        break;
    }

    canvas.drawPath(path, paint);
  }

  Path _getArtisticPath(String mode, int index, int totalCount, double w, double h) {
    if (mode == 'hearts_flower') {
      if (totalCount == 5) {
        final double s = w * 0.32; 
        final double R = s * 1.05;
        final double cx = w * 0.5;
        final double cy = h * 0.5;
        final double theta = -math.pi / 2 + (2 * math.pi / 5) * index;
        final double px = cx + R * math.cos(theta);
        final double py = cy + R * math.sin(theta);
        return _getHeartShape(px, py, s, rotation: theta + math.pi / 2);
      } else {
        final double s = w * 0.45;
        final double cx = w * 0.5;
        final double cy = h * 0.5;
        if (index == 0) {
          return _getHeartShape(cx - s * 0.55, cy - s * 0.45, s);
        } else {
          return _getHeartShape(cx + s * 0.55, cy - s * 0.45, s);
        }
      }
    } else if (mode == 'hearts_balloon') {
      if (totalCount == 5) {
        final double s = w * 0.30;
        final List<List<double>> pos = [
          [w * 0.50, h * 0.05],
          [w * 0.20, h * 0.30],
          [w * 0.80, h * 0.30],
          [w * 0.35, h * 0.65],
          [w * 0.65, h * 0.65],
        ];
        final int i = index.clamp(0, pos.length - 1);
        final double px = pos[i][0];
        final double py = pos[i][1];
        final double rot = math.atan2(h * 1.05 - py, w * 0.5 - px) - math.pi / 2;
        return _getHeartShape(px, py, s, rotation: rot);
      } else {
        double bx = (w / (totalCount + 1)) * (index + 1);
        double by = h * 0.4 + (index % 2 == 0 ? -h * 0.18 : h * 0.12);
        return _getHeartShape(bx, by, w * 0.45);
      }
    } else if (mode == 'leaf_fusion') {
      double centerX = w * 0.5, centerY = h * 0.5;
      double radius = w * 0.32;
      double angle = (2 * math.pi / totalCount) * index;
      double lx = centerX + radius * math.cos(angle);
      double ly = centerY + radius * math.sin(angle);
      return _getLeafShape(lx, ly, radius * 1.5, rotation: angle + math.pi / 2);
    } else if (mode == 'hearts_balloon') {
      final params = ArtisticNatureClipper.getBalloonParams(index, totalCount, w, h);
      return _getHeartShape(
        params['x']!,
        params['y']!,
        params['size']!,
        rotation: params['rotation']!,
      );
    } else {
      final params = ArtisticNatureClipper.getHeartParams(index, totalCount, w, h);
      return _getHeartShape(
        params['x']!,
        params['y']!,
        params['size']!,
        rotation: params['rotation']!,
      );
    }
  }

  Path _getLeafShape(double x, double y, double size, {double rotation = 0}) {
    final path = Path();
    double s = size;
    path.moveTo(x, y);
    path.quadraticBezierTo(x - s * 0.4, y + s * 0.3, x, y + s * 0.8);
    path.quadraticBezierTo(x + s * 0.4, y + s * 0.3, x, y);
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

  Path _getHeartShape(double x, double y, double size, {double rotation = 0}) {
    final path = Path();
    double s = size;
    // Standardized perfect heart
    path.moveTo(x, y + s * 0.2);
    path.cubicTo(x, y - s * 0.15, x + s * 0.5, y - s * 0.15, x + s * 0.5, y + s * 0.3);
    path.cubicTo(x + s * 0.5, y + s * 0.55, x, y + s * 0.75, x, y + s * 0.95);
    path.cubicTo(x, y + s * 0.75, x - s * 0.5, y + s * 0.55, x - s * 0.5, y + s * 0.3);
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
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)));
    }
    return Path()..addRect(rect);
  }

  @override
  bool shouldReclip(CellRectClipper oldClipper) =>
      oldClipper.cell != cell || oldClipper.cornerRadius != cornerRadius;
}

// ──────────────────────────────────────────────────────────────────────────────
// CellBorderPainter — draws the border for a single cell
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

  CanvasFramePainter({
    required this.color,
    required this.width,
  });

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
      size.height - width
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CanvasFramePainter old) =>
      old.color != color || old.width != width;
}
