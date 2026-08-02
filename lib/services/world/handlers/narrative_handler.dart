part of '../game_state.dart';

extension NarrativeHandler on GameState {
  // ================================
  // ENTRY POINT (CHAMAR APÓS RODADA)
  // ================================
  void _processNarrativeAfterRound({
    required int roundJustFinished,
    String? styleNarrative,
  }) {
    final generatedNews = NewsService.generateAfterRound(this);
    final isSpecialRound = _isSpecialNarrativeRound(roundJustFinished);

    final primary = isSpecialRound
        ? _pickPrimarySpecialRoundNews(styleNarrative)
        : _pickPrimaryNormalRoundNews(generatedNews);

    if (primary != null && primary.isNotEmpty) {
      _insertNewsIfNew(primary, category: GameMessageCategory.match);
    }

    final secondary =
        isSpecialRound ? _buildSeasonAnalysisLine(roundJustFinished) : null;

    if (secondary != null && secondary.isNotEmpty) {
      if (primary == null || secondary.trim() != primary.trim()) {
        _insertNewsIfNew(secondary);
      }
    }

    final emotionalContext =
        isSpecialRound ? _buildEmotionalContextLine(roundJustFinished) : null;

    if (emotionalContext != null && emotionalContext.isNotEmpty) {
      if (primary == null || emotionalContext.trim() != primary.trim()) {
        if (secondary == null || emotionalContext.trim() != secondary.trim()) {
          _insertNewsIfNew(emotionalContext);
        }
      }
    }

    _generateDepartmentMessagesForRound(roundJustFinished);
  }

  // ================================
  // PRIMARY NEWS
  // ================================
  String? _pickPrimaryNormalRoundNews(List<String> generatedNews) {
    if (generatedNews.isEmpty) return null;

    final matchNews = generatedNews.first.trim();
    if (matchNews.isEmpty) return null;

    return matchNews;
  }

  String? _pickPrimarySpecialRoundNews(String? styleNarrative) {
    final text = styleNarrative?.trim() ?? '';
    if (text.isEmpty) return null;
    return text;
  }

