// lib/services/simulacao/simulacao_service.dart
import '../../models/competition_model.dart';
import '../../models/partida_model.dart';
import '../../sim/simulador.dart'; // seu motor
// ^ garanta que os IMPORTS nesse arquivo simulador.dart estão no topo,
// e que ele não cria times/escudos: só o motor SimuladorPartida!

class SimulacaoService {
  final SimuladorPartida _engine;
  SimulacaoService({int? seed}) : _engine = SimuladorPartida(seed: seed);

  /// Simula todas as partidas da rodada informada.
  CompetitionModel simularRodada(CompetitionModel comp, int rodada) {
    final partidas = comp.partidas.where((p) => p.rodada == rodada).toList();
    for (final p in partidas) {
      // roda o motor
      final r = _engine.simular(mandante: p.mandante, visitante: p.visitante);

      // grava como finalizada
      final fin = PartidaModel.finalizada(
        id: p.id,
        competicaoId: p.competicaoId,
        rodada: p.rodada,
        dataHora: p.dataHora,
        estadio: p.estadio,
        mandante: p.mandante,
        visitante: p.visitante,
        golsMandante: r.golsMandante,
        golsVisitante: r.golsVisitante,
        finalizacoesMandante: r.finalizMandante,
        finalizacoesVisitante: r.finalizVisitante,
        posseMandante: r.posseMandante,
      );
      comp.upsertPartida(fin);
    }
    return comp;
  }
}
