// lib/models/pe_preferencial.dart
//
// Pé preferencial do jogador (com aliases para compat).
// - Mantém valores clássicos: direito, esquerdo, ambos
// - Adiciona alias `destro` para compat com branches antigos
// - Helpers: label, slug, parsing tolerante, utilidades de UI

enum PePreferencial {
  direito,
  esquerdo,
  ambos,

  /// Alias de compat (equivalente a [direito]).
  destro,
}

extension PePreferencialX on PePreferencial {
  /// Rótulo amigável para UI.
  String get label {
    switch (this) {
      case PePreferencial.direito:
      case PePreferencial.destro:
        return 'Direito';
      case PePreferencial.esquerdo:
        return 'Esquerdo';
      case PePreferencial.ambos:
        return 'Ambos';
    }
  }

  /// Slug estável (útil para persistência/telemetria).
  /// R = direito/destro, L = esquerdo, A = ambos
  String get slug {
    switch (this) {
      case PePreferencial.direito:
      case PePreferencial.destro:
        return 'R';
      case PePreferencial.esquerdo:
        return 'L';
      case PePreferencial.ambos:
        return 'A';
    }
  }

  bool get isDireito =>
      this == PePreferencial.direito || this == PePreferencial.destro;
  bool get isEsquerdo => this == PePreferencial.esquerdo;
  bool get isAmbos => this == PePreferencial.ambos;

  /// Texto curto para listas (R/L/A).
  String get curto => slug;

  /// Serialização simples (mesmo que [slug]).
  String toJson() => slug;

  /// Inverte o pé (útil para treinos específicos).
  PePreferencial get invertido {
    if (isAmbos) return PePreferencial.ambos;
    return isDireito ? PePreferencial.esquerdo : PePreferencial.direito;
  }

  // ======= Parsing / Compat =======

  /// Faz o parse tolerante a:
  /// - nomes: "direito", "esquerdo", "ambos", "destro", "canhoto", "ambidestro"
  /// - slugs: "R", "L", "A"
  /// - inglês: "right", "left", "both", "ambidextrous"
  static PePreferencial fromString(
    String? s, {
    PePreferencial fallback = PePreferencial.direito,
  }) {
    final t = (s ?? '').trim().toLowerCase();

    switch (t) {
      // direito
      case 'r':
      case 'd':
      case 'dir':
      case 'direito':
      case 'destro':
      case 'right':
        return PePreferencial.direito;

      // esquerdo
      case 'l':
      case 'e':
      case 'esq':
      case 'esquerdo':
      case 'canhoto':
      case 'left':
        return PePreferencial.esquerdo;

      // ambos
      case 'a':
      case 'ambos':
      case 'ambidestro':
      case 'ambidextrous':
      case 'both':
        return PePreferencial.ambos;

      default:
        return fallback;
    }
  }

  /// Parse a partir de qualquer objeto (útil em JSON).
  /// Aceita enum, índice, nome, slug ou string.
  static PePreferencial fromJson(Object? v, {PePreferencial? fallback}) {
    if (v is PePreferencial) return v;

    // índice do enum
    if (v is int && v >= 0 && v < PePreferencial.values.length) {
      return PePreferencial.values[v];
    }

    // nome do enum (ex.: "direito", "esquerdo", "ambos", "destro")
    if (v is String) {
      // Tenta bater com name exato do enum
      final lower = v.trim().toLowerCase();
      for (final e in PePreferencial.values) {
        if (e.name.toLowerCase() == lower) return e;
      }
      // Tenta parsing tolerante
      return fromString(v, fallback: fallback ?? PePreferencial.direito);
    }

    return fallback ?? PePreferencial.direito;
  }
}
