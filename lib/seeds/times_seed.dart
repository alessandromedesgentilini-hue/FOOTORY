// lib/seeds/times_seed.dart
//
// Seed mínimo de TIMES para bootar o jogo.
// Compatível com TimeModel (id, nome, estilo: Estilo, elenco, maxEstrangeiros).
//
// Observação:
// - Aqui você pode usar slugs de estilo (ex.: 'posse_de_bola', 'gegenpress',
//   'transicao', 'defensivo', 'sul_americano', 'bola_parada'). Eles são
//   convertidos para o enum Estilo via EstiloX.fromString, com fallback.

import '../models/time_model.dart';
import '../models/jogador.dart';
import '../models/estilos.dart';

/// Converte slug -> Estilo com fallback para o primeiro valor do enum.
Estilo _estilo(String slug) {
  try {
    return EstiloX.fromString(slug);
  } catch (_) {
    return Estilo.values.first;
  }
}

/// Retorna os times base do jogo.
List<TimeModel> timesSeed() {
  return <TimeModel>[
    TimeModel(
      id: 'alpha',
      nome: 'Alpha FC',
      estilo: _estilo('posse_de_bola'),
      elenco: const <Jogador>[],
    ),
    TimeModel(
      id: 'beta',
      nome: 'Beta United',
      estilo: _estilo('gegenpress'),
      elenco: const <Jogador>[],
    ),
    TimeModel(
      id: 'gama',
      nome: 'Gama Clube',
      estilo: _estilo('defensivo'),
      elenco: const <Jogador>[],
    ),
    TimeModel(
      id: 'delta',
      nome: 'Delta SC',
      estilo: _estilo('transicao'),
      elenco: const <Jogador>[],
    ),
  ];
}
