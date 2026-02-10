// lib/world/brasil/serie_a/generator.dart
//
// Gera um pequeno conjunto de jogadores exemplo da Série A de forma COERENTE
// com o motor atual (PlayerGen): OVR 10..100 e pilares alinhados à macro-posição.
//
// Este arquivo é um utilitário/legado para geração de jogadores, e não faz parte
// do loop principal do MVP (GameState + fixtures + tabela).
//
// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:futsim/models/jogador.dart';
import 'package:futsim/models/posicao.dart';
import 'package:futsim/models/pe_preferencial.dart';
import 'package:futsim/services/generator/player_gen.dart';

/// Converte Posicao granular para macro usada pelo app/PlayerGen.
String _macroFromPos(Posicao p) {
  switch (p) {
    case Posicao.GK:
      return 'GK';
    case Posicao.CB:
    case Posicao.RB:
    case Posicao.LB:
      return 'DF';
    case Posicao.DM:
    case Posicao.CM:
    case Posicao.AM:
      return 'MF';
    case Posicao.RW:
    case Posicao.LW:
    case Posicao.ST:
      return 'FW';
  }
}

/// Template mínimo para “forçar” nome/pos/pe/idade onde quisermos,
/// deixando OVR/pilares/foto por conta do PlayerGen (coerente com o resto).
class _Tpl {
  final String id;
  final String nome;
  final Posicao pos; // granular para nossa conveniência; macro é derivada
  final PePreferencial pe;
  final int? idade;

  const _Tpl(this.id, this.nome, this.pos, this.pe, {this.idade});
}

/// Gera um pequeno conjunto de jogadores exemplo da Série A.
/// `nivel` ~2.0..4.0 (usa 3.0 como default se não passar).
List<Jogador> gerarSerieA({List<Jogador>? extras, double nivel = 3.0}) {
  final gen = PlayerGen(); // um gerador por chamada (se quiser, passe seed)
  final rng = Random();

  final base = <_Tpl>[
    _Tpl('BRAA_EX_001', 'João Silva', Posicao.GK, PePreferencial.direito,
        idade: 29),
    _Tpl('BRAA_EX_002', 'Rafael Costa', Posicao.CB, PePreferencial.direito,
        idade: 27),
    _Tpl('BRAA_EX_003', 'Lucas Andrade', Posicao.RB, PePreferencial.direito,
        idade: 26),
    _Tpl('BRAA_EX_004', 'Bruno Teixeira', Posicao.LB, PePreferencial.esquerdo,
        idade: 25),
    _Tpl('BRAA_EX_005', 'Diego Santos', Posicao.DM, PePreferencial.direito,
        idade: 28),
    _Tpl('BRAA_EX_006', 'Gustavo Lima', Posicao.CM, PePreferencial.direito,
        idade: 24),
    _Tpl('BRAA_EX_007', 'Matheus Rocha', Posicao.AM, PePreferencial.esquerdo,
        idade: 23),
    _Tpl('BRAA_EX_008', 'Raul Mendes', Posicao.RW, PePreferencial.direito,
        idade: 25),
    _Tpl('BRAA_EX_009', 'Victor Prado', Posicao.LW, PePreferencial.esquerdo,
        idade: 26),
    _Tpl('BRAA_EX_010', 'Pedro Alves', Posicao.ST, PePreferencial.direito,
        idade: 27),
    _Tpl('BRAA_EX_011', 'Éverton Nunes', Posicao.ST, PePreferencial.direito,
        idade: 28),
  ];

  final out = <Jogador>[];

  for (final t in base) {
    // 1) Pede um jogador “genérico” ao PlayerGen só para obter OVR/pilares/foto coerentes.
    final view = gen
        .gerarProf(
          1,
          nivel: nivel,
          clubeId:
              'BRAA', // só para garantir unicidade do id gerado internamente
        )
        .first;

    // 2) Sobrescreve o que queremos (id/nome/pos/pe/idade), mantendo o resto:
    final macro = _macroFromPos(t.pos); // "GK"/"DF"/"MF"/"FW"

    final patched = PlayerView(
      id: t.id,
      nome: t.nome,
      pos: macro,
      idade: t.idade ?? (21 + rng.nextInt(12)), // 21..32 caso não definido
      pe: t.pe,
      ovr10to100: view.ovr10to100,
      foto: view.foto,
    );

    // 3) Converte para Jogador final (pilares/OVR já mapeados pelo gen):
    final j = gen.toJogadorFromView(patched);

    out.add(j);
  }

  if (extras != null && extras.isNotEmpty) {
    out.addAll(extras);
  }

  return out;
}
