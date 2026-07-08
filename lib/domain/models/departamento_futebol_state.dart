// lib/domain/models/departamento_futebol.dart
//
// Departamento de Futebol (MVP) — compatível com a UI atual
// - Níveis 1..10 para: Olheiros, Negociação, Análise, Planejamento
// - Getters esperados pela DepartamentoFutebolPage:
//
//   rangeDescobertas
//   chanceOffFiltro
//   bonusQualidadeMedia10
//   descontoCompraPct
//   descontoSalarioPct
//   bonusVendaPct
//   planejamentoNivel
//
// Além disso, mantém os getters úteis pro Scout/Mercado:
//   liberaMercosul / liberaInternacional / liberaEuropa
//   maxResultadosRelatorio / maxFiltros / aderencia
//
// Importante: isso é DOMÍNIO. Regras avançadas ficam em services.

class DepartamentoFutebol {
  /// Nível do scouting/olheiros (1..10)
  int olheirosNivel;

  /// Nível do gerente/negociação (1..10)
  int negociacaoNivel;

  /// Nível de análise/relatórios (1..10)
  int analiseNivel;

  /// ✅ Nível de planejamento (1..10) — usado na UI e pode virar limite de alvos depois
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

  // =========================================================
  // Mercado por regiões (unlock por olheiros)
  // =========================================================

  bool get liberaMercosul => olheirosNivel >= 4;
  bool get liberaInternacional => olheirosNivel >= 7;
  bool get liberaEuropa => olheirosNivel >= 9;

  /// String amigável pra UI: quais mercados dá pra buscar.
  /// (A tua page chama isso de rangeDescobertas)
  String get rangeDescobertas {
    if (liberaEuropa) return 'Brasil + Mercosul + Internacional + Europa';
    if (liberaInternacional) return 'Brasil + Mercosul + Internacional';
    if (liberaMercosul) return 'Brasil + Mercosul';
    return 'Brasil';
  }

  // =========================================================
  // Scout/Mercado (MVP) — tamanho, filtros e aderência
  // =========================================================

  /// Quantos jogadores aparecem no relatório mensal.
  int get maxResultadosRelatorio {
    if (olheirosNivel <= 2) return 4;
    if (olheirosNivel <= 4) return 6;
    if (olheirosNivel <= 6) return 8;
    if (olheirosNivel <= 8) return 10;
    return 12;
  }

  /// Quantos filtros o usuário consegue assinalar.
  int get maxFiltros {
    if (olheirosNivel <= 2) return 2;
    if (olheirosNivel <= 4) return 3;
    if (olheirosNivel <= 6) return 4;
    if (olheirosNivel <= 8) return 5;
    return 6;
  }

  /// Aderência do relatório ao pedido.
  /// 0.0 ruim | 1.0 perfeito. Fica “bom de verdade” acima do nível 6.
  double get aderencia {
    if (olheirosNivel <= 2) return 0.45;
    if (olheirosNivel <= 4) return 0.60;
    if (olheirosNivel <= 6) return 0.75;
    if (olheirosNivel <= 8) return 0.88;
    return 0.95;
  }

  /// ✅ (UI) chance do relatório vir “off filtro”.
  /// Ex.: pediu B e vem C/D porque não achou ou porque é impreciso.
  /// Aqui a tua page chama `chanceOffFiltro`.
  ///
  /// Observação: isso NÃO é “mentir”, é aderência/escassez.
  double get chanceOffFiltro {
    // inverso de aderência, com limites realistas
    final x = (1.0 - aderencia).clamp(0.05, 0.65);
    return double.parse(x.toStringAsFixed(2));
  }

  /// ✅ (UI) bônus de qualidade média (em pontos na escala 1..10) para relatórios melhores.
  /// A tua page chama `bonusQualidadeMedia10`.
  ///
  /// MVP: é só informativo; o service pode usar depois.
  double get bonusQualidadeMedia10 {
    // sobe bem pouco (não explode o jogo)
    // 1 -> +0.00, 5 -> +0.20, 10 -> +0.45
    final t = (olheirosNivel - 1) / 9.0; // 0..1
    final b = 0.45 * t;
    return double.parse(b.toStringAsFixed(2));
  }

  // =========================================================
  // Negociação (descontos/bonus) — usado no mercado depois
  // =========================================================

  /// ✅ (UI) desconto máximo na compra (em %)
  /// Ex.: 7 => ~3.5%
  int get descontoCompraPct {
    // 1 -> 0%, 10 -> 8%
    final pct = ((negociacaoNivel - 1) / 9.0) * 8.0;
    return pct.round().clamp(0, 12);
  }

  /// ✅ (UI) desconto máximo em salário (em %)
  int get descontoSalarioPct {
    // 1 -> 0%, 10 -> 6%
    final pct = ((negociacaoNivel - 1) / 9.0) * 6.0;
    return pct.round().clamp(0, 10);
  }

  /// ✅ (UI) bônus máximo na venda (em %)
  int get bonusVendaPct {
    // 1 -> 0%, 10 -> 10%
    final pct = ((negociacaoNivel - 1) / 9.0) * 10.0;
    return pct.round().clamp(0, 15);
  }

  // =========================================================
  // Save / Load
  // =========================================================

  Map<String, dynamic> toJson() => {
        'olheirosNivel': olheirosNivel,
        'negociacaoNivel': negociacaoNivel,
        'analiseNivel': analiseNivel,
        'planejamentoNivel': planejamentoNivel,
      };

  static DepartamentoFutebol fromJson(Map<String, dynamic> m) {
    return DepartamentoFutebol(
      olheirosNivel: (m['olheirosNivel'] as num?)?.toInt(),
      negociacaoNivel: (m['negociacaoNivel'] as num?)?.toInt(),
      analiseNivel: (m['analiseNivel'] as num?)?.toInt(),
      planejamentoNivel: (m['planejamentoNivel'] as num?)?.toInt(),
    );
  }
}
