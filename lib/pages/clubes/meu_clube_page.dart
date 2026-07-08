// lib/pages/clubes/meu_clube_page.dart
//
// Tela "Meu Clube" (MVP) — com Header de status + Finanças (ClubeState real)
// + Acesso ao Departamento de Futebol
// + Acesso ao Mercado (scout mensal por filtros)
//
// - Usa GameState (ano/rodada/divisão/tabela) e ClubeState (finanças)
// - Mantém abas: Elenco (PRO) e Base (U18)
// - Elenco/Base continuam vindo do ClubSquadService (procedural)
//
// ✅ Correção importante:
// - Mostra MÊS atual e status da JANELA (Jan/Jul) no header,
//   usando SeasonClock que já existe em lib/services/world/season_clock.dart
// - Sem mudar estrutura/pastas. Sem duplicar SeasonClock.
//
// ✅ Posições novas:
// - Agora mostra POSIÇÃO DETALHADA (posDet) no elenco/base (LD/LE/ZAG/...)
// - Macro (pos) fica só para filtros/mercado.

import 'package:flutter/material.dart';

import '../../models/jogador.dart';
import '../../services/world/game_state.dart';
import '../../services/club_squad_service.dart';
import '../../services/world/season_clock.dart';

// Domínio
import '../../domain/models/clube_state.dart';

import 'jogador_page.dart';
import 'elenco_page.dart';
import 'departamento_futebol_page.dart';

// ✅ Mercado está em /pages/mercado
import '../mercado/mercado_page.dart';

class MeuClubePage extends StatelessWidget {
  final String slug; // id do clube
  final String? titulo; // opcional

