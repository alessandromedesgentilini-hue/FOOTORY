// lib/services/scout/scout_center_service.dart
//
// ScoutCenterService (MVP) — Relatório mensal por filtros
//
// ✅ Versão compatível com o teu projeto atual:
// - NÃO depende de AttributesContract (evita quebrar por mapping que não existe)
// - Lê dados do teu Jogador real:
//   • nome, idade
//   • pos / posDet (macro vem de posDet/pos)
//   • valorMercado (em vez de "valor")
//   • ovrCheio / estrelas (se existir) — senão calcula pelo mapa de atributos
//   • anosContrato (vira mesesContratoRestantes = anos*12 no MVP)
//
// - Pilares A–E:
//   • calculados por chunk do mapa de atributos (1..10) => 5 médias simples
//
// Se no futuro você quiser pilares “de verdade”, é só trocar _computePillarsFromAttributes().

import 'dart:math';

import '../../models/scout/scout_models.dart';

class ScoutCenterService {
  final Random _rng;

  ScoutCenterService({int? seed}) : _rng = Random(seed);

  // =========================================================
  // Limites por nível
  // =========================================================

  int reportLimitByScoutLevel(int scoutLevel) {
    final lvl = scoutLevel.clamp(1, 10);
    return (6 + lvl * 2).clamp(8, 26);
  }

  int targetsCapacityByScoutLevel(int scoutLevel) {
    final lvl = scoutLevel.clamp(1, 10);
    return (3 + lvl).clamp(4, 15);
  }

  bool canGenerateReport({
    required ScoutCenterState state,
    required String currentMonthKey,
  }) {
    return state.lastReportMonthKey != currentMonthKey;
  }

  // =========================================================
  // Relatório mensal
  // =========================================================

  ScoutReportResult<TJogador> generateMonthlyReport<TJogador>({
    required ScoutCenterState state,
    required String currentMonthKey,
    required int scoutLevel,
    required List<TJogador> pool,
  }) {
    if (!canGenerateReport(state: state, currentMonthKey: currentMonthKey)) {
      return ScoutReportResult<TJogador>(
        newState: state,
        entries: const [],
        wasGenerated: false,
      );
    }

    final filters = state.filters;
    final candidates = <ScoutReportEntry<TJogador>>[];

    for (final j in pool) {
      final nome = _readNome(j);
      final idade = _readIdade(j);
      final macroPos = _readMacroPos(j);
      final region = _readRegion(j);

      final valor = _readValorMercado(j);
      final mesesContratoRestantes = _readMesesContratoRestantes(j);
      final pillars = _computePillarsFromAttributes(j);

      if (!_passesFilters(
        filters: filters,
        idade: idade,
        macroPos: macroPos,
        region: region,
        valor: valor,
        mesesContratoRestantes: mesesContratoRestantes,
        pillars: pillars,
      )) {
        continue;
      }

      final ovr100 = _readOvrCheio(j);
      final estrelas = _readEstrelas(j);

      // Score simples MVP: ovr + soma pilares + ruído leve
      final baseScore = ovr100.toDouble() +
          (pillars.a + pillars.b + pillars.c + pillars.d + pillars.e)
              .toDouble() +
          (_rng.nextDouble() * 3.0);

      candidates.add(
        ScoutReportEntry<TJogador>(
          jogador: j,
          nome: nome,
          idade: idade,
          macroPos: macroPos,
          region: region,
          ovr100: ovr100,
          estrelas: estrelas,
          valor: valor,
          mesesContratoRestantes: mesesContratoRestantes,
          pillarA: pillars.a,
          pillarB: pillars.b,
          pillarC: pillars.c,
          pillarD: pillars.d,
          pillarE: pillars.e,
          score: baseScore,
        ),
      );
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));

    final cap = targetsCapacityByScoutLevel(scoutLevel);
    final limit = reportLimitByScoutLevel(scoutLevel);

    final top = candidates.take(max(cap, limit)).take(limit).toList();

    final snapshots = top
        .map(
          (e) => ScoutReportSnapshot(
            nome: e.nome,
            idade: e.idade,
            macroPos: e.macroPos.label,
            region: e.region.label,
            ovr100: e.ovr100,
            estrelas: e.estrelas,
            valor: e.valor,
            mesesContratoRestantes: e.mesesContratoRestantes,
          ),
        )
        .toList(growable: false);

    final newState = state.copyWith(
      lastReportMonthKey: currentMonthKey,
      lastReport: snapshots,
    );

