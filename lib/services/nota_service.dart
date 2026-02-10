// lib/services/nota_service.dart
//
// Serviço de notas por posição (10..100) sem depender de extensões externas.
// - Evita conflito de imports (usa Posicao com prefixo `pos`).
// - Calcula a nota usando o sum v2 (mesmo motor do app).
// - Define uma posição “principal” compatível a partir de Jogador.pos (GOL/DEF/MEI/ATA).

import '../models/jogador.dart';
import '../models/posicao.dart' as pos; // <- evita ambiguidade e segue lint
import '../services/ratings/service_rating_overall_sum_v2.dart';
// ^ este arquivo deve expor: enum Funcao { GOL, DEF, MEI, ATA } e sumForRole(Funcao, ...)

class NotaService {
  const NotaService();

  /// Converte 0..10 para 10..100; se já for 10..100, apenas clamp.
  int _to100(int v) {
    if (v <= 10) {
      final n = v.clamp(0, 10);
      return (10 + (n / 10) * 90).round();
    }
    return v.clamp(10, 100);
  }

  /// Mapeia uma Posicao granular para a função macro do motor (Funcao).
  /// Resultado: Funcao.GOL / DEF / MEI / ATA
  Funcao _funcaoFromPos(pos.Posicao p) {
    switch (p) {
      case pos.Posicao.GK:
        return Funcao.GOL;
      case pos.Posicao.CB:
      case pos.Posicao.RB:
      case pos.Posicao.LB:
      case pos.Posicao.DM:
        return Funcao.DEF;
      case pos.Posicao.CM:
      case pos.Posicao.AM:
        return Funcao.MEI;
      case pos.Posicao.RW:
      case pos.Posicao.LW:
      case pos.Posicao.ST:
        return Funcao.ATA;
    }
  }

  /// Heurística simples para posição “principal” a partir do campo Jogador.pos
  /// (que costuma ser 'GOL' / 'DEF' / 'MEI' / 'ATA').
  pos.Posicao _principalFromJogador(Jogador j) {
    final s = j.pos.trim().toUpperCase();
    switch (s) {
      case 'GOL':
        return pos.Posicao.GK;
      case 'DEF':
        return pos.Posicao.CB; // representante do bloco defensivo
      case 'MEI':
        return pos.Posicao.CM; // representante do bloco de meio
      case 'ATA':
      default:
        return pos.Posicao.ST; // representante do bloco ofensivo
    }
  }

  /// Nota do jogador **na posição desejada** (escala 10..100).
  int notaNaPosicao(Jogador j, pos.Posicao p) {
    final micros = microsFromPillars(
        j.ofensivo, j.defensivo, j.tecnico, j.mental, j.fisico);
    final func = _funcaoFromPos(p); // Funcao.GOL/DEF/MEI/ATA
    final raw = sumForRole(func, micros); // 10..100
    return _to100(raw);
  }

  /// Nota do jogador na posição “principal” (escala 10..100).
  int notaNaAtual(Jogador j) {
    final p = _principalFromJogador(j);
    return notaNaPosicao(j, p);
  }
}
