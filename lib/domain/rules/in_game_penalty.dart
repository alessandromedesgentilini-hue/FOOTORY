// lib/domain/rules/in_game_penalty.dart
//
// A4 — Penalidade in-game por jogar fora de posição (FutSim)
//
// Regras canônicas:
// - Penalidade só existe DURANTE a partida (tela tática / simulação)
// - Mercado, elenco e UI geral mostram SEMPRE o OVR da função principal
// - Penalidade aplica apenas aos 10 atributos da função em campo
// - Atributos não usados pela função NÃO entram no cálculo
// - Penalidade padrão: −25% (fator 0.75)
// - Arredondamento: round() e clamp 1..10
//
// Exemplo:
// Velocidade 7 fora de posição → 7 × 0.75 = 5.25 → 5

class InGamePenalty {
  const InGamePenalty._();

  /// Penalidade padrão canônica (−25%)
  static const double fatorPadrao = 0.75;

  /// Alternativa caso queira testar −30% no futuro
  static const double fatorSevero = 0.70;

  /// Aplica penalidade a UM atributo individual
  static int aplicar({
    required int valorBase,
    double fator = fatorPadrao,
  }) {
    final base = valorBase.clamp(1, 10);
    final penalizado = (base * fator).round();
    return penalizado.clamp(1, 10);
  }

  /// Aplica penalidade a uma lista de atributos
  static List<int> aplicarEmLista({
    required List<int> valores,
    double fator = fatorPadrao,
  }) {
    return valores.map((v) => aplicar(valorBase: v, fator: fator)).toList();
  }

  /// Aplica penalidade em um MAPA de atributos (Atributo → valor)
  /// Muito usado na simulação de partida
  static Map<T, int> aplicarEmMapa<T>({
    required Map<T, int> atributos,
    double fator = fatorPadrao,
  }) {
    final out = <T, int>{};
    atributos.forEach((k, v) {
      out[k] = aplicar(valorBase: v, fator: fator);
    });
    return out;
  }

  /// Decide automaticamente se aplica penalidade
  /// - Se habilitado: retorna valor original
  /// - Se NÃO habilitado: retorna valor penalizado
  static int aplicarSeNecessario({
    required int valorBase,
    required bool funcaoHabilitada,
    double fator = fatorPadrao,
  }) {
    if (funcaoHabilitada) return valorBase.clamp(1, 10);
    return aplicar(valorBase: valorBase, fator: fator);
  }

  /// Versão utilitária pra debug/UI
  static String descricao({
    required bool funcaoHabilitada,
    double fator = fatorPadrao,
  }) {
    if (funcaoHabilitada) return 'Sem penalidade';
    final pct = ((1 - fator) * 100).round();
    return 'Fora de posição (−$pct%)';
  }
}
