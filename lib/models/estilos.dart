// lib/models/estilos.dart
//
// Estilos de jogo e base estratégica para influenciar a simulação.
// Versão final robusta com:
// • Enums estáveis (BaseEstilo, Estilo) — compatível com versões anteriores
// • Labels, descrições curtas e slugs estáveis (snake_case, sem acento)
// • Normalização tolerante (acentos/hífens/espaços/sinônimos)
// • Serialização: toJson()/fromJson() e utilidades (tryParse, listas canônicas)
// • Mapeamento bidirecional entre Estilo <-> BaseEstilo
//
// Observação: mantenha estes slugs estáveis; são usados em persistência.

enum BaseEstilo {
  tikiTaka,
  gegenpress,
  transicao,
  sulAmericano,
  bolaParada,
}

enum Estilo {
  posseDeBola,
  gegenpress,
  transicao,
  sulAmericano,
  bolaParada,
}

// =======================
// BaseEstilo helpers
// =======================
extension BaseEstiloX on BaseEstilo {
  String get label {
    switch (this) {
      case BaseEstilo.tikiTaka:
        return 'Tiki-Taka';
      case BaseEstilo.gegenpress:
        return 'Gegenpress';
      case BaseEstilo.transicao:
        return 'Transição';
      case BaseEstilo.sulAmericano:
        return 'Sul-Americano';
      case BaseEstilo.bolaParada:
        return 'Bola parada';
    }
  }

  /// slug estável pra persistência (snake_case, sem acento)
  String get slug {
    switch (this) {
      case BaseEstilo.tikiTaka:
        return 'tiki_taka';
      case BaseEstilo.gegenpress:
        return 'gegenpress';
      case BaseEstilo.transicao:
        return 'transicao';
      case BaseEstilo.sulAmericano:
        return 'sul_americano';
      case BaseEstilo.bolaParada:
        return 'bola_parada';
    }
  }

  String toJson() => slug;

  static BaseEstilo fromString(String s,
      {BaseEstilo fallback = BaseEstilo.transicao}) {
    final n = _normalize(s);
    switch (n) {
      case 'tiki_taka':
      case 'tikitaka':
      case 'tiki':
      case 'posse':
      case 'posse_de_bola':
        return BaseEstilo.tikiTaka;
      case 'gegenpress':
      case 'gegen_press':
      case 'pressao_alta':
      case 'pressao':
      case 'pressing':
        return BaseEstilo.gegenpress;
      case 'transicao':
      case 'transicao_rapida':
      case 'contra_ataque':
      case 'contraataque':
        return BaseEstilo.transicao;
      case 'sul_americano':
      case 'sulamericano':
        return BaseEstilo.sulAmericano;
      case 'bola_parada':
      case 'bolaparada':
      case 'set_pieces':
      case 'bola-parada':
        return BaseEstilo.bolaParada;
      default:
        return fallback;
    }
  }

  static BaseEstilo fromJson(Object? v,
          {BaseEstilo fallback = BaseEstilo.transicao}) =>
      v is String ? fromString(v, fallback: fallback) : fallback;
}

// =======================
// Estilo helpers
// =======================
extension EstiloX on Estilo {
  String get label {
    switch (this) {
      case Estilo.posseDeBola:
        return 'Posse de bola';
      case Estilo.gegenpress:
        return 'Gegenpress';
      case Estilo.transicao:
        return 'Transição';
      case Estilo.sulAmericano:
        return 'Sul-Americano';
      case Estilo.bolaParada:
        return 'Bola parada';
    }
  }

  String get descCurta {
    switch (this) {
      case Estilo.posseDeBola:
        return 'Controle, paciência e criação.';
      case Estilo.gegenpress:
        return 'Pressão alta e recuperação imediata.';
      case Estilo.transicao:
        return 'Reação rápida, ataques diretos.';
      case Estilo.sulAmericano:
        return 'Intensidade, competitividade, raça.';
      case Estilo.bolaParada:
        return 'Ênfase em escanteios e faltas perigosas.';
    }
  }

  BaseEstilo get base {
    switch (this) {
      case Estilo.posseDeBola:
        return BaseEstilo.tikiTaka;
      case Estilo.gegenpress:
        return BaseEstilo.gegenpress;
      case Estilo.transicao:
        return BaseEstilo.transicao;
      case Estilo.sulAmericano:
        return BaseEstilo.sulAmericano;
      case Estilo.bolaParada:
        return BaseEstilo.bolaParada;
    }
  }

