import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/data/staff_department_data.dart';
import 'package:footory26/models/staff_department.dart';
import 'package:footory26/pages/club/widgets/staff_avatar.dart';
import 'package:footory26/pages/club/widgets/structure_stars.dart';
import 'package:footory26/pages/club/widgets/structure_tile.dart';
import 'package:footory26/services/world/catalog/club_structures_catalog.dart';
import 'package:footory26/services/world/catalog/structure_costs_catalog.dart';
import 'package:footory26/services/world/catalog/structure_effects_catalog.dart';
import 'package:footory26/services/world/catalog/structure_messages_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

class StructuresPage extends ConsumerWidget {
  const StructuresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState gs = ref.watch(gameStateProvider);

    if (!gs.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentLevels = <ClubStructureType, int>{
      ClubStructureType.complexo: gs.userComplexoLevel,
      ClubStructureType.ct: gs.userCtLevel,
      ClubStructureType.base: gs.userBaseLevel,
      ClubStructureType.scout: gs.userScoutLevel,
      ClubStructureType.financeiro: gs.userFinanceiroLevel,
      ClubStructureType.marketing: gs.userMarketingLevel,
      ClubStructureType.comunicacao: gs.userComunicacaoLevel,
      ClubStructureType.medico: gs.userMedicoLevel,
      ClubStructureType.estadio: gs.userStadiumLevel,
    };

    final totalMaintenance =
        StructureCostsCatalog.getTotalMonthlyMaintenance(currentLevels);

    final categories = <_StructureCategory>[
      const _StructureCategory(
        title: 'Estruturas Esportivas',
        subtitle: 'Base física do projeto esportivo.',
        icon: Icons.sports_soccer_rounded,
        types: [
          ClubStructureType.complexo,
          ClubStructureType.ct,
          ClubStructureType.base,
        ],
      ),
      const _StructureCategory(
        title: 'Gestão Esportiva',
        subtitle: 'Captação, saúde e suporte ao elenco.',
        icon: Icons.manage_search_rounded,
        types: [
          ClubStructureType.scout,
          ClubStructureType.medico,
        ],
      ),
      const _StructureCategory(
        title: 'Gestão Administrativa',
        subtitle: 'Receita, imagem e comunicação do clube.',
        icon: Icons.business_center_rounded,
        types: [
          ClubStructureType.financeiro,
          ClubStructureType.marketing,
          ClubStructureType.comunicacao,
        ],
      ),
      const _StructureCategory(
        title: 'Infraestrutura',
        subtitle: 'Casa do clube e experiência de jogo.',
        icon: Icons.stadium_rounded,
        types: [
          ClubStructureType.estadio,
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Estruturas'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 18),
          children: [
            _StructuresHeroCard(
              clubName: gs.userClubName,
              dateStr: gs.dateStr,
              structuralPower: gs.userStructuralPower,
              maintenance: totalMaintenance,
              balanceMi: gs.userBalance,
            ),
            const SizedBox(height: 8),
            _StructuresDashboard(
              structures: gs.userClubStructures,
              totalMaintenance: totalMaintenance,
              balanceMi: gs.userBalance,
              totalFixedCostMi: gs.userTotalMonthlyFixedCost,
            ),
            const SizedBox(height: 8),
            for (final category in categories) ...[
              _StructureCategoryPanel(
                category: category,
                currentLevels: currentLevels,
                userBalanceMi: gs.userBalance,
                canUpgrade: (type) => gs.canUpgradeStructure(type),
                onUpgrade: (type, level) async {
                  await _showUpgradeFlow(context, ref, gs, type, level);
                },
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showUpgradeFlow(
    BuildContext context,
    WidgetRef ref,
    GameState gs,
    ClubStructureType type,
    int currentLevel,
  ) async {
    final atAbsoluteMax = !StructureCostsCatalog.canUpgrade(currentLevel);
    if (atAbsoluteMax) {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Nível máximo'),
            content: Text(
              '${StructureCostsCatalog.labelOf(type)} já atingiu o nível máximo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final blockedByComplexo = !gs.canUpgradeStructure(type);
    if (blockedByComplexo) {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Estrutura bloqueada'),
            content: Text(
              type == ClubStructureType.complexo
                  ? 'Esta estrutura não pode ser evoluída agora.'
                  : 'Você precisa melhorar primeiro o Complexo Esportivo para continuar evoluindo ${StructureCostsCatalog.labelOf(type)}.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final nextLevel = currentLevel + 1;
    final upgradeCost =
        StructureCostsCatalog.getUpgradeCost(type, currentLevel);
    final currentMaintenance =
        StructureCostsCatalog.getMonthlyMaintenance(type, currentLevel);
    final nextMaintenance =
        StructureCostsCatalog.getMonthlyMaintenance(type, nextLevel);

    final upgradeCostMi = _toMi(upgradeCost);
    final userBalanceMi = gs.userBalance;
    final remainingAfterUpgrade = userBalanceMi - upgradeCostMi;
    final hasEnoughMoney = userBalanceMi >= upgradeCostMi;

    final currentEffect = StructureEffectsCatalog.effectOf(type, currentLevel);
    final nextEffect = StructureEffectsCatalog.effectOf(type, nextLevel);

    final staff = getStaffByDepartment(type.toDepartmentType());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        final fallbackLetter =
            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?';

        Widget sectionTitle(String text) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              text,
              style: t.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
          );
        }

        return AlertDialog(
          title: Text('Evoluir ${StructureCostsCatalog.labelOf(type)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StaffAvatar(
                        assetPath: staff.faceAsset,
                        fallbackLetter: fallbackLetter,
                        radius: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff.name,
                              style: t.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              staff.role,
                              style: t.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                sectionTitle('Nível atual: $currentLevel'),
                Text(
                  currentEffect,
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                sectionTitle('Próximo nível: $nextLevel'),
                Text(
                  nextEffect,
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Custo do upgrade: ${_money(upgradeCost)}',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Equivalente financeiro: ${_moneyMi(upgradeCostMi)}',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saldo atual do clube: ${_moneyMi(userBalanceMi)}',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saldo após upgrade: ${_moneyMi(remainingAfterUpgrade)}',
                  style: t.bodyMedium?.copyWith(
                    color: hasEnoughMoney
                        ? AppColors.textSecondary
                        : AppColors.danger,
                    fontWeight:
                        hasEnoughMoney ? FontWeight.w500 : FontWeight.w900,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manutenção: ${_money(currentMaintenance)}/mês → ${_money(nextMaintenance)}/mês',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                if (!hasEnoughMoney)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.danger.withOpacity(0.28),
                      ),
                    ),
                    child: Text(
                      'Saldo insuficiente para esta evolução. O clube precisa de pelo menos ${_moneyMi(upgradeCostMi)} disponíveis.',
                      style: t.bodyMedium?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),
                if (hasEnoughMoney) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Essa decisão não poderá ser revertida.',
                    style: t.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed:
                  hasEnoughMoney ? () => Navigator.of(ctx).pop(true) : null,
              child: const Text('Evoluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final upgraded = ref.read(gameStateProvider).upgradeUserStructure(type);
    if (!upgraded) {
      if (!context.mounted) return;

      final freshGs = ref.read(gameStateProvider);
      final stillHasEnoughMoney = freshGs.userBalance >= upgradeCostMi;

      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              stillHasEnoughMoney
                  ? 'Estrutura bloqueada'
                  : 'Saldo insuficiente',
            ),
            content: Text(
              stillHasEnoughMoney
                  ? (type == ClubStructureType.complexo
                      ? 'Esta estrutura não pode ser evoluída agora.'
                      : 'O Complexo Esportivo ainda limita essa evolução. Melhore primeiro o Complexo para liberar novos níveis.')
                  : 'O clube não possui caixa suficiente para pagar ${_moneyMi(upgradeCostMi)} neste upgrade.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            StructureMessagesCatalog.upgradeTitle(type, nextLevel),
          ),
          content: Text(
            '${StructureMessagesCatalog.upgradeMessage(type, nextLevel)}\n\n'
            'O clube investiu ${_moneyMi(upgradeCostMi)} nesta evolução.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static int _toMi(int rawValue) {
    return (rawValue / 1000000).round();
  }

  static String _money(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return 'R\$ ${buffer.toString().split('').reversed.join()}';
  }

  static String _moneyMi(int value) {
    return 'R\$ $value mi';
  }
}

class _StructuresHeroCard extends StatelessWidget {
  final String clubName;
  final String dateStr;
  final double structuralPower;
  final int maintenance;
  final int balanceMi;

  const _StructuresHeroCard({
    required this.clubName,
    required this.dateStr,
    required this.structuralPower,
    required this.maintenance,
    required this.balanceMi,
  });

  int _starsFromPower(double value) {
    final level = value.round().clamp(1, 10);
    if (level <= 2) return 1;
    if (level <= 4) return 2;
    if (level <= 6) return 3;
    if (level <= 8) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stars = _starsFromPower(structuralPower);
    final status = StructureMessagesCatalog.phaseLabel(
      structuralPower.round().clamp(1, 10),
    );

    return Container(
      height: 124,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.white.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: AppColors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName.isEmpty ? 'Estruturas do Clube' : clubName,
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
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.94),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StructureStars(
                      filled: stars,
                      size: 16,
                      activeColor: AppColors.white,
                      inactiveColor: AppColors.white.withOpacity(0.35),
                    ),
                    const SizedBox(width: 8),
                    _HeroPill(label: dateStr),
                    const SizedBox(width: 6),
                    _HeroPill(
                      label: structuralPower.toStringAsFixed(1),
                    ),
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

class _StructuresDashboard extends StatelessWidget {
  final ClubStructures structures;
  final int totalMaintenance;
  final int balanceMi;
  final int totalFixedCostMi;

  const _StructuresDashboard({
    required this.structures,
    required this.totalMaintenance,
    required this.balanceMi,
    required this.totalFixedCostMi,
  });

  int _starsFromLevel(double structuralPower) {
    final level = structuralPower.round().clamp(1, 10);
    if (level <= 2) return 1;
    if (level <= 4) return 2;
    if (level <= 6) return 3;
    if (level <= 8) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final stars = _starsFromLevel(structures.structuralPower);
    final status = StructureMessagesCatalog.phaseLabel(
      structures.structuralPower.round().clamp(1, 10),
    );

    return Column(
      children: [
        Row(
          children: [
            _DashboardTile(
              icon: Icons.bolt_rounded,
              label: 'Poder',
              value: structures.structuralPower.toStringAsFixed(1),
              tail: StructureStars(filled: stars, size: 12),
            ),
            const SizedBox(width: 7),
            _DashboardTile(
              icon: Icons.workspace_premium_rounded,
              label: 'Status',
              value: status,
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            _DashboardTile(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Caixa',
              value: _moneyMi(balanceMi),
            ),
            const SizedBox(width: 7),
            _DashboardTile(
              icon: Icons.payments_rounded,
              label: 'Manutenção',
              value: _money(totalMaintenance),
            ),
            const SizedBox(width: 7),
            _DashboardTile(
              icon: Icons.receipt_long_rounded,
              label: 'Custo fixo',
              value: _moneyMi(totalFixedCostMi),
            ),
          ],
        ),
      ],
    );
  }

  static String _money(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return 'R\$ ${buffer.toString().split('').reversed.join()}';
  }

  static String _moneyMi(int value) {
    return 'R\$ $value mi';
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? tail;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.value,
    this.tail,
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
            if (tail != null) ...[
              const SizedBox(width: 4),
              tail!,
            ],
          ],
        ),
      ),
    );
  }
}

class _StructureCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<ClubStructureType> types;

  const _StructureCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.types,
  });
}

class _StructureCategoryPanel extends StatelessWidget {
  final _StructureCategory category;
  final Map<ClubStructureType, int> currentLevels;
  final int userBalanceMi;
  final bool Function(ClubStructureType type) canUpgrade;
  final Future<void> Function(ClubStructureType type, int level) onUpgrade;

  const _StructureCategoryPanel({
    required this.category,
    required this.currentLevels,
    required this.userBalanceMi,
    required this.canUpgrade,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryTitle(
            icon: category.icon,
            title: category.title,
            subtitle: category.subtitle,
          ),
          const SizedBox(height: 10),
          for (final type in category.types) ...[
            StructureTile(
              type: type,
              level: currentLevels[type] ?? 1,
              canUpgradeByGameRule: canUpgrade(type),
              userBalanceMi: userBalanceMi,
              onUpgrade: () async {
                await onUpgrade(type, currentLevels[type] ?? 1);
              },
            ),
            if (type != category.types.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CategoryTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
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

extension _ClubStructureTypeDepartmentMapper on ClubStructureType {
  DepartmentType toDepartmentType() {
    switch (this) {
      case ClubStructureType.complexo:
        return DepartmentType.sportsComplex;
      case ClubStructureType.ct:
        return DepartmentType.trainingCenter;
      case ClubStructureType.base:
        return DepartmentType.academy;
      case ClubStructureType.scout:
        return DepartmentType.scouting;
      case ClubStructureType.financeiro:
        return DepartmentType.finance;
      case ClubStructureType.marketing:
        return DepartmentType.marketing;
      case ClubStructureType.comunicacao:
        return DepartmentType.communication;
      case ClubStructureType.medico:
        return DepartmentType.medical;
      case ClubStructureType.estadio:
        return DepartmentType.stadium;
    }
  }
}
