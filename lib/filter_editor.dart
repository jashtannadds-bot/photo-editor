import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/filter_preset.dart';
import 'package:photho_editor/collageimagehelper.dart';
import 'package:google_fonts/google_fonts.dart';

class TextLayer {
  String text;
  String fontFamily;
  Color color;
  Offset position;
  double fontSize;
  double curve; // -1.0 to 1.0
  double letterSpacing;

  // New Features
  bool isBold;
  bool isItalic;
  bool isStrike;
  bool isUnderline;
  TextAlign textAlign;
  double rotation; // in degrees
  double lineSpacing; // height
  double shadowBlur;
  Color shadowColor;
  Offset shadowOffset;
  String textCase; // 'original', 'uppercase', 'lowercase', 'sentence'

  TextLayer({
    required this.text,
    required this.fontFamily,
    required this.color,
    required this.position,
    this.fontSize = 20,
    this.curve = 0.0,
    this.letterSpacing = 0.0,
    this.isBold = true,
    this.isItalic = false,
    this.isStrike = false,
    this.isUnderline = false,
    this.textAlign = TextAlign.center,
    this.rotation = 0.0,
    this.lineSpacing = 1.2,
    this.shadowBlur = 0.0,
    this.shadowColor = Colors.black45,
    this.shadowOffset = const Offset(2, 2),
    this.textCase = 'original',
  });
}

class CurvedTextPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double radius;
  final double angleOffset; // radians
  final bool isNegative; // true if curvature < 0

  CurvedTextPainter({
    required this.text,
    required this.style,
    required this.radius,
    required this.angleOffset,
    required this.isNegative,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    double totalWidth = 0;
    List<double> charWidths = [];

    for (int i = 0; i < text.length; i++) {
      textPainter.text = TextSpan(text: text[i], style: style);
      textPainter.layout();
      charWidths.add(textPainter.width);
      totalWidth += textPainter.width;
    }

    final double circumference = 2 * math.pi * radius;
    final double totalAngle = (totalWidth / circumference) * 2 * math.pi;

    // Shift center for visibility
    double centerY;
    if (isNegative) {
      // Smiley: arc is at bottom of circle
      centerY = -radius + size.height - (style.fontSize ?? 20) / 2;
    } else {
      // Rainbow: arc is at top of circle
      centerY = radius + (style.fontSize ?? 20) / 2;
    }

    canvas.translate(size.width / 2, centerY);

    double currentAngle = angleOffset - (totalAngle / 2);

    for (int i = 0; i < text.length; i++) {
      final double charAngle = (charWidths[i] / totalWidth) * totalAngle;
      final double midAngle = currentAngle + (charAngle / 2);

      canvas.save();
      canvas.translate(
        radius * math.cos(midAngle),
        radius * math.sin(midAngle),
      );

      double rotation = midAngle + math.pi / 2;
      if (isNegative) {
        rotation += math.pi; // Flip text upright for smiley
      }
      canvas.rotate(rotation);

      textPainter.text = TextSpan(text: text[i], style: style);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-charWidths[i] / 2, -textPainter.height / 2),
      );

      canvas.restore();
      currentAngle += charAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CurvedTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.radius != radius ||
        oldDelegate.angleOffset != angleOffset ||
        oldDelegate.isNegative != isNegative;
  }
}

class CurvedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double curvature; // -1.0 to 1.0
  final TextAlign textAlign;

  const CurvedText({
    super.key,
    required this.text,
    required this.style,
    required this.curvature,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox();
    if (curvature == 0) {
      return Text(text, style: style, textAlign: textAlign);
    }

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final double totalWidth = tp.width;
    // Smoother scaling for radius
    final double minRadius = totalWidth * 0.4;
    final double radius = minRadius + (250 / (curvature.abs() + 0.05) - 25);

    final double circumference = 2 * math.pi * radius;
    final double totalAngle = (totalWidth / circumference) * 2 * math.pi;

    final double arcHeight =
        radius * (1 - math.cos(totalAngle / 2)) + tp.height * 1.5;
    final double arcWidth = radius * math.sin(totalAngle / 2) * 2 + 20;

    final bool isNegative = curvature < 0;
    // Rainbow uses TOP of circle (-pi/2), Smiley uses BOTTOM (pi/2)
    final double angleOffset = isNegative ? math.pi / 2 : -math.pi / 2;

    return CustomPaint(
      size: Size(math.max(totalWidth, arcWidth), arcHeight),
      painter: CurvedTextPainter(
        text: text,
        style: style,
        radius: radius,
        angleOffset: angleOffset,
        isNegative: isNegative,
      ),
    );
  }
}