  /// slug estável pra persistência (snake_case, sem acento)
  String get slug {
    switch (this) {
      case Estilo.posseDeBola:
        return 'posse_de_bola';
      case Estilo.gegenpress:
        return 'gegenpress';
      case Estilo.transicao:
        return 'transicao';
      case Estilo.sulAmericano:
        return 'sul_americano';
      case Estilo.bolaParada:
        return 'bola_parada';
    }
  }

  String toJson() => slug;

  /// Aceita strings com/sem acentos, hífens, espaços ou underscores.
  /// Exemplos aceitos:
  ///  - "Posse de bola", "posse_de_bola"
  ///  - "Gegenpress"
  ///  - "Transição", "transicao"
  ///  - "Sul-Americano", "sul_americano"
  ///  - "Bola parada", "bola-parada"
  ///  - Sinônimos: "tiki-taka" -> posseDeBola; "pressao_alta" -> gegenpress
  static Estilo fromString(String s, {Estilo fallback = Estilo.transicao}) {
    final n = _normalize(s);
    switch (n) {
      case 'posse_de_bola':
      case 'posse':
      case 'posse_bola':
      case 'tiki_taka':
      case 'tikitaka':
      case 'tiki':
        return Estilo.posseDeBola;
      case 'gegenpress':
      case 'gegen_press':
      case 'pressao_alta':
      case 'pressao':
      case 'pressing':
        return Estilo.gegenpress;
      case 'transicao':
      case 'transicao_rapida':
      case 'contra_ataque':
      case 'contraataque':
        return Estilo.transicao;
      case 'sul_americano':
      case 'sulamericano':
        return Estilo.sulAmericano;
      case 'bola_parada':
      case 'bolaparada':
      case 'set_pieces':
      case 'bola-parada':
        return Estilo.bolaParada;
      default:
        return fallback;
    }
  }

  static Estilo fromJson(Object? v, {Estilo fallback = Estilo.transicao}) =>
      v is String ? fromString(v, fallback: fallback) : fallback;
}

// =======================
// Utilidades extras
// =======================

/// Mapeamentos e utilitários canônicos para estilos.
class Estilos {
  Estilos._();

  /// Lista canônica de todos os estilos (ordem sugerida para UI).
  static const List<Estilo> todos = <Estilo>[
    Estilo.posseDeBola,
    Estilo.gegenpress,
    Estilo.transicao,
    Estilo.sulAmericano,
    Estilo.bolaParada,
  ];

  /// Lista canônica da base (ordem sugerida para UI).
  static const List<BaseEstilo> bases = <BaseEstilo>[
    BaseEstilo.tikiTaka,
    BaseEstilo.gegenpress,
    BaseEstilo.transicao,
    BaseEstilo.sulAmericano,
    BaseEstilo.bolaParada,
  ];

  /// Converte um slug/label/sinônimo direto para [Estilo].
  static Estilo parseEstilo(Object? s, {Estilo fallback = Estilo.transicao}) {
    if (s == null) return fallback;
    return EstiloX.fromString(s.toString(), fallback: fallback);
  }

  /// Converte um slug/label/sinônimo direto para [BaseEstilo].
  static BaseEstilo parseBase(Object? s,
          {BaseEstilo fallback = BaseEstilo.transicao}) =>
      BaseEstiloX.fromString(s?.toString() ?? '', fallback: fallback);

  /// Retorna o [Estilo] predominante de uma base (mapeamento 1:1).
  static Estilo fromBase(BaseEstilo base) {
    switch (base) {
      case BaseEstilo.tikiTaka:
        return Estilo.posseDeBola;
      case BaseEstilo.gegenpress:
        return Estilo.gegenpress;
      case BaseEstilo.transicao:
        return Estilo.transicao;
      case BaseEstilo.sulAmericano:
        return Estilo.sulAmericano;
      case BaseEstilo.bolaParada:
        return Estilo.bolaParada;
    }
  }

  /// Retorna a base correspondente a um estilo (atalho para `estilo.base`).
  static BaseEstilo toBase(Estilo estilo) => estilo.base;

  /// Itens para UI (slug, label).
  static List<MapEntry<String, String>> itemsUI() =>
      Estilos.todos.map((e) => MapEntry(e.slug, e.label)).toList();
}

// =======================
// Normalização de string
// =======================

String _normalize(String s) {
  var t = s.trim().toLowerCase();

  // remove acentos comuns (pt)
  t = t
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll(RegExp(r'[ç]'), 'c');

  // normaliza separadores para underscore
  t = t.replaceAll(RegExp(r'[\s\-]+'), '_');

  // deduplica underscores
  t = t.replaceAll(RegExp(r'_+'), '_');

  // remove underscores nas pontas
  if (t.startsWith('_')) t = t.substring(1);
  if (t.endsWith('_')) t = t.substring(0, t.length - 1);

  return t;
}
