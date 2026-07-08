// lib/pages/meu_clube/meu_clube_page.dart
//
// MVP: Meu Clube plugado no ClubSquadService
// - 2 abas: Profissional / Base
// - Lista real dos jogadores (inclui contratados do Mercado)

import 'package:flutter/material.dart';

import '../../models/jogador.dart';
import '../../services/club_squad_service.dart';

class MeuClubePage extends StatefulWidget {
  final String slug;

  const MeuClubePage({
    super.key,
    required this.slug,
  });

  @override
  State<MeuClubePage> createState() => _MeuClubePageState();
}

class _MeuClubePageState extends State<MeuClubePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pro = ClubSquadService.I.getProSquad(widget.slug);
    final base = ClubSquadService.I.getBaseSquad(widget.slug);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Clube'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Profissional'),
            Tab(text: 'Base'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _SquadList(
            title: 'Elenco Profissional',
            subtitle: '${pro.length} jogadores',
            players: pro,
            cs: cs,
          ),
          _SquadList(
            title: 'Elenco da Base',
            subtitle: '${base.length} jogadores',
            players: base,
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _SquadList extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Jogador> players;
  final ColorScheme cs;

  const _SquadList({
    required this.title,
    required this.subtitle,
    required this.players,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Center(
        child: Text(
          'Sem jogadores carregados.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      );
    }

    // ordena pra UX ficar boa
    final list = List<Jogador>.from(players);
    list.sort((a, b) {
      final pa = (a.posDet.isNotEmpty) ? a.posDet : a.pos;
      final pb = (b.posDet.isNotEmpty) ? b.posDet : b.pos;
      final c = pa.compareTo(pb);
      if (c != 0) return c;
      return a.nome.compareTo(b.nome);
    });

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...list.map((j) => _PlayerTile(jogador: j)),
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final Jogador jogador;

  const _PlayerTile({required this.jogador});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pos = jogador.posDet.isNotEmpty ? jogador.posDet : jogador.pos;
    final idade = jogador.idade;
    final anos = jogador.anosContrato;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  pos,
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jogador.nome,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$idade anos • Contrato: $anos ano(s)',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
