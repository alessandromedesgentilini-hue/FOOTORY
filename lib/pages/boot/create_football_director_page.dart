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

  @override
  void initState() {
    super.initState();

    _selectedPortraitId = _defaultPortraitId();

    _favoriteClubId = _firstClubIdOfDivision(
      _favoriteClubDivision,
    );

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

    if (favoriteClubDivision != null) {
      _favoriteClubDivision = favoriteClubDivision;

      _favoriteClubId = director.favoriteClubId;
    }
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

    final favoriteClubId = _favoriteClubId?.trim();

    if (favoriteClubId == null || favoriteClubId.isEmpty) {
      _showMessage(
        'Escolha o clube favorito do Diretor.',
        isError: true,
      );

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

    final director = FootballDirector(
      name: _normalizePersonName(
        _nameController.text,
      ),
      age: parsedAge,
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    _DirectorHero(
                      isExistingCareer: widget.isCompletingExistingCareer,
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Escolha seu retrato',
                      icon: Icons.account_circle_rounded,
                      child: _PortraitSelector(
                        selectedPortraitId: _selectedPortraitId,
                        enabled: !_saving,
                        onSelected: (portraitId) {
                          setState(() {
                            _selectedPortraitId = portraitId;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Informações pessoais',
                      icon: Icons.badge_outlined,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            enabled: !_saving,
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
                              final normalized = _normalizePersonName(
                                value ?? '',
                              );

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
                          const SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            controller: _ageController,
                            enabled: !_saving,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                2,
                              ),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Idade',
                              hintText: 'Entre 18 e 99 anos',
                              prefixIcon: Icon(
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

                              if (age < 18 || age > 99) {
                                return 'A idade deve estar entre 18 e 99 anos.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedCountryCode,
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
                            onChanged: _saving
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      _selectedCountryCode = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Clube do coração',
                      icon: Icons.favorite_rounded,
                      subtitle:
                          'Essa escolha não interfere no clube onde a carreira começará.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FavoriteDivisionSelector(
                            selected: _favoriteClubDivision,
                            enabled: !_saving,
                            onChanged: _changeFavoriteDivision,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
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
                                          errorBuilder: (
                                            _,
                                            __,
                                            ___,
                                          ) {
                                            return const Icon(
                                              Icons.shield_outlined,
                                              size: 22,
                                              color: AppColors.primary,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
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
                            onChanged: _saving
                                ? null
                                : (value) {
                                    setState(() {
                                      _favoriteClubId = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Escola tática favorita',
                      icon: Icons.account_tree_outlined,
                      subtitle:
                          'Essa preferência representa a visão de futebol do Diretor.',
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _favoriteTacticalIdentityId,
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
                            onChanged: _saving
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      _favoriteTacticalIdentityId = value;
                                    });
                                  },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          _TacticalIdentityPreview(
                            identityId: _favoriteTacticalIdentityId,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'O Diretor não possui atributos iniciais. '
                      'Seu legado será construído pelas decisões '
                      'tomadas durante a carreira.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
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
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _continue,
                    icon: _saving
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                            ),
                          )
                        : Icon(
                            widget.isCompletingExistingCareer
                                ? Icons.save_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                    label: Text(
                      _saving
                          ? 'Salvando...'
                          : widget.isCompletingExistingCareer
                              ? 'Salvar Diretor e continuar'
                              : 'Continuar para escolher o clube',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class _DirectorHero extends StatelessWidget {
  final bool isExistingCareer;

  const _DirectorHero({
    required this.isExistingCareer,
  });

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
              Icons.manage_accounts_rounded,
              color: AppColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExistingCareer ? 'Complete seu perfil' : 'Crie seu Diretor',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isExistingCareer
                      ? 'Este save foi criado antes do novo sistema. '
                          'Defina agora quem comanda o projeto esportivo.'
                      : 'Você não é o treinador. Você comanda o futebol, '
                          'escolhe os profissionais e constrói um legado.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.92),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: FootballDirectorPortraitCatalog.all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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
          duration: const Duration(milliseconds: 150),
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
                  color:
                      selected ? AppColors.primarySoft : AppColors.surfaceSoft,
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
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
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
  }
}

class _FavoriteDivisionSelector extends StatelessWidget {
  final DivisionId selected;
  final bool enabled;
  final ValueChanged<DivisionId> onChanged;

  const _FavoriteDivisionSelector({
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
      DivisionId.brD,
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

class _TacticalIdentityPreview extends StatelessWidget {
  final String identityId;

  const _TacticalIdentityPreview({
    required this.identityId,
  });

  @override
  Widget build(BuildContext context) {
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            identity.shortDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

  static String _formatFormation(
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
      (country) {
        return country.code == normalizedCode;
      },
    );
  }
}
