import 'package:footory26/pages/messages/models/message_news_models.dart';

class MessageNewsClassifier {
  const MessageNewsClassifier();

  MessageNewsBuckets splitNews(List<String> news) {
    final matchSummaries = <MessageNewsEntry>[];
    final market = <MessageNewsEntry>[];
    final world = <MessageNewsEntry>[];
    final finance = <MessageNewsEntry>[];
    final training = <MessageNewsEntry>[];
    final season = <MessageNewsEntry>[];

    for (final raw in news) {
      final text = raw.trim();
      if (text.isEmpty) continue;

      final entry = buildEntry(text);

      switch (entry.tone) {
        case MessageNewsTone.match:
          matchSummaries.add(entry);
          break;
        case MessageNewsTone.world:
          world.add(entry);
          break;
        case MessageNewsTone.market:
          market.add(entry);
          break;
        case MessageNewsTone.finance:
        case MessageNewsTone.warning:
          finance.add(entry);
          break;
        case MessageNewsTone.training:
          training.add(entry);
          break;
        case MessageNewsTone.season:
        case MessageNewsTone.analysis:
          season.add(entry);
          break;
      }
    }

    return MessageNewsBuckets(
      matchSummaries: matchSummaries,
      market: market,
      world: world,
      finance: finance,
      training: training,
      season: season,
    );
  }

  MessageNewsEntry buildEntry(String text) {
    final priority = classifyPriority(text);

    if (isSeasonEmotionMessage(text)) {
      return MessageNewsEntry(
        title: 'Temporada e Ambiente',
        tagLabel: 'Temporada',
        text: text,
        tone: MessageNewsTone.analysis,
        priority: priority,
      );
    }

    if (isBrazilCupUserResultMessage(text)) {
      return MessageNewsEntry(
        title: 'Copa Brasileira',
        tagLabel: 'Copa',
        text: text,
        tone: MessageNewsTone.match,
        priority: priority,
      );
    }

    if (isBrazilCupMessage(text)) {
      return MessageNewsEntry(
        title: 'Copa Brasileira',
        tagLabel: 'Copa',
        text: text,
        tone: MessageNewsTone.season,
        priority: priority,
      );
    }

    if (isWorldNewsMessage(text)) {
      return MessageNewsEntry(
        title: 'Notícias do Mundo',
        tagLabel: 'Mundo',
        text: text,
        tone: MessageNewsTone.world,
        priority: priority,
      );
    }

    if (isTrainingMessage(text)) {
      return MessageNewsEntry(
        title: 'Relatório do CT',
        tagLabel: 'CT',
        text: text,
        tone: MessageNewsTone.training,
        priority: priority,
      );
    }

    if (isMatchSummary(text)) {
      return MessageNewsEntry(
        title: 'Partidas',
        tagLabel: 'Partida',
        text: text,
        tone: MessageNewsTone.match,
        priority: priority,
      );
    }

    if (isMarketMessage(text)) {
      return MessageNewsEntry(
        title: 'Mercado do Clube',
        tagLabel: 'Mercado',
        text: text,
        tone: MessageNewsTone.market,
        priority: priority,
      );
    }

    if (isFinanceMessage(text)) {
      final warning = isWarningFinanceMessage(text);

      return MessageNewsEntry(
        title: warning ? 'Alerta Financeiro' : 'Relatório Financeiro',
        tagLabel: 'Financeiro',
        text: text,
        tone: warning ? MessageNewsTone.warning : MessageNewsTone.finance,
        priority: warning ? MessageNewsPriority.critical : priority,
      );
    }

    return MessageNewsEntry(
      title: 'Temporada e Diretoria',
      tagLabel: 'Temporada',
      text: text,
      tone: MessageNewsTone.season,
      priority: priority,
    );
  }

