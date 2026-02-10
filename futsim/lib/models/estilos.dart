// lib/models/estilos.dart

/// Estilos-base do jogo
enum BaseEstilo {
  tikiTaka,
  gegenpress,
  transicao,
  sulAmericano,
  bolaParada,
}

/// Postura/intenção do time dentro do estilo
enum Postura { defensivo, equilibrado, ofensivo }

/// Compat c/ código antigo (inclui 'equilibrado')
enum VariacaoTatica { defensiva, equilibrado, ofensiva }

/// Modelo de Estilo parametrizado
class Estilo {
  final String id;
  final BaseEstilo base;
  final Postura postura;
  final String nome;
  final String titulo;
  final Map<String, double> pesosAtributos;

  const Estilo({
    required this.id,
    required this.base,
    required this.postura,
    required this.nome,
    required this.titulo,
    this.pesosAtributos = const {},
  });

  // helpers
  bool get ehOfensivo => postura == Postura.ofensivo;
  bool get ehDefensivo => postura == Postura.defensivo;
  bool get ehEquilibrado => postura == Postura.equilibrado;

  /// usado por algumas UIs antigas
  String get label => titulo.isNotEmpty ? titulo : nome;

  // ===== Aliases p/ compat com código legado (devem ser final) =====
  static final Estilo posse = EstiloPresets._legacyPosse;
  static final Estilo transicao = EstiloPresets._legacyTransicao;
  static final Estilo vertical = EstiloPresets._legacyVertical;
  static final Estilo defensivo = EstiloPresets._legacyDefensivo;

  // aliases que o código antigo chama como getters estáticos
  static final Estilo tikiTaka = EstiloPresets.tikiTaka(Postura.equilibrado);
  static final Estilo gegenpress =
      EstiloPresets.gegenpress(Postura.equilibrado);
  static final Estilo transicaoRapida =
      EstiloPresets.transicao(Postura.ofensivo);
  static final Estilo sulAmericano =
      EstiloPresets.sulAmericano(Postura.equilibrado);
  static final Estilo cucabol = EstiloPresets.bolaParada(Postura.equilibrado);
}

/// Fábrica de presets e tabelas de pesos
class EstiloPresets {
  // chaves (lowerCamelCase p/ evitar lints)
  static const atrPasse = 'passe';
  static const atrPosicionamento = 'posicionamento';
  static const atrPressao = 'pressao';
  static const atrTransicao = 'transicao';
  static const atrCruzamento = 'cruzamento';
  static const atrBolaParada = 'bolaParada';
  static const atrDrible = 'drible';
  static const atrForca = 'forca';
  static const atrLinhaDef = 'linhaDefensiva';
  static const atrLargura = 'largura';

  // bases
  static const Map<String, double> _baseTikiTaka = {
    atrPasse: 1.0,
    atrPosicionamento: 0.9,
    atrLargura: 0.6,
    atrLinhaDef: 0.6,
  };
  static const Map<String, double> _baseGegen = {
    atrPressao: 1.0,
    atrTransicao: 0.8,
    atrForca: 0.6,
  };
  static const Map<String, double> _baseTransicao = {
    atrTransicao: 1.0,
    atrPasse: 0.6,
    atrLargura: 0.6,
  };
  static const Map<String, double> _baseSulAm = {
    atrDrible: 1.0,
    atrPasse: 0.7,
    atrForca: 0.5,
  };
  static const Map<String, double> _baseBolaParada = {
    atrBolaParada: 1.0,
    atrCruzamento: 0.9,
    atrForca: 0.6,
  };

  // ajuste por postura
  static Map<String, double> _ajustePostura(Postura p) {
    switch (p) {
      case Postura.defensivo:
        return {atrLinhaDef: 0.3, atrPressao: 0.2};
      case Postura.equilibrado:
        return const {};
      case Postura.ofensivo:
        return {atrLargura: 0.3, atrTransicao: 0.3, atrPressao: 0.2};
    }
  }

  static Map<String, double> _mix(Map<String, double> base, Postura p) {
    final out = Map<String, double>.from(base);
    _ajustePostura(p).forEach((k, v) {
      out.update(k, (old) => old + v, ifAbsent: () => v);
    });
    return out;
  }

  // fábricas
  static Estilo tikiTaka(Postura p) => Estilo(
        id: 'tk_${p.name}',
        base: BaseEstilo.tikiTaka,
        postura: p,
        nome: 'Tiki-Taka ${_labelPostura(p)}',
        titulo: 'Tiki-Taka (${_curto(p)})',
        pesosAtributos: _mix(_baseTikiTaka, p),
      );

  static Estilo gegenpress(Postura p) => Estilo(
        id: 'gg_${p.name}',
        base: BaseEstilo.gegenpress,
        postura: p,
        nome: 'Gegenpress ${_labelPostura(p)}',
        titulo: 'Gegenpress (${_curto(p)})',
        pesosAtributos: _mix(_baseGegen, p),
      );

  static Estilo transicao(Postura p) => Estilo(
        id: 'tr_${p.name}',
        base: BaseEstilo.transicao,
        postura: p,
        nome: 'Transição ${_labelPostura(p)}',
        titulo: 'Transição (${_curto(p)})',
        pesosAtributos: _mix(_baseTransicao, p),
      );

  static Estilo sulAmericano(Postura p) => Estilo(
        id: 'sa_${p.name}',
        base: BaseEstilo.sulAmericano,
        postura: p,
        nome: 'Sul-Americano ${_labelPostura(p)}',
        titulo: 'Sul-Am. (${_curto(p)})',
        pesosAtributos: _mix(_baseSulAm, p),
      );

  static Estilo bolaParada(Postura p) => Estilo(
        id: 'bp_${p.name}',
        base: BaseEstilo.bolaParada,
        postura: p,
        nome: 'Bola Parada ${_labelPostura(p)}',
        titulo: 'Bola Parada (${_curto(p)})',
        pesosAtributos: _mix(_baseBolaParada, p),
      );

  // coleções
  static List<Estilo> todos() => [
        for (final p in Postura.values) ...[
          tikiTaka(p),
          gegenpress(p),
          transicao(p),
          sulAmericano(p),
          bolaParada(p),
        ]
      ];

  static List<Estilo> listaEquilibrados() => [
        tikiTaka(Postura.equilibrado),
        gegenpress(Postura.equilibrado),
        transicao(Postura.equilibrado),
        sulAmericano(Postura.equilibrado),
        bolaParada(Postura.equilibrado),
      ];

  static Estilo porId(String id) => todos().firstWhere((e) => e.id == id);

  static String _labelPostura(Postura p) {
    switch (p) {
      case Postura.defensivo:
        return 'Defensivo';
      case Postura.equilibrado:
        return 'Equilibrado';
      case Postura.ofensivo:
        return 'Ofensivo';
    }
  }

  static String _curto(Postura p) {
    switch (p) {
      case Postura.defensivo:
        return 'DEF';
      case Postura.equilibrado:
        return 'EQL';
      case Postura.ofensivo:
        return 'OFN';
    }
  }

  // compat antigas
  static final Estilo _legacyPosse = tikiTaka(Postura.equilibrado);
  static final Estilo _legacyTransicao = transicao(Postura.equilibrado);
  static final Estilo _legacyVertical = transicao(Postura.ofensivo);
  static final Estilo _legacyDefensivo = tikiTaka(Postura.defensivo);
}

/// Lista padrão para dropdowns
final List<Estilo> estilosPadrao = EstiloPresets.listaEquilibrados();

/// Compat: constante usada em telas antigas
final Estilo estiloPosicional = EstiloPresets.tikiTaka(Postura.equilibrado);
