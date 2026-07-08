import 'package:footory26/models/player.dart';

class SeasonPlayerDelta {
  final String playerId;
  final String playerName;
  final int fromOvr;
  final int toOvr;
  final int delta;
  final String message;

  const SeasonPlayerDelta({
    required this.playerId,
    required this.playerName,
    required this.fromOvr,
    required this.toOvr,
    required this.delta,
    required this.message,
  });
}

class SeasonStatLeader {
  final String playerId;
  final String playerName;
  final int value;
  final String label;

  const SeasonStatLeader({
    required this.playerId,
    required this.playerName,
    required this.value,
    required this.label,
  });
}

class SeasonReport {
  final String title;
  final String summary;

  final List<SeasonPlayerDelta> playerDeltas;
  final List<SeasonPlayerDelta> topEvolutions;
  final List<SeasonPlayerDelta> topDeclines;

  final String bestPlayer;
  final String worstPlayer;

  final String topScorer;
  final String topAssister;
  final String mostDecisivePlayer;

  final List<String> seasonHighlights;

  const SeasonReport({
    required this.title,
    required this.summary,
    required this.playerDeltas,
    required this.topEvolutions,
    required this.topDeclines,
    required this.bestPlayer,
    required this.worstPlayer,
    required this.topScorer,
    required this.topAssister,
    required this.mostDecisivePlayer,
    required this.seasonHighlights,
  });
}

class SeasonReportBuilder {
  const SeasonReportBuilder();

  SeasonReport build({
    required List<Player> oldSquad,
    required List<Player> newSquad,
    required String clubName,
    required int finalPosition,
    required int points,
    required List<String> newsFeed,
  }) {
    final deltas = _buildDeltas(oldSquad, newSquad);

    final topUp = deltas.where((e) => e.delta > 0).toList()
      ..sort((a, b) {
        final byDelta = b.delta.compareTo(a.delta);
        if (byDelta != 0) return byDelta;
        return a.playerName.compareTo(b.playerName);
      });

    final topDown = deltas.where((e) => e.delta < 0).toList()
      ..sort((a, b) {
        final byDelta = a.delta.compareTo(b.delta);
        if (byDelta != 0) return byDelta;
        return a.playerName.compareTo(b.playerName);
      });

    final best = topUp.isNotEmpty ? topUp.first : null;
    final worst = topDown.isNotEmpty ? topDown.first : null;

    final topScorerLeader = _findTopScorer(newSquad);
    final topAssisterLeader = _findTopAssister(newSquad);
    final mostDecisiveLeader = _findMostDecisivePlayer(newSquad);

    final emotionalTitle = _buildEmotionalTitle(
      clubName: clubName,
      finalPosition: finalPosition,
    );

    final emotionalSummary = _buildSummary(
      club: clubName,
      pos: finalPosition,
      pts: points,
      deltas: deltas,
      topScorer: topScorerLeader,
      mostDecisive: mostDecisiveLeader,
      newsFeed: newsFeed,
    );

    return SeasonReport(
      title: emotionalTitle,
      summary: emotionalSummary,
      playerDeltas: deltas,
      topEvolutions: topUp.take(5).toList(),
      topDeclines: topDown.take(5).toList(),
      bestPlayer: _buildBestPlayerText(best),
      worstPlayer: _buildWorstPlayerText(worst),
      topScorer: _buildTopScorerText(topScorerLeader),
      topAssister: _buildTopAssisterText(topAssisterLeader),
      mostDecisivePlayer: _buildMostDecisiveText(mostDecisiveLeader),
      seasonHighlights: _extractHighlights(newsFeed),
    );
  }

  List<SeasonPlayerDelta> _buildDeltas(
    List<Player> oldSquad,
    List<Player> newSquad,
  ) {
    final mapOld = {for (final p in oldSquad) p.id: p};

    final list = <SeasonPlayerDelta>[];

    for (final p in newSquad) {
      final old = mapOld[p.id];

      final from = old?.ovrCheio ?? p.ovrCheio;
      final to = p.ovrCheio;
      final delta = to - from;

      list.add(
        SeasonPlayerDelta(
          playerId: p.id,
          playerName: p.nome,
          fromOvr: from,
          toOvr: to,
          delta: delta,
          message: _buildMessage(delta),
        ),
      );
    }

    list.sort((a, b) {
      final byDelta = b.delta.compareTo(a.delta);
      if (byDelta != 0) return byDelta;
      return a.playerName.compareTo(b.playerName);
    });

    return list;
  }

