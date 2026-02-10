// lib/services/evolucao/aprendizado_posicao_service.dart
import '../../models/posicao.dart';

class AprendizadoPosicaoService {
  /// Ganho estimado 0..100 ao treinar uma nova posição.
  /// Mock simples para não quebrar a UI: atacantes ganham mais rápido,
  /// meias medianos, defensores/GK mais lento.
  int ganhoEstimadoPara(Posicao posicao) {
    switch (posicao) {
      case Posicao.GK:
        return 10; // goleiro aprende mais devagar
      case Posicao.RB:
      case Posicao.CB:
      case Posicao.LB:
        return 12; // defensores
      case Posicao.DM:
      case Posicao.CM:
      case Posicao.AM:
        return 16; // meias
      case Posicao.RW:
      case Posicao.LW:
      case Posicao.ST:
        return 18; // atacantes
      default:
        return 15; // fallback seguro p/ outras posições do enum
    }
  }

  /// Sugere posições “vizinhas” para aprendizagem (mock).
  /// Usa apenas valores existentes no teu enum Posicao.
  List<Posicao> sugestoes(Posicao atual) {
    switch (atual) {
      case Posicao.GK:
        return const [Posicao.RB, Posicao.LB];
      case Posicao.CB:
        return const [Posicao.RB, Posicao.LB, Posicao.DM];
      case Posicao.RB:
        return const [Posicao.CB, Posicao.DM, Posicao.RW];
      case Posicao.LB:
        return const [Posicao.CB, Posicao.DM, Posicao.LW];
      case Posicao.DM:
        return const [Posicao.CB, Posicao.CM];
      case Posicao.CM:
        return const [Posicao.DM, Posicao.AM, Posicao.RW, Posicao.LW];
      case Posicao.AM:
        return const [Posicao.CM, Posicao.RW, Posicao.LW, Posicao.ST];
      case Posicao.RW:
        return const [Posicao.AM, Posicao.ST];
      case Posicao.LW:
        return const [Posicao.AM, Posicao.ST];
      case Posicao.ST:
        return const [Posicao.AM, Posicao.RW, Posicao.LW];
      default:
        return const []; // fallback p/ outras posições
    }
  }
}
