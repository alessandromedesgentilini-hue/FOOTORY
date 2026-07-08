// lib/services/assets/face_pool.dart
//
// Pool de rostos (imagens) carregado a partir do AssetManifest.json.
// Expõe helpers para escolher uma foto válida ou cair no placeholder seguro.
//
// Como usar (recomendado):
//  1) No boot do app, rode: await FacePool.I.preload();
//  2) Para exibir a face salva no jogador:
//       Image.asset(FacePool.I.safe(p.faceAsset))
//  3) Para sortear uma aleatória (ex.: ao gerar elencos):
//       final path = FacePool.I.random(base: true/false);
//
// Requisitos no pubspec.yaml (assets recursivos):
// flutter:
//   assets:
//     - assets/rostos/
//     - assets/rostos_base/
//
// Também crie o placeholder:
//   assets/rostos/_default.png
// (qualquer PNG quadrado simples. É o fallback para ausência/erro.)

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class FacePool {
  FacePool._();
  static final FacePool I = FacePool._();

  // Placeholder seguro (precisa existir no bundle!)
  static const String _kPlaceholder = 'assets/rostos/_default.png';

  // Pastas suportadas
  static const String _kDirPro = 'assets/rostos/';
  static const String _kDirBase = 'assets/rostos_base/';

  bool _loaded = false;
  bool _preloading = false;

  // Índices em memória
  List<String> _pro = const <String>[];
  List<String> _base = const <String>[];
  final Set<String> _all = <String>{};

  bool get isLoaded => _loaded;
  int get countPro => _pro.length;
  int get countBase => _base.length;
  int get countAll => _all.length;
  String get placeholder => _kPlaceholder;

  /// Pré-carrega e indexa as imagens existentes em:
  ///   - assets/rostos/**
  ///   - assets/rostos_base/**
  ///
  /// Chamar no boot do app (await!) antes de criar/mostrar jogadores.
  Future<void> preload() async {
    if (_loaded || _preloading) return;
    _preloading = true;
    try {
      final raw = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> map = json.decode(raw);

      // Coleta somente arquivos de imagem conhecidos
      final keys = map.keys
          .where((k) => (_isImagePath(k) &&
              (k.startsWith(_kDirPro) || k.startsWith(_kDirBase))))
          .toList()
        ..sort();

      // Indexa
      _pro = keys.where((p) => p.startsWith(_kDirPro)).toList();
      _base = keys.where((p) => p.startsWith(_kDirBase)).toList();

      _all
        ..clear()
        ..addAll(keys);

      _loaded = true;
    } catch (_) {
      // Em caso de erro, mantemos estado “não carregado” e listas vazias.
      _pro = const <String>[];
      _base = const <String>[];
      _all.clear();
      _loaded = false;
    } finally {
      _preloading = false;
    }
  }

  /// Reseta o índice (força nova leitura do manifest no próximo uso).
  void reset() {
    _loaded = false;
    _preloading = false;
    _pro = const <String>[];
    _base = const <String>[];
    _all.clear();
  }

  /// Retorna uma imagem aleatória da pool (PRO/Base).
  /// Se o índice ainda não foi carregado, dispara o preload sem bloquear
  /// e retorna o placeholder por segurança.
  ///
  /// Observação: o placeholder **não** é sorteado.
  String random({required bool base, Random? rng}) {
    if (!_loaded) {
      // Primeira chamada pode ocorrer antes do boot terminar.
      // Disparamos o preload sem bloquear, e devolvemos o placeholder.
      // ignore: discarded_futures
      preload();
      return _kPlaceholder;
    }

    final listRaw = base ? _base : _pro;
    if (listRaw.isEmpty) return _kPlaceholder;

    // Evita devolver o _default.png no sorteio
    final list = listRaw.where((p) => !_isDefault(p)).toList(growable: false);
    if (list.isEmpty) return _kPlaceholder;

    final r = rng ?? Random();
    return list[r.nextInt(list.length)];
  }

  /// Garante um caminho exibível:
  ///  - se [path] for nulo/vazio → placeholder (e dispara preload, se preciso)
  ///  - se índice não foi carregado ainda → placeholder (e dispara preload)
  ///  - se existir no índice → retorna o próprio [path]
  ///  - caso contrário → placeholder
  String safe(String? path) {
    if (path == null || path.isEmpty) {
      if (!_loaded) {
        // ignore: discarded_futures
        preload();
      }
      return _kPlaceholder;
    }
    if (!_loaded) {
      // Evita quebra logo no start — garante que pelo menos temos algo a exibir
      // e deixamos o índice carregar em background.
      // ignore: discarded_futures
      preload();
      return _kPlaceholder;
    }
    return _all.contains(path) ? path : _kPlaceholder;
  }

  /// Útil para diagnósticos/depuração.
  bool exists(String path) => _loaded && _all.contains(path);

  // ===== Internals =====

  static bool _isImagePath(String p) {
    final s = p.toLowerCase();
    return s.endsWith('.png') ||
        s.endsWith('.jpg') ||
        s.endsWith('.jpeg') ||
        s.endsWith('.webp');
  }

  static bool _isDefault(String p) =>
      p == _kPlaceholder || p.endsWith('/_default.png');
}