  String _buildMessage(int delta) {
    if (delta >= 5) return 'Explodiu de patamar';
    if (delta == 4) return 'Salto impressionante';
    if (delta == 3) return 'Evolução muito forte';
    if (delta == 2) return 'Boa evolução';
    if (delta == 1) return 'Crescimento consistente';
    if (delta == 0) return 'Temporada estável';
    if (delta == -1) return 'Leve queda de rendimento';
    if (delta == -2) return 'Queda preocupante';
    if (delta == -3) return 'Ano muito abaixo';
    return 'Declínio forte na temporada';
  }

  String _buildEmotionalTitle({
    required String clubName,
    required int finalPosition,
  }) {
    if (finalPosition == 1) {
      return 'Relatório da Temporada — Ano histórico para o $clubName';
    }

    if (finalPosition <= 4) {
      return 'Relatório da Temporada — O $clubName voltou a sonhar alto';
    }

    if (finalPosition <= 8) {
      return 'Relatório da Temporada — Campanha competitiva do $clubName';
    }

    if (finalPosition <= 12) {
      return 'Relatório da Temporada — Ano de estabilidade para o $clubName';
    }

    if (finalPosition <= 16) {
      return 'Relatório da Temporada — O $clubName sobreviveu à pressão';
    }

    return 'Relatório da Temporada — Ano duro para o $clubName';
  }

  String _buildSummary({
    required String club,
    required int pos,
    required int pts,
    required List<SeasonPlayerDelta> deltas,
    required SeasonStatLeader? topScorer,
    required SeasonStatLeader? mostDecisive,
    required List<String> newsFeed,
  }) {
    final campaign = _buildCampaignSummary(club, pos, pts);
    final squad = _buildSquadSummary(deltas);
    final hero = _buildHeroSummary(topScorer, mostDecisive);
    final atmosphere = _buildAtmosphereSummary(newsFeed, pos);

    return '$campaign $squad $hero $atmosphere';
  }

  String _buildCampaignSummary(String club, int pos, int pts) {
    if (pos == 1) {
      return '$club encerrou a temporada no topo, com $pts pontos, em uma campanha que muda o peso simbólico do clube no campeonato.';
    }

    if (pos <= 4) {
      return '$club fez uma campanha forte e terminou em ${pos}º lugar com $pts pontos, deixando a sensação de que o projeto esportivo ganhou força.';
    }

    if (pos <= 8) {
      return '$club terminou em ${pos}º lugar com $pts pontos, fechando a temporada de forma competitiva e com sinais claros de evolução.';
    }

    if (pos <= 12) {
      return '$club encerrou a temporada em ${pos}º lugar com $pts pontos, em uma campanha de estabilidade, altos e baixos e pouca margem para euforia.';
    }

    if (pos <= 16) {
      return '$club terminou em ${pos}º lugar com $pts pontos, em uma campanha de tensão, cobrança e alívio no fechamento do ano.';
    }

    return '$club viveu uma temporada pesada e terminou em ${pos}º lugar com $pts pontos, deixando um clima de frustração e necessidade de resposta.';
  }

  String _buildSquadSummary(List<SeasonPlayerDelta> deltas) {
    if (deltas.isEmpty) {
      return 'O elenco terminou o ano sem dados suficientes de evolução individual.';
    }

    final improved = deltas.where((e) => e.delta > 0).length;
    final declined = deltas.where((e) => e.delta < 0).length;
    final stable = deltas.where((e) => e.delta == 0).length;

    if (improved >= declined + 4) {
      return 'No elenco, a temporada deixou uma leitura positiva: vários jogadores cresceram e aumentaram a profundidade do grupo.';
    }

    if (declined >= improved + 4) {
      return 'No elenco, o alerta fica ligado: muitas quedas individuais indicam desgaste, idade ou necessidade de renovação.';
    }

    if (improved > declined) {
      return 'No elenco, houve mais evolução do que queda, sinalizando um grupo que ainda pode render mais.';
    }

    if (declined > improved) {
      return 'No elenco, as quedas pesaram um pouco mais do que as evoluções, exigindo atenção no planejamento.';
    }

    if (stable >= improved + declined) {
      return 'No elenco, o ano foi mais de manutenção do que transformação, com pouca mudança clara de patamar.';
    }

    return 'No elenco, a leitura foi equilibrada: alguns nomes cresceram, outros perderam espaço e o grupo terminou em transição.';
  }

