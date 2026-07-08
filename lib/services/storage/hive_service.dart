import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _boxName = 'futsim_save_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> putMap(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  static Map<String, dynamic>? getMap(String key) {
    final v = _box.get(key);
    if (v == null) return null;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  static bool hasKey(String key) => _box.containsKey(key);

  static Future<void> deleteKey(String key) async {
    await _box.delete(key);
  }
}
