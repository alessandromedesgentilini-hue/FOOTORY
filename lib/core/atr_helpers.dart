// lib/core/atr_helpers.dart
import 'atr_keys.dart';

/// ===============================================================
/// Normalização robusta de chaves de atributos + utilitários
/// ===============================================================
/// - Remove acentos/pontuação/extras e deixa tudo minúsculo
/// - Converte labels antigos/sinônimos para as chaves canônicas (Atr.*)
/// - Aceita também a própria chave canônica escrita com/sem acentos/espacos
/// - Valores retornam clampados em 0..10 (escala base)
///
/// Uso típico:
///   final norm = normalizarAtributos(origem);
///   final completos = completarAtributos(AtrGrupo.todos, norm);

/// Aliases/sinônimos (após normalização) -> chave canônica (Atr.*).
/// Adicione/ajuste conforme surgirem novos rótulos na UI/dados.
final Map<String, String> _aliasCanonico = {
  // Físicos
  _c('potência'): Atr.potencia,
  _c('potencia'): Atr.potencia,
  _c('resistência'): Atr.resistencia,
  _c('resistencia'): Atr.resistencia,
  _c('aptidão física'): Atr.aptidaoFisica,
  _c('aptidao fisica'): Atr.aptidaoFisica,
  _c('coordenação motora'): Atr.coordenacaoMotora,
  _c('coordenacao motora'): Atr.coordenacaoMotora,

  // Mentais
  _c('tomada de decisão'): Atr.tomadaDecisao,
  _c('tomada de decisao'): Atr.tomadaDecisao,
  _c('espírito protagonista'): Atr.espiritoProtagonista,
  _c('espirito protagonista'): Atr.espiritoProtagonista,
  _c('leitura tática'): Atr.leituraTatica,
  _c('leitura tatica'): Atr.leituraTatica,

  // Técnico/Ofensivo/Defensivo (labels antigos de UI)
  _c('chute de longe'): Atr.chuteDeLonge,
  _c('pênalti'): Atr.penalti,
  _c('penalti'): Atr.penalti,
  _c('posição ofensiva'): Atr.posicionamentoOfensivo,
  _c('posicao ofensiva'): Atr.posicionamentoOfensivo,
  _c('jogo aéreo'): Atr.jogoAereo,
  _c('jogo aereo'): Atr.jogoAereo,
  _c('passe curto'): Atr.passeCurto,
  _c('passe longo'): Atr.passeLongo,
  _c('domínio e condução'): Atr.dominioConducao,
  _c('dominio e conducao'): Atr.dominioConducao,
  _c('cruzamento'): Atr.cruzamento,
  _c('visão'): Atr.visao,
  _c('visao'): Atr.visao,

  // Extras comuns / sinônimos frequentes
  _c('aceleração'): Atr.aceleracao,
  _c('aceleracao'): Atr.aceleracao,
  _c('arranque'): Atr.aceleracao,

  _c('pressão pós-perda'): Atr.pressaoPosPerda,
  _c('pressao pos-perda'): Atr.pressaoPosPerda,
  _c('pressao pos perda'): Atr.pressaoPosPerda,

  _c('compactação'): Atr.compactacao,
  _c('compactacao'): Atr.compactacao,

  _c('marcação'): Atr.marcacao,
  _c('marcacao'): Atr.marcacao,

  _c('finalização'): Atr.finalizacao,
  _c('finalizacao'): Atr.finalizacao,

  _c('posicionamento'): Atr.posicionamento,
  _c('cabeceio'): Atr.cabeceio,
  _c('tabela'): Atr.tabela,
  _c('frieza'): Atr.frieza,
  _c('penetração'): Atr.penetracao,
  _c('penetracao'): Atr.penetracao,
  _c('mobilidade'): Atr.mobilidade,
  _c('pressão'): Atr.pressao,
  _c('pressao'): Atr.pressao,
};

/// Cache com TODAS as chaves canônicas conhecidas, já normalizadas,
/// apontando de volta para a própria chave canônica.
/// Permite aceitar a própria chave oficial escrita com/sem acentos/espacos.
final Map<String, String> _oficialCanonico = {
  for (final k in AtrGrupo.todos) _c(k): k,
};

/// Normaliza chaves (minúsculas, sem acentos/pontuação/espacos extras)
/// e aplica o mapeamento para retornar apenas chaves canônicas.
/// Valores são clampados em 0..10.
Map<String, int> normalizarAtributos(Map<String, int> entrada) {
  final out = <String, int>{};
  entrada.forEach((k, v) {
    final ck = _c(k); // chave normalizada
    final can = _aliasCanonico[ck] ?? _oficialCanonico[ck];
    if (can != null && AtrGrupo.todos.contains(can)) {
      out[can] = (v.clamp(0, 10) as num).toInt();
    }
  });
  return out;
}

/// Garante que o mapa possui todas as [chaves] pedidas, preenchendo faltantes com 0.
Map<String, int> completarAtributos(
  Set<String> chaves,
  Map<String, int> dados,
) {
  final base = normalizarAtributos(dados);
  final out = Map<String, int>.from(base);
  for (final key in chaves) {
    out.putIfAbsent(key, () => 0);
  }
  return out;
}

bool isFisico(String k) => AtrGrupo.fisico.contains(k);
bool isMental(String k) => AtrGrupo.mental.contains(k);

/// =======================
/// Helpers de normalização
/// =======================

/// Normaliza string: minúsculo, remove acentos, remove pontuação,
/// colapsa múltiplos espaços em um, e trim no final.
String _c(String s) {
  final lower = s.toLowerCase();
  final folded = _removeAcentos(lower)
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return folded;
}

/// Remoção simples de acentos/diacríticos comuns em PT-BR.
String _removeAcentos(String s) {
  const mapa = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
    'ª': 'a',
    'º': 'o',
  };
  final buf = StringBuffer();
  for (final code in s.runes) {
    final ch = String.fromCharCode(code);
    buf.write(mapa[ch] ?? ch);
  }
  return buf.toString();
}
