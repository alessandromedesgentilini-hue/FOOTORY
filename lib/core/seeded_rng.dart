import 'dart:math';

class SeededRng {
  final Random _rng;
  SeededRng(int seed) : _rng = Random(seed);

  /// Retorna double em [0,1)
  double next() => _rng.nextDouble();

  /// Inteiro em [min, max] inclusivo
  int intInRange(int min, int max) {
    if (max < min) return min;
    return min + _rng.nextInt((max - min) + 1);
  }

  /// Escolhe um índice baseado em pesos percentuais inteiros (somando ~100)
  int weightedIndex(List<int> weights) {
    final total = weights.fold<int>(0, (a, b) => a + b);
    int roll = (_rng.nextDouble() * total).floor();
    for (int i = 0; i < weights.length; i++) {
      if (roll < weights[i]) return i;
      roll -= weights[i];
    }
    return weights.length - 1;
  }
}
