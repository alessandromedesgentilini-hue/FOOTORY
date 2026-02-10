// lib/pages/league/rodadas_page.dart
//
// Rodadas / Resultados — versão robusta e tolerante a diferenças de API.
// - Funciona com GameState variando nomes/assinaturas (dynamic + fallbacks).
// - totalRodadas: usa propriedade/método ou deriva do maior "rodada" em partidas.
// - jogosDaRodada: tenta 0-based e 1-based; se não houver, filtra todas as partidas.
// - Exibe nomes de times a partir de TimeModel, String ou Map.
// - Placar só aparece quando ambos os gols existem; senão mostra "—".

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';

class RodadasPage extends StatelessWidget {
  const RodadasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic gs = GameState.I;

    if (!_hasCompeticao(gs)) {
      return const Scaffold(
        body: Center(child: Text('Crie a competição no Menu.')),
      );
    }

    final total = _safeTotalRodadas(gs);
    final atual1 = _safeRodadaAtual(gs) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Rodadas / Resultados')),
      body: ListView.builder(
        itemCount: total > 0 ? total : 0,
        itemBuilder: (context, r) {
          final rodada0 = r; // 0-based
          final jogos = _jogosDaRodada(gs, rodada0);

          return ExpansionTile(
            initiallyExpanded: (atual1 > 0) && (rodada0 == (atual1 - 1)),
            title: Text('Rodada ${rodada0 + 1}'),
            subtitle: Text('${jogos.length} partidas'),
            children: [
              for (final j in jogos)
                ListTile(
                  title: Text(
                      '${_nomeTime(_getMandante(j))} x ${_nomeTime(_getVisitante(j))}'),
                  trailing: Text(
                    _placar(j),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── GameState safe access ───────────────────────────────────────────────────

  bool _hasCompeticao(dynamic gs) {
    // propriedade
    try {
      final v = gs.temCompeticao;
      if (v is bool) return v;
    } catch (_) {}
    // método
    try {
      final v = gs.temCompeticao();
      if (v is bool) return v;
    } catch (_) {}
    // fallback: existe alguma partida?
    return _todasPartidas(gs).isNotEmpty;
  }

  int _safeTotalRodadas(dynamic gs) {
    // propriedade
    try {
      final v = gs.totalRodadas;
      if (v is int && v > 0) return v;
    } catch (_) {}
    try {
      final v = gs.numeroDeRodadas; // alias comum
      if (v is int && v > 0) return v;
    } catch (_) {}
    // método
    try {
      final v = gs.totalRodadas();
      if (v is int && v > 0) return v;
    } catch (_) {}
    // derivar das partidas
    final all = _todasPartidas(gs);
    if (all.isNotEmpty) {
      int maxR = 0;
      for (final p in all) {
        final r = _readRodada(p);
        if (r != null && r > maxR) maxR = r;
      }
      if (maxR > 0) return maxR;
    }
    return 0;
  }

  /// Retorna rodada atual (1-based) se disponível.
  int? _safeRodadaAtual(dynamic gs) {
    try {
      final v = gs.rodadaAtual;
      if (v is int && v > 0) return v;
    } catch (_) {}
    try {
      final v = gs.rodadaAtual();
      if (v is int && v > 0) return v;
    } catch (_) {}
    return null;
  }

  List _jogosDaRodada(dynamic gs, int idx0) {
    // 1) método direto (0-based)
    try {
      final v = gs.jogosDaRodada(idx0);
      if (v is List) return v;
    } catch (_) {}
    // 2) método (1-based)
    try {
      final v = gs.jogosDaRodada(idx0 + 1);
      if (v is List) return v;
    } catch (_) {}
    // 3) derivar das partidas
    final all = _todasPartidas(gs);
    if (all.isEmpty) return const [];
    final r1 = idx0 + 1;
    return all.where((p) => _readRodada(p) == r1).toList();
  }

  List _todasPartidas(dynamic gs) {
    try {
      final v = gs.partidas;
      if (v is List) return v;
    } catch (_) {}
    try {
      final v = gs.calendar; // alias possível
      if (v is List) return v;
    } catch (_) {}
    try {
      final v = gs.jogos; // outro alias possível
      if (v is List) return v;
    } catch (_) {}
    return const [];
  }

  // ── Partida-like readers ───────────────────────────────────────────────────

  int? _readRodada(dynamic p) {
    try {
      final v = (p as dynamic).rodada;
      if (v is int) return v;
    } catch (_) {}
    try {
      final v = (p as Map)['rodada'];
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString());
    } catch (_) {}
    return null;
  }

  dynamic _getMandante(dynamic p) {
    try {
      return (p as dynamic).mandante;
    } catch (_) {
      try {
        return (p as Map)['mandante'];
      } catch (_) {
        return null;
      }
    }
  }

  dynamic _getVisitante(dynamic p) {
    try {
      return (p as dynamic).visitante;
    } catch (_) {
      try {
        return (p as Map)['visitante'];
      } catch (_) {
        return null;
      }
    }
  }

  String _nomeTime(dynamic t) {
    if (t == null) return '—';
    if (t is String) return t;
    try {
      final n = (t as dynamic).nome;
      if (n is String && n.isNotEmpty) return n;
    } catch (_) {}
    try {
      final n = (t as Map)['nome'];
      if (n is String && n.isNotEmpty) return n;
    } catch (_) {}
    return t.toString();
  }

  int? _gols(dynamic p, {required bool mandante}) {
    // propriedade direta
    try {
      final v =
          mandante ? (p as dynamic).golsMandante : (p as dynamic).golsVisitante;
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString());
    } catch (_) {}
    // Map
    try {
      final key = mandante ? 'golsMandante' : 'golsVisitante';
      final v = (p as Map)[key];
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString());
    } catch (_) {}
    // aliases comuns (gm/gv)
    try {
      final key = mandante ? 'gm' : 'gv';
      final v = (p as Map)[key];
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString());
    } catch (_) {}
    return null;
  }

  String _placar(dynamic p) {
    final gm = _gols(p, mandante: true);
    final gv = _gols(p, mandante: false);
    if (gm == null || gv == null) return '—';
    return '$gm - $gv';
  }
}
