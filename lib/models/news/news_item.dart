// lib/models/news_item.dart
//
// NewsItem (MVP) — item simples de feed de notícias (imprensa/torcida)
// - pensado pra UI depois (aba "News" / rede social)
// - serializável (save/load)

enum NewsType {
  match,
  transfer,
  info,
}

class NewsItem {
  final String id;
  final NewsType type;

  final String title;
  final String body;

  /// Timestamp (ms) — mais fácil de serializar
  final int createdAtMs;

  /// Opcional: a notícia pode estar ligada ao seu clube
  final String? clubId;

  /// Opcional: metadados livres (rodada, placar etc)
  final Map<String, dynamic> meta;

  const NewsItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAtMs,
    this.clubId,
    this.meta = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'createdAtMs': createdAtMs,
        'clubId': clubId,
        'meta': meta,
      };

  factory NewsItem.fromJson(Map<String, dynamic> m) {
    NewsType parseType(Object? v) {
      final s = (v ?? '').toString().toLowerCase().trim();
      for (final t in NewsType.values) {
        if (t.name == s) return t;
      }
      return NewsType.info;
    }

    Map<String, dynamic> safeMeta(Object? v) {
      if (v is Map) {
        return v.map((k, vv) => MapEntry(k.toString(), vv));
      }
      return <String, dynamic>{};
    }

    return NewsItem(
      id: (m['id'] ?? '').toString(),
      type: parseType(m['type']),
      title: (m['title'] ?? '').toString(),
      body: (m['body'] ?? '').toString(),
      createdAtMs: (m['createdAtMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
      clubId: (m['clubId'] as String?)?.toString(),
      meta: safeMeta(m['meta']),
    );
  }
}
