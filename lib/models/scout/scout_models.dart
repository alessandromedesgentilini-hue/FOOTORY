import 'package:flutter/foundation.dart';

enum ScoutRegion {
  brasil,
  americaSul,
  americaNorteCentral,
  europa,
  africa,
  asia,
  oceania,
}

extension ScoutRegionX on ScoutRegion {
  String get label {
    switch (this) {
      case ScoutRegion.brasil:
        return 'Brasil';
      case ScoutRegion.americaSul:
        return 'América do Sul';
      case ScoutRegion.americaNorteCentral:
        return 'Am. Norte/Central';
      case ScoutRegion.europa:
        return 'Europa';
      case ScoutRegion.africa:
        return 'África';
      case ScoutRegion.asia:
        return 'Ásia';
      case ScoutRegion.oceania:
        return 'Oceania';
    }
  }
}

enum MacroPos {
  goleiro,
  defesa,
  meio,
  ataque,
}

extension MacroPosX on MacroPos {
  String get label {
    switch (this) {
      case MacroPos.goleiro:
        return 'GOL';
      case MacroPos.defesa:
        return 'DEF';
      case MacroPos.meio:
        return 'MEI';
      case MacroPos.ataque:
        return 'ATA';
    }
  }
}

enum ScoutContractFilter {
  qualquer,
  livre,
  expiraAte6m,
  expiraAte12m,
  sobContrato,
}

extension ScoutContractFilterX on ScoutContractFilter {
  String get label {
    switch (this) {
      case ScoutContractFilter.qualquer:
        return 'Qualquer';
      case ScoutContractFilter.livre:
        return 'Livre';
      case ScoutContractFilter.expiraAte6m:
        return 'Expira em até 6m';
      case ScoutContractFilter.expiraAte12m:
        return 'Expira em até 12m';
      case ScoutContractFilter.sobContrato:
        return 'Sob contrato';
    }
  }
}

@immutable
class ScoutAgeRange {
  final int min;
  final int max;
  const ScoutAgeRange(this.min, this.max) : assert(min <= max);

  String get label => '$min–$max';

  static const ScoutAgeRange any = ScoutAgeRange(15, 45);
  static const List<ScoutAgeRange> presets = [
    ScoutAgeRange(16, 20),
    ScoutAgeRange(21, 24),
    ScoutAgeRange(25, 29),
    ScoutAgeRange(30, 33),
    ScoutAgeRange(34, 45),
  ];
}

/// Filtros por “assinalar opções”.
@immutable
class ScoutFilters {
  final Set<ScoutRegion> regions;
  final Set<MacroPos> macroPositions;
  final ScoutAgeRange ageRange;
  final ScoutContractFilter contractFilter;

  /// Valor máximo (moeda do seu jogo). Se null, ignora.
  final int? maxValue;

  /// Min Pillars A–E (1..10).
  /// Se null, ignora. Se setado, exige pillar >= min.
  final int? minPillarA;
  final int? minPillarB;
  final int? minPillarC;
  final int? minPillarD;
  final int? minPillarE;

  const ScoutFilters({
    required this.regions,
    required this.macroPositions,
    required this.ageRange,
    required this.contractFilter,
    required this.maxValue,
    required this.minPillarA,
    required this.minPillarB,
    required this.minPillarC,
    required this.minPillarD,
    required this.minPillarE,
  });

  factory ScoutFilters.defaults() {
    return const ScoutFilters(
      regions: {},
      macroPositions: {},
      ageRange: ScoutAgeRange.any,
      contractFilter: ScoutContractFilter.qualquer,
      maxValue: null,
      minPillarA: null,
      minPillarB: null,
      minPillarC: null,
      minPillarD: null,
      minPillarE: null,
    );
  }

  ScoutFilters copyWith({
    Set<ScoutRegion>? regions,
    Set<MacroPos>? macroPositions,
    ScoutAgeRange? ageRange,
    ScoutContractFilter? contractFilter,
    int? maxValue,
    int? minPillarA,
    int? minPillarB,
    int? minPillarC,
    int? minPillarD,
    int? minPillarE,
    bool clearMaxValue = false,
    bool clearA = false,
    bool clearB = false,
    bool clearC = false,
    bool clearD = false,
    bool clearE = false,
  }) {
    return ScoutFilters(
      regions: regions ?? this.regions,
      macroPositions: macroPositions ?? this.macroPositions,
      ageRange: ageRange ?? this.ageRange,
      contractFilter: contractFilter ?? this.contractFilter,
      maxValue: clearMaxValue ? null : (maxValue ?? this.maxValue),
      minPillarA: clearA ? null : (minPillarA ?? this.minPillarA),
      minPillarB: clearB ? null : (minPillarB ?? this.minPillarB),
      minPillarC: clearC ? null : (minPillarC ?? this.minPillarC),
      minPillarD: clearD ? null : (minPillarD ?? this.minPillarD),
      minPillarE: clearE ? null : (minPillarE ?? this.minPillarE),
    );
  }

  Map<String, dynamic> toJson() => {
        'regions': regions.map((e) => e.name).toList(),
        'macroPositions': macroPositions.map((e) => e.name).toList(),
        'ageMin': ageRange.min,
        'ageMax': ageRange.max,
        'contractFilter': contractFilter.name,
        'maxValue': maxValue,
        'minPillarA': minPillarA,
        'minPillarB': minPillarB,
        'minPillarC': minPillarC,
        'minPillarD': minPillarD,
        'minPillarE': minPillarE,
      };

