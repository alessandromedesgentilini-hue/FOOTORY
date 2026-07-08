// lib/services/generator/jogador_generator.dart
//
// Gerador de jogadores (MVP) — Caminho B (CORE COMPLETO)
// - ✅ Gera Jogador com TODOS os atributos reais 1..10 (29 chaves) => CANÔNICO
// - 10 da função ficam mais fortes (identidade por posição)
// - Mantém pilares legados (40..95 aprox) como compat temporária
// - Macro posição: GOL/DEF/MEI/ATA
// - Usa FacePool para rosto (fallback automático)
//
// Observação: depois a gente troca por banco fixo + listas de nomes.

import 'dart:math';

import '../../models/jogador.dart';
import '../../models/pe_preferencial.dart';
import '../assets/face_pool.dart';

class JogadorGenerator {
  final Random _rng;
  JogadorGenerator({int? seed}) : _rng = Random(seed);

  // ----- nomes simples (pode trocar depois pelo teu pool completo) -----
  static const _firstBR = [
    'João',
    'Pedro',
    'Lucas',
    'Matheus',
    'Gabriel',
    'Felipe',
    'André',
    'Bruno',
    'Diego',
    'Gustavo',
    'Rafael',
    'Thiago',
    'Caio',
    'Henrique',
    'Victor',
    'Miguel',
    'Guilherme',
    'Eduardo',
  ];
  static const _lastBR = [
    'Silva',
    'Souza',
    'Oliveira',
    'Santos',
    'Rodrigues',
    'Ferreira',
    'Almeida',
    'Gomes',
    'Carvalho',
    'Ribeiro',
    'Barbosa',
    'Araujo',
    'Pereira',
    'Lima',
    'Correia',
    'Teixeira',
    'Machado',
    'Martins',
  ];

  String _nomeBR() =>
      '${_firstBR[_rng.nextInt(_firstBR.length)]} ${_lastBR[_rng.nextInt(_lastBR.length)]}';

  // Macro posição: "GOL","DEF","MEI","ATA"
  String _macroPos() {
    final p = _rng.nextDouble();
    if (p < 0.10) return 'GOL';
    if (p < 0.10 + 0.35) return 'DEF';
    if (p < 0.10 + 0.35 + 0.35) return 'MEI';
    return 'ATA';
  }

  PePreferencial _sortearPe() {
    final x = _rng.nextDouble();
    if (x < 0.09) return PePreferencial.ambos;
    if (x < 0.59) return PePreferencial.direito;
    return PePreferencial.esquerdo;
  }

  int _randBetween(int min, int max) => min + _rng.nextInt(max - min + 1);

  int _clamp10(int v) => v.clamp(1, 10);

  // =====================================================================
  // CATÁLOGO COMPLETO (29) — CORE
  // =====================================================================

  static const List<String> _catalogoKeys = [
    // Defensivo (linha)
    'cobertura_defensiva',
    'antecipacao',
    'marcacao',
    'jogo_aereo',
    'desarme',

    // Técnico (linha)
    'passe_curto',
    'passe_longo',
    'drible',
    'dominio_conducao',
    'cruzamento',

    // Mental / tático
    'tomada_decisao',
    'capacidade_tatica',
    'frieza',
    'coordenacao_motora',
    'espirito_protagonista',
    'presenca_ofensiva',

    // Físico
    'velocidade',
    'resistencia',
    'potencia',
    'composicao_natural',

    // Ofensivo extra
    'finalizacao',
    'chute_longe',

    // GK (técnicos)
    'def_finalizacoes',
    'def_chute_longe',
    'def_bola_parada',
    'def_penalti',
    'saida_gol',
    'reflexo_reacao',
    'controle_area',
  ];

  // =====================================================================
  // 10 atributos da função (para OVR cheio)
  // =====================================================================

  List<String> _roleKeys(String pos) {
    switch (pos) {
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
      case 'DEF':
        return const [
          'marcacao',
          'cobertura_defensiva',
          'jogo_aereo',
          'antecipacao',
          'desarme',
          'tomada_decisao',
          'capacidade_tatica',
          'potencia',
          'coordenacao_motora',
          'resistencia',
        ];
      case 'MEI':
        return const [
          'passe_curto',
          'passe_longo',
          'dominio_conducao',
          'drible',
          'tomada_decisao',
          'capacidade_tatica',
          'marcacao',
          'resistencia',
          'frieza',
          'velocidade',
        ];
      default: // ATA
        return const [
          'finalizacao',
          'presenca_ofensiva',
          'drible',
          'dominio_conducao',
          'passe_curto',
          'tomada_decisao',
          'frieza',
          'velocidade',
          'potencia',
          'coordenacao_motora',
        ];
    }
  }

  // =====================================================================
  // Geração CORE: catálogo completo coerente por posição
  // =====================================================================

