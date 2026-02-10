// lib/services/match_engine.dart
//
// MatchEngine simples — versão MVP (com artilheiros):
// - Simula placar a partir de mA/mB (0..120) e tier
// - Gera um resumo com nomes de “gols” (bem simples), tipo:
//   "João marca 2x e Carlos define: 3–1"
//
// ✅ Mantém a mesma interface: MatchEngineContext / MatchResult.
// ✅ Não cria estrutura pesada de eventos — só texto.

import 'dart:math';

class MatchEngineContext {
  final double mA; // 0..120 (TeamPowerService)
  final double mB; // 0..120 (TeamPowerService)
  final int tier; // 0..(n-1) (quanto maior, mais desequilíbrio)
  final List<String> nomesAdversario;
  final List<String> seusArtilheiros;
  final int seed;

  const MatchEngineContext({
    required this.mA,
    required this.mB,
    required this.tier,
    required this.nomesAdversario,
    required this.seusArtilheiros,
    required this.seed,
  });
}

class MatchResult {
  final int golsA;
  final int golsB;
  final String resumo;

  const MatchResult({
    required this.golsA,
    required this.golsB,
    required this.resumo,
  });
}

class MatchEngine {
  const MatchEngine();

  Future<MatchResult> simular(MatchEngineContext ctx) async {
    final rng = Random(ctx.seed);

    // =========================================================
    // 1) Normalização (m é 0..120)
    // =========================================================
    double na = (ctx.mA / 100.0).clamp(0.0, 1.2);
    double nb = (ctx.mB / 100.0).clamp(0.0, 1.2);

    // tier maior => menos ruído (jogo “óbvio” fica mais estável)
    final tier = ctx.tier.clamp(0, 10);
    final noiseSpan = (0.18 - (tier * 0.01)).clamp(0.08, 0.18);

    na *= (1.0 - noiseSpan / 2) + rng.nextDouble() * noiseSpan;
    nb *= (1.0 - noiseSpan / 2) + rng.nextDouble() * noiseSpan;

    final diff = (na - nb).clamp(-0.8, 0.8);

    // =========================================================
    // 2) Expectativa total de gols
    // =========================================================
    final baseTotal = 2.45 + rng.nextDouble() * 0.55; // 2.45..3.00
    final totalAdj = (baseTotal + (diff.abs() * 0.35)).clamp(1.8, 3.6);

    // =========================================================
    // 3) Proporção pro A
    // =========================================================
    double propA = (0.5 + (diff * 0.40)).clamp(0.12, 0.88);

    final lambdaA = (totalAdj * propA).clamp(0.05, 4.5);
    final lambdaB = (totalAdj * (1.0 - propA)).clamp(0.05, 4.5);

    // =========================================================
    // 4) Poisson pros gols
    // =========================================================
    int gA = _poisson(rng, lambdaA).clamp(0, 6);
    int gB = _poisson(rng, lambdaB).clamp(0, 6);

    // quebra 0x0 excessivo
    if (gA == 0 && gB == 0) {
      final chanceQuebra0x0 =
          (0.35 + (totalAdj - 2.4) * 0.10).clamp(0.25, 0.55);
      if (rng.nextDouble() < chanceQuebra0x0) {
        if (rng.nextBool()) {
          gA = 1;
        } else {
          gB = 1;
        }
      }
    }

    final resumo = _gerarResumoComGols(gA, gB, ctx, rng);
    return MatchResult(golsA: gA, golsB: gB, resumo: resumo);
  }

  // =========================================================
  // Helpers
  // =========================================================

  int _poisson(Random rng, double lambda) {
    // Knuth Poisson — ótimo pro MVP (lambda baixo)
    final L = exp(-lambda);
    var k = 0;
    var p = 1.0;
    do {
      k++;
      p *= rng.nextDouble();
    } while (p > L);
    return k - 1;
  }

  List<String> _pickLista(Random rng, List<String> src, int maxN) {
    if (src.isEmpty) return const [];
    final pool = List<String>.from(src);
    // shuffle simples
    for (var i = pool.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = pool[i];
      pool[i] = pool[j];
      pool[j] = tmp;
    }
    if (pool.length <= maxN) return pool;
    return pool.take(maxN).toList(growable: false);
  }

  Map<String, int> _distribuirGolsPorNomes(
    Random rng,
    int gols,
    List<String> nomes, {
    String fallback = 'Jogador',
  }) {
    if (gols <= 0) return {};
    final base = nomes.isNotEmpty ? nomes : [fallback];

    // pesos simples: primeiro nome (o “artilheiro”) pesa mais
    final weights = <double>[];
    for (var i = 0; i < base.length; i++) {
      final w = (base.length - i).toDouble();
      weights.add(max(1.0, w));
    }

    int pickIndex() {
      final sum = weights.fold<double>(0.0, (a, b) => a + b);
      var r = rng.nextDouble() * sum;
      for (var i = 0; i < weights.length; i++) {
        r -= weights[i];
        if (r <= 0) return i;
      }
      return 0;
    }

    final out = <String, int>{};
    for (var i = 0; i < gols; i++) {
      final idx = pickIndex();
      final nome = base[idx];
      out[nome] = (out[nome] ?? 0) + 1;
    }
    return out;
  }

  String _fmtGols(Map<String, int> gols) {
    if (gols.isEmpty) return '';
    final entries = gols.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // limita pra não virar textão
    final top = entries.take(3).toList(growable: false);

    String fmtOne(MapEntry<String, int> e) {
      if (e.value <= 1) return e.key;
      return '${e.key} ${e.value}x';
    }

    if (top.length == 1) return fmtOne(top[0]);
    if (top.length == 2) return '${fmtOne(top[0])} e ${fmtOne(top[1])}';
    return '${fmtOne(top[0])}, ${fmtOne(top[1])} e ${fmtOne(top[2])}';
  }

  String _gerarResumoComGols(
      int gA, int gB, MatchEngineContext ctx, Random rng) {
    // pega poucos nomes pra evitar repetição infinita
    final seus = _pickLista(rng, ctx.seusArtilheiros, 3);
    final deles = _pickLista(rng, ctx.nomesAdversario, 3);

    final golsA = _distribuirGolsPorNomes(
      rng,
      gA,
      seus,
      fallback: 'Time A',
    );
    final golsB = _distribuirGolsPorNomes(
      rng,
      gB,
      deles,
      fallback: 'Adversário',
    );

    final placar = '$gA–$gB';

    if (gA > gB) {
      final s = _fmtGols(golsA);
      if (s.isEmpty) return 'Vitória: $placar';
      return '$s decide: $placar';
    }

    if (gB > gA) {
      final s = _fmtGols(golsB);
      if (s.isEmpty) return 'Derrota: $placar';
      // aqui a gente escreve do ponto de vista “do jogo”, não do seu clube
      return '$s define: $placar';
    }

    // empate
    if (gA == 0) return 'Jogo travado e empate em $placar';

    final aTop = _fmtGols(golsA);
    final bTop = _fmtGols(golsB);

    if (aTop.isEmpty || bTop.isEmpty) return 'Empate em $placar';
    return '$aTop e $bTop: empate em $placar';
  }
}
