// lib/sim/sim_adapter.dart
import 'dart:math' as math;

import '../models/partida_model.dart';
import 'simulador.dart';

/// Converte o resultado do simulador em PartidaModel.finalizada.
/// Mantém o simulador desacoplado dos modelos.
class SimAdapter {
  /// Gera a PartidaModel já finalizada.
  /// Se [partidaId] não for passado, gera um id no formato COMP-RNNN-MAN-VIS.
  static PartidaModel toPartida({
    required ResultadoPartida r,
    required String competicaoId,
    required int rodada,
    DateTime? dataHora,
    String? estadio,
    String? partidaId,
  }) {
    final id = partidaId ??
        _gerarId(competicaoId, rodada, r.mandante.nome, r.visitante.nome);

    return PartidaModel.finalizada(
      id: id,
      competicaoId: competicaoId,
      rodada: rodada,
      dataHora: dataHora ?? DateTime.now(),
      estadio: estadio,
      mandante: r.mandante,
      visitante: r.visitante,
      golsMandante: r.golsMandante,
      golsVisitante: r.golsVisitante,
      finalizacoesMandante: r.finalizMandante,
      finalizacoesVisitante: r.finalizVisitante,
      posseMandante: r.posseMandante,
    );
  }

  // ---------- suporte ----------
  static String _gerarId(
    String compId,
    int rodada,
    String mandante,
    String visitante,
  ) {
    final r = rodada.toString().padLeft(3, '0');
    String code(String nome) {
      final up = nome
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9\s]'), ' ')
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .map((w) => w.substring(0, math.min(3, w.length)))
          .join();
      return up.substring(0, math.min(6, up.length));
    }

    return '$compId-R$r-${code(mandante)}-${code(visitante)}';
  }
}
