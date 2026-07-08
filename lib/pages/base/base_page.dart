// lib/pages/base/base_page.dart

import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Base')),
      body: const Center(
        child: Text(
          'Aqui entra a Base:\n'
          '• Jogadores sub-20\n'
          '• Estrutura da base (nível)\n'
          '• Evolução via CT da base\n\n'
          'Sem jogos no MVP.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
