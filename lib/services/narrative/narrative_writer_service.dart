import 'package:footory26/services/club_status/club_status_runtime.dart';
import 'package:footory26/services/narrative/season_narrative_analyzer.dart';
import 'package:footory26/services/narrative/season_narrative_context.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class EndSeasonNarrativeTexts {
  final String emotionLabel;

  final String seasonLine;
  final String supporterLine;
  final String boardLine;
  final String pressLine;

  final String? contextLine;

  const EndSeasonNarrativeTexts({
    required this.emotionLabel,
    required this.seasonLine,
    required this.supporterLine,
    required this.boardLine,
    required this.pressLine,
    this.contextLine,
  });
}

class NarrativeWriterService {
  const NarrativeWriterService();

  EndSeasonNarrativeTexts writeEndSeasonNarrative({
    required SeasonNarrativeContext context,
    required SeasonNarrativeAnalysis analysis,
    required int boardPrestige,
  }) {
    final emotionLabel = _emotionLabel(
      analysis.seasonEmotion,
    );

    final divisionLabel = _divisionShortLabel(
      context.division,
    );

    final contextLine = context.expectation.expectedLabel !=
            context.expectation.initialExpectedLabel
        ? 'CONTEXTO — O elenco terminou o ano em um patamar diferente do início da temporada, mas a avaliação considera a expectativa original definida no começo da campanha.'
        : null;

    return EndSeasonNarrativeTexts(
      emotionLabel: emotionLabel,
      contextLine: contextLine,
      seasonLine:
          'TEMPORADA — $emotionLabel. O ${context.clubName} encerra a campanha na $divisionLabel após um ano marcado por ${_seasonSummary(context, analysis)}.',
      supporterLine: _supporterLine(
        context,
        analysis,
      ),
      boardLine: _boardLine(
        context,
        analysis,
        boardPrestige: boardPrestige,
      ),
      pressLine: _pressLine(
        context,
        analysis,
      ),
    );
  }

  String _emotionLabel(
    SeasonEmotion emotion,
  ) {
    switch (emotion) {
      case SeasonEmotion.legendary:
        return 'Temporada lendária';

      case SeasonEmotion.historic:
        return 'Temporada histórica';

      case SeasonEmotion.excellent:
        return 'Temporada muito acima do esperado';

      case SeasonEmotion.positive:
        return 'Temporada positiva';

      case SeasonEmotion.acceptable:
        return 'Temporada aceitável';

      case SeasonEmotion.survival:
        return 'Temporada de sobrevivência';

      case SeasonEmotion.painful:
        return 'Temporada dolorosa';

      case SeasonEmotion.frustrating:
        return 'Temporada frustrante';

      case SeasonEmotion.critical:
        return 'Temporada crítica';
    }
  }

  String _seasonSummary(
    SeasonNarrativeContext context,
    SeasonNarrativeAnalysis analysis,
  ) {
    if (context.promoted) {
      return 'crescimento esportivo e mudança de percepção sobre o clube';
    }

    if (context.relegated) {
      if (analysis.seasonEmotion == SeasonEmotion.critical) {
        return 'forte pressão esportiva e questionamentos sobre o rumo do projeto';
      }

      return 'frustração esportiva, mas também pela sensação de que o clube ainda pode reagir rapidamente';
    }

    if (analysis.stronglyAboveExpectation) {
      return 'uma campanha muito acima da expectativa inicial';
    }

    if (analysis.onExpectation) {
      return 'uma campanha coerente com a força projetada no início do ano';
    }

    if (analysis.belowExpectation) {
      return 'um desempenho abaixo do esperado em momentos importantes';
    }

    return 'uma campanha competitiva ao longo do campeonato';
  }

