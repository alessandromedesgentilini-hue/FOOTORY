import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/pages/my_club/player_details_page.dart';
import 'package:footory26/pages/my_club/player_ui_helpers.dart';
import 'package:footory26/pages/my_club/widgets/player_shared_widgets.dart';

class SquadList extends StatelessWidget {
  final List<Player> players;

  const SquadList({
    super.key,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    if (players.isEmpty) {
      return Text(
        'Elenco vazio.',
        style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      children: List.generate(players.length, (i) {
        final p = players[i];

        return Padding(
          padding: EdgeInsets.only(bottom: i == players.length - 1 ? 0 : 10),
          child: PlayerRow(player: p),
        );
      }),
    );
  }
}

class PlayerRow extends StatelessWidget {
  final Player player;

  const PlayerRow({
    super.key,
    required this.player,
  });

  Color _ovrColor(int value) {
    if (value >= 80) return AppColors.success;
    if (value >= 70) return AppColors.primary;
    if (value >= 60) return AppColors.accentDark;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ovr = player.ovrCheio;
    final color = _ovrColor(ovr);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlayerDetailsPage(player: player),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlayerFaceAvatar(
                assetPath: player.faceAsset,
                size: 68,
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlagNameLine(
                      countryCode: player.nacionalidade,
                      name: player.nome,
                      centered: false,
                      flagSize: 16,
                      textStyle: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${posLabel(player.posDet)} • ${player.idade} anos • Pé ${player.pe}',
                      style: t.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Stars5(
                      filled: player.stars5,
                      size: 16,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        MiniStatChip(label: 'J', value: player.temporadaJogos),
                        MiniStatChip(label: 'G', value: player.temporadaGols),
                        MiniStatChip(
                          label: 'A',
                          value: player.temporadaAssistencias,
                        ),
                        MiniStatChip(
                          label: 'D',
                          value: player.temporadaDestaques,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'OVR $ovr',
                  style: t.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
