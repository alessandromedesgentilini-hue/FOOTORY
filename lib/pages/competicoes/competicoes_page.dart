// lib/pages/competicoes/competicoes_page.dart
//
// COMPETIÇÕES (MVP)
// - Cabeçalho com divisão/ano/rodada
// - Próxima partida do usuário
// - Última partida do usuário (sem placar, pois o GameState não guarda gols ainda)
// - Tabela completa

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';

class CompeticoesPage extends StatelessWidget {
  const CompeticoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final gs = GameState.I;
    final tabela = gs.tabela ?? const <Map<String, dynamic>>[];

    final prox = gs.proximaPartidaUsuarioInfo;
    final last = gs.lastUserMatch;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Competições'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _card(
            cs,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liga do Brasil • Série ${gs.divisionId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  gs.dataStr,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // =========================
          // Próxima partida (novo formato: home/away)
          // =========================
          if (prox != null) ...[
            _card(
              cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Próxima partida',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Builder(builder: (_) {
                    final homeId = (prox['homeId'] as String?) ?? '';
                    final awayId = (prox['awayId'] as String?) ?? '';
                    final homeNome = (prox['homeNome'] as String?) ?? 'Casa';
                    final awayNome = (prox['awayNome'] as String?) ?? 'Fora';
                    final rodada = prox['rodada'] ?? '-';

                    final mandante = homeId == gs.userClubId;
                    final left = mandante ? gs.userClubName : homeNome;
                    final right = mandante ? awayNome : gs.userClubName;

                    return _matchLine(
                      cs: cs,
                      left: left,
                      right: right,
                      subtitle: 'Rodada $rodada',
                      pill: mandante ? 'CASA' : 'FORA',
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // =========================
          // Última partida (novo formato: home/away) — sem placar por enquanto
          // =========================
          if (last != null) ...[
            _card(
              cs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Última partida',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Builder(builder: (_) {
                    final homeId = (last['homeId'] as String?) ?? '';
                    final awayId = (last['awayId'] as String?) ?? '';
                    final homeNome = (last['homeNome'] as String?) ?? 'Casa';
                    final awayNome = (last['awayNome'] as String?) ?? 'Fora';
                    final rodada = last['rodada'] ?? '-';

                    final mandante = homeId == gs.userClubId;
                    final left = mandante ? gs.userClubName : homeNome;
                    final right = mandante ? awayNome : gs.userClubName;

                    return _matchLine(
                      cs: cs,
                      left: left,
                      right: right,
                      subtitle: 'Rodada $rodada',
                      pill: mandante ? 'CASA' : 'FORA',
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // =========================
          // Tabela
          // =========================
          _card(
            cs,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tabela',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _tableHeader(cs),
                const SizedBox(height: 6),
                for (var i = 0; i < tabela.length; i++)
                  _tableRow(
                    cs: cs,
                    pos: i + 1,
                    row: tabela[i],
                    highlight: (tabela[i]['timeNome'] == gs.userClubName),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(ColorScheme cs, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: child,
    );
  }

  Widget _matchLine({
    required ColorScheme cs,
    required String left,
    required String right,
    required String subtitle,
    String? pill,
    String? score,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: const TextStyle(fontWeight: FontWeight.w900),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (score != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              score,
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        else if (pill != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              pill,
              style: TextStyle(
                color: cs.onSecondaryContainer,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w900),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(ColorScheme cs) {
    final t = TextStyle(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w900,
      fontSize: 12,
    );

    return Row(
      children: [
        SizedBox(width: 28, child: Text('#', style: t)),
        const SizedBox(width: 6),
        Expanded(child: Text('Time', style: t)),
        SizedBox(
            width: 28, child: Text('P', style: t, textAlign: TextAlign.right)),
        const SizedBox(width: 10),
        SizedBox(
            width: 28, child: Text('J', style: t, textAlign: TextAlign.right)),
        const SizedBox(width: 10),
        SizedBox(
            width: 28, child: Text('V', style: t, textAlign: TextAlign.right)),
        const SizedBox(width: 10),
        SizedBox(
            width: 28, child: Text('E', style: t, textAlign: TextAlign.right)),
        const SizedBox(width: 10),
        SizedBox(
            width: 28, child: Text('D', style: t, textAlign: TextAlign.right)),
        const SizedBox(width: 10),
        SizedBox(
            width: 34, child: Text('SG', style: t, textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _tableRow({
    required ColorScheme cs,
    required int pos,
    required Map<String, dynamic> row,
    required bool highlight,
  }) {
    final time = (row['timeNome'] ?? '-') as String;

    final pts = row['pts'] ?? 0;
    final j = row['j'] ?? 0;
    final v = row['v'] ?? 0;
    final e = row['e'] ?? 0;
    final d = row['d'] ?? 0;
    final sg = row['saldo'] ?? 0;

    final bg = highlight ? cs.primaryContainer : cs.surface;
    final fg = highlight ? cs.onPrimaryContainer : cs.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$pos',
              style: TextStyle(fontWeight: FontWeight.w900, color: fg),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              time,
              style: TextStyle(fontWeight: FontWeight.w900, color: fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$pts',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w900, color: fg),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '$j',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w800, color: fg),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '$v',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w800, color: fg),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '$e',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w800, color: fg),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '$d',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w800, color: fg),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 34,
            child: Text(
              '$sg',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w800, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
