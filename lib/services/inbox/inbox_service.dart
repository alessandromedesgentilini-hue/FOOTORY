// lib/services/inbox/inbox_service.dart
//
// Caixa de Entrada MVP (em memória).
// Depois a gente pluga no teu save (GameState) se quiser.

import 'package:flutter/foundation.dart';

enum InboxKind { info, warning, critical }

class InboxMessage {
  final String title;
  final String body;
  final InboxKind kind;
  final DateTime createdAt;

  InboxMessage({
    required this.title,
    required this.body,
    this.kind = InboxKind.info,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class InboxService {
  InboxService._();
  static final InboxService I = InboxService._();

  final List<InboxMessage> _items = [];

  List<InboxMessage> get items => List.unmodifiable(_items);

  void push(InboxMessage msg) {
    _items.insert(0, msg);
    debugPrint('[Inbox] + ${msg.title}');
  }

  void clear() {
    _items.clear();
  }
}
