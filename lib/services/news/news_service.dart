import 'package:footory26/services/world/game_state.dart';

class NewsService {
  const NewsService._();

  // ================================
  // MAIN
  // ================================
  static List<String> generateAfterRound(GameState gs) {
    final news = <String>[];

    final matchLine = gs.lastUserMatch;
    if (matchLine == null || matchLine.trim().isEmpty) {
      return news;
    }

    // 1) Sempre gera uma headline principal da partida.
    news.add(_matchText(gs, matchLine));

    // 2) Gera NO MÁXIMO uma análise complementar.
    final secondary = _pickSecondaryLine(gs);
    if (secondary != null && secondary.trim().isNotEmpty) {
      news.add(secondary);
    }

    return news;
  }

  // ================================
  // MATCH
  // ================================
  static String _matchText(GameState gs, String matchLine) {
    final parsed = _parseUserMatch(gs, matchLine);
    if (parsed == null) {
      return '$matchLine. Resultado importante para a caminhada do ${gs.userClubName} na temporada.';
    }

    final pos = _userPosition(gs);
    final isHome = parsed.isUserHome;
    final goalDiff = (parsed.userGoals - parsed.oppGoals).abs();
    final inTopZone = pos != null && pos <= 4;
    final inDangerZone = pos != null && pos >= _relegationStart(gs);
    final nearTop = pos != null && pos <= 8;
    final lowerZone = pos != null && pos >= (gs.table.getSorted().length - 6);

    final seed = matchLine.hashCode ^
        gs.userWinStreak ^
        (gs.userLoseStreak << 2) ^
        (gs.userDrawStreak << 4) ^
        (gs.roundIndex << 1);

    // ============================
    // VITÓRIA
    // ============================
    if (parsed.userGoals > parsed.oppGoals) {
      if (gs.userWinStreak >= 5) {
        return _pickBySeed(
          [
            '$matchLine. O ${gs.userClubName} segue imparável e confirma o melhor momento da temporada.',
            '$matchLine. A fase é excelente: o ${gs.userClubName} continua vencendo e joga com moral em alta.',
            '$matchLine. O ${gs.userClubName} mantém a sequência perfeita do momento e reforça sua força na competição.',
          ],
          seed,
        );
      }

      if (gs.userWinStreak >= 3) {
        return _pickBySeed(
          [
            '$matchLine. Mais uma vitória para o ${gs.userClubName}, que mantém o embalo e cresce na competição.',
            '$matchLine. O ${gs.userClubName} confirma a boa fase e segue acumulando vitórias importantes.',
            '$matchLine. O momento é positivo: o ${gs.userClubName} vence outra vez e sustenta sua arrancada.',
          ],
          seed,
        );
      }

      if (goalDiff >= 3) {
        return _pickBySeed(
          [
            '$matchLine. Vitória convincente do ${gs.userClubName}, que manda um recado forte para o campeonato.',
            '$matchLine. O ${gs.userClubName} venceu com autoridade e deixou uma impressão muito forte na rodada.',
            '$matchLine. Atuação dominante do ${gs.userClubName}, que construiu um placar largo com méritos.',
          ],
          seed,
        );
      }

      if (goalDiff == 2 && inTopZone) {
        return _pickBySeed(
          [
            '$matchLine. Resultado firme para o ${gs.userClubName}, que sustenta sua presença na parte alta.',
            '$matchLine. O ${gs.userClubName} venceu com segurança e continua forte na briga de cima.',
            '$matchLine. Vitória sólida do ${gs.userClubName}, importante para manter o peso da campanha na parte alta.',
          ],
          seed,
        );
      }

      if (goalDiff == 1 && inDangerZone) {
        return _pickBySeed(
          [
            '$matchLine. Vitória suada e valiosa para o ${gs.userClubName}, que ganha fôlego em meio à pressão.',
            '$matchLine. O ${gs.userClubName} sofreu, mas conseguiu um resultado que pode aliviar o ambiente.',
            '$matchLine. Três pontos pesados para o ${gs.userClubName}, que respira melhor depois de uma vitória apertada.',
          ],
          seed,
        );
      }

      if (!isHome && nearTop) {
        return _pickBySeed(
          [
            '$matchLine. O ${gs.userClubName} busca pontos importantes fora de casa e segue forte na campanha.',
            '$matchLine. Vitória fora de casa que reforça a competitividade do ${gs.userClubName} na parte alta.',
            '$matchLine. O ${gs.userClubName} mostrou força longe de seus domínios e somou um resultado grande na rodada.',
          ],
          seed,
        );
      }

      if (isHome) {
        return _pickBySeed(
          [
            '$matchLine. O ${gs.userClubName} fez o dever de casa e soma um resultado importante na temporada.',
            '$matchLine. Diante da torcida, o ${gs.userClubName} confirmou sua obrigação e saiu com três pontos valiosos.',
            '$matchLine. O ${gs.userClubName} aproveitou o mando e construiu uma vitória importante para sua campanha.',
          ],
          seed,
        );
      }

      return _pickBySeed(
        [
          '$matchLine. Vitória importante do ${gs.userClubName} para seguir avançando na competição.',
          '$matchLine. O ${gs.userClubName} soma três pontos que ajudam a manter a temporada em movimento.',
          '$matchLine. Resultado positivo para o ${gs.userClubName}, que segue empurrando sua campanha para frente.',
        ],
        seed,
      );
    }

    // ============================
    // EMPATE
    // ============================
    if (parsed.userGoals == parsed.oppGoals) {
      if (gs.userDrawStreak >= 4) {
        return _pickBySeed(
          [
            '$matchLine. O ${gs.userClubName} soma mais um empate e vê a campanha seguir travada.',
            '$matchLine. A sequência de empates continua e o ${gs.userClubName} segue com pouca evolução real.',
            '$matchLine. Outro empate para o ${gs.userClubName}, que continua preso num momento morno da temporada.',
          ],
          seed,
        );
      }

      if (gs.userDrawStreak >= 3) {
        return _pickBySeed(
          [
            '$matchLine. O ${gs.userClubName} volta a pontuar, mas a sensação é de oportunidade desperdiçada.',
            '$matchLine. O ponto entra na conta, mas o ${gs.userClubName} sai com gosto de chance perdida.',
            '$matchLine. O ${gs.userClubName} evita a derrota, mas o empate não elimina a sensação de frustração.',
          ],
          seed,
        );
      }

      if (isHome && nearTop) {
        return _pickBySeed(
          [
            '$matchLine. O empate em casa deixa gosto amargo para o ${gs.userClubName}, que poderia se firmar melhor na parte alta.',
            '$matchLine. O ${gs.userClubName} deixa escapar uma chance valiosa de ganhar força na briga de cima.',
            '$matchLine. Dentro de casa, o ${gs.userClubName} tropeça num momento em que uma vitória pesaria muito na campanha.',
          ],
          seed,
        );
      }

      if (isHome && !inDangerZone) {
        return _pickBySeed(
          [
            '$matchLine. O ${gs.userClubName} deixa pontos pelo caminho dentro de casa e sai com sensação de frustração.',
            '$matchLine. O empate em casa freia um pouco o ritmo do ${gs.userClubName} na temporada.',
            '$matchLine. Diante da torcida, o ${gs.userClubName} pontua, mas o resultado fica abaixo do que parecia possível.',
          ],
          seed,
        );
      }

      if (!isHome && inDangerZone) {
        return _pickBySeed(
          [
            '$matchLine. Mesmo sem vencer, o ${gs.userClubName} arranca um ponto fora de casa e tenta seguir vivo na luta.',
            '$matchLine. O ${gs.userClubName} soma um ponto que pode ter utilidade na parte mais pesada da tabela.',
            '$matchLine. Fora de casa, o ${gs.userClubName} ao menos evita a derrota e mantém algum oxigênio na temporada.',
          ],
          seed,
        );
      }

      if (!isHome) {
        return _pickBySeed(
          [
            '$matchLine. O ${gs.userClubName} soma um ponto fora de casa e mantém a campanha em movimento.',
            '$matchLine. Empate fora de casa para o ${gs.userClubName}, que continua andando, ainda que sem grande salto.',
            '$matchLine. O ${gs.userClubName} pontua longe de seus domínios e evita uma rodada completamente vazia.',
          ],
          seed,
        );
      }

      return _pickBySeed(
        [
          '$matchLine. O ${gs.userClubName} pontua, mas fica a sensação de que dava para mais.',
          '$matchLine. O empate mantém o ${gs.userClubName} vivo, mas sem a força de uma vitória.',
          '$matchLine. O ${gs.userClubName} sai com um ponto, embora o resultado não empolgue.',
        ],
        seed,
      );
    }

    // ============================
    // DERROTA
    // ============================
    if (gs.userLoseStreak >= 5) {
      return _pickBySeed(
        [
          '$matchLine. A crise se aprofunda e o ${gs.userClubName} entra em uma fase cada vez mais pesada.',
          '$matchLine. O momento já é abertamente ruim, e o ${gs.userClubName} segue sem encontrar reação.',
          '$matchLine. O ${gs.userClubName} afunda ainda mais numa sequência negativa que pesa sobre a temporada.',
        ],
        seed,
      );
    }

    if (gs.userLoseStreak >= 3) {
      return _pickBySeed(
        [
          '$matchLine. A pressão aumenta sobre o ${gs.userClubName}, que segue sem conseguir reagir.',
          '$matchLine. O ${gs.userClubName} continua acumulando derrotas e vê o ambiente ficar mais pesado.',
          '$matchLine. Novo tropeço do ${gs.userClubName}, que agora entra numa sequência realmente preocupante.',
        ],
        seed,
      );
    }

    if (goalDiff >= 3) {
      return _pickBySeed(
        [
          '$matchLine. Derrota dura para o ${gs.userClubName}, que termina a rodada com sensação pesada.',
          '$matchLine. O ${gs.userClubName} foi superado com clareza e deixa a rodada bastante machucado.',
          '$matchLine. Placar pesado contra o ${gs.userClubName}, que sai da rodada com sinais claros de alerta.',
        ],
        seed,
      );
    }

    if (isHome && nearTop) {
      return _pickBySeed(
        [
          '$matchLine. Tropeço em casa para o ${gs.userClubName}, que perde a chance de se consolidar ainda mais na parte alta.',
          '$matchLine. O ${gs.userClubName} deixa escapar uma oportunidade importante de fortalecer sua campanha no topo.',
          '$matchLine. Derrota em casa justamente quando o ${gs.userClubName} poderia ganhar ainda mais corpo na parte alta.',
        ],
        seed,
      );
    }

    if (isHome && !inDangerZone) {
      return _pickBySeed(
        [
          '$matchLine. Derrota em casa que machuca o ${gs.userClubName} e interrompe um passo importante na campanha.',
          '$matchLine. O ${gs.userClubName} tropeça diante da torcida e deixa uma sensação amarga na rodada.',
          '$matchLine. Revés em casa para o ${gs.userClubName}, que perde um resultado que parecia muito importante para a sequência.',
        ],
        seed,
      );
    }

    if (!isHome && inTopZone) {
      return _pickBySeed(
        [
          '$matchLine. O ${gs.userClubName} tropeça fora de casa, mas segue vivo na briga na parte de cima.',
          '$matchLine. Derrota fora de casa para o ${gs.userClubName}, que ainda mantém peso na luta pelos primeiros lugares.',
          '$matchLine. O ${gs.userClubName} deixa pontos pelo caminho, mas continua inserido na disputa da parte alta.',
        ],
        seed,
      );
    }

    if (!isHome && lowerZone) {
      return _pickBySeed(
        [
          '$matchLine. O ${gs.userClubName} sai derrotado e vê a pressão aumentar na parte de baixo da tabela.',
          '$matchLine. Derrota fora de casa que complica a vida do ${gs.userClubName} num trecho já desconfortável da tabela.',
          '$matchLine. O ${gs.userClubName} volta sem pontos e sente o peso da parte baixa da classificação.',
        ],
        seed,
      );
    }

    return _pickBySeed(
      [
        '$matchLine. Derrota do ${gs.userClubName}, que terá de reagir nas próximas rodadas.',
        '$matchLine. O ${gs.userClubName} sai derrotado e agora precisa responder rapidamente na sequência.',
        '$matchLine. Revés para o ${gs.userClubName}, que perde terreno e terá de buscar reação imediata.',
      ],
      seed,
    );
  }

