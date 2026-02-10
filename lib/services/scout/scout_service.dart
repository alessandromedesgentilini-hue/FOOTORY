// lib/services/scout/scout_service.dart
//
// ScoutService (MVP)
// - 1 relatório por mês
// - Filtros por seleção (sem busca por nome)
// - Nível dos olheiros controla:
//    • maxResultados
//    • maxFiltros
//    • aderência ao pedido (pode vir abaixo do desejado)
//
// ✅ FIX (robusto):
// - Não depende de getters que podem não existir no seu DepartamentoFutebol.
//   (maxFiltros / aderencia / maxResultadosRelatorio)
//   -> tenta ler via dynamic e, se não existir, calcula pelo olheirosNivel.
// - Remove dependência de GradeUtils (implementa conversão aqui).
//
// Observação: contratação só na janela Jan/Jul (isso a gente pluga no MercadoPage depois).

import 'dart:math';

import '../../domain/models/clube_state.dart';
import '../../models/scout/attribute_grade.dart';
import '../../models/scout/scout_candidate.dart';
import '../../models/scout/scout_filter.dart';
import '../../models/scout/scout_report.dart';

class ScoutService {
  const ScoutService();

  ScoutReport gerarRelatorioMensal({
    required ClubeState clube,
    required int temporadaAno,
    required int mes, // 1..12
    required ScoutFilter filtroOriginal,
    required int seed,
  }) {
    final ol = clube.deptFutebol;
    final rng = Random(seed);

    final olheirosNivel = _readOlheirosNivel(ol);

    // 1) normaliza filtro conforme desbloqueios e limite de filtros
    final filtro = _sanitizeFilter(
      filtroOriginal,
      olheirosNivel: olheirosNivel,
      maxFiltros: _readMaxFiltros(ol, olheirosNivel),
    );

    // 2) gera candidatos
    final maxResults = _readMaxResultadosRelatorio(ol, olheirosNivel);
    final aderencia = _readAderencia(ol, olheirosNivel);

    final candidatos = <ScoutCandidate>[];
    final triesMax = maxResults * 30; // tenta bastante p/ respeitar filtros
    var tries = 0;

    while (candidatos.length < maxResults && tries < triesMax) {
      tries++;

      final cand = _rollCandidate(
        rng: rng,
        olheirosNivel: olheirosNivel,
        aderencia: aderencia,
        filtro: filtro,
        temporadaAno: temporadaAno,
        mes: mes,
        idx: candidatos.length,
      );

      if (cand == null) continue;

      // evita duplicados por id
      if (candidatos.any((c) => c.id == cand.id)) continue;
      candidatos.add(cand);
    }

    return ScoutReport(
      temporadaAno: temporadaAno,
      mes: mes.clamp(1, 12),
      filtro: filtro,
      candidatos: candidatos,
      olheirosNivel: olheirosNivel,
      geradoEm: DateTime.now(),
    );
  }

  // =========================================================
  // Internos
  // =========================================================

  int _readOlheirosNivel(dynamic dept) {
    try {
      final v = (dept as dynamic).olheirosNivel;
      if (v is int) return v.clamp(1, 10);
      if (v is num) return v.toInt().clamp(1, 10);
    } catch (_) {}
    return 1;
  }

  int _readMaxResultadosRelatorio(dynamic dept, int olheirosNivel) {
    // tenta getter do seu model
    try {
      final v = (dept as dynamic).maxResultadosRelatorio;
      if (v is int) return v.clamp(2, 50);
      if (v is num) return v.toInt().clamp(2, 50);
    } catch (_) {}

    // fallback pelo nível
    if (olheirosNivel <= 2) return 4;
    if (olheirosNivel <= 4) return 6;
    if (olheirosNivel <= 6) return 8;
    if (olheirosNivel <= 8) return 10;
    return 12;
  }

  int _readMaxFiltros(dynamic dept, int olheirosNivel) {
    // tenta getter do seu model
    try {
      final v = (dept as dynamic).maxFiltros;
      if (v is int) return v.clamp(1, 10);
      if (v is num) return v.toInt().clamp(1, 10);
    } catch (_) {}

    // fallback pelo nível
    if (olheirosNivel <= 2) return 2;
    if (olheirosNivel <= 4) return 3;
    if (olheirosNivel <= 6) return 4;
    if (olheirosNivel <= 8) return 5;
    return 6;
  }

