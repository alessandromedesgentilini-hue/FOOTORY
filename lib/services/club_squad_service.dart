// lib/services/club_squad_service.dart
//
// Geração procedural (MVP) — Caminho B (atributos 1..10)
// + ✅ Métodos para adicionar jogador contratado ao elenco (sem quebrar cache)
//
// ✅ REFATORAÇÃO POSIÇÕES (posDet):
// - Agora gera posições detalhadas perfeitas:
//   GOL, LD, ZAG, LE, VOL, MC, MEI, MD, ME, PD, PE, CA
// - Macro (pos) é derivado no Jogador, então não existe mais “meio-termo”.
//
// ✅ Também corrige bug:
// - "forca" -> "potencia" (chave canônica)
//
// ✅ Também garante atributos com catálogo completo (29 chaves):
// - Jogador já completa no construtor, mas aqui a gente gera melhor e consistente.

import 'dart:math';

import '../core/seeded_rng.dart';
import '../models/jogador.dart';
import '../models/pe_preferencial.dart';

class ClubSquadService {
  ClubSquadService._();
  static final ClubSquadService I = ClubSquadService._();

  final Map<String, List<Jogador>> _cachePro = {};
  final Map<String, List<Jogador>> _cacheBase = {};

  List<Jogador> getProSquad(String clubId) {
    return _cachePro.putIfAbsent(
      clubId,
      () => _generateSquad(clubId, isBase: false),
    );
  }

  List<Jogador> getBaseSquad(String clubId) {
    return _cacheBase.putIfAbsent(
      clubId,
      () => _generateSquad(clubId, isBase: true),
    );
  }

  /// ✅ Adiciona ao elenco PRO (contratações do mercado)
  void addToProSquad(String clubId, Jogador jogador) {
    final list = _cachePro.putIfAbsent(
      clubId,
      () => _generateSquad(clubId, isBase: false),
    );
    if (list.any((j) => j.id == jogador.id)) return;
    list.add(jogador);
  }

  /// ✅ Adiciona à Base
  void addToBaseSquad(String clubId, Jogador jogador) {
    final list = _cacheBase.putIfAbsent(
      clubId,
      () => _generateSquad(clubId, isBase: true),
    );
    if (list.any((j) => j.id == jogador.id)) return;
    list.add(jogador);
  }

  // =====================================================================
  // GERAÇÃO
  // =====================================================================

  List<Jogador> _generateSquad(String clubId, {required bool isBase}) {
    final seed = clubId.hashCode ^ (isBase ? 0xBADA55 : 0xC0FFEE);
    final rng = SeededRng(seed);

    final int size = isBase ? 18 : 23;
    final List<Jogador> list = [];

    // PRO (23-ish) / BASE (18-ish)
    final posList = _buildPosList(size: size, isBase: isBase);

    for (var i = 0; i < size; i++) {
      final posDet = posList[i];

      final idade = isBase ? rng.intInRange(16, 19) : rng.intInRange(21, 34);

      final int min10 = isBase ? 3 : 5;
      final int max10 = isBase ? 6 : 8;

      final attrs = _generateAtributosPorPosDet(
        rng: rng,
        posDet: posDet,
        min10: min10,
        max10: max10,
        isBase: isBase,
      );

      final pe = _randomPe(rng);

      final ovrCheio = _ovrCheioFromAttrs(posDet, attrs);

      final valorMercado = _calcValorMercado(ovrCheio: ovrCheio, idade: idade);
      final salarioMensal = max(20000, (valorMercado / 80).round());
      final anosContrato = rng.intInRange(1, 5);

      // ✅ compat (pilares 0..100) mas agora retornando MAPS certinhos
      final pilares = _legacyPillarsFromAttrs(attrs);

      final jogador = Jogador(
        id: '${clubId}_${isBase ? "b" : "p"}_$i',
        nome: _randomName(rng),
        posDet: posDet,
        idade: idade,
        pe: pe,
        atributos: attrs,
        ofensivo: pilares['of']!,
        defensivo: pilares['df']!,
        tecnico: pilares['te']!,
        mental: pilares['mn']!,
        fisico: pilares['fi']!,
        valorMercado: valorMercado,
        salarioMensal: salarioMensal,
        anosContrato: anosContrato,
        faceAsset: 'faces/placeholder.png',
      );

      list.add(jogador);
    }

    return list;
  }

