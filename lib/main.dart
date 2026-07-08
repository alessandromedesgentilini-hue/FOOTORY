import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_theme.dart';
import 'package:footory26/pages/boot/boot_menu_page.dart';
import 'package:footory26/pages/koea_splash_page.dart';

void main() {
  runApp(const ProviderScope(child: FootoryApp()));
}

/// Raiz do app
/// - Sobe ProviderScope + MaterialApp
/// - Primeira tela: KoeaSplashPage
/// - Depois segue para BootMenuPage
class FootoryApp extends StatelessWidget {
  const FootoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Footory 26',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const KoeaSplashPage(
        nextPage: BootMenuPage(),
      ),
    );
  }
}
