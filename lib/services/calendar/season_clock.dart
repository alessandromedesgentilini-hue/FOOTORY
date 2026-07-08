class SeasonClock {
  final int year;

  /// Estrutura simples:
  ///
  /// 1 = começo do mês
  /// 8 = fim do mês
  ///
  /// Isso deixa MUITO espaço para:
  /// - Copa do Brasil
  /// - Libertadores
  /// - Sul-Americana
  /// - Mundial
  /// - Super Mundial
  /// - amistosos futuros
  ///
  /// sem destruir o calendário.
  const SeasonClock(this.year);

  List<DateTime> monthSlots(int month) {
    const days = <int>[
      2,
      5,
      9,
      12,
      16,
      19,
      23,
      26,
    ];

    return days.map((d) => DateTime(year, month, d)).toList(growable: false);
  }

  /// BRASILEIRÃO
  ///
  /// Estrutura:
  ///
  /// JAN:
  /// - slots 7 e 8
  ///
  /// FEV-NOV:
  /// - slots 2,4,6,8
  ///
  /// Isso cria:
  /// - espaço livre entre rodadas
  /// - espaço pra copas
  /// - espaço pra torneios internacionais
  ///
  /// e mantém o calendário leve e previsível.
  Map<int, DateTime> buildLeagueRoundDates({
    required int totalRounds,
  }) {
    final out = <int, DateTime>{};

    if (totalRounds <= 0) return out;

    int round = 1;

    // Janeiro
    final jan = monthSlots(1);

    for (final idx in <int>[6, 7]) {
      if (round > totalRounds) break;

      out[round] = jan[idx];
      round++;
    }

    // Fevereiro -> Novembro
    const leagueIdxs = <int>[1, 3, 5, 7];

    for (int month = 2; month <= 11; month++) {
      final slots = monthSlots(month);

      for (final idx in leagueIdxs) {
        if (round > totalRounds) break;

        out[round] = slots[idx];
        round++;
      }

      if (round > totalRounds) break;
    }

    // fallback
    if (round <= totalRounds) {
      final dec = monthSlots(12);

      for (final idx in <int>[1, 3, 5, 7]) {
        if (round > totalRounds) break;

        out[round] = dec[idx];
        round++;
      }
    }

    return out;
  }

  /// COPA DO BRASIL
  ///
  /// Usa os slots livres do calendário.
  ///
  /// Estrutura:
  ///
  /// slots:
  /// 1,3,5,7
  ///
  /// Isso intercala naturalmente com a liga.
  ///
  /// Exemplo:
  ///
  /// Liga = slot 2
  /// Copa = slot 3
  /// Liga = slot 4
  ///
  /// Fica com cara real de calendário.
  List<DateTime> buildBrazilCupPhaseDates({
    required int month,
    required int legs,
  }) {
    final slots = monthSlots(month);

    final out = <DateTime>[];

    // Copa ocupa espaços livres da liga.
    const cupIdxs = <int>[
      0,
      2,
      4,
      6,
    ];

    for (final idx in cupIdxs) {
      out.add(slots[idx]);

      if (out.length >= legs) {
        break;
      }
    }

    return out;
  }

  /// LIBERTADORES / SULA FUTURAS
  ///
  /// Mantido separado pra:
  /// - não misturar regras
  /// - permitir expansão futura
  ///
  /// Pode mudar depois sem quebrar Copa BR.
  List<DateTime> buildInternationalPhaseDates({
    required int month,
    required int legs,
  }) {
    final slots = monthSlots(month);

    final out = <DateTime>[];

    // slots mais tardios do mês
    const idxs = <int>[
      2,
      4,
      6,
      7,
    ];

    for (final idx in idxs) {
      out.add(slots[idx]);

      if (out.length >= legs) {
        break;
      }
    }

    return out;
  }

  /// Datas livres futuras.
  ///
  /// Isso aqui vai ser MUITO útil depois:
  /// - eventos
  /// - amistosos
  /// - super mundial
  /// - calendário dinâmico
  /// - adiamentos
  ///
  /// Já deixa o motor preparado.
  List<DateTime> freeSlotsOfMonth({
    required int month,
    required List<DateTime> occupied,
  }) {
    final slots = monthSlots(month);

    return slots.where((d) {
      return !occupied.any(
        (o) => o.year == d.year && o.month == d.month && o.day == d.day,
      );
    }).toList();
  }
}
