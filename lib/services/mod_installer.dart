// lib/services/mod_installer.dart
//
// Stub robusto de "instalador de mods" para o MVP compilar sem sustos.
// Não usa dart:io nem pacotes externos (roda em mobile/web).
// Simula etapas (baixar, validar, extrair, registrar) com callback de progresso
// e permite cancelamento.
//
// Exemplo:
//   final installer = ModInstaller();
//   await installer.instalar(
//     'https://meuservidor.com/mods/pacote.zip',
//     onProgress: (p, step) => debugPrint('${(p * 100).toStringAsFixed(0)}% - $step'),
//   );

import 'dart:async';

typedef ProgressCallback = void Function(double progress, String step);

class ModInstaller {
  bool _busy = false;
  bool _cancelled = false;

  bool get isBusy => _busy;

  /// Cancela a instalação corrente (se houver).
  void cancel() => _cancelled = true;

  /// Validação leve do URL.
  static bool isValidUrl(String url) {
    final u = url.trim();
    final parsed = Uri.tryParse(u);
    if (parsed == null) return false;
    if (!(parsed.isAbsolute &&
        (parsed.scheme == 'http' || parsed.scheme == 'https'))) {
      return false;
    }
    final lower = u.toLowerCase();
    return lower.endsWith('.zip') ||
        lower.endsWith('.mod') ||
        lower.endsWith('.pak');
  }

  /// Instala um mod a partir de [url].
  /// [destinoDiretorio] é reservado para implementação futura.
  Future<void> instalar(
    String url, {
    String? destinoDiretorio,
    ProgressCallback? onProgress,
  }) async {
    if (_busy) {
      onProgress?.call(0, 'ocupado');
      return;
    }
    _busy = true;
    _cancelled = false;

    void step(double p, String s) {
      if (!_cancelled) onProgress?.call(p.clamp(0, 1), s);
    }

    try {
      step(0, 'iniciando');

      // 1) validação
      if (!isValidUrl(url)) {
        step(0, 'url inválida');
        return;
      }

      // 2) baixar (simulado)
      await _simulateStep(
        totalMs: 900,
        baseProgress: 0.00,
        endProgress: 0.40,
        onTick: (p) => step(p, 'baixando'),
      );
      if (_cancelled) {
        onProgress?.call(0, 'cancelado');
        return;
      }

      // 3) validar pacote
      await _simulateStep(
        totalMs: 300,
        baseProgress: 0.40,
        endProgress: 0.55,
        onTick: (p) => step(p, 'validando pacote'),
      );
      if (_cancelled) {
        onProgress?.call(0, 'cancelado');
        return;
      }

      // 4) extrair/instalar
      await _simulateStep(
        totalMs: 700,
        baseProgress: 0.55,
        endProgress: 0.85,
        onTick: (p) => step(p, 'extraindo'),
      );
      if (_cancelled) {
        onProgress?.call(0, 'cancelado');
        return;
      }

      // 5) registrar
      await _simulateStep(
        totalMs: 400,
        baseProgress: 0.85,
        endProgress: 1.00,
        onTick: (p) => step(p, 'registrando'),
      );
      if (_cancelled) {
        onProgress?.call(0, 'cancelado');
        return;
      }

      step(1.00, 'concluído');
    } catch (_) {
      onProgress?.call(0, 'falhou');
    } finally {
      _busy = false;
    }
  }

  // ===== Simulação de etapas =====
  Future<void> _simulateStep({
    required int totalMs,
    required double baseProgress,
    required double endProgress,
    required void Function(double) onTick,
  }) async {
    const ticks = 6; // sensação de progresso
    final perTick = totalMs ~/ ticks;

    for (var i = 0; i < ticks; i++) {
      if (_cancelled) return;
      final t = (i + 1) / ticks;
      final p = baseProgress + (endProgress - baseProgress) * t;
      onTick(p);
      await Future.delayed(Duration(milliseconds: perTick));
    }
  }
}
