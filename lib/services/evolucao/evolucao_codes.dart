// lib/services/evolucao/evolucao_codes.dart
//
// Códigos estáveis que a UI usa para acionar o serviço de evolução.
// - Mantém constantes numéricas para planos e cartas.
// - Inclui helpers utilitários (isPlano, isCarta, label, allPlanos, allCartas).
// - Evita instanciação (construtor privado).
//
// Observações:
// • Os valores abaixo são contratos: mudar exige migração do save/telemetria.
// • Adicione novos códigos sem reaproveitar números já usados.

class EvolucaoCodes {
  EvolucaoCodes._(); // não instanciável

  // ────────────────────── Planos de treino ──────────────────────
  static const int planoOfensivo = 100;
  static const int planoDefensivo = 101;
  static const int planoEquilibrado = 102;
  static const int planoCustom = 199;

  // Conjunto rápido para validação/menus
  static const Set<int> _planos = {
    planoOfensivo,
    planoDefensivo,
    planoEquilibrado,
    planoCustom,
  };

  // ─────────────────── Cartas de evolução (ex.) ─────────────────
  static const int cartaMaisTecnica = 300;
  static const int cartaMaisPasse = 301;
  static const int cartaMaisMarcacao = 302;

  static const Set<int> _cartas = {
    cartaMaisTecnica,
    cartaMaisPasse,
    cartaMaisMarcacao,
  };

  // ───────────────────────── Helpers ────────────────────────────
  static bool isPlano(int code) => _planos.contains(code);
  static bool isCarta(int code) => _cartas.contains(code);

  /// Lista apenas os códigos de planos (útil para menus/debug).
  static List<int> get allPlanos => _planos.toList()..sort();

  /// Lista apenas os códigos de cartas (útil para menus/debug).
  static List<int> get allCartas => _cartas.toList()..sort();

  /// Rótulo amigável para UI/logs.
  static String label(int code) {
    switch (code) {
      // Planos
      case planoOfensivo:
        return 'Plano Ofensivo';
      case planoDefensivo:
        return 'Plano Defensivo';
      case planoEquilibrado:
        return 'Plano Equilibrado';
      case planoCustom:
        return 'Plano Personalizado';
      // Cartas
      case cartaMaisTecnica:
        return 'Carta: +Técnica';
      case cartaMaisPasse:
        return 'Carta: +Passe';
      case cartaMaisMarcacao:
        return 'Carta: +Marcação';
      default:
        return 'Código $code';
    }
  }
}
