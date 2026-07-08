import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

enum ClubHistoricalSize {
  small,
  medium,
  big,
}

enum ClubStatusTier {
  tiny,
  small,
  medium,
  big,
  giant,
}

class ClubStatusSnapshot {
  final ClubHistoricalSize historicalSize;
  final ClubStatusTier currentTier;

  final double clubPower;
  final int legacyPoints;
  final DivisionId divisionId;

  final int statusScore;

  final String label;
  final String pressure;
  final String expectation;
  final String narrativeContext;

  const ClubStatusSnapshot({
    required this.historicalSize,
    required this.currentTier,
    required this.clubPower,
    required this.legacyPoints,
    required this.divisionId,
    required this.statusScore,
    required this.label,
    required this.pressure,
    required this.expectation,
    required this.narrativeContext,
  });
}

class ClubStatusRuntimeService {
  const ClubStatusRuntimeService();

  ClubStatusSnapshot build({
    required ClubHistoricalSize historicalSize,
    required double clubPower10,
    required int legacyPoints,
    required DivisionId divisionId,
  }) {
    final normalizedPower = clubPower10.clamp(1.0, 10.0);

    final score = _statusScore(
      historicalSize: historicalSize,
      clubPower10: normalizedPower,
      legacyPoints: legacyPoints,
      divisionId: divisionId,
    );

    final tier = _tierFromScore(
      score: score,
      historicalSize: historicalSize,
      legacyPoints: legacyPoints,
      divisionId: divisionId,
      clubPower10: normalizedPower,
    );

    return ClubStatusSnapshot(
      historicalSize: historicalSize,
      currentTier: tier,
      clubPower: normalizedPower,
      legacyPoints: legacyPoints,
      divisionId: divisionId,
      statusScore: score,
      label: _label(tier),
      pressure: _pressure(tier),
      expectation: _expectation(tier),
      narrativeContext: _narrativeContext(
        historicalSize: historicalSize,
        currentTier: tier,
        legacyPoints: legacyPoints,
        clubPower10: normalizedPower,
        divisionId: divisionId,
      ),
    );
  }

  int _statusScore({
    required ClubHistoricalSize historicalSize,
    required double clubPower10,
    required int legacyPoints,
    required DivisionId divisionId,
  }) {
    final historicalScore = _historicalBaseScore(historicalSize);
    final powerBonus = _powerBonus(clubPower10);
    final divisionBonus = _divisionBonus(divisionId);
    final legacyBonus = _legacyBonus(legacyPoints);

    return (historicalScore + powerBonus + divisionBonus + legacyBonus)
        .clamp(0, 100);
  }

  int _historicalBaseScore(ClubHistoricalSize historicalSize) {
    switch (historicalSize) {
      case ClubHistoricalSize.small:
        return 22;
      case ClubHistoricalSize.medium:
        return 38;
      case ClubHistoricalSize.big:
        return 56;
    }
  }

  int _powerBonus(double clubPower10) {
    final p = clubPower10.clamp(1.0, 10.0);

    if (p >= 9.0) return 16;
    if (p >= 8.0) return 12;
    if (p >= 7.0) return 9;
    if (p >= 6.0) return 6;
    if (p >= 5.0) return 3;
    if (p >= 4.0) return 1;
    return 0;
  }

  int _divisionBonus(DivisionId divisionId) {
    switch (divisionId) {
      case DivisionId.brA:
        return 6;
      case DivisionId.brB:
        return 3;
      case DivisionId.brC:
        return 1;
      case DivisionId.brD:
        return 0;
    }
  }

  int _legacyBonus(int legacyPoints) {
    if (legacyPoints >= 90) return 24;
    if (legacyPoints >= 70) return 20;
    if (legacyPoints >= 50) return 16;
    if (legacyPoints >= 35) return 12;
    if (legacyPoints >= 22) return 8;
    if (legacyPoints >= 12) return 5;
    if (legacyPoints >= 4) return 2;
    if (legacyPoints <= -12) return -10;
    if (legacyPoints <= -8) return -7;
    if (legacyPoints < 0) return -4;
    return 0;
  }

  ClubStatusTier _tierFromScore({
    required int score,
    required ClubHistoricalSize historicalSize,
    required int legacyPoints,
    required DivisionId divisionId,
    required double clubPower10,
  }) {
    var tier = _rawTierFromScore(score);

    tier = _applyGrowthLocks(
      tier: tier,
      historicalSize: historicalSize,
      legacyPoints: legacyPoints,
      divisionId: divisionId,
      clubPower10: clubPower10,
    );

    return tier;
  }

  ClubStatusTier _rawTierFromScore(int score) {
    if (score >= 82) return ClubStatusTier.giant;
    if (score >= 68) return ClubStatusTier.big;
    if (score >= 52) return ClubStatusTier.medium;
    if (score >= 36) return ClubStatusTier.small;
    return ClubStatusTier.tiny;
  }

