// lib/models/time_sim_ext.dart
//
// Config tática leve + Registry em memória para a simulação.
// Usado por GameState._simular() e pelas ferramentas DEV.
//
// Versão final robusta:
// • TimeTatico: imutável, com clamp seguro no copyWith, toJson/fromJson.
// • TimeTaticoRegistry: CRUD completo (get/set/remove/clear), getOrDefault,
//   seed/listagem/snapshot, (de)serialização, e helpers utilitários.
// • defaultFor(Estilo, nivel): gera configuração base a partir do estilo
//   estratégico do clube e do nível (1..5).

import 'estilos.dart';

class TimeTatico {
  /// Linha defensiva: 1 (baixa) .. 5 (alta)
  final int linha;

  /// Intensidade/pressão: 0..100
  final int intensidade;

  /// Estilo "macro" (informativo e para ajustes leves de simulação)
  final Estilo estiloBase;

  const TimeTatico({
    required this.linha,
    required this.intensidade,
    required this.estiloBase,
  });

  /// Retorna uma cópia com valores ajustados e "clamped" a intervalos válidos.
  TimeTatico copyWith({
    int? linha,
    int? intensidade,
    Estilo? estiloBase,
  }) =>
      TimeTatico(
        linha: (linha ?? this.linha).clamp(1, 5),
        intensidade: (intensidade ?? this.intensidade).clamp(0, 100),
        estiloBase: estiloBase ?? this.estiloBase,
      );

  // -------- Serialização --------

  Map<String, dynamic> toJson() => {
        'linha': linha,
        'intensidade': intensidade,
        'estilo': estiloBase.slug,
      };

  factory TimeTatico.fromJson(Map<String, dynamic> j,
      {Estilo fallbackEstilo = Estilo.transicao}) {
    int asInt(Object? v, [int def = 0]) {
      if (v is int) return v;
      return int.tryParse('${v ?? ''}') ?? def;
    }

    final estilo = EstiloX.fromString(
      (j['estilo'] ?? '').toString(),
      fallback: fallbackEstilo,
    );

    return TimeTatico(
      linha: asInt(j['linha'], 3).clamp(1, 5),
      intensidade: asInt(j['intensidade'], 60).clamp(0, 100),
      estiloBase: estilo,
    );
  }

  @override
  String toString() =>
      'TT(linha:$linha, int:$intensidade, estilo:${estiloBase.slug})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeTatico &&
          other.linha == linha &&
          other.intensidade == intensidade &&
          other.estiloBase == estiloBase);

  @override
  int get hashCode => Object.hash(linha, intensidade, estiloBase);
}

class TimeTaticoRegistry {
  TimeTaticoRegistry._();

  /// slug → TimeTatico
  static final Map<String, TimeTatico> _bySlug = <String, TimeTatico>{};

  // -------- CRUD básico --------
  static void clear() => _bySlug.clear();

  static TimeTatico? de(String slug) => _bySlug[slug];

  static bool contains(String slug) => _bySlug.containsKey(slug);

  static void set(String slug, TimeTatico cfg) => _bySlug[slug] = cfg;

  static bool remove(String slug) => _bySlug.remove(slug) != null;

  /// Define caso não exista e retorna a config armazenada.
  static TimeTatico getOrSet(String slug, TimeTatico cfgDefault) {
    final exist = _bySlug[slug];
    if (exist != null) return exist;
    _bySlug[slug] = cfgDefault;
    return cfgDefault;
  }

  /// Retorna cópia imutável (snapshot) das configs.
  static Map<String, TimeTatico> snapshot() => Map.unmodifiable(_bySlug);

  /// Lista todos os slugs cadastrados.
  static List<String> slugs() => _bySlug.keys.toList(growable: false);

  /// Faz seed de várias configs (substitui existentes pelos mesmos slugs).
  static void seed(Map<String, TimeTatico> many) {
    _bySlug.addAll(many);
  }

  // -------- (De)serialização --------

  /// Exporta para JSON: [{slug, linha, intensidade, estilo}, ...]
  static List<Map<String, dynamic>> exportJson() => _bySlug.entries
      .map((e) => {'slug': e.key, ...e.value.toJson()})
      .toList(growable: false);

  /// Importa de JSON (lista de mapas); se [merge] = false, limpa antes.
  static void importJson(List<dynamic> data, {bool merge = true}) {
    if (!merge) clear();
    for (final e in data) {
      if (e is Map<String, dynamic>) {
        final slug = (e['slug'] ?? '').toString();
        if (slug.isEmpty) continue;
        final cfg = TimeTatico.fromJson(e);
        _bySlug[slug] = cfg;
      }
    }
  }

  // -------- Defaults --------

  /// Config padrão derivada do estilo e nível do clube (1..5 típico).
  /// Mantém diferenças leves só para variar placares.
  static TimeTatico defaultFor(Estilo estilo, double nivel) {
    int linha;
    int intensidade;

    switch (estilo.base) {
      case BaseEstilo.tikiTaka:
        linha = 3;
        intensidade = (60 + (nivel * 5)).round();
        break;
      case BaseEstilo.gegenpress:
        linha = 4;
        intensidade = (70 + (nivel * 6)).round();
        break;
      case BaseEstilo.transicao:
        linha = 3;
        intensidade = (55 + (nivel * 4)).round();
        break;
      case BaseEstilo.sulAmericano:
        linha = 2;
        intensidade = (62 + (nivel * 4)).round();
        break;
      case BaseEstilo.bolaParada:
        linha = 3;
        intensidade = (48 + (nivel * 3)).round();
        break;
    }

    return TimeTatico(
      linha: linha.clamp(1, 5),
      intensidade: intensidade.clamp(0, 100),
      estiloBase: estilo,
    );
  }
}
