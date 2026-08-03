import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/permanent_staff_member.dart';
import 'package:footory26/pages/director/permanent_staff_page.dart';

class HubPermanentStaffPreview extends StatelessWidget {
  final List<PermanentStaffMember> members;

  const HubPermanentStaffPreview({
    super.key,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final visibleMembers = members.take(4).toList();

    if (visibleMembers.isEmpty) {
      return const SizedBox.shrink();
    }

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
          _StaffHeader(
            onTap: () => _openPermanentStaff(context),
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < visibleMembers.length; index++) ...[
                Expanded(
                  child: _StaffMiniCard(
                    member: visibleMembers[index],
                    onTap: () => _openPermanentStaff(context),
                  ),
                ),
                if (index < visibleMembers.length - 1) const SizedBox(width: 7),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _openPermanentStaff(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PermanentStaffPage(),
      ),
    );
  }
}

class _StaffHeader extends StatelessWidget {
  final VoidCallback onTap;

  const _StaffHeader({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.badge_rounded,
                size: 17,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipe Permanente',
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
                    'Profissionais que acompanham sua gestão',
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
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffMiniCard extends StatelessWidget {
  final PermanentStaffMember member;
  final VoidCallback onTap;

  const _StaffMiniCard({
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = _firstName(member.name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 104,
        ),
        padding: const EdgeInsets.fromLTRB(5, 7, 5, 7),
        decoration: BoxDecoration(
          color: AppColors.primarySoft.withOpacity(0.45),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.11),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.14),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(
                  member.portraitAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: AppColors.primarySoft,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 25,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.text,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _roleLabel(member.role),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 8.3,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _firstName(String fullName) {
    final value = fullName.trim();

    if (value.isEmpty) {
      return 'Profissional';
    }

    return value.split(RegExp(r'\s+')).first;
  }

  String _roleLabel(PermanentStaffRole role) {
    switch (role) {
      case PermanentStaffRole.assistantCoach:
        return 'Auxiliar';
      case PermanentStaffRole.performanceAnalyst:
        return 'Analista';
      case PermanentStaffRole.fitnessCoach:
        return 'Preparação';
      case PermanentStaffRole.goalkeeperCoach:
        return 'Goleiros';
    }
  }
}
