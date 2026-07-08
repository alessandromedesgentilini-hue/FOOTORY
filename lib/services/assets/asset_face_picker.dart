// lib/services/assets/asset_face_picker.dart
//
// Picker utilitário para escolher rostos a partir do AssetManifest.
// - Lê somente uma vez e mantém cache em memória.
// - Suporta `assets/rostos/` e `assets/rostos_base/`.
// - Filtra por extensões de imagem.
// - Fornece helpers: `any()`, `many()`, `all()` e `warmUp()`.
//
// Observações
// - Não depende de nenhuma outra classe (ex.: FacePool). Se quiser um
//   placeholder padrão, use `_kDefault` daqui ou seu próprio resolver.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class AssetFacePicker {
  AssetFacePicker._();

  static const String _kManifestPath = 'AssetManifest.json';
  static const String _kDirRostos = 'assets/rostos/';
  static const String _kDirRostosBase = 'assets/rostos_base/';
  static const String _kDefault = 'assets/rostos/_default.png';

  static final Random _rng = Random();

  static List<String>? _cacheAll; // cache combinado (rostos + rostos_base)

  /// Pré-carrega o manifest (opcional).
  static Future<void> warmUp() async {
    await _loadAllIfNeeded();
  }

  /// Limpa o cache (força nova leitura do manifest no próximo uso).
  static void invalidateCache() {
    _cacheAll = null;
  }

  /// Retorna **todas** as imagens de rosto conhecidas.
  /// [includeBase] inclui `assets/rostos_base/`.
  /// [includeDefault] mantém o `_default.png` na lista (por padrão removemos).
  static Future<List<String>> all({
    bool includeBase = true,
    bool includeDefault = false,
  }) async {
    final all = await _loadAllIfNeeded();
    final filtered = all.where((p) {
      final okDir = p.startsWith(_kDirRostos) ||
          (includeBase && p.startsWith(_kDirRostosBase));
      final okExt = _isImagePath(p);
      final notDefault =
          includeDefault || !_isDefaultPlaceholder(p); // remove por padrão
      return okDir && okExt && notDefault;
    }).toList()
      ..sort();
    return List<String>.unmodifiable(filtered);
  }

  /// Retorna um rosto aleatório (ou `null` se nenhum encontrado).
  /// Por padrão, não inclui `_default.png`.
  static Future<String?> any({
    bool includeBase = true,
    bool excludeDefault = true,
  }) async {
    final list = await all(
      includeBase: includeBase,
      includeDefault: !excludeDefault,
    );
    if (list.isEmpty) return null;
    return list[_rng.nextInt(list.length)];
  }

  /// Retorna até [n] rostos aleatórios (sem repetição).
  /// Por padrão, não inclui `_default.png`.
  static Future<List<String>> many(
    int n, {
    bool includeBase = true,
    bool excludeDefault = true,
  }) async {
    if (n <= 0) return const <String>[];
    final list = List<String>.from(await all(
      includeBase: includeBase,
      includeDefault: !excludeDefault,
    ));
    if (list.isEmpty) return const <String>[];
    list.shuffle(_rng);
    return List<String>.unmodifiable(list.take(n));
  }

  // ===== internals =====

  static Future<List<String>> _loadAllIfNeeded() async {
    final cached = _cacheAll;
    if (cached != null) return cached;

    try {
      final raw = await rootBundle.loadString(_kManifestPath);
      final Map<String, dynamic> manifest = json.decode(raw);

      final keys = manifest.keys
          .where((k) =>
              (k.startsWith(_kDirRostos) || k.startsWith(_kDirRostosBase)) &&
              _isImagePath(k))
          .toList()
        ..sort();

      _cacheAll = keys;
      return _cacheAll!;
    } catch (_) {
      _cacheAll = const <String>[];
      return _cacheAll!;
    }
  }

  static bool _isImagePath(String p) {
    final s = p.toLowerCase();
    return s.endsWith('.png') ||
        s.endsWith('.jpg') ||
        s.endsWith('.jpeg') ||
        s.endsWith('.webp');
  }

  static bool _isDefaultPlaceholder(String p) {
    // evita pegar o placeholder quando pedimos "rostos reais"
    return p.endsWith('/_default.png') || p == _kDefault;
  }
}