  String _supporterLine(
    SeasonNarrativeContext context,
    SeasonNarrativeAnalysis analysis,
  ) {
    switch (analysis.supporterMood) {
      case SupporterMood.euphoric:
        if (context.finalPosition == 1) {
          return 'TORCIDA — O fim da temporada entra para a memória da torcida como um dos grandes momentos da história recente do clube.';
        }

        return 'TORCIDA — A torcida termina o ano em euforia, sentindo que o clube mudou de patamar competitivo.';

      case SupporterMood.proud:
        return 'TORCIDA — A torcida encerra o ano orgulhosa com a campanha e sente que o clube deu um passo importante de crescimento.';

      case SupporterMood.satisfied:
        return 'TORCIDA — O ambiente termina positivo, com sensação de evolução e competitividade ao longo da temporada.';

      case SupporterMood.relieved:
        return 'TORCIDA — O fim da temporada traz alívio depois de um campeonato difícil e cheio de pressão.';

      case SupporterMood.hopeful:
        return 'TORCIDA — A queda frustra, mas parte da torcida ainda acredita que o projeto possui base para reagir rapidamente.';

      case SupporterMood.demanding:
        return 'TORCIDA — A campanha deixa a sensação de que o clube poderia ter entregue mais em momentos importantes do ano.';

      case SupporterMood.angry:
        return 'TORCIDA — O clima termina pesado nas arquibancadas, com forte pressão por mudanças e respostas rápidas.';
    }
  }

  String _boardLine(
    SeasonNarrativeContext context,
    SeasonNarrativeAnalysis analysis, {
    required int boardPrestige,
  }) {
    final prestige = boardPrestige.clamp(1, 10).toInt();

    switch (analysis.boardMood) {
      case BoardMood.thrilled:
        if (prestige >= 10) {
          return 'DIRETORIA — A temporada reforça uma relação já histórica. A diretoria reconhece o trabalho como parte central da trajetória recente do clube e deposita confiança total na continuidade do projeto.';
        }

        if (prestige >= 8) {
          return 'DIRETORIA — A temporada amplia ainda mais o prestígio do diretor. Internamente, o planejamento esportivo é tratado com grande respeito e confiança.';
        }

        if (prestige >= 5) {
          return 'DIRETORIA — A temporada consolida a confiança no trabalho desenvolvido e fortalece de forma significativa a relação com o planejamento esportivo.';
        }

        if (prestige >= 3) {
          return 'DIRETORIA — O resultado causa forte entusiasmo e acelera a construção de confiança no trabalho do diretor.';
        }

        return 'DIRETORIA — A temporada causa excelente impressão e representa um passo importante para construir confiança no planejamento esportivo.';

      case BoardMood.satisfied:
        if (prestige >= 10) {
          return 'DIRETORIA — A diretoria considera que o resultado superou a régua inicial e reconhece mais uma contribuição relevante de um trabalho já marcado na história do clube.';
        }

        if (prestige >= 8) {
          return 'DIRETORIA — O resultado supera a régua estabelecida e reforça a elevada confiança da diretoria no trabalho que vem sendo realizado.';
        }

        if (prestige >= 5) {
          return 'DIRETORIA — A diretoria considera que o resultado superou a régua inicial e entende que o trabalho segue justificando a confiança conquistada.';
        }

        if (prestige >= 3) {
          return 'DIRETORIA — O resultado supera a régua estabelecida e contribui para fortalecer a confiança no planejamento esportivo.';
        }

        return 'DIRETORIA — O resultado supera a régua estabelecida e gera uma avaliação positiva sobre os primeiros passos do trabalho.';

      case BoardMood.acceptable:
        if (prestige >= 10) {
          return 'DIRETORIA — A temporada termina dentro de uma margem aceitável. O histórico construído garante confiança, embora a diretoria espere um novo avanço no próximo ano.';
        }

        if (prestige >= 8) {
          return 'DIRETORIA — A avaliação é de uma temporada aceitável. O trabalho acumulado preserva a confiança, mas a diretoria espera evolução na próxima campanha.';
        }

        if (prestige >= 5) {
          return 'DIRETORIA — A temporada fica dentro de uma margem aceitável. A confiança permanece, acompanhada da expectativa de evolução.';
        }

        if (prestige >= 3) {
          return 'DIRETORIA — A avaliação interna é de uma temporada aceitável, ainda sem conclusões definitivas sobre a consolidação do trabalho.';
        }

        return 'DIRETORIA — A temporada é considerada aceitável para o contexto do clube, mas a relação ainda está em fase inicial de avaliação.';

      case BoardMood.alert:
        if (prestige >= 10) {
          return 'DIRETORIA — A diretoria reconhece o peso histórico do trabalho, mas deixa claro que o contexto exige resposta rápida e correções importantes na próxima temporada.';
        }

        if (prestige >= 8) {
          return 'DIRETORIA — O crédito acumulado mantém a confiança no diretor, mas a diretoria cobra uma resposta rápida e consistente na próxima temporada.';
        }

        if (prestige >= 5) {
          return 'DIRETORIA — A confiança construída evita uma reação precipitada, mas será necessário responder rapidamente na próxima temporada.';
        }

        if (prestige >= 3) {
          return 'DIRETORIA — O contexto acende um alerta e interrompe parte do avanço na relação de confiança. A próxima temporada exigirá resposta rápida.';
        }

        return 'DIRETORIA — O contexto difícil acende um alerta precoce. A diretoria espera uma resposta rápida para aumentar a confiança no trabalho.';

      case BoardMood.disappointed:
        if (prestige >= 10) {
          return 'DIRETORIA — A temporada gera forte frustração, mesmo diante de uma trajetória histórica. A diretoria preserva o respeito pelo trabalho, mas cobra uma reação firme.';
        }

        if (prestige >= 8) {
          return 'DIRETORIA — O desempenho gera frustração interna. O prestígio acumulado garante respeito e confiança, mas aumenta também a responsabilidade por uma reação.';
        }

        if (prestige >= 5) {
          return 'DIRETORIA — O desempenho gera frustração e desgasta parte da confiança conquistada. A cobrança por evolução será maior na próxima temporada.';
        }

        if (prestige >= 3) {
          return 'DIRETORIA — A frustração interna interrompe a construção de confiança e aumenta de forma clara a cobrança sobre o planejamento esportivo.';
        }

        return 'DIRETORIA — O desempenho gera frustração em uma relação ainda pouco consolidada e aumenta significativamente a cobrança por resultados.';

      case BoardMood.crisis:
        if (prestige >= 10) {
          return 'DIRETORIA — A temporada provoca uma crise esportiva grave. Nem mesmo o peso histórico do trabalho elimina a cobrança por mudanças profundas e resposta imediata.';
        }

        if (prestige >= 8) {
          return 'DIRETORIA — A crise esportiva coloca o planejamento sob forte pressão. O prestígio acumulado preserva o respeito pelo diretor, mas não reduz a exigência por mudanças imediatas.';
        }

        if (prestige >= 5) {
          return 'DIRETORIA — A temporada coloca o planejamento esportivo em crise e consome parte importante da confiança construída. A resposta terá de ser imediata.';
        }

        if (prestige >= 3) {
          return 'DIRETORIA — A temporada provoca uma crise interna e abala fortemente uma relação de confiança que ainda estava em construção.';
        }

        return 'DIRETORIA — A temporada provoca uma crise esportiva e coloca o planejamento sob pressão máxima em uma relação ainda sem crédito acumulado.';
    }
  }

