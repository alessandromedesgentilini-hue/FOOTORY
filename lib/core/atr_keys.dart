// lib/core/atr_keys.dart
// ===============================================================
// FutSim — Chaves canônicas de atributos (versão final)
// - Conjunto oficial: 25 linhas gerais + 10 de goleiro
// - Aliases legados para compatibilidade com UIs antigas
// - Metadados (categoria, label, ordem) e utilitários de normalização
// - Safe: independente, sem imports externos
// ===============================================================

/// ===== 25 ATRIBUTOS (linhas gerais) =====
class Atr {
  // Ofensivo (5)
  static const String finalizacao = 'finalizacao';
  static const String posicionamentoOfensivo = 'posicionamentoOfensivo';
  static const String drible = 'drible';
  static const String chuteDeLonge = 'chuteDeLonge';
  static const String penalti = 'penalti';

  // Defensivo (5)
  static const String marcacao = 'marcacao';
  static const String desarme = 'desarme';
  static const String interceptacao = 'interceptacao';
  static const String cobertura = 'cobertura';
  static const String jogoAereo = 'jogoAereo';

  // Técnico (5)
  static const String passeCurto = 'passeCurto';
  static const String passeLongo = 'passeLongo';
  static const String dominioConducao = 'dominioConducao';
  static const String cruzamento = 'cruzamento';
  static const String visao = 'visao';

  // Físico (5)
  static const String potencia = 'potencia';
  static const String velocidade = 'velocidade';
  static const String resistencia = 'resistencia';
  static const String aptidaoFisica = 'aptidaoFisica';
  static const String coordenacaoMotora = 'coordenacaoMotora';

  // Mental (5)
  static const String tomadaDecisao = 'tomadaDecisao';
  static const String frieza = 'frieza';
  static const String lideranca = 'lideranca';
  static const String espiritoProtagonista = 'espiritoProtagonista';
  static const String leituraTatica = 'leituraTatica';

  /// ===== 10 de GOLEIRO =====
  static const String gkDefesaPerto = 'gkDefesaPerto';
  static const String gkDefesaLonge = 'gkDefesaLonge';
  static const String gkDefesaPenalti = 'gkDefesaPenalti';
  static const String gkDefesaBolaParada = 'gkDefesaBolaParada';
  static const String gkUmContraUm = 'gkUmContraUm';
  static const String gkSaidasAereas = 'gkSaidasAereas';
  static const String gkDistribCurta = 'gkDistribCurta';
  static const String gkDistribLonga = 'gkDistribLonga';
  static const String gkLibero = 'gkLibero';
  static const String gkReflexos = 'gkReflexos';

  /// ===== CHAVES LEGADAS / COMPAT (usadas em UIs antigas) =====
  /// Não fazem parte do “25+10” oficial; existem para normalização.
  static const String aceleracao =
      'aceleracao'; // alias p/ velocidade (arranque)
  static const String posicionamento =
      'posicionamento'; // genérico (→ ofensivo)
  static const String cabeceio = 'cabeceio'; // alias p/ jogoAereo
  static const String tabela = 'tabela'; // jogo apoiado (→ passeCurto)
  static const String penetracao = 'penetracao'; // condução/arranque (→ drible)
  static const String mobilidade = 'mobilidade'; // físico (→ coordenacaoMotora)
  static const String pressao = 'pressao'; // defensivo genérico (→ marcacao)
  static const String pressaoPosPerda =
      'pressaoPosPerda'; // tático (→ leituraTatica)
  static const String compactacao = 'compactacao'; // tático (→ leituraTatica)
}

/// Categoria canônica de atributo.
enum AtrCategoria {
  ofensivo,
  defensivo,
  tecnico,
  fisico,
  mental,
  goleiro,
  legado
}

/// Grupos utilitários (validação/menus/etc)
class AtrGrupo {
  // 25 principais
  static const List<String> ofensivo = [
    Atr.finalizacao,
    Atr.posicionamentoOfensivo,
    Atr.drible,
    Atr.chuteDeLonge,
    Atr.penalti,
  ];

  static const List<String> defensivo = [
    Atr.marcacao,
    Atr.desarme,
    Atr.interceptacao,
    Atr.cobertura,
    Atr.jogoAereo,
  ];

  static const List<String> tecnico = [
    Atr.passeCurto,
    Atr.passeLongo,
    Atr.dominioConducao,
    Atr.cruzamento,
    Atr.visao,
  ];

  static const List<String> fisico = [
    Atr.potencia,
    Atr.velocidade,
    Atr.resistencia,
    Atr.aptidaoFisica,
    Atr.coordenacaoMotora,
  ];

