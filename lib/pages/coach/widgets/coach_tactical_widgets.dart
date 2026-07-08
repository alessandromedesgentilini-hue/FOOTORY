import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/coach_tactical_identity.dart';

class CoachFormationLine extends StatelessWidget {
  final String label;
  final String formation;
  final bool highlighted;

  const CoachFormationLine({
    super.key,
    required this.label,
    required this.formation,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primarySoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sports_soccer_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          CoachFormationChip(
            formation: formation,
            highlighted: highlighted,
          ),
        ],
      ),
    );
  }
}

class CoachFormationChip extends StatelessWidget {
  final String formation;
  final bool highlighted;

  const CoachFormationChip({
    super.key,
    required this.formation,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        _formatFormation(formation),
        style: t.bodySmall?.copyWith(
          color: highlighted ? AppColors.white : AppColors.text,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _formatFormation(String value) {
    return value
        .replaceAll('_flat', ' linha')
        .replaceAll('_wide', ' aberto')
        .replaceAll('_narrow', ' fechado')
        .replaceAll('_', ' ')
        .toUpperCase();
  }
}

class CoachTacticalBiasGrid extends StatelessWidget {
  final CoachTacticalIdentity identity;

  const CoachTacticalBiasGrid({
    super.key,
    required this.identity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BiasRow(
          label: 'Pressão',
          value: identity.pressureBias,
          icon: Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: 10),
        _BiasRow(
          label: 'Posse',
          value: identity.possessionBias,
          icon: Icons.sync_alt_rounded,
        ),
        const SizedBox(height: 10),
        _BiasRow(
          label: 'Transição',
          value: identity.transitionBias,
          icon: Icons.bolt_rounded,
        ),
        const SizedBox(height: 10),
        _BiasRow(
          label: 'Bola parada',
          value: identity.setPieceBias,
          icon: Icons.sports_handball_rounded,
        ),
      ],
    );
  }
}

class _BiasRow extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _BiasRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final normalized = value.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _labelFromValue(normalized),
            style: t.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _labelFromValue(double value) {
    if (value >= 0.85) return 'Alta';
    if (value >= 0.60) return 'Boa';
    if (value >= 0.40) return 'Média';
    return 'Baixa';
  }
}
