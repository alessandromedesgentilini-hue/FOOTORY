// lib/pages/clubes/jogador_detalhe_page.dart
//
// Página de detalhes do jogador — Caminho B (atributos 1..10)
// - Mostra atributos reais 1..10 (10 da função)
// - OVR cheio = soma dos 10 (10..100) -> dinâmico
// - Estrelas = média 1..10 arredondada pra .5
// - Compat: se ainda não existir `atributos` no Jogador, deriva dos pilares (legado)
//
// ✅ FUNDAMENTAL: mostra TODOS os atributos do jogador (catálogo completo)
//   - Seção "Atributos da função (10)"
//   - Seção "Todos os atributos (core)" com busca + ordenação
//
// Importante: não depende de pe.label (faz fallback seguro)

import 'package:flutter/material.dart';
import '../../models/jogador.dart';

class JogadorDetalhePage extends StatefulWidget {
  final Jogador jogador;
  const JogadorDetalhePage({super.key, required this.jogador});

  @override
  State<JogadorDetalhePage> createState() => _JogadorDetalhePageState();
}

class _JogadorDetalhePageState extends State<JogadorDetalhePage> {
  final TextEditingController _q = TextEditingController();
  bool _sortByValue = true;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.jogador;

    // 1) tenta pegar atributos 1..10 do model novo
    final rawAttrs = _tryGetAtributos(p);

    // 2) normaliza chaves (aceita labels, snake_case etc.)
    final normalized = _normalizeToCoreKeys(rawAttrs);

    // 3) se não tiver, deriva dos pilares (só pra compat)
    final micros =
        normalized.isNotEmpty ? _clamp10(normalized) : _microsFromPillars(p);

    // 4) escolhe os 10 da função (prioriza posição detalhada; fallback macro)
    final posRaw = _posString(p.pos);
    final keys = _roleKeysFromPos(posRaw);

    final values = keys.map((k) => (micros[k] ?? 1).clamp(1, 10)).toList();

    final soma10 = values.fold<int>(0, (a, b) => a + b); // 10..100
    final media10 = soma10 / 10.0; // 1..10
    final estrelas = _roundToHalf(media10);

    // legado: pilares (para debug/migração)
    int atr(Map<String, int> m, String curto, String longo, {int def = 0}) =>
        m[curto] ?? m[longo] ?? def;

    final fin = atr(p.ofensivo, 'fin', 'finalizacao');
    final marc = atr(p.defensivo, 'marc', 'marcacao');
    final tec = atr(p.tecnico, 'tec', 'tecnica');
    final mnt = atr(p.mental, 'mnt', 'mental');
    final fis = atr(p.fisico, 'fis', 'fisico');

    // catálogo completo (core)
    final allAttrs = _buildCatalogWithValues(micros);
    final q = _q.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? allAttrs
        : allAttrs.where((e) => e.label.toLowerCase().contains(q)).toList();

    final sorted = List<_AttrLine>.of(filtered);
    sorted.sort((a, b) {
      if (_sortByValue) {
        final d = b.value.compareTo(a.value);
        if (d != 0) return d;
        return a.label.compareTo(b.label);
      }
      return a.label.compareTo(b.label);
    });

