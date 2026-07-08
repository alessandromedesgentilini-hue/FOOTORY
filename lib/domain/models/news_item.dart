// lib/domain/models/news_item.dart
//
// NewsItem (MVP)
// - Item de notícia simples, com canal (pública x interna)
// - Suporta save/load via JSON (para GameState salvar depois)

enum NewsCanal {
  publica, // imprensa / torcida / mundo
  interna, // diretoria / treinador / jogadores
}

enum NewsTipo {
  partida,
  mercado,
  clube,
  sistema,
}

class NewsItem {
  final String id;

  /// Momento do mundo (pra UI e ordenação)
  final int temporadaAno;
  final int rodada;
  final int mes;
  final int dia;

  final NewsCanal canal;
  final NewsTipo tipo;

  final String titulo;
  final String texto;

  const NewsItem({
    required this.id,
    required this.temporadaAno,
    required this.rodada,
    required this.mes,
    required this.dia,
    required this.canal,
    required this.tipo,
    required this.titulo,
    required this.texto,
  });

  String get dataStr =>
      '${dia.toString().padLeft(2, '0')}/${mes.toString().padLeft(2, '0')}/$temporadaAno';

  Map<String, dynamic> toJson() => {
        'id': id,
        'temporadaAno': temporadaAno,
        'rodada': rodada,
        'mes': mes,
        'dia': dia,
        'canal': canal.name,
        'tipo': tipo.name,
        'titulo': titulo,
        'texto': texto,
      };

  factory NewsItem.fromJson(Map<String, dynamic> m) {
    NewsCanal parseCanal(Object? v) {
      final s = (v ?? 'publica').toString().toLowerCase();
      if (s.contains('intern')) return NewsCanal.interna;
      return NewsCanal.publica;
    }

    NewsTipo parseTipo(Object? v) {
      final s = (v ?? 'sistema').toString().toLowerCase();
      switch (s) {
        case 'partida':
          return NewsTipo.partida;
        case 'mercado':
          return NewsTipo.mercado;
        case 'clube':
          return NewsTipo.clube;
        default:
          return NewsTipo.sistema;
      }
    }

    return NewsItem(
      id: (m['id'] ?? '').toString(),
      temporadaAno: (m['temporadaAno'] as num?)?.toInt() ?? 2026,
      rodada: (m['rodada'] as num?)?.toInt() ?? 1,
      mes: (m['mes'] as num?)?.toInt() ?? 1,
      dia: (m['dia'] as num?)?.toInt() ?? 1,
      canal: parseCanal(m['canal']),
      tipo: parseTipo(m['tipo']),
      titulo: (m['titulo'] ?? '').toString(),
      texto: (m['texto'] ?? '').toString(),
    );
  }
}
