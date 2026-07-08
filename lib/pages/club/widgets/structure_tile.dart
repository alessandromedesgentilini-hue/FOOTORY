import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/pages/club/widgets/structure_stars.dart';
import 'package:footory26/services/world/catalog/club_structures_catalog.dart';
import 'package:footory26/services/world/catalog/structure_costs_catalog.dart';
import 'package:footory26/services/world/catalog/structure_effects_catalog.dart';
import 'package:footory26/services/world/catalog/structure_messages_catalog.dart';

class StructureTile extends StatelessWidget {
  final ClubStructureType type;
  final int level;
  final bool canUpgradeByGameRule;
  final int userBalanceMi;
  final VoidCallback onUpgrade;

  const StructureTile({
    super.key,
    required this.type,
    required this.level,
    required this.canUpgradeByGameRule,
    required this.userBalanceMi,
    required this.onUpgrade,
  });

  int _starsFromLevel(int level) {
    if (level <= 2) return 1;
    if (level <= 4) return 2;
    if (level <= 6) return 3;
    if (level <= 8) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final nextLevel = level < 10 ? level + 1 : 10;
    final canUpgradeByCostRule = StructureCostsCatalog.canUpgrade(level);

    final currentMaintenance =
        StructureCostsCatalog.getMonthlyMaintenance(type, level);
    final nextUpgradeCost = StructureCostsCatalog.getUpgradeCost(type, level);
    final nextUpgradeCostMi = (nextUpgradeCost / 1000000).round();
    final effectText = StructureEffectsCatalog.effectOf(type, level);
    final stars = _starsFromLevel(level);

    final chipColor = _statusColor(level);
    final hasEnoughMoney = userBalanceMi >= nextUpgradeCostMi;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  _iconFor(type),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StructureCostsCatalog.labelOf(type),
                      style: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nível $level',
                      style: t.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StructureStars(filled: stars, size: 17),
                    const SizedBox(height: 6),
                    Text(
                      effectText,
                      style: t.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  StructureMessagesCatalog.shortStatus(level),
                  style: t.labelMedium?.copyWith(
                    color: chipColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniInfo(
                  context,
                  'Manutenção',
                  '${_money(currentMaintenance)}/mês',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniInfo(
                  context,
                  canUpgradeByCostRule ? 'Próximo nível' : 'Status',
                  canUpgradeByCostRule ? '$nextLevel' : 'Máximo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniInfo(
                  context,
                  'Custo upgrade',
                  canUpgradeByCostRule ? _money(nextUpgradeCost) : '—',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniInfo(
                  context,
                  'Caixa necessário',
                  canUpgradeByCostRule ? _moneyMi(nextUpgradeCostMi) : '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (canUpgradeByCostRule && !hasEnoughMoney)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Saldo insuficiente para evoluir agora.',
                  style: t.bodySmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: canUpgradeByCostRule && canUpgradeByGameRule
                        ? onUpgrade
                        : null,
                    child: Text(
                      !canUpgradeByCostRule
                          ? 'Máximo'
                          : !canUpgradeByGameRule &&
                                  type != ClubStructureType.complexo
                              ? 'Bloqueado'
                              : !hasEnoughMoney
                                  ? 'Sem caixa'
                                  : 'Evoluir',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(BuildContext context, String label, String value) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: t.labelLarge?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ClubStructureType type) {
    switch (type) {
      case ClubStructureType.complexo:
        return Icons.domain_rounded;
      case ClubStructureType.ct:
        return Icons.fitness_center_rounded;
      case ClubStructureType.base:
        return Icons.groups_rounded;
      case ClubStructureType.scout:
        return Icons.travel_explore_rounded;
      case ClubStructureType.financeiro:
        return Icons.account_balance_wallet_rounded;
      case ClubStructureType.marketing:
        return Icons.campaign_rounded;
      case ClubStructureType.comunicacao:
        return Icons.mic_rounded;
      case ClubStructureType.medico:
        return Icons.medical_services_rounded;
      case ClubStructureType.estadio:
        return Icons.stadium_rounded;
    }
  }

  Color _statusColor(int level) {
    if (level >= 10) return AppColors.primary;
    if (level >= 8) return AppColors.accentDark;
    if (level >= 4) return AppColors.success;
    return AppColors.textSecondary;
  }

  String _money(int value) {
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

  String _moneyMi(int value) {
    return 'R\$ $value mi';
  }
}
