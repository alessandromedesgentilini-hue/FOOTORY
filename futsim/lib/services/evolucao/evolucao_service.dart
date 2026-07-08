// lib/services/evolucao/evolucao_service.dart
//
// Define os tipos usados na tela e deixa as assinaturas
// batendo com as chamadas atuais da EvolucaoPage.

/// Plano de treino mostrado na UI.
class PlanoTreino {
  final String id;
  final String nome;
  final String? titulo; // usado na UI
  final int pontosPorSemana; // usado na UI
  final Map<String, double> pesosAtributos;

  const PlanoTreino({
    required this.id,
    required this.nome,
    this.titulo,
    this.pontosPorSemana = 0,
    this.pesosAtributos = const {},
  });

  static PlanoTreino ofensivo() =>
      const PlanoTreino(id: 'pt_ofn', nome: 'Ofensivo', pontosPorSemana: 1);
}

/// Carta de evolução simples (stub para UI).
class CartaEvolucao {
  final String nome;
  const CartaEvolucao(this.nome);
}

/// Service usado pela tela de evolução.
/// A ordem dos parâmetros foi ajustada para bater com as chamadas da UI:
/// aplicarTreinoSemanal(planoSelecionado, 1) e aplicarCarta(cartaSelecionada, 1)
class EvolucaoService {
  void aplicarTreinoSemanal(dynamic plano, int semanas) {}
  void aplicarCarta(dynamic carta, int intensidade) {}
  void evoluirTimeFimDeTemporada([dynamic _]) {}
}
