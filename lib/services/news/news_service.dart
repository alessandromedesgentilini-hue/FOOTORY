// lib/services/news/news_service.dart
//
// NewsService (MVP) — feed simples de notícias.
// - Guarda notícias em memória (lista).
// - Permite filtrar por clube (clubId) ou pegar gerais.
// - ID estável (sem Random) baseado em timestamp + contador.
//
// Observação:
// Este arquivo espera o model em:
//   lib/models/news/news_item.dart

import '../../models/news/news_item.dart';

class NewsService {
  NewsService._();
  static final NewsService I = NewsService._();

  final List<NewsItem> _items = [];
  int _seq = 0;

  // =========================
  // GETTERS
  // =========================

  List<NewsItem> get all => List.unmodifiable(_items);

  /// Últimas N notícias (gerais + do clube), ordenadas por createdAt desc
  List<NewsItem> latest({int limit = 30}) {
    final list = List<NewsItem>.from(_items)
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

    if (list.length <= limit) return List.unmodifiable(list);
    return List.unmodifiable(list.take(limit).toList(growable: false));
  }

  /// Últimas N notícias relacionadas a um clube (inclui gerais se includeGeneric=true)
  List<NewsItem> byClub(
    String clubId, {
    int limit = 30,
    bool includeGeneric = true,
  }) {
    final filtered = _items.where((n) {
      if (n.clubId == clubId) return true;
      if (includeGeneric && n.clubId == null) return true;
      return false;
    }).toList()
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

    if (filtered.length <= limit) return List.unmodifiable(filtered);
    return List.unmodifiable(filtered.take(limit).toList(growable: false));
  }

  // =========================
  // ADD
  // =========================

  NewsItem push({
    required NewsType type,
    required String title,
    required String body,
    String? clubId,
    int? createdAtMs,
  }) {
    final now = createdAtMs ?? DateTime.now().millisecondsSinceEpoch;

    final item = NewsItem(
      id: _genId(type, now),
      clubId: clubId,
      type: type,
      title: title,
      body: body,
      createdAtMs: now,
    );

    _items.add(item);
    _trim();
    return item;
  }

  /// Ajuda rápida pra notícia de partida
  NewsItem pushMatch({
    required String title,
    required String body,
    String? clubId,
    int? createdAtMs,
  }) {
    return push(
      type: NewsType.match,
      title: title,
      body: body,
      clubId: clubId,
      createdAtMs: createdAtMs,
    );
  }

  // =========================
  // MAINTENANCE
  // =========================

  void clear() {
    _items.clear();
    _seq = 0;
  }

  void _trim({int maxItems = 120}) {
    if (_items.length <= maxItems) return;

    // mantém as mais novas
    _items.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    _items.removeRange(maxItems, _items.length);
  }

  String _genId(NewsType type, int ms) {
    _seq++;

    // estável e único o suficiente pro MVP
    return 'news_${type.name}_${ms}_$_seq';
  }
}