  // ================================
  // SEASON ANALYSIS
  // ================================
  String? _buildSeasonAnalysisLine(int round) {
    if (!_isSpecialNarrativeRound(round)) return null;

    final pos = _getUserPosition();
    if (pos == null) return null;

    final sorted = table.getSorted();
    if (sorted.isEmpty) return null;

    final idx = sorted.indexWhere((e) => e.clubId == userClubId);
    if (idx < 0) return null;

    final points = sorted[idx].points;
    final total = sorted.length;
    final snap = _expectations;

    final topZone = pos <= 4;
    final dangerZone = pos >= total - 3;
    final lowerZone = pos >= total - 6;
    final status = userClubStatusLabel.toLowerCase();

    if (round == 6) {
      if (topZone) {
        return _pickNarrativeLine(
          [
            '$userClubName faz uma largada promissora. Como $status, o clube já chama atenção no começo da temporada.',
            '$userClubName começa a competição de forma encorpada e passa boa impressão nesse início de campanha.',
            '$userClubName larga bem e mostra sinais de que pode fazer uma campanha competitiva acima do tom esperado para seu momento.',
          ],
          salt: 106,
        );
      }

      if (dangerZone) {
        return _pickNarrativeLine(
          [
            '$userClubName começa a temporada sob pressão e já precisa reagir para não se enrolar cedo.',
            'O início de campanha do $userClubName acende um primeiro sinal de alerta, especialmente pelo status atual de $status.',
            '$userClubName larga de forma desconfortável e sabe que precisa corrigir a rota rapidamente.',
          ],
          salt: 107,
        );
      }

      return _pickNarrativeLine(
        [
          '$userClubName ainda tenta encontrar seu lugar na tabela neste início de temporada.',
          '$userClubName faz um começo de campanha em construção e ainda busca ganhar forma na competição.',
          'O começo da temporada do $userClubName ainda pede leitura, ajustes e mais consistência.',
        ],
        salt: 108,
      );
    }

    if (round == 12) {
      if (topZone) {
        return _pickNarrativeLine(
          [
            '$userClubName entra no primeiro grande recorte da temporada em posição forte, com $points pontos e campanha competitiva.',
            'Com $points pontos, o $userClubName atravessa a primeira faixa importante do campeonato em boa situação.',
            '$userClubName chega à rodada 12 com sinais claros de solidez e presença forte na parte alta.',
          ],
          salt: 112,
        );
      }

      if (dangerZone || lowerZone) {
        return _pickNarrativeLine(
          [
            '$userClubName chega à rodada 12 ainda cercado por pressão e precisando responder com mais consistência.',
            'A altura da rodada 12, o $userClubName ainda vive uma campanha desconfortável e sem muito espaço para erro.',
            '$userClubName entra no primeiro recorte pesado da temporada ainda olhando mais para baixo do que gostaria.',
          ],
          salt: 113,
        );
      }

      return _pickNarrativeLine(
        [
          '$userClubName chega à rodada 12 com campanha ainda aberta, mas já sob uma leitura mais concreta da tabela.',
          'A temporada do $userClubName entra num ponto em que o clube precisa começar a transformar estabilidade em avanço.',
          '$userClubName atravessa a rodada 12 ainda vivo, mas buscando dar um passo mais firme na competição.',
        ],
        salt: 114,
      );
    }

    if (round == 18) {
      if (snap != null && snap.delta >= 2) {
        return _pickNarrativeLine(
          [
            '$userClubName chega à rodada 18 entregando acima do que se esperava e fortalecendo a própria campanha.',
            'A altura da rodada 18, o $userClubName já mostra rendimento superior ao plano inicial da temporada.',
            '$userClubName vira a marca da rodada 18 com sensação clara de campanha acima da expectativa.',
          ],
          salt: 118,
        );
      }

      if (snap != null && snap.delta <= -2) {
        return _pickNarrativeLine(
          [
            '$userClubName alcança a rodada 18 abaixo do que se projetava e entra num momento de cobrança maior.',
            'Com a temporada já ganhando corpo, o $userClubName ainda entrega menos do que o cenário inicial sugeria.',
            '$userClubName cruza a rodada 18 precisando reagir para alinhar rendimento, expectativa e o status de $status.',
          ],
          salt: 119,
        );
      }

      return _pickNarrativeLine(
        [
          '$userClubName chega à rodada 18 com uma campanha que já começa a revelar seu tamanho real.',
          'A marca da rodada 18 coloca o $userClubName num ponto em que a temporada passa a ganhar contornos mais definidos.',
          '$userClubName entra na parte mais séria da temporada com uma campanha que já pede leitura mais madura.',
        ],
        salt: 120,
      );
    }

    if (round == 24) {
      if (topZone) {
        return _pickNarrativeLine(
          [
            '$userClubName entra na rodada 24 com presença firme na parte alta e sensação de campanha consolidada.',
            'Com a temporada avançando, o $userClubName já mostra força real entre os protagonistas da tabela.',
            '$userClubName chega à rodada 24 sustentando uma campanha forte e cada vez mais respeitada.',
          ],
          salt: 124,
        );
      }

      if (dangerZone) {
        return _pickNarrativeLine(
          [
            '$userClubName entra na rodada 24 com urgência crescente e pouca margem para seguir errando.',
            'A temporada pesa mais para o $userClubName na rodada 24, quando o risco passa a ganhar mais corpo.',
            '$userClubName chega à rodada 24 pressionado e cercado por uma sensação clara de alerta.',
          ],
          salt: 125,
        );
      }

      return _pickNarrativeLine(
        [
          '$userClubName alcança a rodada 24 ainda com espaço para mudar o rumo da temporada, para cima ou para baixo.',
          'A altura da rodada 24, a campanha do $userClubName segue em aberto, mas já exige firmeza maior.',
          '$userClubName chega à rodada 24 com a sensação de que o campeonato entrou de vez em seu trecho decisivo.',
        ],
        salt: 126,
      );
    }

    if (round == 30) {
      if (topZone) {
        return _pickNarrativeLine(
          [
            '$userClubName entra na reta final carregando uma campanha forte e com peso real na disputa da parte alta.',
            'A rodada 30 encontra o $userClubName em posição de força para sonhar alto no fechamento da temporada.',
            '$userClubName chega ao trecho decisivo ainda firme entre os times que sustentam ambição alta.',
          ],
          salt: 130,
        );
      }

      if (dangerZone || lowerZone) {
        return _pickNarrativeLine(
          [
            '$userClubName entra na reta final sob forte pressão, sabendo que cada rodada agora pesa demais.',
            'A altura da rodada 30, o $userClubName joga com urgência crescente e quase sem margem para tropeços.',
            '$userClubName chega ao trecho final da temporada com o sinal de alerta completamente ligado.',
          ],
          salt: 131,
        );
      }

      return _pickNarrativeLine(
        [
          '$userClubName entra na reta final ainda tentando definir o verdadeiro tamanho da sua campanha.',
          'A rodada 30 coloca o $userClubName diante de um fechamento de temporada que pode mudar bastante a leitura final.',
          '$userClubName chega ao trecho derradeiro da competição ainda buscando transformar a campanha em algo maior.',
        ],
        salt: 132,
      );
    }

    return null;
  }

