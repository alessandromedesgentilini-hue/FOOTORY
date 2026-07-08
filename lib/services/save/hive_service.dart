import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _boxName = 'futsim_save_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> putJson(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  static Map<String, dynamic>? getJson(String key) {
    final v = _box.get(key);
    if (v == null) return null;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  static Future<void> delete(String key) async {
    await _box.delete(key);
  }

  static bool has(String key) => _box.containsKey(key);
}