    return ScoutReportResult<TJogador>(
      newState: newState,
      entries: top,
      wasGenerated: true,
    );
  }

  // =========================================================
  // FILTERS
  // =========================================================

  bool _passesFilters({
    required ScoutFilters filters,
    required int idade,
    required MacroPos macroPos,
    required ScoutRegion region,
    required int valor,
    required int mesesContratoRestantes,
    required _Pillars pillars,
  }) {
    if (filters.regions.isNotEmpty && !filters.regions.contains(region)) {
      return false;
    }

    if (filters.macroPositions.isNotEmpty &&
        !filters.macroPositions.contains(macroPos)) {
      return false;
    }

    if (idade < filters.ageRange.min || idade > filters.ageRange.max) {
      return false;
    }

    switch (filters.contractFilter) {
      case ScoutContractFilter.qualquer:
        break;
      case ScoutContractFilter.livre:
        if (mesesContratoRestantes != 0) return false;
        break;
      case ScoutContractFilter.expiraAte6m:
        if (mesesContratoRestantes == 0 || mesesContratoRestantes > 6) {
          return false;
        }
        break;
      case ScoutContractFilter.expiraAte12m:
        if (mesesContratoRestantes == 0 || mesesContratoRestantes > 12) {
          return false;
        }
        break;
      case ScoutContractFilter.sobContrato:
        if (mesesContratoRestantes == 0) return false;
        break;
    }

    if (filters.maxValue != null && valor > filters.maxValue!) return false;

    if (filters.minPillarA != null && pillars.a < filters.minPillarA!) {
      return false;
    }
    if (filters.minPillarB != null && pillars.b < filters.minPillarB!) {
      return false;
    }
    if (filters.minPillarC != null && pillars.c < filters.minPillarC!) {
      return false;
    }
    if (filters.minPillarD != null && pillars.d < filters.minPillarD!) {
      return false;
    }
    if (filters.minPillarE != null && pillars.e < filters.minPillarE!) {
      return false;
    }

    return true;
  }

  // =========================================================
  // ADAPTERS (Jogador -> dados)
  // =========================================================

  String _readNome(dynamic j) {
    try {
      final v = j.nome;
      if (v is String && v.trim().isNotEmpty) return v;
    } catch (_) {}
    return 'Desconhecido';
  }

  int _readIdade(dynamic j) {
    try {
      final v = j.idade;
      if (v is int) return v;
      if (v is num) return v.toInt();
    } catch (_) {}
    return 20;
  }

  int _readValorMercado(dynamic j) {
    // teu model usa valorMercado
    try {
      final v = j.valorMercado;
      if (v is int) return v;
      if (v is num) return v.toInt();
    } catch (_) {}

    // fallback antigo: valor
    try {
      final v = j.valor;
      if (v is int) return v;
      if (v is num) return v.toInt();
    } catch (_) {}

    return 0;
  }

  int _readMesesContratoRestantes(dynamic j) {
    // MVP: se tiver mesesContratoRestantes usa; senão anosContrato*12; senão 0 (livre)
    try {
      final v = j.mesesContratoRestantes;
      if (v is int) return v;
      if (v is num) return v.toInt();
    } catch (_) {}

    try {
      final a = j.anosContrato;
      if (a is int) return (a * 12).clamp(0, 120);
      if (a is num) return (a.toInt() * 12).clamp(0, 120);
    } catch (_) {}

    return 0;
  }

  int _readOvrCheio(dynamic j) {
    // teu Jogador tem ovrCheio
    try {
      final v = j.ovrCheio;
      if (v is int) return v.clamp(10, 100);
      if (v is num) return v.toInt().clamp(10, 100);
    } catch (_) {}

    // fallback: soma de 10 atributos “mais altos” se não existir
    final attrs = _readAtributos(j);
    if (attrs.isEmpty) return 10;

    final vals = attrs.values.map((e) => e.clamp(1, 10)).toList();
    vals.sort((a, b) => b.compareTo(a));
    final take10 = vals.take(10).toList();
    final sum = take10.fold<int>(0, (a, b) => a + b);
    return sum.clamp(10, 100);
  }

  double _readEstrelas(dynamic j) {
    // teu Jogador tem estrelas (1..10 em .5)
    try {
      final v = j.estrelas;
      if (v is double) return _roundToHalf(v.clamp(0.0, 10.0));
      if (v is num) return _roundToHalf(v.toDouble().clamp(0.0, 10.0));
    } catch (_) {}

    final ovr = _readOvrCheio(j);
    final avg = ovr / 10.0; // 1..10
    return _roundToHalf(avg);
  }

  MacroPos _readMacroPos(dynamic j) {
    // Preferência: pos (macro) -> DEF/MEI/ATA/GOL
    // fallback: posDet -> LD/LE/ZAG/... e mapeia
    String p = '';

    try {
      final v = j.pos;
      if (v is String) p = v;
    } catch (_) {}

    if (p.isEmpty) {
      try {
        final v = j.posDet;
        if (v is String) p = v;
      } catch (_) {}
    }

    final s = p.toUpperCase().trim();

    if (s == 'GOL' || s == 'GK') return MacroPos.goleiro;

    // defesa
    if (s == 'DEF' ||
        s == 'ZAG' ||
        s == 'LE' ||
        s == 'LD' ||
        s == 'LAT' ||
        s == 'CB' ||
        s == 'LB' ||
        s == 'RB') {
      return MacroPos.defesa;
    }

    // meio
    if (s == 'MEI' ||
        s == 'VOL' ||
        s == 'MC' ||
        s == 'ME' ||
        s == 'MD' ||
        s == 'CAM' ||
        s == 'CDM' ||
        s == 'CM' ||
        s == 'LM' ||
        s == 'RM') {
      return MacroPos.meio;
    }

    // ataque
    if (s == 'ATA' ||
        s == 'CA' ||
        s == 'PE' ||
        s == 'PD' ||
        s == 'ST' ||
        s == 'CF' ||
        s == 'LW' ||
        s == 'RW') {
      return MacroPos.ataque;
    }

    return MacroPos.meio;
  }

  ScoutRegion _readRegion(dynamic j) {
    // MVP: se existir string regiao/region/pais tenta mapear; senão Brasil
    try {
      final v = j.regiao;
      if (v is String) {
        final s = v.toLowerCase().trim();
        for (final r in ScoutRegion.values) {
          if (r.name.toLowerCase() == s) return r;
        }
      }
    } catch (_) {}

    try {
      final v = j.region;
      if (v is String) {
        final s = v.toLowerCase().trim();
        for (final r in ScoutRegion.values) {
          if (r.name.toLowerCase() == s) return r;
        }
      }
    } catch (_) {}

    try {
      final v = j.pais;
      if (v is String) {
        final s = v.toLowerCase().trim();
        if (s == 'brasil' || s == 'brazil') return ScoutRegion.brasil;
      }
    } catch (_) {}

    return ScoutRegion.brasil;
  }

  Map<String, int> _readAtributos(dynamic j) {
    try {
      final v = j.atributos;
      if (v is Map) {
        return v.map((k, v) {
          final kk = k.toString();
          final vv = (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 1;
          return MapEntry(kk, vv.clamp(1, 10));
        });
      }
    } catch (_) {}
    return const {};
  }

  double _roundToHalf(double v) => (v * 2.0).round() / 2.0;

  // =========================================================
  // PILLARS A–E (média por chunks do mapa de atributos)
  // =========================================================

  _Pillars _computePillarsFromAttributes(dynamic j) {
    final attrs = _readAtributos(j);
    if (attrs.isEmpty) {
      return const _Pillars(a: 1, b: 1, c: 1, d: 1, e: 1);
    }

    // ordena as chaves pra ser determinístico
    final keys = attrs.keys.toList()..sort();
    final chunks = _chunk(keys, 5);

    int avgFor(List<String> ks) {
      if (ks.isEmpty) return 1;
      int sum = 0;
      for (final k in ks) {
        sum += (attrs[k] ?? 1).clamp(1, 10);
      }
      return (sum / ks.length).round().clamp(1, 10);
    }

    return _Pillars(
      a: avgFor(chunks[0]),
      b: avgFor(chunks[1]),
      c: avgFor(chunks[2]),
      d: avgFor(chunks[3]),
      e: avgFor(chunks[4]),
    );
  }

  List<List<String>> _chunk(List<String> list, int chunks) {
    final out = List.generate(chunks, (_) => <String>[]);
    for (int i = 0; i < list.length; i++) {
      out[i % chunks].add(list[i]);
    }
    return out;
  }
}

class ScoutReportResult<TJogador> {
  final ScoutCenterState newState;
  final List<ScoutReportEntry<TJogador>> entries;
  final bool wasGenerated;

  ScoutReportResult({
    required this.newState,
    required this.entries,
    required this.wasGenerated,
  });
}

class _Pillars {
  final int a;
  final int b;
  final int c;
  final int d;
  final int e;

  const _Pillars({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.e,
  });
}
