// FutSim – Parte 1 (Spring 1)
// Modelo de Jogador: 10 atributos por função (escala 1–10) e overall por posição (0–100)

import 'dart:convert';

/// Posições suportadas no MVP
enum Posicao {
  GOL, // Goleiro
  ZAG, // Zagueiro
  LAT, // Lateral
  VOL, // Volante (DM)
  MC, // Meia Central (CM)
  MEI, // Meia Ofensivo (AM)
  PON, // Ponta (Winger)
  SA, // Segundo Atacante (SS)
  ATA, // Centroavante (ST)
}

/// Nome canônico das chaves de atributos (em inglês p/ simplificar os pesos)
class AttrKey {
  // Goleiro
  static const String gkLongShotSave = 'gk_long_shot_saving';
  static const String gkCloseShotSave = 'gk_close_shot_saving';
  static const String gkPenaltySave = 'gk_penalty_saving';
  static const String gkSetPieceSave = 'gk_set_piece_saving';
  static const String gkOneOnOne = 'gk_one_on_one';
  static const String gkAerial = 'gk_aerial';
  static const String gkDistribShort = 'gk_distribution_short';
  static const String gkDistribLong = 'gk_distribution_long';
  static const String gkSweeper = 'gk_sweeper';
  static const String gkReflexes = 'gk_reflexes';

  // Defensivos/gerais
  static const String marking = 'marking';
  static const String tackling = 'tackling';
  static const String interception = 'interception';
  static const String strength = 'strength';
  static const String aggression = 'aggression';
  static const String positioningDef = 'positioning_def';
  static const String aerialDuel = 'aerial_duel';
  static const String shortPassing = 'short_passing';
  static const String longPassing = 'long_passing';
  static const String pace = 'pace';
  static const String acceleration = 'acceleration';
  static const String stamina = 'stamina';
  static const String crossing = 'crossing';
  static const String dribbling = 'dribbling';
  static const String firstTouch = 'first_touch';
  static const String vision = 'vision';
  static const String composure = 'composure';
  static const String anticipation = 'anticipation';
  static const String workRate = 'work_rate';

  // Ofensivos
  static const String finishing = 'finishing';
  static const String positioningOff = 'positioning_off';
  static const String heading = 'heading';
  static const String longShots = 'long_shots';
  static const String penalties = 'penalties';
  static const String volleys = 'volleys';
  static const String throughBalls = 'through_balls';
  static const String flair = 'flair';
}

/// Para cada posição: lista de 10 atributos e pesos (somam 1.0)
class PosicaoPerfil {
  final List<String> chaves; // exatamente 10
  final Map<String, double> pesos; // somatório ≈ 1.0
  const PosicaoPerfil(this.chaves, this.pesos);
}