  String _pressLine(
    SeasonNarrativeContext context,
    SeasonNarrativeAnalysis analysis,
  ) {
    final club = context.clubName;

    switch (analysis.pressMood) {
      case PressMood.amazed:
        return 'IMPRENSA — A campanha do $club é tratada como uma das histórias mais marcantes da temporada.';

      case PressMood.impressed:
        return 'IMPRENSA — A imprensa destaca que o clube superou amplamente as projeções feitas no início do campeonato.';

      case PressMood.positive:
        return 'IMPRENSA — A avaliação geral é de que o clube mostrou evolução competitiva real ao longo do ano.';

      case PressMood.neutral:
        return 'IMPRENSA — A campanha é tratada como coerente com o cenário esportivo projetado antes do início da temporada.';

      case PressMood.questioning:
        return 'IMPRENSA — O rebaixamento é tratado como duro, mas compatível com o tamanho do desafio enfrentado pelo clube durante o ano.';

      case PressMood.critical:
        return 'IMPRENSA — A imprensa avalia que o clube ficou abaixo do que poderia entregar dentro da competição.';

      case PressMood.crisis:
        return 'IMPRENSA — A temporada é tratada como uma crise esportiva importante e aumenta o debate sobre o futuro do projeto.';
    }
  }

  String _divisionShortLabel(
    DivisionId div,
  ) {
    switch (div) {
      case DivisionId.brA:
        return 'Série A';

      case DivisionId.brB:
        return 'Série B';

      case DivisionId.brC:
        return 'Série C';

      case DivisionId.brD:
        return 'Série D';
    }
  }
}
