import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/coach_staff.dart';
import 'package:footory26/pages/coach/widgets/coach_common_widgets.dart';
import 'package:footory26/pages/coach/widgets/coach_staff_widgets.dart';
import 'package:footory26/pages/coach/widgets/coach_tactical_widgets.dart';
import 'package:footory26/services/world/catalog/coach_tactical_catalog.dart';

class CoachPage extends ConsumerWidget {
  const CoachPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gs = ref.watch(gameStateProvider);

    if (!gs.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final staff = gs.selectedCoachStaffOrFallback;
    final identity = CoachTacticalCatalog.fromId(staff.tacticalIdentityId);

    final level = gs.userCoachLevel.clamp(1, 10);
    final complexLevel = gs.userComplexoLevel.clamp(1, 10);
    final bonusPct = _coachBonusPct(level);
    final clubName = gs.userClubName.isEmpty ? 'Meu Clube' : gs.userClubName;

    final prestigeStars = _prestigeStars(level);
    final prestigeLabel = _prestigeLabel(level);
    final salary = _salaryByLevel(level);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Comissão Técnica'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Column(
            children: [
              _CoachHeroCard(
                clubName: clubName,
                coach: staff.coach,
                styleLabel: identity.name,
                level: level,
                prestigeLabel: prestigeLabel,
              ),
              const SizedBox(height: 8),
              _CoachQuickGrid(
                level: level,
                prestigeStars: prestigeStars,
                prestigeLabel: prestigeLabel,
                bonusPct: bonusPct,
                license: _licenseLabel(level),
                complexLevel: complexLevel,
                monthlySalary: salary,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _PremiumSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _PanelTitle(
                        icon: Icons.manage_accounts_rounded,
                        title: 'Centro da Comissão',
                        trailing: 'perfil completo',
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            _Block(
                              title: 'Contrato e Custo',
                              icon: Icons.description_outlined,
                              child: Column(
                                children: [
                                  CoachInfoRow(
                                    icon: Icons.calendar_month_rounded,
                                    label: 'Contrato',
                                    value: '31/12/${staff.contractEndYear}',
                                  ),
                                  const SizedBox(height: 10),
                                  CoachInfoRow(
                                    icon: Icons.payments_rounded,
                                    label: 'Salário mensal',
                                    value: _fmtMoney(salary),
                                  ),
                                  const SizedBox(height: 10),
                                  CoachInfoRow(
                                    icon: Icons.star_rounded,
                                    label: 'Prestígio',
                                    value:
                                        '${_starsText(prestigeStars)} $prestigeLabel',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Block(
                              title: 'Comissão Atual',
                              icon: Icons.groups_rounded,
                              child: Column(
                                children: [
                                  CoachAssistantTile(member: staff.assistant1),
                                  const SizedBox(height: 10),
                                  CoachAssistantTile(member: staff.assistant2),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Block(
                              title: 'Identidade Tática',
                              icon: Icons.auto_awesome_rounded,
                              child: Column(
                                children: [
                                  CoachIdentityRow(
                                    label: 'Estilo',
                                    value: identity.name,
                                    icon: Icons.sports_soccer_rounded,
                                  ),
                                  const SizedBox(height: 10),
                                  CoachIdentityRow(
                                    label: 'Resumo',
                                    value: identity.shortDescription,
                                    icon: Icons.description_outlined,
                                  ),
                                  const SizedBox(height: 10),
                                  CoachIdentityRow(
                                    label: 'Filosofia',
                                    value: identity.philosophyDescription,
                                    icon: Icons.psychology_alt_outlined,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Block(
                              title: 'Formações Preferidas',
                              icon: Icons.account_tree_outlined,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CoachFormationLine(
                                    label: 'Principal',
                                    formation: identity.mainFormation,
                                    highlighted: true,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Alternativas',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: identity.secondaryFormations
                                        .map(
                                          (f) => CoachFormationChip(
                                            formation: f,
                                            highlighted: false,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Block(
                              title: 'Comportamento em Campo',
                              icon: Icons.query_stats_rounded,
                              child: CoachTacticalBiasGrid(identity: identity),
                            ),
                            const SizedBox(height: 8),
                            _Block(
                              title: 'Evolução da Comissão',
                              icon: Icons.school_rounded,
                              child: _CoachEvolutionPanel(
                                level: level,
                                complexLevel: complexLevel,
                                balance: gs.userBalance,
                                bonusPct: bonusPct,
                                onUpgrade: () {
                                  final ok =
                                      (ref.read(gameStateProvider) as dynamic)
                                          .upgradeCoachStaffLevel();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok == true
                                            ? 'Comissão técnica evoluída com sucesso.'
                                            : 'Não foi possível evoluir a comissão agora.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachHeroCard extends StatelessWidget {
  final String clubName;
  final CoachStaffMember coach;
  final String styleLabel;
  final int level;
  final String prestigeLabel;

  const _CoachHeroCard({
    required this.clubName,
    required this.coach,
    required this.styleLabel,
    required this.level,
    required this.prestigeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: 124,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.white.withOpacity(0.18),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                coach.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
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
                  clubName,
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
                  '${coach.name} • $styleLabel',
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
                    _HeroPill(label: 'Nível $level'),
                    const SizedBox(width: 6),
                    _HeroPill(label: prestigeLabel),
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

class _CoachQuickGrid extends StatelessWidget {
  final int level;
  final int prestigeStars;
  final String prestigeLabel;
  final int bonusPct;
  final String license;
  final int complexLevel;
  final int monthlySalary;

  const _CoachQuickGrid({
    required this.level,
    required this.prestigeStars,
    required this.prestigeLabel,
    required this.bonusPct,
    required this.license,
    required this.complexLevel,
    required this.monthlySalary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _QuickTile(
              icon: Icons.badge_outlined,
              label: 'Nível',
              value: '$level / 10',
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.workspace_premium_outlined,
              label: 'Categoria',
              value: prestigeLabel,
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.star_rounded,
              label: 'Prestígio',
              value: '${_starsText(prestigeStars)}',
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            _QuickTile(
              icon: Icons.school_rounded,
              label: 'Licença',
              value: license,
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.payments_rounded,
              label: 'Salário',
              value: _fmtMoney(monthlySalary),
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.trending_up_rounded,
              label: 'Bônus',
              value: '+$bonusPct%',
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickTile({
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
            Icon(icon, size: 20, color: AppColors.primary),
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

class _CoachEvolutionPanel extends StatelessWidget {
  final int level;
  final int complexLevel;
  final int balance;
  final int bonusPct;
  final VoidCallback onUpgrade;

  const _CoachEvolutionPanel({
    required this.level,
    required this.complexLevel,
    required this.balance,
    required this.bonusPct,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final nextLevel = (level + 1).clamp(1, 10);
    final hasNext = level < 10;
    final blockedByComplex = hasNext && nextLevel > complexLevel;
    final cost = _upgradeCostToLevel(nextLevel);
    final duration = _courseDuration(nextLevel);
    final nextBonus = _coachBonusPct(nextLevel);
    final currentSalary = _salaryByLevel(level);
    final nextSalary = _salaryByLevel(nextLevel);
    final hasMoney = balance >= cost;

    final canUpgrade = hasNext && !blockedByComplex && hasMoney;

    String status;
    if (!hasNext) {
      status = 'Comissão no nível máximo.';
    } else if (blockedByComplex) {
      status = 'Melhore o Complexo para nível $nextLevel.';
    } else if (!hasMoney) {
      status = 'Caixa insuficiente para evoluir a comissão.';
    } else {
      status =
          'Evolução disponível. Esse investimento melhora a estrutura de trabalho da comissão do clube.';
    }

    return Column(
      children: [
        CoachInfoRow(
          icon: Icons.school_rounded,
          label: 'Licença atual',
          value: _licenseLabel(level),
        ),
        const SizedBox(height: 10),
        CoachInfoRow(
          icon: Icons.upgrade_rounded,
          label: 'Próxima licença',
          value: hasNext ? _licenseLabel(nextLevel) : 'Máxima',
        ),
        const SizedBox(height: 10),
        CoachInfoRow(
          icon: Icons.apartment_rounded,
          label: 'Teto do Complexo',
          value: '$complexLevel / 10',
        ),
        const SizedBox(height: 10),
        CoachInfoRow(
          icon: Icons.payments_rounded,
          label: 'Custo de evolução',
          value: hasNext ? _fmtMoney(cost) : '-',
        ),
        const SizedBox(height: 10),
        CoachInfoRow(
          icon: Icons.attach_money_rounded,
          label: 'Salário mensal',
          value: hasNext
              ? '${_fmtMoney(currentSalary)} → ${_fmtMoney(nextSalary)}'
              : _fmtMoney(currentSalary),
        ),
        const SizedBox(height: 10),
        CoachInfoRow(
          icon: Icons.schedule_rounded,
          label: 'Duração',
          value: hasNext ? duration : '-',
        ),
        const SizedBox(height: 10),
        CoachInfoRow(
          icon: Icons.trending_up_rounded,
          label: 'Bônus',
          value: hasNext ? '+$bonusPct% → +$nextBonus%' : '+$bonusPct%',
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: canUpgrade
                ? AppColors.primary.withOpacity(0.055)
                : AppColors.warning.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: canUpgrade
                  ? AppColors.primary.withOpacity(0.12)
                  : AppColors.warning.withOpacity(0.25),
            ),
          ),
          child: Text(
            status,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canUpgrade ? onUpgrade : null,
            icon: const Icon(Icons.school_rounded),
            label: Text(
              hasNext ? 'Evoluir para nível $nextLevel' : 'Nível máximo',
            ),
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Block({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BlockTitle(icon: icon, title: title),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _BlockTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _BlockTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryDark),
        const SizedBox(width: 7),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
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
        Icon(icon, size: 17, color: AppColors.primaryDark),
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

int _salaryByLevel(int level) {
  final v = level.clamp(1, 10);

  return switch (v) {
    1 => 180000,
    2 => 250000,
    3 => 350000,
    4 => 500000,
    5 => 700000,
    6 => 900000,
    7 => 1200000,
    8 => 1500000,
    9 => 1750000,
    _ => 2000000,
  };
}

int _upgradeCostToLevel(int nextLevel) {
  final v = nextLevel.clamp(1, 10);

  return switch (v) {
    2 => 50000,
    3 => 150000,
    4 => 350000,
    5 => 700000,
    6 => 1500000,
    7 => 3000000,
    8 => 7000000,
    9 => 15000000,
    10 => 25000000,
    _ => 0,
  };
}

String _courseDuration(int nextLevel) {
  final v = nextLevel.clamp(1, 10);

  return switch (v) {
    2 => '1 mês',
    3 => '1 mês',
    4 => '2 meses',
    5 => '2 meses',
    6 => '3 meses',
    7 => '3 meses',
    8 => '4 meses',
    9 => '5 meses',
    10 => '6 meses',
    _ => '-',
  };
}

int _coachBonusPct(int level) {
  final v = level.clamp(1, 10);

  return switch (v) {
    1 => 0,
    2 => 1,
    3 => 2,
    4 => 3,
    5 => 5,
    6 => 7,
    7 => 10,
    8 => 12,
    9 => 15,
    _ => 20,
  };
}

int _prestigeStars(int level) {
  final v = level.clamp(1, 10);

  if (v <= 2) return 1;
  if (v <= 4) return 2;
  if (v <= 6) return 3;
  if (v <= 8) return 4;
  return 5;
}

String _prestigeLabel(int level) {
  final v = level.clamp(1, 10);

  if (v <= 2) return 'Regional';
  if (v <= 4) return 'Nacional';
  if (v <= 6) return 'Continental';
  if (v <= 8) return 'Internacional';
  return 'Lendário';
}

String _starsText(int stars) {
  final safe = stars.clamp(1, 5);
  return '★' * safe;
}

String _licenseLabel(int level) {
  final v = level.clamp(1, 10);

  return switch (v) {
    1 => 'Curso Inicial',
    2 => 'Licença C',
    3 => 'Licença B',
    4 => 'Licença A',
    5 => 'Licença Nacional C',
    6 => 'Licença Nacional B',
    7 => 'Licença Nacional A',
    8 => 'Licença Continental',
    9 => 'Licença Continental Elite',
    _ => 'Licença Mundial',
  };
}
