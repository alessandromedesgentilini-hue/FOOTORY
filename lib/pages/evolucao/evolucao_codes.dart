// lib/services/evolucao_codes.dart
//
// Catálogo de códigos de Evolução — versão final robusta.
// Mantém compat 100% com os códigos existentes e adiciona utilitários:
//
// • Faixas reservadas:
//    - 1xxx → Cartas de evolução (ex.: 1001)
//    - 2xxx → Planos de treino/evolução (ex.: 2001..2003, 2099)
// • Helpers:
//    - isCarta(int), isPlano(int)
//    - label(int) → rótulo amigável
//    - allCartas / allPlanos → conjuntos para validação/listas
//    - safeFromLabel(String) → resolve por rótulo/slug (opcional)
//
// Observação: mantenha os "const int" abaixo inalterados para não quebrar saves.

class EvolucaoCodes {
  EvolucaoCodes._(); // estático utilitário

  // ───────────────────────────────────────────────────────────────────────────
  // CARTAS (1xxx)
  // ───────────────────────────────────────────────────────────────────────────
  /// Carta que prioriza ganhos técnicos (ex.: +Técnica em ciclos de treino).
  static const int cartaMaisTecnica = 1001;

  // ───────────────────────────────────────────────────────────────────────────
  // PLANOS (2xxx)
  // ───────────────────────────────────────────────────────────────────────────
  /// Plano focado em métricas ofensivas/ataque.
  static const int planoOfensivo = 2001;

  /// Plano focado em métricas defensivas/retaguarda.
  static const int planoDefensivo = 2002;

  /// Plano equilibrado (meio-termo entre ataque/defesa).
  static const int planoEquilibrado = 2003;

  /// Plano custom (livre), definido pelo usuário ou branch específico.
  static const int planoCustom = 2099;

  // ───────────────────────────────────────────────────────────────────────────
  // Catálogos/labels (para UI, logs e validação)
  // ───────────────────────────────────────────────────────────────────────────

  static const Map<int, String> _cardLabels = {
    cartaMaisTecnica: 'Carta: Mais técnica',
  };

  static const Map<int, String> _planoLabels = {
    planoOfensivo: 'Plano ofensivo',
    planoDefensivo: 'Plano defensivo',
    planoEquilibrado: 'Plano equilibrado',
    planoCustom: 'Plano custom',
  };

  /// Conjunto com todos os códigos de carta conhecidos.
  static const Set<int> allCartas = {cartaMaisTecnica};

  /// Conjunto com todos os códigos de plano conhecidos.
  static const Set<int> allPlanos = {
    planoOfensivo,
    planoDefensivo,
    planoEquilibrado,
    planoCustom,
  };

  // ───────────────────────────────────────────────────────────────────────────
  // Helpers públicos
  // ───────────────────────────────────────────────────────────────────────────

  /// Retorna `true` se o [code] pertence ao espaço de cartas 1xxx.
  static bool isCarta(int code) =>
      code >= 1000 && code < 2000 && allCartas.contains(code);

  /// Retorna `true` se o [code] pertence ao espaço de planos 2xxx.
  static bool isPlano(int code) =>
      code >= 2000 && code < 3000 && allPlanos.contains(code);

  /// Rótulo amigável para qualquer código suportado.
  /// Se desconhecido, retorna "Desconhecido (#code)".
  static String label(int code) =>
      _cardLabels[code] ?? _planoLabels[code] ?? 'Desconhecido ($code)';

  /// Resolve por rótulo "amigável" ou por **slug** simplificado.
  /// Exemplos aceitos:
  ///  - "Carta: Mais técnica", "mais_tecnica", "carta_mais_tecnica"
  ///  - "Plano ofensivo", "ofensivo", "plano_ofensivo"
  static int? safeFromLabel(String input) {
    final n = _normalize(input);

    // cartas
    if (n == 'mais_tecnica' || n == 'carta_mais_tecnica') {
      return cartaMaisTecnica;
    }

    // planos
    if (n == 'ofensivo' || n == 'plano_ofensivo') return planoOfensivo;
    if (n == 'defensivo' || n == 'plano_defensivo') return planoDefensivo;
    if (n == 'equilibrado' || n == 'plano_equilibrado') return planoEquilibrado;
    if (n == 'custom' || n == 'plano_custom') return planoCustom;

    return null;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Internals
  // ───────────────────────────────────────────────────────────────────────────

  static String _normalize(String s) {
    var t = s.trim().toLowerCase();

    // remove acentos
    t = t
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');

    // normaliza separadores → underscore
    t = t.replaceAll(RegExp(r'[\s\-]+'), '_').replaceAll(RegExp(r'_+'), '_');

    // remove underscores nas pontas
    if (t.startsWith('_')) t = t.substring(1);
    if (t.endsWith('_')) t = t.substring(0, t.length - 1);
    return t;
  }
}
