import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class SeasonExpectationSnapshot {
  final DivisionId division;

  /// Força real atual do usuário (1..10)
  final double userPower10;

  /// Força do usuário no início da temporada (1..10).
  /// Essa é a régua congelada para avaliar o ano.
  final double initialUserPower10;

  /// Estrelas baseadas no floor (0..10) e visual 0..5
  final int userStars10;
  final int userStars5;

  /// Expectativa congelada no início da temporada.
  final int initialExpectedBand;
  final String initialExpectedLabel;

  /// Expectativa e situação atual por band (0..4)
  final int expectedBand;
  final int currentBand;

  /// labels prontas pra UI
  final String expectedLabel;
  final String currentLabel;
  final String statusLabel;

  /// delta = esperado - atual (positivo = acima do esperado)
  final int delta;

  const SeasonExpectationSnapshot({
    required this.division,
    required this.userPower10,
    required this.initialUserPower10,
    required this.userStars10,
    required this.userStars5,
    required this.initialExpectedBand,
    required this.initialExpectedLabel,
    required this.expectedBand,
    required this.currentBand,
    required this.expectedLabel,
    required this.currentLabel,
    required this.statusLabel,
    required this.delta,
  });

  // ============================
  // 🔥 HELPERS (NARRATIVA)
  // ============================

  bool get isAboveExpectation => delta > 0;
  bool get isOnTrack => delta == 0;
  bool get isBelowExpectation => delta < 0;

  bool get isStrongAbove => delta >= 2;
  bool get isStrongBelow => delta <= -2;

  bool get isTitleContender => currentBand == 0;
  bool get isTopSide => currentBand <= 1;
  bool get isMidTable => currentBand == 2;
  bool get isBottomSide => currentBand >= 3;
  bool get isRelegationZone => currentBand == 4;

  bool get improvedPowerDuringSeason => userPower10 > initialUserPower10 + 0.25;

  // ============================
  // 🧠 FRASES PRONTAS (USO DIRETO)
  // ============================

  String get expectationSummary {
    return 'Expectativa inicial: $initialExpectedLabel';
  }

  String get currentExpectationSummary {
    return 'Expectativa atual: $expectedLabel';
  }

  String get currentSituationSummary {
    return 'Situação atual: $currentLabel';
  }

  String get performanceSummary {
    return 'Status: $statusLabel';
  }

  /// Texto curto pronto pra notícia/checkpoint
  String get narrativeLine {
    if (isStrongAbove) {
      return 'Campanha muito acima da expectativa inicial.';
    }

    if (isAboveExpectation) {
      return 'Campanha acima da expectativa inicial.';
    }

    if (isStrongBelow) {
      return 'Desempenho muito abaixo da expectativa inicial.';
    }

    if (isBelowExpectation) {
      return 'Abaixo da expectativa inicial até aqui.';
    }

    return 'Dentro da expectativa inicial até o momento.';
  }

  String get initialExpectationNarrativeLine {
    return 'A régua da temporada foi definida no início como: $initialExpectedLabel.';
  }

  // ============================
  // 💾 SAVE SYSTEM
  // ============================

  Map<String, dynamic> toJson() => {
        'division': division.name,
        'userPower10': userPower10,
        'initialUserPower10': initialUserPower10,
        'userStars10': userStars10,
        'userStars5': userStars5,
        'initialExpectedBand': initialExpectedBand,
        'initialExpectedLabel': initialExpectedLabel,
        'expectedBand': expectedBand,
        'currentBand': currentBand,
        'expectedLabel': expectedLabel,
        'currentLabel': currentLabel,
        'statusLabel': statusLabel,
        'delta': delta,
      };

  static SeasonExpectationSnapshot fromJson(Map<String, dynamic> json) {
    final divName = (json['division'] as String?) ?? DivisionId.brD.name;

    final division = DivisionId.values.firstWhere(
      (e) => e.name == divName,
      orElse: () => DivisionId.brD,
    );

    final expectedBand = (json['expectedBand'] as num?)?.toInt() ?? 2;
    final expectedLabel =
        (json['expectedLabel'] as String?) ?? 'Meio de Tabela';

    return SeasonExpectationSnapshot(
      division: division,
      userPower10: (json['userPower10'] as num?)?.toDouble() ?? 5.0,
      initialUserPower10: (json['initialUserPower10'] as num?)?.toDouble() ??
          (json['userPower10'] as num?)?.toDouble() ??
          5.0,
      userStars10: (json['userStars10'] as num?)?.toInt() ?? 5,
      userStars5: (json['userStars5'] as num?)?.toInt() ?? 2,
      initialExpectedBand:
          (json['initialExpectedBand'] as num?)?.toInt() ?? expectedBand,
      initialExpectedLabel:
          (json['initialExpectedLabel'] as String?) ?? expectedLabel,
      expectedBand: expectedBand,
      currentBand: (json['currentBand'] as num?)?.toInt() ?? 2,
      expectedLabel: expectedLabel,
      currentLabel: (json['currentLabel'] as String?) ?? 'Meio de Tabela',
      statusLabel: (json['statusLabel'] as String?) ?? 'Dentro do esperado',
      delta: (json['delta'] as num?)?.toInt() ?? 0,
    );
  }
}
