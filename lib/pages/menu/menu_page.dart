// lib/pages/menu/menu_page.dart
//
// MenuPage – versão compatível com o novo GameState.
// Simples, estável e sem dependências antigas.

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';
import '../home/home_page.dart';
import '../league/rodada_page.dart';
import '../league/tabela_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ensureSeason();
  }

  Future<void> _ensureSeason() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final gs = GameState.I;
      final started = _hasSeasonStarted(gs);
      if (!started) {
        await gs.iniciarTemporada(divisao: gs.divisionId, seed: 1234);
      }
    } catch (e) {
      _error = 'Erro ao iniciar temporada: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _hasSeasonStarted(GameState gs) {
    try {
      final _ = gs.fixtures;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Menu')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Menu')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final totalRodadas = gs.fixtures.isNotEmpty ? gs.fixtures.length : 0;
    final rodadaAtual =
        gs.rodadaAtual.clamp(1, totalRodadas == 0 ? 1 : totalRodadas);
    final temporadaEncerrada =
        totalRodadas > 0 && gs.rodadaAtual > totalRodadas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu — FutSim'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ResumoCard(
              clube: gs.userClubName,
              divisao: gs.divisionId,
              rodada: rodadaAtual,
              totalRodadas: totalRodadas,
              temporadaEncerrada: temporadaEncerrada,
            ),
            const SizedBox(height: 16),
            _MenuButtons(
              onAbrirHome: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(),
                  ),
                );
              },
              onAbrirRodada: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RodadaPage(titulo: 'Rodada'),
                  ),
                );
              },
              onAbrirTabela: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TabelaPage(titulo: 'Tabela — Série'),
                  ),
                );
              },
              onReiniciarTemporada: () async {
                await _reiniciarTemporada();
              },
            ),
            const Spacer(),
            Text(
              'Versão MVP — Menu simplificado.\n'
              'Lógicas antigas (elencos, base etc.) foram desativadas.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reiniciarTemporada() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final gs = GameState.I;
      await gs.iniciarTemporada(
        divisao: gs.divisionId,
        seed: DateTime.now().microsecond,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Temporada reiniciada!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao reiniciar temporada: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _ResumoCard extends StatelessWidget {
  final String clube;
  final String divisao;
  final int rodada;
  final int totalRodadas;
  final bool temporadaEncerrada;

  const _ResumoCard({
    required this.clube,
    required this.divisao,
    required this.rodada,
    required this.totalRodadas,
    required this.temporadaEncerrada,
  });

  @override
  Widget build(BuildContext context) {
    final styleTitle = Theme.of(context).textTheme.titleLarge;
    final styleBody = Theme.of(context).textTheme.bodyMedium;

    String status;
    if (totalRodadas == 0) {
      status = 'Temporada ainda não iniciada.';
    } else if (temporadaEncerrada) {
      status = 'Temporada encerrada. Confira a tabela!';
    } else {
      status = 'Rodada $rodada de $totalRodadas.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clube: $clube', style: styleTitle),
          const SizedBox(height: 4),
          Text('Divisão: Série $divisao', style: styleBody),
          const SizedBox(height: 4),
          Text(status, style: styleBody),
        ],
      ),
    );
  }
}

class _MenuButtons extends StatelessWidget {
  final VoidCallback onAbrirHome;
  final VoidCallback onAbrirRodada;
  final VoidCallback onAbrirTabela;
  final VoidCallback onReiniciarTemporada;

  const _MenuButtons({
    required this.onAbrirHome,
    required this.onAbrirRodada,
    required this.onAbrirTabela,
    required this.onReiniciarTemporada,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: onAbrirHome,
          icon: const Icon(Icons.home),
          label: const Text('Home'),
        ),
        ElevatedButton.icon(
          onPressed: onAbrirRodada,
          icon: const Icon(Icons.calendar_month),
          label: const Text('Rodada'),
        ),
        ElevatedButton.icon(
          onPressed: onAbrirTabela,
          icon: const Icon(Icons.table_chart),
          label: const Text('Tabela'),
        ),
        ElevatedButton.icon(
          onPressed: onReiniciarTemporada,
          icon: const Icon(Icons.refresh),
          label: const Text('Reiniciar temporada'),
        ),
      ],
    );
  }
}
