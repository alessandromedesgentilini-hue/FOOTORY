import 'package:footory26/models/fixture.dart';
import 'package:footory26/services/calendar/season_clock.dart';
import 'package:footory26/services/league_scheduler.dart';

class LeagueSeasonBundle {
  final List<Fixture> fixtures;
  final Map<int, DateTime> roundDates;
  final int totalRounds;

  const LeagueSeasonBundle({
    required this.fixtures,
    required this.roundDates,
    required this.totalRounds,
  });

  List<Fixture> fixturesOfRound(int round) =>
      fixtures.where((f) => f.round == round).toList();

  LeagueSeasonBundle copyWith({
    List<Fixture>? fixtures,
    Map<int, DateTime>? roundDates,
    int? totalRounds,
  }) {
    return LeagueSeasonBundle(
      fixtures: fixtures ?? this.fixtures,
      roundDates: roundDates ?? this.roundDates,
      totalRounds: totalRounds ?? this.totalRounds,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fixtures': fixtures.map((f) => f.toJson()).toList(),
      'roundDates': roundDates.map(
        (round, date) => MapEntry(round.toString(), date.toIso8601String()),
      ),
      'totalRounds': totalRounds,
    };
  }

  factory LeagueSeasonBundle.fromJson(Map<String, dynamic> json) {
    final rawFixtures = json['fixtures'] as List?;
    final rawDates = (json['roundDates'] as Map?)?.cast<String, dynamic>();

    final fixtures = rawFixtures == null
        ? <Fixture>[]
        : rawFixtures
            .whereType<Map>()
            .map((e) => Fixture.fromJson(e.cast<String, dynamic>()))
            .toList();

    final roundDates = <int, DateTime>{};

    if (rawDates != null) {
      for (final entry in rawDates.entries) {
        final round = int.tryParse(entry.key);
        final date = DateTime.tryParse(entry.value.toString());

        if (round != null && date != null) {
          roundDates[round] = date;
        }
      }
    }

    final totalRounds = _readInt(json['totalRounds'],
        fallback: _maxRoundFromFixtures(fixtures));

    return LeagueSeasonBundle(
      fixtures: fixtures,
      roundDates: roundDates,
      totalRounds: totalRounds,
    );
  }

  static int _maxRoundFromFixtures(List<Fixture> fixtures) {
    return fixtures.fold<int>(0, (m, f) => f.round > m ? f.round : m);
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }
}

class SeasonService {
  final LeagueScheduler _leagueScheduler;

  const SeasonService({LeagueScheduler scheduler = const LeagueScheduler()})
      : _leagueScheduler = scheduler;

  LeagueSeasonBundle buildLeagueSeason({
    required int year,
    required List<String> clubIds,
  }) {
    final fixtures =
        _leagueScheduler.generateDoubleRoundRobin(clubIds: clubIds);

    final maxRound = fixtures.fold<int>(0, (m, f) => f.round > m ? f.round : m);

    final clock = SeasonClock(year);
    final roundDates = clock.buildLeagueRoundDates(totalRounds: maxRound);

    return LeagueSeasonBundle(
      fixtures: fixtures,
      roundDates: roundDates,
      totalRounds: maxRound,
    );
  }
}
