import 'package:flutter/foundation.dart';

import 'game_state.dart';

class AdvanceService {
  static final AdvanceService I = AdvanceService._();
  AdvanceService._();

  // Tempo MVP
  int dia = 1;
  int mes = 1;

  /// Avança 1 dia no jogo
  Future<void> advance() async {
    final gs = GameState.I;

    // 1️⃣ Dia
    dia++;

    // 2️⃣ Virou mês?
    if (dia > _diasDoMes(mes)) {
      dia = 1;
      mes++;

      await _onNovoMes(gs);
    }

    // 3️⃣ Virou ano?
    if (mes > 12) {
      mes = 1;
      await _onNovoAno(gs);
    }

    // 4️⃣ Dia de jogo?
    if (_ehDiaDeJogo(gs)) {
      await gs.simularRodada();
    }

    debugPrint('DATA: $dia/$mes/${gs.temporadaAno}');
  }

  // =============================

  Future<void> _onNovoMes(GameState gs) async {
    // Janeiro: evolução
    if (mes == 1) {
      gs.prepararJaneiroEvolucao();
    }

    // Aqui depois: salários, patrocínio etc.
  }

  Future<void> _onNovoAno(GameState gs) async {
    await gs.iniciarNovaTemporada();
  }

  bool _ehDiaDeJogo(GameState gs) {
    // MVP: um jogo por semana (sábado)
    // Cada 7 dias = rodada
    return dia % 7 == 0 && !gs.temporadaEncerrada;
  }

  int _diasDoMes(int mes) {
    switch (mes) {
      case 2:
        return 28;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }
}
