// lib/models/partida_model.dart
import 'time_model.dart';

/// Estado da partida no ciclo de jogo.
enum PartidaStatus { agendada, emAndamento, finalizada }

/// Resultado lógico de uma partida.
enum Resultado { mandante, visitante, empate }

class PartidaModel {
  // ── Identidade/competição ──────────────────────────────────────────────────
  final String id; // Ex.: "BRA-A-2025-R001-INT-RUB"
  final String competicaoId; // Ex.: "BRA-A-2025"
  final int rodada; // 1-based

  // ── Agenda/local ───────────────────────────────────────────────────────────
  final DateTime dataHora; // Data/hora do kickoff
  final String? estadio; // Opcional

  // ── Times ──────────────────────────────────────────────────────────────────
  final TimeModel mandante;
  final TimeModel visitante;

  // ── Placar (tempo normal) ──────────────────────────────────────────────────
  final int golsMandante;
  final int golsVisitante;

  // ── Decisão por pênaltis (mata-mata) ───────────────────────────────────────
  final int? penaltisMandante; // null = não houve pênaltis
  final int? penaltisVisitante;

  // ── Estatísticas básicas (MVP) ─────────────────────────────────────────────
  final int finalizacoesMandante;
  final int finalizacoesVisitante;

  /// Posse de bola 0..100 para o mandante; a do visitante é 100 - posseMandante.
  final int posseMandante;

  // ── Status ─────────────────────────────────────────────────────────────────
  final PartidaStatus status;

  // ── Construtor base (use as factories para normalização) ───────────────────
  const PartidaModel._({
    required this.id,
    required this.competicaoId,
    required this.rodada,
    required this.dataHora,
    required this.estadio,
    required this.mandante,
    required this.visitante,
    required this.golsMandante,
    required this.golsVisitante,
    required this.penaltisMandante,
    required this.penaltisVisitante,
    required this.finalizacoesMandante,
    required this.finalizacoesVisitante,
    required this.posseMandante,
    required this.status,
  });

  // ── Helpers de ID ──────────────────────────────────────────────────────────

  /// Helper para padronizar IDs de partida.
  /// Ex.: `gerarId('BRA','A',2025,1,'INT','RUB')`
  static String gerarId(
    String pais,
    String divisao,
    int ano,
    int rodada,
    String siglaMandante,
    String siglaVisitante,
  ) {
    final r = rodada.clamp(1, 999).toString().padLeft(3, '0');
    final p = pais.trim().toUpperCase();
    final d = divisao.trim().toUpperCase();
    final sm = siglaMandante.trim().toUpperCase();
    final sv = siglaVisitante.trim().toUpperCase();
    return '$p-$d-$ano-R$r-$sm-$sv';
  }

  // ── Fábricas recomendadas ──────────────────────────────────────────────────

  /// Cria uma partida **agendada** (sem placar/estatísticas).
  factory PartidaModel.agendada({
    required String id,
    required String competicaoId,
    required int rodada,
    required DateTime dataHora,
    String? estadio,
    required TimeModel mandante,
    required TimeModel visitante,
  }) {
    return PartidaModel._(
      id: id,
      competicaoId: competicaoId,
      rodada: rodada < 1 ? 1 : rodada,
      dataHora: dataHora,
      estadio: estadio,
      mandante: mandante,
      visitante: visitante,
      golsMandante: 0,
      golsVisitante: 0,
      penaltisMandante: null,
      penaltisVisitante: null,
      finalizacoesMandante: 0,
      finalizacoesVisitante: 0,
      posseMandante: 50,
      status: PartidaStatus.agendada,
    );
  }

  /// Finaliza uma partida com placar e estatísticas.
  /// Use `penaltis*` apenas em mata-mata com empate no tempo normal.
  factory PartidaModel.finalizada({
    required String id,
    required String competicaoId,
    required int rodada,
    required DateTime dataHora,
    String? estadio,
    required TimeModel mandante,
    required TimeModel visitante,
    required int golsMandante,
    required int golsVisitante,
    int? penaltisMandante,
    int? penaltisVisitante,
    int finalizacoesMandante = 0,
    int finalizacoesVisitante = 0,
    int? posseMandante, // se null, assume 50
  }) {
    final gm = _nz(golsMandante);
    final gv = _nz(golsVisitante);
    final pm = _clampPct(posseMandante ?? 50);

    // Normaliza pênaltis conforme o placar do tempo normal
    int? penM = penaltisMandante;
    int? penV = penaltisVisitante;
    if (gm != gv) {
      penM = null;
      penV = null;
    } else if ((penM == null) != (penV == null)) {
      penM = null;
      penV = null;
    }

    return PartidaModel._(
      id: id,
      competicaoId: competicaoId,
      rodada: rodada < 1 ? 1 : rodada,
      dataHora: dataHora,
      estadio: estadio,
      mandante: mandante,
      visitante: visitante,
      golsMandante: gm,
      golsVisitante: gv,
      penaltisMandante: penM,
      penaltisVisitante: penV,
      finalizacoesMandante: _nz(finalizacoesMandante),
      finalizacoesVisitante: _nz(finalizacoesVisitante),
      posseMandante: pm,
      status: PartidaStatus.finalizada,
    );
  }

