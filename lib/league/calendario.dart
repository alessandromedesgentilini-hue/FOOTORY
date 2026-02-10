// lib/league/calendario.dart
//
// Gera calendário de turno + returno (round-robin) usando o “método do círculo”.
// Requisitos para o gerador básico: número de times PAR (ex.: 20).
//
// Extras desta versão final:
// • API compatível `gerarSerieA(...)` (turno+returno com espaçamento fixo)
// • Função genérica `gerarRoundRobinDuplo(...)` com mais opções
// • Suporte a datas customizadas por rodada (ex.: padrão Quarta/Domingo do FutSim)
// • Validações seguras (times únicos, tamanho par, datas suficientes quando customizadas)
// • Classe `JogoCalendario` com ==/hashCode para facilitar testes
//
// Uso rápido (compat):
//   final jogos = gerarSerieA(times,
//     inicio: DateTime(2025, 5, 1),
//     diasEntreRodadas: 7,
//   );
//
// Uso avançado (padrão BR Quarta/Domingo):
//   final datas = gerarDatasRodadas(
//     inicio: DateTime(2025, 1, 15), // uma quarta
//     totalRodadas: (times.length - 1) * 2,
//     padraoSemanal: const [DateTime.wednesday, DateTime.sunday],
//   );
//   final jogos = gerarRoundRobinDuplo(
//     times,
//     datasRodadas: datas, // datas por rodada 1..N
//   );

import '../models/time_model.dart';

class JogoCalendario {
  final int rodada; // 1..N
  final DateTime data;
  final TimeModel mandante;
  final TimeModel visitante;

  const JogoCalendario({
    required this.rodada,
    required this.data,
    required this.mandante,
    required this.visitante,
  });

  @override
  String toString() =>
      'R$rodada  ${mandante.nome} x ${visitante.nome}  (${data.toIso8601String()})';

  @override
  bool operator ==(Object other) {
    return other is JogoCalendario &&
        other.rodada == rodada &&
        other.data == data &&
        identical(other.mandante, mandante) &&
        identical(other.visitante, visitante);
  }

  @override
  int get hashCode =>
      Object.hash(rodada, data.millisecondsSinceEpoch, mandante, visitante);
}

/// Gera turno + returno (método do círculo), espaçando por [diasEntreRodadas].
/// `times.length` deve ser PAR (ex.: 20).
///
/// Compat com versões anteriores do projeto.
List<JogoCalendario> gerarSerieA(
  List<TimeModel> times, {
  required DateTime inicio,
  int diasEntreRodadas = 7,
}) {
  return gerarRoundRobinDuplo(
    times,
    datasRodadas: _datasPorIntervalo(
      inicio: inicio,
      totalRodadas: (times.length - 1) * 2,
      diasEntreRodadas: diasEntreRodadas,
    ),
  );
}

