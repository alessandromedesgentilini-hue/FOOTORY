// lib/models/treinador.dart
//
// Treinador = "save" central do FutSim.
// - O jogador controla o treinador, não o clube.
// - O treinador tem um clube atual (emprego), pode trocar por proposta.
// - Guardamos metas/checkpoints depois (início/meio/fim) — por enquanto, só base.

class Treinador {
  final String id; // UUID simples/slug (pode virar real depois)
  final String nome;

  // Progressão do treinador (placeholder do MVP)
  int nivel; // 1..99
  double reputacao; // 1..10

  // Clube atual (referência por id institucional 1..80)
  int clubeAtualId;

  // Temporada atual (placeholder)
  int temporada; // ex: 2026

  Treinador({
    required this.id,
    required this.nome,
    required this.clubeAtualId,
    this.nivel = 1,
    this.reputacao = 5.0,
    this.temporada = 2026,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'nivel': nivel,
        'reputacao': reputacao,
        'clubeAtualId': clubeAtualId,
        'temporada': temporada,
      };

  factory Treinador.fromJson(Map<String, dynamic> json) {
    return Treinador(
      id: (json['id'] ?? 'coach-001').toString(),
      nome: (json['nome'] ?? 'Treinador').toString(),
      nivel: (json['nivel'] as num?)?.toInt() ?? 1,
      reputacao: (json['reputacao'] as num?)?.toDouble() ?? 5.0,
      clubeAtualId:
          (json['clubeAtualId'] as num?)?.toInt() ?? 61, // default Série D
      temporada: (json['temporada'] as num?)?.toInt() ?? 2026,
    );
  }

  @override
  String toString() => 'Treinador($nome, clubeAtualId=$clubeAtualId)';
}
