// lib/models/scout/scout_candidate.dart
import 'attribute_grade.dart';
import 'scout_filter.dart';

class ScoutCandidate {
  final String id;
  final String nomeExibicao;

  final ScoutMacroPos pos;
  final int idade;
  final ScoutMarketRegion regiao;
  final ScoutContractStatus contrato;

  final int valorEstimado;
  final int salarioEstimado;

  /// 5 pilares em A–E
  final Map<ScoutPillar, AttributeGrade> pilares;

  /// A–E (um tempero narrativo)
  final AttributeGrade adaptabilidade;

  const ScoutCandidate({
    required this.id,
    required this.nomeExibicao,
    required this.pos,
    required this.idade,
    required this.regiao,
    required this.contrato,
    required this.valorEstimado,
    required this.salarioEstimado,
    required this.pilares,
    required this.adaptabilidade,
  });
}
