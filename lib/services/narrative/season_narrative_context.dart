import 'package:footory26/services/club_status/club_status_runtime.dart';
import 'package:footory26/services/season/season_expectation_snapshot.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class SeasonNarrativeContext {
  final String clubName;

  final DivisionId division;

  final int finalPosition;
  final int totalClubs;
  final int points;

  final bool promoted;
  final bool relegated;

  final ClubStatusSnapshot clubStatus;

  final SeasonExpectationSnapshot expectation;

  final int legacyPoints;

  final double initialPower10;
  final double currentPower10;

  const SeasonNarrativeContext({
    required this.clubName,
    required this.division,
    required this.finalPosition,
    this.totalClubs = 20,
    required this.points,
    required this.promoted,
    required this.relegated,
    required this.clubStatus,
    required this.expectation,
    required this.legacyPoints,
    required this.initialPower10,
    required this.currentPower10,
  });

  double get positionPercentile {
    if (totalClubs <= 0) return 1.0;
    return (finalPosition / totalClubs).clamp(0.0, 1.0);
  }

  bool get finishedTopQuarter => positionPercentile <= 0.25;
  bool get finishedBottomQuarter => positionPercentile >= 0.75;
}
