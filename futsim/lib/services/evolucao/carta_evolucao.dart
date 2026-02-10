class CartaEvolucao {
  final String id;
  final String titulo;
  final String? texto;

  const CartaEvolucao({
    required this.id,
    required this.titulo,
    this.texto,
  });
}