  // ================================
  // SECONDARY PICKER
  // ================================
  static String? _pickSecondaryLine(GameState gs) {
    final tableLine = _tableSituation(gs);
    final streakLine = _streakText(gs);

    final candidates = <String>[];

    if (streakLine != null && streakLine.trim().isNotEmpty) {
      candidates.add(streakLine);
    }

    final shouldUseTable =
        gs.roundIndex <= 4 || gs.roundIndex % 2 == 0 || candidates.isEmpty;

    if (shouldUseTable && tableLine != null && tableLine.trim().isNotEmpty) {
      candidates.add(tableLine);
    }

    if (candidates.isEmpty) return null;

    final seed = gs.userClubName.hashCode ^
        gs.roundIndex ^
        (gs.userWinStreak << 3) ^
        (gs.userLoseStreak << 5) ^
        (gs.userDrawStreak << 7);

    return _pickBySeed(candidates, seed);
  }

  // ================================
  // STREAK
  // ================================
  static String? _streakText(GameState gs) {
    final seed = gs.userClubName.hashCode ^
        gs.userWinStreak ^
        (gs.userLoseStreak << 3) ^
        (gs.userDrawStreak << 6);

    if (gs.userWinStreak >= 5) {
      return _pickBySeed(
        [
          '${gs.userClubName} vive seu melhor momento na temporada, com ${gs.userWinStreak} vitórias seguidas e moral em alta.',
          '${gs.userClubName} atravessa uma fase fortíssima, já com ${gs.userWinStreak} vitórias consecutivas.',
          'O ${gs.userClubName} entra de vez em sua melhor arrancada do ano, embalado por ${gs.userWinStreak} vitórias seguidas.',
        ],
        seed,
      );
    }

    if (gs.userWinStreak >= 3) {
      return _pickBySeed(
        [
          '${gs.userClubName} embala ${gs.userWinStreak} vitórias consecutivas e começa a chamar atenção na competição.',
          '${gs.userClubName} vive sequência positiva de ${gs.userWinStreak} vitórias e fortalece seu momento.',
          'A boa fase do ${gs.userClubName} ganha corpo com ${gs.userWinStreak} vitórias seguidas.',
        ],
        seed,
      );
    }

    if (gs.userLoseStreak >= 5) {
      return _pickBySeed(
        [
          'O clima pesa no ${gs.userClubName}: já são ${gs.userLoseStreak} derrotas consecutivas e o alerta está ligado.',
          'A situação fica cada vez mais delicada no ${gs.userClubName}, que acumula ${gs.userLoseStreak} derrotas seguidas.',
          'O ${gs.userClubName} mergulha em crise, já com ${gs.userLoseStreak} tropeços consecutivos na competição.',
        ],
        seed,
      );
    }

    if (gs.userLoseStreak >= 3) {
      return _pickBySeed(
        [
          '${gs.userClubName} atravessa momento delicado, com ${gs.userLoseStreak} derrotas seguidas e necessidade de resposta imediata.',
          'A sequência negativa aumenta a cobrança sobre o ${gs.userClubName}, agora com ${gs.userLoseStreak} derrotas consecutivas.',
          '${gs.userClubName} vê a pressão crescer após ${gs.userLoseStreak} derrotas seguidas na temporada.',
        ],
        seed,
      );
    }

    if (gs.userDrawStreak >= 4) {
      return _pickBySeed(
        [
          '${gs.userClubName} entra em sequência morna: ${gs.userDrawStreak} empates seguidos e pouca evolução na tabela.',
          'O ${gs.userClubName} segue preso em empates, já são ${gs.userDrawStreak} em sequência e pouca mudança real de cenário.',
          '${gs.userClubName} acumula uma série de ${gs.userDrawStreak} empates e vê a campanha perder ritmo.',
        ],
        seed,
      );
    }

    if (gs.userDrawStreak >= 3) {
      return _pickBySeed(
        [
          '${gs.userClubName} acumula ${gs.userDrawStreak} empates consecutivos e vê a pressão crescer por uma vitória.',
          'A campanha do ${gs.userClubName} entra num trecho travado, com ${gs.userDrawStreak} empates seguidos.',
          '${gs.userClubName} pontua, mas não deslancha: já são ${gs.userDrawStreak} empates consecutivos.',
        ],
        seed,
      );
    }

    return null;
  }

