enum Funcao {
  lateral,
  zagueiro,
  volante,
  meioCentro,
  meia,
  ponta,
  meiaLado, // ME/MD
  centroavante,
  goleiro,
}

extension FuncaoX on Funcao {
  String get key {
    switch (this) {
      case Funcao.lateral:
        return 'lateral';
      case Funcao.zagueiro:
        return 'zagueiro';
      case Funcao.volante:
        return 'volante';
      case Funcao.meioCentro:
        return 'meio_centro';
      case Funcao.meia:
        return 'meia';
      case Funcao.ponta:
        return 'ponta';
      case Funcao.meiaLado:
        return 'meia_lado';
      case Funcao.centroavante:
        return 'centroavante';
      case Funcao.goleiro:
        return 'goleiro';
    }
  }

  static Funcao? fromKey(String key) {
    for (final f in Funcao.values) {
      if (f.key == key) return f;
    }
    return null;
  }
}