  ClubStatusTier _applyGrowthLocks({
    required ClubStatusTier tier,
    required ClubHistoricalSize historicalSize,
    required int legacyPoints,
    required DivisionId divisionId,
    required double clubPower10,
  }) {
    if (historicalSize == ClubHistoricalSize.small) {
      if (legacyPoints < 12 && _rank(tier) > _rank(ClubStatusTier.small)) {
        return ClubStatusTier.small;
      }

      if (legacyPoints < 35 && _rank(tier) > _rank(ClubStatusTier.medium)) {
        return ClubStatusTier.medium;
      }

      if (legacyPoints < 70 && _rank(tier) > _rank(ClubStatusTier.big)) {
        return ClubStatusTier.big;
      }
    }

    if (historicalSize == ClubHistoricalSize.medium) {
      if (legacyPoints < 22 && _rank(tier) > _rank(ClubStatusTier.medium)) {
        return ClubStatusTier.medium;
      }

      if (legacyPoints < 60 && _rank(tier) > _rank(ClubStatusTier.big)) {
        return ClubStatusTier.big;
      }
    }

    if (tier == ClubStatusTier.giant) {
      final canBeGiant = divisionId == DivisionId.brA &&
          clubPower10 >= 8.0 &&
          legacyPoints >= 70;

      if (!canBeGiant) return ClubStatusTier.big;
    }

    if (tier == ClubStatusTier.big) {
      final canBeBig = divisionId == DivisionId.brA ||
          legacyPoints >= 35 ||
          historicalSize == ClubHistoricalSize.big;

      if (!canBeBig) return ClubStatusTier.medium;
    }

    return tier;
  }

  int _rank(ClubStatusTier tier) {
    switch (tier) {
      case ClubStatusTier.tiny:
        return 0;
      case ClubStatusTier.small:
        return 1;
      case ClubStatusTier.medium:
        return 2;
      case ClubStatusTier.big:
        return 3;
      case ClubStatusTier.giant:
        return 4;
    }
  }

  String _label(ClubStatusTier tier) {
    switch (tier) {
      case ClubStatusTier.tiny:
        return 'Projeto pequeno';
      case ClubStatusTier.small:
        return 'Clube em crescimento';
      case ClubStatusTier.medium:
        return 'Clube consolidado';
      case ClubStatusTier.big:
        return 'Força nacional';
      case ClubStatusTier.giant:
        return 'Gigante do país';
    }
  }

  String _pressure(ClubStatusTier tier) {
    switch (tier) {
      case ClubStatusTier.tiny:
        return 'pressão baixa';
      case ClubStatusTier.small:
        return 'pressão moderada';
      case ClubStatusTier.medium:
        return 'cobrança por evolução';
      case ClubStatusTier.big:
        return 'pressão por campanhas fortes';
      case ClubStatusTier.giant:
        return 'cobrança máxima por títulos';
    }
  }

  String _expectation(ClubStatusTier tier) {
    switch (tier) {
      case ClubStatusTier.tiny:
        return 'sobreviver, crescer e criar base';
      case ClubStatusTier.small:
        return 'competir melhor e sonhar com acesso';
      case ClubStatusTier.medium:
        return 'brigar na parte alta e buscar estabilidade';
      case ClubStatusTier.big:
        return 'disputar títulos e vagas importantes';
      case ClubStatusTier.giant:
        return 'vencer títulos e protagonizar a temporada';
    }
  }

  String _narrativeContext({
    required ClubHistoricalSize historicalSize,
    required ClubStatusTier currentTier,
    required int legacyPoints,
    required double clubPower10,
    required DivisionId divisionId,
  }) {
    if (historicalSize == ClubHistoricalSize.small &&
        currentTier == ClubStatusTier.small &&
        divisionId == DivisionId.brA) {
      return 'Mesmo na elite, o clube ainda é visto como um projeto em crescimento. Campanhas seguras têm peso importante.';
    }

    if (historicalSize == ClubHistoricalSize.small &&
        currentTier == ClubStatusTier.medium) {
      return 'O clube deixou de ser apenas uma aposta e começa a ser visto como projeto consolidado.';
    }

    if (historicalSize == ClubHistoricalSize.small &&
        currentTier == ClubStatusTier.big) {
      return 'A trajetória já transformou um projeto modesto em força real, mas esse status veio de anos de construção.';
    }

    if (historicalSize == ClubHistoricalSize.small &&
        currentTier == ClubStatusTier.giant) {
      return 'O clube completou uma ascensão rara e agora é tratado como protagonista nacional.';
    }

    if (historicalSize == ClubHistoricalSize.big &&
        (currentTier == ClubStatusTier.tiny ||
            currentTier == ClubStatusTier.small)) {
      return 'A distância entre a história do clube e seu momento atual aumenta a cobrança por reconstrução.';
    }

    if (historicalSize == ClubHistoricalSize.big &&
        currentTier == ClubStatusTier.medium) {
      return 'O clube ainda carrega peso histórico, mas vive um momento de reconstrução competitiva.';
    }

    if (currentTier == ClubStatusTier.giant) {
      return 'O clube é tratado como protagonista nacional e qualquer oscilação vira assunto.';
    }

    if (currentTier == ClubStatusTier.big) {
      return 'O clube já é visto como força relevante e passa a ser cobrado por campanhas grandes.';
    }

    if (currentTier == ClubStatusTier.medium) {
      return 'O clube vive um estágio de consolidação e tenta transformar estabilidade em ambição.';
    }

    if (currentTier == ClubStatusTier.small) {
      return 'O clube ainda cresce aos poucos, mas já tem força para incomodar adversários maiores.';
    }

    return 'O clube ainda está em estágio inicial de construção esportiva.';
  }
}
