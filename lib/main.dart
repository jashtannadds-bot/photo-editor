import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photho_editor/theme_manager.dart';
import 'package:photho_editor/homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeManager = ThemeManager();

  try {
    await getTemporaryDirectory();
  } catch (e) {
    debugPrint('Path provider warm-up failed: $e');
  }

  runApp(MyApp(themeManager: themeManager));
}

class MyApp extends StatelessWidget {
  final ThemeManager themeManager;
  const MyApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: themeManager.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