class AspectRatioOption {
  final String title;
  final double? ratio;
  final IconData icon;

  const AspectRatioOption(this.title, this.ratio, this.icon);
}

const List<AspectRatioOption> aspectRatios = [
  AspectRatioOption("Original", null, Icons.crop_original_rounded),
  AspectRatioOption("Square", 1.0, Icons.crop_square_rounded),
  AspectRatioOption("Story/Reels", 9 / 16, Icons.phone_android_rounded),
  AspectRatioOption("Post (4:5)", 4 / 5, Icons.portrait_rounded),
  AspectRatioOption("Pinterest", 2 / 3, Icons.image_search_rounded),
  AspectRatioOption("Landscape", 16 / 9, Icons.crop_16_9_rounded),
  AspectRatioOption("Portrait (3:4)", 3 / 4, Icons.crop_portrait_rounded),
];

class FilterEditorScreen extends StatefulWidget {
  final File? initialImage;
  const FilterEditorScreen({super.key, this.initialImage});

  @override
  State<FilterEditorScreen> createState() => _FilterEditorScreenState();
}

class _FilterEditorScreenState extends State<FilterEditorScreen> {
  File? _selectedImage;
  final GlobalKey _saveKey = GlobalKey();

  // State for adjustments
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _vignette = 0.0;
  double _warmth = 0.0;
  double _highlights = 0.0;
  double _shadows = 0.0;
  double _ambiance = 0.0;
  List<double> _baseMatrix = appFilters[0].matrix; // Current selected preset
  AspectRatioOption _selectedRatio = aspectRatios[0];
  final List<TextLayer> _textLayers = [];
  int _selectedTextIndex = -1;
  bool _isHoldingItem = false;
  Offset _currentFingerPos = Offset.zero;
  final List<String> _fontFamilies = [
    'Roboto',
    'Lobster',
    'Pacifico',
    'Dancing Script',
    'Bangers',
    'Montserrat',
    'Caveat',
    'Satisfy',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _resetAdjustments();
      });
    }
  }

  void _resetAdjustments() {
    _brightness = 0.0;
    _contrast = 1.0;
    _saturation = 1.0;
    _baseMatrix = appFilters[0].matrix;
  }

  // Logic to combine Preset Matrix with Manual Sliders
  List<double> _calculateFinalMatrix() {
    // 1. Start with base preset
    List<double> matrix = List.from(_baseMatrix);

    // 2. Apply Brightness (column 5)
    matrix[4] += _brightness * 255;
    matrix[9] += _brightness * 255;
    matrix[14] += _brightness * 255;

    // 3. Apply Contrast & Saturation would ideally be complex math,
    // but for this editor, we use nested ColorFiltered for performance.
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "SNAP-EDIT",
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedImage != null)
            TextButton(
              onPressed: () => _showExportDialog(),
              child: const Text(
                "EXPORT",
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _selectedImage == null
          ? Center(
              child: IconButton(
                icon: const Icon(
                  Icons.add_a_photo,
                  size: 50,
                  color: Colors.white24,
                ),
                onPressed: _pickImage,
              ),
            )
          : Column(
              children: [
                // PREVIEW AREA
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: RepaintBoundary(
                        key: _saveKey,
                        child: _selectedRatio.ratio == null
                            ? _buildPreviewImage()
                            : AspectRatio(
                                aspectRatio: _selectedRatio.ratio!,
                                child: _buildPreviewImage(),
                              ),
                      ),
                    ),
                  ),
                ),
                // TOOLS PANEL (Presets + Sliders)
                _buildControlTabs(),
              ],
            ),
    );
  }

  Widget _buildControlTabs() {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Container(
        height: 250,
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.pinkAccent,
              tabs: [
                Tab(text: "PRESETS"),
                Tab(text: "TUNE IMAGE"),
                Tab(text: "CROP"),
                Tab(text: "TEXT"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Your Presets
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: appFilters.length,
                    padding: const EdgeInsets.all(15),
                    itemBuilder: (context, i) =>
                        _buildFilterThumb(appFilters[i]),
                  ),
                  // Tab 2: Manual Sliders
                  Scrollbar(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildSlider(
                              "BRIGHTNESS",
                              _brightness,
                              -1,
                              1,
                              (v) => setState(() => _brightness = v),
                            ),
                            _buildSlider(
                              "CONTRAST",
                              _contrast,
                              0.5,
                              1.5,
                              (v) => setState(() => _contrast = v),
                            ),
                            _buildSlider(
                              "SATURATION",
                              _saturation,
                              0,
                              2,
                              (v) => setState(() => _saturation = v),
                            ),

                            _buildSlider(
                              "WARMTH",
                              _warmth,
                              -1,
                              1,
                              (v) => setState(() => _warmth = v),
                            ),
                            _buildSlider(
                              "VIGNETTE",
                              _vignette,
                              0,
                              1,
                              (v) => setState(() => _vignette = v),
                            ),
                            _buildSlider(
                              "AMBIANCE",
                              _ambiance,
                              -1,
                              1,
                              (v) => setState(() => _ambiance = v),
                            ),
                            _buildSlider(
                              "HIGHLIGHTS",
                              _highlights,
                              -1,
                              1,
                              (v) => setState(() => _highlights = v),
                            ),
                            _buildSlider(
                              "SHADOWS",
                              _shadows,
                              -1,
                              1,
                              (v) => setState(() => _shadows = v),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tab 3: Crop
                  _buildCropTools(),
                  // Tab 4: Text
                  _buildTextTools(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropTools() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: aspectRatios.length,
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, i) {
        final ratio = aspectRatios[i];
        final isSelected = _selectedRatio == ratio;
        return GestureDetector(
          onTap: () => setState(() => _selectedRatio = ratio),
          child: Container(
            width: 85,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.pinkAccent.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.pinkAccent : Colors.white10,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  ratio.icon,
                  color: isSelected ? Colors.pinkAccent : Colors.white70,
                  size: 24,
                ),
                const SizedBox(height: 5),
                Text(
                  ratio.title,
                  style: TextStyle(
                    color: isSelected ? Colors.pinkAccent : Colors.white70,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextTools() {
    return Column(
      children: [
        // Compact Header
        Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _addTextDialog,
                icon: const Icon(Icons.add, size: 14, color: Colors.pinkAccent),
                label: const Text(
                  "ADD",
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
              ),
              const Spacer(),
              if (_selectedTextIndex != -1) ...[
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(() => _selectedTextIndex = -1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  onPressed: () => setState(() {
                    _textLayers.removeAt(_selectedTextIndex);
                    _selectedTextIndex = -1;
                  }),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
        if (_selectedTextIndex != -1)
          Expanded(
            child: DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  const TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.pinkAccent,
                    labelColor: Colors.pinkAccent,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(text: "FONT"),
                      Tab(text: "COLOR"),
                      Tab(text: "STYLE"),
                      Tab(text: "ADJUST"),
                      Tab(text: "CURVE"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Font Selection
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _fontFamilies.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          itemBuilder: (context, i) {
                            final font = _fontFamilies[i];
                            final isSelected =
                                _textLayers[_selectedTextIndex].fontFamily ==
                                font;
                            return GestureDetector(
                              onTap: () => setState(
                                () =>
                                    _textLayers[_selectedTextIndex].fontFamily =
                                        font,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.pinkAccent
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    font,
                                    style: GoogleFonts.getFont(
                                      font,
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Color Selection
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: Colors.primaries.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
                          ),
                          itemBuilder: (context, i) {
                            final color = Colors.primaries[i];
                            return GestureDetector(
                              onTap: () => setState(
                                () => _textLayers[_selectedTextIndex].color =
                                    color,
                              ),
                              child: Container(
                                width: 35,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        _textLayers[_selectedTextIndex].color ==
                                            color
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Style Tab (Bold, Italic, Align, Case, Decor)
                        _buildTextStyleTab(),
                        // Adjust Tab (Size, Shadow, Degree, Character, Line)
                        _buildTextAdjustTab(),
                        // Curve Selection
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.gesture,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "TEXT CURVE",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "${(_textLayers[_selectedTextIndex].curve * 100).toInt()}%",
                                    style: const TextStyle(
                                      color: Colors.pinkAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      size: 14,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _textLayers[_selectedTextIndex]
                                                  .curve =
                                              0.0,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _textLayers[_selectedTextIndex].curve,
                                min: -1.0,
                                max: 1.0,
                                activeColor: Colors.pinkAccent,
                                inactiveColor: Colors.white10,
                                onChanged: (v) => setState(
                                  () =>
                                      _textLayers[_selectedTextIndex].curve = v,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextStyleTab() {
    final layer = _textLayers[_selectedTextIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FORMAT",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildToggleBtn(
                Icons.format_bold,
                layer.isBold,
                (v) => setState(() => layer.isBold = v),
              ),
              _buildToggleBtn(
                Icons.format_italic,
                layer.isItalic,
                (v) => setState(() => layer.isItalic = v),
              ),
              _buildToggleBtn(
                Icons.format_strikethrough,
                layer.isStrike,
                (v) => setState(() => layer.isStrike = v),
              ),
              _buildToggleBtn(
                Icons.format_underlined,
                layer.isUnderline,
                (v) => setState(() => layer.isUnderline = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "ALIGNMENT",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildAlignBtn(
                TextAlign.left,
                Icons.format_align_left,
                layer.textAlign,
                (v) => setState(() => layer.textAlign = v),
              ),
              _buildAlignBtn(
                TextAlign.center,
                Icons.format_align_center,
                layer.textAlign,
                (v) => setState(() => layer.textAlign = v),
              ),
              _buildAlignBtn(
                TextAlign.right,
                Icons.format_align_right,
                layer.textAlign,
                (v) => setState(() => layer.textAlign = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "CASE",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildCaseBtn(
                "Aa",
                "original",
                layer.textCase,
                (v) => setState(() => layer.textCase = v),
              ),
              _buildCaseBtn(
                "AA",
                "uppercase",
                layer.textCase,
                (v) => setState(() => layer.textCase = v),
              ),
              _buildCaseBtn(
                "aa",
                "lowercase",
                layer.textCase,
                (v) => setState(() => layer.textCase = v),
              ),
              _buildCaseBtn(
                "aA",
                "sentence",
                layer.textCase,
                (v) => setState(() => layer.textCase = v),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _textLayers.removeAt(_selectedTextIndex);
                  _selectedTextIndex = -1;
                });
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text("DELETE LAYER"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.2),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.redAccent, width: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAdjustTab() {
    final layer = _textLayers[_selectedTextIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          _buildSlider(
            "SIZE",
            layer.fontSize,
            10,
            200,
            (v) => setState(() => layer.fontSize = v),
          ),
          _buildSlider(
            "SHADOW",
            layer.shadowBlur,
            0,
            20,
            (v) => setState(() => layer.shadowBlur = v),
          ),
          _buildSlider(
            "DEGREE",
            layer.rotation,
            -180,
            180,
            (v) => setState(() => layer.rotation = v),
          ),
          _buildSlider(
            "CHARACTER",
            layer.letterSpacing,
            -5,
            20,
            (v) => setState(() => layer.letterSpacing = v),
          ),
          _buildSlider(
            "LINE",
            layer.lineSpacing,
            0.5,
            3.0,
            (v) => setState(() => layer.lineSpacing = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(IconData icon, bool isActive, Function(bool) onTap) {
    return GestureDetector(
      onTap: () => onTap(!isActive),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.pinkAccent : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildAlignBtn(
    TextAlign align,
    IconData icon,
    TextAlign current,
    Function(TextAlign) onTap,
  ) {
    bool isActive = align == current;
    return GestureDetector(
      onTap: () => onTap(align),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.pinkAccent : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCaseBtn(
    String label,
    String value,
    String current,
    Function(String) onTap,
  ) {
    bool isActive = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.pinkAccent : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _addTextDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Enter Text", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Type something...",
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _textLayers.add(
                    TextLayer(
                      text: controller.text,
                      fontFamily: _fontFamilies[0],
                      color: Colors.white,
                      position: const Offset(50, 50),
                    ),
                  );
                  _selectedTextIndex = _textLayers.length - 1;
                });
                Navigator.pop(context);
              }
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }

  void _checkDustbinLogic(int index) {
    double screenHeight = MediaQuery.of(context).size.height;
    // Threshold adjusted to 85% for better reliability
    double dustbinLine = screenHeight * 0.85;

    if (_currentFingerPos.dy > dustbinLine) {
      setState(() {
        _textLayers.removeAt(index);
        _selectedTextIndex = -1;
        _isHoldingItem = false;
      });
    }
  }

  Widget _buildStaticDustbin() {
    bool isHovering =
        _currentFingerPos.dy > MediaQuery.of(context).size.height * 0.8;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              isHovering
                  ? Colors.redAccent.withOpacity(0.8)
                  : Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              isHovering ? Icons.delete : Icons.delete_outline,
              color: Colors.white,
              size: isHovering ? 40 : 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterThumb(FilterPreset preset) {
    return GestureDetector(
      onTap: () => setState(() => _baseMatrix = preset.matrix),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(preset.matrix),
                child: Image.file(
                  _selectedImage!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              preset.name,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double val,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    // Scaling logic for display:
    // For values like Brightness (-1 to 1), show -100 to 100
    // For values like Contrast (0.5 to 1.5), show as offset from 1.0?
    // Let's keep it simple: scale the range to 0-100 or -100 to 100.
    int displayValue;
    if (min < 0) {
      // Centered sliders (-1 to 1) -> -100 to 100
      displayValue = (val * 100).toInt();
    } else if (min == 0 && max == 2) {
      // Saturation (0 to 2) -> -100 to 100 where 1.0 is 0
      displayValue = ((val - 1.0) * 100).toInt();
    } else if (min == 0.5 && max == 1.5) {
      // Contrast (0.5 to 1.5) -> -50 to 50
      displayValue = ((val - 1.0) * 100).toInt();
    } else {
      // Others (like Vignette 0 to 1) -> 0 to 100
      displayValue = (val * 100).toInt();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: val,
                min: min,
                max: max,
                activeColor: Colors.pinkAccent,
                inactiveColor: Colors.white10,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              (displayValue > 0 ? "+$displayValue" : "$displayValue"),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.pinkAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MATRIX MATH HELPER FUNCTIONS ---
  List<double> _getSaturationMatrix(double saturation) {
    final double r = 0.2126 * (1 - saturation);
    final double g = 0.7152 * (1 - saturation);
    final double b = 0.0722 * (1 - saturation);

    return [
      r + saturation,
      g,
      b,
      0,
      0,
      r,
      g + saturation,
      b,
      0,
      0,
      r,
      g,
      b + saturation,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  List<double> _getContrastMatrix(double contrast) {
    final double t = (1.0 - contrast) / 2.0 * 255;
    return [
      contrast,
      0,
      0,
      0,
      t,
      0,
      contrast,
      0,
      0,
      t,
      0,
      0,
      contrast,
      0,
      t,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  // --- PRO MATH HELPER FUNCTIONS ---

  // 1. WARMTH (Temperature)
  // Increases yellow/orange for warmth, blue for cool
  List<double> _getWarmthMatrix(double warmth) {
    return [
      1, 0, 0, 0, warmth * 50, // Red
      0, 1, 0, 0, warmth * 30, // Green
      0, 0, 1, 0, -warmth * 50, // Blue (inverse)
      0, 0, 0, 1, 0,
    ];
  }

  // 2. HIGHLIGHTS & SHADOWS (Luminance Mapping)
  // Highlights: Affects the brighter end of the spectrum
  // Shadows: Affects the darker end
  List<double> _getHighlightShadowMatrix(double highlights, double shadows) {
    double h = highlights * 0.2;
    double s = shadows * 0.2;
    return [
      1 + h,
      0,
      0,
      0,
      s * 255,
      0,
      1 + h,
      0,
      0,
      s * 255,
      0,
      0,
      1 + h,
      0,
      s * 255,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  // 3. AMBIANCE (Contrast + Saturation + Brightness Balance)
  // Ambiance is a Snapseed-specific blend that opens up shadows while increasing saturation
  List<double> _getAmbianceMatrix(double ambiance) {
    double sat = 1.0 + (ambiance * 0.5);
    double bright = ambiance * 30;
    return [
      sat,
      0,
      0,
      0,
      bright,
      0,
      sat,
      0,
      0,
      bright,
      0,
      0,
      sat,
      0,
      bright,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  Widget _buildPreviewImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ShaderMask(
          shaderCallback: (rect) {
            return RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(_vignette.clamp(0.0, 1.0)),
              ],
              stops: const [0.6, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.darken,
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(_getAmbianceMatrix(_ambiance)),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                _getHighlightShadowMatrix(_highlights, _shadows),
              ),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(
                  _getSaturationMatrix(_saturation),
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(
                    _getContrastMatrix(_contrast),
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(_getWarmthMatrix(_warmth)),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(_calculateFinalMatrix()),
                      child: _selectedRatio.ratio == null
                          ? Image.file(_selectedImage!, fit: BoxFit.contain)
                          : Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ..._textLayers.asMap().entries.map((entry) {
          int idx = entry.key;
          TextLayer layer = entry.value;
          bool isSelected = idx == _selectedTextIndex;

          String transformedText = layer.text;
          if (layer.textCase == 'uppercase') {
            transformedText = layer.text.toUpperCase();
          } else if (layer.textCase == 'lowercase') {
            transformedText = layer.text.toLowerCase();
          } else if (layer.textCase == 'sentence') {
            if (layer.text.isNotEmpty) {
              transformedText =
                  layer.text[0].toUpperCase() +
                  layer.text.substring(1).toLowerCase();
            }
          }

          return Positioned(
            left: layer.position.dx,
            top: layer.position.dy,
            child: GestureDetector(
              onScaleStart: (details) {
                setState(() {
                  _selectedTextIndex = idx;
                  _isHoldingItem = true;
                });
              },
              onScaleUpdate: (details) {
                setState(() {
                  _currentFingerPos = details.focalPoint;
                  layer.position += details.focalPointDelta;
                  if (details.scale != 1.0) {
                    layer.fontSize = (layer.fontSize * details.scale).clamp(
                      10,
                      200,
                    );
                  }
                  _checkDustbinLogic(idx);
                });
              },
              onScaleEnd: (details) {
                setState(() {
                  _isHoldingItem = false;
                });
              },
              onTap: () {
                setState(() {
                  _selectedTextIndex = idx;
                });
              },
              child: Transform.rotate(
                angle: layer.rotation * (math.pi / 180),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Colors.pinkAccent
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: CurvedText(
                    text: transformedText,
                    style: GoogleFonts.getFont(
                      layer.fontFamily,
                      color: layer.color,
                      fontSize: layer.fontSize,
                      fontWeight: layer.isBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontStyle: layer.isItalic
                          ? FontStyle.italic
                          : FontStyle.normal,
                      decoration: TextDecoration.combine([
                        if (layer.isStrike) TextDecoration.lineThrough,
                        if (layer.isUnderline) TextDecoration.underline,
                      ]),
                      letterSpacing: layer.letterSpacing,
                      height: layer.lineSpacing,
                      shadows: [
                        if (layer.shadowBlur > 0)
                          Shadow(
                            color: layer.shadowColor,
                            blurRadius: layer.shadowBlur,
                            offset: layer.shadowOffset,
                          ),
                      ],
                    ),
                    curvature: layer.curve,
                    textAlign: layer.textAlign,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        if (_isHoldingItem) _buildStaticDustbin(),
      ],
    );
  }

  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          return Container(
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
                const Text(
                  "Choose Aspect Ratio",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Select a ratio for your export",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: aspectRatios.length,
                    itemBuilder: (context, index) {
                      final ratio = aspectRatios[index];
                      final isSelected = _selectedRatio == ratio;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => _selectedRatio = ratio);
                          setState(() => _selectedRatio = ratio);
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.pinkAccent.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.pinkAccent
                                  : Colors.white10,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                ratio.icon,
                                color: isSelected
                                    ? Colors.pinkAccent
                                    : Colors.white,
                                size: 30,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                ratio.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.pinkAccent
                                      : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      CollageHelper.saveCollage(_saveKey, context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "SAVE TO GALLERY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
