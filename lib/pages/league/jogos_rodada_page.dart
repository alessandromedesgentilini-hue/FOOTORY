// lib/pages/league/jogos_rodada_page.dart
//
// Jogos da Rodada — versão final robusta e tolerante a diferenças de API.
// - Lê GameState de forma segura (dynamic) e funciona com branches diferentes.
// - Tenta gs.jogosDaRodada(r); se não houver, filtra gs.partidas por rodada.
// - totalRodadas: usa gs.totalRodadas ou calcula pelo maior "rodada" das partidas.
// - Exibe nomes de times a partir de TimeModel, String ou Map.
// - Mostra placar somente quando houver indicação de partida finalizada
//   (status="finalizada"/isFinalizada) ou quando houver gols diferentes de null.
//
// Requisitos: GameState exposto em services/world/game_state.dart.

import 'package:flutter/material.dart';
import '../../services/world/game_state.dart';

class JogosRodadaPage extends StatefulWidget {
  const JogosRodadaPage({super.key});

  @override
  State<JogosRodadaPage> createState() => _JogosRodadaPageState();
}

class _JogosRodadaPageState extends State<JogosRodadaPage> {
  int _rodSel = 1;

  @override
  void initState() {
    super.initState();
    final dynamic gs = GameState.I;
    final total = _safeTotalRodadas(gs);
    final atual = _safeRodadaAtual(gs) ?? 1;
    _rodSel = _clamp(atual, 1, total > 0 ? total : 1);
  }

  @override
  Widget build(BuildContext context) {
    final dynamic gs = GameState.I;

    final total = _safeTotalRodadas(gs);
    final jogos = _jogosDaRodada(gs, _rodSel);

    return Scaffold(
      appBar: AppBar(title: const Text('Jogos da Rodada')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 12),
              const Text('Rodada:  '),
              DropdownButton<int>(
                value: _rodSel,
                items: List.generate(
                  total > 0 ? total : 1,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1} / ${total > 0 ? total : 1}'),
                  ),
                ),
                onChanged: (v) => setState(() => _rodSel = v ?? 1),
              ),
            ],
          ),
          Expanded(
            child: jogos.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nenhum jogo encontrado para esta rodada.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (_, i) {
                      final j = jogos[i];
                      final mand = _nomeTime(_getMandante(j));
                      final vis = _nomeTime(_getVisitante(j));
                      final placar = _placarSeguro(j);

                      return ListTile(
                        title: Text('$mand  vs  $vis'),
                        subtitle: Text('Rodada $_rodSel'),
                        trailing: Text(placar),
                      );
                    },
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.white.withOpacity(0.06)),
                    itemCount: jogos.length,
                  ),
          ),
        ],
      ),
    );
  }

  // ======== Safe GS access ========

  int _safeTotalRodadas(dynamic gs) {
    // 1) propriedade direta
    try {
      final v = gs.totalRodadas;
      if (v is int && v > 0) return v;
    } catch (_) {}

    // 2) método
    try {
      final v = gs.totalRodadas();
      if (v is int && v > 0) return v;
    } catch (_) {}

    // 3) derivar de partidas
    final parts = _todasPartidas(gs);
    if (parts.isNotEmpty) {
      int maxRod = 0;
      for (final p in parts) {
        final r = _readRodada(p);
        if (r != null && r > maxRod) maxRod = r;
      }
      if (maxRod > 0) return maxRod;
    }

    // fallback
    return 1;
  }

  int? _safeRodadaAtual(dynamic gs) {
    try {
      final v = gs.rodadaAtual;
      if (v is int) return v;
    } catch (_) {}
    try {
      final v = gs.rodadaAtual();
      if (v is int) return v;
    } catch (_) {}
    return null;
  }

  List _jogosDaRodada(dynamic gs, int r) {
    // 1) método direto
    try {
      final v = gs.jogosDaRodada(r);
      if (v is List) return v;
    } catch (_) {}

    // 2) derivar filtrando todas as partidas
    final all = _todasPartidas(gs);
    if (all.isNotEmpty) {
      return all.where((p) => _readRodada(p) == r).toList();
    }

    return const [];
  }

  List _todasPartidas(dynamic gs) {
    try {
      final v = gs.partidas;
      if (v is List) return v;
    } catch (_) {}
    try {
      final v = gs.calendar; // alguns branches
      if (v is List) return v;
    } catch (_) {}
    return const [];
  }

  // ======== Safe readers (Partida-like) ========

  int? _readRodada(dynamic p) {
    // PartidaModel.rodada (int)
    try {
      final v = (p as dynamic).rodada;
      if (v is int) return v;
    } catch (_) {}
    // Map['rodada']
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
    // TimeModel.nome
    try {
      final n = (t as dynamic).nome;
      if (n is String && n.isNotEmpty) return n;
    } catch (_) {}
    // Map['nome']
    try {
      final n = (t as Map)['nome'];
      if (n is String && n.isNotEmpty) return n;
    } catch (_) {}
    return t.toString();
  }

  int? _readGols(dynamic p, {required bool mandante}) {
    final keys = mandante
        ? ['golsMandante', 'gm', 'mandanteGols']
        : ['golsVisitante', 'gv', 'visitanteGols'];

    // dynamic property
    for (final k in keys) {
      try {
        final v = (p as dynamic).__getterHack(k);
        if (v is int) return v;
        if (v != null) return int.tryParse(v.toString());
      } catch (_) {}
    }

    // Map
    try {
      for (final k in keys) {
        final v = (p as Map)[k];
        if (v is int) return v;
        if (v != null) return int.tryParse(v.toString());
      }
    } catch (_) {}

    // PartidaModel conhecido (acesso direto sem reflection)
    try {
      if (mandante) return (p as dynamic).golsMandante as int;
      return (p as dynamic).golsVisitante as int;
    } catch (_) {}

    return null;
  }

  bool _isFinalizada(dynamic p) {
    // PartidaModel: status == finalizada
    try {
      final s = (p as dynamic).status;
      final name = s is Enum ? s.name : s?.toString();
      if (name == 'finalizada') return true;
    } catch (_) {}
    // Map['status']
    try {
      final s = (p as Map)['status']?.toString();
      if (s == 'finalizada') return true;
    } catch (_) {}

    // Heurística: tem gols e finalizações (evita 0x0 agendado)
    final gm = _readGols(p, mandante: true);
    final gv = _readGols(p, mandante: false);
    if (gm != null && gv != null) {
      // Se há gols diferentes de null e pelo menos um > 0, consideramos finalizado
      if (gm > 0 || gv > 0) return true;
    }
    return false;
  }

  String _placarSeguro(dynamic p) {
    final gm = _readGols(p, mandante: true);
    final gv = _readGols(p, mandante: false);

    if (gm == null || gv == null) return '';
    // Se 0x0 mas não temos certeza de status, ocultar
    if (gm == 0 && gv == 0 && !_isFinalizada(p)) return '';
    return '$gm x $gv';
  }

  // ======== Utils ========

  int _clamp(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);
}

// ─────────────────────────────────────────────────────────────────────────────
// Pequeno hack para tentar pegar propriedades dinâmicas por nome sem mirrors.
// Usamos getters comuns quando o objeto expõe; se não, isso não causa efeito.
// ─────────────────────────────────────────────────────────────────────────────
extension on Object {
  dynamic __getterHack(String name) {
    // Não há acesso por string a propriedades em Dart sem mirrors.
    // Mantemos esse método apenas para evitar crashes no try/catch acima.
    throw UnimplementedError();
  }
}
