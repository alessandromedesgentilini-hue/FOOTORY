class PlanoTreino {
  final String id;
  final String nome;
  final String? descricao;

  const PlanoTreino({
    required this.id,
    required this.nome,
    this.descricao,
  });
}
