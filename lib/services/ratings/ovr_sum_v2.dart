// lib/services/ratings/ovr_sum_v2.dart
//
// OVR por função (v2) = soma simples dos 10 atributos (cada um 1..10 ⇒ 10..100).
//
// ▶ Núcleo:
//   - Catálogo de atributos (25 de linha + 7 de goleiro)
//   - Map de 10 atributos por função (ex.: ZAGUEIRO, LATERAL, CA, GOL…)
//   - Projeção dos 5 pilares (40..95) → micros (1..10)
//   - Cálculo de OVR por função: ovrFromMicros(func, micros)
//
// ▶ Compat (mantém API antiga usada nas telas):
//   - microsFromPillars(of, de, te, me, fi)  -> Map<String,int> (1..10)
//   - funcaoFromPos('GOL'|'DEF'|'MEI'|'ATA') -> função canônica (ex.: GOL, ZAGUEIRO, MEIA, CA)
//   - sumForRole(func, micros)               -> ovrFromMicros(func, micros)
//
// As telas podem continuar importando `service_rating_overall_sum_v2.dart`
// (veja mais abaixo um arquivo-curinga de reexport).

import '../../models/jogador.dart';

class Funcao {
  static const lateral = 'LATERAL';
  static const zagueiro = 'ZAGUEIRO';
  static const volante = 'VOLANTE'; // 1º volante
  static const mc = 'MC'; // 2º volante
  static const meia = 'MEIA'; // meia atacante
  static const ponta = 'PONTA';
  static const meMd = 'ME_MD'; // meia-esq / meia-dir
  static const ca = 'CA'; // centroavante
  static const gol = 'GOL'; // goleiro

  /// Mapeia macro posição curta do seu modelo → função padrão deste catálogo.
  /// Aceita: 'GOL' | 'DEF' | 'MEI' | 'ATA' (qualquer outra cai em 'CA').
  static String padraoParaPos(String posCurta) {
    switch (posCurta.toUpperCase()) {
      case 'GOL':
        return gol;
      case 'DEF':
        return zagueiro;
      case 'MEI':
        return meia;
      case 'ATA':
      default:
        return ca;
    }
  }
}

/// nomes canônicos (snake_case)
class Attr {
  // — Ofensivo (5) —
  static const finalizacao = 'finalizacao';
  static const presencaOfensiva = 'presenca_ofensiva';
  static const chuteDeLonge = 'chute_de_longe';
  static const cruzamento = 'cruzamento';
  static const penalti = 'penalti';

  // — Técnico (5) —
  static const passeCurto = 'passe_curto';
  static const passeLongo = 'passe_longo';
  static const drible = 'drible';
  static const dominioConducao = 'dominio_conducao';
  static const bolaParada = 'bola_parada';

  // — Defensivo (5) —
  static const marcacao = 'marcacao';
  static const coberturaDef = 'cobertura_defensiva';
  static const desarme = 'desarme';
  static const jogoAereo = 'jogo_aereo';
  static const antecipacao = 'antecipacao';

  // — Mental (5) —
  static const tomadaDecisao = 'tomada_decisao';
  static const frieza = 'frieza';
  static const capacidadeTatica = 'capacidade_tatica';
  static const espiritoProta = 'espirito_protagonista';
  static const visao = 'visao';

  // — Físico (5) —
  static const velocidade = 'velocidade';
  static const resistencia = 'resistencia';
  static const potencia = 'potencia';
  static const coordenacao = 'coordenacao_motora';
  static const composicaoNatural = 'composicao_natural';

  // — Goleiro (7) —
  static const defFinalizacoes = 'gk_defesa_finalizacoes';
  static const defChuteLonge = 'gk_defesa_chutes_longe';
  static const defBolaParada = 'gk_defesa_bola_parada';
  static const defPenalti = 'gk_defesa_penalti';
  static const saidaDoGol = 'gk_saida_do_gol';
  static const reflexoReacao = 'gk_reflexo_reacao';
  static const controleArea = 'gk_controle_area';
}

