// lib/repo/seed_repo.dart
//
// SeedRepo (VERSÃO FINAL ROBUSTA)
// - Lê seeds da Série A (jogadores e rosters por clube) com tolerância de tipo:
//   * playersBRSerieA2025 pode ser Map<String, Jogador> **ou** função que retorna isso
//     (ou até List<Jogador>); convertemos para Map com chaves estáveis.
//   * rostersSerieA2025 pode mapear slug -> List<String> **ou** slug -> Function() -> List<String>.
// - Fornece utilitários convenientes: listagem de slugs e verificação de disponibilidade.
// - Nunca lança: sempre retorna estruturas vazias em caso de erro.
// - Mantém compat com SaveState.fromSeeds(Map<String, List<String>>).

import '../models/jogador.dart';
import 'save_state.dart';

// Ajuste os caminhos conforme seu projeto (mantendo relativo a /lib/repo):
import '../world/brasil/serie_a/players.dart' show playersBRSerieA2025;
import '../world/brasil/serie_a/_registry.dart' show rostersSerieA2025;

typedef TeamSlug = String;
typedef PlayerId = String;

class SeedRepo {
  /// Carrega o catálogo de jogadores da Série A.
  /// Tolerante aos formatos mais comuns do arquivo de seeds.
  Map<String, Jogador> loadPlayersSerieA() {
    try {
      final dynamic raw = (playersBRSerieA2025 is Function)
          ? playersBRSerieA2025()
          : playersBRSerieA2025;

      // Map<String, Jogador>
      if (raw is Map) {
        final out = <String, Jogador>{};
        raw.forEach((k, v) {
          final key = k?.toString() ?? '';
          if (key.isEmpty) return;
          if (v is Jogador) {
            out[key] = v;
          }
        });
        return out;
      }

      // List<Jogador>
      if (raw is Iterable) {
        final out = <String, Jogador>{};
        var idx = 0;
        for (final e in raw) {
          if (e is! Jogador) continue;
          final base = (e.id.isNotEmpty ? e.id : 'player_$idx');
          var key = base;
          var suf = 1;
          while (out.containsKey(key)) {
            key = '${base}_${suf++}';
          }
          out[key] = e;
          idx++;
        }
        return out;
      }
    } catch (_) {
      // cai para retorno vazio
    }
    return const <String, Jogador>{};
  }

  /// Carrega a lista de playerIds para um clube (slug) específico.
  /// Retorna lista vazia se o slug não existir ou em caso de erro.
  List<PlayerId> loadRosterSerieA(TeamSlug slug) {
    try {
      final dynamic getterOrList = rostersSerieA2025[slug];
      if (getterOrList == null) return const <PlayerId>[];

      final dynamic raw =
          (getterOrList is Function) ? getterOrList() : getterOrList;

      return _toPlayerIdList(raw);
    } catch (_) {
      return const <PlayerId>[];
    }
  }

  /// Cria o SaveState inicial da Série A a partir do registry de rosters.
  SaveState createInitialSaveSerieA() {
    final map = <TeamSlug, List<PlayerId>>{};
    try {
      rostersSerieA2025.forEach((dynamic k, dynamic v) {
        final slug = k?.toString() ?? '';
        if (slug.isEmpty) return;

        final dynamic raw = (v is Function) ? v() : v;
        map[slug] = _toPlayerIdList(raw);
      });
    } catch (_) {
      // se algo falhar, devolve o que tiver sido montado até aqui (ou vazio)
    }
    return SaveState.fromSeeds(map);
  }

  /// Lista de slugs disponíveis no registry da Série A (ordenada).
  List<TeamSlug> clubSlugsSerieA() {
    try {
      final ls = rostersSerieA2025.keys.map((e) => e.toString()).toList();
      ls.sort();
      return ls;
    } catch (_) {
      return const <TeamSlug>[];
    }
  }

  /// Indica se há dados de Série A disponíveis (players e/ou rosters).
  bool get hasSerieAData {
    final hasRosters = () {
      try {
        return rostersSerieA2025.isNotEmpty;
      } catch (_) {
        return false;
      }
    }();
    final hasPlayers = () {
      try {
        final dynamic raw = (playersBRSerieA2025 is Function)
            ? playersBRSerieA2025()
            : playersBRSerieA2025;
        return raw is Map || raw is Iterable;
      } catch (_) {
        return false;
      }
    }();
    return hasRosters || hasPlayers;
  }

  // ────────────────────────────── internals ──────────────────────────────

  List<PlayerId> _toPlayerIdList(dynamic raw) {
    if (raw is Iterable) {
      final out = <PlayerId>[];
      final seen = <PlayerId>{};
      for (final e in raw) {
        final s = e?.toString().trim() ?? '';
        if (s.isEmpty) continue;
        if (seen.add(s)) out.add(s);
      }
      return out;
    }
    if (raw is Map) {
      // Caso raro: veio como mapa indexado {0:'p1',1:'p2'...}
      final values = raw.values;
      return _toPlayerIdList(values);
    }
    return const <PlayerId>[];
  }
}
