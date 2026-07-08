import 'package:flutter/foundation.dart';

/// Temporada no padrão BR (Jan–Dez).
/// Usado para: mês atual, avanço de tempo, e janelas de transferência (Jan/Jul).
///
/// Regras:
/// - Jan = 1 ... Dez = 12
/// - Janela: Janeiro e Julho
/// - Avanço: você decide quando chamar (ex.: ao simular rodada, virar mês, etc.)
@immutable
class SeasonClock {
  final int year;
  final int month; // 1..12

  const SeasonClock({
    required this.year,
    required this.month,
  }) : assert(month >= 1 && month <= 12);

  static const List<String> monthNamesPt = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  String get monthName => monthNamesPt[month - 1];

  /// Janela de transferências (assinatura e chegada/registro).
  bool get isTransferWindow => month == 1 || month == 7;

  /// Apenas para UI. Ex: "Jan/2026"
  String get shortLabel => '${_shortMonth(month)}/$year';

  /// Ex: "Janeiro/2026"
  String get longLabel => '$monthName/$year';

  SeasonClock copyWith({int? year, int? month}) {
    return SeasonClock(
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  /// Avança em N meses.
  SeasonClock addMonths(int delta) {
    if (delta == 0) return this;

    int y = year;
    int m = month + delta;

    while (m > 12) {
      m -= 12;
      y += 1;
    }
    while (m < 1) {
      m += 12;
      y -= 1;
    }

    return SeasonClock(year: y, month: m);
  }

  /// Avança 1 mês.
  SeasonClock nextMonth() => addMonths(1);

  /// Volta 1 mês.
  SeasonClock prevMonth() => addMonths(-1);

  /// Chave de controle para "1 relatório por mês".
  /// Ex: 2026-01
  String get monthKey =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  static String _shortMonth(int m) {
    const shorts = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return shorts[m - 1];
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
      };

  static SeasonClock fromJson(Map<String, dynamic> json) {
    return SeasonClock(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
    );
  }
}
