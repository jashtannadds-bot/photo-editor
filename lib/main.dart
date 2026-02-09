import 'package:flutter/material.dart';
import 'package:photho_editor/circlecollage.dart';
import 'package:photho_editor/collage.dart';
import 'package:photho_editor/filter_editor.dart';
import 'package:photho_editor/freestylecollage.dart';
import 'package:photho_editor/gridcollage.dart';
import 'package:photho_editor/heartflower.dart';
import 'package:photho_editor/homescreen.dart';
import 'package:photho_editor/mickycollage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