/// Perfis de atributos por posição (10 chaves cada)
const Map<Posicao, PosicaoPerfil> kPerfisPosicao = {
  Posicao.GOL: PosicaoPerfil([
    AttrKey.gkCloseShotSave,
    AttrKey.gkLongShotSave,
    AttrKey.gkPenaltySave,
    AttrKey.gkSetPieceSave,
    AttrKey.gkOneOnOne,
    AttrKey.gkAerial,
    AttrKey.gkDistribShort,
    AttrKey.gkDistribLong,
    AttrKey.gkSweeper,
    AttrKey.gkReflexes,
  ], {
    AttrKey.gkCloseShotSave: 0.16,
    AttrKey.gkLongShotSave: 0.10,
    AttrKey.gkPenaltySave: 0.08,
    AttrKey.gkSetPieceSave: 0.08,
    AttrKey.gkOneOnOne: 0.14,
    AttrKey.gkAerial: 0.10,
    AttrKey.gkDistribShort: 0.08,
    AttrKey.gkDistribLong: 0.06,
    AttrKey.gkSweeper: 0.08,
    AttrKey.gkReflexes: 0.12,
  }),
  Posicao.ZAG: PosicaoPerfil([
    AttrKey.marking,
    AttrKey.tackling,
    AttrKey.interception,
    AttrKey.strength,
    AttrKey.aerialDuel,
    AttrKey.positioningDef,
    AttrKey.shortPassing,
    AttrKey.pace,
    AttrKey.anticipation,
    AttrKey.composure,
  ], {
    AttrKey.marking: 0.18,
    AttrKey.tackling: 0.18,
    AttrKey.interception: 0.12,
    AttrKey.strength: 0.12,
    AttrKey.aerialDuel: 0.12,
    AttrKey.positioningDef: 0.12,
    AttrKey.shortPassing: 0.06,
    AttrKey.pace: 0.05,
    AttrKey.anticipation: 0.03,
    AttrKey.composure: 0.02,
  }),
  Posicao.LAT: PosicaoPerfil([
    AttrKey.acceleration,
    AttrKey.pace,
    AttrKey.stamina,
    AttrKey.crossing,
    AttrKey.shortPassing,
    AttrKey.tackling,
    AttrKey.positioningDef,
    AttrKey.dribbling,
    AttrKey.workRate,
    AttrKey.anticipation,
  ], {
    AttrKey.acceleration: 0.14,
    AttrKey.pace: 0.12,
    AttrKey.stamina: 0.12,
    AttrKey.crossing: 0.12,
    AttrKey.shortPassing: 0.10,
    AttrKey.tackling: 0.10,
    AttrKey.positioningDef: 0.10,
    AttrKey.dribbling: 0.08,
    AttrKey.workRate: 0.07,
    AttrKey.anticipation: 0.05,
  }),
  Posicao.VOL: PosicaoPerfil([
    AttrKey.positioningDef,
    AttrKey.tackling,
    AttrKey.interception,
    AttrKey.stamina,
    AttrKey.shortPassing,
    AttrKey.longPassing,
    AttrKey.strength,
    AttrKey.vision,
    AttrKey.composure,
    AttrKey.aggression,
  ], {
    AttrKey.positioningDef: 0.16,
    AttrKey.tackling: 0.16,
    AttrKey.interception: 0.12,
    AttrKey.stamina: 0.10,
    AttrKey.shortPassing: 0.10,
    AttrKey.longPassing: 0.08,
    AttrKey.strength: 0.08,
    AttrKey.vision: 0.08,
    AttrKey.composure: 0.06,
    AttrKey.aggression: 0.06,
  }),
  Posicao.MC: PosicaoPerfil([
    AttrKey.shortPassing,
    AttrKey.longPassing,
    AttrKey.vision,
    AttrKey.firstTouch,
    AttrKey.stamina,
    AttrKey.workRate,
    AttrKey.positioningDef,
    AttrKey.tackling,
    AttrKey.dribbling,
    AttrKey.composure,
  ], {
    AttrKey.shortPassing: 0.18,
    AttrKey.longPassing: 0.12,
    AttrKey.vision: 0.16,
    AttrKey.firstTouch: 0.12,
    AttrKey.stamina: 0.08,
    AttrKey.workRate: 0.06,
    AttrKey.positioningDef: 0.08,
    AttrKey.tackling: 0.06,
    AttrKey.dribbling: 0.08,
    AttrKey.composure: 0.06,
  }),
  Posicao.MEI: PosicaoPerfil([
    AttrKey.vision,
    AttrKey.shortPassing,
    AttrKey.dribbling,
    AttrKey.firstTouch,
    AttrKey.longShots,
    AttrKey.throughBalls,
    AttrKey.finishing,
    AttrKey.composure,
    AttrKey.acceleration,
    AttrKey.flair,
  ], {
    AttrKey.vision: 0.18,
    AttrKey.shortPassing: 0.16,
    AttrKey.dribbling: 0.14,
    AttrKey.firstTouch: 0.12,
    AttrKey.longShots: 0.08,
    AttrKey.throughBalls: 0.10,
    AttrKey.finishing: 0.08,
    AttrKey.composure: 0.06,
    AttrKey.acceleration: 0.04,
    AttrKey.flair: 0.04,
  }),
  Posicao.PON: PosicaoPerfil([
    AttrKey.acceleration,
    AttrKey.pace,
    AttrKey.dribbling,
    AttrKey.crossing,
    AttrKey.positioningOff,
    AttrKey.finishing,
    AttrKey.firstTouch,
    AttrKey.stamina,
    AttrKey.flair,
    AttrKey.workRate,
  ], {
    AttrKey.acceleration: 0.18,
    AttrKey.pace: 0.16,
    AttrKey.dribbling: 0.18,
    AttrKey.crossing: 0.10,
    AttrKey.positioningOff: 0.08,
    AttrKey.finishing: 0.08,
    AttrKey.firstTouch: 0.08,
    AttrKey.stamina: 0.06,
    AttrKey.flair: 0.04,
    AttrKey.workRate: 0.04,
  }),
  Posicao.SA: PosicaoPerfil([
    AttrKey.positioningOff,
    AttrKey.finishing,
    AttrKey.firstTouch,
    AttrKey.dribbling,
    AttrKey.vision,
    AttrKey.shortPassing,
    AttrKey.longShots,
    AttrKey.acceleration,
    AttrKey.composure,
    AttrKey.heading,
  ], {
    AttrKey.positioningOff: 0.16,
    AttrKey.finishing: 0.16,
    AttrKey.firstTouch: 0.12,
    AttrKey.dribbling: 0.12,
    AttrKey.vision: 0.08,
    AttrKey.shortPassing: 0.08,
    AttrKey.longShots: 0.08,
    AttrKey.acceleration: 0.08,
    AttrKey.composure: 0.06,
    AttrKey.heading: 0.06,
  }),
  Posicao.ATA: PosicaoPerfil([
    AttrKey.finishing,
    AttrKey.positioningOff,
    AttrKey.heading,
    AttrKey.strength,
    AttrKey.firstTouch,
    AttrKey.acceleration,
    AttrKey.composure,
    AttrKey.penalties,
    AttrKey.volleys,
    AttrKey.pace,
  ], {
    AttrKey.finishing: 0.22,
    AttrKey.positioningOff: 0.18,
    AttrKey.heading: 0.12,
    AttrKey.strength: 0.10,
    AttrKey.firstTouch: 0.10,
    AttrKey.acceleration: 0.08,
    AttrKey.composure: 0.08,
    AttrKey.penalties: 0.06,
    AttrKey.volleys: 0.04,
    AttrKey.pace: 0.02,
  }),
};

