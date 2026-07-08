// lib/services/world/season_clock.dart
//
// SeasonClock (MVP)
// - Converte "rodadaAtual" em uma data real (aproximação realista).
// - Gera datas de rodadas em padrão BR: quartas e domingos.
// - Resolve mês atual (1..12) e janelas de transferência (Jan/Jul).
//
// Nota: No MVP, a liga é o driver do calendário.
// Depois a gente expande para Copas e datas fixas por competição.

class SeasonClock {
  const SeasonClock();

  /// Data base do início da temporada (aproximação).
  /// Você tinha férias 15/12–14/01. Então começamos após isso.
  /// Aqui: terceiro domingo de janeiro (padrão "começou o ano").
  DateTime seasonStart(int ano) {
    final jan15 = DateTime(ano, 1, 15);
    return _nextWeekday(jan15, DateTime.sunday);
  }

  /// Retorna a data real da rodada (1-indexed).
  /// Usa padrão: Dom, Qua, Dom, Qua...
  DateTime dateForRound({
    required int ano,
    required int rodada,
  }) {
    if (rodada < 1) rodada = 1;
    final start = seasonStart(ano);

    // rodada 1: domingo
    // rodada 2: quarta
    // rodada 3: domingo
    // ...
    final isSunday = rodada.isOdd;

    // cada par de rodadas é "uma semana".
    final weekIndex = (rodada - 1) ~/ 2;

    final baseWeek = start.add(Duration(days: weekIndex * 7));
    if (isSunday) return baseWeek;

    // quarta daquela semana
    return _nextWeekday(baseWeek, DateTime.wednesday);
  }

  /// Mês (1..12) baseado na data da rodada atual.
  int monthForRound({
    required int ano,
    required int rodada,
  }) {
    final d = dateForRound(ano: ano, rodada: rodada);
    return d.month;
  }

  /// Janela de transferências aberta?
  /// Regras: Janeiro e Julho.
  bool isTransferWindowOpen({
    required int ano,
    required int rodada,
  }) {
    final m = monthForRound(ano: ano, rodada: rodada);
    return m == 1 || m == 7;
  }

  // ---------------------------------------------------------
  // helpers
  // ---------------------------------------------------------

  DateTime _nextWeekday(DateTime from, int weekday) {
    var d = from;
    while (d.weekday != weekday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }
}
