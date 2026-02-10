// lib/pages/home/home_page.dart
//
// HOME MVP - Footory
// Tema claro, grid com ícones, botão AVANÇAR destacado.

import 'package:flutter/material.dart';

import '../../services/world/game_state.dart';

// Domínio (pra passar ClubeState no Mercado)
import '../../domain/models/clube_state.dart';

// Pages
import '../meu_clube/meu_clube_page.dart';
import '../mercado/mercado_page.dart';
import '../evolucao/evolucao_page.dart';
import '../estruturas/estruturas_page.dart';
import '../financas/financas_page.dart';
import '../competicoes/competicoes_page.dart';
import '../base/base_page.dart';
import '../inbox/caixa_entrada_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String get _clubId => GameState.I.userClubId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final clubName = _safeReadClubName();
    final division = _safeReadDivision();
    final dateStr = _safeReadDateStr();
    final isMatchDay = _safeReadIsMatchDay();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FOOTORY'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () => _showConfig(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Header do clube
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                _clubBadge(cs),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clubName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Divisão: $division',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isMatchDay ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                      if (isMatchDay) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'DIA DE JOGO',
                            style: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Botão AVANÇAR (destaque)
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'AVANÇAR',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              onPressed: () async {
                await GameState.I.avancarUmDia();
                if (!mounted) return;
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Grid de ícones
          _grid(context),

          const SizedBox(height: 16),

          // Rodapé (debug)
          Text(
            'ClubId: $_clubId',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context) {
    final items = <_HomeItem>[
      _HomeItem(
        title: 'Meu Clube',
        icon: Icons.groups_rounded,
        onTap: () {
          final slug = GameState.I.userClubId;
          _go(context, MeuClubePage(slug: slug));
        },
      ),
      _HomeItem(
        title: 'Mercado',
        icon: Icons.swap_horiz_rounded,
        onTap: () {
          final ClubeState? clube = GameState.I.userClubState;
          if (clube == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Clube do usuário ainda não carregado.'),
              ),
            );
            return;
          }
          _go(context, MercadoPage(clube: clube));
        },
      ),
      _HomeItem(
        title: 'Evolução',
        icon: Icons.trending_up_rounded,
        onTap: () => _go(context, const EvolucaoPage()),
      ),
      _HomeItem(
        title: 'Estruturas',
        icon: Icons.account_balance_rounded,
        onTap: () => _go(context, const EstruturasPage()),
      ),
      _HomeItem(
        title: 'Finanças',
        icon: Icons.attach_money_rounded,
        onTap: () => _go(context, const FinancasPage()),
      ),
      _HomeItem(
        title: 'Competições',
        icon: Icons.emoji_events_rounded,
        onTap: () => _go(context, const CompeticoesPage()),
      ),
      _HomeItem(
        title: 'Base',
        icon: Icons.school_rounded,
        onTap: () => _go(context, const BasePage()),
      ),
      _HomeItem(
        title: 'Caixa Entrada',
        icon: Icons.inbox_rounded,
        onTap: () => _go(context, const CaixaEntradaPage()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (_, i) => _HomeTile(item: items[i]),
    );
  }

  Widget _clubBadge(ColorScheme cs) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.shield_rounded,
        color: cs.onPrimaryContainer,
        size: 30,
      ),
    );
  }

  void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showConfig(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Configurações (MVP)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Depois ligamos tema, idioma e opções premium aqui.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // Leitura segura do GameState
  // -------------------------

  String _safeReadClubName() {
    try {
      final v = GameState.I.userClubName;
      if (v.trim().isNotEmpty) return v;
    } catch (_) {}
    return 'Meu Clube';
  }

  String _safeReadDivision() {
    try {
      final v = GameState.I.divisionId;
      if (v.trim().isNotEmpty) return v;
    } catch (_) {}
    return 'D';
  }

  String _safeReadDateStr() {
    try {
      return GameState.I.dataStr;
    } catch (_) {}
    return '—';
  }

  bool _safeReadIsMatchDay() {
    try {
      return GameState.I.isMatchDay;
    } catch (_) {}
    return false;
  }
}

class _HomeItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _HomeItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class _HomeTile extends StatelessWidget {
  final _HomeItem item;
  const _HomeTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 26),
            const SizedBox(height: 6),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
