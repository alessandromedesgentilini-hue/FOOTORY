// lib/domain/data/finance_seeds.dart
//
// Finance seeds (MVP)
// OBS: No MVP atual, o GameState não depende mais deste arquivo.
// Mas ele pode existir para futuros upgrades (world persistente, seeds por clube).
//
// Objetivo agora: compilar SEM depender de métodos extras do FinanceiroClube.

import '../models/financeiro_clube.dart';

class FinanceSeed {
  final double caixa;
  final double divida;

  const FinanceSeed({
    required this.caixa,
    required this.divida,
  });

  FinanceiroClube toFinanceiro() {
    // ✅ compatível com qualquer versão do FinanceiroClube:
    // se tiver campos extras, eles têm default no construtor.
    return FinanceiroClube(
      caixa: caixa,
      divida: divida,
    );
  }
}

class FinanceSeeds {
  const FinanceSeeds._();

  /// Resolve um seed simples por divisão.
  /// (No futuro você pode usar clubId + seed para variar mais.)
  static FinanceSeed resolve({
    required String clubId,
    required String divisao,
    required int seed,
  }) {
    final d = divisao.toUpperCase();

    // bases por divisão
    double caixaBase;
    double dividaBase;

    switch (d) {
      case 'A':
        caixaBase = 120000000;
        dividaBase = 180000000;
        break;
      case 'B':
        caixaBase = 60000000;
        dividaBase = 220000000;
        break;
      case 'C':
        caixaBase = 35000000;
        dividaBase = 260000000;
        break;
      default:
        caixaBase = 20000000;
        dividaBase = 300000000;
        break;
    }

    // jitter determinístico leve (sem Random import, para manter simples)
    final mix = (seed ^ clubId.hashCode) & 0x7fffffff;
    final t = (mix % 2000) / 2000.0; // 0..0.999
    final factor = 0.90 + (t * 0.20); // 0.90..1.10

    return FinanceSeed(
      caixa: caixaBase * factor,
      divida: dividaBase * factor,
    );
  }
}
