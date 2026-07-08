import 'dart:math';

import 'package:footory26/models/coach_tactical_identity.dart';
import 'package:footory26/models/match_live_event.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/services/match_engine.dart';
import 'package:footory26/services/world/catalog/coach_tactical_catalog.dart';

class MatchLiveNarrativeService {
  MatchLiveNarrativeService({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<MatchLiveEvent> buildEvents({
    required String homeClubName,
    required String awayClubName,
    required MatchResult result,
    required String userClubId,
    required String homeClubId,
    required String awayClubId,
    required String userTacticalIdentityId,
    required List<Player> userSquad,
    int userCoachLevel = 5,
    int userMedicalLevel = 5,
  }) {
    final events = <MatchLiveEvent>[];

    int homeGoals = 0;
    int awayGoals = 0;

    final homeIsUser = homeClubId == userClubId;
    final awayIsUser = awayClubId == userClubId;

    final style = CoachTacticalCatalog.fromId(userTacticalIdentityId);

    events.add(
      MatchLiveEvent(
        minute: 0,
        type: MatchLiveEventType.intro,
        text: _introLine(
          homeClubName: homeClubName,
          awayClubName: awayClubName,
          result: result,
        ),
        isHomeTeamEvent: true,
        teamName: homeClubName,
        opponentName: awayClubName,
        homeGoals: 0,
        awayGoals: 0,
      ),
    );

    final goalMinutes = _goalMinutes(
      homeGoals: result.homeGoals,
      awayGoals: result.awayGoals,
    );

    final neutralMinutes = _neutralEventMinutes(goalMinutes);

    for (final minute in neutralMinutes) {
      final score = _scoreAtMinute(
        goalMinutes: goalMinutes,
        minute: minute,
      );

      final homeEvent = _teamControllingMoment(
        currentHomeGoals: score.$1,
        currentAwayGoals: score.$2,
        result: result,
      );

      final eventTeamName = homeEvent ? homeClubName : awayClubName;
      final eventOpponentName = homeEvent ? awayClubName : homeClubName;

      final isUserEvent = homeEvent == homeIsUser || (!homeEvent && awayIsUser);

      final eventType = _randomEventType(
        minute: minute,
        style: isUserEvent ? style : CoachTacticalCatalog.fallback,
        coachLevel: isUserEvent ? userCoachLevel : 5,
        medicalLevel: isUserEvent ? userMedicalLevel : 5,
      );

      final teamGoals = homeEvent ? score.$1 : score.$2;
      final opponentGoals = homeEvent ? score.$2 : score.$1;

      events.add(
        MatchLiveEvent(
          minute: minute,
          type: eventType,
          text: _eventLine(
            type: eventType,
            minute: minute,
            teamName: eventTeamName,
            opponentName: eventOpponentName,
            style: isUserEvent ? style : CoachTacticalCatalog.fallback,
            isHome: homeEvent,
            teamGoals: teamGoals,
            opponentGoals: opponentGoals,
          ),
          isHomeTeamEvent: homeEvent,
          teamName: eventTeamName,
          opponentName: eventOpponentName,
          homeGoals: score.$1,
          awayGoals: score.$2,
        ),
      );
    }

    events.addAll(
      _plannedNarrativeEvents(
        goalMinutes: goalMinutes,
        homeClubName: homeClubName,
        awayClubName: awayClubName,
        result: result,
        style: style,
        homeIsUser: homeIsUser,
        awayIsUser: awayIsUser,
        userCoachLevel: userCoachLevel,
        userMedicalLevel: userMedicalLevel,
      ),
    );

    for (final goal in goalMinutes) {
      final isHomeGoal = goal.isHomeGoal;
      final goalTeamName = isHomeGoal ? homeClubName : awayClubName;
      final goalOpponentName = isHomeGoal ? awayClubName : homeClubName;

      if (isHomeGoal) {
        homeGoals++;
      } else {
        awayGoals++;
      }

      final scorer = _pickScorer(
        isUserGoal: (isHomeGoal && homeIsUser) || (!isHomeGoal && awayIsUser),
        userSquad: userSquad,
      );

      final goalStyle =
          (isHomeGoal && homeIsUser) || (!isHomeGoal && awayIsUser)
              ? style
              : CoachTacticalCatalog.fallback;

      events.add(
        MatchLiveEvent(
          minute: goal.minute,
          type: MatchLiveEventType.goal,
          text: _goalLine(
            teamName: goalTeamName,
            scorerName: scorer?.nome,
            style: goalStyle,
          ),
          isHomeTeamEvent: isHomeGoal,
          teamName: goalTeamName,
          opponentName: goalOpponentName,
          playerId: scorer?.id,
          playerName: scorer?.nome,
          playerFaceAsset: scorer?.faceAsset,
          homeGoals: homeGoals,
          awayGoals: awayGoals,
        ),
      );
    }

    final halfTimeScore = _scoreAtMinute(
      goalMinutes: goalMinutes,
      minute: 45,
    );

    events.add(
      MatchLiveEvent(
        minute: 45,
        type: MatchLiveEventType.halfTime,
        text: _halfTimeLine(
          homeClubName: homeClubName,
          awayClubName: awayClubName,
          homeGoals: halfTimeScore.$1,
          awayGoals: halfTimeScore.$2,
        ),
        isHomeTeamEvent: true,
        teamName: homeClubName,
        opponentName: awayClubName,
        homeGoals: halfTimeScore.$1,
        awayGoals: halfTimeScore.$2,
      ),
    );

    final finalWinnerIsHome = result.homeGoals >= result.awayGoals;

    events.add(
      MatchLiveEvent(
        minute: 90,
        type: MatchLiveEventType.finalWhistle,
        text: _finalLine(
          homeClubName: homeClubName,
          awayClubName: awayClubName,
          result: result,
        ),
        isHomeTeamEvent: finalWinnerIsHome,
        teamName: finalWinnerIsHome ? homeClubName : awayClubName,
        opponentName: finalWinnerIsHome ? awayClubName : homeClubName,
        homeGoals: result.homeGoals,
        awayGoals: result.awayGoals,
      ),
    );

    events.sort((a, b) {
      final byMinute = a.minute.compareTo(b.minute);
      if (byMinute != 0) return byMinute;

      int priority(MatchLiveEvent e) {
        switch (e.type) {
          case MatchLiveEventType.intro:
            return 0;
          case MatchLiveEventType.pressure:
          case MatchLiveEventType.tactical:
          case MatchLiveEventType.chance:
          case MatchLiveEventType.bigChance:
          case MatchLiveEventType.save:
          case MatchLiveEventType.counterAttack:
          case MatchLiveEventType.crowd:
            return 5;
          case MatchLiveEventType.substitution:
            return 6;
          case MatchLiveEventType.yellowCard:
          case MatchLiveEventType.medicalAttention:
            return 7;
          case MatchLiveEventType.goal:
            return 10;
          case MatchLiveEventType.halfTime:
            return 50;
          case MatchLiveEventType.finalWhistle:
            return 99;
        }
      }

      return priority(a).compareTo(priority(b));
    });

    return _normalizeScoreAfterSort(
      events: events,
      finalHomeGoals: result.homeGoals,
      finalAwayGoals: result.awayGoals,
    );
  }

  List<MatchLiveEvent> _normalizeScoreAfterSort({
    required List<MatchLiveEvent> events,
    required int finalHomeGoals,
    required int finalAwayGoals,
  }) {
    int home = 0;
    int away = 0;

    final normalized = <MatchLiveEvent>[];

    for (final e in events) {
      if (e.type == MatchLiveEventType.goal) {
        if (e.isHomeTeamEvent) {
          home++;
        } else {
          away++;
        }
      }

      normalized.add(
        e.copyWith(
          homeGoals:
              e.type == MatchLiveEventType.finalWhistle ? finalHomeGoals : home,
          awayGoals:
              e.type == MatchLiveEventType.finalWhistle ? finalAwayGoals : away,
        ),
      );
    }

    return normalized;
  }

  List<MatchLiveEvent> _plannedNarrativeEvents({
    required List<_GoalMinute> goalMinutes,
    required String homeClubName,
    required String awayClubName,
    required MatchResult result,
    required CoachTacticalIdentity style,
    required bool homeIsUser,
    required bool awayIsUser,
    required int userCoachLevel,
    required int userMedicalLevel,
  }) {
    final events = <MatchLiveEvent>[];
    final usedMinutes = goalMinutes.map((g) => g.minute).toSet();

    int pickFreeMinute(int min, int max) {
      var minute = min + _random.nextInt(max - min + 1);
      var guard = 0;

      while (usedMinutes.contains(minute) && guard < 50) {
        guard++;
        minute = min + _random.nextInt(max - min + 1);
      }

      usedMinutes.add(minute);
      return minute;
    }

    void addEvent({
      required int minute,
      required MatchLiveEventType type,
      required bool isHome,
      required String teamName,
      required String opponentName,
      required String text,
    }) {
      final score = _scoreAtMinute(
        goalMinutes: goalMinutes,
        minute: minute,
      );

      events.add(
        MatchLiveEvent(
          minute: minute,
          type: type,
          text: text,
          isHomeTeamEvent: isHome,
          teamName: teamName,
          opponentName: opponentName,
          homeGoals: score.$1,
          awayGoals: score.$2,
        ),
      );
    }

    final homeSubMinute = pickFreeMinute(61, 78);
    final awaySubMinute = pickFreeMinute(64, 82);

    addEvent(
      minute: homeSubMinute,
      type: MatchLiveEventType.substitution,
      isHome: true,
      teamName: homeClubName,
      opponentName: awayClubName,
      text: _substitutionLine(homeClubName),
    );

    addEvent(
      minute: awaySubMinute,
      type: MatchLiveEventType.substitution,
      isHome: false,
      teamName: awayClubName,
      opponentName: homeClubName,
      text: _substitutionLine(awayClubName),
    );

    final cardChance = _yellowCardChance(
      style: style,
      coachLevel: userCoachLevel,
    );

    if (_random.nextDouble() < cardChance) {
      final userIsHome = homeIsUser;
      final minute = pickFreeMinute(18, 84);
      final teamName = userIsHome ? homeClubName : awayClubName;
      final opponentName = userIsHome ? awayClubName : homeClubName;

      addEvent(
        minute: minute,
        type: MatchLiveEventType.yellowCard,
        isHome: userIsHome,
        teamName: teamName,
        opponentName: opponentName,
        text: _yellowCardLine(teamName, style),
      );
    }

    if (_random.nextDouble() < 0.28) {
      final opponentIsHome = !homeIsUser;
      final minute = pickFreeMinute(22, 86);
      final teamName = opponentIsHome ? homeClubName : awayClubName;
      final opponentName = opponentIsHome ? awayClubName : homeClubName;

      addEvent(
        minute: minute,
        type: MatchLiveEventType.yellowCard,
        isHome: opponentIsHome,
        teamName: teamName,
        opponentName: opponentName,
        text: _yellowCardLine(teamName, CoachTacticalCatalog.fallback),
      );
    }

    final medicalChance = _medicalAttentionChance(
      medicalLevel: userMedicalLevel,
    );

    if (_random.nextDouble() < medicalChance) {
      final userIsHome = homeIsUser;
      final minute = pickFreeMinute(30, 88);
      final teamName = userIsHome ? homeClubName : awayClubName;
      final opponentName = userIsHome ? awayClubName : homeClubName;

      addEvent(
        minute: minute,
        type: MatchLiveEventType.medicalAttention,
        isHome: userIsHome,
        teamName: teamName,
        opponentName: opponentName,
        text: _medicalAttentionLine(teamName),
      );
    }

    return events;
  }

  double _yellowCardChance({
    required CoachTacticalIdentity style,
    required int coachLevel,
  }) {
    double base = 0.20;

    switch (style.id) {
      case 'gegenpress':
        base += 0.14;
        break;
      case 'set_piece':
        base += 0.08;
        break;
      case 'support_play':
        base += 0.04;
        break;
      case 'tactical_periodization':
        base += 0.02;
        break;
      case 'tiki_taka':
        base -= 0.05;
        break;
    }

    final coach = coachLevel.clamp(1, 10);

    if (coach <= 3) base += 0.08;
    if (coach >= 8) base -= 0.06;

    return base.clamp(0.08, 0.50);
  }

  double _medicalAttentionChance({
    required int medicalLevel,
  }) {
    final level = medicalLevel.clamp(1, 10);

    if (level <= 2) return 0.38;
    if (level <= 4) return 0.30;
    if (level <= 6) return 0.22;
    if (level <= 8) return 0.16;
    return 0.10;
  }

  String _introLine({
    required String homeClubName,
    required String awayClubName,
    required MatchResult result,
  }) {
    switch (result.balance) {
      case MatchBalance.veryBalanced:
      case MatchBalance.balanced:
        return 'BOLA ROLANDO — $homeClubName e $awayClubName começam em clima de equilíbrio.';
      case MatchBalance.slightFavorite:
        return 'BOLA ROLANDO — A partida começa com leve favoritismo, mas o cenário segue aberto.';
      case MatchBalance.clearFavorite:
        return 'BOLA ROLANDO — Um lado chega mais forte e precisa confirmar isso em campo.';
      case MatchBalance.dominantFavorite:
        return 'BOLA ROLANDO — O favoritismo é claro, e a pressão por domínio aparece desde o início.';
    }
  }

  String _halfTimeLine({
    required String homeClubName,
    required String awayClubName,
    required int homeGoals,
    required int awayGoals,
  }) {
    if (homeGoals == awayGoals) {
      return 'INTERVALO — Tudo igual até aqui. O jogo segue aberto para os dois lados.';
    }

    final leader = homeGoals > awayGoals ? homeClubName : awayClubName;

    return 'INTERVALO — O $leader vai para o vestiário em vantagem, mas a partida ainda pede concentração.';
  }

  String _finalLine({
    required String homeClubName,
    required String awayClubName,
    required MatchResult result,
  }) {
    if (result.homeGoals == result.awayGoals) {
      return 'FIM DE JOGO — $homeClubName e $awayClubName empatam em ${result.homeGoals}x${result.awayGoals}.';
    }

    final winner =
        result.homeGoals > result.awayGoals ? homeClubName : awayClubName;

    final winnerGoals = result.homeGoals > result.awayGoals
        ? result.homeGoals
        : result.awayGoals;

    final loserGoals = result.homeGoals > result.awayGoals
        ? result.awayGoals
        : result.homeGoals;

    return 'FIM DE JOGO — O $winner vence por ${winnerGoals}x$loserGoals.';
  }

  String _eventLine({
    required MatchLiveEventType type,
    required int minute,
    required String teamName,
    required String opponentName,
    required CoachTacticalIdentity style,
    required bool isHome,
    required int teamGoals,
    required int opponentGoals,
  }) {
    switch (type) {
      case MatchLiveEventType.pressure:
        return _contextualPressure(
          teamName: teamName,
          teamGoals: teamGoals,
          opponentGoals: opponentGoals,
          minute: minute,
        );
      case MatchLiveEventType.tactical:
        return _contextualTacticalLine(
          teamName: teamName,
          opponentName: opponentName,
          teamGoals: teamGoals,
          opponentGoals: opponentGoals,
          style: style,
          minute: minute,
        );
      case MatchLiveEventType.chance:
        return _chanceLine(teamName, style);
      case MatchLiveEventType.bigChance:
        return _contextualBigChanceLine(
          teamName: teamName,
          teamGoals: teamGoals,
          opponentGoals: opponentGoals,
          minute: minute,
        );
      case MatchLiveEventType.save:
        return _saveLine(teamName);
      case MatchLiveEventType.counterAttack:
        return _counterAttackLine(teamName, opponentName, style);
      case MatchLiveEventType.substitution:
        return _substitutionLine(teamName);
      case MatchLiveEventType.yellowCard:
        return _yellowCardLine(teamName, style);
      case MatchLiveEventType.medicalAttention:
        return _medicalAttentionLine(teamName);
      case MatchLiveEventType.crowd:
        return isHome
            ? 'TORCIDA — A arquibancada empurra o $teamName e aumenta o clima da partida.'
            : 'AMBIENTE — O $teamName tenta esfriar o jogo longe de casa.';
      case MatchLiveEventType.intro:
      case MatchLiveEventType.goal:
      case MatchLiveEventType.halfTime:
      case MatchLiveEventType.finalWhistle:
        return _contextualPressure(
          teamName: teamName,
          teamGoals: teamGoals,
          opponentGoals: opponentGoals,
          minute: minute,
        );
    }
  }

  String _contextualPressure({
    required String teamName,
    required int teamGoals,
    required int opponentGoals,
    required int minute,
  }) {
    final diff = teamGoals - opponentGoals;
    final late = minute >= 70;

    if (diff >= 2) {
      return late
          ? 'PRESSÃO — O $teamName controla a vantagem e tenta esfriar o jogo nos minutos finais.'
          : 'PRESSÃO — O $teamName administra a vantagem e controla o ritmo.';
    }

    if (diff == 1) {
      return late
          ? 'PRESSÃO — O $teamName tenta segurar a vantagem sem abrir mão de buscar o golpe final.'
          : 'PRESSÃO — O $teamName tenta ampliar a vantagem.';
    }

    if (diff == 0) {
      return late
          ? 'PRESSÃO — O $teamName aumenta o volume em busca do gol que pode decidir a partida.'
          : 'PRESSÃO — O $teamName aperta em busca de abrir o placar.';
    }

    if (diff == -1) {
      return late
          ? 'PRESSÃO — O $teamName empilha jogadores no ataque e tenta arrancar o empate.'
          : 'PRESSÃO — O $teamName se lança ao ataque tentando empatar.';
    }

    return late
        ? 'PRESSÃO — O $teamName parte para o tudo ou nada, mesmo deixando espaços atrás.'
        : 'PRESSÃO — O $teamName busca reação e tenta mudar o rumo da partida.';
  }

  String _contextualTacticalLine({
    required String teamName,
    required String opponentName,
    required int teamGoals,
    required int opponentGoals,
    required CoachTacticalIdentity style,
    required int minute,
  }) {
    final diff = teamGoals - opponentGoals;
    final late = minute >= 70;

    if (diff >= 2) {
      return late
          ? 'TÁTICA — O $teamName fecha espaços, baixa o ritmo e obriga o $opponentName a se expor.'
          : 'TÁTICA — O $teamName protege a vantagem e controla melhor os riscos.';
    }

    if (diff == 1) {
      return late
          ? 'TÁTICA — O $teamName tenta controlar os últimos minutos sem perder a agressividade.'
          : 'TÁTICA — O $teamName controla a posse sem abrir mão de atacar.';
    }

    if (diff == -1) {
      return late
          ? 'TÁTICA — O $teamName adianta as linhas e aceita correr riscos para buscar o empate.'
          : 'TÁTICA — O $teamName empurra o $opponentName para trás e tenta mudar o jogo.';
    }

    if (diff <= -2) {
      return late
          ? 'TÁTICA — O $teamName se desorganiza na urgência, tentando criar algo no fim.'
          : 'TÁTICA — O $teamName perde um pouco a estrutura tentando reagir.';
    }

    return _tacticalLine(teamName, opponentName, style);
  }

  String _chanceLine(String teamName, CoachTacticalIdentity style) {
    switch (style.id) {
      case 'tiki_taka':
        return 'CHANCE — O $teamName troca passes perto da área, gira a defesa e finaliza após boa construção.';
      case 'gegenpress':
        return 'CHANCE — O $teamName recupera alto e finaliza antes da defesa conseguir respirar.';
      case 'set_piece':
        return 'CHANCE — O $teamName leva perigo em bola parada bem trabalhada na área.';
      case 'support_play':
        return 'CHANCE — O $teamName aproxima setores, combina pelo lado e chega em condição de finalizar.';
      case 'tactical_periodization':
        return 'CHANCE — O $teamName escolhe bem o momento de acelerar e encontra espaço para finalizar.';
      default:
        return 'CHANCE — O $teamName encontra espaço e leva perigo ao adversário.';
    }
  }

  String _contextualBigChanceLine({
    required String teamName,
    required int teamGoals,
    required int opponentGoals,
    required int minute,
  }) {
    final diff = teamGoals - opponentGoals;
    final late = minute >= 70;

    if (diff < 0) {
      final lines = <String>[
        late
            ? 'GRANDE CHANCE — O $teamName quase arranca uma reação dramática nos minutos finais.'
            : 'GRANDE CHANCE — O $teamName quase consegue a reação em chegada clara.',
        'GRANDE CHANCE — O $teamName se lança ao ataque e desperdiça oportunidade enorme.',
        'GRANDE CHANCE — A pressão do $teamName quase muda o rumo da partida.',
      ];

      return lines[_random.nextInt(lines.length)];
    }

    if (diff > 0) {
      final lines = <String>[
        late
            ? 'GRANDE CHANCE — O $teamName quase mata o jogo em lance claríssimo.'
            : 'GRANDE CHANCE — O $teamName quase amplia e encaminha ainda mais o resultado.',
        'GRANDE CHANCE — O $teamName chega limpo para matar o jogo, mas desperdiça.',
        'GRANDE CHANCE — O $teamName encontra espaço e quase aumenta a vantagem.',
      ];

      return lines[_random.nextInt(lines.length)];
    }

    return _bigChanceLine(teamName);
  }

  String _tacticalLine(
    String teamName,
    String opponentName,
    CoachTacticalIdentity style,
  ) {
    switch (style.id) {
      case 'tiki_taka':
        return 'TÁTICA — O $teamName tenta cansar o $opponentName com posse longa, passes curtos e paciência.';
      case 'gegenpress':
        return 'TÁTICA — O $teamName encurta o campo e impede o $opponentName de respirar na saída.';
      case 'set_piece':
        return 'TÁTICA — O $teamName baixa o ritmo, disputa cada metro e tenta decidir nos detalhes.';
      case 'support_play':
        return 'TÁTICA — O $teamName aproxima laterais, meias e atacantes para criar linhas de passe.';
      case 'tactical_periodization':
        return 'TÁTICA — O $teamName alterna pressão e pausa, tentando controlar os momentos da partida.';
      default:
        return 'TÁTICA — O $teamName tenta interpretar melhor os espaços da partida.';
    }
  }

  String _bigChanceLine(String teamName) {
    final lines = <String>[
      'GRANDE CHANCE — O $teamName chega limpo na área, mas desperdiça uma oportunidade enorme.',
      'GRANDE CHANCE — O $teamName quase marca em finalização de dentro da área.',
      'GRANDE CHANCE — A defesa se salva no limite após chegada forte do $teamName.',
      'GRANDE CHANCE — O $teamName encontra um corredor livre, mas não consegue transformar em gol.',
    ];

    return lines[_random.nextInt(lines.length)];
  }

  String _saveLine(String teamName) {
    final lines = <String>[
      'DEFESA — O goleiro aparece bem após finalização perigosa do $teamName.',
      'DEFESA — O goleiro salva em lance difícil e evita o gol do $teamName.',
      'DEFESA — A finalização sai forte, mas o goleiro espalma e mantém o placar.',
      'DEFESA — O $teamName bate colocado, mas o goleiro voa para fazer grande defesa.',
    ];

    return lines[_random.nextInt(lines.length)];
  }

  String _counterAttackLine(
    String teamName,
    String opponentName,
    CoachTacticalIdentity style,
  ) {
    if (style.id == 'gegenpress') {
      final lines = <String>[
        'CONTRA-ATAQUE — O $teamName rouba a bola e acelera, mas o $opponentName corta no limite.',
        'CONTRA-ATAQUE — O $teamName transforma pressão em transição, mas erra o passe final.',
      ];

      return lines[_random.nextInt(lines.length)];
    }

    final lines = <String>[
      'CONTRA-ATAQUE — O $teamName tenta acelerar em transição, mas o $opponentName consegue recompor.',
      'CONTRA-ATAQUE — O $teamName sai em velocidade, mas erra o último passe.',
      'CONTRA-ATAQUE — O $teamName encontra espaço, porém a defesa corta antes da finalização.',
    ];

    return lines[_random.nextInt(lines.length)];
  }

  String _substitutionLine(String teamName) {
    final lines = <String>[
      'SUBSTITUIÇÃO — O $teamName mexe no time para renovar o fôlego.',
      'SUBSTITUIÇÃO — O treinador do $teamName chama uma mudança para ajustar a equipe.',
      'SUBSTITUIÇÃO — O $teamName vai ao banco e tenta mudar o ritmo da partida.',
      'SUBSTITUIÇÃO — Mudança no $teamName para dar energia nova ao jogo.',
    ];

    return lines[_random.nextInt(lines.length)];
  }

  String _yellowCardLine(String teamName, CoachTacticalIdentity style) {
    if (style.id == 'gegenpress') {
      final lines = <String>[
        'CARTÃO — A pressão do $teamName passa do ponto, e o árbitro mostra amarelo.',
        'CARTÃO — O $teamName tenta morder alto, chega atrasado e recebe amarelo.',
        'CARTÃO — Na tentativa de recuperar rápido, o $teamName comete falta dura.',
      ];

      return lines[_random.nextInt(lines.length)];
    }

    if (style.id == 'set_piece') {
      final lines = <String>[
        'CARTÃO — O $teamName disputa forte pelo alto e acaba punido.',
        'CARTÃO — O $teamName para o contra-ataque rival com falta tática.',
        'CARTÃO — Entrada mais dura do $teamName em disputa física.',
      ];

      return lines[_random.nextInt(lines.length)];
    }

    final lines = <String>[
      'CARTÃO — O $teamName comete falta tática e recebe amarelo.',
      'CARTÃO — Entrada mais forte do $teamName, e o árbitro pune com amarelo.',
      'CARTÃO — O $teamName para o avanço rival e leva cartão amarelo.',
    ];

    return lines[_random.nextInt(lines.length)];
  }

  String _medicalAttentionLine(String teamName) {
    final lines = <String>[
      'ATENDIMENTO — Jogador do $teamName sente uma pancada, mas parece em condição de seguir.',
      'ATENDIMENTO — O departamento médico entra rapidamente para avaliar um atleta do $teamName.',
      'ATENDIMENTO — Sinal de desgaste no $teamName, mas nada indica substituição obrigatória.',
      'ATENDIMENTO — Preocupação rápida no gramado, e o $teamName ganha alguns segundos para reorganizar.',
    ];

    return lines[_random.nextInt(lines.length)];
  }

  String _goalLine({
    required String teamName,
    required String? scorerName,
    required CoachTacticalIdentity style,
  }) {
    final scorer = scorerName == null || scorerName.trim().isEmpty
        ? 'O atacante'
        : scorerName;

    final lines = switch (style.id) {
      'tiki_taka' => <String>[
          'GOL DO $teamName! $scorer aparece após troca de passes e manda para o fundo da rede.',
          'GOL DO $teamName! A jogada nasce em posse trabalhada e $scorer completa com precisão.',
          'GOL DO $teamName! O time envolve a defesa, encontra o espaço e $scorer conclui.',
        ],
      'gegenpress' => <String>[
          'GOL DO $teamName! $scorer aproveita recuperação alta e finaliza com força.',
          'GOL DO $teamName! A pressão rouba a bola no campo ofensivo e $scorer não perdoa.',
          'GOL DO $teamName! O rival erra na saída, e $scorer transforma pressão em vantagem.',
        ],
      'set_piece' => <String>[
          'GOL DO $teamName! $scorer decide após jogada de bola parada.',
          'GOL DO $teamName! A bola parada pesa, e $scorer aparece para concluir.',
          'GOL DO $teamName! No detalhe da bola levantada, $scorer manda para dentro.',
        ],
      'support_play' => <String>[
          'GOL DO $teamName! $scorer completa após boa jogada coletiva pelo lado.',
          'GOL DO $teamName! A aproximação funciona, e $scorer aparece para finalizar.',
          'GOL DO $teamName! O ataque conecta bem os setores e $scorer conclui a jogada.',
        ],
      'tactical_periodization' => <String>[
          'GOL DO $teamName! $scorer aparece no momento certo e conclui a jogada.',
          'GOL DO $teamName! O time acelera na hora certa e $scorer finaliza com categoria.',
          'GOL DO $teamName! A jogada amadurece bem, e $scorer transforma o lance em gol.',
        ],
      _ => <String>[
          'GOL DO $teamName! $scorer aparece bem para concluir a jogada.',
        ],
    };

    return lines[_random.nextInt(lines.length)];
  }

  List<_GoalMinute> _goalMinutes({
    required int homeGoals,
    required int awayGoals,
  }) {
    final goals = <_GoalMinute>[];

    for (int i = 0; i < homeGoals; i++) {
      goals.add(
        _GoalMinute(
          minute: _weightedGoalMinute(),
          isHomeGoal: true,
        ),
      );
    }

    for (int i = 0; i < awayGoals; i++) {
      goals.add(
        _GoalMinute(
          minute: _weightedGoalMinute(),
          isHomeGoal: false,
        ),
      );
    }

    goals.sort((a, b) => a.minute.compareTo(b.minute));
    return goals;
  }

  int _weightedGoalMinute() {
    final roll = _random.nextInt(100);

    if (roll < 15) return 5 + _random.nextInt(16);
    if (roll < 40) return 21 + _random.nextInt(25);
    if (roll < 70) return 46 + _random.nextInt(25);

    return 71 + _random.nextInt(18);
  }

  List<int> _neutralEventMinutes(List<_GoalMinute> goalMinutes) {
    final used = goalMinutes.map((g) => g.minute).toSet();
    final minutes = <int>[];
    final totalGoals = goalMinutes.length;
    final targetCount =
        totalGoals >= 5 ? 8 + _random.nextInt(4) : 6 + _random.nextInt(4);

    int guard = 0;

    while (minutes.length < targetCount && guard < 300) {
      guard++;

      final minute = 3 + _random.nextInt(85);

      if (used.contains(minute)) continue;
      if (minutes.contains(minute)) continue;

      final tooClose = minutes.any((m) => (m - minute).abs() <= 2);
      if (tooClose) continue;

      minutes.add(minute);
    }

    minutes.sort();

    return minutes;
  }

  bool _teamControllingMoment({
    required int currentHomeGoals,
    required int currentAwayGoals,
    required MatchResult result,
  }) {
    if (currentHomeGoals > currentAwayGoals) {
      return _random.nextDouble() < 0.70;
    }

    if (currentAwayGoals > currentHomeGoals) {
      return _random.nextDouble() < 0.30;
    }

    final homeChance = result.homeWinProbability.clamp(0.25, 0.75);

    return _random.nextDouble() < homeChance;
  }

  MatchLiveEventType _randomEventType({
    required int minute,
    required CoachTacticalIdentity style,
    required int coachLevel,
    required int medicalLevel,
  }) {
    final late = minute >= 70;

    final pool = <MatchLiveEventType>[
      MatchLiveEventType.pressure,
      MatchLiveEventType.tactical,
      MatchLiveEventType.chance,
      MatchLiveEventType.counterAttack,
      MatchLiveEventType.crowd,
      MatchLiveEventType.save,
      MatchLiveEventType.bigChance,
    ];

    if (late) {
      pool.add(MatchLiveEventType.bigChance);
    }

    final cardChance = _yellowCardChance(
      style: style,
      coachLevel: coachLevel,
    );

    if (_random.nextDouble() < cardChance) {
      pool.add(MatchLiveEventType.yellowCard);
    }

    final medicalChance = _medicalAttentionChance(
      medicalLevel: medicalLevel,
    );

    if (_random.nextDouble() < medicalChance * 0.45) {
      pool.add(MatchLiveEventType.medicalAttention);
    }

    return pool[_random.nextInt(pool.length)];
  }

  Player? _pickScorer({
    required bool isUserGoal,
    required List<Player> userSquad,
  }) {
    if (!isUserGoal || userSquad.isEmpty) return null;

    final attackers = userSquad.where((p) {
      final pos = p.posDet.name.toUpperCase();

      return pos.contains('CA') ||
          pos.contains('PE') ||
          pos.contains('PD') ||
          pos.contains('MEI') ||
          pos.contains('ATA');
    }).toList();

    final mids = userSquad.where((p) {
      final pos = p.posDet.name.toUpperCase();

      return pos.contains('MC') ||
          pos.contains('VOL') ||
          pos.contains('ME') ||
          pos.contains('MD');
    }).toList();

    final pool = <Player>[
      ...attackers,
      ...attackers,
      ...attackers,
      ...mids,
      ...userSquad,
    ];

    if (pool.isEmpty) return null;

    return pool[_random.nextInt(pool.length)];
  }

  (int, int) _scoreAtMinute({
    required List<_GoalMinute> goalMinutes,
    required int minute,
  }) {
    int home = 0;
    int away = 0;

    for (final goal in goalMinutes) {
      if (goal.minute > minute) continue;

      if (goal.isHomeGoal) {
        home++;
      } else {
        away++;
      }
    }

    return (home, away);
  }
}

class _GoalMinute {
  final int minute;
  final bool isHomeGoal;

  const _GoalMinute({
    required this.minute,
    required this.isHomeGoal,
  });
}
