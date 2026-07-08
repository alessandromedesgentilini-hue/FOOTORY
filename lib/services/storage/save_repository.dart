import '../world/game_state.dart';
import 'hive_service.dart';

class SaveRepository {
  // MVP: 1 slot só
  static const String careerKey = 'career_slot_1';

  static bool hasCareer() => HiveService.hasKey(careerKey);

  static Future<void> saveCareer() async {
    final data = GameState.I.toJson();
    await HiveService.putMap(careerKey, data);
  }

  static Future<bool> loadCareer() async {
    final data = HiveService.getMap(careerKey);
    if (data == null) return false;

    GameState.I.loadFromJsonMap(data);
    return true;
  }

  static Future<void> clearCareer() async {
    await HiveService.deleteKey(careerKey);
  }
}