/// Modelo de Jogador
class Jogador {
  final String id;
  final String nome;
  final int idade; // recomendável 16..40
  final String nacionalidade;

  final Posicao posicaoPrincipal;
  final List<Posicao> funcoesSecundarias;

  final Map<String, int> atributos; // 1..10

  const Jogador({
    required this.id,
    required this.nome,
    required this.idade,
    required this.nacionalidade,
    required this.posicaoPrincipal,
    this.funcoesSecundarias = const [],
    required this.atributos,
  });

  Jogador copyWith({
    String? id,
    String? nome,
    int? idade,
    String? nacionalidade,
    Posicao? posicaoPrincipal,
    List<Posicao>? funcoesSecundarias,
    Map<String, int>? atributos,
  }) {
    return Jogador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
      nacionalidade: nacionalidade ?? this.nacionalidade,
      posicaoPrincipal: posicaoPrincipal ?? this.posicaoPrincipal,
      funcoesSecundarias: funcoesSecundarias ?? this.funcoesSecundarias,
      atributos: atributos ?? this.atributos,
    );
  }

  Map<String, int> get atributosValidados {
    final out = <String, int>{};
    atributos.forEach((k, v) {
      var nv = v;
      if (nv < 1) nv = 1;
      if (nv > 10) nv = 10;
      out[k] = nv;
    });
    return out;
  }

  double overallPara(Posicao posicao) {
    final perfil = kPerfisPosicao[posicao]!;
    final ats = atributosValidados;
    double soma = 0.0;
    for (final key in perfil.chaves) {
      final val = (ats[key] ?? 1).toDouble();
      final esc = val * 10.0; // 1..10 -> 10..100
      final peso = perfil.pesos[key] ?? 0.0;
      soma += esc * peso;
    }
    return double.parse(soma.toStringAsFixed(1));
  }

  double get overallPrincipal => overallPara(posicaoPrincipal);

  MapEntry<Posicao, double> melhorPosicao() {
    Posicao melhor = posicaoPrincipal;
    double melhorVal = overallPara(posicaoPrincipal);
    for (final p in Posicao.values) {
      final val = overallPara(p);
      if (val > melhorVal) {
        melhor = p;
        melhorVal = val;
      }
    }
    return MapEntry(melhor, melhorVal);
  }

  double overallComPenalidade(Posicao jogandoEm,
      {bool aplicarPenalidade = false}) {
    final base = overallPara(jogandoEm);
    if (!aplicarPenalidade) return base;
    final bool posCorreta =
        jogandoEm == posicaoPrincipal || funcoesSecundarias.contains(jogandoEm);
    if (posCorreta) return base;
    return double.parse((base * 0.78).toStringAsFixed(1)); // -22%
  }

  factory Jogador.fromJson(Map<String, dynamic> json) {
    return Jogador(
      id: json['id'] as String,
      nome: json['nome'] as String,
      idade: json['idade'] as int,
      nacionalidade: json['nacionalidade'] as String,
      posicaoPrincipal: _posicaoFromString(json['posicaoPrincipal'] as String),
      funcoesSecundarias: (json['funcoesSecundarias'] as List<dynamic>? ?? [])
          .map((e) => _posicaoFromString(e as String))
          .toList(),
      atributos: (json['atributos'] as Map)
          .map((k, v) => MapEntry(k as String, (v as num).toInt())),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'idade': idade,
        'nacionalidade': nacionalidade,
        'posicaoPrincipal': _posicaoToString(posicaoPrincipal),
        'funcoesSecundarias': funcoesSecundarias.map(_posicaoToString).toList(),
        'atributos': atributosValidados,
      };

  @override
  String toString() => jsonEncode(toJson());

  static String _posicaoToString(Posicao p) => p.name;
  static Posicao _posicaoFromString(String s) =>
      Posicao.values.firstWhere((e) => e.name == s);

  Jogador comAtributosCompletosPara(Posicao posicao) {
    final perfil = kPerfisPosicao[posicao]!;
    final novo = Map<String, int>.from(atributos);
    for (final key in perfil.chaves) {
      novo.putIfAbsent(key, () => 1);
    }
    return copyWith(atributos: novo);
  }
}
