// lib/pages/clubes/jogador_page.dart
//
// JogadorPage (Caminho B — core completo)
// - Mostra OVR cheio (10..100): soma dos 10 atributos da função
// - Mostra estrelas (1..10 em .5): média dos 10 da função
// - Mostra os 10 atributos da função (1..10)
// - ✅ MOSTRA TODOS OS ATRIBUTOS do jogador (catálogo completo)
//
// ✅ Agora exibe POSIÇÃO DETALHADA (posDet) no chip.
// Macro (pos) continua existindo, mas é secundário.

import 'package:flutter/material.dart';
import '../../models/jogador.dart';

class JogadorPage extends StatefulWidget {
  final Jogador jogador;
  const JogadorPage({super.key, required this.jogador});

  @override
  State<JogadorPage> createState() => _JogadorPageState();
}

class _JogadorPageState extends State<JogadorPage> {
  final TextEditingController _q = TextEditingController();
  bool _sortByValue = true;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.jogador;

    final keysFunc = p.chavesFuncao;
    final valuesFunc =
        keysFunc.map((k) => (p.atributos[k] ?? 1).clamp(1, 10)).toList();

    final soma10 = valuesFunc.fold<int>(0, (a, b) => a + b); // 10..100
    final media10 = soma10 / 10.0; // 1..10
    final estrelas = (media10 * 2).round() / 2.0;

    final allAttrs = _buildCatalogWithValues(p);

    final q = _q.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? allAttrs
        : allAttrs
            .where((e) => e.label.toLowerCase().contains(q))
            .toList(growable: false);

    final sorted = List<_AttrLine>.of(filtered);
    sorted.sort((a, b) {
      if (_sortByValue) {
        final d = b.value.compareTo(a.value);
        if (d != 0) return d;
        return a.label.compareTo(b.label);
      }
      return a.label.compareTo(b.label);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(p.nome),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== topo =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      p.facePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.blueGrey.shade700,
                        child: Text(
                          p.iniciais,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(icon: Icons.sports_soccer, label: p.posDet),
                          _chip(
                              icon: Icons.layers_outlined,
                              label: p.pos), // macro só pra debug
                          _chip(icon: Icons.cake, label: 'Idade ${p.idade}'),
                          _chip(icon: Icons.star, label: 'OVR $soma10'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _StarRow(value10: estrelas),
                      const SizedBox(height: 10),
                      Text(
                        'Valor: ${p.valorFormatado}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text('Salário mensal: ${p.salarioFormatado}'),
                      const SizedBox(height: 4),
                      Text(
                        'Contrato: ${p.anosContrato} ano${p.anosContrato == 1 ? "" : "s"}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // ===== atributos da função =====
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Atributos da função (1..10)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(keysFunc.length, (i) {
              final label = _label(keysFunc[i]);
              final v = valuesFunc[i];
              return _attrRow(label, v);
            }),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // ===== todos os atributos =====
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Todos os atributos (core)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _q,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar atributo…',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: Text(
                      _sortByValue ? 'Ordenar por Valor' : 'Ordenar por Nome'),
                  selected: _sortByValue,
                  onSelected: (v) => setState(() => _sortByValue = v),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhum atributo encontrado com esse filtro.'),
              )
            else
              ...sorted.map((e) => _attrRow(e.label, e.value)),
          ],
        ),
      ),
    );
  }

  List<_AttrLine> _buildCatalogWithValues(Jogador p) {
    return Jogador.coreKeys.map((k) {
      final v = (p.atributos[k] ?? 1).clamp(1, 10);
      return _AttrLine(key: k, label: _label(k), value: v);
    }).toList(growable: false);
  }

  Widget _chip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _attrRow(String label, int v) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniBar(value: v),
          const SizedBox(width: 10),
          Text('$v', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  String _label(String k) {
    switch (k) {
      case 'finalizacao':
        return 'Finalização';
      case 'chute_longe':
        return 'Chute de longe';
      case 'presenca_ofensiva':
        return 'Presença ofensiva';
      case 'drible':
        return 'Drible';
      case 'dominio_conducao':
        return 'Domínio/Condução';
      case 'passe_curto':
        return 'Passe curto';
      case 'passe_longo':
        return 'Passe longo';
      case 'cruzamento':
        return 'Cruzamento';
      case 'tomada_decisao':
        return 'Tomada de decisão';
      case 'capacidade_tatica':
        return 'Capacidade tática';
      case 'frieza':
        return 'Frieza';
      case 'espirito_protagonista':
        return 'Espírito protagonista';
      case 'velocidade':
        return 'Velocidade';
      case 'resistencia':
        return 'Resistência';
      case 'potencia':
        return 'Potência';
      case 'composicao_natural':
        return 'Composição natural';
      case 'coordenacao_motora':
        return 'Coordenação motora';
      case 'marcacao':
        return 'Marcação';
      case 'cobertura_defensiva':
        return 'Cobertura defensiva';
      case 'jogo_aereo':
        return 'Jogo aéreo';
      case 'antecipacao':
        return 'Antecipação';
      case 'desarme':
        return 'Desarme';
      case 'def_finalizacoes':
        return 'Def. finalizações';
      case 'def_chute_longe':
        return 'Def. chute de longe';
      case 'def_bola_parada':
        return 'Def. bola parada';
      case 'def_penalti':
        return 'Def. pênalti';
      case 'saida_gol':
        return 'Saída do gol';
      case 'reflexo_reacao':
        return 'Reflexo/Reação';
      case 'controle_area':
        return 'Controle da área';
      default:
        return k;
    }
  }
}

class _AttrLine {
  final String key;
  final String label;
  final int value;
  const _AttrLine(
      {required this.key, required this.label, required this.value});
}

class _MiniBar extends StatelessWidget {
  final int value;
  const _MiniBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clamped = value.clamp(1, 10);
    return SizedBox(
      width: 90,
      height: 8,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.7),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: clamped / 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double value10; // 1..10 em .5
  const _StarRow({required this.value10});

  @override
  Widget build(BuildContext context) {
    final v = value10.clamp(0.0, 10.0);
    final stars5 = v / 2.0;

    final full = stars5.floor();
    final half = (stars5 - full) >= 0.5 ? 1 : 0;
    final empty = 5 - full - half;

    return Row(
      children: [
        ...List.generate(full, (_) => const Icon(Icons.star, size: 18)),
        if (half == 1) const Icon(Icons.star_half, size: 18),
        ...List.generate(empty, (_) => const Icon(Icons.star_border, size: 18)),
        const SizedBox(width: 8),
        Text(
          value10.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
