import 'package:footory26/core/seeded_rng.dart';

class TicketRevenueResult {
  final int amount;
  final String message;

  final int stadiumCapacity;
  final int estimatedAttendance;
  final int averageTicketPrice;

  final double stadiumMultiplier;
  final double formMultiplier;
  final double marketingMultiplier;
  final double randomMultiplier;

  const TicketRevenueResult({
    required this.amount,
    required this.message,
    required this.stadiumCapacity,
    required this.estimatedAttendance,
    required this.averageTicketPrice,
    required this.stadiumMultiplier,
    required this.formMultiplier,
    required this.marketingMultiplier,
    required this.randomMultiplier,
  });
}

class TicketRevenueService {
  const TicketRevenueService();

  TicketRevenueResult calculate({
    required String divisionId,
    required int stadiumLevel,
    required int marketingLevel,
    required int winStreak,
    required int drawStreak,
    required int loseStreak,
    required SeededRng rng,
    int? expectationDeltaPoints,
  }) {
    final safeStadium = stadiumLevel.clamp(1, 10);
    final safeMarketing = marketingLevel.clamp(1, 10);

    final capacity = _capacityByStadiumLevel(safeStadium);
    final occupancyRate = _occupancyRateByMarketingLevel(safeMarketing);
    final baseAttendance = (capacity * occupancyRate).round();

    final momentPoints = expectationDeltaPoints ??
        _temporaryMomentPointsFromStreaks(
          winStreak: winStreak,
          drawStreak: drawStreak,
          loseStreak: loseStreak,
        );

    final attendance = (baseAttendance + (momentPoints * 2000)).clamp(
      0,
      capacity,
    );

    final averageTicketPrice = _averageTicketPriceByDivision(divisionId);
    final amount = attendance * averageTicketPrice;

    return TicketRevenueResult(
      amount: amount,
      message: _buildMessage(
        amount: amount,
        attendance: attendance,
        capacity: capacity,
        stadiumLevel: safeStadium,
        marketingLevel: safeMarketing,
        momentPoints: momentPoints,
        averageTicketPrice: averageTicketPrice,
      ),
      stadiumCapacity: capacity,
      estimatedAttendance: attendance,
      averageTicketPrice: averageTicketPrice,
      stadiumMultiplier: 1.0,
      formMultiplier: 1.0,
      marketingMultiplier: occupancyRate,
      randomMultiplier: 1.0,
    );
  }

  int _capacityByStadiumLevel(int level) {
    return switch (level) {
      1 => 10000,
      2 => 15000,
      3 => 20000,
      4 => 25000,
      5 => 30000,
      6 => 35000,
      7 => 40000,
      8 => 45000,
      9 => 55000,
      _ => 65000,
    };
  }

  double _occupancyRateByMarketingLevel(int level) {
    return switch (level) {
      1 => 0.30,
      2 => 0.40,
      3 => 0.50,
      4 => 0.58,
      5 => 0.65,
      6 => 0.72,
      7 => 0.78,
      8 => 0.84,
      9 => 0.90,
      _ => 0.95,
    };
  }

  int _averageTicketPriceByDivision(String divisionId) {
    final raw = divisionId.trim().toUpperCase();

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
      return 60;
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
      return 40;
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
      return 25;
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
      return 15;
    }

    return 15;
  }

  int _temporaryMomentPointsFromStreaks({
    required int winStreak,
    required int drawStreak,
    required int loseStreak,
  }) {
    if (winStreak >= 5) return 3;
    if (winStreak >= 3) return 2;
    if (winStreak >= 1) return 1;

    if (loseStreak >= 5) return -3;
    if (loseStreak >= 3) return -2;
    if (loseStreak >= 1) return -1;

    return 0;
  }

  String _buildMessage({
    required int amount,
    required int attendance,
    required int capacity,
    required int stadiumLevel,
    required int marketingLevel,
    required int momentPoints,
    required int averageTicketPrice,
  }) {
    final money = _formatMoney(amount);
    final publicText = _formatAudience(attendance);
    final capacityText = _formatAudience(capacity);

    if (attendance >= capacity) {
      return 'Casa cheia: $publicText torcedores compareceram ao estádio, atingindo a capacidade máxima de $capacityText. A operação de jogo gerou $money em receita de bilheteria.';
    }

    if (momentPoints >= 2) {
      return 'A boa fase aumentou a presença da torcida: $publicText torcedores no estádio. A receita operacional da partida gerou $money em bilheteria.';
    }

    if (momentPoints <= -2) {
      return 'A fase ruim reduziu a presença da torcida: $publicText torcedores compareceram ao estádio. Mesmo assim, o clube gerou $money em receita de bilheteria.';
    }

    if (marketingLevel >= 8) {
      return 'O bom trabalho de marketing ajudou a levar $publicText torcedores ao estádio. A operação da partida gerou $money em bilheteria.';
    }

    if (stadiumLevel >= 8) {
      return 'A estrutura do estádio recebeu $publicText torcedores nesta rodada. A renda operacional do jogo foi de $money.';
    }

    return 'O clube recebeu $publicText torcedores no jogo em casa e gerou $money em receita operacional de bilheteria.';
  }

  String _formatAudience(int value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      if (value % 1000 == 0) {
        return '${thousands.toStringAsFixed(0)} mil';
      }

      return '${thousands.toStringAsFixed(1)} mil';
    }

    return value.toString();
  }

  String _formatMoney(int value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)} mi';
    }

    return 'R\$ ${(value / 1000).toStringAsFixed(0)} mil';
  }
}
