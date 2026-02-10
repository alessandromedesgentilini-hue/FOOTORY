import '../models/jogador.dart';
import '../repo/save_state.dart';
import '../repo/seed_repo.dart';

class RosterPipeline {
  final SeedRepo seeds;
  RosterPipeline(this.seeds);

  Map<String, Jogador> buildCatalog() {
    return seeds.loadPlayersSerieA(); // no futuro: aplicar overrides/mods aqui
  }

  SaveState createSave() {
    return seeds.createInitialSaveSerieA();
  }
}