/// Versão genérica de turno+returno com mais opções.
///
/// Você pode fornecer as [datasRodadas] explicitamente (lista com
/// `(n - 1) * 2` datas, em que `n = times.length`) — recomendado
/// quando quiser seguir um calendário fixo (ex.: Quarta/Domingo).
///
/// Se [datasRodadas] for nula, é obrigatório usar `inicio` e
/// `diasEntreRodadas`, que serão usados para datar as rodadas em
/// sequência (turno e depois returno).
List<JogoCalendario> gerarRoundRobinDuplo(
  List<TimeModel> times, {
  // Datas por rodada (1..N). Se fornecido, ignora inicio/diasEntreRodadas.
  List<DateTime>? datasRodadas,

  // Alternativa simples: define um início e um espaçamento fixo entre rodadas.
  DateTime? inicio,
  int diasEntreRodadas = 7,

  // Mantém o primeiro time fixo nas rotações (método clássico do círculo).
  bool manterPrimeiroFixo = true,
}) {
  if (times.isEmpty) {
    return const <JogoCalendario>[];
  }
  if (times.length.isOdd) {
    throw ArgumentError(
        'Número de times precisa ser PAR para round-robin duplo.');
  }

  // Valida times únicos (evita bugs de referência repetida).
  final ids = times.map((t) => t.id).toList();
  if (ids.toSet().length != ids.length) {
    throw ArgumentError('Lista de times contém itens repetidos (mesmo id).');
  }

  final n = times.length;
  final metade = n ~/ 2;
  final rodadasTurno = n - 1;
  final totalRodadas = rodadasTurno * 2;

  // Prepara datas por rodada
  final List<DateTime> datas;
  if (datasRodadas != null) {
    if (datasRodadas.length != totalRodadas) {
      throw ArgumentError(
        'datasRodadas deve conter exatamente $totalRodadas datas '
        '(recebido: ${datasRodadas.length}).',
      );
    }
    datas = List<DateTime>.from(datasRodadas);
  } else {
    if (inicio == null) {
      throw ArgumentError('Informe `datasRodadas` ou `inicio`.');
    }
    datas = _datasPorIntervalo(
      inicio: inicio,
      totalRodadas: totalRodadas,
      diasEntreRodadas: diasEntreRodadas,
    );
  }

  // Cópia mutável para rotação (não muta a lista original).
  final lista = List<TimeModel>.from(times);

  // =================
  // TURNO (n - 1 rodadas)
  // =================
  final jogos = <JogoCalendario>[];
  for (int r = 1; r <= rodadasTurno; r++) {
    final dataRodada = datas[r - 1];

    // Pareamentos “espelho”
    for (int i = 0; i < metade; i++) {
      final mandante = lista[i];
      final visitante = lista[n - 1 - i];
      jogos.add(JogoCalendario(
        rodada: r,
        data: dataRodada,
        mandante: mandante,
        visitante: visitante,
      ));
    }

    // Rotação (método do círculo): mantém o PRIMEIRO fixo (default),
    // move o último para a posição 1; se não quiser fixo, rotaciona tudo.
    if (manterPrimeiroFixo) {
      final last = lista.removeLast();
      lista.insert(1, last);
    } else {
      // Rotação simples de toda a lista (equivalente circular).
      final last = lista.removeLast();
      lista.insert(0, last);
    }
  }

  // =================
  // RETURNO
  // =================
  // Mesmo emparelhamento do turno, mas invertendo mandos.
  // As datas do returno são as datas [rodadasTurno .. totalRodadas-1].
  final turno =
      jogos.where((j) => j.rodada <= rodadasTurno).toList(growable: false);
  for (final j in turno) {
    final rodadaReturno = j.rodada + rodadasTurno;
    final dataReturno = datas[rodadaReturno - 1];
    jogos.add(JogoCalendario(
      rodada: rodadaReturno,
      data: dataReturno,
      mandante: j.visitante,
      visitante: j.mandante,
    ));
  }

  // Ordena por rodada e, em seguida, por data (apenas por segurança)
  jogos.sort((a, b) {
    final c = a.rodada.compareTo(b.rodada);
    return c != 0 ? c : a.data.compareTo(b.data);
  });

  return jogos;
}

/// Gera uma lista de datas por rodada com base em um intervalo fixo de dias.
/// Usado pela API compat `gerarSerieA`.
List<DateTime> _datasPorIntervalo({
  required DateTime inicio,
  required int totalRodadas,
  required int diasEntreRodadas,
}) {
  final out = <DateTime>[];
  var d = inicio;
  for (var i = 0; i < totalRodadas; i++) {
    out.add(d);
    d = d.add(Duration(days: diasEntreRodadas));
  }
  return out;
}

/// Gera datas em padrão semanal para um número de rodadas específico.
/// Útil para o calendário BR salvo no projeto (Quartas e Domingos).
///
/// [padraoSemanal] aceita qualquer combinação de dias (DateTime.weekday):
/// - DateTime.monday(1) .. DateTime.sunday(7)
/// Ex.: const [DateTime.wednesday, DateTime.sunday]
///
/// A primeira data gerada será:
/// - O próprio [inicio], se o dia da semana dele estiver em [padraoSemanal];
/// - Ou a próxima ocorrência do primeiro dia contido em [padraoSemanal], após [inicio].
List<DateTime> gerarDatasRodadas({
  required DateTime inicio,
  required int totalRodadas,
  required List<int> padraoSemanal,
}) {
  assert(padraoSemanal.isNotEmpty, 'padraoSemanal não pode ser vazio.');
  // Normaliza: 1..7
  final dias = padraoSemanal.map((d) => d.clamp(1, 7)).toList(growable: false);

  final out = <DateTime>[];
  var d = inicio;

  // Encontra a primeira data válida
  if (!dias.contains(d.weekday)) {
    d = _proximaOcorrenciaDe(d, dias.first);
  }

  while (out.length < totalRodadas) {
    if (dias.contains(d.weekday)) {
      out.add(d);
    }
    d = d.add(const Duration(days: 1));
  }

  return out;
}

DateTime _proximaOcorrenciaDe(DateTime base, int weekdayWanted) {
  // weekday: 1=Mon..7=Sun
  final delta = (weekdayWanted - base.weekday) % 7;
  final days = delta <= 0 ? delta + 7 : delta;
  return base.add(Duration(days: days));
}
