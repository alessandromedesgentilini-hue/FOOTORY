// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/menu/menu_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FutSimApp());
}

class FutSimApp extends StatelessWidget {
  const FutSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUTSIM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0A7E8C),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}
