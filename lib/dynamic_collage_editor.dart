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
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: CellRectClipper(cell: cell),
          child: child,
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
        clipper = CircleInsetClipper(isInside: index == 0);
        break;
      case 'diamond_inset':
        clipper = DiamondInsetClipper(isInside: index == 0);
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
        clipper = HoneycombClipper();
        break;
      case 'crest5':
        clipper = HoneycombClipper(); // Use honeycomb as a base for crest
        break;
      case 'slanted':
        clipper = SlantedClipper(slant: 0.15, index: index);
        break;
      case 'parallelogram':
        clipper = ParallelogramClipper(index: index);
        break;
      case 'capsule':
        clipper = CapsuleClipper(index: index, totalCount: images.length);
        break;
      case 'arch':
        clipper = ArchClipper(index: index, totalCount: images.length);
        break;
      case 'blob0':
        clipper = OrganicBlobClipper(0, index: index, totalCount: images.length);
        break;
      case 'blob1':
        clipper = OrganicBlobClipper(1, index: index, totalCount: images.length);
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
      case 'slanted_rows':
        clipper = SlantedRowClipper(index: index, totalCount: images.length);
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
      case 'comic_burst_5':
        clipper = ComicBurst5Clipper(index: index);
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
          painter: GridLinesPainter(
            cells: layout.cells!,
            lineColor: _borderColor,
            lineWidth: _borderWidth.clamp(1.0, 8.0),
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
        double s = 0.2 * w;
        path.moveTo(s, 0);
        path.lineTo(w - s, h);
        break;
      case 'parallelogram':
        double s = 0.2 * w;
        path.moveTo(s, 0);
        path.lineTo(0, h);
        path.moveTo(w, 0);
        path.lineTo(w - s, h);
        break;
      case 'circle_inset':
        path.addOval(
          Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.35),
        );
        break;
      case 'diamond_inset':
        path.moveTo(w * 0.5, h * 0.2);
        path.lineTo(w * 0.85, h * 0.5);
        path.lineTo(w * 0.5, h * 0.8);
        path.lineTo(w * 0.15, h * 0.5);
        path.close();
        break;
      case 'triangle_duo':
        // Only draw inner split lines
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h);
        path.moveTo(w * 0.5, 0);
        path.lineTo(0, h);
        break;
      case 'triangle_trio':
        for (int i = 0; i < imageCount; i++) {
          path.moveTo(w * 0.5, 0);
          path.lineTo(w, h);
          path.lineTo(0, h);
          path.close();
        }
        break;
      case 'trapezoid_duo':
        // Only draw inner split lines
        path.moveTo(0, 0);
        path.lineTo(w * 0.2, h * 0.5);
        path.lineTo(w * 0.8, h * 0.5);
        path.lineTo(w, 0);
        break;
      case 'capsule':
        for (int i = 0; i < imageCount; i++) {
          double unitH = h / (imageCount > 0 ? imageCount : 1);
          double top = i * unitH + (unitH * 0.1);
          double capsuleH = unitH * 0.8;
          path.addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.1, top, w * 0.8, capsuleH),
            Radius.circular(capsuleH / 2),
          ));
        }
        break;
      case 'arch':
        for (int i = 0; i < imageCount; i++) {
          double unitW = w / (imageCount > 0 ? imageCount : 1);
          double left = i * unitW + (unitW * 0.05);
          double archW = unitW * 0.9;
          double archH = h * 0.7;
          double archTop = h * 0.15;
          path.moveTo(left, archTop + archH);
          path.lineTo(left, archTop + archW * 0.5);
          path.arcToPoint(Offset(left + archW, archTop + archW * 0.5), radius: Radius.circular(archW * 0.5), clockwise: true);
          path.lineTo(left + archW, archTop + archH);
          path.close();
        }
        break;
      case 'honeycomb4':
      case 'crest5':
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h * 0.25);
        path.lineTo(w, h * 0.75);
        path.lineTo(w * 0.5, h);
        path.lineTo(0, h * 0.75);
        path.lineTo(0, h * 0.25);
        path.close();
        break;
      case 'blob0':
      case 'blob1':
        for (int i = 0; i < imageCount; i++) {
          double scale = 1.0 / (imageCount > 1 ? 1.5 : 1.0);
          double effectiveW = w * scale;
          double effectiveH = h * scale;
          double xOffset = 0, yOffset = 0;
          if (imageCount > 1) {
            int cols = (imageCount > 2) ? 2 : 1;
            xOffset = (i % cols) * (w / cols) * 0.5;
            yOffset = (i ~/ cols) * (h / ((imageCount+1)~/2)) * 0.5;
          }
          if (clipType == 'blob0') {
            path.moveTo(xOffset + effectiveW * 0.2, yOffset + effectiveH * 0.1);
            path.quadraticBezierTo(xOffset + effectiveW * 0.8, yOffset, xOffset + effectiveW * 0.9, yOffset + effectiveH * 0.3);
            path.quadraticBezierTo(xOffset + effectiveW, yOffset + effectiveH * 0.7, xOffset + effectiveW * 0.7, yOffset + effectiveH * 0.9);
            path.quadraticBezierTo(xOffset + effectiveW * 0.3, yOffset + effectiveH, xOffset + effectiveW * 0.1, yOffset + effectiveH * 0.7);
            path.quadraticBezierTo(xOffset, yOffset + effectiveH * 0.3, xOffset + effectiveW * 0.2, yOffset + effectiveH * 0.1);
          } else {
            path.moveTo(xOffset + effectiveW * 0.1, yOffset + effectiveH * 0.4);
            path.quadraticBezierTo(xOffset + effectiveW * 0.2, yOffset, xOffset + effectiveW * 0.6, yOffset + effectiveH * 0.1);
            path.quadraticBezierTo(xOffset + effectiveW, yOffset + effectiveH * 0.2, xOffset + effectiveW * 0.9, yOffset + effectiveH * 0.6);
            path.quadraticBezierTo(xOffset + effectiveW * 0.8, yOffset + effectiveH, xOffset + effectiveW * 0.4, yOffset + effectiveH * 0.9);
            path.quadraticBezierTo(xOffset, yOffset + effectiveH * 0.8, xOffset + effectiveW * 0.1, yOffset + effectiveH * 0.4);
          }
          path.close();
        }
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
      case 'slanted_rows':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(
              SlantedRowClipper(index: i, totalCount: imageCount).getClip(size),
              Offset.zero);
        }
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

          // Draw Black Frame
          Rect frameRect =
              Rect.fromCenter(center: Offset.zero, width: frameW, height: frameH);
          Path framePath = Path()..addRect(frameRect);
          Path transformedFrame = framePath.transform(matrix.storage);
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
          double imgW = frameW * 0.8;
          double imgH = frameH * 0.9;
          Rect imgRect =
              Rect.fromCenter(center: Offset.zero, width: imgW, height: imgH);
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
      case 'puzzle_trio':
        PuzzleTrioPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'cat_hearts':
        CatHeartsPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'love_story':
        LoveStoryPainter(color: lineColor, width: lineWidth).paint(canvas, size);
        break;
      case 'hearts_flower':
      case 'hearts_balloon':
      case 'random_hearts':
      case 'leaf_fusion':
        for (int i = 0; i < imageCount; i++) {
          path.addPath(_getArtisticPath(clipType, i, imageCount, w, h), Offset.zero);
        }
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
      case 'comic_burst_5':
        // Draw quadrants first
        for (int i = 1; i < 5; i++) {
          canvas.drawPath(ComicBurst5Clipper.getComicBurst5Path(i, size), paint);
        }
        // Draw burst last to ensure its jagged border is clean on top
        canvas.drawPath(ComicBurst5Clipper.getComicBurst5Path(0, size), paint);
        break;
    }

    canvas.drawPath(path, paint);
  }

  Path _getArtisticPath(String mode, int index, int totalCount, double w, double h) {
    if (mode == 'hearts_flower') {
      double centerX = w * 0.5, centerY = h * 0.5;
      double radius = w * 0.3;
      double angle = (2 * math.pi / totalCount) * index;
      double px = centerX + radius * 0.95 * math.cos(angle);
      double py = centerY + radius * 0.95 * math.sin(angle);
      return _getHeartShape(px, py, radius * 1.4, rotation: angle + math.pi / 2);
    } else if (mode == 'hearts_balloon') {
      double bx = (w / (totalCount + 1)) * (index + 1);
      double by = h * 0.4 + (index % 2 == 0 ? -h * 0.18 : h * 0.12);
      return _getHeartShape(bx, by, w * 0.45);
    } else if (mode == 'leaf_fusion') {
      double centerX = w * 0.5, centerY = h * 0.5;
      double radius = w * 0.32;
      double angle = (2 * math.pi / totalCount) * index;
      double lx = centerX + radius * math.cos(angle);
      double ly = centerY + radius * math.sin(angle);
      return _getLeafShape(lx, ly, radius * 1.5, rotation: angle + math.pi / 2);
    } else {
      // random_hearts - SYNCED with Clipper
      List<double> xPattern = [0.25, 0.7, 0.35, 0.85, 0.5];
      List<double> yPattern = [0.25, 0.25, 0.75, 0.7, 0.5];
      double rx = xPattern[index % xPattern.length] * w;
      double ry = yPattern[index % yPattern.length] * h;
      double rSize = (index % 2 == 0) ? w * 0.4 : w * 0.5;
      return _getHeartShape(rx, ry, rSize, rotation: index * 0.9);
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
  CellRectClipper({required this.cell});

  @override
  Path getClip(Size size) {
    return Path()..addRect(
      Rect.fromLTWH(
        size.width * cell.left,
        size.height * cell.top,
        size.width * cell.width,
        size.height * cell.height,
      ),
    );
  }

  @override
  bool shouldReclip(CellRectClipper oldClipper) => oldClipper.cell != cell;
}

// ──────────────────────────────────────────────────────────────────────────────
// GridLinesPainter — draws nice lines on the boundaries of cells
// ──────────────────────────────────────────────────────────────────────────────
class GridLinesPainter extends CustomPainter {
  final List<CellRect> cells;
  final Color lineColor;
  final double lineWidth;

  GridLinesPainter({
    required this.cells,
    required this.lineColor,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lineWidth < 0.5) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    for (final cell in cells) {
      final rect = Rect.fromLTWH(
        w * cell.left,
        h * cell.top,
        w * cell.width,
        h * cell.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(GridLinesPainter old) =>
      old.cells != cells ||
      old.lineColor != lineColor ||
      old.lineWidth != lineWidth;
}
