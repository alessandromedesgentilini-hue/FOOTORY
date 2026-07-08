import 'package:flutter/material.dart';

import 'package:footory26/models/staff_department.dart';
import 'package:footory26/pages/messages/models/game_message.dart';
import 'package:footory26/pages/messages/services/message_news_classifier.dart';

class GameMessageService {
  final MessageNewsClassifier _classifier;

  const GameMessageService({
    MessageNewsClassifier classifier = const MessageNewsClassifier(),
  }) : _classifier = classifier;

  List<GameMessage> buildMessages({
    required List<String> newsFeed,
    required List<DepartmentMessage> departmentMessages,
    required Set<String> readMessageIds,
    Map<String, GameMessageCategory> newsCategoryByText =
        const <String, GameMessageCategory>{},
  }) {
    final messages = <GameMessage>[];

    for (int i = 0; i < newsFeed.length; i++) {
      final raw = newsFeed[i].trim();
      if (raw.isEmpty) continue;

      final entry = _classifier.buildEntry(raw);

      final category = newsCategoryByText[raw] ?? _categoryFromTone(entry.tone);

      final importance = _importanceFromText(raw, category);
      final id = buildNewsId(raw);

      messages.add(
        GameMessage(
          id: id,
          title: _titleForCategory(category, fallback: entry.title),
          body: entry.text,
          tag: _tagForCategory(category, fallback: entry.tagLabel),
          category: category,
          importance: importance,
          source: GameMessageSource.newsFeed,
          createdAt: _fakeDateFromIndex(i),
          isRead: readMessageIds.contains(id),
          icon: _iconForCategory(category),
        ),
      );
    }

    for (int i = 0; i < departmentMessages.length; i++) {
      final message = departmentMessages[i];
      final id = buildDepartmentId(message, i);
      final importance = _importanceFromDepartmentMessage(message);

      messages.add(
        GameMessage(
          id: id,
          title: message.displayTitle,
          body: message.text,
          tag: message.displayTag,
          category: GameMessageCategory.department,
          importance: importance,
          source: GameMessageSource.department,
          createdAt: _fakeDateFromIndex(newsFeed.length + i),
          isRead: readMessageIds.contains(id),
          icon: Icons.badge_outlined,
        ),
      );
    }

    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return messages;
  }

  List<GameMessageBucket> buildBuckets(List<GameMessage> messages) {
    return [
      _bucket(
        messages: messages,
        category: GameMessageCategory.match,
        title: 'Resumo da Partida',
        subtitle: 'Resumos, gols e acontecimentos.',
        icon: Icons.sports_soccer_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.market,
        title: 'Mercado do Clube',
        subtitle: 'Propostas, vendas e negociações.',
        icon: Icons.swap_horiz_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.transfer,
        title: 'Transferências',
        subtitle: 'Contratações, vendas e empréstimos.',
        icon: Icons.compare_arrows_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.scout,
        title: 'Scout',
        subtitle: 'Observações, listas e oportunidades.',
        icon: Icons.visibility_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.world,
        title: 'Notícias do Mundo',
        subtitle: 'Transferências e acontecimentos externos.',
        icon: Icons.public_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.competition,
        title: 'Competições',
        subtitle: 'Copas, continentais e torneios mundiais.',
        icon: Icons.emoji_events_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.finance,
        title: 'Financeiro',
        subtitle: 'Receitas, custos e saúde do clube.',
        icon: Icons.account_balance_wallet_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.training,
        title: 'CT / Evolução',
        subtitle: 'Treinamentos e evolução.',
        icon: Icons.fitness_center_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.board,
        title: 'Diretoria',
        subtitle: 'Expectativas, cobrança e comunicados.',
        icon: Icons.business_center_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.legacy,
        title: 'Legado',
        subtitle: 'Memória do clube e reputação do trabalho.',
        icon: Icons.history_edu_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.club,
        title: 'Clube',
        subtitle: 'Ambiente, torcida e bastidores internos.',
        icon: Icons.shield_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.season,
        title: 'Temporada',
        subtitle: 'Campanha, tabela e análise do ano.',
        icon: Icons.insights_rounded,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.department,
        title: 'Departamentos',
        subtitle: 'Atualizações internas.',
        icon: Icons.badge_outlined,
      ),
      _bucket(
        messages: messages,
        category: GameMessageCategory.system,
        title: 'Sistema',
        subtitle: 'Avisos técnicos e registros do save.',
        icon: Icons.settings_rounded,
      ),
    ].where((bucket) => bucket.messages.isNotEmpty).toList();
  }

