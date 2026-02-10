// lib/pages/estruturas/estruturas_page.dart
//
// Estruturas MVP (texto + nível). Complexo Esportivo é o teto.
// Os níveis aqui são lidos/escritos via dynamic no GameState se existirem.

import 'package:flutter/material.dart';

import '../../services/world/game_state.dart';
import '../../services/inbox/inbox_service.dart';

class EstruturasPage extends StatefulWidget {
  const EstruturasPage({super.key});

  @override
  State<EstruturasPage> createState() => _EstruturasPageState();
}

class _EstruturasPageState extends State<EstruturasPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final complexo = _readLevel('complexoNivel', fallback: 1);

    final rows = [
      _Row('Complexo Esportivo', 'complexoNivel', teto: null),
      _Row('CT Profissional', 'ctProNivel', teto: complexo),
      _Row('CT da Base', 'ctBaseNivel', teto: complexo),
      _Row('Dept. Médico', 'dmNivel', teto: complexo),
      _Row('Scout (Análise)', 'scoutNivel', teto: complexo),
      _Row('Estádio', 'estadioNivel', teto: complexo),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Estruturas')),
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
              'Regras:\n'
              '• O Complexo Esportivo define o teto das outras estruturas.\n'
              '• Níveis: 1 a 5.\n'
              '• Depois ligamos custos e tempo de obra.',
              style: TextStyle(fontSize: 12, height: 1.25),
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map((r) => _tile(context, r, complexo)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, _Row r, int complexo) {
    final cs = Theme.of(context).colorScheme;
    final level = _readLevel(r.key, fallback: 1);
    final teto = r.teto;

    final canUp = level < 5 && (teto == null || level < teto);
    final canDown = level > 1 && r.key != 'complexoNivel';

    return Card(
      child: ListTile(
        title: Text(r.title),
        subtitle: Text(
          r.key == 'complexoNivel'
              ? 'Nível $level (teto geral)'
              : 'Nível $level • teto: $teto',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Diminuir (debug)',
              onPressed: canDown
                  ? () {
                      _writeLevel(r.key, level - 1);
                      setState(() {});
                      InboxService.I.push(
                        InboxMessage(
                          title: 'Estruturas',
                          body:
                              '${r.title} caiu para nível ${level - 1} (debug).',
                          kind: InboxKind.info,
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            IconButton(
              tooltip: canUp ? 'Aumentar' : 'Bloqueado pelo teto',
              onPressed: canUp
                  ? () {
                      _writeLevel(r.key, level + 1);
                      setState(() {});
                      InboxService.I.push(
                        InboxMessage(
                          title: 'Estruturas',
                          body: '${r.title} subiu para nível ${level + 1}.',
                          kind: InboxKind.warning,
                        ),
                      );
                    }
                  : null,
              icon: Icon(
                Icons.add_circle_outline,
                color: canUp ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _readLevel(String field, {required int fallback}) {
    try {
      final gs = GameState.I as dynamic;

      // tenta ler como property
      final v = gs.toJson().containsKey(field); // se existir toJson, melhor
      if (v == true) {
        final m = gs.toJson();
        final raw = m[field];
        if (raw is int) return raw.clamp(1, 5);
        if (raw is num) return raw.toInt().clamp(1, 5);
      }
    } catch (_) {}

    try {
      final gs = GameState.I as dynamic;
      final raw = gs[field];
      if (raw is int) return raw.clamp(1, 5);
    } catch (_) {}

    // fallback
    return fallback;
  }

  void _writeLevel(String field, int value) {
    final v = value.clamp(1, 5);
    try {
      final gs = GameState.I as dynamic;
      // tenta set direto
      gs
        ..toString()
        ..hashCode;
      // se tiver property: gs.ctProNivel = v;
      // usando dynamic: acessa pelo nome conhecido
      if (field == 'complexoNivel') gs.complexoNivel = v;
      if (field == 'ctProNivel') gs.ctProNivel = v;
      if (field == 'ctBaseNivel') gs.ctBaseNivel = v;
      if (field == 'dmNivel') gs.dmNivel = v;
      if (field == 'scoutNivel') gs.scoutNivel = v;
      if (field == 'estadioNivel') gs.estadioNivel = v;
      return;
    } catch (_) {}
  }
}

class _Row {
  final String title;
  final String key;
  final int? teto;

  _Row(this.title, this.key, {required this.teto});
}
