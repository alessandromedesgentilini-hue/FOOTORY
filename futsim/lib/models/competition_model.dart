// lib/models/competition_model.dart
//
// Modelo de competição sem depender do tipo Partida (usa dynamic).

import 'time_model.dart';

class CompetitionModel {
  final String id;
  final String nome;
  final int ano;
  final DateTime inicio;

  final List<TimeModel> participantes;
  final List<dynamic> partidas;

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

  // ===== Utilidades =====
  static int _seq = 1;

  /// Compatível com chamadas antigas que passavam parâmetros posicionais.
  static String gerarId([Object? a, Object? b, Object? c]) => 'cmp_${_seq++}';

  /// Inclui ou substitui uma partida existente (mesmo id).
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

  /// Ordena tabela por pontos (fallback: nome).
  void ordenarTabela() {
    participantes.sort((a, b) {
      final ap = _readPontos(a);
      final bp = _readPontos(b);
      final cmp = bp.compareTo(ap);
      if (cmp != 0) return cmp;
      return a.nome.compareTo(b.nome);
    });
  }

  // ===== helpers =====
  int _readPontos(TimeModel t) {
    try {
      final v = (t as dynamic).pontos;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return 0;
    } catch (_) {
      return 0;
    }
  }

  String? _readId(dynamic p) {
    try {
      if (p == null) return null;
      if (p is Map && p['id'] != null) {
        final v = p['id'];
        return v is String ? v : v.toString();
      }
      final v = (p as dynamic).id;
      return v is String ? v : v?.toString();
    } catch (_) {
      return null;
    }
  }
}
