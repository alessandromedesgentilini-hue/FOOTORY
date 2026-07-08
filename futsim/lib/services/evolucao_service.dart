// FutSim – Serviço de Evolução (Spring 1)
// Ganho anual + declínio físico em janeiro que IMPACTA o OVR (físicos apenas).

import 'dart:math';

class AtribF {
  static const String potencia = 'potência';
  static const String velocidade = 'velocidade';
  static const String resistencia = 'resistência';
  static const String aptidao = 'aptidão física';
  static const String coordenacao = 'coordenação motora';
  static const List<String> fisicos = [
    potencia,
    velocidade,
    resistencia,
    aptidao,
    coordenacao
  ];
}

class Balance {
  static int quedaFisicaPorIdade(int idade) {
    if (idade >= 38) return 3;
    if (idade == 36 || idade == 37) return 2;
    if (idade == 33 || idade == 35) return 1;
    return 0;
  }

  static int ganhoBasePorIdade(int idade) {
    if (idade <= 20) return 2;
    if (idade <= 27) return 1;
    if (idade <= 32) return (idade % 2 == 0) ? 1 : 0;
    return 0;
  }

  static int bonusPorMinutos(int minutos) {
    if (minutos >= 2400) return 3;
    if (minutos >= 1500) return 2;
    if (minutos >= 600) return 1;
    return 0;
  }

  static const int focoTreinoPontos = 2;

  static int eventoSorte(Random rng, int idade) {
    return (idade >= 16 && idade <= 20 && rng.nextDouble() < 0.20) ? 1 : 0;
  }
}

class EvolucaoResultado {
  final Map<String, int> atributosNovos;
  final int pontosGanhos;
  final int quedaFisica;
  final Map<String, int> logQueda;
  final Map<String, int> logGanho;
  EvolucaoResultado({
    required this.atributosNovos,
    required this.pontosGanhos,
    required this.quedaFisica,
    required this.logQueda,
    required this.logGanho,
  });
}

class EvolucaoService {
  static Map<String, int> aplicarQuedaFisica(
    Map<String, int> atributos,
    int idadeAtual, {
    List<String>? ordemPrioridade,
  }) {
    final out = Map<String, int>.from(atributos);
    final queda = Balance.quedaFisicaPorIdade(idadeAtual);
    if (queda <= 0) return out;

    final ordem = List<String>.from(
      ordemPrioridade ??
          [
            AtribF.aptidao,
            AtribF.velocidade,
            AtribF.resistencia,
            AtribF.potencia,
            AtribF.coordenacao
          ],
    );

    var restante = queda;
    int idx = 0;
    while (restante > 0) {
      final key = ordem[idx % ordem.length];
      final atual = out[key] ?? 1;
      if (atual > 1) {
        out[key] = atual - 1;
        restante -= 1;
      }
      idx += 1;
      if (idx >= 50) break;
    }
    return out;
  }

  static int calcularPontosGanhoAnual({
    required int idade,
    required int minutosAno,
    required bool recebeuFoco,
    Random? rng,
  }) {
    final r = rng ?? Random();
    return Balance.ganhoBasePorIdade(idade) +
        Balance.bonusPorMinutos(minutosAno) +
        (recebeuFoco ? Balance.focoTreinoPontos : 0) +
        Balance.eventoSorte(r, idade);
  }

  static Map<String, int> aplicarGanhos(
      Map<String, int> atributos, List<String> escolhas) {
    final out = Map<String, int>.from(atributos);
    for (final key in escolhas) {
      out[key] = ((out[key] ?? 1) + 1).clamp(1, 10);
    }
    return out;
  }

  static EvolucaoResultado tickAnualJaneiro({
    required Map<String, int> atributos,
    required int idadeNoDia1Jan,
    required int minutosAnoAnterior,
    required bool recebeuFoco,
    required List<String> escolhasGanhos,
    List<String>? ordemQueda,
    Random? rng,
  }) {
    final aposQueda = aplicarQuedaFisica(atributos, idadeNoDia1Jan,
        ordemPrioridade: ordemQueda);
    final q = Balance.quedaFisicaPorIdade(idadeNoDia1Jan);

    final pts = calcularPontosGanhoAnual(
      idade: idadeNoDia1Jan,
      minutosAno: minutosAnoAnterior,
      recebeuFoco: recebeuFoco,
      rng: rng,
    );

    final aposGanho =
        aplicarGanhos(aposQueda, escolhasGanhos.take(pts).toList());

    final logQueda = <String, int>{
      for (final k in AtribF.fisicos)
        k: (atributos[k] ?? 0) - (aposQueda[k] ?? 0)
    };

    final logGanho = <String, int>{};
    for (final key in escolhasGanhos.take(pts)) {
      logGanho[key] = (logGanho[key] ?? 0) + 1;
    }

    return EvolucaoResultado(
      atributosNovos: aposGanho,
      pontosGanhos: pts,
      quedaFisica: q,
      logQueda: logQueda,
      logGanho: logGanho,
    );
  }
}
