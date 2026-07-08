part of '../game_state.dart';

extension YouthHandler on GameState {
  void _runAnnualYouthIntakeIfNeeded() {
    if (_annualYouthProcessed) return;

    _currentDate = DateTime(_seasonYear, 1, 1);
    dateStr = _formatDate(_currentDate);

    _ageUserSquadByOneYear();

    _newsFeed.insert(0, '01/01 — Virada de ano. Elencos envelhecem +1.');

    final created = _applyYouthIntakeToUserClub();

    final title = 'Base anual';
    final body = created <= 0
        ? 'Nenhum atleta subiu da base este ano.'
        : 'A base revelou $created atleta(s) que já integram o elenco profissional.';
    _newsFeed.insert(0, '$title — $body');

    _pendingCheckpoint ??= SeasonCheckpoint(
      round: 0,
      phase: 'youth',
      title: title,
      body: body,
      tag: created >= 2 ? 'good' : 'neutral',
    );

    _annualYouthProcessed = true;
  }

  void _ageUserSquadByOneYear() {
    final squad = _proSquads[userClubId];
    if (squad == null || squad.isEmpty) return;

    for (var i = 0; i < squad.length; i++) {
      final p = squad[i];
      squad[i] = p.copyWith(idade: p.idade + 1);
    }
  }

  int _applyYouthIntakeToUserClub() {
    final academyLevel = _userAcademyLevel();
    final qtd = _rollYouthCount(academyLevel);

    if (qtd <= 0) return 0;

    final list = _proSquads.putIfAbsent(userClubId, () => <Player>[]);

    Player? best;
    var bestOvr = -1;

    for (var i = 0; i < qtd; i++) {
      final pos = _pickYouthPos();
      final range = _rollYouthOvrCheioRange(academyLevel);

      final p = _playerFactory.criarJogadorComOvrCheioTarget(
        posDet: pos,
        nacionalidade: 'BR',
        idadeMin: range.$3,
        idadeMax: range.$4,
        minOvrCheio: range.$1,
        maxOvrCheio: range.$2,
        maxTries: 35,
      );

      list.add(p);

      final o = p.ovrCheio;
      if (o > bestOvr) {
        bestOvr = o;
        best = p;
      }

      final tier = _youthTierLabelByOvr(o);
      _newsFeed.insert(
        0,
        'Base: ${p.nome} (${p.posDet.name.toUpperCase()}) — ${p.idade} anos — $tier ($o).',
      );
    }

    if (best != null) {
      final tier = _youthTierLabelByOvr(bestOvr);
      _newsFeed.insert(
        0,
        'Destaque da geração: ${best.nome} (${best.posDet.name.toUpperCase()}) — ${best.idade} anos — $tier (${best.ovrCheio}).',
      );
    }

    return qtd;
  }

  int _userAcademyLevel() {
    return userBaseLevel;
  }

  int _rollYouthCount(int level) {
    final ranges = <int, List<int>>{
      1: [1, 1],
      2: [1, 1],
      3: [1, 2],
      4: [1, 3],
      5: [2, 4],
      6: [2, 4],
      7: [3, 5],
      8: [3, 6],
      9: [4, 6],
      10: [4, 7],
    };

    final r = ranges[level.clamp(1, 10)] ?? const [1, 2];
    return _rng.nextInt(r[1] - r[0] + 1) + r[0];
  }

  (int, int, int, int) _rollYouthOvrCheioRange(int level) {
    final minMap = <int, int>{
      1: 30,
      2: 35,
      3: 38,
      4: 40,
      5: 42,
      6: 46,
      7: 50,
      8: 54,
      9: 56,
      10: 59,
    };

    final min = minMap[level.clamp(1, 10)] ?? 38;
    const max = 65;

    final roll = _rng.rangeInt(1, 100);
    if (roll <= 10) {
      return (min, max, 16, 17);
    }
    return (min, max, 18, 20);
  }

  PosDet _pickYouthPos() {
    const pool = <PosDet>[
      PosDet.zag,
      PosDet.ld,
      PosDet.le,
      PosDet.vol,
      PosDet.mc,
      PosDet.mei,
      PosDet.pd,
      PosDet.pe,
      PosDet.ca,
      PosDet.gol,
    ];
    return pool[_rng.nextInt(pool.length)];
  }

  String _youthTierLabelByOvr(int ovrCheio) {
    if (ovrCheio >= 59) return 'Talento geracional';
    if (ovrCheio >= 57) return 'Joia do clube';
    if (ovrCheio >= 50) return 'Grande talento';
    if (ovrCheio >= 46) return 'Promessa';
    if (ovrCheio >= 41) return 'Potencial interessante';
    return 'Jogador de grupo';
  }
}
