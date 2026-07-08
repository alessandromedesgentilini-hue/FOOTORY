// lib/services/simulacao/simulacao_service.dart
//
// Serviço de simulação de partidas.
// - Depende de um motor `SimuladorPartida` (em lib/sim/simulador.dart)
// - Atualiza as partidas da rodada para o status "finalizada"
// - Ignora partidas que já estiverem finalizadas
//
// Interface mínima esperada do motor:
//   class SimResultado {
//     final int golsMandante, golsVisitante;
//     // Em alguns branches: finalizacoesMandante/Visitante
//     // Em outros: chutesMandante/Visitante
//     // Posse: posseMandante (ou, às vezes, posse do mandante)
//   }
//
//   class SimuladorPartida {
//     SimuladorPartida({int? seed});
//     SimResultado simular({required TimeModel mandante, required TimeModel visitante});
//   }

import '../../models/competition_model.dart';
import '../../models/partida_model.dart';
import '../../sim/simulador.dart';

class SimulacaoService {
  final SimuladorPartida _engine;

  // Garante int para o seed do motor (evita int? -> int)
  SimulacaoService({int? seed})
      : _engine = SimuladorPartida(
          seed: seed ?? DateTime.now().millisecondsSinceEpoch,
        );

  // ===== Helpers para ler campos com nomes alternativos =====

  int _golsMandante(dynamic r, {int def = 0}) {
    try {
      // ignore: avoid_dynamic_calls
      final v = r.golsMandante as int?;
      if (v != null) return v;
    } catch (_) {}
    return def;
  }

  int _golsVisitante(dynamic r, {int def = 0}) {
    try {
      // ignore: avoid_dynamic_calls
      final v = r.golsVisitante as int?;
      if (v != null) return v;
    } catch (_) {}
    return def;
  }

  int _finalizacoesMandante(dynamic r, {int def = 0}) {
    try {
      // ignore: avoid_dynamic_calls
      final v = r.finalizacoesMandante as int?;
      if (v != null) return v;
    } catch (_) {}
    try {
      // ignore: avoid_dynamic_calls
      final v = r.chutesMandante as int?;
      if (v != null) return v;
    } catch (_) {}
    return def;
  }

  int _finalizacoesVisitante(dynamic r, {int def = 0}) {
    try {
      // ignore: avoid_dynamic_calls
      final v = r.finalizacoesVisitante as int?;
      if (v != null) return v;
    } catch (_) {}
    try {
      // ignore: avoid_dynamic_calls
      final v = r.chutesVisitante as int?;
      if (v != null) return v;
    } catch (_) {}
    return def;
  }

  int _posseMandante(dynamic r, {int def = 50}) {
    try {
      // ignore: avoid_dynamic_calls
      final v = r.posseMandante as int?;
      if (v != null) return v;
    } catch (_) {}
    try {
      // alguns motores expõem apenas "posse" (do mandante)
      // ignore: avoid_dynamic_calls
      final v = r.posse as int?;
      if (v != null) return v;
    } catch (_) {}
    return def;
  }

  /// Simula todas as partidas da [rodada] dentro do [comp] e marca como finalizadas.
  CompetitionModel simularRodada(CompetitionModel comp, int rodada) {
    final partidas = comp.partidas.where((p) => p.rodada == rodada);
    for (final p in partidas) {
      if (p.isFinalizada) continue;

      final res = _engine.simular(
        mandante: p.mandante,
        visitante: p.visitante,
      );

      final golsM = _golsMandante(res);
      final golsV = _golsVisitante(res);
      final finM = _finalizacoesMandante(res);
      final finV = _finalizacoesVisitante(res);
      final posseM = _posseMandante(res);

      // Se p.rodada for int?, garantimos int com fallback para o arg `rodada`.
      final rodadaInt = (p.rodada as int?) ?? rodada;

      final fin = PartidaModel.finalizada(
        id: p.id,
        competicaoId: p.competicaoId,
        rodada: rodadaInt,
        dataHora: p.dataHora,
        estadio: p.estadio,
        mandante: p.mandante,
        visitante: p.visitante,
        golsMandante: golsM,
        golsVisitante: golsV,
        finalizacoesMandante: finM,
        finalizacoesVisitante: finV,
        posseMandante: posseM,
      );

      comp.upsertPartida(fin);
    }
    return comp;
  }
}