  static ScoutFilters fromJson(Map<String, dynamic> json) {
    final regionsRaw = (json['regions'] as List?)?.cast<String>() ?? const [];
    final macroRaw =
        (json['macroPositions'] as List?)?.cast<String>() ?? const [];

    return ScoutFilters(
      regions: regionsRaw
          .map((s) => ScoutRegion.values.firstWhere((e) => e.name == s))
          .toSet(),
      macroPositions: macroRaw
          .map((s) => MacroPos.values.firstWhere((e) => e.name == s))
          .toSet(),
      ageRange: ScoutAgeRange(
        (json['ageMin'] as num?)?.toInt() ?? 15,
        (json['ageMax'] as num?)?.toInt() ?? 45,
      ),
      contractFilter: ScoutContractFilter.values.firstWhere(
        (e) =>
            e.name ==
            (json['contractFilter'] as String? ??
                ScoutContractFilter.qualquer.name),
      ),
      maxValue: (json['maxValue'] as num?)?.toInt(),
      minPillarA: (json['minPillarA'] as num?)?.toInt(),
      minPillarB: (json['minPillarB'] as num?)?.toInt(),
      minPillarC: (json['minPillarC'] as num?)?.toInt(),
      minPillarD: (json['minPillarD'] as num?)?.toInt(),
      minPillarE: (json['minPillarE'] as num?)?.toInt(),
    );
  }
}

/// Entrada do relatório mensal.
/// `score` é só para ordenação (quanto maior, mais "alvo" ele é).
@immutable
class ScoutReportEntry<TJogador> {
  final TJogador jogador;

  /// Identidade mínima para mostrar na UI (evita depender do seu model em 100 lugares).
  final String nome;
  final int idade;
  final MacroPos macroPos;
  final ScoutRegion region;

  /// OVR cheio (10..100) - soma dos 10 da função.
  final int ovr100;

  /// Estrelas (média 1..10 arredondada pra .5).
  final double estrelas;

  /// Valores auxiliares (se você tiver no seu model, preencha; senão deixa 0).
  final int valor;
  final int mesesContratoRestantes; // 0 = livre

  /// Pillars A–E (1..10). (Heurística no service; pode trocar depois.)
  final int pillarA;
  final int pillarB;
  final int pillarC;
  final int pillarD;
  final int pillarE;

  final double score;

  const ScoutReportEntry({
    required this.jogador,
    required this.nome,
    required this.idade,
    required this.macroPos,
    required this.region,
    required this.ovr100,
    required this.estrelas,
    required this.valor,
    required this.mesesContratoRestantes,
    required this.pillarA,
    required this.pillarB,
    required this.pillarC,
    required this.pillarD,
    required this.pillarE,
    required this.score,
  });
}

/// Estado do Centro de Olheiros (relatório 1x por mês).
@immutable
class ScoutCenterState {
  final ScoutFilters filters;

  /// monthKey do último relatório gerado.
  final String? lastReportMonthKey;

  /// Lista do último relatório (serialização opcional no futuro).
  /// Aqui guardamos apenas IDs/nomes básicos para UI.
  final List<ScoutReportSnapshot> lastReport;

  const ScoutCenterState({
    required this.filters,
    required this.lastReportMonthKey,
    required this.lastReport,
  });

  factory ScoutCenterState.initial() {
    return ScoutCenterState(
      filters: ScoutFilters.defaults(),
      lastReportMonthKey: null,
      lastReport: const [],
    );
  }

  ScoutCenterState copyWith({
    ScoutFilters? filters,
    String? lastReportMonthKey,
    List<ScoutReportSnapshot>? lastReport,
    bool clearReport = false,
  }) {
    return ScoutCenterState(
      filters: filters ?? this.filters,
      lastReportMonthKey: lastReportMonthKey ?? this.lastReportMonthKey,
      lastReport: clearReport ? const [] : (lastReport ?? this.lastReport),
    );
  }

  Map<String, dynamic> toJson() => {
        'filters': filters.toJson(),
        'lastReportMonthKey': lastReportMonthKey,
        'lastReport': lastReport.map((e) => e.toJson()).toList(),
      };

  static ScoutCenterState fromJson(Map<String, dynamic> json) {
    return ScoutCenterState(
      filters: ScoutFilters.fromJson(
          (json['filters'] as Map).cast<String, dynamic>()),
      lastReportMonthKey: json['lastReportMonthKey'] as String?,
      lastReport: ((json['lastReport'] as List?) ?? const [])
          .map((e) =>
              ScoutReportSnapshot.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

@immutable
class ScoutReportSnapshot {
  final String nome;
  final int idade;
  final String macroPos;
  final String region;
  final int ovr100;
  final double estrelas;
  final int valor;
  final int mesesContratoRestantes;

  const ScoutReportSnapshot({
    required this.nome,
    required this.idade,
    required this.macroPos,
    required this.region,
    required this.ovr100,
    required this.estrelas,
    required this.valor,
    required this.mesesContratoRestantes,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'idade': idade,
        'macroPos': macroPos,
        'region': region,
        'ovr100': ovr100,
        'estrelas': estrelas,
        'valor': valor,
        'mesesContratoRestantes': mesesContratoRestantes,
      };

  static ScoutReportSnapshot fromJson(Map<String, dynamic> json) {
    return ScoutReportSnapshot(
      nome: json['nome'] as String? ?? '—',
      idade: (json['idade'] as num?)?.toInt() ?? 0,
      macroPos: json['macroPos'] as String? ?? '—',
      region: json['region'] as String? ?? '—',
      ovr100: (json['ovr100'] as num?)?.toInt() ?? 0,
      estrelas: (json['estrelas'] as num?)?.toDouble() ?? 0.0,
      valor: (json['valor'] as num?)?.toInt() ?? 0,
      mesesContratoRestantes:
          (json['mesesContratoRestantes'] as num?)?.toInt() ?? 0,
    );
  }
}
