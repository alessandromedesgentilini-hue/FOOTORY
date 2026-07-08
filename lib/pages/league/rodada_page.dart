// lib/pages/league/rodada_page.dart
//
// RodadaPage – lista os confrontos da rodada atual e permite simular a rodada.
// Integra com GameState.I (fixtures, rodadaAtual, simularRodada) e abre a TabelaPage.
//
// Dependências esperadas no projeto:
// - lib/services/world/game_state.dart (GameState.I)
// - lib/pages/league/tabela_page.dart (sua TabelaPage robusta)

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';
import 'tabela_page.dart';

class RodadaPage extends StatefulWidget {
  final String titulo;
  const RodadaPage({super.key, this.titulo = 'Rodada'});

  @override
  State<RodadaPage> createState() => _RodadaPageState();
}

class _RodadaPageState extends State<RodadaPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;
    final fixtures = gs.fixtures;
    final totalRounds = fixtures.length;
    final rodada = gs.rodadaAtual.clamp(1, totalRounds);
    final idx = rodada - 1;

    final isSeasonOver = rodada > totalRounds;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.titulo} — ${isSeasonOver ? 'Encerrada' : 'R$rodada/$totalRounds'}'),
        actions: [
          IconButton(
            tooltip: 'Ver Tabela',
            icon: const Icon(Icons.table_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const TabelaPage(titulo: 'Tabela — Série')),
              );
            },
          ),
        ],
      ),
      body: isSeasonOver
          ? _buildSeasonOver(context)
          : _buildRoundList(context, idx),
      floatingActionButton: isSeasonOver
          ? null
          : FloatingActionButton.extended(
              onPressed: _loading ? null : _simulateRound,
              label: Text(_loading ? 'Simulando…' : 'Simular rodada'),
              icon: const Icon(Icons.sports_soccer),
            ),
    );
  }

  Widget _buildRoundList(BuildContext context, int roundIndex) {
    final gs = GameState.I;
    final rf = gs.fixtures[roundIndex];

    if (rf.matches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Nenhuma partida nesta rodada.'),
        ),
      );
    }

    return ListView.separated(
      itemCount: rf.matches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final m = rf.matches[i];
        final home = gs.clubName(m.homeId);
        final away = gs.clubName(m.awayId);
        final isUserGame =
            m.homeId == gs.userClubId || m.awayId == gs.userClubId;

        return ListTile(
          leading: CircleAvatar(
            child: Text('${i + 1}'),
          ),
          title: Text(
            '$home  x  $away',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: isUserGame ? const Text('Seu jogo') : const Text('—'),
          trailing: const Icon(Icons.sports_soccer),
        );
      },
    );
  }

  Widget _buildSeasonOver(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Temporada encerrada!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Confira a classificação final na Tabela.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          const TabelaPage(titulo: 'Tabela — Final')),
                );
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('Abrir Tabela'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateRound() async {
    setState(() => _loading = true);
    try {
      await GameState.I.simularRodada();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rodada simulada! Tabela atualizada.')),
      );
      setState(() {}); // atualiza rodada/tabela na tela
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao simular: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
