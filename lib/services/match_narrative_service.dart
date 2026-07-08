import 'dart:math';

import 'package:footory26/models/coach_tactical_identity.dart';
import 'package:footory26/services/world/catalog/coach_tactical_catalog.dart';

class MatchNarrativeService {
  MatchNarrativeService({Random? random}) : _random = random ?? Random();

  final Random _random;

  String build({
    required String clubName,
    required String tacticalIdentityId,
    required int coachLevel,
    required bool isHome,
    required int goalsFor,
    required int goalsAgainst,
  }) {
    final identity = CoachTacticalCatalog.fromId(tacticalIdentityId);
    final tier = _tierFromCoachLevel(coachLevel);
    final margin = (goalsFor - goalsAgainst).abs();

    final pool = goalsFor > goalsAgainst
        ? _buildWinPool(
            clubName: clubName,
            identity: identity,
            tier: tier,
            isHome: isHome,
            margin: margin,
          )
        : goalsFor == goalsAgainst
            ? _buildDrawPool(
                clubName: clubName,
                identity: identity,
                tier: tier,
                isHome: isHome,
              )
            : _buildLossPool(
                clubName: clubName,
                identity: identity,
                tier: tier,
                isHome: isHome,
                margin: margin,
              );

    if (pool.isEmpty) {
      return '$clubName viveu uma partida dentro de sua proposta, mas sem um retrato narrativo claro.';
    }

    return pool[_random.nextInt(pool.length)];
  }

