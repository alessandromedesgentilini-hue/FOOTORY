// lib/services/save/simple_save.dart
//
// Fachada simples sobre SaveService (services/io/save_service.dart).
// - Evita duplicar persistência (uma única fonte de verdade).
// - Migra automaticamente dos antigos _kClubSlug/_kEstilo (SharedPreferences)
//   para o formato novo (JSON com nome do enum).
//
// API compatível:
//   await SimpleSave.saveClubAndStyle(slug, estilo);
//   final slug = await SimpleSave.loadClubSlug();
//   final estilo = await SimpleSave.loadEstilo();
//   await SimpleSave.clearAll();

import 'package:shared_preferences/shared_preferences.dart';
import '../../models/estilos.dart';
import '../io/save_service.dart';

class SimpleSave {
  // chaves legadas (v0) — usadas só para migração
  static const _kClubSlug = 'save.club_slug';
  static const _kEstilo = 'save.estilo';

  /// Migra dados antigos (se houver) para o SaveService e limpa chaves legadas.
  static Future<void> _maybeMigrate() async {
    final hasCore = await SaveService.hasCore();
    if (hasCore) return;

    final sp = await SharedPreferences.getInstance();
    final slug = sp.getString(_kClubSlug);
    final idx = sp.getInt(_kEstilo);

    if (slug != null && idx != null && idx >= 0 && idx < Estilo.values.length) {
      final estilo = Estilo.values[idx];
      await SaveService.saveCore(slug: slug, estilo: estilo);
      await sp.remove(_kClubSlug);
      await sp.remove(_kEstilo);
    }
  }

  /// Salva clube + estilo escolhidos (formato novo via SaveService).
  static Future<void> saveClubAndStyle(String slug, Estilo estilo) async {
    await SaveService.saveCore(slug: slug, estilo: estilo);
    // opcional: limpa vestígios legados
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kClubSlug);
    await sp.remove(_kEstilo);
  }

  /// Lê o clube salvo (ou null).
  static Future<String?> loadClubSlug() async {
    await _maybeMigrate();
    final core = await SaveService.loadCore();
    return core?.clubSlug;
  }

  /// Lê o estilo salvo (ou null).
  static Future<Estilo?> loadEstilo() async {
    await _maybeMigrate();
    final core = await SaveService.loadCore();
    return core?.estilo;
  }

  /// Limpa tudo (usado em “Novo jogo”).
  static Future<void> clearAll() async {
    await SaveService.clearCore();
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kClubSlug);
    await sp.remove(_kEstilo);
  }
}
