// lib/main.dart
//
// Bootstrap mínimo do FutSim (MVP):
// - Inicializa Hive antes de subir o app
// - Sobe um MaterialApp simples
// - Home = BootMenuPage (Novo Jogo / Continuar)

import 'package:flutter/material.dart';
import 'pages/boot/boot_menu_page.dart';
import 'services/storage/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive (boxes app / save)
  await HiveService.init();

  runApp(const FutSimApp());
}

class FutSimApp extends StatelessWidget {
  const FutSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutSim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0B5ED7),
        brightness: Brightness.light,
      ),
      home: const BootMenuPage(),
    );
  }
}
