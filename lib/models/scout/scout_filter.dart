// lib/models/scout/scout_filter.dart
import 'attribute_grade.dart';

enum ScoutMarketRegion { brasil, mercosul, internacional, europa }

enum ScoutMacroPos { GOL, DEF, MEI, ATA }

enum ScoutAgeBand { u20, a21_24, a25_29, a30_33, a34mais }

enum ScoutContractStatus { livre, curto, medio, longo }

enum ScoutPillar { ofensivo, defensivo, tecnico, mental, fisico }

class ScoutFilter {
  final Set<ScoutMarketRegion> regioes;
  final Set<ScoutMacroPos> posicoes;
  final Set<ScoutAgeBand> idades;
  final Set<ScoutContractStatus> contrato;

  /// Valor máximo estimado (BRL)
  final int? valorMax;

  /// Ex.: ofensivo >= B, fisico >= C...
  final Map<ScoutPillar, AttributeGrade> minPilares;

  const ScoutFilter({
    this.regioes = const {ScoutMarketRegion.brasil},
    this.posicoes = const {},
    this.idades = const {},
    this.contrato = const {},
    this.valorMax,
    this.minPilares = const {},
  });

  ScoutFilter copyWith({
    Set<ScoutMarketRegion>? regioes,
    Set<ScoutMacroPos>? posicoes,
    Set<ScoutAgeBand>? idades,
    Set<ScoutContractStatus>? contrato,
    int? valorMax,
    Map<ScoutPillar, AttributeGrade>? minPilares,
  }) {
    return ScoutFilter(
      regioes: regioes ?? this.regioes,
      posicoes: posicoes ?? this.posicoes,
      idades: idades ?? this.idades,
      contrato: contrato ?? this.contrato,
      valorMax: valorMax ?? this.valorMax,
      minPilares: minPilares ?? this.minPilares,
    );
  }

  Map<String, dynamic> toJson() => {
        'regioes': regioes.map((e) => e.name).toList(),
        'posicoes': posicoes.map((e) => e.name).toList(),
        'idades': idades.map((e) => e.name).toList(),
        'contrato': contrato.map((e) => e.name).toList(),
        'valorMax': valorMax,
        'minPilares': {
          for (final e in minPilares.entries) e.key.name: e.value.name,
        },
      };
}