  String _buildHeroSummary(
    SeasonStatLeader? topScorer,
    SeasonStatLeader? mostDecisive,
  ) {
    if (mostDecisive != null && topScorer != null) {
      if (mostDecisive.playerId == topScorer.playerId) {
        return '${mostDecisive.playerName} terminou como grande rosto da temporada, liderando gols e impacto nos momentos importantes.';
      }

      return '${topScorer.playerName} foi a principal referência em gols, enquanto ${mostDecisive.playerName} apareceu como nome mais decisivo no balanço geral.';
    }

    if (mostDecisive != null) {
      return '${mostDecisive.playerName} foi o nome mais decisivo do ano e virou referência técnica da campanha.';
    }

    if (topScorer != null) {
      return '${topScorer.playerName} terminou como artilheiro e foi a principal referência ofensiva.';
    }

    return 'A temporada não teve um protagonista individual absoluto, reforçando a sensação de campanha coletiva.';
  }

  String _buildAtmosphereSummary(List<String> newsFeed, int pos) {
    final lowerFeed = newsFeed.map((e) => e.toLowerCase()).toList();

    final hadPressure = lowerFeed.any((e) => e.contains('pressão'));
    final hadG4 = lowerFeed.any((e) => e.contains('g4'));
    final hadLeadership = lowerFeed.any((e) => e.contains('liderança'));
    final hadRelegation = lowerFeed.any((e) => e.contains('rebaixamento'));

    if (pos == 1 || hadLeadership) {
      return 'A atmosfera do ano foi de protagonismo, com a torcida sentindo que acompanhava uma campanha especial.';
    }

    if (pos <= 4 || hadG4) {
      return 'A atmosfera do ano foi de ambição, com o clube passando boa parte da campanha olhando para cima.';
    }

    if (pos >= 17 || hadRelegation) {
      return 'A atmosfera do ano foi pesada, marcada por tensão, cobrança e medo de queda.';
    }

    if (hadPressure || pos <= 16 && pos >= 13) {
      return 'A atmosfera do ano oscilou entre cobrança e alívio, sem permitir tranquilidade plena.';
    }

    return 'A atmosfera do ano foi de construção, sem explosão emocional, mas com material para evoluir na próxima temporada.';
  }

  String _buildBestPlayerText(SeasonPlayerDelta? best) {
    if (best == null) {
      return 'Nenhum jogador teve evolução realmente marcante na temporada.';
    }

    if (best.delta >= 5) {
      return '${best.playerName} explodiu de patamar e foi a evolução mais impressionante do elenco.';
    }

    if (best.delta >= 3) {
      return '${best.playerName} foi o principal destaque de evolução do elenco.';
    }

    return '${best.playerName} apresentou crescimento consistente e terminou o ano em alta.';
  }

  String _buildWorstPlayerText(SeasonPlayerDelta? worst) {
    if (worst == null) {
      return 'Nenhum jogador teve queda relevante ao longo da temporada.';
    }

    if (worst.delta <= -4) {
      return '${worst.playerName} teve uma queda forte e termina o ano como ponto de atenção máxima.';
    }

    if (worst.delta <= -2) {
      return '${worst.playerName} terminou o ano em baixa e foi a principal queda do elenco.';
    }

    return '${worst.playerName} teve leve queda e merece acompanhamento na próxima temporada.';
  }

  SeasonStatLeader? _findTopScorer(List<Player> squad) {
    if (squad.isEmpty) return null;

    final sorted = List<Player>.from(squad)
      ..sort((a, b) {
        final byGoals = b.temporadaGols.compareTo(a.temporadaGols);
        if (byGoals != 0) return byGoals;

        final byHighlights =
            b.temporadaDestaques.compareTo(a.temporadaDestaques);
        if (byHighlights != 0) return byHighlights;

        return a.nome.compareTo(b.nome);
      });

    final first = sorted.first;
    if (first.temporadaGols <= 0) return null;

    return SeasonStatLeader(
      playerId: first.id,
      playerName: first.nome,
      value: first.temporadaGols,
      label: 'gols',
    );
  }

  SeasonStatLeader? _findTopAssister(List<Player> squad) {
    if (squad.isEmpty) return null;

    final sorted = List<Player>.from(squad)
      ..sort((a, b) {
        final byAssists =
            b.temporadaAssistencias.compareTo(a.temporadaAssistencias);
        if (byAssists != 0) return byAssists;

        final byHighlights =
            b.temporadaDestaques.compareTo(a.temporadaDestaques);
        if (byHighlights != 0) return byHighlights;

        return a.nome.compareTo(b.nome);
      });

    final first = sorted.first;
    if (first.temporadaAssistencias <= 0) return null;

    return SeasonStatLeader(
      playerId: first.id,
      playerName: first.nome,
      value: first.temporadaAssistencias,
      label: 'assistências',
    );
  }

