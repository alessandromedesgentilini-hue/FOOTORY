import 'package:footory26/models/coach_tactical_identity.dart';

class CoachTacticalCatalog {
  static const gegenpress = CoachTacticalIdentity(
    id: 'gegenpress',
    name: 'Gegenpress',
    shortDescription:
        'Pressão sufocante, intensidade alta e recuperação agressiva da bola.',
    philosophyDescription:
        'A equipe joga para roubar a bola o mais rápido possível. Após perder a posse, o time encurta espaços, pressiona em bloco e tenta transformar cada recuperação em ataque perigoso.',
    mainFormation: '433',
    secondaryFormations: [
      '4231_wide',
      '343',
    ],
    pressureBias: 1.0,
    possessionBias: 0.45,
    transitionBias: 1.0,
    setPieceBias: 0.35,
  );

  static const tikiTaka = CoachTacticalIdentity(
    id: 'tiki_taka',
    name: 'Tiki-Taka',
    shortDescription:
        'Controle da posse, passes curtos e domínio territorial constante.',
    philosophyDescription:
        'A equipe busca controlar o jogo com paciência, circulação rápida e triangulações. O objetivo é cansar o adversário, encontrar espaços e mandar no ritmo da partida.',
    mainFormation: '4312',
    secondaryFormations: [
      '433',
      '4231_wide',
    ],
    pressureBias: 0.60,
    possessionBias: 1.0,
    transitionBias: 0.35,
    setPieceBias: 0.25,
  );

  static const jogoApoiado = CoachTacticalIdentity(
    id: 'support_play',
    name: 'Jogo Apoiado',
    shortDescription:
        'Aproximação entre setores, coletividade e construção segura das jogadas.',
    philosophyDescription:
        'A equipe procura jogar junto. Laterais, meias e atacantes se aproximam para criar linhas de passe, manter a bola viva e construir ataques com apoio constante.',
    mainFormation: '4231_wide',
    secondaryFormations: [
      '433',
      '442_flat',
    ],
    pressureBias: 0.55,
    possessionBias: 0.70,
    transitionBias: 0.50,
    setPieceBias: 0.30,
  );

  static const bolaParada = CoachTacticalIdentity(
    id: 'set_piece',
    name: 'Bola Parada',
    shortDescription:
        'Organização, força aérea e eficiência nos detalhes que decidem partidas.',
    philosophyDescription:
        'A equipe valoriza cada falta, escanteio e lateral perigoso como uma chance real de gol. O time tende a ser pragmático, organizado e forte em duelos físicos.',
    mainFormation: '442_flat',
    secondaryFormations: [
      '352',
      '4141',
    ],
    pressureBias: 0.35,
    possessionBias: 0.40,
    transitionBias: 0.55,
    setPieceBias: 1.0,
  );

  static const periodizacao = CoachTacticalIdentity(
    id: 'tactical_periodization',
    name: 'Periodização Tática',
    shortDescription:
        'Equilíbrio coletivo, treino estruturado e adaptação aos momentos do jogo.',
    philosophyDescription:
        'A equipe busca crescer de forma organizada. O foco está na leitura dos momentos da partida, no equilíbrio entre setores e na evolução coletiva ao longo da temporada.',
    mainFormation: '4141',
    secondaryFormations: [
      '4231_wide',
      '433',
    ],
    pressureBias: 0.55,
    possessionBias: 0.60,
    transitionBias: 0.60,
    setPieceBias: 0.45,
  );

  static const fallback = periodizacao;

  static const all = <CoachTacticalIdentity>[
    gegenpress,
    tikiTaka,
    jogoApoiado,
    bolaParada,
    periodizacao,
  ];

  static CoachTacticalIdentity fromId(String id) {
    return all.firstWhere(
      (e) => e.id == id,
      orElse: () => fallback,
    );
  }
}
