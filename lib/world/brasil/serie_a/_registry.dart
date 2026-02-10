// lib/world/brasil/serie_a/_registry.dart

/// Cada entry do mapa: "slug-do-time" -> função que retorna lista de IDs de jogadores.
/// Ex.: "rubro-rio": () => ["rr_gk_1", "rr_cb_1", ...]
typedef RosterGetter = List<String> Function();

final Map<String, RosterGetter> rostersSerieA2025 = <String, RosterGetter>{
  // Exemplos (preencha com seus times reais e IDs do players.dart):
  'rubro-rio': () => <String>[],
  'inter-sul': () => <String>[],
  'gremio-sul': () => <String>[],
  'verde-oeste': () => <String>[],
  'praia-leste': () => <String>[],
  'tricolor-sp': () => <String>[],
  'parque-leste': () => <String>[],
  'minas-atletico': () => <String>[],
};
