// lib/services/mercado/mercado_service.dart
import 'dart:math';

/// Etapas de uma negociação simples.
enum EtapaNegociacao { propostaClube, propostaJogador, acordo, encerrada }

/// Estado da negociação.
class Negociacao {
  final String id;
  final Object jogador; // mantém genérico pro MVP

  int roundsRestantes;
  EtapaNegociacao etapa;

  /// Oferta pelo clube (valor de transferência).
  int? ofertaClube;

  /// Oferta ao jogador (salário mensal).
  int? ofertaJogador;

  Negociacao({
    required this.id,
    required this.jogador,
    required this.roundsRestantes,
    this.etapa = EtapaNegociacao.propostaClube,
    this.ofertaClube,
    this.ofertaJogador,
  });
}

/// Gateway de finanças (stub em memória).
class InMemoryFinanceGateway {
  const InMemoryFinanceGateway();

  bool podePagar(String clubeId, int valor) => true;
  void debitar(String clubeId, int valor) {/* no-op */}
}

/// Serviço de mercado: avalia valores e conduz uma negociação simples.
class MercadoService {
  final Random _rng;
  final InMemoryFinanceGateway fin;

  MercadoService({int? seed, InMemoryFinanceGateway? finance})
      : _rng = Random(seed),
        fin = finance ?? const InMemoryFinanceGateway();

  /// Avalia um valor de transferência (1.000.000 .. 15.000.000).
  int avaliarValor(Object jogador) {
    // 1000000 a 15000000 inclusive
    return 1000000 + _rng.nextInt(14000001);
  }

  /// Avalia um salário alvo (50.000 .. 600.000).
  int salarioAlvo(Object jogador) {
    return 50000 + _rng.nextInt(551000);
  }

  /// Cria uma negociação com um número de rounds.
  Negociacao iniciarNegociacao(Object jogador, {int rounds = 4}) {
    final id =
        'NEG-${DateTime.now().millisecondsSinceEpoch}-${_rng.nextInt(9999)}';
    return Negociacao(id: id, jogador: jogador, roundsRestantes: rounds);
  }

  /// Clube melhora a oferta de transferência.
  void proporAoClube(Negociacao neg) {
    if (neg.etapa == EtapaNegociacao.acordo ||
        neg.etapa == EtapaNegociacao.encerrada) return;

    // 500000..2000000 (inclusive)
    final delta = 500000 + _rng.nextInt(1500001);
    neg.ofertaClube = (neg.ofertaClube ?? 0) + delta;
    _tick(neg, proxima: EtapaNegociacao.propostaJogador);
  }

  /// Clube melhora a oferta salarial ao jogador.
  void proporAoJogador(Negociacao neg) {
    if (neg.etapa == EtapaNegociacao.acordo ||
        neg.etapa == EtapaNegociacao.encerrada) return;

    // 10000..50000 (inclusive)
    final delta = 10000 + _rng.nextInt(40001);
    neg.ofertaJogador = (neg.ofertaJogador ?? 0) + delta;
    _tick(neg, proxima: EtapaNegociacao.propostaClube);
  }

  // ----------------- internos -----------------

  void _tick(Negociacao neg, {required EtapaNegociacao proxima}) {
    if (neg.roundsRestantes <= 0) {
      neg.etapa = EtapaNegociacao.encerrada;
      return;
    }
    neg.roundsRestantes -= 1;

    // Probabilidade de fechar se as ofertas estiverem próximas do alvo.
    if (neg.ofertaClube != null && neg.ofertaJogador != null) {
      final val = neg.ofertaClube!;
      final sal = neg.ofertaJogador!;
      final alvoVal = avaliarValor(neg.jogador);
      final alvoSal = salarioAlvo(neg.jogador);

      final okVal = val >= (alvoVal * 0.90).round();
      final okSal = sal >= (alvoSal * 0.90).round();

      if (okVal && okSal && _rng.nextDouble() < 0.15) {
        neg.etapa = EtapaNegociacao.acordo;
        return;
      }
    }

    neg.etapa = proxima;
  }
}
