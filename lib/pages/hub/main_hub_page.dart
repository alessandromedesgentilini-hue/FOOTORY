import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/providers.dart';
import 'package:footory26/models/fixture.dart';
import 'package:footory26/models/player.dart';

import 'package:footory26/pages/club/structures_page.dart';
import 'package:footory26/pages/coach/coach_page.dart';
import 'package:footory26/pages/director/football_director_page.dart';
import 'package:footory26/pages/director/permanent_staff_page.dart';
import 'package:footory26/pages/finance/finance_page.dart';
import 'package:footory26/pages/hub/widgets/hub_contextual_standings.dart';
import 'package:footory26/pages/hub/widgets/hub_director_hero.dart';
import 'package:footory26/pages/hub/widgets/hub_executive_summary.dart';
import 'package:footory26/pages/hub/widgets/hub_messages_counter.dart';
import 'package:footory26/pages/hub/widgets/hub_next_match_block.dart';
import 'package:footory26/pages/hub/widgets/hub_permanent_staff_preview.dart';
import 'package:footory26/pages/hub/widgets/hub_secondary_nav.dart';
import 'package:footory26/pages/market/market_page.dart';
import 'package:footory26/pages/market/transfer_offer_dialog.dart';
import 'package:footory26/pages/match_preview/match_preview_page.dart';
import 'package:footory26/pages/match_preview/models/match_preview_player.dart';
import 'package:footory26/pages/messages/messages_page.dart';
import 'package:footory26/pages/my_club/my_club_page.dart';
import 'package:footory26/pages/observation/observation_page.dart';
import 'package:footory26/pages/season/season_report_page.dart';
import 'package:footory26/pages/standings/standings_page.dart';

import 'package:footory26/services/lineup/auto_lineup_service.dart';
import 'package:footory26/services/save/save_storage_service.dart';
import 'package:footory26/services/world/catalog/coach_tactical_catalog.dart';
import 'package:footory26/services/world/catalog/permanent_staff_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

class MainHubPage extends ConsumerStatefulWidget {
  const MainHubPage({super.key});

  @override
  ConsumerState<MainHubPage> createState() => _MainHubPageState();
}

class _MainHubPageState extends ConsumerState<MainHubPage> {
  final SaveStorageService _saveStorage = SaveStorageService();
  final AutoLineupService _autoLineupService = const AutoLineupService();

  bool _checkpointDialogOpen = false;
  bool _transferDialogOpen = false;
  bool _marketOpportunityDialogOpen = false;
  bool _seasonReportOpening = false;
  bool _seasonReportShownForCurrentSeasonEnd = false;
  bool _savingGame = false;
  bool _pendingUiCheckScheduled = false;
  bool _openingMatchLive = false;

  final Set<String> _shownMarketOpportunityLines = <String>{};

  @override
  void initState() {
    super.initState();
    _schedulePendingUiChecks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedulePendingUiChecks();
  }