  /// Marca uma partida como **em andamento** (opcional no MVP).
  factory PartidaModel.emAndamento({
    required String id,
    required String competicaoId,
    required int rodada,
    required DateTime dataHora,
    String? estadio,
    required TimeModel mandante,
    required TimeModel visitante,
    int golsMandante = 0,
    int golsVisitante = 0,
    int finalizacoesMandante = 0,
    int finalizacoesVisitante = 0,
    int? posseMandante,
  }) {
    return PartidaModel._(
      id: id,
      competicaoId: competicaoId,
      rodada: rodada < 1 ? 1 : rodada,
      dataHora: dataHora,
      estadio: estadio,
      mandante: mandante,
      visitante: visitante,
      golsMandante: _nz(golsMandante),
      golsVisitante: _nz(golsVisitante),
      penaltisMandante: null,
      penaltisVisitante: null,
      finalizacoesMandante: _nz(finalizacoesMandante),
      finalizacoesVisitante: _nz(finalizacoesVisitante),
      posseMandante: _clampPct(posseMandante ?? 50),
      status: PartidaStatus.emAndamento,
    );
  }

  // ── Helpers de leitura ─────────────────────────────────────────────────────
  bool get isAgendada => status == PartidaStatus.agendada;
  bool get isEmAndamento => status == PartidaStatus.emAndamento;
  bool get isFinalizada => status == PartidaStatus.finalizada;

  int get posseVisitante => 100 - posseMandante;

  bool get empateNoTempoNormal => golsMandante == golsVisitante;

  bool get tevePenaltis =>
      penaltisMandante != null && penaltisVisitante != null;

  /// Resultado no tempo normal.
  Resultado get resultadoTempoNormal {
    if (golsMandante > golsVisitante) return Resultado.mandante;
    if (golsVisitante > golsMandante) return Resultado.visitante;
    return Resultado.empate;
  }

  /// Resultado final (considera pênaltis se houver).
  Resultado get resultadoFinal {
    final tn = resultadoTempoNormal;
    if (tn != Resultado.empate) return tn;
    if (!tevePenaltis) return Resultado.empate;
    return (penaltisMandante! > penaltisVisitante!)
        ? Resultado.mandante
        : Resultado.visitante;
  }

  /// Vencedor no tempo normal (ou `null` se empate).
  TimeModel? get vencedorTempoNormal {
    switch (resultadoTempoNormal) {
      case Resultado.mandante:
        return mandante;
      case Resultado.visitante:
        return visitante;
      case Resultado.empate:
        return null;
    }
  }

  /// Vencedor final (considera pênaltis se houver).
  TimeModel? get vencedorFinal {
    switch (resultadoFinal) {
      case Resultado.mandante:
        return mandante;
      case Resultado.visitante:
        return visitante;
      case Resultado.empate:
        return null;
    }
  }

  String get placarString {
    // Mantém chaves aqui porque há uma letra imediatamente após a interpolação.
    final base = '${golsMandante}x$golsVisitante';
    if (tevePenaltis) {
      return '$base ($penaltisMandante-$penaltisVisitante nos pênaltis)';
    }
    return base;
  }

