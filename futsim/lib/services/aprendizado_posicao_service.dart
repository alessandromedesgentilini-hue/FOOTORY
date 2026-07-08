import '../models/jogador.dart';

class TreinoPosicao {
  final String jogadorId;
  final Posicao novaPosicao;
  final int partidasNecessarias;
  int partidasAcumuladas;
  final DateTime inicio;

  TreinoPosicao({
    required this.jogadorId,
    required this.novaPosicao,
    required this.partidasNecessarias,
    this.partidasAcumuladas = 0,
    DateTime? inicio,
  }) : inicio = inicio ?? DateTime.now();

  bool get concluido => partidasAcumuladas >= partidasNecessarias;
}

class AprendizagemPosicaoService {
  final int capacidadeSlots; // ex.: CT level 3 => 3 treinos simultâneos
  final List<TreinoPosicao> _ativos = [];

  AprendizagemPosicaoService({required this.capacidadeSlots});

  List<TreinoPosicao> get ativos => List.unmodifiable(_ativos);

  static int _partidasNecessariasParaNovaPosicao(int numPosicoesAtuais) {
    // 3ª posição = 20 partidas; cada nova dobra (40, 80, 160…)
    if (numPosicoesAtuais <= 2) return 20;
    final pot = numPosicoesAtuais - 2;
    return 20 * (1 << pot);
  }

  bool iniciarTreino({
    required String jogadorId,
    required Posicao novaPosicao,
    required int numPosicoesAtuais,
  }) {
    if (_ativos.length >= capacidadeSlots) return false;
    if (_ativos
        .any((t) => t.jogadorId == jogadorId && t.novaPosicao == novaPosicao))
      return false;

    final req = _partidasNecessariasParaNovaPosicao(numPosicoesAtuais);
    _ativos.add(TreinoPosicao(
      jogadorId: jogadorId,
      novaPosicao: novaPosicao,
      partidasNecessarias: req,
    ));
    return true;
  }

  // Conte 1 participação se jogou 1 min ou 90 min
  void registrarParticipacao(String jogadorId) {
    for (final t in _ativos) {
      if (t.jogadorId == jogadorId && !t.concluido) {
        t.partidasAcumuladas += 1;
      }
    }
  }

  // Remove concluídos e retorna para aplicar no save e liberar slot
  List<TreinoPosicao> concluirProntos() {
    final concluidos = <TreinoPosicao>[];
    _ativos.removeWhere((t) {
      if (t.concluido) {
        concluidos.add(t);
        return true;
      }
      return false;
    });
    return concluidos;
  }
}
