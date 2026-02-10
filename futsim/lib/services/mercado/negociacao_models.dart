enum EtapaNegociacao { propostaClube, propostaJogador, acordo, encerrada }

class Negociacao {
  final String id;
  final EtapaNegociacao etapa;

  const Negociacao({
    required this.id,
    required this.etapa,
  });
}

// Gateway de finanças em memória (stub)
class InMemoryFinanceGateway {
  const InMemoryFinanceGateway();

  // bool podePagar(String clubeId, int valor) => true;
}
