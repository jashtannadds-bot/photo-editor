import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/filter_preset.dart';
import 'package:photho_editor/collageimagehelper.dart';

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
      length: 2,
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
                ],
              ),
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

  List<double> _getTintMatrix(double tint) {
    return [
      1, 0, 0, 0, tint * 30, // Red
      0, 1.1, 0, 0, -tint * 20, // Green
      0, 0, 1, 0, tint * 30, // Blue
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _getExposureMatrix(double exposure) {
    double ev = exposure + 1.0;
    return [ev, 0, 0, 0, 0, 0, ev, 0, 0, 0, 0, 0, ev, 0, 0, 0, 0, 0, 1, 0];
  }

  Widget _buildPreviewImage() {
    return ShaderMask(
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
            colorFilter: ColorFilter.matrix(_getSaturationMatrix(_saturation)),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(_getContrastMatrix(_contrast)),
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

  List<double> _getHiShadowMatrix(double highlights, double shadows) {
    double h = 1 + (highlights * 0.1);
    double s = shadows * 30;
    return [h, 0, 0, 0, s, 0, h, 0, 0, s, 0, 0, h, 0, s, 0, 0, 0, 1, 0];
  }
}