/// 5×5 — distribuição fechada (25 de linha)
const Map<String, List<String>> atrPorPilar = {
  'OF': [
    Attr.finalizacao,
    Attr.presencaOfensiva,
    Attr.chuteDeLonge,
    Attr.cruzamento,
    Attr.penalti,
  ],
  'TE': [
    Attr.passeCurto,
    Attr.passeLongo,
    Attr.drible,
    Attr.dominioConducao,
    Attr.bolaParada,
  ],
  'DE': [
    Attr.marcacao,
    Attr.coberturaDef,
    Attr.desarme,
    Attr.jogoAereo,
    Attr.antecipacao,
  ],
  'ME': [
    Attr.tomadaDecisao,
    Attr.frieza,
    Attr.capacidadeTatica,
    Attr.espiritoProta,
    Attr.visao,
  ],
  'FI': [
    Attr.velocidade,
    Attr.resistencia,
    Attr.potencia,
    Attr.coordenacao,
    Attr.composicaoNatural,
  ],
};

const Set<String> gkOnly = {
  Attr.defFinalizacoes,
  Attr.defChuteLonge,
  Attr.defBolaParada,
  Attr.defPenalti,
  Attr.saidaDoGol,
  Attr.reflexoReacao,
  Attr.controleArea,
};

/// 10 por função — só nomes da lista oficial acima (25 de linha + 7 GK)
const Map<String, List<String>> funcAttrs = {
  Funcao.lateral: [
    Attr.coberturaDef,
    Attr.antecipacao,
    Attr.passeCurto,
    Attr.cruzamento,
    Attr.tomadaDecisao,
    Attr.capacidadeTatica,
    Attr.velocidade,
    Attr.resistencia,
    Attr.potencia,
    Attr.composicaoNatural,
  ],
  Funcao.zagueiro: [
    Attr.marcacao,
    Attr.coberturaDef,
    Attr.jogoAereo,
    Attr.antecipacao,
    Attr.desarme,
    Attr.tomadaDecisao,
    Attr.frieza,
    Attr.capacidadeTatica,
    Attr.potencia,
    Attr.coordenacao,
  ],
  Funcao.volante: [
    Attr.marcacao,
    Attr.coberturaDef,
    Attr.jogoAereo,
    Attr.antecipacao,
    Attr.desarme,
    Attr.passeCurto,
    Attr.passeLongo,
    Attr.tomadaDecisao,
    Attr.capacidadeTatica,
    Attr.resistencia,
  ],
  Funcao.mc: [
    Attr.drible,
    Attr.chuteDeLonge,
    Attr.marcacao,
    Attr.antecipacao,
    Attr.passeCurto,
    Attr.passeLongo,
    Attr.dominioConducao,
    Attr.tomadaDecisao,
    Attr.resistencia,
    Attr.frieza,
  ],
  Funcao.meia: [
    Attr.finalizacao,
    Attr.drible,
    Attr.passeCurto,
    Attr.passeLongo,
    Attr.dominioConducao,
    Attr.tomadaDecisao,
    Attr.frieza,
    Attr.velocidade,
    Attr.resistencia,
    Attr.coordenacao,
  ],
  Funcao.ponta: [
    Attr.finalizacao,
    Attr.drible,
    Attr.passeCurto,
    Attr.dominioConducao,
    Attr.cruzamento,
    Attr.tomadaDecisao,
    Attr.espiritoProta,
    Attr.velocidade,
    Attr.coordenacao,
    Attr.frieza,
  ],
  Funcao.meMd: [
    Attr.drible,
    Attr.passeCurto,
    Attr.passeLongo,
    Attr.dominioConducao,
    Attr.tomadaDecisao,
    Attr.capacidadeTatica,
    Attr.coberturaDef,
    Attr.resistencia,
    Attr.velocidade,
    Attr.potencia,
  ],
  Funcao.ca: [
    Attr.finalizacao,
    Attr.presencaOfensiva,
    Attr.drible,
    Attr.jogoAereo,
    Attr.passeCurto,
    Attr.dominioConducao,
    Attr.tomadaDecisao,
    Attr.frieza,
    Attr.potencia,
    Attr.coordenacao,
  ],
  Funcao.gol: [
    Attr.defFinalizacoes,
    Attr.defChuteLonge,
    Attr.defBolaParada,
    Attr.defPenalti,
    Attr.saidaDoGol,
    Attr.reflexoReacao,
    Attr.controleArea,
    Attr.tomadaDecisao, // mental comum
    Attr.frieza, // mental comum
    Attr.composicaoNatural, // físico comum
  ],
};

/// look-up rápido: a qual pilar pertence cada atributo de linha
final Map<String, String> _pilarDe = () {
  final map = <String, String>{};
  atrPorPilar.forEach((pilar, lista) {
    for (final a in lista) {
      map[a] = pilar;
    }
  });
  return map;
}();