  // ================================
  // TABLE
  // ================================
  static String? _tableSituation(GameState gs) {
    final sorted = gs.table.getSorted();
    if (sorted.isEmpty) return null;

    final idx = sorted.indexWhere((e) => e.clubId == gs.userClubId);
    if (idx < 0) return null;

    final pos = idx + 1;
    final total = sorted.length;
    final entry = sorted[idx];
    final points = entry.points;

    final topZoneLimit = 4;
    final relegationStart = total - 3;
    final seed = gs.userClubName.hashCode ^ pos ^ (points << 1) ^ gs.roundIndex;
    final earlyRounds = gs.roundIndex <= 4;

    if (earlyRounds) {
      if (pos <= topZoneLimit) {
        return _pickBySeed(
          [
            '${gs.userClubName} larga bem e aparece entre os primeiros colocados.',
            '${gs.userClubName} começa a temporada em posição competitiva na parte alta.',
            '${gs.userClubName} abre a campanha com presença forte entre os primeiros da tabela.',
          ],
          seed,
        );
      }

      if (pos >= relegationStart) {
        return _pickBySeed(
          [
            '${gs.userClubName} começa a temporada sob pressão e precisa reagir cedo.',
            '${gs.userClubName} tem início incômodo de campanha e já vê a parte baixa da tabela de perto.',
            '${gs.userClubName} larga mal e precisará responder rapidamente para não se afundar cedo.',
          ],
          seed,
        );
      }

      return _pickBySeed(
        [
          '${gs.userClubName} ainda tenta encontrar seu lugar na tabela neste início de temporada.',
          '${gs.userClubName} faz uma largada de campanha ainda em construção na classificação.',
          '${gs.userClubName} começa o campeonato buscando transformar o início em algo mais sólido.',
        ],
        seed,
      );
    }

    if (pos == 1) {
      return _pickBySeed(
        [
          '${gs.userClubName} assume a liderança da competição com $points pontos e reforça a sensação de campanha forte.',
          '${gs.userClubName} chega ao topo da tabela com $points pontos e passa a carregar o peso da liderança.',
          'A liderança agora é do ${gs.userClubName}, que alcança $points pontos e vive um grande momento.',
        ],
        seed,
      );
    }

    if (pos <= topZoneLimit) {
      return _pickBySeed(
        [
          '${gs.userClubName} aparece no G4, em ${pos}º lugar com $points pontos, e fortalece a briga na parte de cima.',
          '${gs.userClubName} se mantém entre os primeiros, agora em ${pos}º com $points pontos.',
          '${gs.userClubName} pisa firme no G4 e reforça sua campanha na parte alta com $points pontos.',
        ],
        seed,
      );
    }

    if (pos == relegationStart) {
      return _pickBySeed(
        [
          '${gs.userClubName} cai para a zona de rebaixamento: ${pos}º lugar e $points pontos. O sinal de alerta está aceso.',
          '${gs.userClubName} entra no Z4 e vê a pressão aumentar com $points pontos.',
          'O ${gs.userClubName} escorrega para a zona de rebaixamento e agora vive um momento de alerta real.',
        ],
        seed,
      );
    }

    if (pos > relegationStart) {
      return _pickBySeed(
        [
          '${gs.userClubName} segue afundado na parte de baixo da tabela, em ${pos}º lugar com $points pontos.',
          '${gs.userClubName} continua em situação incômoda, preso na parte inferior com $points pontos.',
          'A tabela ainda aperta o ${gs.userClubName}, agora em ${pos}º lugar com $points pontos.',
        ],
        seed,
      );
    }

    if (pos <= 8) {
      return _pickBySeed(
        [
          '${gs.userClubName} se mantém competitivo, em ${pos}º lugar com $points pontos, ainda próximo da parte alta.',
          '${gs.userClubName} segue perto do bloco de cima, ocupando o ${pos}º lugar com $points pontos.',
          '${gs.userClubName} mantém sua campanha viva na metade superior, em ${pos}º com $points pontos.',
        ],
        seed,
      );
    }

    if (pos >= total - 6) {
      return _pickBySeed(
        [
          '${gs.userClubName} ronda a parte perigosa da tabela, em ${pos}º lugar com $points pontos.',
          '${gs.userClubName} continua olhando mais para baixo do que gostaria, agora em ${pos}º com $points pontos.',
          '${gs.userClubName} permanece perto da zona incômoda da classificação, com $points pontos.',
        ],
        seed,
      );
    }

    return _pickBySeed(
      [
        '${gs.userClubName} permanece no meio da tabela, em ${pos}º lugar com $points pontos, tentando ganhar tração na temporada.',
        '${gs.userClubName} segue no bloco intermediário da classificação, em ${pos}º com $points pontos.',
        '${gs.userClubName} ocupa a região central da tabela e ainda busca transformar sua campanha em algo maior.',
      ],
      seed,
    );
  }

