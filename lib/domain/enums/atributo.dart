enum Atributo {
  // OFENSIVO
  finalizacao,
  posicionamentoOfensivo,
  drible,
  chuteDeLonge,
  penaltis,

  // DEFENSIVO
  marcacao,
  desarme,
  interceptacao,
  coberturaDefensiva,
  jogoAereo,

  // TECNICO
  passeCurto,
  passeLongo,
  dominioEConducao,
  cruzamento,
  bolaParada,

  // FISICO
  potencia,
  velocidade,
  resistencia,
  aptidaoFisica,
  coordenacaoMotora,

  // MENTAL
  tomadaDeDecisao,
  frieza,
  lideranca,
  espiritoProtagonista,
  leituraTatica,

  // GOLEIRO (10)
  gkDefesaPerto,
  gkDefesaLonge,
  gkDefesaPenalti,
  gkDefesaBolaParada,
  gkUmContraUm,
  gkJogoAereo,
  gkDistribuicaoCurta,
  gkDistribuicaoLonga,
  gkLibero,
  gkReflexos,
}

extension AtributoX on Atributo {
  /// Chave canônica para salvar em JSON/Hive (PT-BR sem acento).
  String get key {
    switch (this) {
      case Atributo.finalizacao:
        return 'finalizacao';
      case Atributo.posicionamentoOfensivo:
        return 'posicionamento_ofensivo';
      case Atributo.drible:
        return 'drible';
      case Atributo.chuteDeLonge:
        return 'chute_de_longe';
      case Atributo.penaltis:
        return 'penaltis';

      case Atributo.marcacao:
        return 'marcacao';
      case Atributo.desarme:
        return 'desarme';
      case Atributo.interceptacao:
        return 'interceptacao';
      case Atributo.coberturaDefensiva:
        return 'cobertura_defensiva';
      case Atributo.jogoAereo:
        return 'jogo_aereo';

      case Atributo.passeCurto:
        return 'passe_curto';
      case Atributo.passeLongo:
        return 'passe_longo';
      case Atributo.dominioEConducao:
        return 'dominio_e_conducao';
      case Atributo.cruzamento:
        return 'cruzamento';
      case Atributo.bolaParada:
        return 'bola_parada';

      case Atributo.potencia:
        return 'potencia';
      case Atributo.velocidade:
        return 'velocidade';
      case Atributo.resistencia:
        return 'resistencia';
      case Atributo.aptidaoFisica:
        return 'aptidao_fisica';
      case Atributo.coordenacaoMotora:
        return 'coordenacao_motora';

      case Atributo.tomadaDeDecisao:
        return 'tomada_de_decisao';
      case Atributo.frieza:
        return 'frieza';
      case Atributo.lideranca:
        return 'lideranca';
      case Atributo.espiritoProtagonista:
        return 'espirito_protagonista';
      case Atributo.leituraTatica:
        return 'leitura_tatica';

      case Atributo.gkDefesaPerto:
        return 'gk_defesa_perto';
      case Atributo.gkDefesaLonge:
        return 'gk_defesa_longe';
      case Atributo.gkDefesaPenalti:
        return 'gk_defesa_penalti';
      case Atributo.gkDefesaBolaParada:
        return 'gk_defesa_bola_parada';
      case Atributo.gkUmContraUm:
        return 'gk_um_contra_um';
      case Atributo.gkJogoAereo:
        return 'gk_jogo_aereo';
      case Atributo.gkDistribuicaoCurta:
        return 'gk_distribuicao_curta';
      case Atributo.gkDistribuicaoLonga:
        return 'gk_distribuicao_longa';
      case Atributo.gkLibero:
        return 'gk_libero';
      case Atributo.gkReflexos:
        return 'gk_reflexos';
    }
  }

  static Atributo? fromKey(String key) {
    for (final a in Atributo.values) {
      if (a.key == key) return a;
    }
    return null;
  }

  bool get isGoleiro => key.startsWith('gk_');
}
