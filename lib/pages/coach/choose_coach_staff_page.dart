import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/coach_staff.dart';
import 'package:footory26/pages/hub/main_hub_page.dart';
import 'package:footory26/services/save/save_storage_service.dart';
import 'package:footory26/services/world/catalog/coach_staff_catalog.dart';

class ChooseCoachStaffPage extends ConsumerStatefulWidget {
  final String slotId;

  const ChooseCoachStaffPage({
    super.key,
    required this.slotId,
  });

  @override
  ConsumerState<ChooseCoachStaffPage> createState() =>
      _ChooseCoachStaffPageState();
}

class _ChooseCoachStaffPageState extends ConsumerState<ChooseCoachStaffPage> {
  final SaveStorageService _saveStorage = SaveStorageService();

  CoachStaff? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (CoachStaffCatalog.all.isNotEmpty) {
      _selected = CoachStaffCatalog.all.first;
    }
  }

  Future<void> _chooseAndContinue(CoachStaff staff) async {
    if (_saving) return;

    setState(() {
      _selected = staff;
      _saving = true;
    });

    try {
      final state = ref.read(gameStateProvider);

      state.currentSaveSlotId = widget.slotId;
      state.chooseCoachStaff(staff);

      await _saveStorage.saveFromGameState(
        slotId: widget.slotId,
        gs: state,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainHubPage(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _openDetails(CoachStaff staff) async {
    final choose = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _CoachStaffDetailsPage(
          staff: staff,
          selected: _selected?.id == staff.id,
        ),
      ),
    );

    if (choose == true) {
      await _chooseAndContinue(staff);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = ref.watch(gameStateProvider);

    final clubName = gs.userClubName.isEmpty ? 'Seu Clube' : gs.userClubName;
    final level = gs.userCoachLevel.clamp(1, 10);
    final staffList = CoachStaffCatalog.all;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Escolher DNA Tático'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Column(
            children: [
              _CoachSelectionHero(
                clubName: clubName,
                level: level,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: staffList.isEmpty
                    ? const Center(
                        child: Text('Nenhuma comissão disponível.'),
                      )
                    : _CoachStyleList(
                        staffList: staffList,
                        selected: _selected,
                        saving: _saving,
                        onSelect: (staff) {
                          setState(() {
                            _selected = staff;
                          });
                        },
                        onDetails: _openDetails,
                        onChoose: _chooseAndContinue,
                      ),
              ),
              const SizedBox(height: 8),
              _ConfirmButton(
                selected: _selected,
                saving: _saving,
                onPressed: _selected == null
                    ? null
                    : () => _chooseAndContinue(_selected!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachSelectionHero extends StatelessWidget {
  final String clubName;
  final int level;

  const _CoachSelectionHero({
    required this.clubName,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: 118,
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
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.white.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
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
                  'DNA Tático',
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
                  clubName,
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
                    const _HeroPill(label: 'Escolha a filosofia'),
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

class _CoachStyleList extends StatelessWidget {
  final List<CoachStaff> staffList;
  final CoachStaff? selected;
  final bool saving;
  final ValueChanged<CoachStaff> onSelect;
  final ValueChanged<CoachStaff> onDetails;
  final Future<void> Function(CoachStaff staff) onChoose;

  const _CoachStyleList({
    required this.staffList,
    required this.selected,
    required this.saving,
    required this.onSelect,
    required this.onDetails,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.auto_awesome_rounded,
            title: 'Escolha a identidade do seu clube',
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: staffList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final staff = staffList[index];
                final isSelected = selected?.id == staff.id;

                return _CoachStyleCard(
                  staff: staff,
                  selected: isSelected,
                  saving: saving,
                  onSelect: () => onSelect(staff),
                  onDetails: () => onDetails(staff),
                  onChoose: () => onChoose(staff),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachStyleCard extends StatelessWidget {
  final CoachStaff staff;
  final bool selected;
  final bool saving;
  final VoidCallback onSelect;
  final VoidCallback onDetails;
  final VoidCallback onChoose;

  const _CoachStyleCard({
    required this.staff,
    required this.selected,
    required this.saving,
    required this.onSelect,
    required this.onDetails,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final nationality = _countryLabel(staff.coach.nationalityCode);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft.withOpacity(0.92)
                : AppColors.primary.withOpacity(0.045),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.11),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _FlagIcon(
                    countryCode: staff.coach.nationalityCode,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      staff.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${staff.coach.name} • $nationality',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                staff.shortDescription,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                  height: 1.28,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: onDetails,
                        icon: const Icon(Icons.info_outline_rounded, size: 17),
                        label: const Text('Detalhes'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: saving ? null : onChoose,
                        icon: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 17,
                        ),
                        label: const Text('Escolher'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final CoachStaff? selected;
  final bool saving;
  final VoidCallback? onPressed;

  const _ConfirmButton({
    required this.selected,
    required this.saving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = selected == null
        ? 'Escolher comissão'
        : saving
            ? 'Salvando...'
            : 'Confirmar ${selected!.name}';

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: saving ? null : onPressed,
        icon: saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check_circle_outline_rounded),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CoachStaffDetailsPage extends StatelessWidget {
  final CoachStaff staff;
  final bool selected;

  const _CoachStaffDetailsPage({
    required this.staff,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final nationality = _countryLabel(staff.coach.nationalityCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalhes da Comissão'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Column(
            children: [
              Container(
                height: 112,
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
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.psychology_alt_rounded,
                        color: AppColors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name,
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
                            '$nationality • ${staff.coach.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.labelMedium?.copyWith(
                              color: AppColors.white.withOpacity(0.94),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          _HeroPill(label: 'DNA Tático'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _PremiumSurface(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      const _PanelTitle(
                        icon: Icons.sports_rounded,
                        title: 'Treinador Principal',
                      ),
                      const SizedBox(height: 8),
                      _CoachMainCard(member: staff.coach),
                      const SizedBox(height: 12),
                      const _PanelTitle(
                        icon: Icons.article_rounded,
                        title: 'Filosofia',
                      ),
                      const SizedBox(height: 8),
                      _TextBlock(text: staff.shortDescription),
                      const SizedBox(height: 12),
                      const _PanelTitle(
                        icon: Icons.groups_2_rounded,
                        title: 'Auxiliares',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _AssistantMiniCard(member: staff.assistant1),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _AssistantMiniCard(member: staff.assistant2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                  label: Text(
                    selected
                        ? 'Manter esta comissão'
                        : 'Escolher esta comissão',
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

class _CoachMainCard extends StatelessWidget {
  final CoachStaffMember member;

  const _CoachMainCard({
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                member.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FlagNameLine(
                  countryCode: member.nationalityCode,
                  name: member.name,
                  centered: false,
                  flagSize: 18,
                  textStyle: t.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  member.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
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

class _AssistantMiniCard extends StatelessWidget {
  final CoachStaffMember member;

  const _AssistantMiniCard({
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: 164,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                member.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            member.role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _FlagNameLine(
              countryCode: member.nationalityCode,
              name: member.name,
              centered: true,
              flagSize: 15,
              textStyle: t.labelSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String text;

  const _TextBlock({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
      ),
    );
  }
}

class _FlagNameLine extends StatelessWidget {
  final String countryCode;
  final String name;
  final bool centered;
  final double flagSize;
  final TextStyle? textStyle;

  const _FlagNameLine({
    required this.countryCode,
    required this.name,
    required this.centered,
    required this.flagSize,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _FlagIcon(
          countryCode: countryCode,
          size: flagSize,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            name,
            maxLines: centered ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class _FlagIcon extends StatelessWidget {
  final String countryCode;
  final double size;

  const _FlagIcon({
    required this.countryCode,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final flagPath = _flagAssetFromCode(countryCode);

    return Image.asset(
      flagPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          countryCode.toUpperCase(),
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
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

  const _PanelTitle({
    required this.icon,
    required this.title,
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
      ],
    );
  }
}

String _flagAssetFromCode(String code) {
  final normalized = code.trim().toLowerCase();

  switch (normalized) {
    case 'eng':
      return 'assets/flags/eng.png';
    default:
      return 'assets/flags/$normalized.png';
  }
}

String _countryLabel(String code) {
  switch (code.trim().toLowerCase()) {
    case 'bra':
    case 'br':
      return 'Brasil';
    case 'arg':
      return 'Argentina';
    case 'uru':
      return 'Uruguai';
    case 'chi':
      return 'Chile';
    case 'col':
      return 'Colômbia';
    case 'par':
      return 'Paraguai';
    case 'per':
      return 'Peru';
    case 'bol':
      return 'Bolívia';
    case 'ven':
      return 'Venezuela';
    case 'eng':
      return 'Inglaterra';
    case 'esp':
      return 'Espanha';
    case 'ita':
      return 'Itália';
    case 'ger':
    case 'deu':
      return 'Alemanha';
    case 'fra':
      return 'França';
    case 'por':
      return 'Portugal';
    case 'ned':
      return 'Holanda';
    default:
      return code.toUpperCase();
  }
}
