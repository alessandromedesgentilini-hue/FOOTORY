import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/models/scout/scout_target.dart';

class ScoutService {
  final SeededRng rng;

  ScoutService(this.rng);

  /// TABELA DEFINITIVA A–E (OVR = soma 10..100)
  /// E: até 45
  /// D: 46–55
  /// C: 56–65
  /// B: 66–75
  /// A: 76+
  String realQualityFromOvr(int ovr) {
    if (ovr >= 76) return 'A';
    if (ovr >= 66) return 'B';
    if (ovr >= 56) return 'C';
    if (ovr >= 46) return 'D';
    return 'E';
  }

  /// Aplica imprecisão conforme scoutLevel (1..5).
  /// Ruim tende a errar pra baixo (piora), raramente pra cima.
  String estimatedQuality({
    required int ovrReal,
    required int scoutLevel,
  }) {
    final real = realQualityFromOvr(ovrReal);
    final idxReal = _idxFromLetter(real);

    int error;

    switch (scoutLevel.clamp(1, 5)) {
      case 5:
        error = _weightedChoice([
          (0, 85),
          (1, 15),
        ]);
        break;
      case 4:
        error = _weightedChoice([
          (0, 70),
          (1, 25),
          (-1, 5),
        ]);
        break;
      case 3:
        error = _weightedChoice([
          (0, 55),
          (1, 30),
          (2, 10),
          (-1, 5),
        ]);
        break;
      case 2:
        error = _weightedChoice([
          (1, 45),
          (2, 30),
          (0, 20),
          (-1, 5),
        ]);
        break;
      default:
        error = _weightedChoice([
          (2, 45),
          (1, 35),
          (3, 15),
          (0, 5),
        ]);
        break;
    }

    final idxEst = (idxReal + error).clamp(0, 4);
    return _letterFromIdx(idxEst);
  }

  /// Escolhe jogadores do pool considerando "capacidade de achar" (scoutLevel).
  /// Melhor scout = mais chance de puxar C/B/A.
  List<Player> pickPoolByScoutLevel({
    required List<Player> source,
    required int scoutLevel,
    required int count,
  }) {
    if (source.isEmpty) return [];

    final byA = <Player>[];
    final byB = <Player>[];
    final byC = <Player>[];
    final byD = <Player>[];
    final byE = <Player>[];

    for (final p in source) {
      final q = realQualityFromOvr(p.ovrCheio);
      switch (q) {
        case 'A':
          byA.add(p);
          break;
        case 'B':
          byB.add(p);
          break;
        case 'C':
          byC.add(p);
          break;
        case 'D':
          byD.add(p);
          break;
        default:
          byE.add(p);
      }
    }

    List<(List<Player>, int)> weights;

    switch (scoutLevel.clamp(1, 5)) {
      case 5:
        weights = [
          (byA, 30),
          (byB, 30),
          (byC, 25),
          (byD, 12),
          (byE, 3),
        ];
        break;
      case 4:
        weights = [
          (byA, 18),
          (byB, 28),
          (byC, 30),
          (byD, 18),
          (byE, 6),
        ];
        break;
      case 3:
        weights = [
          (byA, 8),
          (byB, 18),
          (byC, 32),
          (byD, 28),
          (byE, 14),
        ];
        break;
      case 2:
        weights = [
          (byA, 3),
          (byB, 10),
          (byC, 22),
          (byD, 35),
          (byE, 30),
        ];
        break;
      default:
        weights = [
          (byA, 1),
          (byB, 5),
          (byC, 14),
          (byD, 35),
          (byE, 45),
        ];
        break;
    }

    final picked = <Player>[];
    final usedIds = <String>{};

    int guard = 0;
    while (picked.length < count && guard < 2000) {
      guard++;

      final bucket = _weightedBucket(weights);
      if (bucket.isEmpty) continue;

      final p = bucket[rng.nextInt(bucket.length)];
      if (usedIds.contains(p.id)) continue;

      usedIds.add(p.id);
      picked.add(p);
    }

    if (picked.length < count) {
      final shuffled = List<Player>.from(source);
      rng.shuffle(shuffled);

      for (final p in shuffled) {
        if (picked.length >= count) break;
        if (usedIds.contains(p.id)) continue;

        usedIds.add(p.id);
        picked.add(p);
      }
    }

    return picked.take(count).toList();
  }

  /// Constrói targets prontos pra UI (UI não inventa regra).
  List<ScoutTarget> buildTargets({
    required List<Player> players,
    required int scoutLevel,
    required MarketListType listType,
    required String motivo,
  }) {
    return players.map((p) {
      final qEst = estimatedQuality(
        ovrReal: p.ovrCheio,
        scoutLevel: scoutLevel,
      );

      return ScoutTarget(
        jogadorId: p.id,
        playerName: p.nome,
        posLabel: _posLabelFromPosDet(p.posDet),
        qualityLabel: qEst,
        listType: listType,
        motivo: motivo,
        faceAsset: p.faceAsset,
      );
    }).toList();
  }

  String _posLabelFromPosDet(PosDet p) {
    switch (p) {
      case PosDet.gol:
        return 'GOL';
      case PosDet.ld:
        return 'LD';
      case PosDet.le:
        return 'LE';
      case PosDet.zag:
        return 'ZAG';
      case PosDet.vol:
        return 'VOL';
      case PosDet.mc:
        return 'MC';
      case PosDet.mei:
        return 'MEI';
      case PosDet.pd:
        return 'PD';
      case PosDet.pe:
        return 'PE';
      case PosDet.ca:
        return 'CA';
    }
  }

  int _idxFromLetter(String l) {
    switch (l) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return 4;
    }
  }

  String _letterFromIdx(int idx) {
    switch (idx) {
      case 0:
        return 'A';
      case 1:
        return 'B';
      case 2:
        return 'C';
      case 3:
        return 'D';
      default:
        return 'E';
    }
  }

  int _weightedChoice(List<(int value, int w)> items) {
    final total = items.fold<int>(0, (s, e) => s + e.$2);
    final r = rng.nextInt(total);

    int acc = 0;
    for (final it in items) {
      acc += it.$2;
      if (r < acc) return it.$1;
    }

    return items.last.$1;
  }

  List<Player> _weightedBucket(List<(List<Player>, int)> weights) {
    final total = weights.fold<int>(0, (s, e) => s + e.$2);
    final r = rng.nextInt(total);

    int acc = 0;
    for (final w in weights) {
      acc += w.$2;
      if (r < acc) return w.$1;
    }

    return weights.last.$1;
  }
}