  static const List<String> mental = [
    Atr.tomadaDecisao,
    Atr.frieza,
    Atr.lideranca,
    Atr.espiritoProtagonista,
    Atr.leituraTatica,
  ];

  // 10 de goleiro
  static const List<String> goleiro = [
    Atr.gkDefesaPerto,
    Atr.gkDefesaLonge,
    Atr.gkDefesaPenalti,
    Atr.gkDefesaBolaParada,
    Atr.gkUmContraUm,
    Atr.gkSaidasAereas,
    Atr.gkDistribCurta,
    Atr.gkDistribLonga,
    Atr.gkLibero,
    Atr.gkReflexos,
  ];

  // Compatibilidade (não entram no “25+10” oficial)
  static const List<String> legados = [
    Atr.aceleracao,
    Atr.posicionamento,
    Atr.cabeceio,
    Atr.tabela,
    Atr.penetracao,
    Atr.mobilidade,
    Atr.pressao,
    Atr.pressaoPosPerda,
    Atr.compactacao,
  ];

  /// Conjunto apenas dos **oficiais** (25 + 10).
  static const Set<String> oficiais = {
    ...ofensivo,
    ...defensivo,
    ...tecnico,
    ...fisico,
    ...mental,
    ...goleiro,
  };

  /// Conjunto das **linhas gerais** (somente 25, sem goleiro).
  static const Set<String> linhasGerais = {
    ...ofensivo,
    ...defensivo,
    ...tecnico,
    ...fisico,
    ...mental,
  };

  /// Conjunto completo incluindo legados.
  static final Set<String> todos = {
    ...oficiais,
    ...legados, // manter por último para compat
  };

  /// Lista ordenada canônica (25 gerais + 10 GK), ideal para UIs.
  static const List<String> ordemPadrao = [
    // Ofensivo
    ...ofensivo,
    // Defensivo
    ...defensivo,
    // Técnico
    ...tecnico,
    // Físico
    ...fisico,
    // Mental
    ...mental,
    // Goleiro
    ...goleiro,
  ];
}

/// Metadados por atributo (categoria, label, ordem).
class AtrMeta {
  final String chave;
  final AtrCategoria categoria;
  final String label; // Label “bonito” p/ UI (pt-BR)
  final int ordem; // posição na ordem canônica (0..34); legados recebem 1000+

  const AtrMeta(this.chave, this.categoria, this.label, this.ordem);