  PartidaModel copyWith({
    String? id,
    String? competicaoId,
    int? rodada,
    DateTime? dataHora,
    String? estadio,
    TimeModel? mandante,
    TimeModel? visitante,
    int? golsMandante,
    int? golsVisitante,
    int? penaltisMandante,
    int? penaltisVisitante,
    int? finalizacoesMandante,
    int? finalizacoesVisitante,
    int? posseMandante,
    PartidaStatus? status,
  }) {
    final gm = _nz(golsMandante ?? this.golsMandante);
    final gv = _nz(golsVisitante ?? this.golsVisitante);

    // Se mudar o placar, revalida pênaltis automaticamente
    int? penM = penaltisMandante ?? this.penaltisMandante;
    int? penV = penaltisVisitante ?? this.penaltisVisitante;
    if (gm != gv) {
      penM = null;
      penV = null;
    } else if ((penM == null) != (penV == null)) {
      penM = null;
      penV = null;
    }

    return PartidaModel._(
      id: id ?? this.id,
      competicaoId: competicaoId ?? this.competicaoId,
      rodada: (rodada ?? this.rodada),
      dataHora: dataHora ?? this.dataHora,
      estadio: estadio ?? this.estadio,
      mandante: mandante ?? this.mandante,
      visitante: visitante ?? this.visitante,
      golsMandante: gm,
      golsVisitante: gv,
      penaltisMandante: penM,
      penaltisVisitante: penV,
      finalizacoesMandante:
          _nz(finalizacoesMandante ?? this.finalizacoesMandante),
      finalizacoesVisitante:
          _nz(finalizacoesVisitante ?? this.finalizacoesVisitante),
      posseMandante: _clampPct(posseMandante ?? this.posseMandante),
      status: status ?? this.status,
    );
  }

  /// Serializa para JSON (salva apenas **chaves** dos times).
  Map<String, dynamic> toJson({
    String Function(TimeModel t)? timeKey,
  }) {
    final key = timeKey ?? ((t) => t.nome); // troque p/ t.id quando existir
    return {
      'id': id,
      'competicaoId': competicaoId,
      'rodada': rodada,
      'dataHora': dataHora.toIso8601String(),
      'estadio': estadio,
      'mandante': key(mandante),
      'visitante': key(visitante),
      'golsMandante': golsMandante,
      'golsVisitante': golsVisitante,
      'penaltisMandante': penaltisMandante,
      'penaltisVisitante': penaltisVisitante,
      'finalizacoesMandante': finalizacoesMandante,
      'finalizacoesVisitante': finalizacoesVisitante,
      'posseMandante': posseMandante,
      'status': status.name,
    };
  }

  /// Desserializa de JSON resolvendo `TimeModel` via [resolveTime].
  factory PartidaModel.fromJson(
    Map<String, dynamic> json, {
    required TimeModel Function(String key) resolveTime,
  }) {
    final mandKey = (json['mandante'] as String?) ?? '';
    final visKey = (json['visitante'] as String?) ?? '';
    final mand = resolveTime(mandKey);
    final vis = resolveTime(visKey);

    return PartidaModel._(
      id: (json['id'] as String?) ?? '',
      competicaoId: (json['competicaoId'] as String?) ?? '',
      rodada: _asInt(json['rodada']).clamp(1, 999),
      dataHora: DateTime.tryParse((json['dataHora'] as String?) ?? '') ??
          DateTime.now(),
      estadio: json['estadio'] as String?,
      mandante: mand,
      visitante: vis,
      golsMandante: _nz(_asInt(json['golsMandante'])),
      golsVisitante: _nz(_asInt(json['golsVisitante'])),
      penaltisMandante: json['penaltisMandante'] == null
          ? null
          : _nz(_asInt(json['penaltisMandante'])),
      penaltisVisitante: json['penaltisVisitante'] == null
          ? null
          : _nz(_asInt(json['penaltisVisitante'])),
      finalizacoesMandante: _nz(_asInt(json['finalizacoesMandante'])),
      finalizacoesVisitante: _nz(_asInt(json['finalizacoesVisitante'])),
      posseMandante: _clampPct(_asInt(json['posseMandante'])),
      status: _statusFromString(json['status'] as String?),
    );
  }

  @override
  String toString() =>
      '[$competicaoId R$rodada] ${mandante.nome} $placarString ${visitante.nome}';

  // Igualdade por ID (útil para sets, updates, etc.)
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PartidaModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  // ── Internals ───────────────────────────────────────────────────────────────
  static PartidaStatus _statusFromString(String? s) {
    switch ((s ?? '').trim().toLowerCase()) {
      case 'agendada':
      case 'scheduled':
        return PartidaStatus.agendada;
      case 'emandamento':
      case 'em_andamento':
      case 'inprogress':
      case 'in_progress':
        return PartidaStatus.emAndamento;
      case 'finalizada':
      case 'finished':
      case 'completed':
        return PartidaStatus.finalizada;
      default:
        return PartidaStatus.agendada;
    }
  }
}

// ── Helpers internos ─────────────────────────────────────────────────────────
int _nz(int? v) => v == null || v < 0 ? 0 : v;

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

int _clampPct(int v) {
  if (v < 0) return 0;
  if (v > 100) return 100;
  return v;
}
