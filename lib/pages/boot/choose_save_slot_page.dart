import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/save_slot_data.dart';
import 'package:footory26/pages/boot/create_football_director_page.dart';
import 'package:footory26/pages/hub/main_hub_page.dart';
import 'package:footory26/services/save/save_storage_service.dart';
import 'package:footory26/services/world/catalog/football_director_portrait_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

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
  ConsumerState<ChooseSaveSlotPage> createState() {
    return _ChooseSaveSlotPageState();
  }
}

class _ChooseSaveSlotPageState extends ConsumerState<ChooseSaveSlotPage> {
  final SaveStorageService _storage = SaveStorageService();

  bool _loading = true;
  String? _loadError;
  int? _processingSlotIndex;

  List<SaveSlotData?> _slots = const <SaveSlotData?>[];

  bool get _isProcessing => _processingSlotIndex != null;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final slots = await _storage.loadAllSlots();

      if (!mounted) return;

      setState(() {
        _slots = slots;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _slots = List<SaveSlotData?>.filled(
          SaveStorageService.slotIds.length,
          null,
        );

        _loading = false;
        _loadError = 'Não foi possível carregar os saves. Tente novamente.';
      });
    }
  }

  Future<void> _handleTap({
    required int index,
    required SaveSlotData? slot,
  }) async {
    if (_isProcessing) return;

    if (index < 0 || index >= SaveStorageService.slotIds.length) {
      return;
    }

    final slotId = SaveStorageService.slotIds[index];

    setState(() {
      _processingSlotIndex = index;
    });

    try {
      if (widget.mode == SaveSlotMode.newGame) {
        await _startNewGame(
          index: index,
          slotId: slotId,
          occupiedSlot: slot,
        );

        return;
      }

      await _continueGame(
        slot: slot,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Não foi possível abrir esse save. $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingSlotIndex = null;
        });
      }
    }
  }

  Future<void> _startNewGame({
    required int index,
    required String slotId,
    required SaveSlotData? occupiedSlot,
  }) async {
    if (occupiedSlot != null) {
      final overwrite = await _confirmOverwrite(
        index: index,
        slot: occupiedSlot,
      );

      if (overwrite != true) return;
    }

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateFootballDirectorPage(
          slotId: slotId,
        ),
      ),
    );

    if (!mounted) return;

    await _loadSlots();
  }

  Future<void> _continueGame({
    required SaveSlotData? slot,
  }) async {
    if (slot == null) {
      _showMessage('Esse slot está vazio.');
      return;
    }

    final slotId = slot.slotId.trim();

    if (!_storage.isValidSlotId(slotId)) {
      throw StateError('O identificador do slot é inválido.');
    }

    await _storage.seedMissingStateFromCatalog(
      slotId: slotId,
      slot: slot,
    );

    final state = await _storage.loadSlotState(slotId);

    if (state == null) {
      throw StateError(
        'O estado completo da carreira não foi encontrado.',
      );
    }

    final gs = ref.read(gameStateProvider);

    gs.currentSaveSlotId = slotId;
    gs.clearFootballDirector();
    gs.clearSelectedCoachStaff();

    gs.startSeasonFromSave(
      division: slot.divisionId,
      seed: slot.seed,
      userClubId: slot.clubId,
      userClubName: slot.clubName,
    );

    if (!gs.isInitialized) {
      throw StateError(
        gs.initError ?? 'O mundo da carreira não pôde ser inicializado.',
      );
    }

    gs.restoreRuntimeStateFromSave(state);

    await _storage.setLastActiveSlotId(slotId);

    if (!mounted) return;

    if (!gs.hasFootballDirector) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateFootballDirectorPage(
            slotId: slotId,
            isCompletingExistingCareer: true,
          ),
        ),
      );

      if (!mounted) return;

      await _loadSlots();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainHubPage(),
      ),
      (route) => false,
    );
  }

  Future<bool?> _confirmOverwrite({
    required int index,
    required SaveSlotData slot,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final directorName = slot.directorName?.trim();

        final ownerLine = directorName != null && directorName.isNotEmpty
            ? 'Diretor: $directorName.'
            : 'Este é um save de uma versão anterior.';

        return AlertDialog(
          title: const Text('Sobrescrever save?'),
          content: Text(
            'O slot ${index + 1} já está ocupado por '
            '${slot.clubName}.\n\n'
            '$ownerLine\n\n'
            'A carreira atual será substituída somente quando '
            'a criação da nova carreira for concluída.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSlot(int index) async {
    if (_isProcessing) return;

    if (index < 0 || index >= _slots.length) return;

    final slot = _slots[index];

    if (slot == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Apagar save?'),
          content: Text(
            'Deseja apagar a carreira de ${slot.clubName} '
            'no slot ${index + 1}?\n\n'
            'Essa ação não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _processingSlotIndex = index;
    });

    try {
      await _storage.deleteSlot(slot.slotId);
      await _loadSlots();

      if (!mounted) return;

      _showMessage('Save apagado.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Não foi possível apagar esse save.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingSlotIndex = null;
        });
      }
    }
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
    final textTheme = Theme.of(context).textTheme;
    final isNewGame = widget.mode == SaveSlotMode.newGame;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewGame ? 'Escolher Slot' : 'Continuar Carreira',
        ),
      ),
      body: _buildBody(
        context: context,
        textTheme: textTheme,
        isNewGame: isNewGame,
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required TextTheme textTheme,
    required bool isNewGame,
  }) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSlots,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24,
        ),
        children: [
          _IntroCard(
            text: isNewGame
                ? 'Escolha o slot da nova carreira. '
                    'Depois você criará seu Diretor de Futebol.'
                : 'Escolha a carreira que deseja continuar.',
          ),
          if (_loadError != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(
              message: _loadError!,
              onRetry: _loadSlots,
            ),
          ],
          const SizedBox(height: 16),
          ...List.generate(
            SaveStorageService.slotIds.length,
            (index) {
              final slot = index < _slots.length ? _slots[index] : null;

              final isProcessing = _processingSlotIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SaveSlotCard(
                  index: index,
                  slot: slot,
                  processing: isProcessing,
                  interactionsEnabled: !_isProcessing,
                  onTap: () {
                    _handleTap(
                      index: index,
                      slot: slot,
                    );
                  },
                  onDelete: slot == null ? null : () => _deleteSlot(index),
                ),
              );
            },
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Carregando carreira...',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final String text;

  const _IntroCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              height: 1.35,
            ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorBox({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.danger.withOpacity(0.22),
        ),
      ),
      child: Row(
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
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Tentar novamente',
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _SaveSlotCard extends StatelessWidget {
  final int index;
  final SaveSlotData? slot;
  final bool processing;
  final bool interactionsEnabled;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _SaveSlotCard({
    required this.index,
    required this.slot,
    required this.processing,
    required this.interactionsEnabled,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = slot == null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: interactionsEnabled || processing ? 1 : 0.62,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: interactionsEnabled ? onTap : null,
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _SlotLeading(
                    index: index,
                    slot: slot,
                    processing: processing,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: isEmpty
                        ? _EmptySlotInfo(index: index)
                        : _OccupiedSlotInfo(slot: slot!),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Apagar save',
                      onPressed: interactionsEnabled ? onDelete : null,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                      ),
                      color: AppColors.danger,
                    ),
                  ],
                  const SizedBox(width: 2),
                  processing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                          ),
                        )
                      : const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
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

class _SlotLeading extends StatelessWidget {
  final int index;
  final SaveSlotData? slot;
  final bool processing;

  const _SlotLeading({
    required this.index,
    required this.slot,
    required this.processing,
  });

  @override
  Widget build(BuildContext context) {
    final portraitId = slot?.directorPortraitId?.trim();

    if (portraitId != null && portraitId.isNotEmpty) {
      final assetPath = FootballDirectorPortraitCatalog.assetOf(
        portraitId,
      );

      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: processing ? AppColors.primary : AppColors.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return _SlotNumber(index: index);
            },
          ),
        ),
      );
    }

    return _SlotNumber(index: index);
  }
}

