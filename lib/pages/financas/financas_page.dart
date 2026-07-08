// lib/pages/financas/financas_page.dart

import 'package:flutter/material.dart';

class FinancasPage extends StatelessWidget {
  const FinancasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Finanças')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            ),
            child: const Text(
              'Aqui vai:\n'
              '• Caixa\n'
              '• Dívida\n'
              '• Receitas / Despesas\n'
              '• Saúde financeira\n\n'
              'Dia 1: salários e manutenção (automático).',
              style: TextStyle(height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}
