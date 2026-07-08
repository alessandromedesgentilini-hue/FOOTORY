import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/coach_staff.dart';
import 'package:footory26/models/save_slot_data.dart';
import 'package:footory26/pages/boot/choose_club_page.dart';
import 'package:footory26/pages/hub/main_hub_page.dart';
import 'package:footory26/services/save/save_storage_service.dart';
import 'package:footory26/services/world/game_state.dart';
import 'package:footory26/services/world/catalog/coach_staff_catalog.dart';

enum SaveSlotMode {
  newGame,
  continueGame,
}

class ChooseSaveSlotPage extends ConsumerStatefulWidget {
  final SaveSlotMode mode;

  const ChooseSaveSlotPage({
    super.key,
    required this.mode,
  });

  @override
  ConsumerState<ChooseSaveSlotPage> createState() => _ChooseSaveSlotPageState();
}

class _ChooseSaveSlotPageState extends ConsumerState<ChooseSaveSlotPage> {
  final SaveStorageService _storage = SaveStorageService();

  bool _loading = true;
  List<SaveSlotData?> _slots = const <SaveSlotData?>[];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await _storage.loadAllSlots();
    if (!mounted) return;

    setState(() {
      _slots = slots;
      _loading = false;
    });
  }

  Future<void> _handleTap({
    required int index,
    required SaveSlotData? slot,
  }) async {
    final slotId = SaveStorageService.slotIds[index];

    if (widget.mode == SaveSlotMode.newGame) {
      if (slot != null) {
        final overwrite = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Sobrescrever save?'),
              content: Text(
                'O slot ${index + 1} já está ocupado por ${slot.clubName}. Deseja sobrescrever esse save?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Sobrescrever'),
                ),
              ],
            );
          },
        );

        if (overwrite != true) return;
      }

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChooseClubPage(slotId: slotId),
        ),
      );
      return;
    }

    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esse slot está vazio.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _storage.seedMissingStateFromCatalog(
      slotId: slot.slotId,
      slot: slot,
    );

    final state = await _storage.loadSlotState(slot.slotId);

    final gs = ref.read(gameStateProvider);

    gs.currentSaveSlotId = slot.slotId;
    gs.clearSelectedCoachStaff();

    gs.startSeasonFromSave(
      division: slot.divisionId,
      seed: slot.seed,
      userClubId: slot.clubId,
      userClubName: slot.clubName,
    );

    final restoredCoach = _coachFromSave(
      slot: slot,
      state: state,
    );

    if (restoredCoach != null) {
      gs.chooseCoachStaff(restoredCoach);
    }

    if (state != null) {
      gs.restoreRuntimeStateFromSave(state);
    }

    await _storage.setLastActiveSlotId(slot.slotId);

    await _storage.saveFromGameState(
      slotId: slot.slotId,
      gs: gs,
    );

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainHubPage(),
      ),
      (route) => false,
    );
  }

  CoachStaff? _coachFromSave({
    required SaveSlotData slot,
    required Map<String, dynamic>? state,
  }) {
    String coachId = slot.coachStaffId;
    int level = slot.coachLevel;
    int contractEndYear = slot.contractEndYear;
    CoachPrestige prestige = CoachPrestige.regional;

    final coachMap = (state?['coachStaff'] as Map?)?.cast<String, dynamic>();

    if (coachMap != null) {
      final savedId = (coachMap['id'] as String?)?.trim();
      if (savedId != null && savedId.isNotEmpty) {
        coachId = savedId;
      }

      level = _readInt(coachMap['level'], fallback: level);
      contractEndYear = _readInt(
        coachMap['contractEndYear'],
        fallback: contractEndYear,
      );

      prestige = _prestigeFromString(
        coachMap['prestige']?.toString(),
        fallback: prestige,
      );
    } else if (state != null) {
      final savedId = (state['coachStaffId'] as String?)?.trim();
      if (savedId != null && savedId.isNotEmpty) {
        coachId = savedId;
      }

      level = _readInt(
        state['userCoachLevel'],
        fallback: level,
      );
    }

    final baseCoach =
        CoachStaffCatalog.all.where((e) => e.id == coachId).firstOrNull;

    if (baseCoach == null) return null;

    return baseCoach.copyWith(
      level: level.clamp(1, 10),
      contractEndYear: contractEndYear.clamp(2026, 2099),
      prestige: prestige,
    );
  }

  int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  CoachPrestige _prestigeFromString(
    String? value, {
    required CoachPrestige fallback,
  }) {
    switch ((value ?? '').trim()) {
      case 'regional':
        return CoachPrestige.regional;
      case 'nacional':
        return CoachPrestige.nacional;
      case 'continental':
        return CoachPrestige.continental;
      case 'internacional':
        return CoachPrestige.internacional;
      case 'lendario':
        return CoachPrestige.lendario;
      default:
        return fallback;
    }
  }

  Future<void> _deleteSlot(int index) async {
    final slot = _slots[index];
    if (slot == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Apagar save?'),
          content: Text(
            'Deseja apagar o save de ${slot.clubName} no slot ${index + 1}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _storage.deleteSlot(slot.slotId);
    await _loadSlots();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isNewGame = widget.mode == SaveSlotMode.newGame;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewGame ? 'Escolher Slot' : 'Continuar Carreira'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.softCardGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Text(
                    isNewGame
                        ? 'Escolha em qual slot você quer iniciar a nova carreira.'
                        : 'Escolha qual carreira você quer continuar.',
                    style: t.bodyMedium?.copyWith(
                      color: AppColors.text,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_slots.length, (index) {
                  final slot = _slots[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SaveSlotCard(
                      index: index,
                      slot: slot,
                      onTap: () => _handleTap(index: index, slot: slot),
                      onDelete: slot == null ? null : () => _deleteSlot(index),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _SaveSlotCard extends StatelessWidget {
  final int index;
  final SaveSlotData? slot;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _SaveSlotCard({
    required this.index,
    required this.slot,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isEmpty = slot == null;

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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: t.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Slot ${index + 1}',
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vazio',
                              style: t.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot!.clubName,
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${slot!.divisionId} • Temporada ${slot!.seasonYear} • Rodada ${slot!.roundIndex}',
                              style: t.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Comissão nível ${slot!.coachLevel} • Contrato ${slot!.contractEndYear}',
                              style: t.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Salvo em ${_formatSavedAt(slot!.savedAtIso)}',
                              style: t.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.danger,
                  ),
                ],
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatSavedAt(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year;
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/$y $h:$min';
    } catch (_) {
      return iso;
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
