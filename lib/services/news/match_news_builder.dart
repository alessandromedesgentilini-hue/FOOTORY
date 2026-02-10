// lib/services/news/match_news_builder.dart
//
// MatchNewsBuilder (MVP)
// - Gera texto simples de notícia baseado no placar
// - Regras:
//   Vitória: 1 gol = "disputado"; 2 gols = "domínio"; 3+ = "atropelo"
//   Derrota: 1 gol = "apesar do esforço"; 2 gols = "dominado"; 3+ = "goleado"
//   Empate: 0x0 morno; outros = movimentado

import '../../models/news/news_item.dart';

class MatchNewsBuilder {
  const MatchNewsBuilder();

  NewsItem build({
    required String clubId,
    required String clubNome,
    required String adversarioNome,
    required int rodada,
    required int golsPro,
    required int golsContra,
    required bool mandante,
    int? createdAtMs,
  }) {
    final nowMs = createdAtMs ?? DateTime.now().millisecondsSinceEpoch;

    final placar = mandante
        ? '$clubNome $golsPro x $golsContra $adversarioNome'
        : '$adversarioNome $golsContra x $golsPro $clubNome';

    final diff = (golsPro - golsContra).abs();
    final venceu = golsPro > golsContra;
    final perdeu = golsPro < golsContra;
    final empatou = golsPro == golsContra;

    final title = 'Rodada $rodada: $placar';

    final body = _buildBody(
      clubNome: clubNome,
      adversarioNome: adversarioNome,
      rodada: rodada,
      golsPro: golsPro,
      golsContra: golsContra,
      diff: diff,
      venceu: venceu,
      perdeu: perdeu,
      empatou: empatou,
      mandante: mandante,
    );

    // ✅ IMPORTANTE: use ${rodada} pra não virar "rodada_"
    final id = 'match_${clubId}_${rodada}_${nowMs}_${golsPro}x$golsContra';

    return NewsItem(
      id: id,
      type: NewsType.match, // ✅ garante o required 'type'
      title: title,
      body: body,
      createdAtMs: nowMs,
      clubId: clubId,
      meta: {
        'rodada': rodada,
        'clubNome': clubNome,
        'adversarioNome': adversarioNome,
        'golsPro': golsPro,
        'golsContra': golsContra,
        'mandante': mandante,
      },
    );
  }

  String _buildBody({
    required String clubNome,
    required String adversarioNome,
    required int rodada,
    required int golsPro,
    required int golsContra,
    required int diff,
    required bool venceu,
    required bool perdeu,
    required bool empatou,
    required bool mandante,
  }) {
    // Empates
    if (empatou) {
      if (golsPro == 0) {
        return 'Jogo morno na rodada $rodada: poucas chances e placar zerado. '
            'As equipes somaram um ponto e ficaram no “quem sabe na próxima”.';
      }
      return 'Jogo movimentado na rodada $rodada: as equipes trocaram golpes e o empate acabou sendo justo. '
          'Ficou tudo igual no placar.';
    }

    // Vitórias
    if (venceu) {
      if (diff == 1) {
        return 'Vitória apertada e suada na rodada $rodada. '
            '$clubNome venceu por um gol de diferença em um jogo disputado, decidido nos detalhes.';
      }
      if (diff == 2) {
        return 'Vitória convincente na rodada $rodada. '
            '$clubNome controlou o jogo e confirmou o resultado com domínio claro sobre o adversário.';
      }
      // 3+
      return 'Goleada na rodada $rodada. '
          '$clubNome foi totalmente dominante e o placar refletiu o que aconteceu em campo — atropelo sem discussão.';
    }

    // Derrotas
    if (perdeu) {
      if (diff == 1) {
        return 'Derrota por detalhes na rodada $rodada. '
            'Apesar do esforço, $clubNome acabou superado por um gol e não foi suficiente para bater o adversário.';
      }
      if (diff == 2) {
        return 'Derrota dura na rodada $rodada. '
            '$clubNome foi dominado em boa parte do jogo e o placar mostrou a diferença entre as equipes.';
      }
      // 3+
      return 'Goleada sofrida na rodada $rodada. '
          '$clubNome foi absolutamente dominado e o resultado foi pesado — noite para esquecer.';
    }

    // fallback (não deveria acontecer)
    return 'Rodada $rodada encerrada. Placar: $golsPro x $golsContra.';
  }
}