  String? _buildEmotionalContextLine(int round) {
    if (!_isSpecialNarrativeRound(round)) return null;

    final pos = _getUserPosition();
    if (pos == null) return null;

    final sorted = table.getSorted();
    if (sorted.isEmpty) return null;

    final idx = sorted.indexWhere((e) => e.clubId == userClubId);
    if (idx < 0) return null;

    final points = sorted[idx].points;
    final total = sorted.length;
    final snap = _expectations;

    final statusTone = _clubStatusToneForNarrative();
    final legacyTone = _legacyToneForNarrative();
    final expectationTone = _expectationToneForNarrative(snap?.delta);
    final tableTone = _tableToneForNarrative(
      position: pos,
      totalTeams: total,
    );

    if (round == 6) {
      return 'CLIMA DA TEMPORADA — Início de liga: $statusTone $tableTone $expectationTone';
    }

    if (round == 12) {
      return 'CLIMA DA TEMPORADA — Primeiro recorte real: $userClubName soma $points pontos. $statusTone $tableTone';
    }

    if (round == 18) {
      return 'CLIMA DA TEMPORADA — Meio de campanha: a posição atual começa a pesar na leitura do trabalho. $expectationTone $legacyTone';
    }

    if (round == 24) {
      return 'CLIMA DA TEMPORADA — A temporada entra em fase de cobrança. $statusTone $tableTone';
    }

    if (round == 30) {
      return 'CLIMA DA TEMPORADA — Reta final: cada resultado agora muda a narrativa do ano. $tableTone $expectationTone';
    }

    return null;
  }

  // ================================
  // DEPARTMENT
  // ================================
  void _generateDepartmentMessagesForRound(int roundJustFinished) {
    if (!_shouldTriggerDepartmentMessages(roundJustFinished)) return;

    final sorted = table.getSorted();
    final totalTeams = sorted.isEmpty ? 20 : sorted.length;
    final userPosition = _getUserPosition() ?? 10;

    final message = _departmentMessageService.generateFromStructures(
      rng: _rng,
      structures: _userClubStructures,
      financeHealth: userFinanceHealth,
      winStreak: userWinStreak,
      drawStreak: userDrawStreak,
      loseStreak: userLoseStreak,
      tablePosition: userPosition,
      totalTeams: totalTeams,
      divisionId: divisionId,
    );

    _departmentMessages.insert(0, message);
  }

  bool _shouldTriggerDepartmentMessages(int round) {
    switch (round) {
      case 5:
      case 13:
      case 21:
      case 29:
      case 35:
        return true;
      default:
        return false;
    }
  }

  // ================================
  // HELPERS
  // ================================
  int? _getUserPosition() {
    final sorted = table.getSorted();
    if (sorted.isEmpty) return null;

    final idx = sorted.indexWhere((e) => e.clubId == userClubId);
    if (idx < 0) return null;

    return idx + 1;
  }

  String _pickNarrativeLine(List<String> options, {int salt = 0}) {
    if (options.isEmpty) return '';

    final seed = userClubName.hashCode ^
        roundIndex ^
        (userWinStreak << 2) ^
        (userLoseStreak << 4) ^
        (userDrawStreak << 6) ^
        salt;

    final index = seed.abs() % options.length;
    return options[index];
  }

  String _clubStatusToneForNarrative() {
    final status = userClubStatus;

    switch (status.currentTier) {
      case ClubStatusTier.tiny:
        return 'O $userClubName ainda é tratado como projeto pequeno, então cada ponto ajuda a construir respeito.';
      case ClubStatusTier.small:
        return 'O $userClubName vive fase de crescimento e começa a transformar competitividade em expectativa.';
      case ClubStatusTier.medium:
        return 'O $userClubName já é visto como clube consolidado, com cobrança por evolução real.';
      case ClubStatusTier.big:
        return 'O $userClubName já é tratado como força nacional, e campanhas comuns começam a parecer pouco.';
      case ClubStatusTier.giant:
        return 'O $userClubName carrega status de gigante, então qualquer oscilação vira cobrança imediata.';
    }
  }

