part of '../game_state.dart';

extension TransferFlowHandler on GameState {
  void clearPendingTransferOffer() {
    if (_pendingTransferOffer == null) return;
    _pendingTransferOffer = null;
    notifyListeners();
  }

  bool addToObservationList({
    required Player player,
    required String clubDestinoId,
    bool lockCurrentTransferWindow = false,
  }) {
    if (_observedPlayers.any((p) => p.id == player.id)) return false;
    if (_observedPlayers.length >= 10) return false;

    _observedPlayers.add(
      ObservedPlayer(
        id: player.id,
        nome: player.nome,
        idade: player.idade,
        ovr: player.ovrCheio,
        posDet: player.posDet,
        clubIdAtual: clubDestinoId,
        anosObservado: 0,
        faceAsset: player.faceAsset,
        lockedTransferYear: lockCurrentTransferWindow ? currentDate.year : null,
        lockedTransferMonth:
            lockCurrentTransferWindow ? currentDate.month : null,
      ),
    );

    notifyListeners();
    return true;
  }

  bool _addToObservationListSilently({
    required Player player,
    required String clubDestinoId,
    bool lockCurrentTransferWindow = false,
  }) {
    if (_observedPlayers.any((p) => p.id == player.id)) return false;
    if (_observedPlayers.length >= 10) return false;

    _observedPlayers.add(
      ObservedPlayer(
        id: player.id,
        nome: player.nome,
        idade: player.idade,
        ovr: player.ovrCheio,
        posDet: player.posDet,
        clubIdAtual: clubDestinoId,
        anosObservado: 0,
        faceAsset: player.faceAsset,
        lockedTransferYear: lockCurrentTransferWindow ? currentDate.year : null,
        lockedTransferMonth:
            lockCurrentTransferWindow ? currentDate.month : null,
      ),
    );

    return true;
  }

  String rejectPendingTransferOffer() {
    final offer = _pendingTransferOffer;
    if (offer == null) return 'Nenhuma proposta ativa.';

    final squad = _proSquads[userClubId] ?? const <Player>[];
    final player = squad.cast<Player?>().firstWhere(
          (p) => p?.id == offer.playerId,
          orElse: () => null,
        );

    final contextLabel =
        player == null ? '' : _playerSeasonOfferContext(player);
    final extra = contextLabel.isEmpty ? '' : ' $contextLabel';

    _newsFeed.insert(
      0,
      'MERCADO — Proposta recusada. ${clubName(offer.toClubId)} não levou ${offer.playerName}.$extra',
    );

    _pendingTransferOffer = null;
    notifyListeners();
    return 'Proposta recusada.';
  }

  String acceptPendingTransferOffer({
    bool addToObservation = false,
  }) {
    final offer = _pendingTransferOffer;
    if (offer == null) return 'Nenhuma proposta ativa.';

    final squad = _proSquads[userClubId];
    if (squad == null || squad.isEmpty) {
      _pendingTransferOffer = null;
      notifyListeners();
      return 'Elenco não encontrado.';
    }

    final idx = squad.indexWhere((p) => p.id == offer.playerId);
    if (idx < 0) {
      _pendingTransferOffer = null;
      notifyListeners();
      return 'Jogador não encontrado no elenco.';
    }

    final player = squad[idx];
    final acceptedByPlayer = _playerAcceptsTransfer(
      player: player,
      destinationClubId: offer.toClubId,
    );

    if (!acceptedByPlayer) {
      final contextLabel = _playerSeasonOfferContext(player);
      final extra = contextLabel.isEmpty ? '' : ' $contextLabel';

      _newsFeed.insert(
        0,
        'MERCADO — ${player.nome} recusou a transferência para ${clubName(offer.toClubId)}.$extra',
      );

      _pendingTransferOffer = null;
      notifyListeners();
      return 'O jogador recusou a transferência.';
    }

    squad.removeAt(idx);

    applyUserSaleFinance(
      value: offer.offeredValue,
      player: player,
    );

    if (addToObservation) {
      addToObservationList(
        player: player,
        clubDestinoId: offer.toClubId,
        lockCurrentTransferWindow: true,
      );
    }

    _newsFeed.insert(
      0,
      _buildAcceptedSaleNews(
        player: player,
        destinationClubId: offer.toClubId,
        soldValue: offer.offeredValue,
      ),
    );

    _pendingTransferOffer = null;
    notifyListeners();
    return 'Transferência concluída com sucesso!';
  }

