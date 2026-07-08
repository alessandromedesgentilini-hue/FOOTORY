// lib/league/temporada_service.dart
//
// Serviço de temporada: gera calendário (turno + returno) e simula partidas.
// Mantém API simples e compatível, com opções avançadas:
// • simularTemporada(...) — temporada completa (ou com datas customizadas)
// • simularPrimeirasRodadas(...) — tabela parcial até N rodadas
// • simularIntervaloDeRodadas(...) — simula um recorte [Rini..Rfim]
// • Callbacks por rodada (onRodadaSimulada) para telemetria/logs
// • Reuso opcional de Tabela base (ex.: acumular fases)
// • Dias fixos entre rodadas OU lista explícita de datas (datasRodadas)
//
// Observações:
// - O calendário é gerado via calendário.dart (gerarSerieA/gerarRoundRobinDuplo).
// - Exige número de times PAR (o gerador valida).
// - O serviço é “stateless”: nenhuma mutação global, retorno autocontido.

import 'calendario.dart';
import 'tabela.dart';
import '../models/time_model.dart';
import '../sim/simulador.dart';

class TemporadaResultado {
  final Tabela tabelaFinal;
  final List<ResultadoPartida> resultados;
  final List<JogoCalendario> calendario;

  const TemporadaResultado({
    required this.tabelaFinal,
    required this.resultados,
    required this.calendario,
  });

  /// Retorna a quantidade de rodadas presentes no calendário retornado.
  int get totalRodadas =>
      calendario.isEmpty ? 0 : calendario.map((e) => e.rodada).toSet().length;
}

class TemporadaService {
  final SimuladorPartida simulador;

  TemporadaService({required this.simulador});

  /// Gera calendário completo (turno + returno) e simula TODAS as partidas.
  ///
  /// Se [datasRodadas] for fornecido, ele será usado como fonte de datas
  /// (comprimento deve ser 2*(n-1)). Caso contrário, usa [inicio] +
  /// [diasEntreRodadas] (default 7).
  ///
  /// [onRodadaSimulada] (opcional) é chamado ao fim de cada rodada com a lista
  /// de resultados daquela rodada (na ordem dos jogos).
  ///
  /// [tabelaBase] permite acumular com dados prévios (ex.: punições, fases).
  TemporadaResultado simularTemporada({
    required List<TimeModel> times,
    required DateTime inicio,
    int diasEntreRodadas = 7,
    List<DateTime>? datasRodadas,
    void Function(int rodada, List<ResultadoPartida> resultadosDaRodada)?
        onRodadaSimulada,
    Tabela? tabelaBase,
  }) {
    final cal = _buildCalendario(
      times: times,
      inicio: inicio,
      diasEntreRodadas: diasEntreRodadas,
      datasRodadas: datasRodadas,
    );

    final tabela = tabelaBase ?? Tabela();
    final resultados = <ResultadoPartida>[];

    _simulateOverCalendar(
      calendario: cal,
      tabela: tabela,
      pushResultado: resultados.add,
      onRodadaSimulada: onRodadaSimulada,
    );

    return TemporadaResultado(
      tabelaFinal: tabela,
      resultados: resultados,
      calendario: cal,
    );
  }

  /// Simula somente as **primeiras [nRodadas]** do calendário gerado,
  /// retornando a tabela parcial + resultados dessas rodadas.
  ///
  /// Aceita [datasRodadas] para usar um calendário predefinido; se omitido,
  /// usa [inicio] + [diasEntreRodadas].
  TemporadaResultado simularPrimeirasRodadas({
    required List<TimeModel> times,
    required DateTime inicio,
    int diasEntreRodadas = 7,
    required int nRodadas,
    List<DateTime>? datasRodadas,
    void Function(int rodada, List<ResultadoPartida> resultadosDaRodada)?
        onRodadaSimulada,
    Tabela? tabelaBase,
  }) {
    final cal = _buildCalendario(
      times: times,
      inicio: inicio,
      diasEntreRodadas: diasEntreRodadas,
      datasRodadas: datasRodadas,
    );

    final total = _totalRodadas(times.length);
    final maxRodada = nRodadas.clamp(1, total);
    final recorte =
        cal.where((j) => j.rodada <= maxRodada).toList(growable: false);

    final tabela = tabelaBase ?? Tabela();
    final resultados = <ResultadoPartida>[];

    _simulateOverCalendar(
      calendario: recorte,
      tabela: tabela,
      pushResultado: resultados.add,
      onRodadaSimulada: onRodadaSimulada,
    );

    return TemporadaResultado(
      tabelaFinal: tabela,
      resultados: resultados,
      calendario: recorte,
    );
  }

