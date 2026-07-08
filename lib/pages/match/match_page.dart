// lib/pages/match/match_page.dart
//
// Tela de partida (placeholder do MVP)
//
// A versão antiga usava diretamente MatchEngine, TierService e
// um modelo de MatchResult com campos que mudaram (eventos, tier enum, etc).
// Para o MVP atual, o fluxo principal é:
//   HomePage -> simularRodada() -> RodadaPage/TabelaPage
//
// Então, por enquanto, deixamos essa tela como um stub simples,
// só para não quebrar o projeto. Depois que o loop da temporada
// estiver redondo, podemos voltar aqui e montar uma UI completa
// para acompanhar uma partida específica.

import 'package:flutter/material.dart';

class MatchPage extends StatelessWidget {
  final String? homeName;
  final String? awayName;

  const MatchPage({
    super.key,
    this.homeName,
    this.awayName,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = (homeName != null && awayName != null)
        ? '${homeName!} x ${awayName!}'
        : 'Partida';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Tela de partida (MatchPage) ainda em construção.\n\n'
            'O MVP atual usa a simulação simples por rodada e a Tabela.\n'
            'Assim que o loop da temporada estiver redondo, '
            'a gente volta aqui pra montar a experiência completa de match.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
