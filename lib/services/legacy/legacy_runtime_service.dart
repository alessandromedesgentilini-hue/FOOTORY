import 'package:footory26/models/league_table.dart';
import 'package:footory26/services/legacy/club_legacy.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class LegacySeasonResult {
  final int seasonPoints;
  final int totalPoints;
  final ClubLegacyEntry updatedEntry;
  final String summaryLine;

  const LegacySeasonResult({
    required this.seasonPoints,
    required this.totalPoints,
    required this.updatedEntry,
    required this.summaryLine,
  });
}

class LegacyRuntimeService {
  const LegacyRuntimeService();

  ClubLegacyEntry? getClubLegacy(
    Map<String, ClubLegacyEntry> legacyMap,
    String clubId,
  ) {
    if (clubId.trim().isEmpty) return null;
    return legacyMap[clubId];
  }

  void restoreLegacyMap({
    required Map<String, ClubLegacyEntry> target,
    required Map<String, ClubLegacyEntry> source,
  }) {
    target
      ..clear()
      ..addAll(source);
  }

  LegacySeasonResult processSeasonEnd({
    required String clubId,
    required String clubName,
    required DivisionId divisionId,
    required Map<DivisionId, LeagueTable> tablesByDivision,
    required Map<String, ClubLegacyEntry> legacyMap,
  }) {
    final seasonPoints = calculateSeasonPerformancePoints(
      clubId: clubId,
      divisionId: divisionId,
      tablesByDivision: tablesByDivision,
    );

    final current = legacyMap[clubId];

    final updated = current == null
        ? ClubLegacyEntry(
            clubId: clubId,
            totalPoints: seasonPoints,
            seasons: 1,
          )
        : current.copyWith(
            totalPoints: current.totalPoints + seasonPoints,
            seasons: current.seasons + 1,
          );

    legacyMap[clubId] = updated;

    final summaryLine =
        '${_buildSeasonSummaryLine(seasonPoints)} — ${ClubLegacyHelper.label(updated.totalPoints)} no $clubName.';

    return LegacySeasonResult(
      seasonPoints: seasonPoints,
      totalPoints: updated.totalPoints,
      updatedEntry: updated,
      summaryLine: summaryLine,
    );
  }

  int calculateSeasonPerformancePoints({
    required String clubId,
    required DivisionId divisionId,
    required Map<DivisionId, LeagueTable> tablesByDivision,
  }) {
    final userTable = tablesByDivision[divisionId];
    if (userTable == null) return 0;

    final sorted = userTable.getSorted();
    final index = sorted.indexWhere((row) => row.clubId == clubId);
    if (index < 0) return 0;

    final position = index + 1;
    final divisionWeight = _divisionWeight(divisionId);

    final base = _basePointsForPosition(position);
    final weightedBonus = _weightedBonusForPosition(
      position: position,
      divisionWeight: divisionWeight,
    );

    return base + weightedBonus;
  }

  int _basePointsForPosition(int position) {
    if (position == 1) return 8;
    if (position == 2) return 5;
    if (position <= 4) return 4;
    if (position <= 8) return 2;
    if (position <= 12) return 1;
    if (position <= 16) return 0;
    if (position <= 18) return -2;
    return -4;
  }

  int _weightedBonusForPosition({
    required int position,
    required int divisionWeight,
  }) {
    if (position == 1) return divisionWeight * 2;
    if (position <= 4) return divisionWeight;
    if (position >= 19) return -divisionWeight;
    if (position >= 17) return -(divisionWeight / 2).round();

    return 0;
  }

  int _divisionWeight(DivisionId divisionId) {
    switch (divisionId) {
      case DivisionId.brA:
        return 4;
      case DivisionId.brB:
        return 3;
      case DivisionId.brC:
        return 2;
      case DivisionId.brD:
        return 1;
    }
  }

  String _buildSeasonSummaryLine(int seasonPoints) {
    if (seasonPoints >= 14) {
      return 'TEMPORADA LENDÁRIA — O clube viveu um ano que aumenta muito seu peso histórico';
    }

    if (seasonPoints >= 10) {
      return 'TEMPORADA HISTÓRICA — O clube encerra o ano com forte ganho de reputação';
    }

    if (seasonPoints >= 6) {
      return 'TEMPORADA MARCANTE — A campanha fortalece a imagem esportiva do clube';
    }

    if (seasonPoints >= 3) {
      return 'TEMPORADA POSITIVA — O clube sai do ano mais respeitado';
    }

    if (seasonPoints >= 1) {
      return 'TEMPORADA ESTÁVEL — O clube mantém sua reputação em leve crescimento';
    }

    if (seasonPoints == 0) {
      return 'TEMPORADA NEUTRA — O clube fecha o ano sem grande mudança de reputação';
    }

    if (seasonPoints >= -2) {
      return 'TEMPORADA DE ALERTA — A campanha gera cobrança e pequena perda de confiança';
    }

    if (seasonPoints >= -4) {
      return 'TEMPORADA FRUSTRANTE — O clube perde força simbólica no cenário esportivo';
    }

    return 'TEMPORADA CRÍTICA — O ano deixa uma marca negativa na reputação do clube';
  }
}