  List<String> _buildPosList({required int size, required bool isBase}) {
    final base = <String>[];

    if (!isBase) {
      base.addAll([
        'GOL',
        'GOL',
        'LD',
        'LD',
        'LE',
        'LE',
        'ZAG',
        'ZAG',
        'ZAG',
        'ZAG',
        'VOL',
        'VOL',
        'VOL',
        'MC',
        'MC',
        'MC',
        'MC',
        'MEI',
        'MEI',
        'MD',
        'ME',
        'PD',
        'PE',
        'CA',
        'CA',
      ]);
    } else {
      base.addAll([
        'GOL',
        'GOL',
        'LD',
        'LD',
        'LE',
        'LE',
        'ZAG',
        'ZAG',
        'ZAG',
        'VOL',
        'VOL',
        'MC',
        'MC',
        'MC',
        'MEI',
        'MD',
        'ME',
        'PD',
        'PE',
        'CA',
      ]);
    }

    if (base.length > size) {
      return base.take(size).toList(growable: false);
    }

    while (base.length < size) {
      base.add(base.length.isEven ? 'MC' : 'ZAG');
    }

    return base;
  }

  // =====================================================================
  // ATRIBUTOS 1..10 — por posição DETALHADA
  // =====================================================================

  Map<String, int> _generateAtributosPorPosDet({
    required SeededRng rng,
    required String posDet,
    required int min10,
    required int max10,
    required bool isBase,
  }) {
    int roll() {
      final bonusChance = isBase ? 8 : 12; // %
      final v = rng.intInRange(1, 100);
      if (v <= bonusChance) {
        return min(10, max10 + 1);
      }
      return rng.intInRange(min10, max10);
    }

    // Começa com catálogo completo (default baixo) e sobrescreve os 10 da função
    final m = Jogador.coreDefault(value: max(1, min10 - 1));

    final keys10 = _roleKeysFromPosDet(posDet);
    for (final k in keys10) {
      m[k] = roll();
    }

    // espalhada leve
    void bump(String k, int lo, int hi) {
      final v = rng.intInRange(lo, hi).clamp(1, 10);
      if ((m[k] ?? 1) < v) m[k] = v;
    }

    bump('passe_longo', min10, max10);
    bump('capacidade_tatica', min10, max10);
    bump('tomada_decisao', min10, max10);
    bump('frieza', min10, max10);

    bump('resistencia', min10, max10);
    bump('velocidade', min10, max10);
    bump('potencia', min10, max10);

    final out = <String, int>{};
    for (final k in Jogador.coreKeys) {
      final v = (m[k] ?? 1).clamp(1, 10);
      out[k] = v;
    }
    return out;
  }

  int _ovrCheioFromAttrs(String posDet, Map<String, int> attrs) {
    final keys = _roleKeysFromPosDet(posDet);
    var sum = 0;
    for (final k in keys) {
      sum += (attrs[k] ?? 1).clamp(1, 10);
    }
    return sum.clamp(10, 100);
  }

