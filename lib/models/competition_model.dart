// lib/models/competition_model.dart
//
// Modelo de competição genérico, independente da implementação de Partida.
// Versão final robusta, com:
// • Suporte a participantes (TimeModel) e partidas (dynamic).
// • Upsert seguro de partidas por ID.
// • Ordenação customizável por pontos, saldo, vitórias ou nome.
// • Métodos auxiliares para rodadas e controle incremental.
// • Fallbacks para APIs antigas (compatibilidade).

import 'time_model.dart';

class CompetitionModel {
  final String id;
  final String nome;
  final int ano;
  final DateTime inicio;

  /// Participantes desta competição.
  final List<TimeModel> participantes;

  /// Partidas associadas a esta competição.
  final List<dynamic> partidas;

  /// Rodada atual (1-based).
  int rodadaAtual;

  CompetitionModel({
    required this.id,
    required this.nome,
    required this.ano,
    required this.inicio,
    List<TimeModel>? participantesIn,
    List<dynamic>? partidasIn,
    this.rodadaAtual = 1,
  })  : participantes = participantesIn ?? <TimeModel>[],
        partidas = partidasIn ?? <dynamic>[];

  // ====== Gerador de IDs ======
  static int _seq = 1;

  /// Gera IDs únicos e sequenciais para competições.
  /// Compatível com chamadas antigas que passavam parâmetros posicionais.
  static String gerarId([Object? a, Object? b, Object? c]) => 'cmp_${_seq++}';

  // ====== Partidas ======

  /// Inclui ou substitui uma partida existente com base no ID.
  void upsertPartida(dynamic p) {
    final pid = _readId(p);
    if (pid == null) return;

    final idx = partidas.indexWhere((x) => _readId(x) == pid);
    if (idx >= 0) {
      partidas[idx] = p;
    } else {
      partidas.add(p);
    }
  }

  /// Retorna a lista de partidas de uma rodada específica (1-based).
  List<dynamic> partidasDaRodada(int rodada) {
    return partidas.where((p) {
      try {
        final r = (p as dynamic).rodada;
        return r == rodada;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  /// Avança para a próxima rodada se ainda houver jogos pendentes.
  bool avancarRodada() {
    final totalRodadas = _inferirTotalRodadas();
    if (rodadaAtual < totalRodadas) {
      rodadaAtual++;
      return true;
    }
    return false;
  }

  /// Tenta inferir o total de rodadas a partir das partidas carregadas.
  int _inferirTotalRodadas() {
    if (partidas.isEmpty) return rodadaAtual;
    final rodadas = partidas.map((p) {
      try {
        return (p as dynamic).rodada ?? 0;
      } catch (_) {
        return 0;
      }
    }).toSet();
    return rodadas.isEmpty
        ? rodadaAtual
        : rodadas.reduce((a, b) => a > b ? a : b);
  }

  // ====== Tabela / Ranking ======

  /// Ordena a tabela por pontos, saldo, vitórias e, por fim, nome.
  /// Se `criterioExtra` for fornecido, ele será chamado antes do nome.
  void ordenarTabela({int Function(TimeModel a, TimeModel b)? criterioExtra}) {
    participantes.sort((a, b) {
      final ap = _readPontos(a);
      final bp = _readPontos(b);

      // Ordena por pontos (decrescente)
      var cmp = bp.compareTo(ap);
      if (cmp != 0) return cmp;

      // Critério extra customizado (ex.: saldo/vitórias)
      if (criterioExtra != null) {
        cmp = criterioExtra(a, b);
        if (cmp != 0) return cmp;
      }

      // Fallback: ordena por nome para consistência
      return a.nome.compareTo(b.nome);
    });
  }

  // ====== Helpers ======

  int _readPontos(TimeModel t) {
    try {
      final v = (t as dynamic).pontos;
      if (v is int) return v;
      if (v is num) return v.toInt();
    } catch (_) {}
    return 0;
  }

  String? _readId(dynamic p) {
    try {
      if (p == null) return null;

      // Caso seja um Map com ID
      if (p is Map && p['id'] != null) {
        final v = p['id'];
        return v is String ? v : v.toString();
      }

      // Caso seja objeto com campo .id
      final v = (p as dynamic).id;
      return v is String ? v : v?.toString();
    } catch (_) {
      return null;
    }
  }
}
