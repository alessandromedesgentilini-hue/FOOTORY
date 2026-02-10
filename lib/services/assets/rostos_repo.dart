// lib/services/assets/rostos_repo.dart
//
// Índice leve de rostos **agrupados por subpastas** usando o AssetManifest.
// Útil quando você quer sortear fotos por “grupo” (ex.: etnias/países/estilos).
//
// Convenções / requisitos no pubspec.yaml:
// flutter:
//   assets:
//     - assets/rostos/         (pastas filhas viram *grupos*)
//     - assets/rostos_base/    (se quiser outro repositório, crie outro RostosRepo)
//
// Exemplo de estrutura para grupos:
//   assets/rostos/latinoamericanos/xxx.png
//   assets/rostos/europeus/yyy.jpg
//
// Como usar (sugestão):
//   final repo = RostosRepo(root: 'assets/rostos/');
//   await repo.init();                 // de preferência no boot
//   final p1 = repo.randomFromGroup('latinoamericanos');
//   final p2 = repo.any();             // sorteia de qualquer grupo
//   Image.asset(repo.safe(p1));        // exibir garantindo placeholder
//
// Observação importante: este repositório **não substitui** o FacePool,
// ele é complementar quando você precisa de agrupamento por subdiretórios.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class RostosRepo {
  /// Diretório raiz (precisa terminar com '/'), ex.: 'assets/rostos/'.
  final String root;

  final Random _rng;
  final Map<String, List<String>> _byGroup = <String, List<String>>{};
  final Set<String> _all = <String>{};

  bool _loaded = false;
  bool _loading = false;

  /// Placeholder padrão, consistente com o restante do projeto.
  /// Recomenda-se criar este arquivo:
  ///   assets/rostos/_default.png
  static const String _kPlaceholder = 'assets/rostos/_default.png';

  RostosRepo({required String root, int? seed})
      : root = root.endsWith('/') ? root : '$root/',
        _rng = Random(seed);

  bool get isLoaded => _loaded;
  Iterable<String> get groups => _byGroup.keys;
  int get countAll => _all.length;
  int countOf(String group) => _byGroup[group]?.length ?? 0;

  /// Carrega/indiza os assets do manifest que pertencem ao [root].
  Future<void> init() async {
    if (_loaded || _loading) return;
    _loading = true;
    try {
      final raw = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest =
          json.decode(raw) as Map<String, dynamic>;

      _byGroup.clear();
      _all.clear();

      for (final path in manifest.keys) {
        if (!path.startsWith(root)) continue;
        if (!_isImagePath(path)) continue;

        // Ex.: 'latinoamericanos/xxx.png'
        final remainder = path.substring(root.length);
        final slash = remainder.indexOf('/');
        if (slash <= 0) continue;

        final group = remainder.substring(0, slash);
        _byGroup.putIfAbsent(group, () => <String>[]);

        // Evita que o placeholder entre nos sorteios dos grupos
        if (!_isDefault(path)) {
          _byGroup[group]!.add(path);
        }

        _all.add(path);
      }

      // Ordena listas para reprodutibilidade
      for (final e in _byGroup.values) {
        e.sort();
      }

      _loaded = true;
    } catch (_) {
      // Mantém estado “não carregado” e índices limpos em caso de erro
      _byGroup.clear();
      _all.clear();
      _loaded = false;
    } finally {
      _loading = false;
    }
  }

  /// Força reconstrução do índice no próximo [init].
  void reset() {
    _loaded = false;
    _loading = false;
    _byGroup.clear();
    _all.clear();
  }

  /// Retorna um asset aleatório do [group].
  /// - Se o grupo não existir ou estiver vazio, tenta sortear de **qualquer grupo**.
  /// - Se ainda assim não houver, cai no placeholder (se existir) ou em ''.
  ///
  /// Se ainda não carregou, dispara [init] em background e retorna o placeholder.
  String randomFromGroup(String group) {
    if (!_loaded) {
      // Chamada precoce (antes de init); evita quebra e inicia o carregamento.
      // ignore: discarded_futures
      init();
      return _placeholderOrEmpty();
    }

    final list = _byGroup[group];
    if (list != null && list.isNotEmpty) {
      return list[_rng.nextInt(list.length)];
    }

    // Tenta qualquer grupo
    if (_byGroup.isNotEmpty) {
      final all = _byGroup.values.expand((e) => e).toList(growable: false);
      if (all.isNotEmpty) {
        return all[_rng.nextInt(all.length)];
      }
    }

    return _placeholderOrEmpty();
  }

  /// Sorteia de **qualquer grupo**.
  /// Se vazio ou não carregado, retorna placeholder (ou '').
  String any() {
    if (!_loaded) {
      // ignore: discarded_futures
      init();
      return _placeholderOrEmpty();
    }
    final all = _byGroup.values.expand((e) => e).toList(growable: false);
    if (all.isEmpty) return _placeholderOrEmpty();
    return all[_rng.nextInt(all.length)];
  }

  /// Garante um caminho exibível:
  /// - null/vazio → placeholder (se existir) ou ''
  /// - não carregado → placeholder (e dispara init)
  /// - existe no índice → retorna o próprio
  /// - senão → placeholder
  String safe(String? path) {
    if (path == null || path.isEmpty) {
      if (!_loaded) {
        // ignore: discarded_futures
        init();
      }
      return _placeholderOrEmpty();
    }
    if (!_loaded) {
      // ignore: discarded_futures
      init();
      return _placeholderOrEmpty();
    }
    return _all.contains(path) ? path : _placeholderOrEmpty();
  }

  /// Verifica se o asset existe no índice carregado.
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

  String _placeholderOrEmpty() {
    // Retorna o placeholder se ele estiver no bundle; senão, string vazia para a UI cair nas iniciais.
    return (_kPlaceholder);
  }
}
