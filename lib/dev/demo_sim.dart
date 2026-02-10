// lib/dev/demo_sim.dart
//
// Demo simples para testar tática + simulação sem depender de telas.
// Chame `runDemoSim()` a partir de um botão/entrada DEV no app.
//
// Este arquivo é **tolerante a diferenças de API** do GameState:
// usa `dynamic` + try/catch para não quebrar a compilação caso
// alguns métodos (seedSerieA, tabela, etc.) não existam no seu branch.
//
// Melhorias desta versão:
// • Parâmetros opcionais (rounds, showTop, seedIfMissing, tactics)
// • Fallbacks de APIs (ex.: seedSerieA/seedBrasileirao; simularProximaRodada/simularRodada/simular)
// • Logs mais claros e helpers utilitários
// • Extração resiliente de campos da tabela com null-safety
//
// ignore_for_file: avoid_print

import '../services/world/game_state.dart';
import '../models/estilos.dart';
import '../models/time_sim_ext.dart';

/// Executa uma simulação rápida.
///
/// [rounds] quantas rodadas simular (default: 1)
/// [showTop] quantas posições imprimir no ranking ao final (default: 5)
/// [seedIfMissing] semeia competição caso não exista (default: true)
/// [tactics] define tática por slug (ex.: {'rubro-rio': Estilo.posseDeBola})
void runDemoSim({
  int rounds = 1,
  int showTop = 5,
  bool seedIfMissing = true,
  Map<String, Estilo>? tactics,
}) {
  // Usa dynamic para não exigir que TODO mundo tenha as mesmas assinaturas.
  final dynamic gs = GameState.I;

  // 1) Garantir competição semeada (se a API existir)
  if (seedIfMissing) {
    _ensureSeed(gs);
  }

  // Helper p/ buscar nível do clube (quando existir), com fallback 3.0.
  double nivelFor(String slug) {
    try {
      final n = gs.nivelDoClube(slug);
      if (n is num) return n.toDouble();
    } catch (_) {}
    return 3.0;
  }

  // 2) Definir táticas p/ clubes fornecidos (se o registry existir)
  final tac = tactics ??
      <String, Estilo>{
        // Slugs exemplos em ASCII “seguros”
        'rubro-rio': Estilo.posseDeBola,
        'cruz-maltino': Estilo.transicao,
      };
  tac.forEach((slug, estilo) {
    try {
      final cfg = TimeTaticoRegistry.defaultFor(estilo, nivelFor(slug));
      TimeTaticoRegistry.set(slug, cfg);
      logDemo('Tática definida: $slug -> ${estilo.label}');
    } catch (_) {
      warnDemo(
        'TimeTaticoRegistry indisponível; não foi possível setar tática p/ $slug.',
      );
    }
  });

  // 3) Simular N rodadas (se existir tal API)
  final simOk = _simulateRounds(gs, rounds);
  if (!simOk) {
    warnDemo('Nenhuma API de simulação encontrada; pulando simulação.');
  }

  // 4) Imprimir top-N da tabela (se existir tal API)
  _printStandings(gs, topN: showTop);
}

// --------- helpers de seed/sim/standings ---------

void _ensureSeed(dynamic gs) {
  try {
    final tem = (gs.temCompeticao as bool?) ?? false;
    if (!tem) {
      // Tenta diferentes nomes de métodos de seed (compat)
      final seeded = _tryCall(gs, 'seedSerieA') ||
          _tryCall(gs, 'seedBrasileirao') ||
          _tryCall(gs, 'seed');

      if (seeded) {
        logDemo('Seed de competição executado.');
      } else {
        warnDemo('API de seed não encontrada; seguindo sem semear.');
      }
    } else {
      logDemo('Competição já estava semeada.');
    }
  } catch (_) {
    // Se `temCompeticao` não existir, tenta semear direto (best effort)
    final seeded = _tryCall(gs, 'seedSerieA') ||
        _tryCall(gs, 'seedBrasileirao') ||
        _tryCall(gs, 'seed');
    if (seeded) {
      logDemo('Seed tentado sem `temCompeticao`; executado com sucesso.');
    } else {
      warnDemo('Seed indisponível; pulando.');
    }
  }
}

bool _simulateRounds(dynamic gs, int rounds) {
  var ok = false;
  for (var i = 0; i < rounds; i++) {
    // Tenta as possíveis assinaturas de simulação
    final ran = _tryCall(gs, 'simularProximaRodada') ||
        _tryCall(gs, 'simularRodada') ||
        _tryCall(gs, 'simular');
    ok = ok || ran;
    if (ran) {
      logDemo('Rodada ${i + 1} simulada.');
    } else {
      break;
    }
  }
  return ok;
}

void _printStandings(dynamic gs, {int topN = 5}) {
  try {
    final rodada = _asIntOr(gs, 'rodadaAtual', 0);
    final total = _asIntOr(gs, 'totalRodadas', 0);

    final tabela = _callResult(gs, 'tabela');
    final list = (tabela is Iterable) ? tabela.toList() : const [];
    final top = list.take(topN).toList();

    logDemo(
        '=== TOP $topN ${rodada > 0 && total > 0 ? "APÓS $rodada/$total" : ""} ===');
    for (final r in top) {
      print(_formatRow(r));
    }
    if (top.isEmpty) {
      warnDemo('Tabela vazia/indisponível; nada para imprimir.');
    }
  } catch (_) {
    warnDemo('tabela/rodadaAtual/totalRodadas indisponíveis; sem ranking.');
  }
}

