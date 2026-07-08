// lib/models/scout/scout_report.dart
import 'scout_candidate.dart';
import 'scout_filter.dart';

class ScoutReport {
  final int temporadaAno;
  final int mes; // 1..12
  final ScoutFilter filtro;
  final List<ScoutCandidate> candidatos;
  final int olheirosNivel;
  final DateTime geradoEm;

  const ScoutReport({
    required this.temporadaAno,
    required this.mes,
    required this.filtro,
    required this.candidatos,
    required this.olheirosNivel,
    required this.geradoEm,
  });
}
