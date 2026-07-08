// lib/services/generator/player_gen.dart
//
// Gera jogadores (PRO e Base) e mapeia para o modelo `Jogador`.
//
// ✅ CAMINHO B (CORE COMPLETO):
// - O modelo canônico é atributos 1..10 (Map<String,int>) dentro de Jogador.
// - PlayerView continua existindo para compat.
// - toJogadorFromView agora cria `atributos` com TODOS os 29 atributos.
// - OVR cheio (10..100) = soma dos 10 atributos da função (macro pos).
// - Mantém pilares (40..95) como compat temporária (pra telas antigas não quebrarem).

import 'dart:math';

import 'package:futsim/models/jogador.dart';
import 'package:futsim/models/pe_preferencial.dart';
import 'package:futsim/services/assets/face_pool.dart';

class PlayerView {
  final String id;
  final String nome;

  /// "GK" | "DF" | "MF" | "FW"
  final String pos;
  final int idade;
  final PePreferencial pe;

  /// Overall em escala 10..100 (macronível do jogador)
  final int ovr10to100;

  /// Caminho do asset (opcional — pode ser null e cair no placeholder)
  final String? foto;

  const PlayerView({
    required this.id,
    required this.nome,
    required this.pos,
    required this.idade,
    required this.pe,
    required this.ovr10to100,
    required this.foto,
  });
}

class PlayerGen {
  final Random _rng;
  PlayerGen({int? seed})
      : _rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

  // ======= Nomes simples (placeholder) =======
  static const _firstNames = <String>[
    'João',
    'Pedro',
    'Felipe',
    'Matheus',
    'Gustavo',
    'Rafael',
    'Eduardo',
    'Diego',
    'Henrique',
    'André',
    'Bruno',
    'Lucas',
    'Victor',
    'Thiago',
    'Guilherme',
    'Caio',
    'Luan',
    'Igor',
    'Marcelo',
    'Fabio',
    'Tiago',
    'Alex',
    'Daniel',
    'Leandro',
  ];

  static const _surnames = <String>[
    'Silva',
    'Souza',
    'Oliveira',
    'Gomes',
    'Almeida',
    'Pereira',
    'Ferreira',
    'Martins',
    'Machado',
    'Rodrigues',
    'Barbosa',
    'Teixeira',
    'Correia',
    'Araujo',
    'Carvalho',
    'Costa',
    'Moura',
    'Mendes',
    'Ribeiro',
    'Cardoso',
    'Cavalcanti',
    'Tavares',
    'Rocha',
    'Nogueira',
  ];

  String _nome() {
    final a = _firstNames[_rng.nextInt(_firstNames.length)];
    final b = _surnames[_rng.nextInt(_surnames.length)];
    return '$a $b';
  }

  String _pos() {
    const macro = ['GK', 'DF', 'MF', 'FW'];
    return macro[_rng.nextInt(macro.length)];
  }

  PePreferencial _pe() {
    final r = _rng.nextDouble();
    if (r < 0.10) return PePreferencial.ambos;
    if (r < 0.55) return PePreferencial.direito;
    return PePreferencial.esquerdo;
  }

  int _ovr10to100(double nivel) {
    final double base = (60 + (nivel - 3.0) * 8).clamp(50.0, 75.0);
    final int noise = _rng.nextInt(21) - 10; // +/-10
    final int val = (base + noise).round();
    return val.clamp(10, 100);
  }

  // =========================
  // Geração de jogadores
  // =========================

  List<PlayerView> gerarProf(
    int n, {
    required double nivel,
    required String clubeId,
  }) {
    final list = <PlayerView>[];
    for (var i = 0; i < n; i++) {
      final id = '${clubeId}_P_${i}_${_rng.nextInt(1 << 31)}';
      final pos = _pos();
      final face = FacePool.I.random(base: false, rng: _rng);
      list.add(
        PlayerView(
          id: id,
          nome: _nome(),
          pos: pos,
          idade: 18 + _rng.nextInt(17), // 18..34
          pe: _pe(),
          ovr10to100: _ovr10to100(nivel),
          foto: face,
        ),
      );
    }
    return list;
  }

  List<PlayerView> gerarBase({
    required String clubeId,
    required double nivel,
    int n = 12,
  }) {
    final list = <PlayerView>[];
    for (var i = 0; i < n; i++) {
      final id = '${clubeId}_B_${i}_${_rng.nextInt(1 << 31)}';
      final pos = _pos();
      final face = FacePool.I.random(base: true, rng: _rng);
      list.add(
        PlayerView(
          id: id,
          nome: _nome(),
          pos: pos,
          idade: 16 + _rng.nextInt(3), // 16..18
          pe: _pe(),
          ovr10to100: (_ovr10to100(nivel) - 5).clamp(10, 100),
          foto: face,
        ),
      );
    }
    return list;
  }

  // =========================
  // Mapping para Jogador (CAMINHO B — CORE COMPLETO)
  // =========================

