// lib/pages/evolucao/evolucao_page.dart
//
// Evolução (MVP - NOVO MODELO FINAL)
// - Janeiro: 100% automático (não existe "pendente" pro user distribuir)
// - Dia 05: BAU mensal (CT pro + CT base) + premios de competicoes
// - User distribui BAU manualmente com custo progressivo

import 'package:flutter/material.dart';

import '../../models/jogador.dart';
import '../../services/world/game_state.dart';
import '../../services/club_squad_service.dart';
import '../../services/evolucao/evolucao_service.dart';

class EvolucaoPage extends StatefulWidget {
  const EvolucaoPage({super.key});

  @override
  State<EvolucaoPage> createState() => _EvolucaoPageState();
}

class _EvolucaoPageState extends State<EvolucaoPage> {
  String get _clubId => GameState.I.userClubId;

  List<Jogador> get _pro => ClubSquadService.I.getProSquad(_clubId);
  List<Jogador> get _base => ClubSquadService.I.getBaseSquad(_clubId);

  @override
  Widget build(BuildContext context) {
    final bau = GameState.I.bauEvolucaoPontos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolucao'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _topCard(context, bau),
          const SizedBox(height: 12),
          _sectionTitle('Elenco PRO'),
          _playersList(_pro),
          const SizedBox(height: 12),
          _sectionTitle('Base'),
          _playersList(_base),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _topCard(BuildContext context, int bau) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Janeiro: evolucao/regressao AUTOMATICA (por idade e funcao).',
            style: TextStyle(fontSize: 12, height: 1.25),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dia 05: voce recebe pontos no BAU (CT + Base).',
            style: TextStyle(fontSize: 12, height: 1.25),
          ),
          const SizedBox(height: 6),
          const Text(
            'BAU: voce distribui manualmente (custo progressivo).',
            style: TextStyle(fontSize: 12, height: 1.25),
          ),
          const SizedBox(height: 4),
          const Text(
            'Custos: 6->7 = 1 | 7->8 = 2 | 8->9 = 3 | 9->10 = 5',
            style: TextStyle(fontSize: 12, height: 1.25),
          ),
          const SizedBox(height: 8),
          Text(
            'BAU atual: $bau',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 6),
        child: Text(
          t,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      );

  Widget _playersList(List<Jogador> list) {
    if (list.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Sem jogadores.'),
        ),
      );
    }

    return Card(
      child: Column(
        children: list.map(_playerTile).toList(),
      ),
    );
  }

  Widget _playerTile(Jogador j) {
    return ListTile(
      title: Text('${j.nome} (${j.idade})'),
      subtitle: Text('Pos: ${j.posDet}'),
      trailing: const Icon(Icons.tune),
      onTap: () => _openPlayerEvo(j),
    );
  }

  void _openPlayerEvo(Jogador jogadorInicial) {
    Jogador current = jogadorInicial;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final attrs = _attrsOf(current);
            final keys = _resolveKeys(current, attrs);

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: 12 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pos: ${current.posDet} (${current.pos}) - Idade: ${current.idade}',
                    ),
                    const SizedBox(height: 6),
                    Text('BAU do clube: ${GameState.I.bauEvolucaoPontos}'),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: keys.length,
                        itemBuilder: (_, i) {
                          final k = keys[i];
                          final v = (attrs[k] ?? 1).clamp(1, 10);

                          final cost = EvolucaoService.I.custoParaUpar(v);
                          final canUpFromBau =
                              GameState.I.bauEvolucaoPontos >= cost && v < 10;

                          final bauLabel = canUpFromBau
                              ? 'Upar (BAU) custo $cost'
                              : 'Upar (BAU) custo $cost (sem pontos)';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_prettyKey(k)}: $v',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                PopupMenuButton(
                                  tooltip: 'Upar',
                                  onSelected: (sel) {
                                    final selStr = sel.toString();
                                    if (selStr != 'bau') return;
                                    if (!canUpFromBau) return;

                                    final updated = EvolucaoService.I
                                        .withAttrDelta(current, k, 1);

                                    EvolucaoService.I.replaceInSquads(
                                      clubId: _clubId,
                                      updated: updated,
                                    );

                                    GameState.I.bauEvolucaoPontos -= cost;

                                    current = updated;

                                    setState(() {});
                                    setModal(() {});
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'bau',
                                      enabled: canUpFromBau,
                                      child: Text(bauLabel),
                                    ),
                                  ],
                                  child: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Fechar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _resolveKeys(Jogador j, Map<String, int> attrs) {
    try {
      final dyn = j as dynamic;
      final v = dyn.coreKeys;
      if (v is List) {
        final out = <String>[];
        for (final e in v) {
          out.add(e.toString());
        }
        if (out.isNotEmpty) return out;
      }
    } catch (_) {}

    final out = attrs.keys.toList();
    out.sort();
    return out;
  }

  Map<String, int> _attrsOf(Jogador j) {
    try {
      final v = (j as dynamic).atributos;
      if (v is Map<String, int>) return Map<String, int>.from(v);
      if (v is Map) {
        return v.map((k, val) => MapEntry(k.toString(), (val as num).toInt()));
      }
    } catch (_) {}
    return <String, int>{};
  }

  String _prettyKey(String k) {
    final s = k.replaceAll('_', ' ');
    if (s.isEmpty) return k;
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }
}
