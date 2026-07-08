// lib/models/jogador.dart
//
// Jogador (Fase 1 — modelo NOVO com atributos 1..10 + compat)
//
// ✅ POSIÇÕES (refactor):
// - posDet (canônico): GOL, LD, ZAG, LE, VOL, MC, MEI, MD, ME, PD, PE, CA
// - pos (macro): GOL, DEF, MEI, ATA
//
// ✅ OVR canônico:
// - soma dos 10 atributos da função (10..100) baseado em posDet
//
// ✅ Atributos:
// - Map<String,int> 1..10
// - Sempre contém as 29 chaves do catálogo core (faltantes viram 1)
//
// ✅ Pé preferencial:
// - usa PePreferencialX.fromJson (tolerante a slug/nome/aliases)
//
// Legado/pilares permanecem por compat.

import 'package:intl/intl.dart';

import '../services/assets/face_pool.dart';
import 'pe_preferencial.dart';

class Jogador {
  // =========================================================
  // Catálogo core (29 atributos) — snake_case (CANÔNICO)
  // =========================================================

  static const List<String> coreKeys = <String>[
    // Defensivo
    'cobertura_defensiva',
    'antecipacao',
    'marcacao',
    'jogo_aereo',
    'desarme',

    // Técnico
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

    // Ofensivo
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

  static Map<String, int> coreDefault({int value = 1}) {
    final v = value.clamp(1, 10);
    return {for (final k in coreKeys) k: v};
  }

  // =========================================================
  // POSIÇÕES DETALHADAS (canônicas)
  // =========================================================

  static const List<String> posDetValidas = <String>[
    'GOL',
    'LD',
    'ZAG',
    'LE',
    'VOL',
    'MC',
    'MEI',
    'MD',
    'ME',
    'PD',
    'PE',
    'CA',
  ];

  /// posDet -> macro
  static String macroFromPosDet(String posDet) {
    final p = posDet.toUpperCase().trim();
    if (p == 'GOL') return 'GOL';
    if (p == 'LD' || p == 'LE' || p == 'ZAG') return 'DEF';
    if (p == 'VOL' || p == 'MC' || p == 'MEI' || p == 'MD' || p == 'ME') {
      return 'MEI';
    }
    if (p == 'PD' || p == 'PE' || p == 'CA') return 'ATA';
    return 'MEI';
  }

  /// 10 atributos por posDet
  static const Map<String, List<String>> roleKeysByPosDet = {
    'GOL': [
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
    ],
    'LD': [
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
    ],
    'LE': [
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
    ],
    'ZAG': [
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
    ],
    'VOL': [
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
    ],
    'MC': [
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
    ],
    'MEI': [
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
    ],
    'MD': [
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
    ],
    'ME': [
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
    ],
    'PD': [
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
    ],
    'PE': [
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
    ],
    'CA': [
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
    ],
  };

  // =========================================================
  // Campos
  // =========================================================

  final String id;
  final String nome;

  /// Macro: GOL/DEF/MEI/ATA
  final String pos;

  /// Detalhada: GOL/LD/ZAG/LE/VOL/MC/MEI/MD/ME/PD/PE/CA
  final String posDet;

  final int idade;
  final PePreferencial pe;

  /// Catálogo completo 29 (1..10)
  final Map<String, int> atributos;

  /// Legado/compat
  final Map<String, int> ofensivo;
  final Map<String, int> defensivo;
  final Map<String, int> tecnico;
  final Map<String, int> mental;
  final Map<String, int> fisico;

  final String? faceAsset;

  final int salarioMensal;
  final int valorMercado;
  final int anosContrato;

  Jogador({
    required this.id,
    required this.nome,
    String? pos,
    String? posDet,
    required this.idade,
    required this.pe,
    required Map<String, int> atributos,
    Map<String, int>? ofensivo,
    Map<String, int>? defensivo,
    Map<String, int>? tecnico,
    Map<String, int>? mental,
    Map<String, int>? fisico,
    required this.faceAsset,
    required this.salarioMensal,
    required this.valorMercado,
    required this.anosContrato,
  })  : posDet = _normalizePosDet(
          posDet ?? _defaultPosDetFromMacro(pos ?? 'MEI'),
        ),
        pos = _normalizeMacro(
          pos ??
              macroFromPosDet(posDet ?? _defaultPosDetFromMacro(pos ?? 'MEI')),
        ),
        atributos = Map.unmodifiable(_mergeAndClampCore(atributos)),
        ofensivo = Map.unmodifiable(ofensivo ?? const {}),
        defensivo = Map.unmodifiable(defensivo ?? const {}),
        tecnico = Map.unmodifiable(tecnico ?? const {}),
        mental = Map.unmodifiable(mental ?? const {}),
        fisico = Map.unmodifiable(fisico ?? const {});

  // =========================================================
  // Helpers UI
  // =========================================================

  String get iniciais {
    final parts = nome.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    final s = (a + b).toUpperCase();
    return s.isEmpty ? '?' : s;
  }

  String get facePath => FacePool.I.safe(faceAsset);

  String get valorFormatado =>
      NumberFormat.simpleCurrency(locale: 'pt_BR').format(valorMercado);

  String get salarioFormatado =>
      NumberFormat.simpleCurrency(locale: 'pt_BR').format(salarioMensal);

  // =========================================================
  // OVR (Caminho B)
  // =========================================================

  List<String> get chavesFuncao =>
      roleKeysByPosDet[posDet] ?? roleKeysByPosDet['MC']!;

  int get ovrCheio {
    var sum = 0;
    for (final k in chavesFuncao) {
      sum += (atributos[k] ?? 1).clamp(1, 10);
    }
    return sum.clamp(10, 100);
  }

  double get estrelas {
    final v = ovrCheio / 10.0;
    final r = (v * 2).round() / 2.0;
    return double.parse(r.toStringAsFixed(1));
  }

  // =========================================================
  // JSON
  // =========================================================

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'pos': pos,
        'posDet': posDet,
        'idade': idade,
        'pe': pe.toJson(),
        'atributos': atributos,
        'ofensivo': ofensivo,
        'defensivo': defensivo,
        'tecnico': tecnico,
        'mental': mental,
        'fisico': fisico,
        'faceAsset': faceAsset,
        'salarioMensal': salarioMensal,
        'valorMercado': valorMercado,
        'anosContrato': anosContrato,
      };

