// lib/services/io/save_service.dart
//
// Persistência simples do "core" do save (clube escolhido + estilo).
// Usa SharedPreferences gravando um JSON minimalista com versionamento.
//
// API:
//   await SaveService.saveCore(slug: 'palestra-italia', estilo: Estilo.transicao);
//   final core = await SaveService.loadCore(); // CoreSave? (null se não existir)
//   final has = await SaveService.hasCore();
//   await SaveService.clearCore();
//
// Extras:
//  - Migração automática de chaves legadas: 'career.club' / 'career.estilo'.
//

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futsim/models/estilos.dart';

const String _kCoreKey = 'futsim.core.v1';
const int _kCoreVersion = 1;

// chaves legadas (utilizadas por versões antigas / CareerState)
const String _kLegacyClub = 'career.club';
const String _kLegacyEstilo = 'career.estilo';

class CoreSave {
  final int version;
  final String clubSlug;
  final Estilo estilo;

  const CoreSave({
    required this.version,
    required this.clubSlug,
    required this.estilo,
  });

  Map<String, dynamic> toJson() => {
        'v': version,
        'club': clubSlug,
        'estilo': estilo.name, // enum -> string canônica
      };

  static CoreSave? fromJson(Map<String, dynamic>? m) {
    if (m == null) return null;
    final slug = m['club'] as String?;
    final eName = m['estilo'] as String?;
    if (slug == null || slug.isEmpty || eName == null || eName.isEmpty) {
      return null;
    }
    final ver = (m['v'] is int) ? (m['v'] as int) : _kCoreVersion;
    final e = _estiloFromName(eName);
    return CoreSave(version: ver, clubSlug: slug, estilo: e);
  }

  static Estilo _estiloFromName(String n) {
    // Usa o normalizador robusto do enum (aceita variações/acentos/sinônimos)
    return EstiloX.fromString(n, fallback: Estilo.transicao);
  }
}

class SaveService {
  SaveService._();

  /// Salva o núcleo do save (club + estilo), sobrescrevendo a versão atual.
  static Future<void> saveCore({
    required String slug,
    required Estilo estilo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final core =
        CoreSave(version: _kCoreVersion, clubSlug: slug, estilo: estilo);
    await prefs.setString(_kCoreKey, jsonEncode(core.toJson()));
  }

  /// Carrega o núcleo do save.
  /// - Tenta a chave atual.
  /// - Se não existir, tenta migrar de chaves legadas e já persiste no formato novo.
  static Future<CoreSave?> loadCore() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Tenta formato atual
    final raw = prefs.getString(_kCoreKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return CoreSave.fromJson(map);
      } catch (_) {
        // Se corrompido, cai para tentativa de migração
      }
    }

    // 2) Migração automática de chaves legadas
    final legacyClub = prefs.getString(_kLegacyClub);
    final legacyEst = prefs.getString(_kLegacyEstilo);
    if (legacyClub != null && legacyEst != null) {
      final estilo = CoreSave._estiloFromName(legacyEst);
      final migrated = CoreSave(
        version: _kCoreVersion,
        clubSlug: legacyClub,
        estilo: estilo,
      );
      // Persiste no novo formato
      await prefs.setString(_kCoreKey, jsonEncode(migrated.toJson()));
      return migrated;
    }

    // Nada encontrado
    return null;
  }

  /// Verifica se já existe um save core.
  static Future<bool> hasCore() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_kCoreKey)) return true;
    // também considera legado para resposta mais amigável
    return prefs.containsKey(_kLegacyClub) && prefs.containsKey(_kLegacyEstilo);
  }

  /// Limpa o núcleo do save (não apaga chaves legadas).
  static Future<void> clearCore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCoreKey);
  }
}
