import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/providers.dart';
import 'package:footory26/services/team_power_service.dart';
import 'package:footory26/services/world/game_state.dart';

class ClubPage extends ConsumerWidget {
  const ClubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState gs = ref.watch(gameStateProvider);

    final pro = gs.getProSquad();
    final snap = gs.expectations;

    // ✅ Força REAL do humano: média do elenco (dinâmica)
    final tp = const TeamPowerService();
    final userSnap = tp.snapshotFromSquad(pro);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Clube'),
        // OBS: se esta página foi aberta com Navigator.push(),
        // a setinha aparece automaticamente. Mas deixar assim é ok.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gs.userClubName.isEmpty ? 'Meu Clube' : gs.userClubName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Divisão: ${gs.divisionId}'),
                  const SizedBox(height: 4),
                  Text('Data: ${gs.dateStr}'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Força do Clube',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 10),
                      _StarsRow(stars5: userSnap.stars5),
                      const Spacer(),
                      Text(
                        userSnap.label10,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _kv('Expectativa da Temporada', snap?.expectedLabel ?? '-'),
                  _kv('Situação Atual', snap?.statusLabel ?? '-'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text(
                    'Elenco Profissional',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text('${pro.length} jogadores'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (pro.isEmpty)
            const Center(child: Text('Sem elenco carregado.'))
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pro.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = pro[i];

                  final nome = p.nome;
                  final idade = p.idade;
                  final pos = p.posDet.name.toUpperCase();
                  final ovr = p.ovrCheio; // 10..100

                  final rating10 = tp.playerRating10(p);
                  final stars10 = tp.stars10FromRating(rating10);
                  final stars5 = tp.stars5FromStars10(stars10);

                  return ListTile(
                    dense: true,
                    title: Text(nome),
                    subtitle: Text('$pos • Idade: $idade'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'OVR $ovr',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        _StarsRow(stars5: stars5),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(
              k,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final int stars5; // 0..5
  const _StarsRow({required this.stars5});

  @override
  Widget build(BuildContext context) {
    final s = stars5.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < s;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 18,
        );
      }),
    );
  }
}
