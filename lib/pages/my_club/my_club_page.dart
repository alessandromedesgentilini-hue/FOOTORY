import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/pages/my_club/player_details_page.dart';
import 'package:footory26/services/team_power_service.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

class MyClubPage extends ConsumerStatefulWidget {
  const MyClubPage({super.key});

  @override
  ConsumerState<MyClubPage> createState() => _MyClubPageState();
}

class _MyClubPageState extends ConsumerState<MyClubPage> {
  bool _checkpointDialogOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeShowCheckpointModal();
  }

  @override
  void didUpdateWidget(covariant MyClubPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeShowCheckpointModal();
  }

  void _maybeShowCheckpointModal() {
    if (_checkpointDialogOpen) return;

    final gs = ref.read(gameStateProvider);
    final cp = gs.pendingCheckpoint;

    if (cp == null) return;

    _checkpointDialogOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(cp.title),
            content: Text(cp.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      ref.read(gameStateProvider).consumePendingCheckpoint();

      _checkpointDialogOpen = false;
    });
  }

  String _fmtMoney(int value) {
    final negative = value < 0;
    final abs = value.abs();

    String raw;
    if (abs >= 1000000000) {
      raw = '${(abs / 1000000000).toStringAsFixed(1)} bi';
    } else if (abs >= 1000000) {
      raw = '${(abs / 1000000).toStringAsFixed(1)} mi';
    } else if (abs >= 1000) {
      raw = '${(abs / 1000).toStringAsFixed(0)} mil';
    } else {
      raw = '$abs';
    }

    return negative ? '-R\$ $raw' : 'R\$ $raw';
  }

  String _divisionLabel(String divisionId) {
    switch (divisionId) {
      case 'brA':
        return 'Liga BR A';
      case 'brB':
        return 'Liga BR B';
      case 'brC':
        return 'Liga BR C';
      case 'brD':
        return 'Liga BR D';
      default:
        return 'Liga Nacional';
    }
  }

  String _fmt10(int stars10) {
    return '${stars10.clamp(0, 10)} / 10';
  }

  @override
  Widget build(BuildContext context) {
    final GameState gs = ref.watch(gameStateProvider);

    if (!gs.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final squad = gs.getProSquad();

    const tp = TeamPowerService();

    final userPower10 = gs.clubPower10(gs.userClubId);
    final userStars10 = tp.stars10FromRating(userPower10);
    final userStars5 = tp.stars5FromStars10(userStars10);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Clube'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Column(
            children: [
              _ClubHeroCard(
                clubId: gs.userClubId,
                clubName: gs.userClubName,
                dateStr: gs.dateStr,
                division: _divisionLabel(gs.divisionId),
                seasonYear: gs.seasonYear,
                powerLabel: _fmt10(userStars10),
              ),
              const SizedBox(height: 8),
              _ClubResumeGrid(
                squadCount: squad.length,
                stars5: userStars5,
                balance: _fmtMoney(gs.userBalance),
                wage: _fmtMoney(gs.userMonthlyWage),
                structureLevel: gs.userComplexoLevel,
                coachLevel: gs.userCoachLevel,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _SquadPanel(
                  players: squad,
                  totalPlayers: squad.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClubHeroCard extends StatelessWidget {
  final String clubId;
  final String clubName;
  final String dateStr;
  final String division;
  final int seasonYear;
  final String powerLabel;

  const _ClubHeroCard({
    required this.clubId,
    required this.clubName,
    required this.dateStr,
    required this.division,
    required this.seasonYear,
    required this.powerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final club = BrazilClubCatalog.byId(clubId);
    final badgePath = club?.badgeAsset ?? 'assets/faces/_placeholder.png';

    return Container(
      height: 118,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.strongCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: AppColors.white.withOpacity(0.18),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                badgePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shield_rounded,
                  color: AppColors.white,
                  size: 42,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName.isEmpty ? 'Meu Clube' : clubName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$division • Temporada $seasonYear',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.94),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _HeroPill(label: dateStr),
                    const SizedBox(width: 6),
                    _HeroPill(label: 'Força $powerLabel'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.white.withOpacity(0.14),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _ClubResumeGrid extends StatelessWidget {
  final int squadCount;
  final int stars5;
  final String balance;
  final String wage;
  final int structureLevel;
  final int coachLevel;

  const _ClubResumeGrid({
    required this.squadCount,
    required this.stars5,
    required this.balance,
    required this.wage,
    required this.structureLevel,
    required this.coachLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _ResumeTile(
              icon: Icons.groups_rounded,
              label: 'Elenco',
              value: '$squadCount',
            ),
            const SizedBox(width: 7),
            _ResumeTile(
              icon: Icons.star_rounded,
              label: 'Estrelas',
              value: '$stars5 / 5',
            ),
            const SizedBox(width: 7),
            _ResumeTile(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Caixa',
              value: balance,
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            _ResumeTile(
              icon: Icons.payments_rounded,
              label: 'Salários',
              value: wage,
            ),
            const SizedBox(width: 7),
            _ResumeTile(
              icon: Icons.apartment_rounded,
              label: 'Estrutura',
              value: 'Nível $structureLevel',
            ),
            const SizedBox(width: 7),
            _ResumeTile(
              icon: Icons.groups_2_rounded,
              label: 'Comissão',
              value: 'Nível $coachLevel',
            ),
          ],
        ),
      ],
    );
  }
}

class _ResumeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResumeTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.13),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.055),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquadPanel extends StatelessWidget {
  final List<Player> players;
  final int totalPlayers;

  const _SquadPanel({
    required this.players,
    required this.totalPlayers,
  });

  List<_SquadListItem> _items() {
    final ordered = List<Player>.from(players);

    ordered.sort((a, b) {
      final aGroup = _positionGroupIndex(a.posLabel);
      final bGroup = _positionGroupIndex(b.posLabel);

      if (aGroup != bGroup) return aGroup.compareTo(bGroup);
      return b.ovrCheio.compareTo(a.ovrCheio);
    });

    final items = <_SquadListItem>[];
    String? currentGroup;

    for (final player in ordered) {
      final group = _positionGroupLabel(player.posLabel);

      if (group != currentGroup) {
        currentGroup = group;
        items.add(_SquadListItem.header(group));
      }

      items.add(_SquadListItem.player(player));
    }

    return items;
  }

  static int _positionGroupIndex(String pos) {
    final p = pos.toUpperCase();

    if (p.contains('GOL') || p == 'GK') return 0;
    if (p.contains('LAT') || p.contains('LD') || p.contains('LE')) return 1;
    if (p.contains('ZAG') || p == 'ZC' || p == 'CB') return 2;
    if (p.contains('VOL')) return 3;
    if (p == 'MC' || p.contains('MEI') || p == 'CAM' || p == 'CM') return 4;
    if (p.contains('PON') || p == 'PE' || p == 'PD' || p == 'LW' || p == 'RW') {
      return 5;
    }
    if (p.contains('ATA') || p == 'CA' || p == 'ST' || p == 'CF') return 6;

    return 7;
  }

  static String _positionGroupLabel(String pos) {
    final index = _positionGroupIndex(pos);

    switch (index) {
      case 0:
        return 'Goleiros';
      case 1:
        return 'Laterais';
      case 2:
        return 'Zagueiros';
      case 3:
        return 'Volantes';
      case 4:
        return 'Meias';
      case 5:
        return 'Pontas';
      case 6:
        return 'Atacantes';
      default:
        return 'Outros';
    }
  }

  void _openPlayerDetails(BuildContext context, Player player) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerDetailsPage(player: player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();

    return _PremiumSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            icon: Icons.groups_rounded,
            title: 'Elenco Principal',
            trailing: '$totalPlayers jogadores',
          ),
          const SizedBox(height: 8),
          Expanded(
            child: players.isEmpty
                ? const Center(
                    child: Text('Nenhum jogador encontrado.'),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      if (item.isHeader) {
                        return _PositionHeader(label: item.header!);
                      }

                      final player = item.player!;

                      return _PlayerCompactRow(
                        player: player,
                        onTap: () => _openPlayerDetails(context, player),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SquadListItem {
  final String? header;
  final Player? player;

  const _SquadListItem.header(this.header) : player = null;
  const _SquadListItem.player(this.player) : header = null;

  bool get isHeader => header != null;
}

class _PositionHeader extends StatelessWidget {
  final String label;

  const _PositionHeader({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
      ),
    );
  }
}

class _PlayerCompactRow extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const _PlayerCompactRow({
    required this.player,
    required this.onTap,
  });

  int _contractEndYear(Player player) {
    try {
      return (player as dynamic).contractEndYear as int;
    } catch (_) {
      return 2026;
    }
  }

  String _marketStatusLabel(Player player) {
    String raw;

    try {
      raw = ((player as dynamic).marketStatus).toString();
    } catch (_) {
      raw = 'normal';
    }

    raw = raw.split('.').last;

    switch (raw) {
      case 'transferListed':
        return 'À venda';
      case 'loanListed':
        return 'Empréstimo';
      case 'transferOrLoan':
        return 'Venda/Emp.';
      case 'untouchable':
        return 'Intransferível';
      case 'releasePlanned':
        return 'Rescisão';
      case 'normal':
      default:
        return 'Normal';
    }
  }

  Color _contractColor(Player player) {
    final year = _contractEndYear(player);

    if (year <= 2026) return Colors.redAccent;
    if (year == 2027) return Colors.orangeAccent;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final contractEndYear = _contractEndYear(player);
    final marketStatus = _marketStatusLabel(player);
    final contractColor = _contractColor(player);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.065),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              _PlayerFace(faceAsset: player.faceAsset),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '31/12/$contractEndYear • $marketStatus',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: contractColor,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _SmallTag(label: player.posLabel),
              const SizedBox(width: 6),
              _OvrBadge(value: player.ovrCheio),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerFace extends StatelessWidget {
  final String? faceAsset;

  const _PlayerFace({
    required this.faceAsset,
  });

  @override
  Widget build(BuildContext context) {
    final path = faceAsset;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: path == null || path.isEmpty
          ? const Icon(
              Icons.person_rounded,
              size: 22,
              color: AppColors.primary,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String label;

  const _SmallTag({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
      ),
    );
  }
}

class _OvrBadge extends StatelessWidget {
  final int value;

  const _OvrBadge({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _PremiumSurface extends StatelessWidget {
  final Widget child;

  const _PremiumSurface({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.13),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.065),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const _PanelTitle({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
          ),
        ),
        Text(
          trailing,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
