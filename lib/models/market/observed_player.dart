import 'package:footory26/models/player.dart';

class ObservedPlayer {
  final String id;
  final String nome;
  final int idade;
  final int ovr;
  final PosDet posDet;
  final String clubIdAtual;
  final int anosObservado;

  const ObservedPlayer({
    required this.id,
    required this.nome,
    required this.idade,
    required this.ovr,
    required this.posDet,
    required this.clubIdAtual,
    required this.anosObservado,
  });

  ObservedPlayer copyWith({
    String? id,
    String? nome,
    int? idade,
    int? ovr,
    PosDet? posDet,
    String? clubIdAtual,
    int? anosObservado,
  }) {
    return ObservedPlayer(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
      ovr: ovr ?? this.ovr,
      posDet: posDet ?? this.posDet,
      clubIdAtual: clubIdAtual ?? this.clubIdAtual,
      anosObservado: anosObservado ?? this.anosObservado,
    );
  }
}