  List<GameMessage> buildImportantMessages(List<GameMessage> messages) {
    return messages.where((m) => m.needsAttention).toList();
  }

  int unreadTotal(List<GameMessage> messages) {
    return messages.where((m) => !m.isRead).length;
  }

  int criticalTotal(List<GameMessage> messages) {
    return messages
        .where((m) => m.importance == GameMessageImportance.critical)
        .length;
  }

  int importantTotal(List<GameMessage> messages) {
    return messages
        .where((m) => m.importance == GameMessageImportance.important)
        .length;
  }

  String buildNewsId(String text) {
    return 'news_${text.hashCode}';
  }

  String buildDepartmentId(DepartmentMessage message, int index) {
    return 'dept_${message.text.hashCode}_$index';
  }

  GameMessageBucket _bucket({
    required List<GameMessage> messages,
    required GameMessageCategory category,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final filtered = messages.where((m) => m.category == category).toList();

    return GameMessageBucket(
      category: category,
      title: title,
      subtitle: subtitle,
      icon: icon,
      messages: filtered,
    );
  }

  GameMessageCategory _categoryFromTone(dynamic tone) {
    final toneName = tone.toString();

    if (toneName.contains('match')) return GameMessageCategory.match;
    if (toneName.contains('market')) return GameMessageCategory.market;
    if (toneName.contains('world')) return GameMessageCategory.world;
    if (toneName.contains('finance')) return GameMessageCategory.finance;
    if (toneName.contains('warning')) return GameMessageCategory.finance;
    if (toneName.contains('training')) return GameMessageCategory.training;
    if (toneName.contains('season')) return GameMessageCategory.season;
    if (toneName.contains('analysis')) return GameMessageCategory.season;

    return GameMessageCategory.season;
  }

  String _titleForCategory(
    GameMessageCategory category, {
    required String fallback,
  }) {
    switch (category) {
      case GameMessageCategory.match:
        return 'Resumo da Partida';
      case GameMessageCategory.market:
        return 'Mercado do Clube';
      case GameMessageCategory.transfer:
        return 'Transferências';
      case GameMessageCategory.scout:
        return 'Scout';
      case GameMessageCategory.world:
        return 'Notícias do Mundo';
      case GameMessageCategory.competition:
        return 'Competições';
      case GameMessageCategory.finance:
        return 'Financeiro';
      case GameMessageCategory.training:
        return 'CT / Evolução';
      case GameMessageCategory.season:
        return 'Temporada';
      case GameMessageCategory.department:
        return 'Departamentos';
      case GameMessageCategory.legacy:
        return 'Legado';
      case GameMessageCategory.board:
        return 'Diretoria';
      case GameMessageCategory.club:
        return 'Clube';
      case GameMessageCategory.system:
        return 'Sistema';
    }
  }

  String _tagForCategory(
    GameMessageCategory category, {
    required String fallback,
  }) {
    switch (category) {
      case GameMessageCategory.match:
        return 'Partida';
      case GameMessageCategory.market:
        return 'Mercado';
      case GameMessageCategory.transfer:
        return 'Transferência';
      case GameMessageCategory.scout:
        return 'Scout';
      case GameMessageCategory.world:
        return 'Mundo';
      case GameMessageCategory.competition:
        return 'Competição';
      case GameMessageCategory.finance:
        return 'Financeiro';
      case GameMessageCategory.training:
        return 'CT';
      case GameMessageCategory.season:
        return 'Temporada';
      case GameMessageCategory.department:
        return 'Departamento';
      case GameMessageCategory.legacy:
        return 'Legado';
      case GameMessageCategory.board:
        return 'Diretoria';
      case GameMessageCategory.club:
        return 'Clube';
      case GameMessageCategory.system:
        return 'Sistema';
    }
  }

  GameMessageImportance _importanceFromDepartmentMessage(
    DepartmentMessage message,
  ) {
    final lower = '${message.displayTitle} ${message.text}'.toLowerCase();

    if (_containsAny(lower, const [
      'crise',
      'colapso',
      'urgente',
      'grave',
      'crítico',
      'critico',
      'demissão',
      'demissao',
    ])) {
      return GameMessageImportance.critical;
    }

    if (_containsAny(lower, const [
      'atenção',
      'atencao',
      'importante',
      'alerta',
      'diretoria',
      'objetivo',
    ])) {
      return GameMessageImportance.important;
    }

    return GameMessageImportance.relevant;
  }

  GameMessageImportance _importanceFromText(
    String text,
    GameMessageCategory category,
  ) {
    final lower = text.toLowerCase();

    if (_containsAny(lower, const [
      'crise absoluta',
      'colapso',
      'demissão',
      'demissao',
      'rebaixado',
      'rebaixamento confirmado',
      'caixa no vermelho',
      'fluxo operacional no vermelho',
      'crítico',
      'critico',
      'atenção imediata',
      'atencao imediata',
      'lesão grave',
      'lesao grave',
    ])) {
      return GameMessageImportance.critical;
    }

    if (_containsAny(lower, const [
      'oportunidade de mercado',
      'título',
      'titulo',
      'campeão',
      'campeao',
      'acesso confirmado',
      'classificação histórica',
      'classificacao historica',
      'proposta',
      'venda concluída',
      'venda concluida',
      'negociação avançou',
      'negociacao avancou',
      'alerta financeiro',
      'caixa apertado',
      'fluxo operacional apertado',
      'objetivo da diretoria',
      'briefing da diretoria',
    ])) {
      return GameMessageImportance.important;
    }

    if (category == GameMessageCategory.finance ||
        category == GameMessageCategory.market ||
        category == GameMessageCategory.transfer ||
        category == GameMessageCategory.scout ||
        category == GameMessageCategory.season ||
        category == GameMessageCategory.competition ||
        category == GameMessageCategory.board ||
        category == GameMessageCategory.legacy ||
        category == GameMessageCategory.department) {
      return GameMessageImportance.relevant;
    }

    return GameMessageImportance.info;
  }

  IconData _iconForCategory(GameMessageCategory category) {
    switch (category) {
      case GameMessageCategory.match:
        return Icons.sports_soccer_rounded;
      case GameMessageCategory.market:
        return Icons.swap_horiz_rounded;
      case GameMessageCategory.transfer:
        return Icons.compare_arrows_rounded;
      case GameMessageCategory.scout:
        return Icons.visibility_rounded;
      case GameMessageCategory.world:
        return Icons.public_rounded;
      case GameMessageCategory.competition:
        return Icons.emoji_events_rounded;
      case GameMessageCategory.finance:
        return Icons.account_balance_wallet_rounded;
      case GameMessageCategory.training:
        return Icons.fitness_center_rounded;
      case GameMessageCategory.season:
        return Icons.insights_rounded;
      case GameMessageCategory.department:
        return Icons.badge_outlined;
      case GameMessageCategory.legacy:
        return Icons.history_edu_rounded;
      case GameMessageCategory.board:
        return Icons.business_center_rounded;
      case GameMessageCategory.club:
        return Icons.shield_rounded;
      case GameMessageCategory.system:
        return Icons.settings_rounded;
    }
  }

  DateTime _fakeDateFromIndex(int index) {
    final now = DateTime.now();
    return now.subtract(Duration(minutes: index));
  }

  bool _containsAny(String text, List<String> terms) {
    for (final term in terms) {
      if (text.contains(term)) return true;
    }
    return false;
  }
}
