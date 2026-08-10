part of '../game_state.dart';

extension MarketOpportunityHandler on GameState {
  bool _shouldTryGenerateMarketOpportunity(int round) {
    final score = userScoutLevel + userComunicacaoLevel;

    if (score < 10) return false;

    if (score <= 13) {
      return round == 10;
    }

    if (score <= 16) {
      return round == 10 || round == 20;
    }

    return round == 10 || round == 20 || round == 30;
  }

  bool _tryGenerateMarketOpportunity() {
    final score = userScoutLevel + userComunicacaoLevel;

    if (score < 10) return false;

    const chance = 0.60;
    if (_rng.nextDouble() > chance) return false;

    final range = _marketOpportunityOvrRangeByScore(score);
    final minOvr = range[0];
    final maxOvr = range[1];

    final player = _playerFactory.criarJogadorComOvrCheioTarget(
      posDet: _pickMarketOpportunityPosition(),
      nacionalidade: 'BR',
      idadeMin: 18,
      idadeMax: 30,
      minOvrCheio: minOvr,
      maxOvrCheio: maxOvr,
      maxTries: 45,
    );

    _marketService.addTransferPlayer(player);

    final target = ScoutTarget(
      jogadorId: player.id,
      playerName: player.nome,
      posLabel: _marketOpportunityPosLabel(player.posDet),
      qualityLabel: _marketOpportunityQualityLabel(player.ovrCheio),
      listType: MarketListType.transfer,
      motivo:
          'Oportunidade de Mercado — Scout e Comunicação identificaram um jogador disponível abaixo do valor devido à situação do clube de origem.',
      faceAsset: player.faceAsset,
    );

    _scoutTransfers.insert(0, target);

    _insertNewsIfNew(_buildMarketOpportunityText(player));

    return true;
  }

  String _buildMarketOpportunityText(Player player) {
    final posLabel = _marketOpportunityPosLabel(player.posDet);

    return 'Jorge Silveira, Chefe de Observação — O cruzamento das informações disponíveis apontou uma chance rara por ${player.nome}, $posLabel de OVR ${player.ovrCheio}. A leitura do mercado indicou uma situação favorável no clube de origem. A operação pode sair abaixo do valor normal, mas a negociação dependerá da força do departamento financeiro.';
  }

  List<int> _marketOpportunityOvrRangeByScore(int score) {
    if (score <= 13) return <int>[60, 65];
    if (score <= 16) return <int>[64, 70];
    if (score <= 20) return <int>[70, 77];
    return <int>[60, 62];
  }

  PosDet _pickMarketOpportunityPosition() {
    final roll = _rng.rangeInt(1, 100);

    if (roll <= 8) return PosDet.gol;
    if (roll <= 18) return PosDet.ld;
    if (roll <= 28) return PosDet.le;
    if (roll <= 43) return PosDet.zag;
    if (roll <= 55) return PosDet.vol;
    if (roll <= 67) return PosDet.mc;
    if (roll <= 78) return PosDet.mei;
    if (roll <= 87) return PosDet.pd;
    if (roll <= 96) return PosDet.pe;
    return PosDet.ca;
  }

  String _marketOpportunityPosLabel(PosDet pos) {
    switch (pos) {
      case PosDet.gol:
        return 'GOL';
      case PosDet.ld:
        return 'LD';
      case PosDet.le:
        return 'LE';
      case PosDet.zag:
        return 'ZAG';
      case PosDet.vol:
        return 'VOL';
      case PosDet.mc:
        return 'MC';
      case PosDet.mei:
        return 'MEI';
      case PosDet.pd:
        return 'PD';
      case PosDet.pe:
        return 'PE';
      case PosDet.ca:
        return 'CA';
    }
  }

  String _marketOpportunityQualityLabel(int ovr) {
    if (ovr >= 76) return 'A';
    if (ovr >= 70) return 'B';
    if (ovr >= 64) return 'C';
    if (ovr >= 58) return 'D';
    return 'E';
  }
}