  // ================================
  // ATTENDANCE
  // ================================
  static String? buildHomeGateNews({
    required String clubName,
    required int attendance,
    required int stadiumLevel,
  }) {
    if (attendance <= 0) return null;

    final capacity = _estimatedCapacityByStadiumLevel(stadiumLevel);
    final occupancy = capacity <= 0
        ? 0
        : ((attendance / capacity) * 100).round().clamp(0, 100);

    final seed = clubName.hashCode ^ attendance ^ (stadiumLevel << 4);

    if (occupancy >= 95) {
      return _pickBySeed(
        [
          '$clubName praticamente lotou o estádio: $attendance torcedores e clima de grande apoio nas arquibancadas.',
          '$clubName teve casa cheia na prática, com $attendance torcedores empurrando a equipe.',
          '$clubName contou com arquibancadas muito cheias: $attendance torcedores e ambiente forte de apoio.',
        ],
        seed,
      );
    }

    if (occupancy >= 80) {
      return _pickBySeed(
        [
          '$clubName contou com ótimo público: $attendance torcedores (${occupancy}% de ocupação).',
          '$clubName teve grande presença de torcida, com $attendance torcedores nas arquibancadas.',
          '$clubName recebeu um público muito forte: $attendance torcedores e ${occupancy}% de ocupação.',
        ],
        seed,
      );
    }

    if (occupancy >= 60) {
      return _pickBySeed(
        [
          '$clubName teve boa presença nas arquibancadas, com $attendance torcedores e ${occupancy}% de ocupação.',
          '$clubName contou com apoio consistente da torcida, levando $attendance torcedores ao estádio.',
          '$clubName recebeu um público positivo, com $attendance torcedores acompanhando a partida.',
        ],
        seed,
      );
    }

    if (occupancy >= 45) {
      return _pickBySeed(
        [
          '$clubName recebeu $attendance torcedores, com ${occupancy}% de ocupação do estádio.',
          '$clubName teve público moderado, com $attendance torcedores presentes.',
          '$clubName contou com presença razoável nas arquibancadas: $attendance torcedores.',
        ],
        seed,
      );
    }

    return _pickBySeed(
      [
        'Público discreto para o $clubName: $attendance torcedores, com apenas ${occupancy}% de ocupação.',
        '$clubName teve arquibancadas vazias para o padrão da casa, com só $attendance torcedores.',
        'O público foi baixo para o $clubName: $attendance torcedores e pouco peso vindo das arquibancadas.',
      ],
      seed,
    );
  }

