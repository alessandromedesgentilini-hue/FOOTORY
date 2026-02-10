import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../mods/roster_overrides.dart';

class ModInstaller {
  static Future<Directory> _modsRosterDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'FutSim', 'mods', 'rosters'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<RosterOverrides> installFromUrl(String url) async {
    final uri = Uri.parse(url);
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao baixar pack (HTTP ${resp.statusCode}).');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (!data.containsKey('overrides') || data['overrides'] is not List) {
      throw Exception('Pack inválido: campo "overrides" ausente.');
    }
    final pack = RosterOverrides.fromJson(data);
    final dir = await _modsRosterDir();
    final file = File(p.join(dir.path, 'overrides.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data), flush: true);
    return pack;
  }

  static Future<RosterOverrides?> readActivePack() async {
    final dir = await _modsRosterDir();
    final file = File(p.join(dir.path, 'overrides.json'));
    if (!await file.exists()) return null;
    final txt = await file.readAsString();
    try {
      final j = jsonDecode(txt) as Map<String, dynamic>;
      return RosterOverrides.fromJson(j);
    } catch (_) {
      return null;
    }
  }

  static Future<void> uninstallPack() async {
    final dir = await _modsRosterDir();
    final file = File(p.join(dir.path, 'overrides.json'));
    if (await file.exists()) await file.delete();
  }

  static Future<String> modsFolderPath() async => (await _modsRosterDir()).path;
}