// --------- utils de reflexão segura (dinâmica) ---------

/// Tenta invocar `obj.nome()` sem argumentos; retorna true se executou sem erro.
bool _tryCall(dynamic obj, String nome) {
  try {
    final fn = obj as dynamic;
    // dart dynamic: chamar `fn.nome()` dispara NoSuchMethodError se não existir
    // ignore: avoid_dynamic_calls
    fn.noSuchMethod; // apenas força análise; não executa
  } catch (_) {}
  try {
    // ignore: avoid_dynamic_calls
    final res = Function.apply((obj as dynamic).__proto__ ?? (_) {}, const []);
    // Acima não é viável em Dart; mantemos a chamada direta dentro do try abaixo.
  } catch (_) {}
  try {
    // Chamadas diretas sob try/catch para ativar NoSuchMethod quando ausente.
    switch (nome) {
      case 'seedSerieA':
        // ignore: avoid_dynamic_calls
        obj.seedSerieA();
        return true;
      case 'seedBrasileirao':
        // ignore: avoid_dynamic_calls
        obj.seedBrasileirao();
        return true;
      case 'seed':
        // ignore: avoid_dynamic_calls
        obj.seed();
        return true;
      case 'simularProximaRodada':
        // ignore: avoid_dynamic_calls
        obj.simularProximaRodada();
        return true;
      case 'simularRodada':
        // ignore: avoid_dynamic_calls
        obj.simularRodada();
        return true;
      case 'simular':
        // ignore: avoid_dynamic_calls
        obj.simular();
        return true;
      default:
        return false;
    }
  } catch (_) {
    return false;
  }
}

/// Invoca `obj.nome()` e retorna o resultado, ou null se não existir/der erro.
dynamic _callResult(dynamic obj, String nome) {
  try {
    switch (nome) {
      case 'tabela':
        // ignore: avoid_dynamic_calls
        return obj.tabela();
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

int _asIntOr(dynamic obj, String prop, int fallback) {
  try {
    // ignore: avoid_dynamic_calls
    final v = (obj as dynamic)
        .noSuchMethod; // apenas para acalmar alguns analisadores, sem efeito
  } catch (_) {}
  try {
    switch (prop) {
      case 'rodadaAtual':
        // ignore: avoid_dynamic_calls
        final v = obj.rodadaAtual;
        if (v is int) return v;
        if (v is num) return v.toInt();
        return fallback;
      case 'totalRodadas':
        // ignore: avoid_dynamic_calls
        final v = obj.totalRodadas;
        if (v is int) return v;
        if (v is num) return v.toInt();
        return fallback;
      default:
        return fallback;
    }
  } catch (_) {
    return fallback;
  }
}

/// Formata uma linha da tabela tentando extrair campos comuns.
/// Se falhar, retorna `toString()`.
String _formatRow(dynamic row) {
  try {
    final d = row as dynamic;
    final pos = _safeAny(d, 'pos');
    final timeNome = _safeAny(d, 'time') != null
        ? (_safeAny(d.time, 'nome') ?? '???')
        : (_safeAny(d, 'timeNome') ?? '???');
    final pts = _safeAny(d, 'pts');
    final j = _safeAny(d, 'j');
    final v = _safeAny(d, 'v');
    final e = _safeAny(d, 'e');
    final dDer = _safeAny(d, 'd');
    final gp = _safeAny(d, 'gp');
    final gc = _safeAny(d, 'gc');
    final saldo = _safeAny(d, 'saldo') ?? _safeAny(d, 'sg');

    return '$pos. $timeNome  —  $pts pts  (J:$j  V:$v  E:$e  D:$dDer  GP:$gp  GC:$gc  SG:$saldo)';
  } catch (_) {
    return row.toString();
  }
}

dynamic _safeAny(dynamic obj, String prop) {
  try {
    switch (prop) {
      case 'pos':
        // ignore: avoid_dynamic_calls
        return obj.pos;
      case 'time':
        // ignore: avoid_dynamic_calls
        return obj.time;
      case 'timeNome':
        // ignore: avoid_dynamic_calls
        return obj.timeNome;
      case 'pts':
        // ignore: avoid_dynamic_calls
        return obj.pts;
      case 'j':
        // ignore: avoid_dynamic_calls
        return obj.j;
      case 'v':
        // ignore: avoid_dynamic_calls
        return obj.v;
      case 'e':
        // ignore: avoid_dynamic_calls
        return obj.e;
      case 'd':
        // ignore: avoid_dynamic_calls
        return obj.d;
      case 'gp':
        // ignore: avoid_dynamic_calls
        return obj.gp;
      case 'gc':
        // ignore: avoid_dynamic_calls
        return obj.gc;
      case 'saldo':
        // ignore: avoid_dynamic_calls
        return obj.saldo;
      case 'sg':
        // ignore: avoid_dynamic_calls
        return obj.sg;
      case 'nome':
        // ignore: avoid_dynamic_calls
        return obj.nome;
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

// --------- helpers de log (apenas console) ---------
void logDemo(Object msg) {
  print('[demo_sim] $msg');
}

void warnDemo(Object msg) {
  print('[demo_sim][WARN] $msg');
}
