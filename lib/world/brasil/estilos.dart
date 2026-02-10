// Estilos táticos unificados para o jogo.

enum BaseEstilo {
  tikiTaka, // posse de bola
  gegenpress, // pressão pós-perda
  transicao, // transições rápidas
  sulAmericano, // catimba/duelos
  bolaParada, // foco em bolas paradas
}

class Estilo {
  final BaseEstilo base;
  final String nome;
  const Estilo._(this.base, this.nome);

  static const Estilo posseDeBola =
      Estilo._(BaseEstilo.tikiTaka, 'Posse de bola');
  static const Estilo gegenpress =
      Estilo._(BaseEstilo.gegenpress, 'Gegenpress');
  static const Estilo transicao = Estilo._(BaseEstilo.transicao, 'Transição');
  static const Estilo sulAmericano =
      Estilo._(BaseEstilo.sulAmericano, 'Sul-americano');
  static const Estilo bolaParada =
      Estilo._(BaseEstilo.bolaParada, 'Bola parada');

  String get label => nome;
}
