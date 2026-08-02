import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/football_director.dart';
import 'package:footory26/pages/boot/choose_club_page.dart';
import 'package:footory26/services/save/save_storage_service.dart';
import 'package:footory26/services/world/catalog/coach_tactical_catalog.dart';
import 'package:footory26/services/world/catalog/football_director_portrait_catalog.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class CreateFootballDirectorPage extends ConsumerStatefulWidget {
  final String slotId;

  /// Usado quando um save antigo já foi carregado,
  /// mas ainda não possui Diretor de Futebol.
  final bool isCompletingExistingCareer;

  const CreateFootballDirectorPage({
    super.key,
    required this.slotId,
    this.isCompletingExistingCareer = false,
  });

  @override
  ConsumerState<CreateFootballDirectorPage> createState() {
    return _CreateFootballDirectorPageState();
  }
}

class _CreateFootballDirectorPageState
    extends ConsumerState<CreateFootballDirectorPage> {
  static const int _lastStepIndex = 5;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _ageController = TextEditingController();

  final SaveStorageService _saveStorage = SaveStorageService();

  late String _selectedPortraitId;

  String _selectedCountryCode = _CountryCatalog.defaultCountryCode;

  DivisionId _favoriteClubDivision = DivisionId.brA;

  String? _favoriteClubId;

  String _favoriteTacticalIdentityId = CoachTacticalCatalog.fallback.id;

  bool _saving = false;

  int _currentStep = 0;

  bool _ageManuallyEdited = false;

  @override
  void initState() {
    super.initState();

    _selectedPortraitId = _defaultPortraitId();

    _favoriteClubId = _firstClubIdOfDivision(
      _favoriteClubDivision,
    );

    _ageController.text = FootballDirectorPortraitCatalog.suggestedAgeOf(
      _selectedPortraitId,
    ).toString();

    /*
     * Um Diretor existente só deve preencher a tela
     * durante a migração de um save antigo.
     *
     * Em uma carreira nova, nunca reutilizamos dados
     * temporários deixados no GameState por outra tentativa.
     */
    if (widget.isCompletingExistingCareer) {
      _fillExistingDirectorIfAvailable();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();

    super.dispose();
  }

  String _defaultPortraitId() {
    if (FootballDirectorPortraitCatalog.all.isEmpty) {
      throw StateError(
        'O catálogo de retratos dos Diretores está vazio.',
      );
    }

    return FootballDirectorPortraitCatalog.all.first.id;
  }

  void _fillExistingDirectorIfAvailable() {
    final director = ref.read(gameStateProvider).footballDirector;

    if (director == null) return;

    _nameController.text = director.name;
    _ageController.text = director.age.toString();
    _ageManuallyEdited = true;

    if (FootballDirectorPortraitCatalog.containsId(
      director.portraitId,
    )) {
      _selectedPortraitId = director.portraitId;
    }

    final normalizedCountryCode = director.countryCode.trim().toUpperCase();

    if (_CountryCatalog.containsCode(
      normalizedCountryCode,
    )) {
      _selectedCountryCode = normalizedCountryCode;
    }

    final tacticalIdentityExists = CoachTacticalCatalog.all.any(
      (identity) {
        return identity.id == director.favoriteTacticalIdentityId;
      },
    );

    if (tacticalIdentityExists) {
      _favoriteTacticalIdentityId = director.favoriteTacticalIdentityId;
    }

    final favoriteClubDivision = _findClubDivision(
      director.favoriteClubId,
    );

    if (favoriteClubDivision == null) {
      return;
    }

    /*
     * A Série D permanece reconhecida internamente para permitir
     * a leitura de saves antigos, mas não pode ser selecionada
     * como clube do coração na versão atual.
     */
    if (favoriteClubDivision == DivisionId.brD) {
      _favoriteClubDivision = DivisionId.brA;
      _favoriteClubId = _firstClubIdOfDivision(
        DivisionId.brA,
      );

      return;
    }

    _favoriteClubDivision = favoriteClubDivision;
    _favoriteClubId = director.favoriteClubId;
  }

  Future<void> _continue() async {
    if (_saving) return;

    final normalizedSlotId = widget.slotId.trim();

    if (!_saveStorage.isValidSlotId(
      normalizedSlotId,
    )) {
      _showMessage(
        'O slot selecionado não é válido.',
        isError: true,
      );

      return;
    }

    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    if (!FootballDirectorPortraitCatalog.containsId(
      _selectedPortraitId,
    )) {
      _showMessage(
        'Escolha um retrato válido.',
        isError: true,
      );

      return;
    }

    if (!_CountryCatalog.containsCode(
      _selectedCountryCode,
    )) {
      _showMessage(
        'Escolha um país válido.',
        isError: true,
      );

      return;
    }

    if (!_isAllowedFavoriteDivision(
      _favoriteClubDivision,
    )) {
      _showMessage(
        'Escolha um clube das Séries A, B ou C.',
        isError: true,
      );

      return;
    }

    final favoriteClubId = _favoriteClubId?.trim();

    if (favoriteClubId == null || favoriteClubId.isEmpty) {
      _showMessage(
        'Escolha o clube favorito do Diretor.',
        isError: true,
      );

      return;
    }

    final favoriteClubExists = BrazilClubCatalog.byDivision(
      _favoriteClubDivision,
    ).any(
      (club) => club.id == favoriteClubId,
    );

    if (!favoriteClubExists) {
      _showMessage(
        'O clube favorito selecionado não pertence '
        'à divisão informada.',
        isError: true,
      );

      return;
    }

    final tacticalIdentityExists = CoachTacticalCatalog.all.any(
      (identity) {
        return identity.id == _favoriteTacticalIdentityId;
      },
    );

    if (!tacticalIdentityExists) {
      _showMessage(
        'Escolha uma escola tática válida.',
        isError: true,
      );

      return;
    }

    final parsedAge = int.tryParse(
      _ageController.text.trim(),
    );

    if (parsedAge == null) {
      _showMessage(
        'Informe uma idade válida.',
        isError: true,
      );

      return;
    }

    if (!FootballDirectorPortraitCatalog.isAllowedAge(
      parsedAge,
    )) {
      _showMessage(
        'A idade deve estar entre '
        '${FootballDirectorPortraitCatalog.minimumAllowedAge} e '
        '${FootballDirectorPortraitCatalog.maximumAllowedAge} anos.',
        isError: true,
      );

      return;
    }

    final normalizedAge = FootballDirectorPortraitCatalog.normalizeAge(
      parsedAge,
    );

    final director = FootballDirector(
      name: _normalizePersonName(
        _nameController.text,
      ),
      age: normalizedAge,
      countryCode: _selectedCountryCode.trim().toUpperCase(),
      favoriteClubId: favoriteClubId,
      favoriteTacticalIdentityId: _favoriteTacticalIdentityId,
      portraitId: _selectedPortraitId,
    );

    if (!director.hasRequiredData) {
      _showMessage(
        'Preencha todos os dados obrigatórios.',
        isError: true,
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final gameState = ref.read(
        gameStateProvider,
      );

      gameState.currentSaveSlotId = normalizedSlotId;

      gameState.assignFootballDirector(
        director,
      );

      if (widget.isCompletingExistingCareer) {
        await _completeExistingCareer(
          gameState: gameState,
          slotId: normalizedSlotId,
        );

        return;
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) {
            return ChooseClubPage(
              slotId: normalizedSlotId,
            );
          },
        ),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Erro ao criar Diretor de Futebol: $error',
      );
      debugPrint('$stackTrace');

      if (!mounted) return;

      _showMessage(
        'Não foi possível continuar.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _completeExistingCareer({
    required dynamic gameState,
    required String slotId,
  }) async {
    if (!gameState.isInitialized) {
      throw StateError(
        'A carreira antiga não está inicializada.',
      );
    }

    if (!gameState.hasSelectedCoachStaff) {
      throw StateError(
        'A carreira antiga não possui '
        'um treinador válido.',
      );
    }

    if (!gameState.hasFootballDirector) {
      throw StateError(
        'O Diretor de Futebol não foi atribuído.',
      );
    }

    await _saveStorage.saveFromGameState(
      slotId: slotId,
      gs: gameState,
    );

    if (!mounted) return;

    /*
     * Quem abriu esta página controla o próximo destino.
     * No fluxo atual, ChooseSaveSlotPage receberá o resultado
     * e seguirá para o Hub.
     */
    Navigator.of(context).pop(true);
  }

  String _normalizePersonName(
    String value,
  ) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .join(' ');
  }

  void _changeFavoriteDivision(
    DivisionId division,
  ) {
    if (_saving) return;

    if (!_isAllowedFavoriteDivision(
      division,
    )) {
      return;
    }

    if (_favoriteClubDivision == division) {
      return;
    }

    setState(() {
      _favoriteClubDivision = division;

      _favoriteClubId = _firstClubIdOfDivision(
        division,
      );
    });
  }

  bool _isAllowedFavoriteDivision(
    DivisionId division,
  ) {
    return division == DivisionId.brA ||
        division == DivisionId.brB ||
        division == DivisionId.brC;
  }

  String? _firstClubIdOfDivision(
    DivisionId division,
  ) {
    final clubs = BrazilClubCatalog.byDivision(
      division,
    );

    if (clubs.isEmpty) {
      return null;
    }

    return clubs.first.id;
  }

  DivisionId? _findClubDivision(
    String clubId,
  ) {
    final normalizedClubId = clubId.trim();

    if (normalizedClubId.isEmpty) {
      return null;
    }

    for (final division in DivisionId.values) {
      final exists = BrazilClubCatalog.byDivision(
        division,
      ).any(
        (club) => club.id == normalizedClubId,
      );

      if (exists) {
        return division;
      }
    }

    return null;
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

  void _onPortraitSelected(
    String portraitId,
  ) {
    if (_saving) return;

    if (!FootballDirectorPortraitCatalog.containsId(
      portraitId,
    )) {
      return;
    }

    setState(() {
      _selectedPortraitId = portraitId;

      if (!_ageManuallyEdited) {
        _ageController.text = FootballDirectorPortraitCatalog.suggestedAgeOf(
          portraitId,
        ).toString();
      }
    });
  }

  void _onAgeChanged() {
    _ageManuallyEdited = true;
  }

  void _onBack() {
    if (_saving || _currentStep <= 0) {
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  void _onContinue() {
    if (_saving) return;

    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < _lastStepIndex) {
      setState(() {
        _currentStep++;
      });

      return;
    }

    _continue();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (!FootballDirectorPortraitCatalog.containsId(
          _selectedPortraitId,
        )) {
          _showMessage(
            'Escolha um retrato válido.',
            isError: true,
          );

          return false;
        }

        return true;

      case 1:
        final formState = _formKey.currentState;

        if (formState == null || !formState.validate()) {
          return false;
        }

        return true;

      case 2:
        if (!_CountryCatalog.containsCode(
          _selectedCountryCode,
        )) {
          _showMessage(
            'Escolha um país válido.',
            isError: true,
          );

          return false;
        }

        return true;

      case 3:
        if (!_isAllowedFavoriteDivision(
          _favoriteClubDivision,
        )) {
          _showMessage(
            'Escolha um clube das Séries A, B ou C.',
            isError: true,
          );

          return false;
        }

        final favoriteClubs = BrazilClubCatalog.byDivision(
          _favoriteClubDivision,
        );

        final favoriteClubId = _favoriteClubId;

        if (favoriteClubId == null ||
            !favoriteClubs.any(
              (club) => club.id == favoriteClubId,
            )) {
          _showMessage(
            'Escolha um clube válido.',
            isError: true,
          );

          return false;
        }

        return true;

      case 4:
        final tacticalIdentityExists = CoachTacticalCatalog.all.any(
          (identity) {
            return identity.id == _favoriteTacticalIdentityId;
          },
        );

        if (!tacticalIdentityExists) {
          _showMessage(
            'Escolha uma escola tática válida.',
            isError: true,
          );

          return false;
        }

        return true;

      case 5:
        return true;

      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteClubs = BrazilClubCatalog.byDivision(
      _favoriteClubDivision,
    );

    final validFavoriteClubValue = favoriteClubs.any(
      (club) => club.id == _favoriteClubId,
    )
        ? _favoriteClubId
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isCompletingExistingCareer
              ? 'Criar Diretor'
              : 'Seu Diretor de Futebol',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _DirectorProgressIndicator(
                currentStep: _currentStep,
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _PortraitStep(
                      selectedPortraitId: _selectedPortraitId,
                      enabled: !_saving,
                      onSelected: _onPortraitSelected,
                    ),
                    _PersonalDataStep(
                      nameController: _nameController,
                      ageController: _ageController,
                      selectedPortraitId: _selectedPortraitId,
                      enabled: !_saving,
                      onAgeChanged: _onAgeChanged,
                    ),
                    _CountryStep(
                      selectedCountryCode: _selectedCountryCode,
                      selectedPortraitId: _selectedPortraitId,
                      enabled: !_saving,
                      onCountryChanged: (value) {
                        setState(() {
                          _selectedCountryCode = value;
                        });
                      },
                    ),
                    _FavoriteClubStep(
                      favoriteClubDivision: _favoriteClubDivision,
                      favoriteClubId: validFavoriteClubValue,
                      enabled: !_saving,
                      onDivisionChanged: _changeFavoriteDivision,
                      onClubChanged: (value) {
                        setState(() {
                          _favoriteClubId = value;
                        });
                      },
                    ),
                    _TacticalIdentityStep(
                      favoriteTacticalIdentityId: _favoriteTacticalIdentityId,
                      enabled: !_saving,
                      onIdentityChanged: (value) {
                        setState(() {
                          _favoriteTacticalIdentityId = value;
                        });
                      },
                    ),
                    _DirectorConfirmationStep(
                      selectedPortraitId: _selectedPortraitId,
                      nameController: _nameController,
                      ageController: _ageController,
                      selectedCountryCode: _selectedCountryCode,
                      favoriteClubDivision: _favoriteClubDivision,
                      favoriteClubId: _favoriteClubId,
                      favoriteTacticalIdentityId: _favoriteTacticalIdentityId,
                    ),
                  ],
                ),
              ),
              _BottomNavigationBar(
                currentStep: _currentStep,
                saving: _saving,
                isCompletingExistingCareer: widget.isCompletingExistingCareer,
                onBack: _onBack,
                onContinue: _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectorProgressIndicator extends StatelessWidget {
  static const List<String> _stepTitles = <String>[
    'Retrato',
    'Nome e idade',
    'Nacionalidade',
    'Clube do coração',
    'Filosofia tática',
    'Confirmação',
  ];

  final int currentStep;

  const _DirectorProgressIndicator({
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final safeStep = currentStep.clamp(
      0,
      _stepTitles.length - 1,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        10,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              _stepTitles.length,
              (index) {
                final completed = index < safeStep;
                final current = index == safeStep;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < _stepTitles.length - 1 ? 6 : 0,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      height: 5,
                      decoration: BoxDecoration(
                        color: completed || current
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(
                          999,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${safeStep + 1}',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Etapa ${safeStep + 1} de ${_stepTitles.length}',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _stepTitles[safeStep],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
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

class _PortraitStep extends StatelessWidget {
  final String selectedPortraitId;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _PortraitStep({
    required this.selectedPortraitId,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Escolha seu retrato',
            description: 'Selecione a aparência do seu Diretor de Futebol.',
          ),
          const SizedBox(height: 16),
          _PortraitSelector(
            selectedPortraitId: selectedPortraitId,
            enabled: enabled,
            onSelected: onSelected,
          ),
          const SizedBox(height: 16),
          _SelectedPortraitInfo(
            portraitId: selectedPortraitId,
          ),
        ],
      ),
    );
  }
}

class _SelectedPortraitInfo extends StatelessWidget {
  final String portraitId;

  const _SelectedPortraitInfo({
    required this.portraitId,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final suggestedAge = FootballDirectorPortraitCatalog.suggestedAgeOf(
      portraitId,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Idade sugerida para este retrato: $suggestedAge anos',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalDataStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final String selectedPortraitId;
  final bool enabled;
  final VoidCallback onAgeChanged;

  const _PersonalDataStep({
    required this.nameController,
    required this.ageController,
    required this.selectedPortraitId,
    required this.enabled,
    required this.onAgeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Nome e idade',
            description:
                'Defina como seu Diretor será chamado e qual será sua idade.',
          ),
          const SizedBox(height: 16),
          _CompactPortrait(
            portraitId: selectedPortraitId,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            enabled: enabled,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLength: 32,
            decoration: const InputDecoration(
              labelText: 'Nome',
              hintText: 'Como seu Diretor será chamado?',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
              ),
              counterText: '',
            ),
            validator: (value) {
              final normalized = (value ?? '')
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((part) => part.isNotEmpty)
                  .join(' ');

              if (normalized.isEmpty) {
                return 'Informe o nome do Diretor.';
              }

              if (normalized.length < 2) {
                return 'O nome precisa ter pelo menos 2 caracteres.';
              }

              if (normalized.length > 32) {
                return 'O nome pode ter no máximo 32 caracteres.';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: ageController,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                2,
              ),
            ],
            onChanged: (_) {
              onAgeChanged();
            },
            decoration: InputDecoration(
              labelText: 'Idade',
              hintText:
                  'Entre ${FootballDirectorPortraitCatalog.minimumAllowedAge} '
                  'e ${FootballDirectorPortraitCatalog.maximumAllowedAge} anos',
              prefixIcon: const Icon(
                Icons.cake_outlined,
              ),
            ),
            validator: (value) {
              final age = int.tryParse(
                value?.trim() ?? '',
              );

              if (age == null) {
                return 'Informe uma idade válida.';
              }

              if (!FootballDirectorPortraitCatalog.isAllowedAge(
                age,
              )) {
                return 'A idade deve estar entre '
                    '${FootballDirectorPortraitCatalog.minimumAllowedAge} e '
                    '${FootballDirectorPortraitCatalog.maximumAllowedAge} anos.';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _CompactPortrait extends StatelessWidget {
  final String portraitId;

  const _CompactPortrait({
    required this.portraitId,
  });

  @override
  Widget build(BuildContext context) {
    final portrait = FootballDirectorPortraitCatalog.byId(
      portraitId,
    );

    if (portrait == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            portrait.assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 42,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CountryStep extends StatelessWidget {
  final String selectedCountryCode;
  final String selectedPortraitId;
  final bool enabled;
  final ValueChanged<String> onCountryChanged;

  const _CountryStep({
    required this.selectedCountryCode,
    required this.selectedPortraitId,
    required this.enabled,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Nacionalidade',
            description:
                'Selecione o país de origem do seu Diretor de Futebol.',
          ),
          const SizedBox(height: 16),
          _CompactPortrait(
            portraitId: selectedPortraitId,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedCountryCode,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'País',
              prefixIcon: Icon(
                Icons.public_rounded,
              ),
            ),
            items: _CountryCatalog.all.map(
              (country) {
                return DropdownMenuItem<String>(
                  value: country.code,
                  child: Text(
                    country.name,
                  ),
                );
              },
            ).toList(),
            onChanged: enabled
                ? (value) {
                    if (value == null) return;

                    onCountryChanged(value);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _FavoriteClubStep extends StatelessWidget {
  final DivisionId favoriteClubDivision;
  final String? favoriteClubId;
  final bool enabled;
  final ValueChanged<DivisionId> onDivisionChanged;
  final ValueChanged<String?> onClubChanged;

  const _FavoriteClubStep({
    required this.favoriteClubDivision,
    required this.favoriteClubId,
    required this.enabled,
    required this.onDivisionChanged,
    required this.onClubChanged,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteClubs = BrazilClubCatalog.byDivision(
      favoriteClubDivision,
    );

    final validFavoriteClubValue = favoriteClubs.any(
      (club) => club.id == favoriteClubId,
    )
        ? favoriteClubId
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Clube do coração',
            description:
                'Essa escolha representa sua ligação pessoal e não define '
                'o clube inicial da carreira.',
          ),
          const SizedBox(height: 16),
          _RestrictedDivisionSelector(
            selected: favoriteClubDivision,
            enabled: enabled,
            onChanged: onDivisionChanged,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: validFavoriteClubValue,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Clube favorito',
              prefixIcon: Icon(
                Icons.shield_outlined,
              ),
            ),
            items: favoriteClubs.map(
              (club) {
                return DropdownMenuItem<String>(
                  value: club.id,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Image.asset(
                          club.badgeAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.shield_outlined,
                              size: 22,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
            onChanged: enabled ? onClubChanged : null,
          ),
        ],
      ),
    );
  }
}

class _RestrictedDivisionSelector extends StatelessWidget {
  final DivisionId selected;
  final bool enabled;
  final ValueChanged<DivisionId> onChanged;

  const _RestrictedDivisionSelector({
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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: divisions.map(
        (division) {
          return ChoiceChip(
            label: Text(
              _divisionLabel(
                division,
              ),
            ),
            selected: division == selected,
            onSelected: enabled
                ? (_) {
                    onChanged(
                      division,
                    );
                  }
                : null,
          );
        },
      ).toList(),
    );
  }

  static String _divisionLabel(
    DivisionId division,
  ) {
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

class _TacticalIdentityStep extends StatelessWidget {
  final String favoriteTacticalIdentityId;
  final bool enabled;
  final ValueChanged<String> onIdentityChanged;

  const _TacticalIdentityStep({
    required this.favoriteTacticalIdentityId,
    required this.enabled,
    required this.onIdentityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Filosofia tática',
            description: 'Defina a visão de futebol preferida do seu Diretor.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: favoriteTacticalIdentityId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Escola tática',
              prefixIcon: Icon(
                Icons.sports_soccer_rounded,
              ),
            ),
            items: CoachTacticalCatalog.all.map(
              (identity) {
                return DropdownMenuItem<String>(
                  value: identity.id,
                  child: Text(
                    identity.name,
                  ),
                );
              },
            ).toList(),
            onChanged: enabled
                ? (value) {
                    if (value == null) return;

                    onIdentityChanged(value);
                  }
                : null,
          ),
          const SizedBox(height: 16),
          _TacticalIdentityPreview(
            identityId: favoriteTacticalIdentityId,
          ),
        ],
      ),
    );
  }
}

class _DirectorConfirmationStep extends StatelessWidget {
  final String selectedPortraitId;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final String selectedCountryCode;
  final DivisionId favoriteClubDivision;
  final String? favoriteClubId;
  final String favoriteTacticalIdentityId;

  const _DirectorConfirmationStep({
    required this.selectedPortraitId,
    required this.nameController,
    required this.ageController,
    required this.selectedCountryCode,
    required this.favoriteClubDivision,
    required this.favoriteClubId,
    required this.favoriteTacticalIdentityId,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final portrait = FootballDirectorPortraitCatalog.byId(
      selectedPortraitId,
    );

    final country = _CountryCatalog.fromCode(
      selectedCountryCode,
    );

    final club = _findClub(
      division: favoriteClubDivision,
      clubId: favoriteClubId,
    );

    final tacticalIdentity = CoachTacticalCatalog.fromId(
      favoriteTacticalIdentityId,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Confirmação',
            description: 'Revise os dados do seu Diretor antes de continuar.',
          ),
          const SizedBox(height: 20),
          if (portrait != null)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(27),
                  child: Image.asset(
                    portrait.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          _ConfirmationRow(
            label: 'Nome',
            value: nameController.text.trim(),
          ),
          const SizedBox(height: 12),
          _ConfirmationRow(
            label: 'Idade',
            value: '${ageController.text.trim()} anos',
          ),
          const SizedBox(height: 12),
          _ConfirmationRow(
            label: 'País',
            value: country.name,
          ),
          if (club != null) ...[
            const SizedBox(height: 12),
            _ConfirmationRow(
              label: 'Clube do coração',
              value: club.name,
              assetPath: club.badgeAsset,
            ),
          ],
          const SizedBox(height: 12),
          _ConfirmationRow(
            label: 'Escola tática',
            value: tacticalIdentity.name,
          ),
          const SizedBox(height: 12),
          _ConfirmationRow(
            label: 'Formação de referência',
            value: _formatFormation(
              tacticalIdentity.mainFormation,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'O Diretor não possui atributos iniciais. '
                  'Seu legado será construído pelas decisões '
                  'tomadas durante a carreira.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static dynamic _findClub({
    required DivisionId division,
    required String? clubId,
  }) {
    if (clubId == null || clubId.trim().isEmpty) {
      return null;
    }

    final clubs = BrazilClubCatalog.byDivision(
      division,
    );

    for (final club in clubs) {
      if (club.id == clubId) {
        return club;
      }
    }

    return null;
  }
}

class _ConfirmationRow extends StatelessWidget {
  final String label;
  final String value;
  final String? assetPath;

  const _ConfirmationRow({
    required this.label,
    required this.value,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          if (assetPath != null) ...[
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                assetPath!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.shield_outlined,
                    size: 24,
                    color: AppColors.primary,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
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

class _StepHeader extends StatelessWidget {
  final String title;
  final String description;

  const _StepHeader({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  final int currentStep;
  final bool saving;
  final bool isCompletingExistingCareer;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const _BottomNavigationBar({
    required this.currentStep,
    required this.saving,
    required this.isCompletingExistingCareer,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == 5;

    final primaryLabel = isLastStep
        ? isCompletingExistingCareer
            ? 'Salvar Diretor e continuar'
            : 'Continuar para escolher o clube'
        : 'Continuar';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: saving ? null : onBack,
                child: const Text(
                  'Voltar',
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: currentStep > 0 ? 2 : 1,
            child: FilledButton(
              onPressed: saving ? null : onContinue,
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      primaryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitSelector extends StatelessWidget {
  final String selectedPortraitId;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _PortraitSelector({
    required this.selectedPortraitId,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final columns = constraints.maxWidth < 340 ? 2 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: FootballDirectorPortraitCatalog.all.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.86,
          ),
          itemBuilder: (
            context,
            index,
          ) {
            final portrait = FootballDirectorPortraitCatalog.all[index];

            final selected = portrait.id == selectedPortraitId;

            return AnimatedOpacity(
              duration: const Duration(
                milliseconds: 150,
              ),
              opacity: enabled ? 1 : 0.65,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled
                      ? () {
                          onSelected(
                            portrait.id,
                          );
                        }
                      : null,
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 170,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySoft
                          : AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            portrait.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 42,
                                ),
                              );
                            },
                          ),
                        ),
                        if (selected)
                          Positioned(
                            top: 7,
                            right: 7,
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(
                                  999,
                                ),
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TacticalIdentityPreview extends StatelessWidget {
  final String identityId;

  const _TacticalIdentityPreview({
    required this.identityId,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final identity = CoachTacticalCatalog.fromId(
      identityId,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            identity.name,
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            identity.shortDescription,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.text,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Formação de referência: '
                  '${_formatFormation(identity.mainFormation)}',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryOption {
  final String code;
  final String name;

  const _CountryOption({
    required this.code,
    required this.name,
  });
}

class _CountryCatalog {
  static const String defaultCountryCode = 'BR';

  static const List<_CountryOption> all = <_CountryOption>[
    _CountryOption(
      code: 'AR',
      name: 'Argentina',
    ),
    _CountryOption(
      code: 'DE',
      name: 'Alemanha',
    ),
    _CountryOption(
      code: 'SA',
      name: 'Arábia Saudita',
    ),
    _CountryOption(
      code: 'BO',
      name: 'Bolívia',
    ),
    _CountryOption(
      code: 'BR',
      name: 'Brasil',
    ),
    _CountryOption(
      code: 'CM',
      name: 'Camarões',
    ),
    _CountryOption(
      code: 'CL',
      name: 'Chile',
    ),
    _CountryOption(
      code: 'CN',
      name: 'China',
    ),
    _CountryOption(
      code: 'CO',
      name: 'Colômbia',
    ),
    _CountryOption(
      code: 'KR',
      name: 'Coreia do Sul',
    ),
    _CountryOption(
      code: 'CI',
      name: 'Costa do Marfim',
    ),
    _CountryOption(
      code: 'CR',
      name: 'Costa Rica',
    ),
    _CountryOption(
      code: 'EC',
      name: 'Equador',
    ),
    _CountryOption(
      code: 'EG',
      name: 'Egito',
    ),
    _CountryOption(
      code: 'ES',
      name: 'Espanha',
    ),
    _CountryOption(
      code: 'US',
      name: 'Estados Unidos',
    ),
    _CountryOption(
      code: 'FR',
      name: 'França',
    ),
    _CountryOption(
      code: 'GH',
      name: 'Gana',
    ),
    _CountryOption(
      code: 'NL',
      name: 'Holanda',
    ),
    _CountryOption(
      code: 'ENG',
      name: 'Inglaterra',
    ),
    _CountryOption(
      code: 'IT',
      name: 'Itália',
    ),
    _CountryOption(
      code: 'JP',
      name: 'Japão',
    ),
    _CountryOption(
      code: 'MX',
      name: 'México',
    ),
    _CountryOption(
      code: 'NG',
      name: 'Nigéria',
    ),
    _CountryOption(
      code: 'NZ',
      name: 'Nova Zelândia',
    ),
    _CountryOption(
      code: 'PY',
      name: 'Paraguai',
    ),
    _CountryOption(
      code: 'PE',
      name: 'Peru',
    ),
    _CountryOption(
      code: 'PT',
      name: 'Portugal',
    ),
    _CountryOption(
      code: 'SN',
      name: 'Senegal',
    ),
    _CountryOption(
      code: 'TR',
      name: 'Turquia',
    ),
    _CountryOption(
      code: 'UY',
      name: 'Uruguai',
    ),
    _CountryOption(
      code: 'VE',
      name: 'Venezuela',
    ),
  ];

  static bool containsCode(
    String code,
  ) {
    final normalizedCode = code.trim().toUpperCase();

    return all.any(
      (country) => country.code == normalizedCode,
    );
  }

  static _CountryOption fromCode(
    String code,
  ) {
    final normalizedCode = code.trim().toUpperCase();

    for (final country in all) {
      if (country.code == normalizedCode) {
        return country;
      }
    }

    return all.firstWhere(
      (country) => country.code == defaultCountryCode,
      orElse: () => all.first,
    );
  }
}

String _formatFormation(
  String formation,
) {
  switch (formation.trim().toLowerCase()) {
    case '343':
      return '3-4-3';

    case '352':
      return '3-5-2';

    case '433':
      return '4-3-3';

    case '442':
    case '442_flat':
      return '4-4-2';

    case '4141':
      return '4-1-4-1';

    case '4231':
    case '4231_wide':
      return '4-2-3-1';

    case '4312':
      return '4-3-1-2';

    default:
      return formation;
  }
}
