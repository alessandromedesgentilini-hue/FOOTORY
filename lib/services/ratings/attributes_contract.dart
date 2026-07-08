import 'package:footory26/models/player.dart';

/// Contrato oficial dos atributos do Footory.
/// Fonte única da verdade para:
/// - nomes internos dos atributos
/// - labels bonitos na UI
/// - ordem fixa dos 10 atributos por posição
///
/// Importante:
/// - ME/MD não existem mais no jogo.
/// - Lateral Direito e Lateral Esquerdo compartilham o mesmo pacote de atributos.
/// - Ponta Direita e Ponta Esquerda compartilham o mesmo pacote de atributos.

class AttributesContract {
  const AttributesContract._();

  // =========================
  // Labels oficiais
  // =========================

  static const Map<String, String> labels = {
    'coberturaDefensiva': 'Cobertura Defensiva',
    'antecipacao': 'Antecipação',
    'passeCurto': 'Passe Curto',
    'cruzamento': 'Cruzamento',
    'tomadaDecisao': 'Tomada de Decisão',
    'capacidadeTatica': 'Capacidade Tática',
    'velocidade': 'Velocidade',
    'resistencia': 'Resistência',
    'potencia': 'Potência',
    'composicaoNatural': 'Composição Natural',
    'marcacao': 'Marcação',
    'jogoAereo': 'Jogo Aéreo',
    'desarme': 'Desarme',
    'frieza': 'Frieza',
    'coordenacaoMotora': 'Coordenação Motora',
    'passeLongo': 'Passe Longo',
    'drible': 'Drible',
    'chuteDeLonge': 'Chute de Longe',
    'dominioConducao': 'Domínio e Condução',
    'finalizacao': 'Finalização',
    'espiritoProtagonista': 'Espírito Protagonista',
    'presencaOfensiva': 'Presença Ofensiva',
    'defesaFinalizacoes': 'Defesa em Finalizações',
    'defesaChutesLonge': 'Defesa em Chutes de Longe',
    'defesaBolaParada': 'Defesa de Bola Parada',
    'defesaPenalti': 'Defesa de Pênalti',
    'saidaDoGol': 'Saída do Gol',
    'reflexoReacao': 'Reflexo e Reação',
    'controleDaArea': 'Controle da Área',
  };

  // =========================
  // Ordem oficial por posição
  // =========================

  static const List<String> lateral = [
    'coberturaDefensiva',
    'antecipacao',
    'passeCurto',
    'cruzamento',
    'tomadaDecisao',
    'capacidadeTatica',
    'velocidade',
    'resistencia',
    'potencia',
    'composicaoNatural',
  ];

  static const List<String> zagueiro = [
    'marcacao',
    'coberturaDefensiva',
    'jogoAereo',
    'antecipacao',
    'desarme',
    'tomadaDecisao',
    'frieza',
    'capacidadeTatica',
    'potencia',
    'coordenacaoMotora',
  ];

  static const List<String> volante = [
    'marcacao',
    'coberturaDefensiva',
    'jogoAereo',
    'antecipacao',
    'desarme',
    'passeCurto',
    'passeLongo',
    'tomadaDecisao',
    'capacidadeTatica',
    'resistencia',
  ];

  static const List<String> meioCentro = [
    'drible',
    'chuteDeLonge',
    'marcacao',
    'antecipacao',
    'passeCurto',
    'passeLongo',
    'dominioConducao',
    'tomadaDecisao',
    'resistencia',
    'frieza',
  ];

  static const List<String> meia = [
    'finalizacao',
    'drible',
    'passeCurto',
    'passeLongo',
    'dominioConducao',
    'tomadaDecisao',
    'frieza',
    'velocidade',
    'resistencia',
    'coordenacaoMotora',
  ];

  static const List<String> ponta = [
    'finalizacao',
    'drible',
    'passeCurto',
    'dominioConducao',
    'cruzamento',
    'tomadaDecisao',
    'espiritoProtagonista',
    'velocidade',
    'coordenacaoMotora',
    'frieza',
  ];

  static const List<String> centroavante = [
    'finalizacao',
    'presencaOfensiva',
    'drible',
    'jogoAereo',
    'passeCurto',
    'dominioConducao',
    'tomadaDecisao',
    'frieza',
    'potencia',
    'coordenacaoMotora',
  ];

  static const List<String> goleiro = [
    'defesaFinalizacoes',
    'defesaChutesLonge',
    'defesaBolaParada',
    'defesaPenalti',
    'saidaDoGol',
    'reflexoReacao',
    'controleDaArea',
    'tomadaDecisao',
    'frieza',
    'composicaoNatural',
  ];

  // =========================
  // API pública
  // =========================

  static List<String> keysForPosition(PosDet posDet) {
    switch (posDet) {
      case PosDet.gol:
        return goleiro;
      case PosDet.ld:
      case PosDet.le:
        return lateral;
      case PosDet.zag:
        return zagueiro;
      case PosDet.vol:
        return volante;
      case PosDet.mc:
        return meioCentro;
      case PosDet.mei:
        return meia;
      case PosDet.pd:
      case PosDet.pe:
        return ponta;
      case PosDet.ca:
        return centroavante;
    }
  }

  static String labelOf(String key) {
    return labels[key] ?? key;
  }

  static Map<String, String> orderedLabelsForPosition(PosDet posDet) {
    final keys = keysForPosition(posDet);
    return {
      for (final key in keys) key: labelOf(key),
    };
  }

  static bool isGoalkeeperAttribute(String key) {
    return const {
      'defesaFinalizacoes',
      'defesaChutesLonge',
      'defesaBolaParada',
      'defesaPenalti',
      'saidaDoGol',
      'reflexoReacao',
      'controleDaArea',
    }.contains(key);
  }
}
