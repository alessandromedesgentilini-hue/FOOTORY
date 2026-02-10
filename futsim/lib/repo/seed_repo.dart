import '../world/brasil/serie_a/players.dart';
import '../world/brasil/serie_a/rosters/_registry.dart';
import '../models/jogador.dart';
import 'save_state.dart';

class SeedRepo {
  Map<String, Jogador> loadPlayersSerieA() => playersBRSerieA2025();

  List<String> loadRosterSerieA(String slug) {
    final fn = rostersSerieA2025[slug];
    return fn != null ? fn() : <String>[];
  }

  SaveState createInitialSaveSerieA() {
    final map = <String, List<String>>{};
    rostersSerieA2025.forEach((slug, getter) => map[slug] = getter());
    return SaveState.fromSeeds(map);
  }
}
