// lib/domain/models/departamento_futebol.dart
//
// Departamento de Futebol (MVP)
// - Níveis 1..10
// - Model de DOMÍNIO (UI apenas consome)
// - Regras simples e estáveis para Mercado / Scout

class DepartamentoFutebol {
  // =============================
  // Níveis (1..10)
  // =============================

  int olheirosNivel;
  int negociacaoNivel;
  int analiseNivel;
  int planejamentoNivel;

  DepartamentoFutebol({
    int? olheirosNivel,
    int? negociacaoNivel,
    int? analiseNivel,
    int? planejamentoNivel,
  })  : olheirosNivel = _clamp10(olheirosNivel ?? 1),
        negociacaoNivel = _clamp10(negociacaoNivel ?? 1),
        analiseNivel = _clamp10(analiseNivel ?? 1),
        planejamentoNivel = _clamp10(planejamentoNivel ?? 1);

  static int _clamp10(int v) => v.clamp(1, 10);

  // =============================
  // OLHEIROS / SCOUT
  // =============================

  /// Quantidade máxima de jogadores no relatório mensal
  int get maxResultadosRelatorio {
    if (olheirosNivel <= 2) return 4;
    if (olheirosNivel <= 4) return 6;
    if (olheirosNivel <= 6) return 8;
    if (olheirosNivel <= 8) return 10;
    return 12;
  }

  /// Texto amigável para UI (mercados disponíveis)
  String get rangeDescobertas {
    if (olheirosNivel >= 9) return 'Brasil + Mercosul + Internacional + Europa';
    if (olheirosNivel >= 7) return 'Brasil + Mercosul + Internacional';
    if (olheirosNivel >= 4) return 'Brasil + Mercosul';
    return 'Brasil';
  }

  /// Aderência do relatório ao filtro (0..1)
  double get _aderencia {
    if (olheirosNivel <= 2) return 0.45;
    if (olheirosNivel <= 4) return 0.60;
    if (olheirosNivel <= 6) return 0.75;
    if (olheirosNivel <= 8) return 0.88;
    return 0.95;
  }

  /// 🔥 USADO NA UI
  /// Chance de o relatório vir fora do filtro
  double get chanceOffFiltro {
    final v = (1.0 - _aderencia).clamp(0.05, 0.65);
    return double.parse(v.toStringAsFixed(2));
  }

  /// 🔥 USADO NA UI
  /// Bônus leve de qualidade média (escala 1..10)
  double get bonusQualidadeMedia10 {
    final t = (olheirosNivel - 1) / 9.0; // 0..1
    final b = 0.45 * t; // máx +0.45
    return double.parse(b.toStringAsFixed(2));
  }

  // =============================
  // NEGOCIAÇÃO
  // =============================

  /// 🔥 USADO NA UI — desconto máximo na compra (%)
  int get descontoCompraPct {
    final pct = ((negociacaoNivel - 1) / 9.0) * 8.0;
    return pct.round().clamp(0, 15);
  }

  /// 🔥 USADO NA UI — desconto máximo no salário (%)
  int get descontoSalarioPct {
    final pct = ((negociacaoNivel - 1) / 9.0) * 6.0;
    return pct.round().clamp(0, 12);
  }

  /// 🔥 USADO NA UI — bônus máximo na venda (%)
  int get bonusVendaPct {
    final pct = ((negociacaoNivel - 1) / 9.0) * 10.0;
    return pct.round().clamp(0, 20);
  }

  // =============================
  // SERIALIZAÇÃO
  // =============================

  Map<String, dynamic> toJson() => {
        'olheirosNivel': olheirosNivel,
        'negociacaoNivel': negociacaoNivel,
        'analiseNivel': analiseNivel,
        'planejamentoNivel': planejamentoNivel,
      };

  factory DepartamentoFutebol.fromJson(Map<String, dynamic> json) {
    return DepartamentoFutebol(
      olheirosNivel: (json['olheirosNivel'] as num?)?.toInt(),
      negociacaoNivel: (json['negociacaoNivel'] as num?)?.toInt(),
      analiseNivel: (json['analiseNivel'] as num?)?.toInt(),
      planejamentoNivel: (json['planejamentoNivel'] as num?)?.toInt(),
    );
  }
}
