import 'package:footory26/models/fixture.dart';

class LeagueScheduler {
  const LeagueScheduler();

  /// Gera SOMENTE os fixtures (ida+volta).
  /// Datas são responsabilidade do SeasonClock (calendar/).
  List<Fixture> generateDoubleRoundRobin({
    required List<String> clubIds,
  }) {
    if (clubIds.length != 20) {
      throw StateError(
          'Liga precisa ter 20 clubes, mas tem ${clubIds.length}.');
    }

    final list = List<String>.from(clubIds);
    if (list.length.isOdd) list.add('BYE');

    final n = list.length;
    final half = n ~/ 2;
    final roundsPerLeg = n - 1;

    final rot = List<String>.from(list);
    final out = <Fixture>[];

    int round = 1;

    // Ida
    for (int r = 0; r < roundsPerLeg; r++) {
      for (int i = 0; i < half; i++) {
        final a = rot[i];
        final b = rot[n - 1 - i];
        if (a == 'BYE' || b == 'BYE') continue;

        final home = (r.isEven) ? a : b;
        final away = (r.isEven) ? b : a;

        out.add(Fixture(round: round, homeClubId: home, awayClubId: away));
      }
      round++;

      // rotate (fix first)
      final fixed = rot.first;
      final rest = rot.sublist(1);
      final last = rest.removeLast();
      rest.insert(0, last);
      rot
        ..clear()
        ..add(fixed)
        ..addAll(rest);
    }

    // Volta (espelha a ida)
    for (int r = 0; r < roundsPerLeg; r++) {
      final idaRound = r + 1;
      final idaDaRodada = out.where((f) => f.round == idaRound).toList();

      for (final fx in idaDaRodada) {
        out.add(Fixture(
          round: round,
          homeClubId: fx.awayClubId,
          awayClubId: fx.homeClubId,
        ));
      }
      round++;
    }

    return out;
  }
}
