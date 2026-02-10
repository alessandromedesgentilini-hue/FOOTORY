// lib/pages/clubes/tatica_page.dart
//
// Tela de tática (somente visualização na V1)
// • Busca config no TimeTaticoRegistry; se não existir, gera default a partir
//   do estilo/nivel do clube no GameState e salva no registry.
// • Compatível com TimeTatico (linha: 1..5; intensidade: 0..100; estiloBase: Estilo).
// • UI mostra linha em 3 níveis (Baixa/Média/Alta) colapsando 1..5 -> 1..3.
// • Totalmente read-only (travado na V1).

import 'package:flutter/material.dart';
import '../../models/estilos.dart';
import '../../models/time_sim_ext.dart';
import '../../services/world/game_state.dart';

class TaticaPage extends StatefulWidget {
  final String? slug; // slug do clube selecionado
  const TaticaPage({super.key, required this.slug});

  @override
  State<TaticaPage> createState() => _TaticaPageState();
}

class _TaticaPageState extends State<TaticaPage> {
  @override
  void didUpdateWidget(covariant TaticaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // quando trocar de clube no dropdown, força rebuild
    if (oldWidget.slug != widget.slug) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    if (slug == null) {
      return const Center(
        child: Text('Selecione um clube para ver a tática.'),
      );
    }

    // tenta recuperar config salva; se não houver, cria a default (e grava)
    var cfg = TimeTaticoRegistry.de(slug);
    if (cfg == null) {
      final estilo = _safeEstiloDoClube(slug);
      final nivel = _safeNivelDoClube(slug);
      cfg = TimeTaticoRegistry.defaultFor(estilo, nivel);
      TimeTaticoRegistry.set(slug, cfg); // trava para a V1
    }

    // ATENÇÃO: TimeTatico usa "estiloBase", não "estilo"
    final estilo = cfg.estiloBase;
    // TimeTatico.linha é 1..5; colapsamos para 1..3 só para exibição
    final linhaDisplay = _linhaDisplay(cfg.linha); // 1..3
    final intensidade = cfg.intensidade; // 0..100

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(
          title: 'Estilo de jogo',
          trailing: estilo.label,
          child: Text(
            estilo.descCurta,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 12),
        _infoCard(
          title: 'Linha defensiva',
          trailing: _linhaLabel(linhaDisplay),
          child: Row(
            children: [
              _linhaChip('Baixa', active: linhaDisplay == 1),
              const SizedBox(width: 8),
              _linhaChip('Média', active: linhaDisplay == 2),
              const SizedBox(width: 8),
              _linhaChip('Alta', active: linhaDisplay == 3),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _infoCard(
          title: 'Intensidade',
          trailing: '$intensidade',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: intensidade / 100),
              const SizedBox(height: 6),
              const Text(
                'Pressão/ritmo (travado na V1)',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _LockedNote(),
      ],
    );
  }

  // ==== Safe reads do GameState (tolerante a branches diferentes) ====

  Estilo _safeEstiloDoClube(String slug) {
    try {
      final v = (GameState.I as dynamic).estiloDoClube(slug);
      if (v is Estilo) return v;
    } catch (_) {}
    return Estilo.transicao;
  }

  double _safeNivelDoClube(String slug) {
    try {
      final v = (GameState.I as dynamic).nivelDoClube(slug);
      if (v is num) return v.toDouble();
    } catch (_) {}
    return 3.0;
  }

  // ==== Mapeamentos/labels ====

  /// Colapsa linha 1..5 (modelo) para 1..3 (UI)
  int _linhaDisplay(int l15) {
    final l = l15.clamp(1, 5);
    if (l <= 2) return 1; // 1-2 → Baixa
    if (l == 3) return 2; // 3   → Média
    return 3; // 4-5 → Alta
  }

  String _linhaLabel(int l) {
    switch (l) {
      case 1:
        return 'Baixa';
      case 3:
        return 'Alta';
      case 2:
      default:
        return 'Média';
    }
  }

  // ==== UI helpers ====

  Widget _linhaChip(String text, {required bool active}) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      side: BorderSide(
        color: active ? Colors.teal : Colors.grey.shade700,
        width: active ? 1.5 : 1,
      ),
      backgroundColor: active ? Colors.teal.withOpacity(0.15) : null,
    );
  }

  Widget _infoCard({
    required String title,
    required String trailing,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(trailing,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _LockedNote extends StatelessWidget {
  const _LockedNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
        color: Colors.amber.withOpacity(0.08),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tática travada nesta versão: o estilo foi definido no início do jogo. '
              'Na V1 só visualizamos. Ajustes finos ficam para uma versão futura.',
            ),
          ),
        ],
      ),
    );
  }
}