  const MeuClubePage({
    super.key,
    required this.slug,
    this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;

    final bool isUserClub = slug == gs.userClubId;
    final nomeAppBar = isUserClub ? gs.userClubName : (titulo ?? slug);

    final ClubeState? cs = isUserClub ? gs.userClubState : gs.clubStateOf(slug);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(nomeAppBar),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Elenco'),
              Tab(text: 'Base'),
            ],
          ),
          actions: [
            if (cs != null && isUserClub)
              IconButton(
                tooltip: 'Mercado',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // ✅ FIX: MercadoPage agora exige clube
                      builder: (_) => MercadoPage(clube: cs),
                    ),
                  );
                },
                icon: const Icon(Icons.storefront_outlined),
              ),
            if (cs != null)
              IconButton(
                tooltip: 'Departamento de Futebol',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DepartamentoFutebolPage(clube: cs),
                    ),
                  );
                },
                icon: const Icon(Icons.apartment_outlined),
              ),
            IconButton(
              tooltip: 'Abrir gerador (Elenco / Base)',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ElencoPage()),
                );
              },
              icon: const Icon(Icons.build),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _MeuClubeHeader(slug: slug),
              const Divider(height: 1),
              Expanded(
                child: TabBarView(
                  children: [
                    _ElencoTab(isBase: false, clubeId: slug),
                    _ElencoTab(isBase: true, clubeId: slug),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// HEADER (status do clube + tabela + finanças)
/// =======================================================

class _MeuClubeHeader extends StatelessWidget {
  final String slug;
  const _MeuClubeHeader({required this.slug});

  @override
  Widget build(BuildContext context) {
    final gs = GameState.I;

    final bool isUser = slug == gs.userClubId;

    final String div = gs.divisionId;
    final int ano = gs.temporadaAno;
    final int rodada = gs.rodadaAtual;
    final int total = gs.totalRodadas;
    final bool encerrada = gs.temporadaEncerrada;

    final ClubeState? cs = isUser ? gs.userClubState : gs.clubStateOf(slug);

    final userRow =
        isUser ? _findUserRow(gs.tabela ?? const [], gs.userClubName) : null;

    final cal = _CalendarInfo.fromGameState(gs);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.emoji_events_outlined,
                  title: 'Temporada',
                  value: '$ano',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  icon: Icons.layers_outlined,
                  title: 'Divisão',
                  value: div,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  title: 'Rodada',
                  value: encerrada ? 'Encerrada' : '$rodada/$total',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.date_range_outlined,
                  title: 'Mês',
                  value: cal.mesLabel,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  icon: Icons.swap_horiz,
                  title: 'Janela',
                  value: cal.janelaAberta ? 'ABERTA (Jan/Jul)' : 'Fechada',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CardBox(
                  title: 'Tabela',
                  icon: Icons.table_chart_outlined,
                  child: isUser
                      ? _TabelaResumo(userRow: userRow)
                      : const Text(
                          'Resumo da tabela disponível apenas para o clube do usuário (MVP).',
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardBox(
                  title: 'Finanças',
                  icon: Icons.account_balance_wallet_outlined,
                  child: _FinanceResumo(clube: cs),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic>? _findUserRow(
    List<Map<String, dynamic>> tabela,
    String userClubName,
  ) {
    for (var i = 0; i < tabela.length; i++) {
      final r = tabela[i];
      final nome = (r['timeNome'] ?? '').toString();
      if (nome == userClubName) {
        return {
          ...r,
          'pos': i + 1,
        };
      }
    }
    return null;
  }
}

class _CalendarInfo {
  final String mesLabel;
  final bool janelaAberta;

  _CalendarInfo({
    required this.mesLabel,
    required this.janelaAberta,
  });

  factory _CalendarInfo.fromGameState(dynamic gs) {
    // Se no futuro o GameState expuser mesAtual/janelaAberta, isso aproveita
    try {
      final v = (gs as dynamic).mesAtual;
      if (v is int) {
        final label = _mesNomePt(v);
        final janela =
            _tryBool(() => (gs as dynamic).janelaTransferenciaAberta) ??
                _tryBool(() => (gs as dynamic).janelaAberta) ??
                false;
        return _CalendarInfo(mesLabel: label, janelaAberta: janela);
      }
    } catch (_) {}

    // ✅ Caminho padrão: SeasonClock (já existente)
    final int ano = _tryInt(() => (gs as dynamic).temporadaAno) ?? 2026;
    final int rodada = _tryInt(() => (gs as dynamic).rodadaAtual) ?? 1;
    const clock = SeasonClock();

    final mes = clock.monthForRound(ano: ano, rodada: rodada);
    final janela = clock.isTransferWindowOpen(ano: ano, rodada: rodada);

    return _CalendarInfo(
      mesLabel: _mesNomePt(mes),
      janelaAberta: janela,
    );
  }

  static int? _tryInt(int Function() fn) {
    try {
      return fn();
    } catch (_) {
      return null;
    }
  }

  static bool? _tryBool(bool Function() fn) {
    try {
      return fn();
    } catch (_) {
      return null;
    }
  }

  static String _mesNomePt(int m) {
    switch (m) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return '—';
    }
  }
}

class _TabelaResumo extends StatelessWidget {
  final Map<String, dynamic>? userRow;
  const _TabelaResumo({required this.userRow});

  @override
  Widget build(BuildContext context) {
    if (userRow == null) {
      return const Text('Ainda sem dados (simule ao menos uma rodada).');
    }

    final pos = userRow!['pos'] ?? '-';
    final pts = userRow!['pts'] ?? 0;
    final j = userRow!['j'] ?? 0;
    final v = userRow!['v'] ?? 0;
    final e = userRow!['e'] ?? 0;
    final d = userRow!['d'] ?? 0;
    final gp = userRow!['gp'] ?? 0;
    final gc = userRow!['gc'] ?? 0;
    final saldo = userRow!['saldo'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posição: $posº',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: [
            _MiniStat(label: 'PTS', value: '$pts'),
            _MiniStat(label: 'J', value: '$j'),
            _MiniStat(label: 'V', value: '$v'),
            _MiniStat(label: 'E', value: '$e'),
            _MiniStat(label: 'D', value: '$d'),
            _MiniStat(label: 'GP', value: '$gp'),
            _MiniStat(label: 'GC', value: '$gc'),
            _MiniStat(label: 'SG', value: '$saldo'),
          ],
        ),
      ],
    );
  }
}

class _FinanceResumo extends StatelessWidget {
  final ClubeState? clube;
  const _FinanceResumo({required this.clube});

  @override
  Widget build(BuildContext context) {
    if (clube == null) {
      return const Text('Sem dados financeiros (clube não encontrado).');
    }

    final cs = clube!;
    final saude = cs.labelSaudeFinanceira;
    final repasse = '${cs.percentualRepasse}%';
    final caixa = _fmtMoney(cs.financeiro.caixa);
    final divida = _fmtMoney(cs.financeiro.divida);
    final dividaLiquida = _fmtMoney(cs.dividaLiquida);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LineKV(
          label: 'Saúde',
          value: saude,
          valueStyle: TextStyle(
            fontWeight: FontWeight.w900,
            color: _colorSaude(context, cs.saudeFinanceira),
          ),
        ),
        const SizedBox(height: 6),
        _LineKV(label: 'Repasse', value: repasse),
        const SizedBox(height: 6),
        _LineKV(label: 'Caixa', value: caixa),
        const SizedBox(height: 6),
        _LineKV(label: 'Dívida', value: divida),
        const SizedBox(height: 6),
        _LineKV(label: 'Dívida líquida', value: dividaLiquida),
      ],
    );
  }

  Color _colorSaude(BuildContext context, SaudeFinanceira s) {
    final cs = Theme.of(context).colorScheme;
    switch (s) {
      case SaudeFinanceira.muitoBem:
        return cs.primary;
      case SaudeFinanceira.bem:
        return cs.tertiary;
      case SaudeFinanceira.razoavel:
        return cs.secondary;
      case SaudeFinanceira.mal:
        return Colors.orangeAccent;
      case SaudeFinanceira.criseAbsoluta:
        return Colors.redAccent;
    }
  }
}

String _fmtMoney(num v) {
  final n = v.round();
  if (n.abs() >= 1000000000) {
    final b = n / 1000000000.0;
    return 'R\$ ${b.toStringAsFixed(2)}B';
  }
  if (n.abs() >= 1000000) {
    final m = n / 1000000.0;
    return 'R\$ ${m.toStringAsFixed(1)}M';
  }
  if (n.abs() >= 1000) {
    final k = n / 1000.0;
    return 'R\$ ${k.toStringAsFixed(1)}k';
  }
  return 'R\$ $n';
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _CardBox({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LineKV extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _LineKV({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

/// =======================================================
/// ABAS (Elenco/Base)
/// =======================================================

class _ElencoTab extends StatefulWidget {
  final bool isBase;
  final String clubeId;

  const _ElencoTab({
    super.key,
    required this.isBase,
    required this.clubeId,
  });

  @override
  State<_ElencoTab> createState() => _ElencoTabState();
}

class _ElencoTabState extends State<_ElencoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final List<Jogador> jogadores = widget.isBase
        ? ClubSquadService.I.getBaseSquad(widget.clubeId)
        : ClubSquadService.I.getProSquad(widget.clubeId);

    if (jogadores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isBase
                    ? 'Base vazia.\nGere atletas U18 para este clube.'
                    : 'Elenco vazio.\nGere o elenco PRO para este clube.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir gerador (Elenco / Base)'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ElencoPage()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: jogadores.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final p = jogadores[i];

        // tenta pegar pelos getters atuais do seu Jogador, mas sem quebrar caso mude:
        final ovrCheio = _safeInt(() => (p as dynamic).ovrCheio) ?? 0;
        final estrelas = _safeDouble(() => (p as dynamic).estrelas) ?? 0.0;

        final facePath = _safeString(() => (p as dynamic).facePath) ??
            _safeString(() => (p as dynamic).faceAsset);
        final iniciais = _safeString(() => (p as dynamic).iniciais) ??
            (p.nome.isNotEmpty
                ? p.nome
                    .trim()
                    .split(' ')
                    .map((e) => e.isNotEmpty ? e[0] : '')
                    .take(2)
                    .join()
                : '?');

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: (facePath != null)
                ? Image.asset(
                    facePath,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      radius: 22,
                      child: Text(iniciais),
                    ),
                  )
                : CircleAvatar(
                    radius: 22,
                    child: Text(iniciais),
                  ),
          ),
          title: Text(p.nome, overflow: TextOverflow.ellipsis),
          subtitle: Text('${p.posDet} · ${_peLabel(p.pe)} · ${p.idade} anos'),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$ovrCheio',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                '${estrelas.toStringAsFixed(1)}★',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => JogadorPage(jogador: p),
              ),
            );
          },
        );
      },
    );
  }

  int? _safeInt(dynamic Function() fn) {
    try {
      final v = fn();
      if (v is int) return v;
      if (v is num) return v.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  double? _safeDouble(dynamic Function() fn) {
    try {
      final v = fn();
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _safeString(dynamic Function() fn) {
    try {
      final v = fn();
      if (v == null) return null;
      return v.toString();
    } catch (_) {
      return null;
    }
  }
}

String _peLabel(dynamic pe) {
  if (pe == null) return '-';
  try {
    final name = (pe as dynamic).name;
    if (name != null) return name.toString().toUpperCase();
  } catch (_) {}
  final s = pe.toString();
  if (s.contains('.')) return s.split('.').last.toUpperCase();
  return s.toUpperCase();
}
