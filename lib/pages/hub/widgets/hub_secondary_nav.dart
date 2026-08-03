import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

class HubSecondaryNav extends StatelessWidget {
  final VoidCallback onMyClub;
  final VoidCallback onMarket;
  final VoidCallback onMessages;
  final VoidCallback onStandings;
  final VoidCallback onObservation;
  final VoidCallback onStructures;
  final VoidCallback onFinance;
  final VoidCallback onCoach;
  final VoidCallback onDirector;
  final VoidCallback onPermanentStaff;

  const HubSecondaryNav({
    super.key,
    required this.onMyClub,
    required this.onMarket,
    required this.onMessages,
    required this.onStandings,
    required this.onObservation,
    required this.onStructures,
    required this.onFinance,
    required this.onCoach,
    required this.onDirector,
    required this.onPermanentStaff,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _NavigationHeader(),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _NavigationGroup(
                  title: 'Clube',
                  icon: Icons.shield_rounded,
                  children: [
                    _NavigationAction(
                      icon: Icons.groups_rounded,
                      label: 'Meu clube',
                      onTap: onMyClub,
                    ),
                    _NavigationAction(
                      icon: Icons.apartment_rounded,
                      label: 'Estruturas',
                      onTap: onStructures,
                    ),
                    _NavigationAction(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Finanças',
                      onTap: onFinance,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NavigationGroup(
                  title: 'Futebol',
                  icon: Icons.sports_soccer_rounded,
                  children: [
                    _NavigationAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Mercado',
                      onTap: onMarket,
                    ),
                    _NavigationAction(
                      icon: Icons.visibility_rounded,
                      label: 'Observação',
                      onTap: onObservation,
                    ),
                    _NavigationAction(
                      icon: Icons.sports_rounded,
                      label: 'Comissão',
                      onTap: onCoach,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _NavigationGroup(
                  title: 'Direção',
                  icon: Icons.business_center_rounded,
                  children: [
                    _NavigationAction(
                      icon: Icons.person_rounded,
                      label: 'Diretor',
                      onTap: onDirector,
                    ),
                    _NavigationAction(
                      icon: Icons.badge_rounded,
                      label: 'Equipe permanente',
                      onTap: onPermanentStaff,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NavigationGroup(
                  title: 'Central',
                  icon: Icons.dashboard_rounded,
                  children: [
                    _NavigationAction(
                      icon: Icons.mail_rounded,
                      label: 'Mensagens',
                      onTap: onMessages,
                      compact: true,
                    ),
                    _NavigationAction(
                      icon: Icons.leaderboard_rounded,
                      label: 'Classificação',
                      onTap: onStandings,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationHeader extends StatelessWidget {
  const _NavigationHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.apps_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Áreas do clube',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Acesse os setores da sua gestão',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavigationGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_NavigationAction> children;

  const _NavigationGroup({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 146,
      ),
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1) const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }
}

class _NavigationAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  const _NavigationAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Ink(
          width: double.infinity,
          height: compact ? 36 : 38,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: AppColors.border.withOpacity(0.82),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