  void _schedulePendingUiChecks() {
    if (_pendingUiCheckScheduled) return;

    _pendingUiCheckScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _pendingUiCheckScheduled = false;

      if (!mounted) return;

      await _runPendingUiFlows();
    });
  }

  Future<void> _runPendingUiFlows() async {
    if (!mounted) return;
    if (_openingMatchLive) return;

    _maybeResetSeasonReportFlag();

    await _maybeShowCheckpointModal();
    if (!mounted) return;

    await _maybeShowTransferOfferModal();
    if (!mounted) return;

    await _maybeShowMarketOpportunityModal();
    if (!mounted) return;

    await _maybeOpenSeasonReport();
  }

  void _maybeResetSeasonReportFlag() {
    final gs = ref.read(gameStateProvider);

    if (!gs.seasonEnded) {
      _seasonReportShownForCurrentSeasonEnd = false;
    }
  }

  Future<void> _saveGameManually() async {
    if (_savingGame) return;

    setState(() {
      _savingGame = true;
    });

    try {
      final gs = ref.read(gameStateProvider);
      final slotId = await _saveStorage.loadLastActiveSlotId();

      if (slotId == null || slotId.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhum slot ativo encontrado para salvar.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      await _saveStorage.saveFromGameState(
        slotId: slotId,
        gs: gs,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jogo salvo com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao salvar o jogo.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingGame = false;
        });
      }
    }
  }

  Future<void> _maybeShowCheckpointModal() async {
    if (_checkpointDialogOpen) return;
    if (_openingMatchLive) return;

    final route = ModalRoute.of(context);

    if (route == null || !route.isCurrent) return;

    final gs = ref.read(gameStateProvider);
    final checkpoint = gs.pendingCheckpoint;

    if (checkpoint == null) return;

    _checkpointDialogOpen = true;

    try {
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(checkpoint.title),
            content: Text(checkpoint.body),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      ref.read(gameStateProvider).consumePendingCheckpoint();
    } finally {
      _checkpointDialogOpen = false;
    }
  }

  Future<void> _maybeShowTransferOfferModal() async {
    if (_transferDialogOpen) return;
    if (_checkpointDialogOpen) return;
    if (_openingMatchLive) return;

    final route = ModalRoute.of(context);

    if (route == null || !route.isCurrent) return;

    final gs = ref.read(gameStateProvider);
    final offer = gs.pendingTransferOffer;

    if (offer == null) return;

    _transferDialogOpen = true;

    try {
      if (!mounted) return;

      final decision = await showDialog<TransferOfferDecision>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return TransferOfferDialog(
            offer: offer,
            fromClubName: gs.clubName(offer.fromClubId),
            toClubName: gs.clubName(offer.toClubId),
          );
        },
      );

      if (!mounted) return;

      final state = ref.read(gameStateProvider);
      String? message;

      switch (decision) {
        case TransferOfferDecision.accept:
          message = state.acceptPendingTransferOffer(
            addToObservation: false,
          );
          break;

        case TransferOfferDecision.acceptAndObserve:
          message = state.acceptPendingTransferOffer(
            addToObservation: true,
          );
          break;

        case TransferOfferDecision.reject:
          message = state.rejectPendingTransferOffer();
          break;

        case null:
          message = null;
          break;
      }

      if (!mounted) return;

      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _transferDialogOpen = false;
    }
  }

  Future<void> _maybeShowMarketOpportunityModal() async {
    if (_marketOpportunityDialogOpen) return;
    if (_checkpointDialogOpen) return;
    if (_transferDialogOpen) return;
    if (_seasonReportOpening) return;
    if (_openingMatchLive) return;

    final route = ModalRoute.of(context);

    if (route == null || !route.isCurrent) return;

    final gs = ref.read(gameStateProvider);

    final opportunityLine = gs.newsFeed.cast<String?>().firstWhere(
          (line) =>
              line != null &&
              line.toLowerCase().contains(
                    'oportunidade de mercado',
                  ),
          orElse: () => null,
        );

    if (opportunityLine == null) return;

    if (_shownMarketOpportunityLines.contains(opportunityLine)) {
      return;
    }

    _shownMarketOpportunityLines.add(opportunityLine);
    _marketOpportunityDialogOpen = true;

    try {
      if (!mounted) return;

      final openMarket = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Oportunidade de Mercado'),
            content: Text(opportunityLine),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Ver depois'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                icon: const Icon(Icons.search_rounded),
                label: const Text('Avaliar oportunidade'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (openMarket == true) {
        _openMarket();
      }
    } finally {
      _marketOpportunityDialogOpen = false;
    }
  }

  Future<void> _maybeOpenSeasonReport() async {
    if (_seasonReportOpening) return;
    if (_checkpointDialogOpen) return;
    if (_transferDialogOpen) return;
    if (_marketOpportunityDialogOpen) return;
    if (_openingMatchLive) return;

    final route = ModalRoute.of(context);

    if (route == null || !route.isCurrent) return;

    final gs = ref.read(gameStateProvider);

    if (!gs.seasonEnded) {
      _seasonReportShownForCurrentSeasonEnd = false;
      return;
    }

    if (gs.lastSeasonReport == null) return;
    if (_seasonReportShownForCurrentSeasonEnd) return;

    await _openSeasonReport(
      markAsShown: true,
    );
  }

  Future<void> _openSeasonReport({
    required bool markAsShown,
  }) async {
    if (_seasonReportOpening) return;

    final gs = ref.read(gameStateProvider);
    final report = gs.lastSeasonReport;

    if (report == null) return;

    _seasonReportOpening = true;

    if (markAsShown) {
      _seasonReportShownForCurrentSeasonEnd = true;
    }

    try {
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return SeasonReportPage(
              report: report,
            );
          },
        ),
      );
    } finally {
      _seasonReportOpening = false;

      if (mounted) {
        _schedulePendingUiChecks();
      }
    }
  }

  Future<void> _simulateRoundOrNextSeason() async {
    final gs = ref.read(gameStateProvider);

    if (!gs.isInitialized) return;

    if (gs.seasonEnded) {
      if (gs.lastSeasonReport != null &&
          !_seasonReportShownForCurrentSeasonEnd) {
        await _openSeasonReport(
          markAsShown: true,
        );

        return;
      }

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Iniciar Nova Temporada'),
            content: const Text(
              'Deseja iniciar a próxima temporada?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Iniciar'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !mounted) return;

      _seasonReportShownForCurrentSeasonEnd = false;
      ref.read(gameStateProvider).startNextSeason();
      _schedulePendingUiChecks();

      return;
    }

    if (_openingMatchLive) return;

    final nextFixture = _nextUserFixture(gs);

    if (nextFixture == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhuma partida disponível para esta rodada.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    _openingMatchLive = true;

    try {
      final squad = gs.getProSquad();
      final coachStaff = gs.selectedCoachStaffOrFallback;

      final tacticalIdentity = CoachTacticalCatalog.fromId(
        coachStaff.tacticalIdentityId,
      );

      final lineup = _autoLineupService.build(
        squad: squad,
        formation: tacticalIdentity.mainFormation,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return MatchPreviewPage(
              homeClubName: gs.clubName(
                nextFixture.homeClubId,
              ),
              awayClubName: gs.clubName(
                nextFixture.awayClubId,
              ),
              userClubName: gs.userClubName,
              tacticalIdentityId: coachStaff.tacticalIdentityId,
              starters: lineup.starters.map(_toPreviewPlayer).toList(),
              reserves: lineup.reserves.map(_toPreviewPlayer).toList(),
              momentText: _buildMomentText(gs),
              opponentReport: _buildOpponentReport(
                gs,
                nextFixture,
              ),
            );
          },
        ),
      );
    } finally {
      _openingMatchLive = false;

      if (mounted) {
        _schedulePendingUiChecks();
      }
    }
  }

  MatchPreviewPlayer _toPreviewPlayer(Player player) {
    return MatchPreviewPlayer(
      name: player.nome,
      position: player.posLabel,
      overall: player.ovrCheio,
      faceAsset: player.faceAsset,
    );
  }

  String _buildMomentText(GameState gs) {
    if (gs.userWinStreak >= 3) {
      return '${gs.userClubName} chega embalado por uma sequência forte '
          'de vitórias. O ambiente é de confiança antes da partida.';
    }

    if (gs.userLoseStreak >= 2) {
      return '${gs.userClubName} entra pressionado após resultados ruins. '
          'A comissão busca uma resposta imediata em campo.';
    }

    if (gs.userDrawStreak >= 2) {
      return '${gs.userClubName} vem de empates seguidos. O time compete, '
          'mas precisa transformar equilíbrio em vitória.';
    }

    return '${gs.userClubName} chega para a rodada em momento estável. '
        'A comissão aposta na execução do plano de jogo.';
  }

  String _buildOpponentReport(
    GameState gs,
    Fixture fixture,
  ) {
    final opponentId = fixture.homeClubId == gs.userClubId
        ? fixture.awayClubId
        : fixture.homeClubId;

    final opponentName = gs.clubName(opponentId);

    final userPower = gs.clubPower10(
      gs.userClubId,
    );

    final opponentPower = gs.clubPower10(
      opponentId,
    );

    final difference = opponentPower - userPower;

    if (difference >= 0.8) {
      return '$opponentName chega como adversário perigoso e tecnicamente '
          'superior. Será preciso competir com organização e reduzir erros.';
    }

    if (difference <= -0.8) {
      return '$opponentName parece inferior no papel, mas ainda pode '
          'incomodar se encontrar espaços. O favoritismo precisa virar '
          'controle.';
    }

    return '$opponentName tem nível parecido e deve oferecer um jogo '
        'equilibrado. Detalhes podem decidir a partida.';
  }

  void _openMyClub() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyClubPage(),
      ),
    );
  }

  void _openMarket() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MarketPage(),
      ),
    );
  }

  void _openMessages() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MessagesPage(),
      ),
    );
  }

  void _openStandings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const StandingsPage(),
      ),
    );
  }

  void _openObservation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ObservationPage(),
      ),
    );
  }

  void _openStructures() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const StructuresPage(),
      ),
    );
  }

  void _openFinance() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FinancePage(),
      ),
    );
  }

  void _openCoach() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CoachPage(),
      ),
    );
  }

  void _openDirector() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FootballDirectorPage(),
      ),
    );
  }

  void _openPermanentStaff() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PermanentStaffPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = ref.watch(gameStateProvider);

    _schedulePendingUiChecks();

    if (!gs.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final director = gs.footballDirector;

    if (director == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final nextFixture = _nextUserFixture(gs);
    final table = gs.table.getSorted();

    return Scaffold(
      backgroundColor: const Color(0xFFF2EFF8),
      appBar: AppBar(
        title: const Text('Footory 26'),
        actions: [
          IconButton(
            tooltip: 'Salvar jogo',
            onPressed: _savingGame ? null : _saveGameManually,
            icon: _savingGame
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.save_rounded,
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            10,
            8,
            10,
            22,
          ),
          child: Column(
            children: [
              HubDirectorHero(
                director: director,
                career: gs.directorCareer,
                clubId: gs.userClubId,
                clubName: gs.userClubName,
                divisionId: gs.divisionId,
                dateStr: gs.dateStr,
                seasonYear: gs.seasonYear,
              ),
              const SizedBox(height: 10),
              HubPermanentStaffPreview(
                members: PermanentStaffCatalog.all,
              ),
              const SizedBox(height: 10),
              if (nextFixture != null) ...[
                HubNextMatchBlock(
                  gs: gs,
                  fx: nextFixture,
                ),
                const SizedBox(height: 10),
              ],
              HubExecutiveSummary(
                gs: gs,
                table: table,
              ),
              const SizedBox(height: 10),
              HubMessagesCounter(
                unreadNews: gs.unreadNewsCount,
                unreadDepartment: gs.unreadDepartmentMessagesCount,
                onOpenMessages: _openMessages,
              ),
              const SizedBox(height: 10),
              HubContextualStandings(
                table: table,
                userClubId: gs.userClubId,
                gs: gs,
                onOpenStandings: _openStandings,
              ),
              if (gs.seasonEnded && gs.lastSeasonReport != null) ...[
                const SizedBox(height: 10),
                _CompactAlertButton(
                  icon: Icons.emoji_events_rounded,
                  label: 'Fim de temporada — ver relatório',
                  onTap: () {
                    _openSeasonReport(
                      markAsShown: true,
                    );
                  },
                ),
              ],
              if (gs.pendingTransferOffer != null) ...[
                const SizedBox(height: 10),
                _CompactAlertButton(
                  icon: Icons.swap_calls_rounded,
                  label: 'Proposta em aberto — avaliar',
                  onTap: () async {
                    await _maybeShowTransferOfferModal();
                  },
                ),
              ],
              const SizedBox(height: 10),
              HubSecondaryNav(
                onMyClub: _openMyClub,
                onMarket: _openMarket,
                onMessages: _openMessages,
                onStandings: _openStandings,
                onObservation: _openObservation,
                onStructures: _openStructures,
                onFinance: _openFinance,
                onCoach: _openCoach,
                onDirector: _openDirector,
                onPermanentStaff: _openPermanentStaff,
              ),
              const SizedBox(height: 12),
              _AdvanceRoundButton(
                seasonEnded: gs.seasonEnded,
                reportAvailable: gs.lastSeasonReport != null,
                reportShown: _seasonReportShownForCurrentSeasonEnd,
                openingMatch: _openingMatchLive,
                onPressed: _simulateRoundOrNextSeason,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Fixture? _nextUserFixture(GameState gs) {
    if (gs.seasonEnded) return null;

    final round = gs.roundIndex;

    for (final fixture in gs.fixtures) {
      if (fixture.round != round) continue;

      final involvesUser = fixture.homeClubId == gs.userClubId ||
          fixture.awayClubId == gs.userClubId;

      if (involvesUser) {
        return fixture;
      }
    }

    return null;
  }
}

class _CompactAlertButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CompactAlertButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AdvanceRoundButton extends StatelessWidget {
  final bool seasonEnded;
  final bool reportAvailable;
  final bool reportShown;
  final bool openingMatch;
  final VoidCallback onPressed;

  const _AdvanceRoundButton({
    required this.seasonEnded,
    required this.reportAvailable,
    required this.reportShown,
    required this.openingMatch,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;

    if (openingMatch) {
      label = 'Abrindo partida...';
      icon = Icons.hourglass_top_rounded;
    } else if (!seasonEnded) {
      label = 'Assistir Partida';
      icon = Icons.play_arrow_rounded;
    } else if (reportAvailable && !reportShown) {
      label = 'Ver Relatório da Temporada';
      icon = Icons.emoji_events_rounded;
    } else {
      label = 'Próxima Temporada';
      icon = Icons.skip_next_rounded;
    }

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: openingMatch ? null : onPressed,
        icon: openingMatch
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
