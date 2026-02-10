// lib/services/world/game_state.dart
import 'dart:math' as math;

import '../../models/time_model.dart';
import '../../models/estilos.dart';
import '../../models/jogador.dart';

class GameState {
  GameState._();
  static final GameState I = GameState._();

  _Competition? _comp;

  // Getters públicos para a UI
  int get rodadaAtual => _comp?.rodadaAtual ?? 0; // 0-based
  int get totalRodadas => _comp?.totalRodadas ?? 0;
  bool get temCompeticao => _comp != null;
  bool get podeSimularRodada =>
      _comp != null && _comp!.rodadaAtual < _comp!.totalRodadas;
  List<TimeModel> get times => List.unmodifiable(_comp?.times ?? const []);

  /// cria uma Série A simples com 8 clubes e 14 rodadas (turno e returno)
  void seedSerieA() {
    final times = <TimeModel>[
      TimeModel(
          nome: 'Inter-Sul', elenco: <Jogador>[], estiloAtual: Estilo.posse),
      TimeModel(
          nome: 'Grêmio-Sul',
          elenco: <Jogador>[],
          estiloAtual: Estilo.transicao),
      TimeModel(
          nome: 'Rubro Rio', elenco: <Jogador>[], estiloAtual: Estilo.vertical),
      TimeModel(
          nome: 'Verde Oeste',
          elenco: <Jogador>[],
          estiloAtual: Estilo.defensivo),
      TimeModel(
          nome: 'Praia Leste',
          elenco: <Jogador>[],
          estiloAtual: Estilo.transicao),
      TimeModel(
          nome: 'Tricolor SP', elenco: <Jogador>[], estiloAtual: Estilo.posse),
      TimeModel(
          nome: 'Parque Leste',
          elenco: <Jogador>[],
          estiloAtual: Estilo.vertical),
      TimeModel(
          nome: 'Minas Atlético',
          elenco: <Jogador>[],
          estiloAtual: Estilo.defensivo),
    ];

    final totalRodadas = (times.length - 1) * 2;

    _comp = _Competition(
      id: 'br-serie-a-fic',
      nome: 'Liga Elite (mini)',
      totalRodadas: totalRodadas,
      rodadaAtual: 0,
      times: times,
      partidas: <_Match>[],
      calendario: <List<_Match>>[],
    );

    _gerarTabelaInicial();
    _gerarCalendarioRoundRobin();
  }

  void _gerarTabelaInicial() {
    final c = _comp;
    if (c == null) return;
    c.tabelaInterna = {
      for (final t in c.times)
        _keyTime(t): _Row(pts: 0, j: 0, v: 0, e: 0, d: 0, gp: 0, gc: 0),
    };
  }

  String _keyTime(TimeModel t) => t.nome;

  /// Gera calendário turno e returno com algoritmo do “círculo”
  void _gerarCalendarioRoundRobin() {
    final c = _comp!;
    final n = c.times.length;
    assert(n % 2 == 0, 'Número de times deve ser par para este gerador');

    final idx = List<int>.generate(n, (i) => i);
    final metade = n ~/ 2;

    // TURN0 (ida)
    for (var r = 0; r < n - 1; r++) {
      final rodada = <_Match>[];
      for (var i = 0; i < metade; i++) {
        final a = c.times[idx[i]];
        final b = c.times[idx[n - 1 - i]];

        // alterna mando para balancear
        final casaPrimeiro = (r + i) % 2 == 0;
        final mandante = casaPrimeiro ? a : b;
        final visitante = casaPrimeiro ? b : a;

        rodada.add(_Match(
          id: 'R${r + 1}-${_keyTime(mandante)}-${_keyTime(visitante)}',
          casa: mandante,
          fora: visitante,
          golsCasa: 0,
          golsFora: 0,
          status: _MatchStatus.agendada,
        ));
      }
      c.calendario.add(rodada);

      // rotação (mantém idx[0] fixo)
      final fixo = idx.first;
      final resto = idx.sublist(1);
      resto.insert(0, resto.removeLast());
      idx
        ..clear()
        ..add(fixo)
        ..addAll(resto);
    }

    // TURNO 2 (volta) — inverte mandos
    final tamanhoIda = c.calendario.length;
    for (var r = 0; r < tamanhoIda; r++) {
      final ida = c.calendario[r];
      final volta = <_Match>[];
      for (final m in ida) {
        volta.add(_Match(
          id: 'R${tamanhoIda + r + 1}-${_keyTime(m.fora)}-${_keyTime(m.casa)}',
          casa: m.fora,
          fora: m.casa,
          golsCasa: 0,
          golsFora: 0,
          status: _MatchStatus.agendada,
        ));
      }
      c.calendario.add(volta);
    }
  }

  /// Simula a PRÓXIMA rodada do calendário (empates possíveis)
  void simularProximaRodada() {
    final c = _comp;
    if (c == null) return;
    if (c.rodadaAtual >= c.totalRodadas) return;

    final jogos = c.calendario[c.rodadaAtual];

    for (var i = 0; i < jogos.length; i++) {
      final j = jogos[i];
      // gerador determinístico por rodada+par (reprodutível)
      final r = math.Random(c.rodadaAtual * 97 + i * 31);

      final golsM = _sorteiaGols(r, vantagemCasa: true);
      final golsV = _sorteiaGols(r, vantagemCasa: false);

      jogos[i] = j.copyWith(
        golsCasa: golsM,
        golsFora: golsV,
        status: _MatchStatus.finalizada,
      );

      c.partidas.add(jogos[i]); // histórico linear
      _aplicarResultado(_keyTime(j.casa), _keyTime(j.fora), golsM, golsV);
    }

    c.rodadaAtual += 1;
  }

