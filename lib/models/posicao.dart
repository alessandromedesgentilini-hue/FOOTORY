// ignore_for_file: constant_identifier_names

// lib/models/posicao.dart
//
// Enum detalhado com todas as posições + helpers completos:
// - Labels curtos (UI), nomes longos (descrições)
// - Macro posição (GOL/DEF/MEI/ATA)
// - Parsing tolerante (aceita abreviações, nomes em português/inglês)
// - Serialização/deserialização
// - Checagem de posição principal/secundária

enum Posicao {
  GK, // goleiro
  RB, // lateral direito
  CB, // zagueiro
  LB, // lateral esquerdo
  DM, // volante
  CM, // meio-campista central
  AM, // meia-atacante
  RW, // ponta direita
  LW, // ponta esquerda
  ST, // centroavante
}

extension PosicaoX on Posicao {
  // ======== Labels curtos para UI ========
  String get label {
    switch (this) {
      case Posicao.GK:
        return 'GOL';
      case Posicao.RB:
        return 'LD';
      case Posicao.CB:
        return 'ZAG';
      case Posicao.LB:
        return 'LE';
      case Posicao.DM:
        return 'VOL';
      case Posicao.CM:
        return 'MEI';
      case Posicao.AM:
        return 'MA';
      case Posicao.RW:
        return 'PD';
      case Posicao.LW:
        return 'PE';
      case Posicao.ST:
        return 'ATA';
    }
  }

  // ======== Nome completo da posição ========
  String get nomeCompleto {
    switch (this) {
      case Posicao.GK:
        return 'Goleiro';
      case Posicao.RB:
        return 'Lateral Direito';
      case Posicao.CB:
        return 'Zagueiro';
      case Posicao.LB:
        return 'Lateral Esquerdo';
      case Posicao.DM:
        return 'Volante';
      case Posicao.CM:
        return 'Meio-Campista';
      case Posicao.AM:
        return 'Meia-Atacante';
      case Posicao.RW:
        return 'Ponta Direita';
      case Posicao.LW:
        return 'Ponta Esquerda';
      case Posicao.ST:
        return 'Centroavante';
    }
  }

  // ======== Macro posição (GOL/DEF/MEI/ATA) ========
  String get macro {
    switch (this) {
      case Posicao.GK:
        return 'GOL';
      case Posicao.RB:
      case Posicao.CB:
      case Posicao.LB:
        return 'DEF';
      case Posicao.DM:
      case Posicao.CM:
      case Posicao.AM:
        return 'MEI';
      case Posicao.RW:
      case Posicao.LW:
      case Posicao.ST:
        return 'ATA';
    }
  }

  bool get isGoleiro => this == Posicao.GK;
  bool get isDefensor => macro == 'DEF';
  bool get isMeio => macro == 'MEI';
  bool get isAtacante => macro == 'ATA';

  // ======== Slug estável para persistência ========
  String get slug => name.toLowerCase();

  String toJson() => slug;

  // ======== Parsing tolerante ========
  static Posicao? parse(String? s) {
    if (s == null || s.trim().isEmpty) return null;

    final t = s.trim().toUpperCase();
    switch (t) {
      // Goleiro
      case 'GK':
      case 'GOL':
      case 'GOLEIRO':
        return Posicao.GK;

      // Laterais
      case 'RB':
      case 'LD':
      case 'LATERAL DIREITO':
        return Posicao.RB;

      case 'LB':
      case 'LE':
      case 'LATERAL ESQUERDO':
        return Posicao.LB;

      // Zagueiro
      case 'CB':
      case 'ZAG':
      case 'ZAGUEIRO':
        return Posicao.CB;

      // Meio-campo
      case 'DM':
      case 'VOL':
      case 'VOLANTE':
        return Posicao.DM;

      case 'CM':
      case 'MEI':
      case 'MC':
      case 'MEIO':
      case 'MEIO-CAMPISTA':
        return Posicao.CM;

      case 'AM':
      case 'MA':
      case 'MEIA':
      case 'MEIA-ATACANTE':
        return Posicao.AM;

      // Pontas e atacantes
      case 'RW':
      case 'PD':
      case 'PONTA DIREITA':
        return Posicao.RW;

      case 'LW':
      case 'PE':
      case 'PONTA ESQUERDA':
        return Posicao.LW;

      case 'ST':
      case 'CF':
      case 'ATA':
      case 'ATACANTE':
      case 'CENTROAVANTE':
        return Posicao.ST;

      default:
        return null;
    }
  }

  static Posicao fromJson(Object? v, {Posicao fallback = Posicao.CM}) {
    if (v == null) return fallback;

    if (v is Posicao) return v;

    // Tenta índice do enum
    if (v is int && v >= 0 && v < Posicao.values.length) {
      return Posicao.values[v];
    }

    // Tenta string com parse tolerante
    if (v is String) {
      return parse(v) ?? fallback;
    }

    return fallback;
  }

  // ======== Utilidade: comparar macro ========
  bool mesmaMacro(Posicao outra) => macro == outra.macro;

  // ======== Listas úteis para UI ========
  static List<Posicao> get todas => Posicao.values;

  static List<Posicao> get goleiros => [Posicao.GK];

  static List<Posicao> get defensores => [Posicao.RB, Posicao.CB, Posicao.LB];

  static List<Posicao> get meioCampistas =>
      [Posicao.DM, Posicao.CM, Posicao.AM];

  static List<Posicao> get atacantes => [Posicao.RW, Posicao.LW, Posicao.ST];
}
