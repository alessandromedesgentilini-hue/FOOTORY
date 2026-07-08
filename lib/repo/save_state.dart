// lib/repo/save_state.dart
//
// Estado inicial salvo a partir dos seeds (rosters por time) — VERSÃO FINAL
// - Imutável (deep-unmodifiable): nem o mapa nem as listas internas podem ser
//   mutadas de fora.
// - Robustez na desserialização (fromJson tolerante a formatos).
// - Helpers de uso comum: empty, copyWith, withUpdatedRoster, merge,
//   rosterFor, teams, contains.
// - Igualdade profunda e hashCode consistente (útil para testes).
//
// Mantém compat com o shape antigo: Map<String, List<String>> rostersByTeam.

import 'dart:collection';

typedef TeamId = String;
typedef PlayerId = String;

class SaveState {
  /// Mapa imutável: teamId -> lista imutável de playerIds
  final Map<TeamId, List<PlayerId>> rostersByTeam;

  /// Construtor interno que aplica deep-unmodifiable.
  const SaveState._internal(this.rostersByTeam);

  /// Cria um estado vazio.
  factory SaveState.empty() => const SaveState._internal(const {});

  /// Constrói a partir dos seeds (já em memória), aplicando deep-unmodifiable.
  factory SaveState.fromSeeds(Map<TeamId, List<PlayerId>> seeds) {
    return SaveState._internal(_deepUnmodifiable(seeds));
  }

  /// Serialização simples.
  Map<String, dynamic> toJson() => {
        'rostersByTeam': rostersByTeam,
      };

  /// Desserialização tolerante:
  /// - Aceita valores como List ou Iterable;
  /// - Coage cada item para String (via toString) e filtra vazios;
  /// - Gera estrutura deep-unmodifiable.
  static SaveState fromJson(Map<String, dynamic> json) {
    final raw = json['rostersByTeam'];

    if (raw is! Map) {
      // Fallback seguro
      return SaveState.empty();
    }

    final out = <TeamId, List<PlayerId>>{};
    raw.forEach((k, v) {
      final team = k?.toString() ?? '';
      if (team.isEmpty) return;

      Iterable<dynamic> it;
      if (v is Iterable) {
        it = v;
      } else if (v is Map) {
        // Caso inesperado: valores vieram como mapa (ex.: {0: 'p1', 1: 'p2'})
        it = v.values;
      } else {
        it = const [];
      }

      final players = <PlayerId>[];
      final seen = <PlayerId>{};
      for (final e in it) {
        final s = e?.toString().trim() ?? '';
        if (s.isEmpty) continue;
        if (seen.add(s)) players.add(s); // dedup preservando ordem
      }
      out[team] = players;
    });

    return SaveState._internal(_deepUnmodifiable(out));
  }

  // ===== Helpers de leitura =====

  /// Lista imutável de ids de times.
  List<TeamId> get teams => UnmodifiableListView(rostersByTeam.keys);

  /// Retorna a lista (imutável) de jogadores de um time. Vazio se inexistente.
  List<PlayerId> rosterFor(TeamId team) =>
      rostersByTeam[team] ?? const <PlayerId>[];

  bool containsTeam(TeamId team) => rostersByTeam.containsKey(team);

  bool containsPlayer(TeamId team, PlayerId player) =>
      rostersByTeam[team]?.contains(player) ?? false;

  // ===== Helpers de escrita (imutáveis) =====

  /// Retorna um novo SaveState substituindo o roster do [team].
  SaveState withUpdatedRoster(TeamId team, List<PlayerId> players) {
    final sanitized = _sanitizeIds(players);
    final next = Map<TeamId, List<PlayerId>>.from(rostersByTeam)
      ..[team] = sanitized;
    return SaveState._internal(_deepUnmodifiable(next));
  }

  /// Merge com outro estado.
  /// - Se [override] = true (default), o roster do [other] substitui o atual;
  /// - Se false, faz união preservando a ordem do atual e adicionando novos do other.
  SaveState merge(SaveState other, {bool override = true}) {
    final next = <TeamId, List<PlayerId>>{};
    // base = atual
    rostersByTeam.forEach((t, list) {
      next[t] = List<PlayerId>.from(list);
    });
    // aplica other
    other.rostersByTeam.forEach((t, list) {
      if (override || !next.containsKey(t)) {
        next[t] = List<PlayerId>.from(list);
      } else {
        // união preservando ordem e sem duplicatas
        final cur = next[t]!;
        final seen = cur.toSet();
        for (final p in list) {
          if (seen.add(p)) cur.add(p);
        }
      }
    });
    return SaveState._internal(_deepUnmodifiable(next));
  }

  /// copyWith completo (substitui o mapa inteiro, se fornecido).
  SaveState copyWith({Map<TeamId, List<PlayerId>>? rostersByTeam}) {
    if (rostersByTeam == null) return this;
    return SaveState._internal(_deepUnmodifiable(rostersByTeam));
  }

  // ===== Igualdade / hash / debug =====

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SaveState) return false;
    final a = rostersByTeam, b = other.rostersByTeam;
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      final va = a[k], vb = b[k];
      if (vb == null) return false;
      if (va!.length != vb.length) return false;
      for (var i = 0; i < va.length; i++) {
        if (va[i] != vb[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    // Hash profundo (ordem relevante)
    final parts = <Object>[];
    rostersByTeam.forEach((k, v) {
      parts.add(k);
      parts.addAll(v);
    });
    return Object.hashAll(parts);
  }

  @override
  String toString() => 'SaveState(teams: ${rostersByTeam.keys.length})';

  // ===== Internos =====

  static Map<TeamId, List<PlayerId>> _deepUnmodifiable(
      Map<TeamId, List<PlayerId>> src) {
    final frozen = <TeamId, List<PlayerId>>{
      for (final e in src.entries) e.key: List<PlayerId>.unmodifiable(e.value),
    };
    return UnmodifiableMapView(frozen);
  }

  static List<PlayerId> _sanitizeIds(Iterable<dynamic> ids) {
    final out = <PlayerId>[];
    final seen = <PlayerId>{};
    for (final e in ids) {
      final s = e?.toString().trim() ?? '';
      if (s.isEmpty) continue;
      if (seen.add(s)) out.add(s);
    }
    return List<PlayerId>.unmodifiable(out);
  }
}
