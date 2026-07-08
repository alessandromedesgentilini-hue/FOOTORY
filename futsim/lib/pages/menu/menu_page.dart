import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final gs = GameState.I;

  @override
  Widget build(BuildContext context) {
    final temComp = gs.temCompeticao;
    final rodada = gs.rodadaAtual; // 0..total
    final total = gs.totalRodadas; // 14 no seed
    final terminou = temComp && rodada >= total;

    String labelSimular() {
      if (!temComp) return 'Simular rodada';
      if (terminou) return 'Temporada concluída';
      final proxima = (rodada + 1).clamp(1, total);
      return 'Simular rodada $proxima / $total';
    }

    final tabela = gs.tabela();

    return Scaffold(
      appBar: AppBar(title: const Text('FUTSIM – Menu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(spacing: 12, runSpacing: 12, children: [
              ElevatedButton(
                onPressed: () {
                  gs.seedSerieA();
                  setState(() {});
                },
                child: const Text('Criar Série A (seed)'),
              ),
              ElevatedButton(
                onPressed: (temComp && !terminou)
                    ? () {
                        gs.simularProximaRodada();
                        setState(() {});
                      }
                    : null,
                child: Text(labelSimular()),
              ),
            ]),
            const SizedBox(height: 24),
            if (temComp) ...[
              Text(
                terminou
                    ? 'Rodadas concluídas: $rodada / $total  •  ✅ Temporada concluída'
                    : 'Rodadas concluídas: $rodada / $total',
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: tabela.length,
                itemBuilder: (context, i) {
                  final r = tabela[i];
                  return ListTile(
                    leading: Text('${r.pos}'),
                    title: Text(r.time.nome),
                    subtitle: Text(
                        'J:${r.j}  V:${r.v}  E:${r.e}  D:${r.d}  GP:${r.gp}  GC:${r.gc}'),
                    trailing: Text('${r.pts} pts  SG:${r.saldo}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
