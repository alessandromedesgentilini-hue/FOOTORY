/// Códigos estáveis usados pelo EvolucaoService.
/// Troque os valores aqui se o serviço usar outros números.
class EvolucaoCodes {
  // --- Planos de treino (0..99) ---
  /// Foco em ataque (ex.: finalização, técnica, passe)
  static const int planoOfensivo = 0;

  /// Foco em defesa (ex.: marcação, interceptação, físico)
  static const int planoDefensivo = 1;

  /// Balanceado entre ataque e defesa
  static const int planoEquilibrado = 2;

  /// Plano criado na UI com pesos customizados
  static const int planoCustom = 3;

  // --- Cartas de evolução (100..199) ---
  /// Carta que concede +1 em Técnica
  static const int cartaMaisTecnica = 100;

  /// Exemplos (adicione se existir no serviço)
  static const int cartaMaisFisico = 101;
  static const int cartaMaisVisao = 102;
}