    return Scaffold(
      appBar: AppBar(title: Text(p.nome)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== topo =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      p.facePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CircleAvatar(
                        radius: 48,
                        child: Text(
                          p.iniciais,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(icon: Icons.sports_soccer, label: posRaw),
                          _chip(icon: Icons.cake, label: 'Idade ${p.idade}'),
                          _chip(
                              icon: Icons.directions_walk,
                              label: 'Pé ${_peLabel(p.pe)}'),
                          _chip(icon: Icons.star, label: 'OVR $soma10'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _StarRow(value10: estrelas),
                      const SizedBox(height: 12),
                      Text(
                        'Valor: ${p.valorFormatado}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text('Salário mensal: ${p.salarioFormatado}'),
                      const SizedBox(height: 4),
                      Text(
                          'Contrato: ${p.anosContrato} ano${p.anosContrato == 1 ? "" : "s"}'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // ===== 10 da função =====
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Atributos da função (1..10)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Base: ${_roleNameForPos(posRaw)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(keys.length, (i) {
              return _attrRow(_attrLabel(keys[i]), values[i]);
            }),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // ===== todos os atributos =====
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Todos os atributos (core)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _q,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar atributo…',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: Text(
                      _sortByValue ? 'Ordenar por Valor' : 'Ordenar por Nome'),
                  selected: _sortByValue,
                  onSelected: (v) => setState(() => _sortByValue = v),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhum atributo encontrado com esse filtro.'),
              )
            else
              ...sorted.map((e) => _attrRow(e.label, e.value)),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // ===== legado (debug) =====
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilares (legado)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            _kv('Finalização (legado)', fin),
            _kv('Marcação (legado)', marc),
            _kv('Técnica (legado)', tec),
            _kv('Mental (legado)', mnt),
            _kv('Físico (legado)', fis),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // Catálogo completo (core) — 29 atributos (snake keys)
  // =========================================================

  static const List<String> _coreKeys = <String>[
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

  List<_AttrLine> _buildCatalogWithValues(Map<String, int> attrs10) {
    return _coreKeys.map((k) {
      final v = (attrs10[k] ?? 1).clamp(1, 10);
      return _AttrLine(key: k, label: _attrLabel(k), value: v);
    }).toList(growable: false);
  }

  // =========================================================
  // Tenta ler `atributos` do Jogador (modelo novo)
  // =========================================================

  Map<String, int> _tryGetAtributos(Jogador p) {
    try {
      final dyn = p as dynamic;
      final v = dyn.atributos;
      if (v is Map<String, int>) return v;
      if (v is Map) {
        return v.map((k, val) => MapEntry(k.toString(), (val as num).toInt()));
      }
    } catch (_) {}
    return const {};
  }

  Map<String, int> _clamp10(Map<String, int> m) {
    final out = <String, int>{};
    for (final e in m.entries) {
      out[e.key] = e.value.clamp(1, 10);
    }
    return out;
  }

  // =========================================================
  // Normaliza chaves do Map para o catálogo core (snake_case)
  // Aceita:
  // - snake_case core
  // - labels "Finalização", "Passe Curto" etc.
  // - variações comuns (ex: dominio e conducao / domínio e condução)
  // - chaves antigas curtas se algum dia tiverem sido usadas
  // =========================================================

  Map<String, int> _normalizeToCoreKeys(Map<String, int> raw) {
    if (raw.isEmpty) return const {};

    // Mapa label->key (e alias)
    final aliases = <String, String>{
      // Ofensivo
      'finalizacao': 'finalizacao',
      'finalização': 'finalizacao',
      'fin': 'finalizacao',
      'chute_de_longe': 'chute_longe',
      'chute_longe': 'chute_longe',
      'chute de longe': 'chute_longe',

      'presenca_ofensiva': 'presenca_ofensiva',
      'presença ofensiva': 'presenca_ofensiva',
      'presenca ofensiva': 'presenca_ofensiva',

      // Técnico
      'drible': 'drible',
      'dominio_conducao': 'dominio_conducao',
      'dominio e conducao': 'dominio_conducao',
      'domínio e condução': 'dominio_conducao',
      'dominio/conducao': 'dominio_conducao',
      'domínio/condução': 'dominio_conducao',
      'dominio': 'dominio_conducao',

      'passe_curto': 'passe_curto',
      'passe curto': 'passe_curto',
      'passe_longo': 'passe_longo',
      'passe longo': 'passe_longo',
      'cruzamento': 'cruzamento',

      // Mental/Tático
      'tomada_decisao': 'tomada_decisao',
      'tomada de decisão': 'tomada_decisao',
      'capacidade_tatica': 'capacidade_tatica',
      'capacidade tática': 'capacidade_tatica',
      'frieza': 'frieza',
      'coordenacao_motora': 'coordenacao_motora',
      'coordenação motora': 'coordenacao_motora',
      'espirito_protagonista': 'espirito_protagonista',
      'espírito protagonista': 'espirito_protagonista',

      // Defensivo
      'marcacao': 'marcacao',
      'marcação': 'marcacao',
      'cobertura_defensiva': 'cobertura_defensiva',
      'cobertura defensiva': 'cobertura_defensiva',
      'antecipacao': 'antecipacao',
      'antecipação': 'antecipacao',
      'jogo_aereo': 'jogo_aereo',
      'jogo aéreo': 'jogo_aereo',
      'desarme': 'desarme',

      // Físico
      'velocidade': 'velocidade',
      'resistencia': 'resistencia',
      'resistência': 'resistencia',
      'potencia': 'potencia',
      'potência': 'potencia',
      'composicao_natural': 'composicao_natural',
      'composição natural': 'composicao_natural',

      // GK
      'defesa em finalizacoes': 'def_finalizacoes',
      'defesa em finalizações': 'def_finalizacoes',
      'def_finalizacoes': 'def_finalizacoes',
      'def. finalizacoes': 'def_finalizacoes',
      'def. finalizações': 'def_finalizacoes',

      'defesa em chutes de longe': 'def_chute_longe',
      'defesa em chute de longe': 'def_chute_longe',
      'def_chute_longe': 'def_chute_longe',

      'defesa de bola parada': 'def_bola_parada',
      'def_bola_parada': 'def_bola_parada',

      'defesa de penalti': 'def_penalti',
      'defesa de pênalti': 'def_penalti',
      'def_penalti': 'def_penalti',

      'saida do gol': 'saida_gol',
      'saída do gol': 'saida_gol',
      'saida_gol': 'saida_gol',

      'reflexo e reacao': 'reflexo_reacao',
      'reflexo e reação': 'reflexo_reacao',
      'reflexo_reacao': 'reflexo_reacao',

      'controle da area': 'controle_area',
      'controle da área': 'controle_area',
      'controle_area': 'controle_area',
    };

    String norm(String s) {
      // baixa, remove espaços duplicados, troca separadores e remove acentos básicos
      var x = s.trim().toLowerCase();
      x = x.replaceAll('-', ' ').replaceAll('_', ' ').replaceAll('/', ' ');
      x = x.replaceAll(RegExp(r'\s+'), ' ');
      // remove acentos simples
      x = x
          .replaceAll('á', 'a')
          .replaceAll('à', 'a')
          .replaceAll('ã', 'a')
          .replaceAll('â', 'a')
          .replaceAll('é', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ç', 'c');
      return x;
    }

    // Preenche resultado com o que vier no raw, normalizando.
    final out = <String, int>{};

    for (final e in raw.entries) {
      final keyRaw = e.key;
      final v = e.value;

      // 1) se já for uma coreKey, usa direto
      if (_coreKeys.contains(keyRaw)) {
        out[keyRaw] = v;
        continue;
      }

      // 2) tenta alias por normalização
      final k1 = norm(keyRaw);

      // tenta encontrar alias direto com k1
      final mapped = aliases[k1] ?? aliases[keyRaw.toLowerCase()];

      if (mapped != null && _coreKeys.contains(mapped)) {
        out[mapped] = v;
        continue;
      }

      // 3) tenta reconstruir snake_case básico a partir do texto
      final snake = k1.replaceAll(' ', '_');
      if (aliases.containsKey(k1)) {
        final m = aliases[k1]!;
        out[m] = v;
        continue;
      }
      if (aliases.containsKey(snake)) {
        final m = aliases[snake]!;
        out[m] = v;
        continue;
      }
      if (_coreKeys.contains(snake)) {
        out[snake] = v;
        continue;
      }
    }

    // garante que, se vierem duplicadas (ex label + snake), o maior valor fique
    final merged = <String, int>{};
    for (final k in out.keys) {
      final cur = merged[k];
      final nv = out[k]!;
      if (cur == null || nv > cur) merged[k] = nv;
    }

    return merged;
  }

  // =========================================================
  // Compat: Deriva micros 1..10 a partir dos pilares (40..95)
  // =========================================================

  Map<String, int> _microsFromPillars(Jogador p) {
    int g(Map<String, int> m, String s1, String s2, int d) =>
        m[s1] ?? m[s2] ?? d;

    final of = g(p.ofensivo, 'fin', 'finalizacao', 60);
    final df = g(p.defensivo, 'marc', 'marcacao', 60);
    final te = g(p.tecnico, 'tec', 'tecnica', 60);
    final mn = g(p.mental, 'mnt', 'mental', 60);
    final fi = g(p.fisico, 'fis', 'fisico', 60);

    int map40a95to1a10(int v) {
      final cl = v.clamp(40, 95);
      final n = 1.0 + ((cl - 40.0) / 55.0) * 9.0;
      return n.round().clamp(1, 10);
    }

    final of10 = map40a95to1a10(of);
    final df10 = map40a95to1a10(df);
    final te10 = map40a95to1a10(te);
    final mn10 = map40a95to1a10(mn);
    final fi10 = map40a95to1a10(fi);

    int mix2(int a, int b) => ((a + b) / 2.0).round().clamp(1, 10);
    int mix3(int a, int b, int c) => ((a + b + c) / 3.0).round().clamp(1, 10);

    return <String, int>{
      // ATA / TEC / MEN / FIS
      'finalizacao': of10,
      'chute_longe': mix2(of10, fi10),
      'presenca_ofensiva': mix2(of10, fi10),
      'drible': mix2(of10, te10),
      'dominio_conducao': te10,
      'passe_curto': mix2(te10, mn10),
      'passe_longo': mix2(te10, mn10),
      'cruzamento': te10,
      'tomada_decisao': mn10,
      'capacidade_tatica': mn10,
      'frieza': mn10,
      'coordenacao_motora': mix2(te10, fi10),
      'espirito_protagonista': mix2(mn10, of10),

      // DEF
      'marcacao': df10,
      'cobertura_defensiva': mix2(df10, mn10),
      'jogo_aereo': mix2(df10, fi10),
      'antecipacao': mix2(df10, mn10),
      'desarme': df10,

      // FIS
      'velocidade': fi10,
      'resistencia': fi10,
      'potencia': fi10,
      'composicao_natural': mix2(mn10, fi10),

      // GK
      'def_finalizacoes': mix3(df10, mn10, fi10),
      'def_chute_longe': mix2(df10, mn10),
      'def_bola_parada': mix2(df10, te10),
      'def_penalti': mix2(mn10, fi10),
      'saida_gol': mix2(mn10, fi10),
      'reflexo_reacao': fi10,
      'controle_area': mix2(df10, mn10),
    };
  }

  // =========================================================
  // 10 atributos por POSIÇÃO (prioritário) + fallback macro
  // =========================================================

  List<String> _roleKeysFromPos(String pos) {
    final p = pos.toUpperCase().trim();

    // 1) posição detalhada (mais correto)
    // chaves esperadas: GOL, ZAG, LAT, LE, LD, VOL, MC, MA, ME, MD, PE, PD, CA
    switch (p) {
      case 'GOL':
      case 'GK':
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

      case 'LAT':
      case 'LE':
      case 'LD':
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

      case 'MA':
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

      case 'PE':
      case 'PD':
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

      case 'ME':
      case 'MD':
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

    // 2) macro (se vier DEF/MEI/ATA)
    if (p == 'DEF') {
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
    }
    if (p == 'MEI') {
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
    }
    if (p == 'ATA') {
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

    // 3) inferência por substring (robusto)
    final inferred = _inferPos(pos);
    if (inferred != p) return _roleKeysFromPos(inferred);

    // 4) fallback: meio-campo genérico
    return const [
      'passe_curto',
      'passe_longo',
      'dominio_conducao',
      'drible',
      'tomada_decisao',
      'capacidade_tatica',
      'resistencia',
      'frieza',
      'velocidade',
      'potencia',
    ];
  }

  String _roleNameForPos(String pos) {
    final p = _inferPos(pos);
    switch (p) {
      case 'GOL':
        return 'Goleiro';
      case 'ZAG':
        return 'Zagueiro';
      case 'LAT':
      case 'LE':
      case 'LD':
        return 'Lateral';
      case 'VOL':
        return 'Volante';
      case 'MC':
        return 'Meio-Centro';
      case 'MA':
        return 'Meia-Atacante';
      case 'ME':
      case 'MD':
        return 'Meia (ME/MD)';
      case 'PE':
      case 'PD':
        return 'Ponta';
      case 'CA':
        return 'Centroavante';
      default:
        return 'Genérico';
    }
  }

  String _inferPos(String pos) {
    final p = pos.toUpperCase().trim();
    if (p == 'GOL' || p == 'GK') return 'GOL';
    if (p == 'ZAG' || p == 'CB') return 'ZAG';
    if (p == 'LAT' || p == 'LE' || p == 'LD' || p == 'LB' || p == 'RB')
      return 'LAT';
    if (p == 'VOL' || p == 'CDM') return 'VOL';
    if (p == 'MC' || p == 'CM') return 'MC';
    if (p == 'MA' || p == 'CAM') return 'MA';
    if (p == 'ME' || p == 'MD' || p == 'LM' || p == 'RM') return 'ME';
    if (p == 'PE' || p == 'PD' || p == 'LW' || p == 'RW') return 'PE';
    if (p == 'CA' || p == 'ST' || p == 'CF') return 'CA';

    // macro fallback
    if (p == 'DEF' || p == 'MEI' || p == 'ATA') return p;

    // tenta por substring
    if (p.contains('GOL')) return 'GOL';
    if (p.contains('ZAG')) return 'ZAG';
    if (p.contains('LAT')) return 'LAT';
    if (p.contains('VOL')) return 'VOL';
    if (p.contains('MC')) return 'MC';
    if (p.contains('MA')) return 'MA';
    if (p.contains('ME') || p.contains('MD')) return 'ME';
    if (p.contains('PE') || p.contains('PD')) return 'PE';
    if (p.contains('CA')) return 'CA';

    return p;
  }

  String _posString(dynamic pos) {
    if (pos == null) return '-';
    try {
      // se for enum
      final name = (pos as dynamic).name;
      if (name != null) return name.toString().toUpperCase();
    } catch (_) {}
    final s = pos.toString();
    if (s.contains('.')) return s.split('.').last.toUpperCase();
    return s.toUpperCase();
  }

  // =========================================================
  // Labels
  // =========================================================

  String _attrLabel(String k) {
    switch (k) {
      case 'finalizacao':
        return 'Finalização';
      case 'chute_longe':
        return 'Chute de longe';
      case 'presenca_ofensiva':
        return 'Presença ofensiva';
      case 'drible':
        return 'Drible';
      case 'dominio_conducao':
        return 'Domínio/Condução';
      case 'passe_curto':
        return 'Passe curto';
      case 'passe_longo':
        return 'Passe longo';
      case 'cruzamento':
        return 'Cruzamento';
      case 'tomada_decisao':
        return 'Tomada de decisão';
      case 'capacidade_tatica':
        return 'Capacidade tática';
      case 'frieza':
        return 'Frieza';
      case 'espirito_protagonista':
        return 'Espírito protagonista';
      case 'velocidade':
        return 'Velocidade';
      case 'resistencia':
        return 'Resistência';
      case 'potencia':
        return 'Potência';
      case 'composicao_natural':
        return 'Composição natural';
      case 'coordenacao_motora':
        return 'Coordenação motora';
      case 'marcacao':
        return 'Marcação';
      case 'cobertura_defensiva':
        return 'Cobertura defensiva';
      case 'jogo_aereo':
        return 'Jogo aéreo';
      case 'antecipacao':
        return 'Antecipação';
      case 'desarme':
        return 'Desarme';
      case 'def_finalizacoes':
        return 'Def. finalizações';
      case 'def_chute_longe':
        return 'Def. chute de longe';
      case 'def_bola_parada':
        return 'Def. bola parada';
      case 'def_penalti':
        return 'Def. pênalti';
      case 'saida_gol':
        return 'Saída do gol';
      case 'reflexo_reacao':
        return 'Reflexo/Reação';
      case 'controle_area':
        return 'Controle da área';
      default:
        return k;
    }
  }

  // =========================================================
  // UI helpers
  // =========================================================

  Widget _chip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _kv(String k, int v) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(k),
      trailing: Text(
        '$v',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _attrRow(String label, int v) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniBar(value: v),
          const SizedBox(width: 10),
          Text('$v', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  String _peLabel(dynamic pe) {
    if (pe == null) return '-';
    try {
      final name = (pe as dynamic).name;
      if (name != null) return name.toString().toUpperCase();
    } catch (_) {}
    final s = pe.toString();
    if (s.contains('.')) return s.split('.').last.toUpperCase();
    return s.toUpperCase();
  }

  double _roundToHalf(double v) => (v * 2).round() / 2.0;
}

class _AttrLine {
  final String key;
  final String label;
  final int value;
  const _AttrLine(
      {required this.key, required this.label, required this.value});
}

class _MiniBar extends StatelessWidget {
  final int value; // 1..10
  const _MiniBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clamped = value.clamp(1, 10);
    return SizedBox(
      width: 90,
      height: 8,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.7),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: clamped / 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double value10; // 1..10 em .5
  const _StarRow({required this.value10});

  @override
  Widget build(BuildContext context) {
    final v = value10.clamp(0.0, 10.0);
    final stars5 = v / 2.0;

    final full = stars5.floor();
    final half = (stars5 - full) >= 0.5 ? 1 : 0;
    final empty = 5 - full - half;

    return Row(
      children: [
        ...List.generate(full, (_) => const Icon(Icons.star, size: 18)),
        if (half == 1) const Icon(Icons.star_half, size: 18),
        ...List.generate(empty, (_) => const Icon(Icons.star_border, size: 18)),
        const SizedBox(width: 8),
        Text(value10.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