  Map<String, int> _gerarCatalogoCompleto({
    required String pos,
    required bool isBase,
  }) {
    final min10 = isBase ? 3 : 5;
    final max10 = isBase ? 6 : 8;

    int rollBase() {
      final bonusChance = isBase ? 8 : 12; // %
      final v = _randBetween(1, 100);
      if (v <= bonusChance) return min(10, max10 + 1);
      return _randBetween(min10, max10);
    }

    final m = <String, int>{};

    // 1) base para todo mundo (não vira tudo 1 fora da função)
    for (final k in _catalogoKeys) {
      m[k] = rollBase();
    }

    // 2) identidade: 10 da função sobem / fora da função caem leve
    final role = _roleKeys(pos);

    for (final k in _catalogoKeys) {
      if (!role.contains(k)) {
        final dec = _randBetween(0, 2); // -0..-2
        m[k] = _clamp10(m[k]! - dec);
      }
    }

    for (final k in role) {
      final inc = _randBetween(1, 2); // +1..+2
      m[k] = _clamp10((m[k] ?? rollBase()) + inc);
    }

    // 3) assinatura por macro (sinergias pequenas)
    _applyMacroSignature(pos, m);

    // 4) clamp final
    return m.map((k, v) => MapEntry(k, _clamp10(v)));
  }

  void _applyMacroSignature(String pos, Map<String, int> m) {
    void bump(String k, int d) => m[k] = _clamp10((m[k] ?? 5) + d);
    final p = pos.toUpperCase();

    if (p == 'GOL') {
      bump('reflexo_reacao', _randBetween(0, 1));
      bump('controle_area', _randBetween(0, 1));
      bump('tomada_decisao', _randBetween(0, 1));
      bump('frieza', _randBetween(0, 1));
      bump('finalizacao', -_randBetween(0, 1));
      bump('drible', -_randBetween(0, 1));
      return;
    }

    if (p == 'DEF') {
      bump('marcacao', _randBetween(0, 1));
      bump('desarme', _randBetween(0, 1));
      bump('cobertura_defensiva', _randBetween(0, 1));
      bump('jogo_aereo', _randBetween(0, 1));
      bump('finalizacao', -_randBetween(0, 1));
      return;
    }

    if (p == 'MEI') {
      bump('passe_curto', _randBetween(0, 1));
      bump('passe_longo', _randBetween(0, 1));
      bump('tomada_decisao', _randBetween(0, 1));
      bump('capacidade_tatica', _randBetween(0, 1));
      bump('marcacao', _randBetween(0, 1));
      return;
    }

    // ATA
    bump('finalizacao', _randBetween(0, 1));
    bump('presenca_ofensiva', _randBetween(0, 1));
    bump('velocidade', _randBetween(0, 1));
    bump('coordenacao_motora', _randBetween(0, 1));
    bump('desarme', -_randBetween(0, 1));
  }

  int _ovrCheio(String pos, Map<String, int> attrs) {
    final keys = _roleKeys(pos);
    var sum = 0;
    for (final k in keys) {
      sum += (attrs[k] ?? 1).clamp(1, 10);
    }
    return sum; // 10..100
  }

  // =====================================================================
  // Pilares legados 40..95 (compat temporária)
  // =====================================================================

  Map<String, Map<String, int>> _legacyPillarsFromAttrs(
      Map<String, int> attrs) {
    int to95(int v10) {
      final v = v10.clamp(1, 10);
      final n = 40 + ((v - 1) / 9.0) * 55.0;
      return n.round().clamp(40, 95);
    }

    int pick(String k, int def10) => to95(attrs[k] ?? def10);

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

  /// Gera um lote de jogadores prontos para uso na UI.
  /// - [quantidade] número de jogadores
  /// - [nacionalidade] hoje só influencia o nome (BR)
  /// - [isBase] true gera 16–18 anos e atributos mais baixos
  List<Jogador> gerarLote(
    int quantidade, {
    String nacionalidade = 'BRA',
    bool isBase = false,
  }) {
    final List<Jogador> out = [];

    for (var i = 0; i < quantidade; i++) {
      final nome = nacionalidade.toUpperCase() == 'BRA' ? _nomeBR() : _nomeBR();
      final pos = _macroPos();
      final idade = isBase ? _randBetween(16, 18) : _randBetween(18, 34);
      final pe = _sortearPe();

      // ✅ catálogo completo 29
      final atributos = _gerarCatalogoCompleto(pos: pos, isBase: isBase);

      // ✅ OVR cheio dinâmico (10..100) baseado nos 10 da função
      final ovr = _ovrCheio(pos, atributos);

      final valor = _calcValorMercado(ovrCheio: ovr, idade: idade);
      final salario =
          (max(ovr - 50, 1) * (isBase ? 800 : 4500)) + _randBetween(0, 2500);

      final face = FacePool.I.random(base: isBase);

      final pilares = _legacyPillarsFromAttrs(atributos);

      out.add(
        Jogador(
          id: 'gen_${pos.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}_$i',
          nome: nome,
          pos: pos,
          idade: idade,
          pe: pe,
          atributos: atributos,
          ofensivo: pilares['of']!,
          defensivo: pilares['df']!,
          tecnico: pilares['te']!,
          mental: pilares['mn']!,
          fisico: pilares['fi']!,
          faceAsset: face,
          salarioMensal: salario,
          valorMercado: valor,
          anosContrato: isBase ? 3 : _randBetween(1, 5),
        ),
      );
    }

    return out;
  }
}