  factory Jogador.fromJson(Map<String, dynamic> j) {
    Map<String, int> mapSI(Object? v) {
      if (v is Map) {
        return v.map((k, val) => MapEntry(k.toString(), (val as num).toInt()));
      }
      return <String, int>{};
    }

    final posMacro = (j['pos'] ?? 'MEI').toString();
    final posDet = (j['posDet'] as String?)?.toString();

    final attrsRaw = mapSI(j['atributos']);
    final attrs = attrsRaw.isNotEmpty ? attrsRaw : coreDefault(value: 1);

    return Jogador(
      id: (j['id'] ?? '').toString(),
      nome: (j['nome'] ?? '').toString(),
      pos: posMacro,
      posDet: posDet,
      idade: (j['idade'] as num?)?.toInt() ?? 20,
      pe: PePreferencialX.fromJson(j['pe']),
      atributos: attrs,
      ofensivo: mapSI(j['ofensivo']),
      defensivo: mapSI(j['defensivo']),
      tecnico: mapSI(j['tecnico']),
      mental: mapSI(j['mental']),
      fisico: mapSI(j['fisico']),
      faceAsset: (j['faceAsset'] as String?)?.trim(),
      salarioMensal: (j['salarioMensal'] as num?)?.toInt() ?? 0,
      valorMercado: (j['valorMercado'] as num?)?.toInt() ?? 0,
      anosContrato: (j['anosContrato'] as num?)?.toInt() ?? 1,
    );
  }

  // =========================================================
  // Internos
  // =========================================================

  static String _normalizeMacro(String s) {
    final t = s.trim().toUpperCase();
    switch (t) {
      case 'GOL':
      case 'DEF':
      case 'MEI':
      case 'ATA':
        return t;
      default:
        return 'MEI';
    }
  }

  static String _normalizePosDet(String s) {
    final t = s.trim().toUpperCase();
    if (posDetValidas.contains(t)) return t;
    return 'MC';
  }

  static String _defaultPosDetFromMacro(String macro) {
    final m = macro.trim().toUpperCase();
    switch (m) {
      case 'GOL':
        return 'GOL';
      case 'DEF':
        return 'ZAG';
      case 'MEI':
        return 'MC';
      case 'ATA':
        return 'CA';
      default:
        return 'MC';
    }
  }

  static Map<String, int> _mergeAndClampCore(Map<String, int> incoming) {
    final base = coreDefault(value: 1);
    for (final e in incoming.entries) {
      final k = e.key.toString();
      if (!coreKeys.contains(k)) continue;
      base[k] = e.value.clamp(1, 10);
    }
    return base;
  }
}