  /// Simula rodadas em um **intervalo** (inclusive), útil para avançar em blocos.
  ///
  /// Aceita [datasRodadas] para usar um calendário predefinido; se omitido,
  /// usa [inicio] + [diasEntreRodadas].
  TemporadaResultado simularIntervaloDeRodadas({
    required List<TimeModel> times,
    required DateTime inicio,
    int diasEntreRodadas = 7,
    required int rodadaInicial, // 1-based
    required int rodadaFinal, // 1-based
    List<DateTime>? datasRodadas,
    void Function(int rodada, List<ResultadoPartida> resultadosDaRodada)?
        onRodadaSimulada,
    Tabela? tabelaBase,
  }) {
    final cal = _buildCalendario(
      times: times,
      inicio: inicio,
      diasEntreRodadas: diasEntreRodadas,
      datasRodadas: datasRodadas,
    );

    final total = _totalRodadas(times.length);
    final rIni = rodadaInicial.clamp(1, total);
    final rFim = rodadaFinal.clamp(rIni, total);

    final recorte =
        cal.where((j) => j.rodada >= rIni && j.rodada <= rFim).toList();

    final tabela = tabelaBase ?? Tabela();
    final resultados = <ResultadoPartida>[];

    _simulateOverCalendar(
      calendario: recorte,
      tabela: tabela,
      pushResultado: resultados.add,
      onRodadaSimulada: onRodadaSimulada,
    );

    return TemporadaResultado(
      tabelaFinal: tabela,
      resultados: resultados,
      calendario: recorte,
    );
  }

  // ----------------- Internals -----------------

  List<JogoCalendario> _buildCalendario({
    required List<TimeModel> times,
    required DateTime inicio,
    required int diasEntreRodadas,
    List<DateTime>? datasRodadas,
  }) {
    if (datasRodadas != null) {
      // Usa caminho avançado (datas explícitas)
      return gerarRoundRobinDuplo(
        times,
        datasRodadas: datasRodadas,
      );
    }
    // Compat: espaçamento fixo
    return gerarSerieA(
      times,
      inicio: inicio,
      diasEntreRodadas: diasEntreRodadas,
    );
  }

  /// Simula todos os jogos de [calendario], disparando callback por rodada.
  void _simulateOverCalendar({
    required List<JogoCalendario> calendario,
    required Tabela tabela,
    required void Function(ResultadoPartida r) pushResultado,
    void Function(int rodada, List<ResultadoPartida> resultadosDaRodada)?
        onRodadaSimulada,
  }) {
    // Agrupa por rodada preservando a ordem original
    final porRodada = <int, List<JogoCalendario>>{};
    for (final j in calendario) {
      porRodada.putIfAbsent(j.rodada, () => <JogoCalendario>[]).add(j);
    }

    final rodadasOrdenadas = porRodada.keys.toList()..sort();

    for (final rNum in rodadasOrdenadas) {
      final jogosDaRodada = porRodada[rNum]!;
      final resDaRodada = <ResultadoPartida>[];

      for (final j in jogosDaRodada) {
        final r = simulador.simular(
          mandante: j.mandante,
          visitante: j.visitante,
        );
        tabela.registra(r);
        pushResultado(r);
        resDaRodada.add(r);
      }

      if (onRodadaSimulada != null) {
        onRodadaSimulada(rNum, resDaRodada);
      }
    }
  }

  /// Total de rodadas de um round-robin duplo (turno+returno) com `n` times.
  int _totalRodadas(int nTimes) {
    if (nTimes % 2 != 0) {
      throw ArgumentError('Número de times precisa ser PAR.');
    }
    return 2 * (nTimes - 1);
  }
}