  // distribuição simples: 0..4 gols com pesos; mandante tem leve bônus
  int _sorteiaGols(math.Random r, {required bool vantagemCasa}) {
    // pesos ~ [0:30%, 1:35%, 2:20%, 3:10%, 4+:5%]
    final p = r.nextDouble();
    int g;
    if (p < 0.30) {
      g = 0;
    } else if (p < 0.65) {
      g = 1;
    } else if (p < 0.85) {
      g = 2;
    } else if (p < 0.95) {
      g = 3;
    } else {
      g = 4;
    }
    if (vantagemCasa && r.nextDouble() < 0.20) {
      g = math.min(4, g + 1);
    }
    return g;
  }

  void _aplicarResultado(String idM, String idV, int gm, int gv) {
    final c = _comp!;
    final tm = c.tabelaInterna[idM]!;
    final tv = c.tabelaInterna[idV]!;

    tm.j++;
    tv.j++;
    tm.gp += gm;
    tm.gc += gv;
    tv.gp += gv;
    tv.gc += gm;

    if (gm > gv) {
      tm.v++;
      tm.pts += 3;
      tv.d++;
    } else if (gm < gv) {
      tv.v++;
      tv.pts += 3;
      tm.d++;
    } else {
      tm.e++;
      tv.e++;
      tm.pts += 1;
      tv.pts += 1;
    }
  }

  /// Retorna a tabela convertida para o modelo esperado na UI
  List<StandingsRow> tabela() {
    final c = _comp;
    if (c == null) return [];

    final rows = <StandingsRow>[];
    for (final t in c.times) {
      final r = c.tabelaInterna[_keyTime(t)]!;
      final saldo = r.gp - r.gc;
      rows.add(
        StandingsRow(
          pos: 0,
          time: t,
          j: r.j,
          v: r.v,
          e: r.e,
          d: r.d,
          gp: r.gp,
          gc: r.gc,
          saldo: saldo,
          pts: r.pts,
        ),
      );
    }

    rows.sort((a, b) {
      final byPts = b.pts.compareTo(a.pts);
      if (byPts != 0) return byPts;
      final bySaldo = b.saldo.compareTo(a.saldo);
      if (bySaldo != 0) return bySaldo;
      final byGp = b.gp.compareTo(a.gp);
      if (byGp != 0) return byGp;
      return a.time.nome.compareTo(b.time.nome);
    });

    for (var i = 0; i < rows.length; i++) {
      rows[i] = rows[i].copyWith(pos: i + 1);
    }
    return rows;
  }

  /// Fixtures para a rodada pedida (0-based). Útil para a UI.
  List<MatchView> jogosDaRodada(int rodada) {
    final c = _comp;
    if (c == null) return const [];
    if (rodada < 0 || rodada >= c.calendario.length) return const [];
    return c.calendario[rodada]
        .map((m) => MatchView(
              casa: m.casa.nome,
              fora: m.fora.nome,
              golsCasa: m.golsCasa,
              golsFora: m.golsFora,
              finalizada: m.status == _MatchStatus.finalizada,
            ))
        .toList(growable: false);
  }

  List<MatchView> jogosDaRodadaAtual() => jogosDaRodada(rodadaAtual);
}

/// ─────────────────────────── Internals ───────────────────────────
class _Competition {
  final String id;
  final String nome;
  final int totalRodadas;
  int rodadaAtual;
  final List<TimeModel> times;
  final List<_Match> partidas; // histórico linear (após jogar)
  final List<List<_Match>> calendario; // fixture por rodada

  Map<String, _Row> tabelaInterna = {};

  _Competition({
    required this.id,
    required this.nome,
    required this.totalRodadas,
    required this.rodadaAtual,
    required this.times,
    required this.partidas,
    required this.calendario,
  });
}

enum _MatchStatus { agendada, finalizada }

class _Match {
  final String id;
  final TimeModel casa;
  final TimeModel fora;
  final int golsCasa;
  final int golsFora;
  final _MatchStatus status;

  _Match({
    required this.id,
    required this.casa,
    required this.fora,
    required this.golsCasa,
    required this.golsFora,
    required this.status,
  });

  _Match copyWith({
    String? id,
    TimeModel? casa,
    TimeModel? fora,
    int? golsCasa,
    int? golsFora,
    _MatchStatus? status,
  }) {
    return _Match(
      id: id ?? this.id,
      casa: casa ?? this.casa,
      fora: fora ?? this.fora,
      golsCasa: golsCasa ?? this.golsCasa,
      golsFora: golsFora ?? this.golsFora,
      status: status ?? this.status,
    );
  }
}

class _Row {
  int pts, j, v, e, d, gp, gc;
  _Row({
    required this.pts,
    required this.j,
    required this.v,
    required this.e,
    required this.d,
    required this.gp,
    required this.gc,
  });
}

class StandingsRow {
  final int pos;
  final TimeModel time;
  final int j, v, e, d, gp, gc, saldo, pts;

  StandingsRow({
    required this.pos,
    required this.time,
    required this.j,
    required this.v,
    required this.e,
    required this.d,
    required this.gp,
    required this.gc,
    required this.saldo,
    required this.pts,
  });

  StandingsRow copyWith({int? pos}) => StandingsRow(
        pos: pos ?? this.pos,
        time: time,
        j: j,
        v: v,
        e: e,
        d: d,
        gp: gp,
        gc: gc,
        saldo: saldo,
        pts: pts,
      );
}

/// Projeção simples para a UI
class MatchView {
  final String casa;
  final String fora;
  final int golsCasa;
  final int golsFora;
  final bool finalizada;
  const MatchView({
    required this.casa,
    required this.fora,
    required this.golsCasa,
    required this.golsFora,
    required this.finalizada,
  });
}