  List<String> _roleKeysFromPosDet(String posDet) {
    final p = posDet.toUpperCase().trim();

    switch (p) {
      case 'GOL':
        return const [
          'def_finalizacoes',
          'def_chute_longe',
          'def_bola_parada',
          'def_penalti',
          'saida_gol',
          'reflexo_reacao',
          'controle_area',
          'tomada_decisao',
          'frieza',
          'composicao_natural',
        ];

      case 'LD':
      case 'LE':
        return const [
          'cobertura_defensiva',
          'antecipacao',
          'passe_curto',
          'cruzamento',
          'tomada_decisao',
          'capacidade_tatica',
          'velocidade',
          'resistencia',
          'potencia',
          'composicao_natural',
        ];

      case 'ZAG':
        return const [
          'marcacao',
          'cobertura_defensiva',
          'jogo_aereo',
          'antecipacao',
          'desarme',
          'tomada_decisao',
          'frieza',
          'capacidade_tatica',
          'potencia',
          'coordenacao_motora',
        ];

      case 'VOL':
        return const [
          'marcacao',
          'cobertura_defensiva',
          'jogo_aereo',
          'antecipacao',
          'desarme',
          'passe_curto',
          'passe_longo',
          'tomada_decisao',
          'capacidade_tatica',
          'resistencia',
        ];

      case 'MC':
        return const [
          'drible',
          'chute_longe',
          'marcacao',
          'antecipacao',
          'passe_curto',
          'passe_longo',
          'dominio_conducao',
          'tomada_decisao',
          'resistencia',
          'frieza',
        ];

      case 'MEI':
        return const [
          'finalizacao',
          'drible',
          'passe_curto',
          'passe_longo',
          'dominio_conducao',
          'tomada_decisao',
          'frieza',
          'velocidade',
          'resistencia',
          'coordenacao_motora',
        ];

      case 'MD':
      case 'ME':
        return const [
          'drible',
          'passe_curto',
          'passe_longo',
          'dominio_conducao',
          'tomada_decisao',
          'capacidade_tatica',
          'cobertura_defensiva',
          'resistencia',
          'velocidade',
          'potencia',
        ];

      case 'PD':
      case 'PE':
        return const [
          'finalizacao',
          'drible',
          'passe_curto',
          'dominio_conducao',
          'cruzamento',
          'tomada_decisao',
          'espirito_protagonista',
          'velocidade',
          'coordenacao_motora',
          'frieza',
        ];

      case 'CA':
        return const [
          'finalizacao',
          'presenca_ofensiva',
          'drible',
          'jogo_aereo',
          'passe_curto',
          'dominio_conducao',
          'tomada_decisao',
          'frieza',
          'potencia',
          'coordenacao_motora',
        ];
    }

    return _roleKeysFromPosDet('MC');
  }

  // ✅ FIX REAL: agora retorna os 5 mapas (Map<String,int>)
  Map<String, Map<String, int>> _legacyPillarsFromAttrs(
      Map<String, int> attrs) {
    int to95(int v10) {
      final v = v10.clamp(1, 10);
      final n = 40 + ((v - 1) / 9.0) * 55.0;
      return n.round().clamp(40, 95);
    }

    int pick(String k, int def) => to95(attrs[k] ?? def);

    final fin = pick('finalizacao', 6);
    final marc = pick('marcacao', 6);
    final tec = pick('drible', 6);
    final mnt = pick('tomada_decisao', 6);
    final fis = pick('velocidade', 6);

    return {
      'of': {'fin': fin, 'finalizacao': fin},
      'df': {'marc': marc, 'marcacao': marc},
      'te': {'tec': tec, 'tecnica': tec},
      'mn': {'mnt': mnt, 'mental': mnt},
      'fi': {'fis': fis, 'fisico': fis},
    };
  }

  int _calcValorMercado({required int ovrCheio, required int idade}) {
    final base = ovrCheio * 100000;

    double mult;
    if (idade <= 20) {
      mult = 1.25;
    } else if (idade <= 24) {
      mult = 1.15;
    } else if (idade <= 29) {
      mult = 1.00;
    } else if (idade <= 33) {
      mult = 0.85;
    } else {
      mult = 0.70;
    }

    return (base * mult).round().clamp(200000, 500000000);
  }

  // =====================================================================
  // HELPERS
  // =====================================================================

  PePreferencial _randomPe(SeededRng rng) {
    final v = rng.intInRange(0, 99);
    if (v < 15) return PePreferencial.ambos;
    if (v < 65) return PePreferencial.direito;
    return PePreferencial.esquerdo;
  }

  String _randomName(SeededRng rng) {
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

    final n = nomes[rng.intInRange(0, nomes.length - 1)];
    final s = sobrenomes[rng.intInRange(0, sobrenomes.length - 1)];
    return '$n $s';
  }
}
