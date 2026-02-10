// lib/services/mercado/mercado_service.dart

enum EtapaNegociacao { comClube, comJogador, concluida, abortada }

class Negociacao {
  final dynamic jogador; // UI pode mandar Object
  final int roundsRestantes;
  const Negociacao({this.jogador, this.roundsRestantes = 0});
}

class MercadoService {
  double avaliarValor(dynamic jogador) => 0;
  double salarioAlvo(dynamic jogador) => 0;
  Negociacao iniciarNegociacao(dynamic jogador) => Negociacao(jogador: jogador);
  void proporAoClube(Negociacao n) {}
  void proporAoJogador(Negociacao n) {}
}
