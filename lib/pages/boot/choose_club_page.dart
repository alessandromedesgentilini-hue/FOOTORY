import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/pages/coach/choose_coach_staff_page.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class ChooseClubPage extends ConsumerStatefulWidget {
  final String slotId;

  const ChooseClubPage({
    super.key,
    required this.slotId,
  });

  @override
  ConsumerState<ChooseClubPage> createState() => _ChooseClubPageState();
}

class _ChooseClubPageState extends ConsumerState<ChooseClubPage> {
  DivisionId _selectedDivision = DivisionId.brD;

  int _buildNewCareerSeed({
    required String slotId,
    required String clubId,
    required DivisionId division,
  }) {
    final now = DateTime.now().microsecondsSinceEpoch;

    return now ^
        slotId.hashCode ^
        clubId.hashCode ^
        division.toString().hashCode;
  }

  @override
  Widget build(BuildContext context) {
    final gs = ref.read(gameStateProvider);
    final clubes = BrazilClubCatalog.byDivision(_selectedDivision);
    final theme = Theme.of(context);

    final divisionLabel = _getDivisionLabel(_selectedDivision);
    final divisionCode = _getDivisionCode(_selectedDivision);

    return Scaffold(
      appBar: AppBar(
        title: Text(divisionLabel),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gs.initError != null) ...[
                _ErrorBox(message: gs.initError!),
                const SizedBox(height: 16),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.softCardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Escolha seu clube',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Agora dá para iniciar carreira em qualquer divisão do Brasil.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _DivisionSelector(
                selected: _selectedDivision,
                onChanged: (value) {
                  setState(() {
                    _selectedDivision = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Clubes disponíveis',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${clubes.length} clubes',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.accentDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: clubes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final c = clubes[i];

                    return _ClubTile(
                      clubName: c.name,
                      clubId: c.id,
                      assetPath: c.badgeAsset,
                      onTap: () {
                        final gs = ref.read(gameStateProvider);

                        final seed = _buildNewCareerSeed(
                          slotId: widget.slotId,
                          clubId: c.id,
                          division: _selectedDivision,
                        );

                        gs.currentSaveSlotId = widget.slotId;
                        gs.clearSelectedCoachStaff();

                        gs.startSeason(
                          division: divisionCode,
                          seed: seed,
                          userClubId: c.id,
                          userClubName: c.name,
                        );

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ChooseCoachStaffPage(
                              slotId: widget.slotId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDivisionLabel(DivisionId d) {
    switch (d) {
      case DivisionId.brA:
        return 'Liga Brasileira A';
      case DivisionId.brB:
        return 'Liga Brasileira B';
      case DivisionId.brC:
        return 'Liga Brasileira C';
      case DivisionId.brD:
        return 'Liga Brasileira D';
    }
  }

  String _getDivisionCode(DivisionId d) {
    switch (d) {
      case DivisionId.brA:
        return 'BR-A';
      case DivisionId.brB:
        return 'BR-B';
      case DivisionId.brC:
        return 'BR-C';
      case DivisionId.brD:
        return 'BR-D';
    }
  }
}

class _DivisionSelector extends StatelessWidget {
  final DivisionId selected;
  final ValueChanged<DivisionId> onChanged;

  const _DivisionSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final divisions = <DivisionId>[
      DivisionId.brA,
      DivisionId.brB,
      DivisionId.brC,
      DivisionId.brD,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: divisions.map((division) {
        final isSelected = division == selected;

        return ChoiceChip(
          label: Text(_labelOf(division)),
          selected: isSelected,
          onSelected: (_) => onChanged(division),
        );
      }).toList(),
    );
  }

  String _labelOf(DivisionId d) {
    switch (d) {
      case DivisionId.brA:
        return 'Série A';
      case DivisionId.brB:
        return 'Série B';
      case DivisionId.brC:
        return 'Série C';
      case DivisionId.brD:
        return 'Série D';
    }
  }
}

class _ClubTile extends StatelessWidget {
  final String clubName;
  final String clubId;
  final String assetPath;
  final VoidCallback onTap;

  const _ClubTile({
    required this.clubName,
    required this.clubId,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clubName,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clubId,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