  SeasonStatLeader? _findMostDecisivePlayer(List<Player> squad) {
    if (squad.isEmpty) return null;

    final sorted = List<Player>.from(squad)
      ..sort((a, b) {
        final aScore = _decisiveScore(a);
        final bScore = _decisiveScore(b);

        final byScore = bScore.compareTo(aScore);
        if (byScore != 0) return byScore;

        return a.nome.compareTo(b.nome);
      });

    final first = sorted.first;
    final score = _decisiveScore(first);

    if (score <= 0) return null;

    return SeasonStatLeader(
      playerId: first.id,
      playerName: first.nome,
      value: score,
      label: 'impacto',
    );
  }

  int _decisiveScore(Player p) {
    return (p.temporadaGols * 3) +
        (p.temporadaAssistencias * 2) +
        (p.temporadaDestaques * 4);
  }

  String _buildTopScorerText(SeasonStatLeader? leader) {
    if (leader == null) {
      return 'O clube terminou a temporada sem um artilheiro claramente destacado.';
    }

    if (leader.value >= 20) {
      return '${leader.playerName} terminou como grande artilheiro do clube, com ${leader.value} gol(s), em uma temporada de forte protagonismo ofensivo.';
    }

    if (leader.value >= 10) {
      return '${leader.playerName} terminou como artilheiro do clube, com ${leader.value} gol(s).';
    }

    return '${leader.playerName} foi o artilheiro do clube, com ${leader.value} gol(s), mas sem números de domínio absoluto.';
  }

  String _buildTopAssisterText(SeasonStatLeader? leader) {
    if (leader == null) {
      return 'Nenhum jogador se destacou de forma clara como principal garçom do elenco.';
    }

    if (leader.value >= 12) {
      return '${leader.playerName} foi o grande garçom da temporada, com ${leader.value} passe(s) para gol.';
    }

    return '${leader.playerName} foi o líder em assistências, com ${leader.value} passe(s) para gol.';
  }

  String _buildMostDecisiveText(SeasonStatLeader? leader) {
    if (leader == null) {
      return 'A temporada não teve um nome isolado como jogador mais decisivo do elenco.';
    }

    if (leader.value >= 45) {
      return '${leader.playerName} foi o jogador mais decisivo da temporada e carregou peso enorme nos momentos importantes.';
    }

    return '${leader.playerName} foi o jogador mais decisivo da temporada, somando peso ofensivo e presença nos momentos importantes.';
  }

  List<String> _extractHighlights(List<String> newsFeed) {
    final highlights = <String>[];
    final seen = <String>{};

    for (final n in newsFeed) {
      final text = n.trim();
      if (text.isEmpty) continue;

      final lower = text.toLowerCase();

      final isRelevant = lower.contains('temporada histórica') ||
          lower.contains('temporada dura') ||
          lower.contains('temporada') ||
          lower.contains('atmosfera') ||
          lower.contains('torcida') ||
          lower.contains('imprensa') ||
          lower.contains('liderança') ||
          lower.contains('g4') ||
          lower.contains('zona de rebaixamento') ||
          lower.contains('rebaixamento') ||
          lower.contains('acesso') ||
          lower.contains('título') ||
          lower.contains('campeão') ||
          lower.contains('vice') ||
          lower.contains('semifinal') ||
          lower.contains('final') ||
          lower.contains('vitórias consecutivas') ||
          lower.contains('vitórias seguidas') ||
          lower.contains('derrotas seguidas') ||
          lower.contains('derrotas consecutivas') ||
          lower.contains('empates consecutivos') ||
          lower.contains('reta final') ||
          lower.contains('metade da temporada') ||
          lower.contains('fim de temporada') ||
          lower.contains('pressão') ||
          lower.contains('diretoria') ||
          lower.contains('destaque do jogo') ||
          lower.contains('3 x') ||
          lower.contains('4 x') ||
          lower.contains('5 x');

      if (!isRelevant) continue;
      if (seen.contains(text)) continue;

      seen.add(text);
      highlights.add(text);

      if (highlights.length >= 7) {
        break;
      }
    }

    if (highlights.isEmpty) {
      return const [
        'A temporada terminou sem grandes marcos narrativos registrados.',
      ];
    }

    return highlights;
  }
}