  double _readAderencia(dynamic dept, int olheirosNivel) {
    // tenta getter do seu model
    try {
      final v = (dept as dynamic).aderencia;
      if (v is double) return v.clamp(0.0, 1.0);
      if (v is num) return v.toDouble().clamp(0.0, 1.0);
    } catch (_) {}

    // fallback pelo nível
    if (olheirosNivel <= 2) return 0.45;
    if (olheirosNivel <= 4) return 0.60;
    if (olheirosNivel <= 6) return 0.75;
    if (olheirosNivel <= 8) return 0.88;
    return 0.95;
  }

  ScoutFilter _sanitizeFilter(
    ScoutFilter f, {
    required int olheirosNivel,
    required int maxFiltros,
  }) {
    // 1) regiões desbloqueadas
    final unlocked = <ScoutMarketRegion>{ScoutMarketRegion.brasil};
    if (olheirosNivel >= 4) unlocked.add(ScoutMarketRegion.mercosul);
    if (olheirosNivel >= 7) unlocked.add(ScoutMarketRegion.internacional);
    if (olheirosNivel >= 9) unlocked.add(ScoutMarketRegion.europa);

    final regioes = f.regioes.where(unlocked.contains).toSet();
    final fixedRegioes = regioes.isEmpty ? {ScoutMarketRegion.brasil} : regioes;

    // 2) limite de filtros: corta excesso de minPilares
    // prioridade: regioes, posicoes, idades, contrato, valorMax e depois minPilares.
    final minP = Map<ScoutPillar, AttributeGrade>.from(f.minPilares);

    int countActive() {
      var n = 0;
      if (fixedRegioes.isNotEmpty) n++;
      if (f.posicoes.isNotEmpty) n++;
      if (f.idades.isNotEmpty) n++;
      if (f.contrato.isNotEmpty) n++;
      if (f.valorMax != null) n++;
      n += minP.length;
      return n;
    }

    while (countActive() > maxFiltros && minP.isNotEmpty) {
      final k = minP.keys.toList()..sort((a, b) => a.index.compareTo(b.index));
      minP.remove(k.last);
    }

    return f.copyWith(regioes: fixedRegioes, minPilares: minP);
  }

  ScoutCandidate? _rollCandidate({
    required Random rng,
    required int olheirosNivel,
    required double aderencia,
    required ScoutFilter filtro,
    required int temporadaAno,
    required int mes,
    required int idx,
  }) {
    // 1) região
    final reg = _pickFromSet(rng, filtro.regioes);

    // 2) posição
    final pos = filtro.posicoes.isEmpty
        ? _pickMacro(rng)
        : _pickFromSet(rng, filtro.posicoes);

    // 3) idade
    final idade = _pickAge(rng, filtro.idades);

    // 4) contrato
    final contrato = filtro.contrato.isEmpty
        ? _pickContrato(rng)
        : _pickFromSet(rng, filtro.contrato);

    // 5) gera pilares (A–E)
    final pilares = _generatePillarsForCandidate(
      rng: rng,
      pos: pos,
      regiao: reg,
      idade: idade,
    );

    // 6) aplica filtro por minPilares com “aderência”
    if (!_meetsMinPillars(pilares, filtro.minPilares)) {
      final acceptChance = (1.0 - aderencia).clamp(0.05, 0.65);
      if (rng.nextDouble() > acceptChance) return null;
    }

    // 7) valor/salário estimados
    final ovrAprox = _overallProxy(pilares);
    final valor = _valorEstimado(ovrAprox: ovrAprox, idade: idade, regiao: reg);
    if (filtro.valorMax != null && valor > filtro.valorMax!) {
      final acceptChance = 0.25 + (1.0 - aderencia) * 0.5;
      if (rng.nextDouble() > acceptChance) return null;
    }

    final salario = max(20000, (valor / 85).round());

    // 8) nome
    final nome = _randomName(rng);

    // 9) id
    final id =
        'sc_${temporadaAno}_${mes}_${reg.name}_${pos.name}_${idx}_${idade}_${rng.nextInt(1 << 20)}';

    return ScoutCandidate(
      id: id,
      nomeExibicao: nome,
      pos: pos,
      idade: idade,
      regiao: reg,
      contrato: contrato,
      valorEstimado: valor,
      salarioEstimado: salario,
      pilares: pilares,
      adaptabilidade: _rollAdaptabilidade(rng, regiao: reg),
    );
  }