  List<String> _buildWinPool({
    required String clubName,
    required CoachTacticalIdentity identity,
    required _CoachTier tier,
    required bool isHome,
    required int margin,
  }) {
    switch (identity.id) {
      case 'gegenpress':
        switch (tier) {
          case _CoachTier.low:
            return [
              '$clubName venceu na base da intensidade. A pressão ainda não foi perfeita, mas a equipe já mostrou vontade de sufocar o adversário.',
              '$clubName correu riscos, apertou alto e encontrou a vitória mesmo com uma execução ainda irregular do Gegenpress.',
              '$clubName transformou energia em resultado. A equipe pressionou mais do que organizou, mas fez o suficiente para vencer.',
            ];
          case _CoachTier.mid:
            return [
              '$clubName pressionou alto, forçou erros e construiu a vitória com agressividade.',
              '$clubName acelerou a partida, incomodou a saída rival e venceu com uma pressão já bem mais coordenada.',
              '$clubName encurtou espaços, recuperou bolas importantes e fez a intensidade virar resultado.',
            ];
          case _CoachTier.high:
            return [
              '$clubName sufocou o adversário por longos trechos e venceu impondo intensidade do início ao fim.',
              '$clubName dominou o ritmo físico da partida e transformou pressão em controle real do jogo.',
              '$clubName foi agressivo, compacto e muito coordenado para construir uma vitória forte.',
            ];
          case _CoachTier.elite:
            return [
              '$clubName estrangulou o rival desde a perda da bola e venceu com um Gegenpress de elite.',
              '$clubName fez a partida girar em sua pressão, recuperou bolas em zonas perigosas e venceu com autoridade.',
              '$clubName atropelou no ritmo, pressionou sem parar e confirmou uma atuação de altíssimo nível.',
            ];
        }

      case 'tiki_taka':
        switch (tier) {
          case _CoachTier.low:
            return [
              '$clubName tentou controlar a posse e, mesmo longe da versão ideal do Tiki-Taka, encontrou o caminho da vitória.',
              '$clubName buscou ter a bola por mais tempo e venceu com uma ideia de jogo ainda em construção.',
              '$clubName mostrou paciência com a bola, oscilou na execução, mas conseguiu transformar posse em resultado.',
            ];
          case _CoachTier.mid:
            return [
              '$clubName circulou melhor a bola e construiu a vitória com mais controle das ações.',
              '$clubName teve mais domínio do ritmo e venceu com sinais claros de evolução no controle do jogo.',
              '$clubName soube trocar passes, ocupar espaços e vencer sem perder sua proposta.',
            ];
          case _CoachTier.high:
            return [
              '$clubName impôs posse, ritmo e circulação de bola para construir a vitória com autoridade.',
              '$clubName comandou o jogo com a bola nos pés e venceu com uma atuação de bastante controle.',
              '$clubName controlou territórios, cansou o adversário e transformou paciência em vitória.',
            ];
          case _CoachTier.elite:
            return [
              '$clubName deu uma aula de controle, posse e ritmo, vencendo com um Tiki-Taka de nível elite.',
              '$clubName mandou no jogo do início ao fim e transformou posse em domínio real da partida.',
              '$clubName fez o adversário correr atrás da bola e venceu com autoridade técnica impressionante.',
            ];
        }

      case 'support_play':
        switch (tier) {
          case _CoachTier.low:
            return [
              '$clubName tentou aproximar suas peças e encontrou a vitória com um jogo coletivo ainda em crescimento.',
              '$clubName buscou jogar mais junto e venceu apoiado em conexões curtas, mesmo sem grande refinamento.',
              '$clubName mostrou intenção coletiva, aproximou setores e construiu uma vitória importante.',
            ];
          case _CoachTier.mid:
            return [
              '$clubName venceu com boa circulação curta e aproximações que deram fluidez ao ataque.',
              '$clubName conseguiu jogar mais perto entre setores e transformou essa conexão em resultado.',
              '$clubName fez um jogo coletivo mais limpo e venceu com boas combinações ofensivas.',
            ];
          case _CoachTier.high:
            return [
              '$clubName jogou junto, triangulou bem e construiu uma vitória com bastante fluidez ofensiva.',
              '$clubName conectou suas peças com qualidade e venceu através de um jogo coletivo muito sólido.',
              '$clubName foi fluido, próximo e criativo para construir uma vitória convincente.',
            ];
          case _CoachTier.elite:
            return [
              '$clubName deu uma aula de jogo apoiado, com conexões rápidas e ataque coletivo de altíssimo nível.',
              '$clubName jogou em bloco, conectou setores o tempo todo e venceu com futebol coletivo de elite.',
              '$clubName transformou aproximação e fluidez em domínio ofensivo, vencendo como uma equipe muito madura.',
            ];
        }

      case 'set_piece':
        switch (tier) {
          case _CoachTier.low:
            return [
              '$clubName venceu de forma pragmática, brigando por cada detalhe e valorizando os momentos decisivos.',
              '$clubName não encantou, mas foi competitivo, objetivo e encontrou a vitória na eficiência.',
              '$clubName fez um jogo simples, disputou cada bola e venceu com espírito prático.',
            ];
          case _CoachTier.mid:
            return [
              '$clubName foi objetivo, controlou melhor os detalhes e fez a eficiência pesar a seu favor.',
              '$clubName soube travar o jogo quando precisava e decidiu a partida de forma prática.',
              '$clubName venceu sem desperdiçar energia, apoiado em organização e boa leitura dos lances decisivos.',
            ];
          case _CoachTier.high:
            return [
              '$clubName soube jogar com frieza, foi forte nos detalhes e construiu uma vitória muito eficiente.',
              '$clubName foi maduro, competitivo e decidiu a partida com precisão nos momentos certos.',
              '$clubName fez um jogo frio, organizado e eficiente, exatamente dentro da sua proposta.',
            ];
          case _CoachTier.elite:
            return [
              '$clubName transformou organização e detalhe em domínio prático do jogo, vencendo com autoridade fria.',
              '$clubName venceu com eficiência quase cirúrgica, controlando cada pequena vantagem da partida.',
              '$clubName foi implacável nos detalhes e confirmou uma atuação pragmática de altíssimo nível.',
            ];
        }

      case 'tactical_periodization':
      default:
        switch (tier) {
          case _CoachTier.low:
            return [
              '$clubName venceu com mais organização, ainda construindo uma identidade coletiva mais clara.',
              '$clubName mostrou disciplina, respeitou a proposta e encontrou a vitória mesmo com execução irregular.',
              '$clubName fez um jogo consciente, controlou alguns momentos e saiu com um resultado importante.',
            ];
          case _CoachTier.mid:
            return [
              '$clubName fez o jogo certo, controlou melhor os espaços e encontrou a vitória com inteligência.',
              '$clubName soube competir, leu bem os momentos da partida e construiu um resultado importante.',
              '$clubName venceu com organização, escolhas corretas e uma leitura mais madura do jogo.',
            ];
          case _CoachTier.high:
            return [
              '$clubName mostrou organização, leitura e transições firmes para vencer com muita maturidade.',
              '$clubName executou bem seu plano de jogo e venceu controlando espaços e momentos-chave.',
              '$clubName foi estrategicamente forte e transformou equilíbrio coletivo em vitória consistente.',
            ];
          case _CoachTier.elite:
            return [
              '$clubName executou o plano com precisão e venceu com uma atuação estrategicamente impecável.',
              '$clubName controlou a partida com inteligência superior e venceu sem perder sua estrutura.',
              '$clubName jogou exatamente a partida que precisava e confirmou sua força com execução de elite.',
            ];
        }
    }
  }

