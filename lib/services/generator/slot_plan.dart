// lib/services/generator/slot_plan.dart
//
// Plano canônico de distribuição de posições (titulares + reservas) e
// perfis por posição (pesos dos grupos de atributos: of/def/tec/men/fis).
//
// Este arquivo é estável e pensado para "versão final":
//  • `SlotPlan` é imutável em runtime (Map.unmodifiable).
//  • `kSlot433` define um elenco 4-3-3 padrão (11 + banco).
//  • `kPerfisPosicao` traz pesos por posição para cálculo/geração.
//  • Helpers utilitários no final para enumerar slots e validar.
//
// Dependência: models/posicao.dart (enum Posicao).

import 'package:futsim/models/posicao.dart';

/// Plano de slots (titulares + reservas).
class SlotPlan {
  /// Quantidade por posição entre os TITULARES. Ex.: { GK:1, CB:2, ... }
  final Map<Posicao, int> titulares;

  /// Quantidade por posição entre os RESERVAS. Ex.: { GK:1, CB:2, ... }
  final Map<Posicao, int> reservas;

  const SlotPlan._({
    required this.titulares,
    required this.reservas,
  });

  /// Constrói um plano imutável em runtime.
  ///
  /// - Valores não positivos são descartados.
  /// - Os mapas retornados são `Map.unmodifiable`.
  factory SlotPlan({
    required Map<Posicao, int> titulares,
    required Map<Posicao, int> reservas,
  }) {
    Map<Posicao, int> sanitize(Map<Posicao, int> m) {
      final out = <Posicao, int>{};
      for (final e in m.entries) {
        final v = e.value;
        if (v > 0) out[e.key] = v;
      }
      return Map<Posicao, int>.unmodifiable(out);
    }

    return SlotPlan._(
      titulares: sanitize(titulares),
      reservas: sanitize(reservas),
    );
  }

  /// Quantidade total de titulares.
  int get totalTitulares => titulares.values.fold<int>(0, (sum, n) => sum + n);

  /// Quantidade total de reservas planejadas.
  int get totalReservas => reservas.values.fold<int>(0, (sum, n) => sum + n);

  /// Total de slots (titulares + reservas).
  int get totalSlots => totalTitulares + totalReservas;

  /// Lista expandida de posições de titulares (ex.: [GK, RB, CB, CB, ...]).
  List<Posicao> titularesExpandido() => _expandMap(titulares);

  /// Lista expandida de posições de reservas (ex.: [GK, CB, CB, ...]).
  List<Posicao> reservasExpandido() => _expandMap(reservas);

  List<Posicao> _expandMap(Map<Posicao, int> m) {
    final out = <Posicao>[];
    for (final e in m.entries) {
      for (var i = 0; i < e.value; i++) {
        out.add(e.key);
      }
    }
    return out;
  }

  /// Valida se o plano parece coerente (ex.: 11 titulares).
  bool isCoerente({int titularesEsperado = 11}) {
    if (totalTitulares != titularesEsperado) return false;

    // Pelo menos 1 goleiro no elenco (titulares + reservas).
    final gkTotal = (titulares[Posicao.GK] ?? 0) + (reservas[Posicao.GK] ?? 0);
    if (gkTotal < 1) return false;

    return true;
  }

  @override
  String toString() =>
      'SlotPlan(titulares=$titulares, reservas=$reservas, total=$totalSlots)';
}

/// 4-3-3 base (11 titulares + banco variado).
final SlotPlan kSlot433 = SlotPlan(
  titulares: <Posicao, int>{
    Posicao.GK: 1,
    Posicao.RB: 1,
    Posicao.CB: 2,
    Posicao.LB: 1,
    Posicao.CM: 2,
    Posicao.AM: 1,
    Posicao.RW: 1,
    Posicao.LW: 1,
    Posicao.ST: 1,
  },
  reservas: <Posicao, int>{
    Posicao.GK: 1,
    Posicao.CB: 2,
    Posicao.RB: 1,
    Posicao.LB: 1,
    Posicao.DM: 1,
    Posicao.CM: 2,
    Posicao.AM: 1,
    Posicao.RW: 1,
    Posicao.LW: 1,
    Posicao.ST: 1,
  },
);

/// Pesos por posição para distribuir os grupos (of/def/tec/men/fis).
/// Mantidos imutáveis com Map.unmodifiable.
final Map<Posicao, Map<String, int>> kPerfisPosicao =
    Map<Posicao, Map<String, int>>.unmodifiable({
  Posicao.GK: const {'of': 1, 'def': 5, 'tec': 3, 'men': 4, 'fis': 4},
  Posicao.CB: const {'of': 1, 'def': 5, 'tec': 2, 'men': 3, 'fis': 5},
  Posicao.RB: const {'of': 2, 'def': 4, 'tec': 3, 'men': 3, 'fis': 4},
  Posicao.LB: const {'of': 2, 'def': 4, 'tec': 3, 'men': 3, 'fis': 4},
  Posicao.DM: const {'of': 2, 'def': 4, 'tec': 4, 'men': 4, 'fis': 3},
  Posicao.CM: const {'of': 3, 'def': 3, 'tec': 4, 'men': 4, 'fis': 3},
  Posicao.AM: const {'of': 5, 'def': 1, 'tec': 5, 'men': 4, 'fis': 2},
  Posicao.RW: const {'of': 5, 'def': 1, 'tec': 4, 'men': 3, 'fis': 4},
  Posicao.LW: const {'of': 5, 'def': 1, 'tec': 4, 'men': 3, 'fis': 4},
  Posicao.ST: const {'of': 5, 'def': 1, 'tec': 4, 'men': 3, 'fis': 4},
});

/// --------- Helpers opcionais ---------

/// Retorna uma lista ordenada e expandida de slots (titulares antes de reservas).
List<Posicao> expandSlots433({SlotPlan? plan}) {
  final effective = plan ?? kSlot433;
  final out = <Posicao>[];
  out.addAll(effective.titularesExpandido());
  out.addAll(effective.reservasExpandido());
  return out;
}

/// Verifica coerência do 4-3-3 padrão.
bool isSlot433Coerente() => kSlot433.isCoerente();

/// Sugere um banco “mínimo” (posições chave) caso queira reduzir reservas.
List<Posicao> bancoMinimo() {
  // 1 GK, 1 zagueiro, 1 lateral, 1 volante, 1 meia, 1 ponta, 1 centroavante
  return const [
    Posicao.GK,
    Posicao.CB,
    Posicao.RB,
    Posicao.DM,
    Posicao.AM,
    Posicao.RW,
    Posicao.ST,
  ];
}
