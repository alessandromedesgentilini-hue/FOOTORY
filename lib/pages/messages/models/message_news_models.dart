import 'package:flutter/material.dart';

class MessageNewsBuckets {
  final List<MessageNewsEntry> matchSummaries;
  final List<MessageNewsEntry> market;
  final List<MessageNewsEntry> world;
  final List<MessageNewsEntry> finance;
  final List<MessageNewsEntry> training;
  final List<MessageNewsEntry> season;

  const MessageNewsBuckets({
    required this.matchSummaries,
    required this.market,
    required this.world,
    required this.finance,
    required this.training,
    required this.season,
  });

  int get totalNews =>
      matchSummaries.length +
      market.length +
      world.length +
      finance.length +
      training.length +
      season.length;
}

class MessageNewsEntry {
  final String title;
  final String tagLabel;
  final String text;
  final MessageNewsTone tone;
  final MessageNewsPriority priority;

  const MessageNewsEntry({
    required this.title,
    required this.tagLabel,
    required this.text,
    required this.tone,
    this.priority = MessageNewsPriority.normal,
  });

  bool get isImportant =>
      priority == MessageNewsPriority.high ||
      priority == MessageNewsPriority.critical;

  bool get isCritical => priority == MessageNewsPriority.critical;

  String get priorityLabel {
    switch (priority) {
      case MessageNewsPriority.low:
        return 'Informativo';
      case MessageNewsPriority.normal:
        return 'Atualização';
      case MessageNewsPriority.high:
        return 'Importante';
      case MessageNewsPriority.critical:
        return 'Crítico';
    }
  }
}

enum MessageNewsPriority {
  low,
  normal,
  high,
  critical,
}

enum MessageNewsTone {
  match,
  analysis,
  market,
  world,
  warning,
  training,
  finance,
  season,
}

class MessageNewsToneStyle {
  final Color background;
  final Color border;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;
  final Color tagColor;
  final IconData icon;

  const MessageNewsToneStyle({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.iconColor,
    required this.titleColor,
    required this.tagColor,
    required this.icon,
  });
}
