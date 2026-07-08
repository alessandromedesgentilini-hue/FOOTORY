import 'package:footory26/models/player.dart';

String flagAssetFromCode(String code) {
  final normalized = code.trim().toLowerCase();

  switch (normalized) {
    case 'gb':
    case 'uk':
    case 'en':
    case 'eng':
      return 'assets/flags/eng.png';
    default:
      return 'assets/flags/$normalized.png';
  }
}

String countryDisplayName(String code) {
  switch (code.trim().toLowerCase()) {
    case 'br':
      return 'Brasil';
    case 'ar':
      return 'Argentina';
    case 'uy':
      return 'Uruguai';
    case 'py':
      return 'Paraguai';
    case 'cl':
      return 'Chile';
    case 'bo':
      return 'Bolívia';
    case 've':
      return 'Venezuela';
    case 'ec':
      return 'Equador';
    case 'co':
      return 'Colômbia';
    case 'pe':
      return 'Peru';
    case 'mx':
      return 'México';
    case 'cr':
      return 'Costa Rica';
    case 'us':
      return 'Estados Unidos';
    case 'ca':
      return 'Canadá';
    case 'it':
      return 'Itália';
    case 'es':
      return 'Espanha';
    case 'de':
      return 'Alemanha';
    case 'fr':
      return 'França';
    case 'pt':
      return 'Portugal';
    case 'nl':
      return 'Holanda';
    case 'be':
      return 'Bélgica';
    case 'hr':
      return 'Croácia';
    case 'rs':
      return 'Sérvia';
    case 'is':
      return 'Islândia';
    case 'ch':
      return 'Suíça';
    case 'se':
      return 'Suécia';
    case 'dk':
      return 'Dinamarca';
    case 'no':
      return 'Noruega';
    case 'pl':
      return 'Polônia';
    case 'at':
      return 'Áustria';
    case 'cz':
      return 'República Tcheca';
    case 'eng':
    case 'gb':
    case 'uk':
    case 'en':
      return 'Inglaterra';
    case 'jp':
      return 'Japão';
    case 'cn':
      return 'China';
    case 'kr':
      return 'Coreia do Sul';
    case 'sa':
      return 'Arábia Saudita';
    case 'ir':
      return 'Irã';
    case 'au':
      return 'Austrália';
    case 'ng':
      return 'Nigéria';
    case 'ci':
      return 'Costa do Marfim';
    case 'sn':
      return 'Senegal';
    case 'ml':
      return 'Mali';
    case 'cm':
      return 'Camarões';
    case 'gh':
      return 'Gana';
    case 'dz':
      return 'Argélia';
    case 'ma':
      return 'Marrocos';
    default:
      return code.trim().toUpperCase();
  }
}

String posLabel(PosDet pos) {
  switch (pos) {
    case PosDet.gol:
      return 'Goleiro';
    case PosDet.ld:
      return 'Lateral Direito';
    case PosDet.le:
      return 'Lateral Esquerdo';
    case PosDet.zag:
      return 'Zagueiro';
    case PosDet.vol:
      return 'Volante';
    case PosDet.mc:
      return 'Meio-Campo';
    case PosDet.mei:
      return 'Meia';
    case PosDet.pd:
      return 'Ponta Direita';
    case PosDet.pe:
      return 'Ponta Esquerda';
    case PosDet.ca:
      return 'Centroavante';
  }
}

String footLabel(String pe) {
  switch (pe.toUpperCase()) {
    case 'E':
      return 'Canhoto';
    case 'A':
      return 'Ambidestro';
    default:
      return 'Destro';
  }
}

String prettyAttrName(String key) {
  const map = <String, String>{
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

  return map[key] ?? key;
}