  static const Map<String, AtrMeta> _map = {
    // Ofensivo (0..4)
    Atr.finalizacao:
        AtrMeta(Atr.finalizacao, AtrCategoria.ofensivo, 'Finalização', 0),
    Atr.posicionamentoOfensivo: AtrMeta(Atr.posicionamentoOfensivo,
        AtrCategoria.ofensivo, 'Posicionamento Ofensivo', 1),
    Atr.drible: AtrMeta(Atr.drible, AtrCategoria.ofensivo, 'Drible', 2),
    Atr.chuteDeLonge:
        AtrMeta(Atr.chuteDeLonge, AtrCategoria.ofensivo, 'Chute de Longe', 3),
    Atr.penalti: AtrMeta(Atr.penalti, AtrCategoria.ofensivo, 'Pênalti', 4),

    // Defensivo (5..9)
    Atr.marcacao: AtrMeta(Atr.marcacao, AtrCategoria.defensivo, 'Marcação', 5),
    Atr.desarme: AtrMeta(Atr.desarme, AtrCategoria.defensivo, 'Desarme', 6),
    Atr.interceptacao:
        AtrMeta(Atr.interceptacao, AtrCategoria.defensivo, 'Interceptação', 7),
    Atr.cobertura:
        AtrMeta(Atr.cobertura, AtrCategoria.defensivo, 'Cobertura', 8),
    Atr.jogoAereo:
        AtrMeta(Atr.jogoAereo, AtrCategoria.defensivo, 'Jogo Aéreo', 9),

    // Técnico (10..14)
    Atr.passeCurto:
        AtrMeta(Atr.passeCurto, AtrCategoria.tecnico, 'Passe Curto', 10),
    Atr.passeLongo:
        AtrMeta(Atr.passeLongo, AtrCategoria.tecnico, 'Passe Longo', 11),
    Atr.dominioConducao: AtrMeta(
        Atr.dominioConducao, AtrCategoria.tecnico, 'Domínio/Condução', 12),
    Atr.cruzamento:
        AtrMeta(Atr.cruzamento, AtrCategoria.tecnico, 'Cruzamento', 13),
    Atr.visao: AtrMeta(Atr.visao, AtrCategoria.tecnico, 'Visão de Jogo', 14),

    // Físico (15..19)
    Atr.potencia: AtrMeta(Atr.potencia, AtrCategoria.fisico, 'Potência', 15),
    Atr.velocidade:
        AtrMeta(Atr.velocidade, AtrCategoria.fisico, 'Velocidade', 16),
    Atr.resistencia:
        AtrMeta(Atr.resistencia, AtrCategoria.fisico, 'Resistência', 17),
    Atr.aptidaoFisica:
        AtrMeta(Atr.aptidaoFisica, AtrCategoria.fisico, 'Aptidão Física', 18),
    Atr.coordenacaoMotora: AtrMeta(
        Atr.coordenacaoMotora, AtrCategoria.fisico, 'Coordenação Motora', 19),

    // Mental (20..24)
    Atr.tomadaDecisao: AtrMeta(
        Atr.tomadaDecisao, AtrCategoria.mental, 'Tomada de Decisão', 20),
    Atr.frieza: AtrMeta(Atr.frieza, AtrCategoria.mental, 'Frieza', 21),
    Atr.lideranca: AtrMeta(Atr.lideranca, AtrCategoria.mental, 'Liderança', 22),
    Atr.espiritoProtagonista: AtrMeta(Atr.espiritoProtagonista,
        AtrCategoria.mental, 'Espírito Protagonista', 23),
    Atr.leituraTatica:
        AtrMeta(Atr.leituraTatica, AtrCategoria.mental, 'Leitura Tática', 24),

    // Goleiro (25..34)
    Atr.gkDefesaPerto: AtrMeta(
        Atr.gkDefesaPerto, AtrCategoria.goleiro, 'GK — Defesa (Perto)', 25),
    Atr.gkDefesaLonge: AtrMeta(
        Atr.gkDefesaLonge, AtrCategoria.goleiro, 'GK — Defesa (Longe)', 26),
    Atr.gkDefesaPenalti: AtrMeta(Atr.gkDefesaPenalti, AtrCategoria.goleiro,
        'GK — Defesa de Pênalti', 27),
    Atr.gkDefesaBolaParada: AtrMeta(Atr.gkDefesaBolaParada,
        AtrCategoria.goleiro, 'GK — Defesa Bola Parada', 28),
    Atr.gkUmContraUm:
        AtrMeta(Atr.gkUmContraUm, AtrCategoria.goleiro, 'GK — 1x1', 29),
    Atr.gkSaidasAereas: AtrMeta(
        Atr.gkSaidasAereas, AtrCategoria.goleiro, 'GK — Saídas Aéreas', 30),
    Atr.gkDistribCurta: AtrMeta(Atr.gkDistribCurta, AtrCategoria.goleiro,
        'GK — Distribuição Curta', 31),
    Atr.gkDistribLonga: AtrMeta(Atr.gkDistribLonga, AtrCategoria.goleiro,
        'GK — Distribuição Longa', 32),
    Atr.gkLibero:
        AtrMeta(Atr.gkLibero, AtrCategoria.goleiro, 'GK — Líbero', 33),
    Atr.gkReflexos:
        AtrMeta(Atr.gkReflexos, AtrCategoria.goleiro, 'GK — Reflexos', 34),

    // Legados (ordem 1000+ para sempre irem ao fim quando misturados)
    Atr.aceleracao: AtrMeta(
        Atr.aceleracao, AtrCategoria.legado, 'LEGADO — Aceleração', 1000),
    Atr.posicionamento: AtrMeta(Atr.posicionamento, AtrCategoria.legado,
        'LEGADO — Posicionamento', 1001),
    Atr.cabeceio:
        AtrMeta(Atr.cabeceio, AtrCategoria.legado, 'LEGADO — Cabeceio', 1002),
    Atr.tabela:
        AtrMeta(Atr.tabela, AtrCategoria.legado, 'LEGADO — Tabela', 1003),
    Atr.penetracao: AtrMeta(
        Atr.penetracao, AtrCategoria.legado, 'LEGADO — Penetração', 1004),
    Atr.mobilidade: AtrMeta(
        Atr.mobilidade, AtrCategoria.legado, 'LEGADO — Mobilidade', 1005),
    Atr.pressao:
        AtrMeta(Atr.pressao, AtrCategoria.legado, 'LEGADO — Pressão', 1006),
    Atr.pressaoPosPerda: AtrMeta(Atr.pressaoPosPerda, AtrCategoria.legado,
        'LEGADO — Pressão pós-perda', 1007),
    Atr.compactacao: AtrMeta(
        Atr.compactacao, AtrCategoria.legado, 'LEGADO — Compactação', 1008),
  };

