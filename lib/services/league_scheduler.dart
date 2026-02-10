// lib/services/league_scheduler.dart
//
// Gera calendário de pontos corridos **duplo turno** (ida e volta)
// usando o "circle method" clássico de round-robin.
//
// Características:
// - Exige número PAR de clubes (ex.: 20).
// - Usa SeededRng para embaralhar a ordem inicial (varia o calendário).
// - Cada time enfrenta TODOS os outros 2x (casa/fora).
// - Evita padrão de pegar sempre o mesmo adversário.
//

import '../core/seeded_rng.dart';
import '../models/fixture.dart';

class LeagueScheduler {
  /// Gera calendário de pontos corridos **duplo turno**.
  /// [clubIds] precisa ter quantidade PAR (ex.: 20).
  /// Retorna uma lista de [RoundFixtures], rounds = (clubIds.length - 1) * 2.
  static List<RoundFixtures> generateDoubleRoundRobin({
    required List<String> clubIds,
    required int seed,
  }) {
    if (clubIds.isEmpty) {
      return [];
    }

    // Remove duplicados, se houver (dup aqui quebra o algoritmo).
    final seen = <String>{};
    final ids = <String>[];
    for (final id in clubIds) {
      if (id.trim().isEmpty) continue;
      if (seen.add(id)) ids.add(id);
    }

    if (ids.length.isOdd) {
      throw ArgumentError(
          'Número de clubes deve ser par. Recebidos: ${ids.length}');
    }
    if (ids.length < 2) {
      return [];
    }

    // Embaralha ordem inicial para variar o calendário.
    final rnd = SeededRng(seed);
    for (int i = ids.length - 1; i > 0; i--) {
      final j = rnd.intInRange(0, i);
      final tmp = ids[i];
      ids[i] = ids[j];
      ids[j] = tmp;
    }

    final n = ids.length;
    final roundsCount = n - 1;

    // "circle method":
    // - fixa o primeiro
    // - rotaciona os demais em círculo
    final fixed = ids.first;
    final rot = ids.sublist(1); // tamanho n-1

    final roundsOne = <RoundFixtures>[];

    for (int r = 0; r < roundsCount; r++) {
      // monta a linha da rodada: [fixed, ...rot]
      final line = <String>[fixed, ...rot];
      final matches = <MatchFixture>[];

      final half = n ~/ 2;
      for (int i = 0; i < half; i++) {
        final a = line[i];
        final b = line[n - 1 - i];

        // alterna mando por rodada + índice para quebrar padrões
        final swap = ((r + i) % 2 == 1);
        final home = swap ? b : a;
        final away = swap ? a : b;

        matches.add(
          MatchFixture(
            homeId: home,
            awayId: away,
            round: r + 1,
          ),
        );
      }

      roundsOne.add(
        RoundFixtures(
          round: r + 1,
          matches: matches,
        ),
      );

      // Rotação: pega o último de rot e coloca na frente
      if (rot.length > 1) {
        final last = rot.removeLast();
        rot.insert(0, last);
      }
    }

    // Segundo turno: inverte mandos e soma rounds
    final roundsTwo = <RoundFixtures>[];
    for (final rf in roundsOne) {
      final newRound = rf.round + roundsCount;
      final m2 = <MatchFixture>[];

      for (final m in rf.matches) {
        m2.add(
          MatchFixture(
            homeId: m.awayId,
            awayId: m.homeId,
            round: newRound,
          ),
        );
      }

      roundsTwo.add(
        RoundFixtures(
          round: newRound,
          matches: m2,
        ),
      );
    }

    return [...roundsOne, ...roundsTwo];
  }
}