  // =========================================================
  // Geração de pilares (A–E)
  // =========================================================

  Map<ScoutPillar, AttributeGrade> _generatePillarsForCandidate({
    required Random rng,
    required ScoutMacroPos pos,
    required ScoutMarketRegion regiao,
    required int idade,
  }) {
    double base = switch (regiao) {
      ScoutMarketRegion.brasil => 6.0,
      ScoutMarketRegion.mercosul => 5.7,
      ScoutMarketRegion.internacional => 6.1,
      ScoutMarketRegion.europa => 6.4,
    };

    if (idade <= 20) base -= 0.2;
    if (idade >= 33) base -= 0.15;

    double rollAvg({double spread = 1.2}) {
      final v = base + (rng.nextDouble() * spread * 2.0 - spread);
      return v.clamp(1.0, 10.0);
    }

    var of = rollAvg();
    var df = rollAvg();
    var te = rollAvg();
    var mn = rollAvg();
    var fi = rollAvg();

    switch (pos) {
      case ScoutMacroPos.GOL:
        df = (df + 1.0).clamp(1.0, 10.0);
        mn = (mn + 0.3).clamp(1.0, 10.0);
        of = (of - 0.8).clamp(1.0, 10.0);
        break;
      case ScoutMacroPos.DEF:
        df = (df + 0.9).clamp(1.0, 10.0);
        fi = (fi + 0.2).clamp(1.0, 10.0);
        of = (of - 0.5).clamp(1.0, 10.0);
        break;
      case ScoutMacroPos.MEI:
        te = (te + 0.7).clamp(1.0, 10.0);
        mn = (mn + 0.3).clamp(1.0, 10.0);
        break;
      case ScoutMacroPos.ATA:
        of = (of + 0.9).clamp(1.0, 10.0);
        fi = (fi + 0.2).clamp(1.0, 10.0);
        df = (df - 0.6).clamp(1.0, 10.0);
        break;
    }

    return {
      ScoutPillar.ofensivo: _GradeUtils.fromAvg10(of),
      ScoutPillar.defensivo: _GradeUtils.fromAvg10(df),
      ScoutPillar.tecnico: _GradeUtils.fromAvg10(te),
      ScoutPillar.mental: _GradeUtils.fromAvg10(mn),
      ScoutPillar.fisico: _GradeUtils.fromAvg10(fi),
    };
  }

  bool _meetsMinPillars(
    Map<ScoutPillar, AttributeGrade> got,
    Map<ScoutPillar, AttributeGrade> min,
  ) {
    if (min.isEmpty) return true;

    // melhor = menor index (A antes de E)
    bool ok(AttributeGrade g, AttributeGrade m) => g.index <= m.index;

    for (final e in min.entries) {
      final g = got[e.key];
      if (g == null) return false;
      if (!ok(g, e.value)) return false;
    }
    return true;
  }

  // =========================================================
  // Helpers
  // =========================================================

  T _pickFromSet<T>(Random rng, Set<T> s) {
    final list = s.toList();
    return list[rng.nextInt(list.length)];
  }

  ScoutMacroPos _pickMacro(Random rng) {
    final v = rng.nextInt(100);
    if (v < 12) return ScoutMacroPos.GOL;
    if (v < 42) return ScoutMacroPos.DEF;
    if (v < 74) return ScoutMacroPos.MEI;
    return ScoutMacroPos.ATA;
  }

  int _pickAge(Random rng, Set<ScoutAgeBand> bands) {
    if (bands.isEmpty) {
      return 18 + rng.nextInt(17); // 18..34
    }
    final b = _pickFromSet(rng, bands);
    switch (b) {
      case ScoutAgeBand.u20:
        return 16 + rng.nextInt(5); // 16..20
      case ScoutAgeBand.a21_24:
        return 21 + rng.nextInt(4);
      case ScoutAgeBand.a25_29:
        return 25 + rng.nextInt(5);
      case ScoutAgeBand.a30_33:
        return 30 + rng.nextInt(4);
      case ScoutAgeBand.a34mais:
        return 34 + rng.nextInt(5); // 34..38
    }
  }

