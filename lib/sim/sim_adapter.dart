// lib/sim/sim_adapter.dart
//
// Adapta o resultado do motor de simulação (`ResultadoPartida`) para o
// modelo de app (`PartidaModel.finalizada`), mantendo o motor desacoplado.

import 'dart:math' as math;

import '../models/partida_model.dart';
import 'simulador.dart';

/// Converte o resultado do simulador em PartidaModel.finalizada.
/// Mantém o simulador desacoplado dos modelos.
class SimAdapter {
  /// Cria uma [PartidaModel] já finalizada a partir de [ResultadoPartida].
  ///
  /// Se [partidaId] não for informado, gera no formato:
  ///   `<COMP>-R<rodada(3d)>-<MANATE>-<VISIT>`
  /// onde MANATE/VISIT são siglas (até 6 chars) derivadas dos nomes dos times.
  static PartidaModel toPartida({
    required ResultadoPartida r,
    required String competicaoId,
    required int rodada,
    DateTime? dataHora,
    String? estadio,
    String? partidaId,
  }) {
    final id = partidaId ??
        _gerarId(
          competicaoId,
          rodada,
          r.mandante.nome,
          r.visitante.nome,
        );

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
    final comp = _cleanIdToken(compId, maxLen: 12);
    final r = rodada.toString().padLeft(3, '0');
    final man = _siglaDeNome(mandante);
    final vis = _siglaDeNome(visitante);
    return '$comp-R$r-$man-$vis';
  }

  /// Cria uma sigla em até 6 chars a partir do nome do clube.
  /// - remove tudo que não for [A-Z0-9] ou espaço
  /// - usa as três primeiras letras de cada palavra e junta
  /// - corta em 6 chars no máximo
  static String _siglaDeNome(String nome) {
    final up = (nome.isEmpty ? 'X' : nome).toUpperCase();
    final cleaned = up.replaceAll(RegExp(r'[^A-Z0-9\s]'), ' ').trim();
    final parts = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);

    // pega até 3 letras de cada parte e junta
    final joined =
        parts.map((w) => w.substring(0, math.min(3, w.length))).join();

    final sigla = joined.isEmpty ? 'X' : joined;
    return sigla.substring(0, math.min(6, sigla.length));
  }

  /// Normaliza um token de id (competição) para usar no início do ID.
  static String _cleanIdToken(String s, {int maxLen = 12}) {
    final up = s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\-]'), '-');
    final trimmed =
        up.replaceAll(RegExp(r'-{2,}'), '-').replaceAll(RegExp(r'^-|-$'), '');
    final safe = trimmed.isEmpty ? 'COMP' : trimmed;
    return safe.substring(0, math.min(maxLen, safe.length));
  }
}