  bool _playerAcceptsTransfer({
    required Player player,
    required String destinationClubId,
  }) {
    final destPower = clubCpuPower10(destinationClubId);
    final currentPower = clubPower10(userClubId);

    var chance = 0.45;

    if (destPower > currentPower) chance += 0.20;
    if (destPower >= currentPower + 1.0) chance += 0.10;

    if (player.idade <= 21) {
      chance += 0.08;
    } else if (player.idade <= 27) {
      chance += 0.04;
    } else if (player.idade >= 31) {
      chance -= 0.06;
    }

    if (player.ovrCheio >= 80) {
      chance -= 0.05;
    } else if (player.ovrCheio <= 60) {
      chance += 0.05;
    }

    if (player.temporadaGols >= 8) chance -= 0.04;
    if (player.temporadaDestaques >= 4) chance -= 0.03;

    switch (userFinanceHealth) {
      case FinanceHealth.muitoSaudavel:
        chance -= 0.03;
        break;
      case FinanceHealth.saudavel:
        chance -= 0.01;
        break;
      case FinanceHealth.estavel:
        break;
      case FinanceHealth.pressionado:
        chance += 0.04;
        break;
      case FinanceHealth.critico:
        chance += 0.08;
        break;
      case FinanceHealth.colapsoFinanceiro:
        chance += 0.12;
        break;
    }

    chance = chance.clamp(0.15, 0.95);
    return _rng.nextDouble() <= chance;
  }

  bool _shouldTryGenerateTransferOffer(int round) {
    if (_pendingTransferOffer != null) return false;

    switch (round) {
      case 9:
      case 19:
      case 30:
        return true;
      default:
        return false;
    }
  }

  void _maybeGenerateTransferOffer() {
    final squad = _proSquads[userClubId];
    if (squad == null || squad.isEmpty) return;

    final candidates = squad.where((p) => p.ovrCheio >= 55).toList();
    if (candidates.isEmpty) return;

    final chosen = _pickTransferCandidate(candidates);
    final destinationClubId = _pickInterestedClubForPlayer(chosen.ovrCheio);

    if (destinationClubId == null) return;
    if (destinationClubId == userClubId) return;

    final offer = TransferOffer(
      playerId: chosen.id,
      playerName: chosen.nome,
      fromClubId: userClubId,
      toClubId: destinationClubId,
      offeredValue: _estimatedTransferValue(chosen),
      playerOvr: chosen.ovrCheio,
    );

    _pendingTransferOffer = offer;

    _newsFeed.insert(
      0,
      _buildOfferNewsLine(
        player: chosen,
        destinationClubId: destinationClubId,
        offeredValue: offer.offeredValue,
      ),
    );
  }