  // ================================
  // CAPACITY
  // ================================
  static int _estimatedCapacityByStadiumLevel(int level) {
    switch (level.clamp(1, 10)) {
      case 1:
        return 4000;
      case 2:
        return 7000;
      case 3:
        return 10000;
      case 4:
        return 15000;
      case 5:
        return 22000;
      case 6:
        return 30000;
      case 7:
        return 40000;
      case 8:
        return 50000;
      case 9:
        return 65000;
      case 10:
        return 80000;
      default:
        return 10000;
    }
  }

  // ================================
  // HIGHLIGHTS (USADO NO REPORT)
  // ================================
  static List<String> extractSeasonHighlights(List<String> news) {
    final highlights = <String>[];
    final seen = <String>{};

    for (final n in news) {
      final text = n.trim();
      if (text.isEmpty) continue;

      final lower = text.toLowerCase();

      final isRelevant = lower.contains('liderança') ||
          lower.contains('g4') ||
          lower.contains('zona de rebaixamento') ||
          lower.contains('rebaixamento') ||
          lower.contains('vitórias consecutivas') ||
          lower.contains('vitórias seguidas') ||
          lower.contains('derrotas consecutivas') ||
          lower.contains('derrotas seguidas') ||
          lower.contains('empates consecutivos') ||
          lower.contains('empates seguidos') ||
          lower.contains('melhor momento na temporada') ||
          lower.contains('alerta está ligado') ||
          lower.contains('pressão aumenta') ||
          lower.contains('moral em alta') ||
          lower.contains('campanha forte') ||
          lower.contains('parte de cima') ||
          lower.contains('parte de baixo') ||
          lower.contains('crise') ||
          lower.contains('tropeço') ||
          lower.contains('frustração') ||
          lower.contains('gosto amargo') ||
          lower.contains('3 x') ||
          lower.contains('4 x') ||
          lower.contains('5 x');

      if (!isRelevant) continue;
      if (seen.contains(text)) continue;

      seen.add(text);
      highlights.add(text);

      if (highlights.length >= 5) {
        break;
      }
    }

    return highlights;
  }

