import 'time_model.dart';

class StandingsRow {
  final TimeModel time;
  int jogos;
  int vitorias;
  int empates;
  int derrotas;
  int golsPro;
  int golsContra;
  int saldo;
  int pontos;

  StandingsRow({
    required this.time,
    this.jogos = 0,
    this.vitorias = 0,
    this.empates = 0,
    this.derrotas = 0,
    this.golsPro = 0,
    this.golsContra = 0,
    this.saldo = 0,
    this.pontos = 0,
  });
}