  String _tableToneForNarrative({
    required int position,
    required int totalTeams,
  }) {
    final dangerZone = position >= totalTeams - 3;
    final lowerZone = position >= totalTeams - 6;
    final tier = userClubStatusTier;

    if (position == 1) {
      if (tier == ClubStatusTier.giant || tier == ClubStatusTier.big) {
        return 'a liderança confirma o protagonismo esperado.';
      }

      return 'a liderança transforma a campanha em assunto nacional.';
    }

    if (position <= 4) {
      if (tier == ClubStatusTier.tiny || tier == ClubStatusTier.small) {
        return 'a presença no G4 muda o tamanho emocional da temporada.';
      }

      if (tier == ClubStatusTier.giant) {
        return 'a presença no G4 mantém o clube dentro da obrigação mínima de protagonismo.';
      }

      return 'a presença no G4 aumenta ambição, expectativa e cobrança.';
    }

    if (position <= 8) {
      if (tier == ClubStatusTier.tiny || tier == ClubStatusTier.small) {
        return 'a campanha mantém o clube competitivo e alimenta sensação de crescimento.';
      }

      if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
        return 'a posição competitiva ainda não elimina a cobrança por algo maior.';
      }

      return 'a campanha mantém o clube competitivo e ainda com margem para sonhar.';
    }

    if (position <= 12) {
      if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
        return 'a tabela mostra uma campanha comum demais para o peso atual do clube.';
      }

      return 'a tabela mostra equilíbrio, mas ainda sem uma narrativa forte de afirmação.';
    }

    if (dangerZone) {
      if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
        return 'a zona de risco é tratada como crise pesada para o tamanho atual do clube.';
      }

      return 'a zona de risco pressiona o ambiente e deixa pouca margem para erro.';
    }

    if (lowerZone) {
      if (tier == ClubStatusTier.tiny || tier == ClubStatusTier.small) {
        return 'a proximidade da parte baixa preocupa, mas ainda é lida como parte do processo de crescimento.';
      }

      return 'a proximidade da parte baixa deixa o ambiente instável.';
    }

    return 'a campanha ainda pede cuidado para não transformar oscilação em crise.';
  }

  String _expectationToneForNarrative(int? delta) {
    final tier = userClubStatusTier;

    if (delta == null) {
      return 'A expectativa ainda não tem leitura clara contra a campanha atual.';
    }

    if (delta >= 4) {
      if (tier == ClubStatusTier.tiny || tier == ClubStatusTier.small) {
        return 'O rendimento está muito acima do plano inicial e já muda a forma como o clube é visto.';
      }

      return 'O rendimento está muito acima do plano inicial e muda o tamanho da temporada.';
    }

    if (delta >= 2) {
      return 'O clube entrega acima do esperado e começa a ganhar respeito.';
    }

    if (delta <= -4) {
      if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
        return 'O desempenho está muito abaixo do esperado e transforma cobrança em crise.';
      }

      return 'O desempenho está bem abaixo do esperado e aumenta a pressão interna.';
    }

    if (delta <= -2) {
      return 'A campanha ainda está abaixo da expectativa e exige resposta.';
    }

    return 'O desempenho segue próximo do que foi projetado pela diretoria.';
  }

  String _legacyToneForNarrative() {
    final seasons = userLegacySeasons;

    if (seasons <= 0) {
      return 'Como ainda não existe legado acumulado, cada sequência ajuda a definir a primeira imagem do projeto.';
    }

    final points = userLegacyPoints;

    if (points >= 35) {
      return 'O legado recente dá confiança, mas também aumenta o padrão de cobrança.';
    }

    if (points >= 12) {
      return 'A memória positiva da passagem sustenta o ambiente mesmo nos momentos de oscilação.';
    }

    if (points >= 0) {
      return 'A passagem ainda busca uma marca mais forte para ser lembrada pela torcida.';
    }

    return 'O histórico recente aumenta a cobrança e reduz a paciência com tropeços.';
  }
}
