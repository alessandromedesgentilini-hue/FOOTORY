// lib/core/atr_helpers.dart
import '../models/jogador.dart';

/// Lista oficial dos 25 atributos de linha (mesma ordem usada no jogo).
const List<String> kAllAtrKeys = [
  // Ofensivo
  Atr.finalizacao,
  Atr.chuteDeLonge,
  Atr.presencaOfensiva,
  Atr.penalti,
  Atr.drible,
  // Técnico
  Atr.dominioConducao,
  Atr.passeCurto,
  Atr.passeLongo,
  Atr.cruzamento,
  Atr.bolaParada,
  // Defensivo
  Atr.marcacao,
  Atr.coberturaDefensiva,
  Atr.desarme,
  Atr.antecipacao,
  Atr.jogoAereo,
  // Mental
  Atr.tomadaDecisao,
  Atr.frieza,
  Atr.capacidadeTatica,
  Atr.consistencia,
  Atr.resiliencia,
  Atr.espiritoProtagonista,
  // Físico
  Atr.velocidade,
  Atr.resistencia,
  Atr.potencia,
  Atr.composicaoNatural,
  Atr.coordenacaoMotora,
];

/// Set para contains O(1)
final Set<String> _allAtrKeySet = Set.unmodifiable(kAllAtrKeys);

/// Clampa para 1..10 e garante int.
int _c(int v) {
  if (v < 1) return 1;
  if (v > 10) return 10;
  return v;
}

/// Preenche TODOS os 25 atributos com `fill` e aplica `overrides` por cima.
/// - `fill` é clampado para 1..10.
/// - chaves desconhecidas em `overrides` são ignoradas com segurança.
Map<String, int> fillAllAtributos({
  int fill = 1,
  Map<String, int> overrides = const {},
}) {
  final f = _c(fill);
  final m = <String, int>{for (final k in kAllAtrKeys) k: f};

  if (overrides.isNotEmpty) {
    overrides.forEach((k, v) {
      if (_allAtrKeySet.contains(k)) m[k] = _c(v);
    });
  }
  return m;
}

/// Monta atributos “de linha” considerando a POSIÇÃO atual.
/// MVP: usa todos 25 com `fill` (default 1) + `overrides`.
/// No futuro dá para plugar templates por posição aqui sem quebrar nada.
Map<String, int> buildAtributosPara(
  Posicao pos, {
  int fill = 1,
  Map<String, int> overrides = const {},
}) {
  return fillAllAtributos(fill: fill, overrides: overrides);
}

/// Monta os 10 atributos de GOLEIRO (default `fill`, com `overrides`).
/// Requer que `GK.todos` esteja definido em `models/jogador.dart`.
Map<String, int> buildGKAtributos({
  int fill = 1,
  Map<String, int> overrides = const {},
}) {
  final f = _c(fill);
  final m = <String, int>{for (final k in GK.todos) k: f};

  if (overrides.isNotEmpty) {
    overrides.forEach((k, v) {
      if (GK.todos.contains(k)) m[k] = _c(v);
    });
  }
  return m;
}