  MessageNewsPriority classifyPriority(String text) {
    final lower = text.toLowerCase();

    if (_containsAny(lower, const [
      'crise absoluta',
      'colapso',
      'demissão',
      'demissao',
      'caixa no vermelho',
      'fluxo operacional no vermelho',
      'fluxo operacional zerado',
      'rebaixamento confirmado',
      'foi rebaixado',
      'temporada crítica',
      'temporada critica',
      'campanha crítica',
      'campanha critica',
      'atenção imediata',
      'atencao imediata',
      'lesão grave',
      'lesao grave',
      'crítico',
      'critico',
    ])) {
      return MessageNewsPriority.critical;
    }

    if (_containsAny(lower, const [
      'oportunidade de mercado',
      'proposta',
      'venda concluída',
      'venda concluida',
      'negociação avançou',
      'negociacao avancou',
      'contratação concluída',
      'contratacao concluida',
      'empréstimo concluído',
      'emprestimo concluido',
      'título',
      'titulo',
      'campeão',
      'campeao',
      'acesso confirmado',
      'classificação histórica',
      'classificacao historica',
      'temporada histórica',
      'temporada historica',
      'temporada lendária',
      'temporada lendaria',
      'campanha histórica',
      'campanha historica',
      'campanha lendária',
      'campanha lendaria',
      'briefing da diretoria',
      'objetivo da diretoria',
      'alerta financeiro',
      'caixa apertado',
      'fluxo operacional apertado',
      'pressão forte',
      'pressao forte',
      'pressão crescente',
      'pressao crescente',
    ])) {
      return MessageNewsPriority.high;
    }

    if (_containsAny(lower, const [
      'bilheteria',
      'patrocínio',
      'patrocinio',
      'receita mensal',
      'receita operacional',
      'treino',
      'treinamentos',
      'ct —',
      'relatório do ct',
      'relatorio do ct',
      'giro da rodada',
      'notícias do mundo',
      'noticia do mundo',
    ])) {
      return MessageNewsPriority.low;
    }

    return MessageNewsPriority.normal;
  }

  bool isSeasonEmotionMessage(String text) {
    final lower = text.toLowerCase();

    const prefixes = <String>[
      'temporada —',
      'temporada histórica',
      'temporada lendária',
      'temporada marcante',
      'temporada positiva',
      'temporada neutra',
      'temporada de alerta',
      'temporada frustrante',
      'temporada crítica',
      'temporada dura',
      'temporada dolorosa',
      'memória do clube',
      'legado —',
      'clima da temporada',
      'atmosfera —',
      'torcida —',
      'diretoria —',
      'imprensa —',
      'virada de temporada',
      'fim de temporada',
      'relatório da temporada',
      'briefing da diretoria',
      'nova temporada',
      'contexto —',
    ];

    for (final prefix in prefixes) {
      if (lower.startsWith(prefix)) return true;
    }

    const indicators = <String>[
      'peso histórico',
      'memória acumulada',
      'reputação',
      'status atual',
      'confiança muito alta',
      'confiança alta',
      'confiança moderada',
      'confiança neutra',
      'pressão crescente',
      'pressão forte',
      'contexto histórico',
      'campanha histórica',
      'campanha lendária',
      'campanha frustrante',
      'campanha crítica',
      'campanha de sobrevivência',
      'projeto esportivo',
      'ambiente interno',
      'torcida termina',
      'torcida respira',
      'a imprensa',
      'a diretoria',
    ];

    for (final indicator in indicators) {
      if (lower.contains(indicator)) return true;
    }

    return false;
  }

  bool isBrazilCupUserResultMessage(String text) {
    final lower = text.toLowerCase();

    if (!lower.contains('copa brasileira') &&
        !lower.contains('copa do brasil') &&
        !lower.contains('copa nacional')) {
      return false;
    }

    if (lower.contains('notícias do mundo')) return false;
    if (lower.contains('noticia do mundo')) return false;
    if (lower.contains('resultados da')) return false;
    if (lower.contains('classificados:')) return false;
    if (lower.contains('campeão definido')) return false;

    return lower.contains('é campeão') ||
        lower.contains('ficou com o vice-campeonato') ||
        lower.contains('avançou na') ||
        lower.contains('foi eliminado na');
  }

  bool isBrazilCupMessage(String text) {
    final lower = text.toLowerCase();

    const indicators = <String>[
      'copa brasileira',
      'copa do brasil',
      'copa nacional',
      'sorteio da copa',
      'primeira fase foi sorteada',
      'fase 2 foi sorteada',
      'mata-mata',
      'confrontos de ida e volta',
      'quartas de final',
      'semifinal',
      'final da copa',
    ];

    for (final indicator in indicators) {
      if (lower.contains(indicator)) return true;
    }

    return false;
  }

