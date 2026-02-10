// lib/pages/league/tabela_page.dart
//
// Tabela – Série (VERSÃO ENXUTA E ROBUSTA)
// - Aceita múltiplos formatos de entrada (List<dynamic>):
//     • Map com chaves: pts, j, v, e, d, gp, gc, saldo, timeNome
//     • Map com {pos, row} onde row tem as chaves acima
//     • Objetos com getters simples (bem “tolerante”)
// - Se não vier posição, ordena por: pontos, vitórias, saldo, gols pró.
// - Se [rows] for null, tenta ler de GameState.I.tabela (propriedade).

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';

class TabelaPage extends StatelessWidget {
  final String titulo;
  final List<dynamic>? rows; // opcional: se vier null, tenta GameState.I.tabela

  const TabelaPage({
    super.key,
    this.titulo = 'Tabela — Série',
    this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final data = rows ?? _safeTabelaFromGameState();

    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(titulo)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Tabela indisponível no momento.\n'
              'Inicie/simule uma rodada para visualizar a classificação.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final norm = _normalizeRows(data);

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: ListView.separated(
        itemCount: norm.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final r = norm[i];
          return ListTile(
            leading: CircleAvatar(child: Text(r.pos.toString())),
            title: Text(
              r.timeNome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'J:${r.j}  V:${r.v}  E:${r.e}  D:${r.d}  '
              'GP:${r.gp}  GC:${r.gc}  SG:${r.saldo}',
            ),
            trailing: Text(
              '${r.pts} pts',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  // ======= Leitura segura do GameState =======
  List<dynamic> _safeTabelaFromGameState() {
    try {
      final gs = GameState.I;

      // 1) Propriedade gs.tabela (é o teu caso atual)
      try {
        final v = (gs as dynamic).tabela;
        if (v is Iterable) return v.toList();
      } catch (_) {}

      // 2) Alguns estados antigos: tabelaAtual/tabelaFinal/tabelaObj
      try {
        final t = (gs as dynamic).tabelaFinal ??
            (gs as dynamic).tabelaAtual ??
            (gs as dynamic).tabelaObj;
        if (t != null) {
          try {
            final v = (t as dynamic).linhasOrdenadas;
            if (v is Iterable) return v.toList();
          } catch (_) {
            try {
              final v = (t as dynamic).linhasOrdenadas();
              if (v is Iterable) return v.toList();
            } catch (_) {}
          }
        }
      } catch (_) {}

      return const <dynamic>[];
    } catch (_) {
      return const <dynamic>[];
    }
  }
}

// ======= Normalização =======

class _RowNorm {
  final int pos;
  final String timeNome;
  final int pts, j, v, e, d, gp, gc, saldo;
  const _RowNorm({
    required this.pos,
    required this.timeNome,
    required this.pts,
    required this.j,
    required this.v,
    required this.e,
    required this.d,
    required this.gp,
    required this.gc,
    required this.saldo,
  });
}

List<_RowNorm> _normalizeRows(List<dynamic> rows) {
  // Extrai {pos, base} quando vier como {pos, row}
  final extracted = <({int? pos, Object base})>[];
  for (final r in rows) {
    int? pos;
    Object base = r;

    if (r is Map) {
      if (r['pos'] is int && r['row'] != null) {
        pos = r['pos'] as int;
        base = r['row'] as Object;
      }
    } else {
      try {
        final p = (r as dynamic).pos;
        final b = (r as dynamic).row;
        if (p is int && b != null) {
          pos = p;
          base = b as Object;
        }
      } catch (_) {}
    }

    extracted.add((pos: pos, base: base));
  }

  // Lê estatísticas de cada linha
  final temp = <({
    int? pos,
    String nome,
    int pts,
    int j,
    int v,
    int e,
    int d,
    int gp,
    int gc,
    int saldo
  })>[];

  for (final it in extracted) {
    final b = it.base;

    final nome = _readTeamName(b);
    final pts = _readIntAny(b, const ['pts', 'pontos']) ?? 0;
    final v = _readIntAny(b, const ['v', 'vitorias']) ?? 0;
    final e = _readIntAny(b, const ['e', 'empates']) ?? 0;
    final d = _readIntAny(b, const ['d', 'derrotas']) ?? 0;
    final gp = _readIntAny(b, const ['gp', 'golsPro', 'gols_pro']) ?? 0;
    final gc = _readIntAny(b, const ['gc', 'golsContra', 'gols_contra']) ?? 0;
    final j = _readIntAny(b, const ['j', 'jogos']) ?? (v + e + d);
    final saldo = _readIntAny(b, const ['saldo', 'sg']) ?? (gp - gc);

    temp.add((
      pos: it.pos,
      nome: nome,
      pts: pts,
      j: j,
      v: v,
      e: e,
      d: d,
      gp: gp,
      gc: gc,
      saldo: saldo,
    ));
  }

  // Ordena: pontos DESC, vitórias DESC, saldo DESC, gols pró DESC
  final needsSort = temp.any((x) => x.pos == null);
  final ord = [...temp];

  if (needsSort) {
    ord.sort((a, b) {
      int c = b.pts.compareTo(a.pts);
      if (c != 0) return c;
      c = b.v.compareTo(a.v);
      if (c != 0) return c;
      c = b.saldo.compareTo(a.saldo);
      if (c != 0) return c;
      return b.gp.compareTo(a.gp);
    });
  } else {
    ord.sort((a, b) => (a.pos ?? 0).compareTo(b.pos ?? 0));
  }

  // Numera posições (quando não vierem prontas)
  final out = <_RowNorm>[];
  for (var i = 0; i < ord.length; i++) {
    final r = ord[i];
    out.add(_RowNorm(
      pos: r.pos ?? (i + 1),
      timeNome: r.nome,
      pts: r.pts,
      j: r.j,
      v: r.v,
      e: r.e,
      d: r.d,
      gp: r.gp,
      gc: r.gc,
      saldo: r.saldo,
    ));
  }

  return out;
}

// ======= Leitores seguros =======

String _readTeamName(Object row) {
  if (row is Map) {
    final t = row['time'];
    if (t is Map && t['nome'] is String && (t['nome'] as String).isNotEmpty) {
      return t['nome'] as String;
    }
    if (row['timeNome'] is String && (row['timeNome'] as String).isNotEmpty) {
      return row['timeNome'] as String;
    }
    if (row['nome'] is String && (row['nome'] as String).isNotEmpty) {
      return row['nome'] as String;
    }
  } else {
    try {
      final t = (row as dynamic).time;
      if (t != null) {
        try {
          final n = (t as dynamic).nome;
          if (n is String && n.isNotEmpty) return n;
        } catch (_) {}
      }
    } catch (_) {}
    try {
      final n = (row as dynamic).timeNome;
      if (n is String && n.isNotEmpty) return n;
    } catch (_) {}
    try {
      final n = (row as dynamic).nome;
      if (n is String && n.isNotEmpty) return n;
    } catch (_) {}
  }
  return '—';
}

int? _readIntAny(Object row, List<String> keys) {
  if (row is Map) {
    for (final k in keys) {
      final v = row[k];
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString());
    }
    return null;
  }

  // Objetos com getters (tentativas simples)
  for (final k in keys) {
    try {
      final v = (row as dynamic).__lookup(k);
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString());
    } catch (_) {}
  }

  return null;
}

/// Helper simples para tentar pegar propriedades comuns sem reflection pesada.
/// A ideia aqui é: tentar getters conhecidos. Se não existir, dá erro e cai no catch.
extension _Lookup on Object {
  dynamic __lookup(String k) {
    switch (k) {
      case 'pts':
      case 'pontos':
        return (this as dynamic).pts ?? (this as dynamic).pontos;
      case 'v':
      case 'vitorias':
        return (this as dynamic).v ?? (this as dynamic).vitorias;
      case 'e':
      case 'empates':
        return (this as dynamic).e ?? (this as dynamic).empates;
      case 'd':
      case 'derrotas':
        return (this as dynamic).d ?? (this as dynamic).derrotas;
      case 'gp':
      case 'golsPro':
      case 'gols_pro':
        return (this as dynamic).gp ??
            (this as dynamic).golsPro ??
            (this as dynamic).gols_pro;
      case 'gc':
      case 'golsContra':
      case 'gols_contra':
        return (this as dynamic).gc ??
            (this as dynamic).golsContra ??
            (this as dynamic).gols_contra;
      case 'saldo':
      case 'sg':
        return (this as dynamic).saldo ?? (this as dynamic).sg;
      case 'j':
      case 'jogos':
        return (this as dynamic).j ?? (this as dynamic).jogos;
      default:
        // tenta propriedade com mesmo nome
        return (this as dynamic).$k;
    }
  }
}