  Jogador toJogadorFromView(PlayerView pv) {
    final macro = _tradPos(pv.pos); // GOL/DEF/MEI/ATA

    // converte pv.ovr10to100 (10..100) para média 1..10 (aprox)
    final media10 = (pv.ovr10to100 / 10.0).clamp(1.0, 10.0);

    // ✅ gera catálogo completo 29 coerente
    final attrs = _gerarCatalogoCompleto(
      macro: macro,
      media10: media10,
    );

    // OVR cheio (10..100) = soma dos 10 atributos da função
    final ovrCheio = _ovrCheio(macro, attrs);

    int precifica(int ovr) => 150000 + max(ovr - 60, 0) * 11000;
    int salario(int ovr) => 12000 + max(ovr - 60, 0) * 900;

    final pilares = _legacyPillarsFromAttrs(attrs);
    final faceOk = FacePool.I.safe(pv.foto);

    return Jogador(
      id: pv.id,
      nome: pv.nome,
      pos: macro,
      idade: pv.idade,
      pe: pv.pe,
      atributos: attrs,
      ofensivo: pilares['of']!,
      defensivo: pilares['df']!,
      tecnico: pilares['te']!,
      mental: pilares['mn']!,
      fisico: pilares['fi']!,
      faceAsset: faceOk,
      salarioMensal: salario(ovrCheio),
      valorMercado: precifica(ovrCheio),
      anosContrato: 3,
    );
  }

  // =========================================================
  // CATÁLOGO COMPLETO (29) — mesmo padrão do resto do projeto
  // =========================================================

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

    // GK
    'def_finalizacoes',
    'def_chute_longe',
    'def_bola_parada',
    'def_penalti',
    'saida_gol',
    'reflexo_reacao',
    'controle_area',
  ];

  // 10 chaves da função (pra OVR cheio)
  List<String> _roleKeys(String macro) {
    switch (macro) {
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
          'forca',
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

  Map<String, int> _gerarCatalogoCompleto({
    required String macro,
    required double media10, // 1..10
  }) {
    int clamp10(int v) => v.clamp(1, 10);

    // rolagem base perto da média do PV
    int rollBase({int spread = 2}) {
      final base = media10.round();
      final noise = _rng.nextInt(spread * 2 + 1) - spread; // -2..+2
      return clamp10(base + noise);
    }

    final m = <String, int>{};

    // 1) base pra todo catálogo
    for (final k in _catalogoKeys) {
      m[k] = rollBase(spread: 2);
    }

    // 2) identidade: 10 da função sobem, resto cai um pouco
    final role = _roleKeys(macro);

    for (final k in _catalogoKeys) {
      if (!role.contains(k)) {
        final dec = _rng.nextInt(3); // 0..2
        m[k] = clamp10(m[k]! - dec);
      }
    }

    for (final k in role) {
      final inc = 1 + _rng.nextInt(2); // +1..+2
      m[k] = clamp10((m[k] ?? rollBase()) + inc);
    }

    // 3) assinatura leve por macro
    _applyMacroSignature(macro, m);

    return m.map((k, v) => MapEntry(k, clamp10(v)));
  }

  void _applyMacroSignature(String macro, Map<String, int> m) {
    int clamp10(int v) => v.clamp(1, 10);
    void bump(String k, int d) => m[k] = clamp10((m[k] ?? 5) + d);

    switch (macro) {
      case 'GOL':
        bump('reflexo_reacao', _rng.nextInt(2)); // 0..1
        bump('def_finalizacoes', _rng.nextInt(2));
        bump('controle_area', _rng.nextInt(2));
        bump('tomada_decisao', _rng.nextInt(2));
        bump('finalizacao', -_rng.nextInt(2));
        bump('drible', -_rng.nextInt(2));
        return;
      case 'DEF':
        bump('marcacao', _rng.nextInt(2));
        bump('desarme', _rng.nextInt(2));
        bump('cobertura_defensiva', _rng.nextInt(2));
        bump('jogo_aereo', _rng.nextInt(2));
        bump('finalizacao', -_rng.nextInt(2));
        return;
      case 'MEI':
        bump('passe_curto', _rng.nextInt(2));
        bump('passe_longo', _rng.nextInt(2));
        bump('tomada_decisao', _rng.nextInt(2));
        bump('capacidade_tatica', _rng.nextInt(2));
        bump('marcacao', _rng.nextInt(2));
        return;
      default: // ATA
        bump('finalizacao', _rng.nextInt(2));
        bump('presenca_ofensiva', _rng.nextInt(2));
        bump('velocidade', _rng.nextInt(2));
        bump('coordenacao_motora', _rng.nextInt(2));
        bump('desarme', -_rng.nextInt(2));
        return;
    }
  }

  int _ovrCheio(String macro, Map<String, int> attrs) {
    final keys = _roleKeys(macro);
    var sum = 0;
    for (final k in keys) {
      sum += (attrs[k] ?? 1).clamp(1, 10);
    }
    return sum;
  }

  // =========================================================
  // Pilares legados 40..95 (compat temporária)
  // =========================================================

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

  String _tradPos(String p) {
    switch (p) {
      case 'GK':
        return 'GOL';
      case 'DF':
        return 'DEF';
      case 'MF':
        return 'MEI';
      case 'FW':
      default:
        return 'ATA';
    }
  }
}