  Player _pickTransferCandidate(List<Player> candidates) {
    final weighted = <Player>[];

    for (final p in candidates) {
      var weight = 1;

      weight += (p.ovrCheio / 10).floor().clamp(1, 10);
      weight += p.temporadaGols * 2;
      weight += p.temporadaAssistencias;
      weight += p.temporadaDestaques * 2;

      if (p.idade <= 23) weight += 3;
      if (p.idade <= 20) weight += 2;

      switch (p.posDet) {
        case PosDet.ca:
          weight += 4;
          break;
        case PosDet.pd:
        case PosDet.pe:
        case PosDet.mei:
          weight += 3;
          break;
        case PosDet.mc:
          weight += 2;
          break;
        case PosDet.vol:
        case PosDet.ld:
        case PosDet.le:
        case PosDet.zag:
          weight += 1;
          break;
        case PosDet.gol:
          break;
      }

      for (int i = 0; i < weight; i++) {
        weighted.add(p);
      }
    }

    if (weighted.isEmpty) {
      candidates.sort((a, b) => b.ovrCheio.compareTo(a.ovrCheio));
      final topN = candidates.length >= 5 ? 5 : candidates.length;
      return candidates[_rng.nextInt(topN)];
    }

    return weighted[_rng.nextInt(weighted.length)];
  }

  String? _pickInterestedClubForPlayer(int ovr) {
    final wantedDivision = _preferredDivisionForOvr(ovr);
    final wantedDivId = _parseDivisionId(wantedDivision);
    if (wantedDivId == null) return null;

    final clubs = List<String>.from(_clubIdsByDiv[wantedDivId] ?? const []);
    clubs.removeWhere((id) => id == userClubId);
    if (clubs.isEmpty) return null;

    return clubs[_rng.nextInt(clubs.length)];
  }

  String _preferredDivisionForOvr(int ovr) {
    if (ovr >= 68) return 'BR-A';
    if (ovr >= 60) return 'BR-B';
    if (ovr >= 50) return 'BR-C';
    return 'BR-D';
  }

  int _estimatedTransferValue(Player player) {
    final marketValue = estimatePlayerValueForUserClub(player);
    double multiplier = 1.0;

    multiplier += (player.temporadaGols * 0.015).clamp(0.0, 0.15);
    multiplier += (player.temporadaAssistencias * 0.010).clamp(0.0, 0.08);
    multiplier += (player.temporadaDestaques * 0.020).clamp(0.0, 0.12);

    if (player.idade <= 21) {
      multiplier += 0.10;
    } else if (player.idade <= 24) {
      multiplier += 0.05;
    } else if (player.idade >= 31) {
      multiplier -= 0.06;
    }

    switch (userFinanceHealth) {
      case FinanceHealth.muitoSaudavel:
        multiplier += 0.10;
        break;
      case FinanceHealth.saudavel:
        multiplier += 0.05;
        break;
      case FinanceHealth.estavel:
        break;
      case FinanceHealth.pressionado:
        multiplier -= 0.08;
        break;
      case FinanceHealth.critico:
        multiplier -= 0.15;
        break;
      case FinanceHealth.colapsoFinanceiro:
        multiplier -= 0.22;
        break;
    }

    multiplier = multiplier.clamp(0.65, 1.60);
    return (marketValue * multiplier).round();
  }

