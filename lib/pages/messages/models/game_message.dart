import 'package:flutter/material.dart';

enum GameMessageCategory {
  match,
  market,
  world,
  finance,
  training,
  season,
  department,
  competition,
  legacy,
  board,
  scout,
  transfer,
  club,
  system,
}

enum GameMessageImportance {
  info,
  relevant,
  important,
  critical,
}

enum GameMessageSource {
  newsFeed,
  department,
  system,
}

class GameMessage {
  final String id;
  final String title;
  final String body;
  final String tag;
  final GameMessageCategory category;
  final GameMessageImportance importance;
  final GameMessageSource source;
  final DateTime createdAt;
  final bool isRead;
  final IconData icon;

  const GameMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.category,
    required this.importance,
    required this.source,
    required this.createdAt,
    required this.isRead,
    required this.icon,
  });

  GameMessage copyWith({
    String? id,
    String? title,
    String? body,
    String? tag,
    GameMessageCategory? category,
    GameMessageImportance? importance,
    GameMessageSource? source,
    DateTime? createdAt,
    bool? isRead,
    IconData? icon,
  }) {
    return GameMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tag: tag ?? this.tag,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
    );
  }

  bool get isCritical => importance == GameMessageImportance.critical;

  bool get isImportant =>
      importance == GameMessageImportance.important ||
      importance == GameMessageImportance.critical;

  bool get needsAttention => isImportant;

  String get categoryLabel {
    switch (category) {
      case GameMessageCategory.match:
        return 'Partida';
      case GameMessageCategory.market:
        return 'Mercado';
      case GameMessageCategory.world:
        return 'Mundo';
      case GameMessageCategory.finance:
        return 'Financeiro';
      case GameMessageCategory.training:
        return 'CT';
      case GameMessageCategory.season:
        return 'Temporada';
      case GameMessageCategory.department:
        return 'Departamento';
      case GameMessageCategory.competition:
        return 'Competições';
      case GameMessageCategory.legacy:
        return 'Legado';
      case GameMessageCategory.board:
        return 'Diretoria';
      case GameMessageCategory.scout:
        return 'Scout';
      case GameMessageCategory.transfer:
        return 'Transferências';
      case GameMessageCategory.club:
        return 'Clube';
      case GameMessageCategory.system:
        return 'Sistema';
    }
  }

  String get importanceLabel {
    switch (importance) {
      case GameMessageImportance.info:
        return 'Informação';
      case GameMessageImportance.relevant:
        return 'Relevante';
      case GameMessageImportance.important:
        return 'Importante';
      case GameMessageImportance.critical:
        return 'Crítico';
    }
  }

  static GameMessageCategory categoryFromString(
    String? value, {
    GameMessageCategory fallback = GameMessageCategory.season,
  }) {
    switch ((value ?? '').trim()) {
      case 'match':
        return GameMessageCategory.match;
      case 'market':
        return GameMessageCategory.market;
      case 'world':
        return GameMessageCategory.world;
      case 'finance':
        return GameMessageCategory.finance;
      case 'training':
        return GameMessageCategory.training;
      case 'season':
        return GameMessageCategory.season;
      case 'department':
        return GameMessageCategory.department;
      case 'competition':
        return GameMessageCategory.competition;
      case 'legacy':
        return GameMessageCategory.legacy;
      case 'board':
        return GameMessageCategory.board;
      case 'scout':
        return GameMessageCategory.scout;
      case 'transfer':
        return GameMessageCategory.transfer;
      case 'club':
        return GameMessageCategory.club;
      case 'system':
        return GameMessageCategory.system;
      default:
        return fallback;
    }
  }
}

class GameMessageBucket {
  final GameMessageCategory category;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<GameMessage> messages;

  const GameMessageBucket({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.messages,
  });

  int get total => messages.length;

  int get unreadCount => messages.where((m) => !m.isRead).length;

  int get importantCount => messages.where((m) => m.needsAttention).length;

  bool get hasUnread => unreadCount > 0;

  bool get hasImportant => importantCount > 0;
}
