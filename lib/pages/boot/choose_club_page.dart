import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/pages/coach/choose_coach_staff_page.dart';
import 'package:footory26/services/save/save_storage_service.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class ChooseClubPage extends ConsumerStatefulWidget {
  final String slotId;

  const ChooseClubPage({
    super.key,
    required this.slotId,
  });

  @override
  ConsumerState<ChooseClubPage> createState() {
    return _ChooseClubPageState();
  }
}

class _ChooseClubPageState extends ConsumerState<ChooseClubPage> {
  static const List<DivisionId> _availableDivisions = <DivisionId>[
    DivisionId.brA,
    DivisionId.brB,
    DivisionId.brC,
  ];

  DivisionId _selectedDivision = DivisionId.brA;

  String? _processingClubId;

  bool get _isProcessing => _processingClubId != null;

  int _buildNewCareerSeed({
    required String slotId,
    required String clubId,
    required DivisionId division,
  }) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return timestamp ^
        slotId.hashCode ^
        clubId.hashCode ^
        division.name.hashCode;
  }

  Future<void> _selectClub({
    required String clubId,
    required String clubName,
  }) async {
    if (_isProcessing) return;

    final normalizedSlotId = widget.slotId.trim();

    if (!SaveStorageService.slotIds.contains(normalizedSlotId)) {
      _showMessage(
        'O slot selecionado não é válido.',
        isError: true,
      );
      return;
    }

    final gs = ref.read(gameStateProvider);

    if (!gs.hasFootballDirector) {
      _showMessage(
        'Crie o Diretor de Futebol antes de escolher o clube.',
        isError: true,
      );
      return;
    }

    final divisionCode = _divisionCode(_selectedDivision);

    final clubExistsInDivision = BrazilClubCatalog.byDivision(
      _selectedDivision,
    ).any((club) => club.id == clubId);

    if (!clubExistsInDivision) {
      _showMessage(
        'O clube selecionado não pertence a essa divisão.',
        isError: true,
      );
      return;
    }

    setState(() {
      _processingClubId = clubId;
    });

    try {
      final seed = _buildNewCareerSeed(
        slotId: normalizedSlotId,
        clubId: clubId,
        division: _selectedDivision,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChooseCoachStaffPage(
            slotId: normalizedSlotId,
            divisionId: divisionCode,
            seed: seed,
            clubId: clubId,
            clubName: clubName,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingClubId = null;
        });
      }
    }
  }

  void _changeDivision(DivisionId division) {
    if (_isProcessing) return;
    if (!_availableDivisions.contains(division)) return;
    if (_selectedDivision == division) return;

    setState(() {
      _selectedDivision = division;
    });
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.danger : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clubs = BrazilClubCatalog.byDivision(_selectedDivision);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Escolher Clube'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  24,
                ),
                children: [
                  const _ClubSelectionHero(),
                  const SizedBox(height: 16),
                  _DivisionSelector(
                    selected: _selectedDivision,
                    enabled: !_isProcessing,
                    onChanged: _changeDivision,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _divisionTitle(_selectedDivision),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
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
                          '${clubs.length} clubes',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.accentDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (clubs.isEmpty)
                    const _EmptyClubList()
                  else
                    ...List.generate(
                      clubs.length,
                      (index) {
                        final club = clubs[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == clubs.length - 1 ? 0 : 10,
                          ),
                          child: _ClubTile(
                            clubName: club.name,
                            assetPath: club.badgeAsset,
                            processing: _processingClubId == club.id,
                            enabled: !_isProcessing,
                            onTap: () {
                              _selectClub(
                                clubId: club.id,
                                clubName: club.name,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  const _SeriesDInformation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _divisionTitle(DivisionId division) {
    switch (division) {
      case DivisionId.brA:
        return 'Clubes da Série A';
      case DivisionId.brB:
        return 'Clubes da Série B';
      case DivisionId.brC:
        return 'Clubes da Série C';
      case DivisionId.brD:
        return 'Clubes da Série D';
    }
  }

  static String _divisionCode(DivisionId division) {
    switch (division) {
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

class _ClubSelectionHero extends StatelessWidget {
  const _ClubSelectionHero();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.white.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escolha seu primeiro clube',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Este será o início da carreira do seu Diretor de Futebol. '
                  'O clube do coração escolhido anteriormente não interfere '
                  'nesta decisão.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DivisionSelector extends StatelessWidget {
  final DivisionId selected;
  final bool enabled;
  final ValueChanged<DivisionId> onChanged;

  const _DivisionSelector({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const divisions = <DivisionId>[
      DivisionId.brA,
      DivisionId.brB,
      DivisionId.brC,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: divisions.map((division) {
          final selectedDivision = division == selected;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: division == divisions.last ? 0 : 7,
              ),
              child: _DivisionButton(
                label: _labelOf(division),
                selected: selectedDivision,
                enabled: enabled,
                onTap: () => onChanged(division),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static String _labelOf(DivisionId division) {
    switch (division) {
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

class _DivisionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _DivisionButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  final String clubName;
  final String assetPath;
  final bool processing;
  final bool enabled;
  final VoidCallback onTap;

  const _ClubTile({
    required this.clubName,
    required this.assetPath,
    required this.processing,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled || processing ? 1 : 0.60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: processing ? AppColors.primary : AppColors.border,
                width: processing ? 2 : 1,
              ),
              boxShadow: AppColors.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color:
                            processing ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.shield_outlined,
                          color: AppColors.primary,
                          size: 30,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      clubName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: processing
                          ? AppColors.primarySoft
                          : AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    alignment: Alignment.center,
                    child: processing
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primary,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyClubList extends StatelessWidget {
  const _EmptyClubList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.textSecondary,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'Nenhum clube disponível nesta divisão.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SeriesDInformation extends StatelessWidget {
  const _SeriesDInformation();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'A Série D continua ativa e totalmente simulada no mundo do '
              'jogo, com acesso e rebaixamento. Ela apenas não está '
              'disponível como ponto inicial da carreira.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