  String _buildOfferNewsLine({
    required Player player,
    required String destinationClubId,
    required int offeredValue,
  }) {
    final context = _playerSeasonOfferContext(player);
    final club = clubName(destinationClubId);
    final valueLabel = MoneyFormatter.formatCurrency(offeredValue);

    final financeContext = _financialPressureOfferContext();

    if (context.isEmpty && financeContext.isEmpty) {
      return 'MERCADO — $club fez proposta por ${player.nome} (${player.ovrCheio}) no valor de $valueLabel.';
    }

    return 'MERCADO — $club fez proposta por ${player.nome} (${player.ovrCheio}) no valor de $valueLabel. ${[
      context,
      financeContext,
    ].where((e) => e.trim().isNotEmpty).join(' ')}';
  }

  String _buildAcceptedSaleNews({
    required Player player,
    required String destinationClubId,
    required int soldValue,
  }) {
    final club = clubName(destinationClubId);
    final context = _playerSeasonOfferContext(player);

    final availablePct = userRepassPercentage.clamp(0.0, 1.0).toDouble();
    final debtPct = (1.0 - availablePct).clamp(0.0, 1.0).toDouble();

    final debtAmount = (soldValue * debtPct).round();
    final availableAmount = soldValue - debtAmount;

    final operationalAmount = (availableAmount / 2).round();
    final cashAmount = availableAmount - operationalAmount;

    final soldLabel = MoneyFormatter.formatCurrency(soldValue);
    final debtLabel = MoneyFormatter.formatCurrency(debtAmount);
    final operationalLabel = MoneyFormatter.formatCurrency(operationalAmount);
    final cashLabel = MoneyFormatter.formatCurrency(cashAmount);

    final debtPctLabel = (debtPct * 100).round();
    final availablePctLabel = (availablePct * 100).round();

    final contextText = context.isEmpty ? '' : ' $context';

    return 'MERCADO — Venda concluída. ${player.nome} foi negociado com $club por $soldLabel.$contextText '
        'Pela condição financeira atual do clube, $debtPctLabel% da operação ($debtLabel) foi direcionado para quitação de dívidas. '
        'Os outros $availablePctLabel% foram liberados para o clube: $operationalLabel reforçam o fluxo de caixa para salários e manutenção, '
        'e $cashLabel entram no caixa disponível para investimentos.';
  }

  String _playerSeasonOfferContext(Player player) {
    final tags = <String>[];

    if (player.temporadaGols >= 10) {
      tags.add(
        'O jogador vive grande fase ofensiva, com ${player.temporadaGols} gols na temporada.',
      );
    } else if (player.temporadaGols >= 5) {
      tags.add('Ele já soma ${player.temporadaGols} gols na temporada.');
    }

    if (player.temporadaAssistencias >= 5) {
      tags.add(
        'Também contribuiu com ${player.temporadaAssistencias} assistências.',
      );
    }

    if (player.temporadaDestaques >= 4) {
      tags.add('Vem sendo uma das peças mais importantes do elenco.');
    } else if (player.temporadaDestaques >= 2) {
      tags.add('Tem aparecido bem entre os destaques recentes do time.');
    }

    if (tags.isEmpty && player.participacoesEmGol >= 4) {
      tags.add(
        'Ele já participou diretamente de ${player.participacoesEmGol} gols do clube.',
      );
    }

    return tags.join(' ');
  }

  String _financialPressureOfferContext() {
    switch (userFinanceHealth) {
      case FinanceHealth.muitoSaudavel:
      case FinanceHealth.saudavel:
        return '';
      case FinanceHealth.estavel:
        return 'A situação financeira do clube segue controlada, sem pressão extrema por venda.';
      case FinanceHealth.pressionado:
        return 'Nos bastidores, o caixa já pede atenção e uma venda importante ajudaria bastante.';
      case FinanceHealth.critico:
        return 'O momento financeiro pesa, e propostas desse porte ganham força na mesa da diretoria.';
      case FinanceHealth.colapsoFinanceiro:
        return 'Em colapso financeiro, o clube perde margem para endurecer negociações e sente forte pressão por venda.';
    }
  }

  void _ageObservedPlayers() {
    for (var i = 0; i < _observedPlayers.length; i++) {
      final p = _observedPlayers[i];

      _observedPlayers[i] = p.copyWith(
        idade: p.idade + 1,
        anosObservado: p.anosObservado + 1,
        clearTransferLock: true,
      );
    }
  }

  void _materializeObservedPlayersForClub(String clubId) {
    if (clubId == userClubId) return;

    final matching =
        _observedPlayers.where((p) => p.clubIdAtual == clubId).toList();

    if (matching.isEmpty) return;

    final squad = _proSquads.putIfAbsent(clubId, () => <Player>[]);

    for (final op in matching) {
      final player = _playerFactory.criarJogadorComOvrCheioTarget(
        posDet: op.posDet,
        nacionalidade: 'BR',
        idadeMin: op.idade,
        idadeMax: op.idade,
        minOvrCheio: op.ovr,
        maxOvrCheio: op.ovr,
        maxTries: 1,
      );

      squad.add(
        player.copyWith(
          nome: op.nome,
          faceAsset: op.faceAsset,
        ),
      );
    }

    _observedPlayers.removeWhere((p) => p.clubIdAtual == clubId);
  }

  String trySignFromScout(ScoutTarget target) {
    if (!isInitialized) return 'Erro: jogo não inicializado.';
    if (userClubId.isEmpty) return 'Erro: clube do usuário inválido.';

    final isOpportunity = _isMarketOpportunityTarget(target);

    final preview = previewNegotiationFromScout(target);
    if (preview == null) {
      _removeScoutTargetEverywhere(target.jogadorId);
      notifyListeners();
      return 'Negociação falhou. Jogador não está mais disponível.';
    }

    final outcome = isOpportunity
        ? _resolveMarketOpportunityNegotiation(preview)
        : const NegotiationService().resolveNegotiation(
            preview: preview,
            roll: _rng.nextDouble(),
          );

    if (!outcome.success) {
      final failedPlayer = _marketService.removePlayerByListType(
        jogadorId: target.jogadorId,
        listType: target.listType,
      );

      _removeScoutTargetEverywhere(target.jogadorId);

      var observationText = '';

      if (failedPlayer != null) {
        final addedToObservation = _addToObservationListSilently(
          player: failedPlayer,
          clubDestinoId: 'mercado_observado',
        );

        if (addedToObservation) {
          observationText =
              ' O jogador saiu da lista atual do mercado, mas foi mantido na lista de observação do clube para futuras oportunidades.';
        } else {
          observationText =
              ' O jogador saiu da lista atual do mercado. A lista de observação já está cheia ou ele já estava sendo observado.';
        }
      } else {
        observationText =
            ' O jogador saiu da lista atual do mercado e não está mais disponível.';
      }

      _newsFeed.insert(
        0,
        '${outcome.title} — ${preview.playerName}. ${outcome.message}$observationText',
      );

      notifyListeners();
      return '${outcome.message}$observationText';
    }

    final player = _marketService.removePlayerByListType(
      jogadorId: target.jogadorId,
      listType: target.listType,
    );

    if (player == null) {
      _removeScoutTargetEverywhere(target.jogadorId);
      notifyListeners();
      return 'Negociação falhou. Jogador não está mais disponível.';
    }

    final marketValue = preview.marketValue;

    final discount =
        isOpportunity ? _opportunityDiscount(userFinanceiroLevel) : 0.0;

    final transferCost =
        (preview.negotiatedCost * (1 - discount)).round().clamp(0, 999999999);

    final salary = preview.negotiatedSalary;

    if (userBalance < transferCost) {
      _marketService.addPlayerByListType(
        player: player,
        listType: target.listType,
      );

      return 'Caixa insuficiente. A contratação de ${player.nome} exige ${MoneyFormatter.formatCurrency(transferCost)}, e o clube não tem saldo disponível.';
    }

    final finalPlayer = target.listType == MarketListType.loan
        ? player.copyWith(
            isLoan: true,
            loanOriginClubId: 'external',
          )
        : player;

    final arrivalIsImmediate =
        target.listType == MarketListType.free || isTransferWindowOpen;

    if (arrivalIsImmediate) {
      final list = _proSquads.putIfAbsent(userClubId, () => <Player>[]);

      list.add(finalPlayer);

      _applyUserTransferExpenseWithSalary(
        transferCost: transferCost,
        salary: salary,
      );

      _removeScoutTargetEverywhere(target.jogadorId);

      _newsFeed.insert(
        0,
        '${outcome.title} — ${player.nome}. ${outcome.message}',
      );

      _newsFeed.insert(
        0,
        _buildScoutSigningNews(
          player: finalPlayer,
          listType: target.listType,
          transferCost: transferCost,
          marketValue: marketValue,
          salary: salary,
          isOpportunity: isOpportunity,
          discount: discount,
        ),
      );

      notifyListeners();

      switch (target.listType) {
        case MarketListType.free:
          return isOpportunity
              ? 'Oportunidade concluída com sucesso!'
              : 'Contratação concluída com sucesso!';
        case MarketListType.transfer:
          return isOpportunity
              ? 'Oportunidade de mercado concluída com sucesso!'
              : 'Transferência concluída com sucesso!';
        case MarketListType.loan:
          return isOpportunity
              ? 'Oportunidade de empréstimo concluído com sucesso!'
              : 'Empréstimo concluído com sucesso!';
      }
    }

    final arrivalDate = _nextTransferWindowDate();

    _futureArrivals.add(
      FutureArrival(
        player: finalPlayer,
        listType: target.listType,
        agreedCost: transferCost,
        agreedSalary: salary,
        marketValue: marketValue,
        arrivalYear: arrivalDate.year,
        arrivalMonth: arrivalDate.month,
        isOpportunity: isOpportunity,
        discount: discount,
      ),
    );

    _applyUserTransferAgreementExpense(
      transferCost: transferCost,
    );

    _removeScoutTargetEverywhere(target.jogadorId);

    _newsFeed.insert(
      0,
      '${outcome.title} — ${player.nome}. ${outcome.message}',
    );

    _newsFeed.insert(
      0,
      _buildFutureArrivalAgreementNews(
        player: finalPlayer,
        listType: target.listType,
        transferCost: transferCost,
        marketValue: marketValue,
        salary: salary,
        isOpportunity: isOpportunity,
        discount: discount,
        arrivalYear: arrivalDate.year,
        arrivalMonth: arrivalDate.month,
      ),
    );

    notifyListeners();

    final arrivalLabel = arrivalDate.month == 7
        ? 'julho/${arrivalDate.year}'
        : 'janeiro/${arrivalDate.year}';

    switch (target.listType) {
      case MarketListType.free:
        return 'Contratação concluída com sucesso!';
      case MarketListType.transfer:
        return isOpportunity
            ? 'Oportunidade fechada com sucesso! Chegada confirmada para $arrivalLabel.'
            : 'Transferência acertada com sucesso! Chegada confirmada para $arrivalLabel.';
      case MarketListType.loan:
        return isOpportunity
            ? 'Oportunidade de empréstimo fechada! Chegada confirmada para $arrivalLabel.'
            : 'Empréstimo acertado com sucesso! Chegada confirmada para $arrivalLabel.';
    }
  }

  bool _isMarketOpportunityTarget(ScoutTarget target) {
    return target.motivo.toLowerCase().contains('oportunidade de mercado');
  }

  double _opportunityDiscount(int financeLevel) {
    final level = financeLevel.clamp(1, 10);

    if (level <= 3) return 0.25;
    if (level <= 6) return 0.35;
    if (level <= 8) return 0.45;
    if (level == 9) return 0.50;
    return 0.60;
  }

  double _opportunitySuccessChance(int financeLevel) {
    final level = financeLevel.clamp(1, 10);

    if (level <= 3) return 0.75;
    if (level <= 6) return 0.80;
    if (level <= 8) return 0.85;
    if (level == 9) return 0.90;
    return 0.95;
  }

  NegotiationOutcome _resolveMarketOpportunityNegotiation(
    NegotiationPreview preview,
  ) {
    final chance = _opportunitySuccessChance(userFinanceiroLevel);
    final success = _rng.nextDouble() <= chance;

    if (success) {
      return NegotiationOutcome(
        type: NegotiationOutcomeType.success,
        success: true,
        title: 'Oportunidade aproveitada',
        message:
            'O Departamento Financeiro agiu rápido e conseguiu fechar uma condição rara por ${preview.playerName}. A operação saiu abaixo do valor normal de mercado e reforça a sensação de que o clube aproveitou uma brecha importante.',
      );
    }

    return NegotiationOutcome(
      type: NegotiationOutcomeType.failed,
      success: false,
      title: 'Oportunidade perdida',
      message:
          'Mesmo com o cenário favorável, a negociação por ${preview.playerName} caiu nos detalhes finais. Outros interessados se movimentaram rápido e o clube perdeu a janela ideal para fechar o negócio.',
    );
  }

  void _applyUserTransferExpenseWithSalary({
    required int transferCost,
    required int salary,
  }) {
    final currentFinance = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyTransferExpense(
      current: currentFinance,
      transferCost: transferCost,
      salary: salary,
    );
  }

  void _applyUserTransferAgreementExpense({
    required int transferCost,
  }) {
    final currentFinance = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] =
        _financeRuntimeService.applyTransferAgreementExpense(
      current: currentFinance,
      transferCost: transferCost,
    );
  }

  int _salaryForUserClubMarketValue(int marketValue) {
    return _financeRuntimeService.calculatePlayerSalary(
      finance: userFinance,
      financeLevel: userFinanceiroLevel,
      playerValue: marketValue,
    );
  }

  int _costToSignScoutPlayer({
    required Player player,
    required MarketListType listType,
  }) {
    switch (listType) {
      case MarketListType.free:
        return _financeRuntimeService.estimateFreeAgentSigningCost(
          playerOvr: player.ovrCheio,
          playerAge: player.idade,
          divisionId: _userDiv(),
        );

      case MarketListType.transfer:
        return estimatePlayerValueForUserClub(player);

      case MarketListType.loan:
        final fullValue = estimatePlayerValueForUserClub(player);
        return (fullValue * 0.12).round().clamp(0, fullValue);
    }
  }

  String _buildScoutSigningNews({
    required Player player,
    required MarketListType listType,
    required int transferCost,
    required int marketValue,
    required int salary,
    bool isOpportunity = false,
    double discount = 0.0,
  }) {
    final pos = _posLabelCompact(player.posDet);
    final costLabel = MoneyFormatter.formatCurrency(transferCost);
    final salaryLabel = MoneyFormatter.formatCurrency(salary);
    final marketLabel = MoneyFormatter.formatCurrency(marketValue);
    final discountPct = (discount * 100).round();

    if (isOpportunity) {
      return 'Oportunidade de mercado concluída — chegou ${player.nome}, $pos de OVR ${player.ovrCheio}. Valor estimado: $marketLabel. O clube fechou por $costLabel, com desconto aproximado de $discountPct%. Salário mensal: $salaryLabel.';
    }

    switch (listType) {
      case MarketListType.free:
        return 'MERCADO — Chegou ${player.nome}, $pos de OVR ${player.ovrCheio}. Livre no mercado, custou $costLabel em luvas. Valor de mercado estimado: $marketLabel. Salário mensal: $salaryLabel.';

      case MarketListType.transfer:
        return 'MERCADO — Chegou ${player.nome}, $pos de OVR ${player.ovrCheio}. O clube investiu $costLabel na transferência. Valor de mercado estimado: $marketLabel. Salário mensal: $salaryLabel.';

      case MarketListType.loan:
        return 'MERCADO — Chegou ${player.nome}, $pos de OVR ${player.ovrCheio}, por empréstimo. O custo inicial foi de $costLabel. Valor de mercado estimado: $marketLabel. Salário mensal: $salaryLabel.';
    }
  }

  String _buildFutureArrivalAgreementNews({
    required Player player,
    required MarketListType listType,
    required int transferCost,
    required int marketValue,
    required int salary,
    required int arrivalYear,
    required int arrivalMonth,
    bool isOpportunity = false,
    double discount = 0.0,
  }) {
    final pos = _posLabelCompact(player.posDet);
    final costLabel = MoneyFormatter.formatCurrency(transferCost);
    final salaryLabel = MoneyFormatter.formatCurrency(salary);
    final marketLabel = MoneyFormatter.formatCurrency(marketValue);
    final discountPct = (discount * 100).round();
    final monthLabel = arrivalMonth == 7 ? 'julho' : 'janeiro';

    final base = isOpportunity
        ? 'Oportunidade de mercado acertada — ${player.nome}, $pos de OVR ${player.ovrCheio}, teve a chegada confirmada para $monthLabel/$arrivalYear.'
        : '${listType == MarketListType.loan ? 'Empréstimo acertado' : 'Transferência acertada'} — ${player.nome}, $pos de OVR ${player.ovrCheio}, teve a chegada confirmada para $monthLabel/$arrivalYear.';

    final discountText = isOpportunity
        ? ' O clube aproveitou a brecha e fechou com desconto aproximado de $discountPct%.'
        : '';

    return '$base Valor estimado: $marketLabel. Custo fechado agora: $costLabel.$discountText Salário mensal previsto a partir da chegada: $salaryLabel.';
  }

  void _processFutureArrivalsForCurrentWindow() {
    if (!isTransferWindowOpen) return;
    if (_futureArrivals.isEmpty) return;

    final arriving = _futureArrivals.where((arrival) {
      return arrival.arrivalYear == currentDate.year &&
          arrival.arrivalMonth == currentDate.month;
    }).toList();

    if (arriving.isEmpty) return;

    final squad = _proSquads.putIfAbsent(userClubId, () => <Player>[]);

    for (final arrival in arriving) {
      if (squad.any((p) => p.id == arrival.player.id)) continue;

      squad.add(arrival.player);

      _insertNewsIfNew(
        _buildFutureArrivalCompletedNews(arrival),
      );
    }

    _futureArrivals.removeWhere((arrival) {
      return arrival.arrivalYear == currentDate.year &&
          arrival.arrivalMonth == currentDate.month;
    });

    _recalculateMonthlyWageForClub(userClubId);
  }

  String _buildFutureArrivalCompletedNews(FutureArrival arrival) {
    final player = arrival.player;
    final pos = _posLabelCompact(player.posDet);
    final salaryLabel = MoneyFormatter.formatCurrency(arrival.agreedSalary);

    switch (arrival.listType) {
      case MarketListType.free:
        return 'MERCADO — Chegada confirmada. ${player.nome}, $pos de OVR ${player.ovrCheio}, já está integrado ao elenco. Salário mensal: $salaryLabel.';

      case MarketListType.transfer:
        return 'MERCADO — Chegada confirmada. ${player.nome}, $pos de OVR ${player.ovrCheio}, apresentou-se ao clube após acordo antecipado. Salário mensal: $salaryLabel.';

      case MarketListType.loan:
        return 'MERCADO — Chegada confirmada. ${player.nome}, $pos de OVR ${player.ovrCheio}, chegou por empréstimo após acordo antecipado. Salário mensal: $salaryLabel.';
    }
  }

  void _removeScoutTargetEverywhere(String jogadorId) {
    _scoutTransfers.removeWhere((t) => t.jogadorId == jogadorId);
    _scoutLoans.removeWhere((t) => t.jogadorId == jogadorId);
    _scoutFrees.removeWhere((t) => t.jogadorId == jogadorId);
  }

  String _posLabelCompact(PosDet pos) {
    switch (pos) {
      case PosDet.gol:
        return 'goleiro';
      case PosDet.ld:
        return 'lateral-direito';
      case PosDet.le:
        return 'lateral-esquerdo';
      case PosDet.zag:
        return 'zagueiro';
      case PosDet.vol:
        return 'volante';
      case PosDet.mc:
        return 'meio-campista';
      case PosDet.mei:
        return 'meia';
      case PosDet.pd:
        return 'ponta-direita';
      case PosDet.pe:
        return 'ponta-esquerda';
      case PosDet.ca:
        return 'centroavante';
    }
  }
}
