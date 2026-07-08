class SponsorRevenueResult {
  final int monthlyAmount;
  final int annualAmount;
  final String message;

  const SponsorRevenueResult({
    required this.monthlyAmount,
    required this.annualAmount,
    required this.message,
  });
}

class SponsorRevenueService {
  const SponsorRevenueService();

  static const int marketingUpgradeBonus = 7000000;

  SponsorRevenueResult calculateMonthly({
    required String divisionId,
    required int marketingLevel,
  }) {
    final safeLevel = marketingLevel.clamp(1, 10);
    final annualAmount = _annualSponsorshipByDivisionAndMarketing(
      divisionId: divisionId,
      marketingLevel: safeLevel,
    );

    final monthlyAmount = (annualAmount / 12).round();

    return SponsorRevenueResult(
      monthlyAmount: monthlyAmount,
      annualAmount: annualAmount,
      message:
          'O clube gerou ${_formatMoney(monthlyAmount)} em receita mensal de patrocínio. O contrato anual estimado é de ${_formatMoney(annualAmount)}, considerando a divisão atual e o nível $safeLevel de marketing.',
    );
  }

  int calculateImmediateUpgradeBonus({
    required String divisionId,
    required int newMarketingLevel,
  }) {
    return marketingUpgradeBonus;
  }

  int _annualSponsorshipByDivisionAndMarketing({
    required String divisionId,
    required int marketingLevel,
  }) {
    final level = marketingLevel.clamp(1, 10);
    final division = _normalizeDivisionId(divisionId);

    return switch (division) {
      'A' => _serieAAnnual(level),
      'B' => _serieBAnnual(level),
      'C' => _serieCAnnual(level),
      'D' => _serieDAnnual(level),
      _ => _serieDAnnual(level),
    };
  }

  int _serieAAnnual(int level) {
    return switch (level) {
      1 => 60000000,
      2 => 90000000,
      3 => 129000000,
      4 => 150000000,
      5 => 200000000,
      6 => 220000000,
      7 => 270000000,
      8 => 320000000,
      9 => 400000000,
      _ => 500000000,
    };
  }

  int _serieBAnnual(int level) {
    return switch (level) {
      1 => 24000000,
      2 => 36000000,
      3 => 51600000,
      4 => 60000000,
      5 => 80000000,
      6 => 88000000,
      7 => 108000000,
      8 => 128000000,
      9 => 160000000,
      _ => 200000000,
    };
  }

  int _serieCAnnual(int level) {
    return switch (level) {
      1 => 10800000,
      2 => 16200000,
      3 => 23220000,
      4 => 27000000,
      5 => 36000000,
      6 => 39600000,
      7 => 48600000,
      8 => 57600000,
      9 => 72000000,
      _ => 90000000,
    };
  }

  int _serieDAnnual(int level) {
    return switch (level) {
      1 => 6000000,
      2 => 9000000,
      3 => 12900000,
      4 => 15000000,
      5 => 20000000,
      6 => 22000000,
      7 => 27000000,
      8 => 32000000,
      9 => 40000000,
      _ => 50000000,
    };
  }

  String _normalizeDivisionId(String value) {
    final raw = value.trim().toUpperCase();

    if (raw == 'A' ||
        raw == 'BRA' ||
        raw == 'BR_A' ||
        raw == 'BR-A' ||
        raw == 'BR A' ||
        raw == 'SERIE_A' ||
        raw == 'SÉRIE_A' ||
        raw == 'LIGA_A' ||
        raw == 'DIVISIONID.BRA' ||
        raw.endsWith('.BRA')) {
      return 'A';
    }

    if (raw == 'B' ||
        raw == 'BRB' ||
        raw == 'BR_B' ||
        raw == 'BR-B' ||
        raw == 'BR B' ||
        raw == 'SERIE_B' ||
        raw == 'SÉRIE_B' ||
        raw == 'LIGA_B' ||
        raw == 'DIVISIONID.BRB' ||
        raw.endsWith('.BRB')) {
      return 'B';
    }

    if (raw == 'C' ||
        raw == 'BRC' ||
        raw == 'BR_C' ||
        raw == 'BR-C' ||
        raw == 'BR C' ||
        raw == 'SERIE_C' ||
        raw == 'SÉRIE_C' ||
        raw == 'LIGA_C' ||
        raw == 'DIVISIONID.BRC' ||
        raw.endsWith('.BRC')) {
      return 'C';
    }

    if (raw == 'D' ||
        raw == 'BRD' ||
        raw == 'BR_D' ||
        raw == 'BR-D' ||
        raw == 'BR D' ||
        raw == 'SERIE_D' ||
        raw == 'SÉRIE_D' ||
        raw == 'LIGA_D' ||
        raw == 'DIVISIONID.BRD' ||
        raw.endsWith('.BRD')) {
      return 'D';
    }

    return 'D';
  }

  String _formatMoney(int value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)} mi';
    }

    return 'R\$ ${(value / 1000).toStringAsFixed(0)} mil';
  }
}
