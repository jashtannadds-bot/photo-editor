import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photho_editor/filter_preset.dart';
import 'package:photho_editor/collageimagehelper.dart';

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
  double _warmth = 0.0;
  double _highlights = 0.0;
  double _shadows = 0.0;
  double _ambiance = 0.0;
  List<double> _baseMatrix = appFilters[0].matrix; // Current selected preset

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "SNAP-EDIT",
          style: TextStyle(letterSpacing: 2, fontSize: 14),
        ),
        actions: [
          if (_selectedImage != null)
            TextButton(
              onPressed: () => CollageHelper.saveCollage(_saveKey, context),
              child: const Text(
                "EXPORT",
                style: TextStyle(color: Colors.pinkAccent),
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
                  child: RepaintBoundary(
                    key: _saveKey,
                    child: Center(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(
                          _getWarmthMatrix(_warmth),
                        ),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(
                            _getHighlightShadowMatrix(_highlights, _shadows),
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                              _getAmbianceMatrix(_ambiance),
                            ),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(
                                _calculateFinalMatrix(),
                              ), // Presets & Brightness
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
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
    return DefaultTabController(
      length: 2,
      child: Container(
        height: 220,
        color: const Color(0xFF121212),
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
                  Padding(
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
                      ],
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
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 9),
          ),
        ),
        Expanded(
          child: Slider(
            value: val,
            min: min,
            max: max,
            activeColor: Colors.pinkAccent,
            onChanged: onChanged,
          ),
        ),
      ],
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

  List<double> _getHiShadowMatrix(double highlights, double shadows) {
    double h = 1 + (highlights * 0.1);
    double s = shadows * 30;
    return [h, 0, 0, 0, s, 0, h, 0, 0, s, 0, 0, h, 0, s, 0, 0, 0, 1, 0];
  }
}