  /// Retorna metadados; se a chave for inválida, retorna null.
  static AtrMeta? de(String chave) => _map[chave];

  /// Label amigável para UI; se desconhecida, retorna a própria chave.
  static String labelDe(String chave) => _map[chave]?.label ?? chave;

  /// Categoria da chave; null se desconhecida.
  static AtrCategoria? categoriaDe(String chave) => _map[chave]?.categoria;

  /// Ordem padrão (para sort estável em UIs).
  static int ordemDe(String chave) => _map[chave]?.ordem ?? 2000;

  /// Ordena chaves pelo critério canônico de exibição.
  static List<String> ordenar(Iterable<String> chaves) {
    final list = chaves.toList();
    list.sort((a, b) => ordemDe(a).compareTo(ordemDe(b)));
    return list;
  }
}

/// Aliases e utilitários de normalização.
class AtrAlias {
  /// Mapa: alias legado → chave oficial.
  /// Observações de mapeamento:
  /// - posicionamento (genérico) → posicionamentoOfensivo (único pos. oficial)
  /// - mobilidade → coordenacaoMotora (aspecto motor/arranque)
  /// - pressao → marcacao (pressão marca alto)
  /// - pressaoPosPerda/compactacao → leituraTatica (princípios táticos)
  static const Map<String, String> aliasParaOficial = {
    Atr.aceleracao: Atr.velocidade,
    Atr.posicionamento: Atr.posicionamentoOfensivo,
    Atr.cabeceio: Atr.jogoAereo,
    Atr.tabela: Atr.passeCurto,
    Atr.penetracao: Atr.drible,
    Atr.mobilidade: Atr.coordenacaoMotora,
    Atr.pressao: Atr.marcacao,
    Atr.pressaoPosPerda: Atr.leituraTatica,
    Atr.compactacao: Atr.leituraTatica,
  };

  /// Mapa invertido (oficial → lista de aliases).
  static final Map<String, List<String>> oficialParaAliases = () {
    final Map<String, List<String>> out = {
      for (final k in AtrGrupo.oficiais) k: <String>[]
    };
    aliasParaOficial.forEach((alias, oficial) {
      out.putIfAbsent(oficial, () => <String>[]).add(alias);
    });
    return out;
  }();

  /// Índice auxiliar ignorando caixa (lowercase) para qualquer chave conhecida (oficial/legado).
  static final Map<String, String> _lowerIndex = () {
    final Map<String, String> idx = {};
    for (final k in AtrGrupo.todos) {
      idx[k.toLowerCase()] = k;
    }
    // também indexa labels (sem acento/espaco) → oficial (útil quando UI manda rótulo)
    AtrMeta._map.forEach((k, meta) {
      final normLabel = _simplify(meta.label);
      idx.putIfAbsent(normLabel, () => k);
    });
    return idx;
  }();

  /// Normaliza uma chave ou label potencialmente "suja" para a chave **oficial**.
  /// Regras:
  /// - trim, remove acentos, remove espaços, hífens e underscores na comparação
  /// - case-insensitive
  /// - aplica aliases legados
  /// - se já for oficial, retorna inalterado
  static String normalizar(String chaveOuLabel) {
    final raw = (chaveOuLabel).trim();

    // 1) Se já é oficial/legado exato:
    if (AtrGrupo.todos.contains(raw)) {
      if (AtrGrupo.oficiais.contains(raw)) return raw;
      // legado → direciona para oficial
      return aliasParaOficial[raw] ?? raw;
    }

    // 2) Match ignorando caixa
    final lowerHit = _lowerIndex[raw.toLowerCase()];
    if (lowerHit != null) {
      return AtrGrupo.oficiais.contains(lowerHit)
          ? lowerHit
          : (aliasParaOficial[lowerHit] ?? lowerHit);
    }

    // 3) Match por forma "simplificada" (sem acento/espacos/_/-)
    final simplified = _simplify(raw);
    final simplifiedHit = _lowerIndex[simplified];
    if (simplifiedHit != null) {
      return AtrGrupo.oficiais.contains(simplifiedHit)
          ? simplifiedHit
          : (aliasParaOficial[simplifiedHit] ?? simplifiedHit);
    }

    // 4) Tentativa final: se passou "posicionamento" como palavra solta etc.
    final maybe =
        aliasParaOficial[raw] ?? aliasParaOficial[_simplify(raw)] ?? raw;
    return maybe;
  }

