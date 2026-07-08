import 'dart:math';

/// RNG determinístico (seed fixo) para o mundo.
/// Regra: tudo procedural passa por aqui (direto ou via PlayerFactory).
class SeededRng {
  final Random _r;

  SeededRng(int seed) : _r = Random(seed);

  int nextInt(int maxExclusive) => _r.nextInt(maxExclusive);

  /// Inclusive..inclusive
  int rangeInt(int minInclusive, int maxInclusive) {
    if (maxInclusive < minInclusive) {
      throw ArgumentError('maxInclusive < minInclusive');
    }
    final span = maxInclusive - minInclusive + 1;
    return minInclusive + _r.nextInt(span);
  }

  double nextDouble() => _r.nextDouble();

  bool chance(double p01) {
    if (p01 <= 0) return false;
    if (p01 >= 1) return true;
    return _r.nextDouble() < p01;
  }

  T pick<T>(List<T> list) {
    if (list.isEmpty) throw ArgumentError('pick() list vazia');
    return list[_r.nextInt(list.length)];
  }

  void shuffle<T>(List<T> list) => list.shuffle(_r);

  String id(String prefix) {
    // id curta determinística (boa o bastante pro MVP)
    final a = rangeInt(100000, 999999);
    final b = rangeInt(100000, 999999);
    return '$prefix-$a$b';
  }
}
