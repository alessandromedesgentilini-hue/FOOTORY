// lib/services/match/style_tables.dart
import 'match_models.dart';

enum EstiloJogo {
  tikiTaka,
  gegenpress,
  transicaoRapida,
  cucaBall,
  sulAmericano,
}

/// Percentuais por grupo (precisam somar ~1.0)
class Distribuicao {
  final double atk;
  final double mid;
  final double def;
  final double other;

  const Distribuicao({
    required this.atk,
    required this.mid,
    required this.def,
    required this.other,
  });

  double get sum => atk + mid + def + other;

  double weight(PosGrupo g) {
    switch (g) {
      case PosGrupo.atk:
        return atk;
      case PosGrupo.mid:
        return mid;
      case PosGrupo.def:
        return def;
      case PosGrupo.other:
      case PosGrupo.gk:
        return other;
    }
  }
}

class StyleTable {
  final Distribuicao gols;
  final Distribuicao assists;

  const StyleTable({required this.gols, required this.assists});
}

/// Tabelas base (MVP). Ajustamos depois no balance.
const Map<EstiloJogo, StyleTable> kStyleTables = {
  EstiloJogo.tikiTaka: StyleTable(
    gols: Distribuicao(atk: 0.60, mid: 0.28, def: 0.10, other: 0.02),
    assists: Distribuicao(atk: 0.30, mid: 0.55, def: 0.13, other: 0.02),
  ),
  EstiloJogo.gegenpress: StyleTable(
    gols: Distribuicao(atk: 0.62, mid: 0.30, def: 0.06, other: 0.02),
    assists: Distribuicao(atk: 0.34, mid: 0.52, def: 0.12, other: 0.02),
  ),
  EstiloJogo.transicaoRapida: StyleTable(
    gols: Distribuicao(atk: 0.70, mid: 0.20, def: 0.08, other: 0.02),
    assists: Distribuicao(atk: 0.45, mid: 0.40, def: 0.13, other: 0.02),
  ),
  EstiloJogo.cucaBall: StyleTable(
    gols: Distribuicao(atk: 0.66, mid: 0.18, def: 0.14, other: 0.02),
    assists: Distribuicao(atk: 0.38, mid: 0.38, def: 0.22, other: 0.02),
  ),
  EstiloJogo.sulAmericano: StyleTable(
    gols: Distribuicao(atk: 0.64, mid: 0.26, def: 0.08, other: 0.02),
    assists: Distribuicao(atk: 0.36, mid: 0.50, def: 0.12, other: 0.02),
  ),
};

/// Helper pra tu mapear teu estilo atual (string / enum do teu projeto) pra este enum MVP.
/// Se tu já tem enum, tu troca aqui depois.
EstiloJogo estiloFromAny(dynamic v) {
  final s = v.toString().toLowerCase();
  if (s.contains("tiki")) return EstiloJogo.tikiTaka;
  if (s.contains("gegen") || s.contains("press")) return EstiloJogo.gegenpress;
  if (s.contains("trans")) return EstiloJogo.transicaoRapida;
  if (s.contains("cuca")) return EstiloJogo.cucaBall;
  return EstiloJogo.sulAmericano;
}
