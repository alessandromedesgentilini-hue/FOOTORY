// lib/models/standings_row.dart
//
// Modelo de linha de classificação para tabelas de ligas.
// - Armazena estatísticas completas do time.
// - Mantém métodos para aplicar resultados e recalcular saldo.
// - Compatível com TimeModel.
// - Serialização pronta para salvar/recuperar estados.

import 'time_model.dart';

class StandingsRow {
  final TimeModel time;

  int jogos;
  int vitorias;
  int empates;
  int derrotas;
  int golsPro;
  int golsContra;
  int pontos;

  StandingsRow({
    required this.time,
    this.jogos = 0,
    this.vitorias = 0,
    this.empates = 0,
    this.derrotas = 0,
    this.golsPro = 0,
    this.golsContra = 0,
    this.pontos = 0,
  });

  // ======= Getters derivados =======
  int get saldo => golsPro - golsContra;

  // ======= Atualização de linha =======
  void aplicarResultado({
    required int golsFeitos,
    required int golsSofridos,
  }) {
    jogos++;
    golsPro += golsFeitos;
    golsContra += golsSofridos;

    if (golsFeitos > golsSofridos) {
      vitorias++;
      pontos += 3;
    } else if (golsFeitos == golsSofridos) {
      empates++;
      pontos += 1;
    } else {
      derrotas++;
    }
  }

  // ======= Reset para nova competição =======
  void reset() {
    jogos = 0;
    vitorias = 0;
    empates = 0;
    derrotas = 0;
    golsPro = 0;
    golsContra = 0;
    pontos = 0;
  }

  // ======= Serialização =======
  Map<String, dynamic> toJson() => {
        'time': time.id, // usamos ID para persistir
        'jogos': jogos,
        'vitorias': vitorias,
        'empates': empates,
        'derrotas': derrotas,
        'golsPro': golsPro,
        'golsContra': golsContra,
        'pontos': pontos,
      };

  factory StandingsRow.fromJson(
    Map<String, dynamic> json, {
    required TimeModel Function(String id) resolveTime,
  }) {
    return StandingsRow(
      time: resolveTime(json['time'] as String),
      jogos: json['jogos'] as int? ?? 0,
      vitorias: json['vitorias'] as int? ?? 0,
      empates: json['empates'] as int? ?? 0,
      derrotas: json['derrotas'] as int? ?? 0,
      golsPro: json['golsPro'] as int? ?? 0,
      golsContra: json['golsContra'] as int? ?? 0,
      pontos: json['pontos'] as int? ?? 0,
    );
  }

  // ======= Comparação para ordenação =======
  static int comparar(StandingsRow a, StandingsRow b) {
    // Critérios: pontos > vitórias > saldo > gols pró > nome do time
    int cmp = b.pontos.compareTo(a.pontos);
    if (cmp != 0) return cmp;

    cmp = b.vitorias.compareTo(a.vitorias);
    if (cmp != 0) return cmp;

    cmp = b.saldo.compareTo(a.saldo);
    if (cmp != 0) return cmp;

    cmp = b.golsPro.compareTo(a.golsPro);
    if (cmp != 0) return cmp;

    return a.time.nome.compareTo(b.time.nome);
  }

  @override
  String toString() =>
      '${time.nome} - Pts:$pontos | J:$jogos | V:$vitorias | E:$empates | D:$derrotas | GP:$golsPro | GC:$golsContra | SG:$saldo';
}
