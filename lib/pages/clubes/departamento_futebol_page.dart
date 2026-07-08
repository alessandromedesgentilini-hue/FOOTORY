// lib/pages/clubes/departamento_futebol_page.dart
//
// Tela: Departamento de Futebol (MVP)
// - Mostra níveis (1..10) e efeitos práticos (olheiros + negociação)
// - Sem pessoas individuais: investimento por departamento
//
// UI ONLY — não altera lógica de jogo.

import 'package:flutter/material.dart';
import '../../domain/models/clube_state.dart';

class DepartamentoFutebolPage extends StatelessWidget {
  final ClubeState clube;

  const DepartamentoFutebolPage({
    super.key,
    required this.clube,
  });

  @override
  Widget build(BuildContext context) {
    final d = clube.deptFutebol;

    // Descobertas por ciclo (relatório mensal)
    final maxDesc = d.maxResultadosRelatorio;
    final minDesc = (maxDesc - 2).clamp(2, maxDesc);
    final rangeText = '$minDesc–$maxDesc jogadores';

    // chance off-filtro (0..1 => %)
    final offPct = (d.chanceOffFiltro * 100).round();

    // bônus de qualidade (1..10)
    final qBonus = d.bonusQualidadeMedia10;

    // percentuais (INT no model)
    final buyPct = d.descontoCompraPct;
    final salPct = d.descontoSalarioPct;
    final sellPct = d.bonusVendaPct;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamento de Futebol'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopCard(
              title: clube.nome,
              subtitle: 'Define a qualidade das decisões esportivas do clube.',
              chips: [
                _ChipInfo(
                  icon: Icons.layers_outlined,
                  label: 'Divisão ${clube.divisao}',
                ),
                _ChipInfo(
                  icon: Icons.search_outlined,
                  label: 'Olheiros ${d.olheirosNivel}/10',
                ),
                _ChipInfo(
                  icon: Icons.handshake_outlined,
                  label: 'Negociação ${d.negociacaoNivel}/10',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.search_outlined,
              title: 'Olheiros',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LevelRow(label: 'Nível', value: d.olheirosNivel),
                  const SizedBox(height: 10),
                  _LineKV(label: 'Mercados', value: d.rangeDescobertas),
                  const SizedBox(height: 6),
                  _LineKV(label: 'Descobertas por ciclo', value: rangeText),
                  const SizedBox(height: 6),
                  _LineKV(
                    label: 'Chance de vir fora do pedido',
                    value: '$offPct%',
                  ),
                  const SizedBox(height: 6),
                  _LineKV(
                    label: 'Bônus leve de qualidade',
                    value: '+${qBonus.toStringAsFixed(2)} (em 1..10)',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Quanto maior o nível, mais opções aparecem e mais próximas do pedido.',
                    style: TextStyle(height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.handshake_outlined,
              title: 'Negociação',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LevelRow(label: 'Nível', value: d.negociacaoNivel),
                  const SizedBox(height: 10),
                  _LineKV(
                    label: 'Compra (desconto)',
                    value: '-$buyPct%',
                  ),
                  const SizedBox(height: 6),
                  _LineKV(
                    label: 'Salário (desconto)',
                    value: '-$salPct%',
                  ),
                  const SizedBox(height: 6),
                  _LineKV(
                    label: 'Venda (bônus)',
                    value: '+$sellPct%',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Negociação reduz compra/salário e melhora vendas.',
                    style: TextStyle(height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              icon: Icons.psychology_outlined,
              title: 'Planejamento de Elenco',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LevelRow(label: 'Nível', value: d.planejamentoNivel),
                  const SizedBox(height: 10),
                  const Text(
                    'Reservado para versões futuras (alertas e recomendações).',
                    style: TextStyle(height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),
            const _HintBox(
              text:
                  'No Mercado, recomendações vêm dos Olheiros e preços são ajustados pela Negociação.',
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== COMPONENTES ===================== */

class _TopCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_ChipInfo> chips;

  const _TopCard({
    required this.title,
    required this.subtitle,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                chips.map((c) => _chip(context, c.icon, c.label)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ChipInfo {
  final IconData icon;
  final String label;
  const _ChipInfo({required this.icon, required this.label});
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  final String label;
  final int value;

  const _LevelRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(1, 10);
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w800))),
        Text('$v/10', style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _LineKV extends StatelessWidget {
  final String label;
  final String value;

  const _LineKV({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _HintBox extends StatelessWidget {
  final String text;
  const _HintBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, size: 18),
          SizedBox(width: 10),
          Expanded(
              child: Text(
            'No Mercado, as recomendações virão do nível de Olheiros e o preço final será ajustado pelo nível de Negociação.',
          )),
        ],
      ),
    );
  }
}