  // ================================
  // HELPERS
  // ================================
  static int? _userPosition(GameState gs) {
    final sorted = gs.table.getSorted();
    if (sorted.isEmpty) return null;

    final idx = sorted.indexWhere((e) => e.clubId == gs.userClubId);
    if (idx < 0) return null;

    return idx + 1;
  }

  static int _relegationStart(GameState gs) {
    final total = gs.table.getSorted().length;
    return total - 3;
  }

  static _ParsedUserMatch? _parseUserMatch(GameState gs, String matchLine) {
    const separator = ' x ';
    final sepIndex = matchLine.indexOf(separator);
    if (sepIndex < 0) return null;

    final left = matchLine.substring(0, sepIndex).trim();
    final right = matchLine.substring(sepIndex + separator.length).trim();

    final leftGoalsMatch = RegExp(r'(\d+)\s*$').firstMatch(left);
    final rightGoalsMatch = RegExp(r'^(\d+)').firstMatch(right);

    if (leftGoalsMatch == null || rightGoalsMatch == null) return null;

    final homeGoals = int.tryParse(leftGoalsMatch.group(1) ?? '');
    final awayGoals = int.tryParse(rightGoalsMatch.group(1) ?? '');
    if (homeGoals == null || awayGoals == null) return null;

    final homeClub = left.substring(0, leftGoalsMatch.start).trim();
    final awayClub = right.substring(rightGoalsMatch.end).trim();

    final isUserHome = homeClub == gs.userClubName;
    final isUserAway = awayClub == gs.userClubName;

    if (!isUserHome && !isUserAway) return null;

    return _ParsedUserMatch(
      isUserHome: isUserHome,
      userGoals: isUserHome ? homeGoals : awayGoals,
      oppGoals: isUserHome ? awayGoals : homeGoals,
    );
  }

  static String _pickBySeed(List<String> options, int seed) {
    if (options.isEmpty) return '';
    final index = seed.abs() % options.length;
    return options[index];
  }
}

class _ParsedUserMatch {
  final bool isUserHome;
  final int userGoals;
  final int oppGoals;

  const _ParsedUserMatch({
    required this.isUserHome,
    required this.userGoals,
    required this.oppGoals,
  });
}
