import 'package:flutter/material.dart';

class FilterPreset {
  final String name;
  final List<double> matrix;

  FilterPreset({required this.name, required this.matrix});
}

final List<FilterPreset> appFilters = [
  FilterPreset(name: "None", matrix: [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterPreset(name: "Kodak", matrix: [
    1.2, 0.1, 0.1, 0, 20,
    0.1, 1.0, 0.1, 0, 0,
    0.1, 0.1, 0.8, 0, -20,
    0, 0, 0, 1, 0,
  ]),
  FilterPreset(name: "Noir", matrix: [
    0.33, 0.59, 0.11, 0, 0,
    0.33, 0.59, 0.11, 0, 0,
    0.33, 0.59, 0.11, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterPreset(name: "Vintage", matrix: [
    0.9, 0.5, 0.1, 0, 0,
    0.3, 0.8, 0.1, 0, 0,
    0.2, 0.3, 0.5, 0, 0,
    0, 0, 0, 1, 0,
  ]),
  FilterPreset(name: "Aura Blue", matrix: [
    1, 0, 0, 0, -20,
    0, 1.1, 0, 0, -10,
    0, 0, 1.5, 0, 20,
    0, 0, 0, 1, 0,
  ]),
];