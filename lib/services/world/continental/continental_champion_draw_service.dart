import 'package:footory26/core/seeded_rng.dart';
import '../catalog/world_club_summary.dart';

class ContinentalChampionDrawService {
  const ContinentalChampionDrawService._();

  /// Sorteia um campeão usando peso por força base.
  ///
  /// Regra:
  /// - Clubes mais fortes têm mais chance.
  /// - Não é determinístico por força pura.
  /// - Peso = basePower².
  static WorldClubSummary drawChampion({
    required List<WorldClubSummary> clubs,
    required SeededRng rng,
  }) {
    if (clubs.isEmpty) {
      throw StateError(
          'Não é possível sortear campeão continental sem clubes.');
    }

    final weights = clubs.map(_weightForClub).toList(growable: false);
    final totalWeight = weights.fold<double>(0, (sum, value) => sum + value);

    if (totalWeight <= 0) {
      return clubs.first;
    }

    final roll = rng.nextDouble() * totalWeight;

    var cursor = 0.0;

    for (var i = 0; i < clubs.length; i++) {
      cursor += weights[i];

      if (roll <= cursor) {
        return clubs[i];
      }
    }

    return clubs.last;
  }

  static double _weightForClub(WorldClubSummary club) {
    final power = club.basePower.clamp(1.0, 10.0);
    return power * power;
  }
}