  bool isWorldNewsMessage(String text) {
    final lower = text.toLowerCase();

    if (_looksLikeUserClubMarketMessage(lower)) {
      return false;
    }

    const strongIndicators = <String>[
      'notícias do mundo',
      'noticia do mundo',
      'mercado da bola',
      'notícias do futebol',
      'noticia do futebol',
      'mundo do futebol',
      'janela nacional',
      'giro da rodada',
      'giro do mercado',
      'bastidores do futebol',
      'janela da cpu',
      'clubes movimentaram',
      'movimentação dos clubes',
      'movimentações externas',
      'campeão definido',
      'sagrou-se campeão',
      'levantou a taça nacional',
    ];

    for (final indicator in strongIndicators) {
      if (lower.contains(indicator)) return true;
    }

    return false;
  }

  bool _looksLikeUserClubMarketMessage(String lower) {
    const userMarketIndicators = <String>[
      'venda concluída',
      'proposta',
      'recusou a transferência',
      'oportunidade de mercado',
      'negociação concluída',
      'negociação frustrada',
      'departamento financeiro fechou a operação',
      'livre no mercado',
      'por empréstimo',
      'lista de observação',
      'salário mensal',
      'valor de mercado',
      'luvas',
      'contratação concluída',
      'empréstimo concluído',
      'negociação avançou',
    ];

    for (final indicator in userMarketIndicators) {
      if (lower.contains(indicator)) return true;
    }

    return false;
  }

  bool isMarketMessage(String text) {
    final lower = text.toLowerCase();

    if (isWorldNewsMessage(text)) return false;

    const indicators = <String>[
      'negociação concluída',
      'negociação frustrada',
      'proposta',
      'transferência',
      'livre no mercado',
      'por empréstimo',
      'venda concluída',
      'recusou a transferência',
      'oportunidade de mercado',
      'lista de observação',
      'luvas',
      'salário mensal',
      'valor de mercado',
      'departamento financeiro fechou a operação',
      'negociação avançou',
      'contratação concluída',
      'empréstimo concluído',
    ];

    for (final indicator in indicators) {
      if (lower.contains(indicator)) return true;
    }

    return false;
  }

  bool isFinanceMessage(String text) {
    final lower = text.toLowerCase();

    const indicators = <String>[
      'finanças',
      'financeiro',
      'caixa no vermelho',
      'caixa apertado',
      'caixa livre',
      'caixa disponível',
      'fluxo de caixa',
      'fluxo operacional',
      'empréstimo operacional',
      'crédito emergencial',
      'saúde financeira',
      'custos fixos',
      'folha salarial',
      'manutenção estrutural',
      'bilheteria',
      'patrocínio',
      'dívida',
      'dívidas',
      'quitação de dívidas',
      'abatimento da dívida',
      'repasse',
      'receita operacional',
      'receita mensal',
    ];

    for (final indicator in indicators) {
      if (lower.contains(indicator)) return true;
    }

    return false;
  }

  bool isWarningFinanceMessage(String text) {
    final lower = text.toLowerCase();

    return lower.contains('caixa no vermelho') ||
        lower.contains('fluxo operacional no vermelho') ||
        lower.contains('fluxo operacional zerado') ||
        lower.contains('empréstimo operacional') ||
        lower.contains('crédito emergencial') ||
        lower.contains('colapso') ||
        lower.contains('crítico') ||
        lower.contains('atenção imediata') ||
        lower.contains('caixa apertado') ||
        lower.contains('fluxo operacional apertado');
  }

  bool isTrainingMessage(String text) {
    final lower = text.toLowerCase();

    const indicators = <String>[
      'ct —',
      'relatório do ct',
      'treinamentos',
      'evolução',
      'boa evolução',
      'período (+1)',
      'treino',
      'centro de treinamento',
    ];

    for (final indicator in indicators) {
      if (lower.contains(indicator)) return true;
    }

    return false;
  }

  bool isMatchSummary(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('notícias do mundo')) return false;
    if (lower.contains('noticia do mundo')) return false;

    if (isSeasonEmotionMessage(text)) return false;

    final hasScore = RegExp(r'\d+\s*x\s*\d+').hasMatch(lower);
    if (hasScore) return true;

    const matchIndicators = <String>[
      'marcou para',
      'marcaram os gols',
      'marcou o gol',
      'gols do',
      'destaque do jogo',
      'venceu',
      'vitória',
      'derrota',
      'empate',
      'fora de casa',
      'diante da torcida',
      'resultado importante',
      'placar',
    ];

    for (final indicator in matchIndicators) {
      if (lower.contains(indicator)) return true;
    }

    return false;
  }

  bool _containsAny(String text, List<String> terms) {
    for (final term in terms) {
      if (text.contains(term)) return true;
    }
    return false;
  }
}
