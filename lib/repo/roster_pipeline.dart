// lib/repo/roster_pipeline.dart
//
// Pipeline de elenco (ROBUSTO/TOLERANTE)
// - Centraliza a criação do catálogo de jogadores e o save inicial.
// - Corrige os imports para o diretório atual de `repo/`.
// - Aceita transformações/overrides opcionais nos jogadores antes de devolver.
// - É tolerante ao tipo retornado pelo SeedRepo (Map<String, Jogador> **ou**
//   List<Jogador>), convertendo quando necessário.

import '../models/jogador.dart';
import 'save_state.dart';
import 'seed_repo.dart';

typedef JogadorTransform = Jogador Function(Jogador);

class RosterPipeline {
  final SeedRepo seeds;

  /// Transforms executados em ordem para cada jogador do catálogo.
  /// Útil para aplicar overrides/mods sem acoplar nesta classe.
  final List<JogadorTransform> _transforms;

  const RosterPipeline(
    this.seeds, {
    List<JogadorTransform> transforms = const [],
  }) : _transforms = transforms;

  /// Constrói o catálogo principal de jogadores da Série A.
  /// - Se o `SeedRepo` retornar `Map<String, Jogador>`, usa como base.
  /// - Se retornar `List<Jogador>`, converte para Map via `id` (ou índice).
  /// - Aplica [transforms] (se houver) a cada jogador antes de devolver.
  Map<String, Jogador> buildCatalog() {
    final dynamic raw = seeds.loadPlayersSerieA();

    Map<String, Jogador> toMap(dynamic src) {
      if (src is Map<String, Jogador>) {
        return Map<String, Jogador>.from(src);
      }
      if (src is List<Jogador>) {
        final out = <String, Jogador>{};
        for (var i = 0; i < src.length; i++) {
          final j = src[i];
          final key = (j.id.isNotEmpty ? j.id : 'player_$i');
          // Em caso raro de chave duplicada, suffix incremental
          var k = key;
          var suffix = 1;
          while (out.containsKey(k)) {
            k = '${key}_${suffix++}';
          }
          out[k] = j;
        }
        return out;
      }
      // Tipo inesperado: devolve vazio para não quebrar a UI
      return <String, Jogador>{};
    }

    final base = toMap(raw);

    if (_transforms.isEmpty) return base;

    // Aplica as transforms em sequência, com tolerância a erros
    final patched = <String, Jogador>{};
    base.forEach((k, v) {
      Jogador cur = v;
      for (final t in _transforms) {
        try {
          cur = t(cur);
        } catch (_) {
          // Ignora falha pontual na transformação para não abortar o pipeline
          // (Mantém `cur` como estava).
        }
      }
      patched[k] = cur;
    });

    return patched;
  }

  /// Cria um save inicial com base no seed da Série A.
  /// A implementação concreta fica no `SeedRepo`.
  SaveState createSave() {
    return seeds.createInitialSaveSerieA();
  }
}