  /// Normaliza um mapa de atributos, aplicando:
  /// - normalização de chaves (aliases/labels → oficial)
  /// - opção de clamp nos valores (por padrão 1–10)
  /// - merge de chaves repetidas (prefere o maior valor encontrado)
  static Map<String, num> normalizarMapa(
    Map<String, num> origem, {
    bool clampValores = true,
    num min = 1,
    num max = 10,
  }) {
    final Map<String, num> out = {};
    origem.forEach((k, v) {
      final oficial = normalizar(k);
      num val = v;
      if (clampValores) {
        if (val < min) val = min;
        if (val > max) val = max;
      }
      if (!out.containsKey(oficial)) {
        out[oficial] = val;
      } else {
        // Mantém o maior valor (evita perda quando veio alias + oficial)
        if (val > out[oficial]!) out[oficial] = val;
      }
    });
    return out;
  }

  /// True se a chave é legacy (não oficial).
  static bool isLegado(String chave) =>
      AtrGrupo.legados.contains(chave) ||
      !AtrGrupo.oficiais.contains(normalizar(chave));

  /// True se a chave é oficial (25 + 10).
  static bool isOficial(String chave) =>
      AtrGrupo.oficiais.contains(normalizar(chave));

  /// Categoria (considerando normalização).
  static AtrCategoria? categoria(String chave) =>
      AtrMeta.categoriaDe(normalizar(chave));

  /// Retorna os aliases canônicos de uma chave oficial.
  static List<String> aliasesDe(String chaveOficial) =>
      oficialParaAliases[normalizar(chaveOficial)] ?? const [];

  /// Simplificação: remove acentos, espaços, underscores e hífens e converte para lowercase.
  static String _simplify(String s) {
    final noAccents = _removeDiacritics(s);
    final compact = noAccents.replaceAll(RegExp(r'[\s_\-\/]+'), '');
    return compact.toLowerCase();
  }

  /// Remoção básica de diacríticos (suficiente para pt-BR) — versão segura.
  static String _removeDiacritics(String input) {
    // Percorre os runes para evitar “RangeError (index)” com UTF-16 surrogate pairs.
    const from = 'áàâãäÁÀÂÃÄéêÉÊíÍóôõÓÔÕúÚçÇ';
    const to = 'aaaaaAAAAAeeEEiIoOoOOuUcC';
    final sb = StringBuffer();
    for (final rune in input.runes) {
      final c = String.fromCharCode(rune);
      final i = from.indexOf(c);
      sb.write(i == -1 ? c : to[i]);
    }
    return sb.toString();
  }
}

/// Helpers de validação e consulta rápida.
class AtrUtils {
  /// Verifica se **todas** as chaves do conjunto são oficiais (25 + 10).
  static bool soOficiais(Iterable<String> chaves) {
    for (final c in chaves) {
      if (!AtrGrupo.oficiais.contains(AtrAlias.normalizar(c))) return false;
    }
    return true;
  }

  /// Retorna as chaves inválidas (após normalização) que não pertencem ao conjunto oficial.
  static List<String> chavesInvalidas(Iterable<String> chaves) {
    final List<String> out = [];
    for (final c in chaves) {
      final n = AtrAlias.normalizar(c);
      if (!AtrGrupo.oficiais.contains(n)) out.add(c);
    }
    return out;
  }

  /// Lista ordenada canônica (labels bonitos) para UI, com opção de incluir legados ao final.
  static List<MapEntry<String, String>> listarParaUI(
      {bool incluirLegados = false}) {
    final List<String> base = List.of(AtrGrupo.ordemPadrao);
    if (incluirLegados) {
      base.addAll(AtrGrupo.legados);
    }
    return base.map((k) => MapEntry(k, AtrMeta.labelDe(k))).toList();
  }

  /// Retorna a lista de chaves oficiais da categoria solicitada.
  static List<String> porCategoria(AtrCategoria cat) {
    switch (cat) {
      case AtrCategoria.ofensivo:
        return List.of(AtrGrupo.ofensivo);
      case AtrCategoria.defensivo:
        return List.of(AtrGrupo.defensivo);
      case AtrCategoria.tecnico:
        return List.of(AtrGrupo.tecnico);
      case AtrCategoria.fisico:
        return List.of(AtrGrupo.fisico);
      case AtrCategoria.mental:
        return List.of(AtrGrupo.mental);
      case AtrCategoria.goleiro:
        return List.of(AtrGrupo.goleiro);
      case AtrCategoria.legado:
        return List.of(AtrGrupo.legados);
    }
  }
}
