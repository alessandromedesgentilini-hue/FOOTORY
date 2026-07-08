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
    SeasonNarrativeAnalysis analysis,
  ) {
    switch (analysis.boardMood) {
      case BoardMood.thrilled:
        return 'DIRETORIA — Internamente, a temporada fortalece muito a confiança no planejamento esportivo do clube.';

      case BoardMood.satisfied:
        return 'DIRETORIA — A diretoria considera que o resultado final superou a régua estabelecida no início do campeonato.';

      case BoardMood.acceptable:
        return 'DIRETORIA — A avaliação interna é de uma temporada dentro de uma margem considerada aceitável para o contexto do clube.';

      case BoardMood.alert:
        return 'DIRETORIA — Apesar do contexto difícil, a diretoria entende que será necessário responder rápido na próxima temporada.';

      case BoardMood.disappointed:
        return 'DIRETORIA — O desempenho gera frustração interna e aumenta a cobrança por evolução competitiva.';

      case BoardMood.crisis:
        return 'DIRETORIA — A temporada aumenta drasticamente a pressão sobre o planejamento esportivo do clube.';
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
