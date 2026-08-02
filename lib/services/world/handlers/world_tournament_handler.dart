part of '../game_state.dart';

extension WorldTournamentHandler on GameState {
  void _recordSimonBolivarSeasonResultIfNeeded(
    String championClubId,
  ) {
    if (championClubId.trim().isEmpty) return;

    final alreadyRecorded = _simonBolivarHistory.any(
      (result) => result.seasonYear == _seasonYear,
    );

    if (alreadyRecorded) return;

    final finalFixture = _simonBolivarFinalFixture();
    if (finalFixture == null) return;

    final runnerUpClubId = championClubId == finalFixture.homeClubId
        ? finalFixture.awayClubId
        : finalFixture.homeClubId;

    final fallback = _buildSimonBolivarFallbackQualifiedIds(
      championClubId: championClubId,
      runnerUpClubId: runnerUpClubId,
    );

    _simonBolivarHistory.add(
      SimonBolivarSeasonResult(
        seasonYear: _seasonYear,
        championClubId: championClubId,
        runnerUpClubId: runnerUpClubId,
        fallbackQualifiedClubIds: fallback,
      ),
    );
  }

  CupFixture? _simonBolivarFinalFixture() {
    if (_simonBolivarKnockoutFixtures.isEmpty) return null;

    final maxPhase =
        _simonBolivarKnockoutFixtures.map((fixture) => fixture.phase).fold<int>(
              0,
              (a, b) => a > b ? a : b,
            );

    final finals = _simonBolivarKnockoutFixtures
        .where((fixture) => fixture.phase == maxPhase)
        .toList();

    if (finals.isEmpty) return null;

    return finals.last;
  }

  List<String> _buildSimonBolivarFallbackQualifiedIds({
    required String championClubId,
    required String runnerUpClubId,
  }) {
    final ids = <String>[];

    final ordered = List<CupFixture>.from(
      _simonBolivarKnockoutFixtures,
    )..sort((a, b) {
        final phase = b.phase.compareTo(a.phase);

        if (phase != 0) return phase;

        return b.leg.compareTo(a.leg);
      });

    for (final fixture in ordered) {
      for (final clubId in <String>[
        fixture.homeClubId,
        fixture.awayClubId,
      ]) {
        if (clubId == championClubId) continue;
        if (clubId == runnerUpClubId) continue;
        if (ids.contains(clubId)) continue;

        ids.add(clubId);
      }
    }

    return List<String>.unmodifiable(ids);
  }

  void _ensureSimonBolivarCompletedForSeason() {
    for (var i = 0; i < 8; i++) {
      final before = _simonBolivarKnockoutFixtures.length;

      _simulateSimonBolivarBetweenDates(
        fromDate: DateTime(_seasonYear, 1, 1),
        toDate: DateTime(_seasonYear, 12, 31),
      );

      final championId = _simonBolivarService.resolveChampion(
        knockoutFixtures: _simonBolivarKnockoutFixtures,
      );

      if (championId != null) return;

      if (_simonBolivarKnockoutFixtures.length == before && i > 0) {
        return;
      }
    }
  }

  void _runWorldTournamentsForSeasonEnd() {
    _ensureSimonBolivarCompletedForSeason();

    final simonResult = _simonBolivarHistory
        .where(
          (result) => result.seasonYear == _seasonYear,
        )
        .cast<SimonBolivarSeasonResult?>()
        .firstWhere(
          (result) => result != null,
          orElse: () => null,
        );

    if (simonResult == null) {
      _insertNewsIfNew(
        'ATLAS — Os torneios mundiais não foram executados porque a Simón Bolívar ainda não tem campeão registrado.',
      );

      return;
    }

    _runAtlasClubForSeason(
      simonResult.championClubId,
    );

    _runAtlasChampionsClubIfNeeded();
  }

  void _runAtlasClubForSeason(
    String simonBolivarChampionClubId,
  ) {
    final alreadyPlayed = _atlasClubHistory.any(
      (result) => result.seasonYear == _seasonYear,
    );

    if (alreadyPlayed) return;

    final result = WorldTournamentService.runAtlasClub(
      seasonYear: _seasonYear,
      simonBolivarChampionClubId: simonBolivarChampionClubId,
      rng: _rng,
    );

    _atlasClubHistory.add(result);

    final summary = WorldTournamentService.atlasClubSummary(
      result,
    );

    _addWorldTournamentSummaryIfNeeded(summary);

    if (result.championClubId == userClubId) {
      _registerDirectorWorldTrophy(
        competitionId: 'ATL',
        competitionName: 'ATLAS Club',
      );
    }

    _insertNewsIfNew(
      'ATLAS Club — ${_worldClubName(result.championClubId)} venceu '
      '${_worldClubName(result.runnerUpClubId)} e conquistou o título '
      'mundial da temporada.',
    );
  }

  void _runAtlasChampionsClubIfNeeded() {
    final alreadyPlayed = _atlasChampionsHistory.any(
      (result) => result.seasonYear == _seasonYear,
    );

    if (alreadyPlayed) return;

    final result = WorldTournamentService.runAtlasChampionsClub(
      seasonYear: _seasonYear,
      simonBolivarResults: _simonBolivarHistory,
      rng: _rng,
    );

    if (result == null) return;

    _atlasChampionsHistory.add(result);

    final summary = WorldTournamentService.atlasChampionsSummary(
      result,
    );

    _addWorldTournamentSummaryIfNeeded(summary);

    if (result.championClubId == userClubId) {
      _registerDirectorWorldTrophy(
        competitionId: 'ATLC',
        competitionName: 'ATLAS Champions Club',
      );
    }

    _insertNewsIfNew(
      'ATLAS Champions Club — '
      '${_worldClubName(result.championClubId)} derrotou '
      '${_worldClubName(result.runnerUpClubId)} e conquistou o '
      'Super Mundial de Clubes.',
    );
  }

  void _registerDirectorWorldTrophy({
    required String competitionId,
    required String competitionName,
  }) {
    _ensureDirectorCareerForCurrentSeason();

    final career = _directorCareer;
    if (career == null) return;

    _directorCareer = career.registerTrophy(
      competitionId: competitionId,
      competitionName: competitionName,
      seasonYear: _seasonYear,
      clubId: userClubId,
      clubName: userClubName,
    );
  }

  void _addWorldTournamentSummaryIfNeeded(
    WorldTournamentResult result,
  ) {
    final exists = _worldTournamentHistory.any(
      (item) =>
          item.seasonYear == result.seasonYear &&
          item.competitionId == result.competitionId,
    );

    if (exists) return;

    _worldTournamentHistory.add(result);
  }

  String _worldClubName(
    String clubId,
  ) {
    final local = _clubNames[clubId];

    if (local != null && local.trim().isNotEmpty) {
      return local;
    }

    final world = WorldClubRegistry.byId(clubId);

    if (world != null) {
      return world.name;
    }

    return clubId;
  }
}
