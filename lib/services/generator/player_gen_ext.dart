// lib/services/generator/player_gen_ext.dart
//
// Extensões de compatibilidade para JogadorGenerator.
// Mantém assinaturas antigas usadas em pontos legados do app
// (ex.: sortearPePreferencial), redirecionando para a lógica atual.
//
// Uso:
//   final gen = JogadorGenerator();
//   final pe = gen.sortearPePreferencial(); // API legada preservada
//
// Observação:
// - NÃO altera a geração principal do JogadorGenerator
// - Apenas evita quebrar código antigo durante a migração

import 'dart:math';

import '../../models/pe_preferencial.dart';
import 'jogador_generator.dart';

extension JogadorGeneratorCompat on JogadorGenerator {
  /// Mantém a antiga assinatura `sortearPePreferencial([seed])`.
  /// Distribuição aproximada:
  ///   • direito ~78%
  ///   • esquerdo ~20%
  ///   • ambos ~2%
  PePreferencial sortearPePreferencial([int? seed]) {
    final rng = seed != null ? Random(seed) : Random();
    final p = rng.nextDouble();

    if (p < 0.78) return PePreferencial.direito;
    if (p < 0.98) return PePreferencial.esquerdo;
    return PePreferencial.ambos;
  }
}