  List<String> _buildDrawPool({
    required String clubName,
    required CoachTacticalIdentity identity,
    required _CoachTier tier,
    required bool isHome,
  }) {
    switch (identity.id) {
      case 'gegenpress':
        return isHome
            ? [
                '$clubName pressionou bastante, mas transformou pouca intensidade em vantagem real.',
                '$clubName tentou sufocar o rival, porém faltou precisão para transformar roubo de bola em vitória.',
                '$clubName jogou em alta rotação, mas a pressão não encontrou a recompensa final.',
              ]
            : [
                '$clubName brigou em alta rotação e arrancou um empate importante fora de casa.',
                '$clubName fez da intensidade sua principal arma e trouxe um ponto valioso.',
                '$clubName pressionou, correu riscos e saiu de campo com um empate competitivo.',
              ];

      case 'tiki_taka':
        return isHome
            ? [
                '$clubName teve a bola por longos momentos, mas o controle não virou vitória.',
                '$clubName controlou boa parte das ações, mas faltou transformar posse em golpe final.',
                '$clubName dominou territórios, circulou a bola, mas encontrou pouca profundidade.',
              ]
            : [
                '$clubName tentou controlar o ritmo fora de casa e somou um ponto útil.',
                '$clubName buscou controlar a posse longe de casa e saiu com um empate aceitável.',
                '$clubName teve paciência com a bola e segurou um empate dentro da sua proposta.',
              ];

      case 'support_play':
        return isHome
            ? [
                '$clubName conectou boas jogadas, mas faltou precisão no último terço.',
                '$clubName tentou acelerar combinações curtas, mas não teve contundência suficiente.',
                '$clubName aproximou setores e construiu bem, porém faltou transformar fluidez em vitória.',
              ]
            : [
                '$clubName tentou jogar junto e construir por baixo, saindo com um ponto honesto.',
                '$clubName manteve sua proposta coletiva e preservou um empate fora de casa.',
                '$clubName encontrou conexões em bons momentos e voltou com um empate aceitável.',
              ];

      case 'set_piece':
        return isHome
            ? [
                '$clubName tentou decidir nos detalhes, mas o empate em casa deixa sensação de chance perdida.',
                '$clubName fez um jogo pragmático, porém não foi eficiente o bastante para vencer.',
                '$clubName buscou força nas jogadas decisivas, mas faltou precisão nos momentos finais.',
              ]
            : [
                '$clubName travou o jogo e arrancou um ponto funcional longe de casa.',
                '$clubName soube competir nos detalhes e saiu com um empate útil.',
                '$clubName foi organizado, reduziu riscos e voltou para casa com um ponto pragmático.',
              ];

      case 'tactical_periodization':
      default:
        return isHome
            ? [
                '$clubName fez um jogo organizado, mas não encontrou o golpe certo para vencer.',
                '$clubName jogou com disciplina, porém faltou contundência para transformar controle em resultado.',
                '$clubName alternou bons momentos de domínio, mas não conseguiu sustentar vantagem.',
              ]
            : [
                '$clubName competiu com inteligência e trouxe um ponto importante para casa.',
                '$clubName executou uma partida equilibrada fora de casa e somou um empate útil.',
                '$clubName leu bem alguns momentos da partida e preservou um resultado importante.',
              ];
    }
  }

  List<String> _buildLossPool({
    required String clubName,
    required CoachTacticalIdentity identity,
    required _CoachTier tier,
    required bool isHome,
    required int margin,
  }) {
    switch (identity.id) {
      case 'gegenpress':
        return [
          '$clubName tentou sufocar o rival, mas deixou espaços e acabou castigado.',
          '$clubName pressionou forte por momentos, porém a exposição custou caro.',
          '$clubName jogou em alta rotação, mas a intensidade virou risco quando a equipe perdeu organização.',
        ];

      case 'tiki_taka':
        return [
          '$clubName tentou controlar o jogo, mas a posse pouco virou perigo real.',
          '$clubName teve a bola em bons momentos, mas faltou agressividade para evitar a derrota.',
          '$clubName circulou bastante, porém encontrou pouca profundidade e acabou punido.',
        ];

      case 'support_play':
        return [
          '$clubName tentou construir coletivamente, mas não teve força suficiente para evitar a derrota.',
          '$clubName conectou suas peças por momentos, mas faltou contundência.',
          '$clubName buscou aproximações e jogo curto, porém perdeu impacto nos metros finais.',
        ];

      case 'set_piece':
        return [
          '$clubName apostou no pragmatismo, mas viu o rival ser mais eficiente.',
          '$clubName tentou sobreviver nos detalhes, porém acabou castigado.',
          '$clubName disputou o jogo em margens pequenas, mas não conseguiu vencer os lances decisivos.',
        ];

      case 'tactical_periodization':
      default:
        return [
          '$clubName foi competitivo por trechos, mas não encontrou a execução necessária.',
          '$clubName até teve momentos organizados, mas faltou transformar isso em resultado.',
          '$clubName tentou controlar os momentos do jogo, porém não conseguiu responder quando a partida mudou.',
        ];
    }
  }

  _CoachTier _tierFromCoachLevel(int level) {
    final v = level.clamp(1, 10);

    if (v <= 4) return _CoachTier.low;
    if (v <= 6) return _CoachTier.mid;
    if (v <= 8) return _CoachTier.high;

    return _CoachTier.elite;
  }
}

enum _CoachTier {
  low,
  mid,
  high,
  elite,
}
