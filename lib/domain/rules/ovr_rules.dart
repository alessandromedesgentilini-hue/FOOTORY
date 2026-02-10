// lib/domain/rules/ovr_rules.dart
//
// A1/A3 — Regras canônicas de Overall (OVR) do FutSim
// - Atributos: 1..10 (inteiros)
// - OVR por função: soma dos 10 atributos da função (10..100)
// - Função principal: maior OVR entre funções habilitadas
// - Empate: mantém a função principal atual (se fornecida)
// - Sem média, sem pesos, sem "potencial" escondido
//
// Obs: Gameplay usa atributos. OVR é resumo/mercado/UI.

import '../data/funcoes_map.dart';
import '../enums/atributo.dart';
import '../enums/funcao.dart';

class OvrRules {
  const OvrRules._();

  /// Clamp canônico do atributo (1..10).
  static int clampAttr(int v) => v.clamp(1, 10);

  /// Calcula OVR de uma função (soma dos 10 atributos).
  /// - Se algum atributo estiver ausente no mapa, assume 1.
  static int ovrDaFuncao({
    required Funcao funcao,
    required Map<Atributo, int> atributos,
  }) {
    final keys = atributosPorFuncao[funcao];
    if (keys == null || keys.length != 10) {
      throw StateError(
        'Mapa de funcao invalido: ${funcao.key}. '
        'Esperado 10 atributos em atributosPorFuncao.',
      );
    }

    var soma = 0;
    for (final a in keys) {
      soma += clampAttr(atributos[a] ?? 1);
    }
    return soma.clamp(10, 100);
  }

  /// Retorna a função principal (maior OVR) a partir das funções habilitadas.
  /// - Se principalAtual for fornecida e empatar, ela permanece.
  /// - Se funcoesHabilitadas estiver vazio, lança erro.
  static Funcao funcaoPrincipal({
    required Set<Funcao> funcoesHabilitadas,
    required Map<Atributo, int> atributos,
    Funcao? principalAtual,
  }) {
    if (funcoesHabilitadas.isEmpty) {
      throw StateError('funcoesHabilitadas nao pode ser vazio.');
    }

    Funcao? melhor = principalAtual;
    var melhorOvr = -1;

    if (melhor != null && funcoesHabilitadas.contains(melhor)) {
      melhorOvr = ovrDaFuncao(funcao: melhor, atributos: atributos);
    } else {
      melhor = null;
    }

    for (final f in funcoesHabilitadas) {
      final o = ovrDaFuncao(funcao: f, atributos: atributos);
      if (o > melhorOvr) {
        melhor = f;
        melhorOvr = o;
      }
      // Empate: não troca (mantém principalAtual, se existir).
    }

    return melhor ?? funcoesHabilitadas.first;
  }

  /// OVR principal (OVR da função principal).
  static int ovrPrincipal({
    required Set<Funcao> funcoesHabilitadas,
    required Map<Atributo, int> atributos,
    Funcao? principalAtual,
  }) {
    final f = funcaoPrincipal(
      funcoesHabilitadas: funcoesHabilitadas,
      atributos: atributos,
      principalAtual: principalAtual,
    );
    return ovrDaFuncao(funcao: f, atributos: atributos);
  }

  /// Calcula um ranking de OVR por função (apenas para funções habilitadas).
  /// Útil para tela de perfil/tática.
  static Map<Funcao, int> ovrPorFuncoesHabilitadas({
    required Set<Funcao> funcoesHabilitadas,
    required Map<Atributo, int> atributos,
  }) {
    final out = <Funcao, int>{};
    for (final f in funcoesHabilitadas) {
      out[f] = ovrDaFuncao(funcao: f, atributos: atributos);
    }
    return out;
  }

  /// Retorna o OVR efetivo in-game para uma função em campo:
  /// - Se função habilitada: OVR normal.
  /// - Se não habilitada: aplica penalidade nos 10 atributos da função.
  ///
  /// fatorPenalidade:
  /// - padrão canônico: 0.75 (−25%)
  /// - se um dia quiser −30%: 0.70
  static int ovrEfetivoEmJogo({
    required Funcao funcaoEmCampo,
    required Set<Funcao> funcoesHabilitadas,
    required Map<Atributo, int> atributos,
    double fatorPenalidade = 0.75,
  }) {
    final keys = atributosPorFuncao[funcaoEmCampo];
    if (keys == null || keys.length != 10) {
      throw StateError(
        'Mapa de funcao invalido: ${funcaoEmCampo.key}. '
        'Esperado 10 atributos em atributosPorFuncao.',
      );
    }

    final habilitada = funcoesHabilitadas.contains(funcaoEmCampo);
    var soma = 0;

    for (final a in keys) {
      final base = clampAttr(atributos[a] ?? 1);

      if (habilitada) {
        soma += base;
      } else {
        final penalizado = (base * fatorPenalidade).round().clamp(1, 10);
        soma += penalizado;
      }
    }

    return soma.clamp(10, 100);
  }

  /// Retorna os 10 atributos efetivos (já penalizados se fora de posição),
  /// para o motor de eventos de partida.
  static Map<Atributo, int> atributosEfetivosEmJogo({
    required Funcao funcaoEmCampo,
    required Set<Funcao> funcoesHabilitadas,
    required Map<Atributo, int> atributos,
    double fatorPenalidade = 0.75,
  }) {
    final keys = atributosPorFuncao[funcaoEmCampo];
    if (keys == null || keys.length != 10) {
      throw StateError(
        'Mapa de funcao invalido: ${funcaoEmCampo.key}. '
        'Esperado 10 atributos em atributosPorFuncao.',
      );
    }

    final habilitada = funcoesHabilitadas.contains(funcaoEmCampo);
    final out = <Atributo, int>{};

    for (final a in keys) {
      final base = clampAttr(atributos[a] ?? 1);
      if (habilitada) {
        out[a] = base;
      } else {
        out[a] = (base * fatorPenalidade).round().clamp(1, 10);
      }
    }

    return out;
  }
}