class _SlotNumber extends StatelessWidget {
  final int index;

  const _SlotNumber({
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(17),
      ),
      alignment: Alignment.center,
      child: Text(
        '${index + 1}',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _EmptySlotInfo extends StatelessWidget {
  final int index;

  const _EmptySlotInfo({
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Slot ${index + 1}',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vazio',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OccupiedSlotInfo extends StatelessWidget {
  final SaveSlotData slot;

  const _OccupiedSlotInfo({
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final directorName = slot.directorName?.trim();

    final directorLabel = directorName != null && directorName.isNotEmpty
        ? 'Diretor: $directorName'
        : 'Diretor ainda não criado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          slot.clubName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          directorLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: slot.hasDirectorSummary
                ? AppColors.primaryDark
                : AppColors.warning,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_divisionLabel(slot.divisionId)} • '
          'Temporada ${slot.seasonYear} • '
          'Rodada ${slot.roundIndex}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Comissão nível ${slot.coachLevel} • '
          'Contrato ${slot.contractEndYear}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Salvo em ${_formatSavedAt(slot.savedAtIso)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  static String _divisionLabel(String divisionId) {
    switch (divisionId.trim().toUpperCase()) {
      case 'BR-A':
      case 'BRA':
        return 'Série A';

      case 'BR-B':
      case 'BRB':
        return 'Série B';

      case 'BR-C':
      case 'BRC':
        return 'Série C';

      case 'BR-D':
      case 'BRD':
        return 'Série D';

      default:
        return divisionId.trim().isEmpty
            ? 'Divisão não informada'
            : divisionId.trim();
    }
  }

  static String _formatSavedAt(String iso) {
    final parsed = DateTime.tryParse(iso);

    if (parsed == null) {
      return iso;
    }

    final date = parsed.toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