/// Soma simples dos 10 atributos da função (1..10) ⇒ 10..100.
int ovrFromMicros(String funcao, Map<String, int> micros) {
  final keys = funcAttrs[funcao] ?? funcAttrs[Funcao.ca]!;
  var sum = 0;
  for (final k in keys) {
    final v = micros[k] ?? 1;
    final vi = v < 1 ? 1 : (v > 10 ? 10 : v); // evita num vs int do clamp
    sum += vi;
  }
  return sum < 10 ? 10 : (sum > 100 ? 100 : sum);
}

/// OVR “default” para um Jogador (usa função padrão por macro).
int ovrPadraoParaJogador(Jogador j) {
  final f = Funcao.padraoParaPos(j.pos);
  final micros = microsFromJogador(j);
  return ovrFromMicros(f, micros);
}

/// Projeta os micros a partir dos 5 pilares (40..95 -> 1..10) usando o modelo Jogador.
Map<String, int> microsFromJogador(Jogador j) {
  return microsFromPillars(
      j.ofensivo, j.defensivo, j.tecnico, j.mental, j.fisico,
      isGK: j.pos.toUpperCase() == 'GOL');
}

/// ========= Compat layer (mantém API antiga das telas) =========

/// Projeta micros (1..10) a partir dos 5 mapas de pilares do seu modelo.
/// - Se [isGK] = true, zera (1) atributos de linha menos mentais/comp. natural.
/// - Se false (linha), GK-only = 1.
Map<String, int> microsFromPillars(
  Map<String, int> ofensivo,
  Map<String, int> defensivo,
  Map<String, int> tecnico,
  Map<String, int> mental,
  Map<String, int> fisico, {
  bool isGK = false,
}) {
  final of = _pillar10(_avg(ofensivo.values));
  final de = _pillar10(_avg(defensivo.values));
  final te = _pillar10(_avg(tecnico.values));
  final me = _pillar10(_avg(mental.values));
  final fi = _pillar10(_avg(fisico.values));

  int valPara(String attr) {
    final pilar = _pilarDe[attr];
    if (pilar == 'OF') return of;
    if (pilar == 'DE') return de;
    if (pilar == 'TE') return te;
    if (pilar == 'ME') return me;
    if (pilar == 'FI') return fi;

    // GK-only -> mistura defensivo/mental/físico
    switch (attr) {
      case Attr.defFinalizacoes:
      case Attr.defChuteLonge:
      case Attr.defBolaParada:
      case Attr.defPenalti:
        return ((de + me) / 2).round();
      case Attr.saidaDoGol:
        return ((de + fi) / 2).round();
      case Attr.reflexoReacao:
        return ((me + de) / 2).round();
      case Attr.controleArea:
        return ((me + de) / 2).round();
    }
    return 5;
  }

  final out = <String, int>{};

  // 25 de linha
  for (final lista in atrPorPilar.values) {
    for (final a in lista) {
      final v = valPara(a);
      out[a] = v < 1 ? 1 : (v > 10 ? 10 : v);
    }
  }

  // 7 de GK
  for (final a in gkOnly) {
    final v = valPara(a);
    out[a] = v < 1 ? 1 : (v > 10 ? 10 : v);
  }

  if (isGK) {
    // goleiro: zera (1) os atributos de linha — mantém mentais comuns e comp. natural
    out.updateAll((k, v) {
      final isLinha = !gkOnly.contains(k);
      final keepCommon = k == Attr.tomadaDecisao ||
          k == Attr.frieza ||
          k == Attr.composicaoNatural;
      return (isLinha && !keepCommon) ? 1 : v;
    });
  } else {
    // linha: GK-only => 1
    for (final k in gkOnly) {
      out[k] = 1;
    }
  }

  return out;
}

/// Mantém a assinatura antiga usada nas telas.
String funcaoFromPos(String pos) => Funcao.padraoParaPos(pos);

/// Mantém a assinatura antiga usada nas telas.
int sumForRole(String funcao, Map<String, int> micros) =>
    ovrFromMicros(funcao, micros);

/// ========= helpers internos =========

int _avg(Iterable<int> vals) {
  if (vals.isEmpty) return 50;
  final d = vals.fold<int>(0, (a, b) => a + b) / vals.length;
  return d.round();
}

/// Normaliza um pilar 40..95 → 1..10 (int, clamp seguro).
int _pillar10(int p) {
  const min = 40, max = 95;
  var v = p;
  if (v < min) v = min;
  if (v > max) v = max;
  final n = (v - min) / (max - min);
  final out = (1 + n * 9).round();
  return out.clamp(1, 10);
}