  ScoutContractStatus _pickContrato(Random rng) {
    final v = rng.nextInt(100);
    if (v < 10) return ScoutContractStatus.livre;
    if (v < 35) return ScoutContractStatus.curto;
    if (v < 75) return ScoutContractStatus.medio;
    return ScoutContractStatus.longo;
  }

  AttributeGrade _rollAdaptabilidade(Random rng,
      {required ScoutMarketRegion regiao}) {
    int roll() {
      final p = rng.nextInt(100);
      if (p < 8) return 5; // A
      if (p < 26) return 4; // B
      if (p < 71) return 3; // C
      if (p < 93) return 2; // D
      return 1; // E
    }

    var tier = roll(); // 1..5
    if (regiao == ScoutMarketRegion.europa ||
        regiao == ScoutMarketRegion.internacional) {
      if (rng.nextInt(100) < 18) tier = min(5, tier + 1);
    }

    return switch (tier) {
      5 => AttributeGrade.A,
      4 => AttributeGrade.B,
      3 => AttributeGrade.C,
      2 => AttributeGrade.D,
      _ => AttributeGrade.E,
    };
  }

  int _overallProxy(Map<ScoutPillar, AttributeGrade> pilares) {
    int v(AttributeGrade g) {
      switch (g) {
        case AttributeGrade.A:
          return 10;
        case AttributeGrade.B:
          return 8;
        case AttributeGrade.C:
          return 6;
        case AttributeGrade.D:
          return 4;
        case AttributeGrade.E:
          return 2;
      }
    }

    final vals = pilares.values.map(v).toList();
    final avg = vals.reduce((a, b) => a + b) / vals.length;
    return (avg * 10).round().clamp(10, 100);
  }

  int _valorEstimado({
    required int ovrAprox,
    required int idade,
    required ScoutMarketRegion regiao,
  }) {
    final base = ovrAprox * 100000;

    double multIdade;
    if (idade <= 20) {
      multIdade = 1.25;
    } else if (idade <= 24) {
      multIdade = 1.15;
    } else if (idade <= 29) {
      multIdade = 1.00;
    } else if (idade <= 33) {
      multIdade = 0.85;
    } else {
      multIdade = 0.70;
    }

    double multReg = switch (regiao) {
      ScoutMarketRegion.brasil => 1.00,
      ScoutMarketRegion.mercosul => 0.88,
      ScoutMarketRegion.internacional => 1.10,
      ScoutMarketRegion.europa => 1.35,
    };

    return (base * multIdade * multReg).round().clamp(200000, 900000000);
  }

  String _randomName(Random rng) {
    const nomes = [
      'Carlos',
      'João',
      'Pedro',
      'Lucas',
      'Mateus',
      'Rafael',
      'Bruno',
      'Diego',
      'Gabriel',
      'Gustavo',
      'Henrique',
      'Vitor',
      'Caio',
      'Fábio',
      'Renan',
      'Arthur',
      'Samuel',
      'Davi',
      'André',
      'Felipe',
      'Igor',
      'Daniel',
      'Thiago',
      'Murilo',
    ];
    const sobrenomes = [
      'Silva',
      'Souza',
      'Santos',
      'Oliveira',
      'Pereira',
      'Costa',
      'Rodrigues',
      'Almeida',
      'Nascimento',
      'Ferreira',
      'Carvalho',
      'Gomes',
      'Martins',
      'Araújo',
      'Barbosa',
      'Ribeiro',
      'Cardoso',
      'Melo',
      'Teixeira',
    ];

    final n = nomes[rng.nextInt(nomes.length)];
    final s = sobrenomes[rng.nextInt(sobrenomes.length)];
    return '$n $s';
  }
}

class _GradeUtils {
  // Conversão simples (1..10) -> A..E
  // Ajuste as faixas depois se quiser.
  static AttributeGrade fromAvg10(double v) {
    final x = v.clamp(1.0, 10.0);
    if (x >= 8.6) return AttributeGrade.A;
    if (x >= 7.2) return AttributeGrade.B;
    if (x >= 5.8) return AttributeGrade.C;
    if (x >= 4.4) return AttributeGrade.D;
    return AttributeGrade.E;
  }
}
