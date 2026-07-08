import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/fixture.dart';
import 'package:footory26/models/player.dart';

import 'package:footory26/pages/club/structures_page.dart';
import 'package:footory26/pages/coach/coach_page.dart';
import 'package:footory26/pages/finance/finance_page.dart';
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
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
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
            content: Text('Nenhum slot ativo encontrado para salvar.'),
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
    final cp = gs.pendingCheckpoint;
    if (cp == null) return;

    _checkpointDialogOpen = true;

    if (!mounted) {
      _checkpointDialogOpen = false;
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(cp.title),
          content: Text(cp.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      _checkpointDialogOpen = false;
      return;
    }

    ref.read(gameStateProvider).consumePendingCheckpoint();
    _checkpointDialogOpen = false;
  }

  Future<void> _maybeShowTransferOfferModal() async {
    if (_transferDialogOpen) return;
    if (_checkpointDialogOpen) return;

    final gs = ref.read(gameStateProvider);
    final offer = gs.pendingTransferOffer;
    if (offer == null) return;

    _transferDialogOpen = true;

    if (!mounted) {
      _transferDialogOpen = false;
      return;
    }

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

    if (!mounted) {
      _transferDialogOpen = false;
      return;
    }

    final state = ref.read(gameStateProvider);
    String? message;

    switch (decision) {
      case TransferOfferDecision.accept:
        message = state.acceptPendingTransferOffer(addToObservation: false);
        break;
      case TransferOfferDecision.acceptAndObserve:
        message = state.acceptPendingTransferOffer(addToObservation: true);
        break;
      case TransferOfferDecision.reject:
        message = state.rejectPendingTransferOffer();
        break;
      case null:
        message = null;
        break;
    }

    _transferDialogOpen = false;

    if (!mounted) return;

    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _maybeShowMarketOpportunityModal() async {
    if (_marketOpportunityDialogOpen) return;
    if (_checkpointDialogOpen) return;
    if (_transferDialogOpen) return;
    if (_seasonReportOpening) return;
    if (_openingMatchLive) return;

    final gs = ref.read(gameStateProvider);

    final opportunityLine = gs.newsFeed.cast<String?>().firstWhere(
          (line) =>
              line != null &&
              line.toLowerCase().contains('oportunidade de mercado'),
          orElse: () => null,
        );

    if (opportunityLine == null) return;
    if (_shownMarketOpportunityLines.contains(opportunityLine)) return;

    _shownMarketOpportunityLines.add(opportunityLine);
    _marketOpportunityDialogOpen = true;

    if (!mounted) {
      _marketOpportunityDialogOpen = false;
      return;
    }

    final openMarket = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Oportunidade de Mercado'),
          content: Text(opportunityLine),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Ver depois'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Avaliar oportunidade'),
            ),
          ],
        );
      },
    );

    _marketOpportunityDialogOpen = false;

    if (!mounted) return;

    if (openMarket == true) {
      _openMarket();
    }
  }

  Future<void> _maybeOpenSeasonReport() async {
    if (_seasonReportOpening) return;
    if (_checkpointDialogOpen) return;
    if (_transferDialogOpen) return;
    if (_marketOpportunityDialogOpen) return;
    if (_openingMatchLive) return;

    final gs = ref.read(gameStateProvider);

    if (!gs.seasonEnded) {
      _seasonReportShownForCurrentSeasonEnd = false;
      return;
    }

    if (gs.lastSeasonReport == null) return;
    if (_seasonReportShownForCurrentSeasonEnd) return;

    await _openSeasonReport(markAsShown: true);
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
          builder: (_) => SeasonReportPage(report: report),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _seasonReportOpening = false;
        });
      }
    }
  }

  Future<void> _simulateRoundOrNextSeason() async {
    final gs = ref.read(gameStateProvider);
    if (!gs.isInitialized) return;

    if (gs.seasonEnded) {
      if (gs.lastSeasonReport != null &&
          !_seasonReportShownForCurrentSeasonEnd) {
        await _openSeasonReport(markAsShown: true);
        return;
      }

      _seasonReportShownForCurrentSeasonEnd = false;
      gs.startNextSeason();
      _schedulePendingUiChecks();
      return;
    }

    if (_openingMatchLive) return;

    final nextFx = _nextUserFixture(gs);
    if (nextFx == null) return;

    _openingMatchLive = true;

    try {
      final squad = gs.getProSquad();
      final coachStaff = gs.selectedCoachStaffOrFallback;
      final identity =
          CoachTacticalCatalog.fromId(coachStaff.tacticalIdentityId);

      final lineup = _autoLineupService.build(
        squad: squad,
        formation: identity.mainFormation,
      );

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MatchPreviewPage(
            homeClubName: gs.clubName(nextFx.homeClubId),
            awayClubName: gs.clubName(nextFx.awayClubId),
            userClubName: gs.userClubName,
            tacticalIdentityId: coachStaff.tacticalIdentityId,
            starters: lineup.starters.map(_toPreviewPlayer).toList(),
            reserves: lineup.reserves.map(_toPreviewPlayer).toList(),
            momentText: _buildMomentText(gs),
            opponentReport: _buildOpponentReport(gs, nextFx),
          ),
        ),
      );
    } finally {
      _openingMatchLive = false;
      if (mounted) {
        _schedulePendingUiChecks();
      }
    }
  }

  MatchPreviewPlayer _toPreviewPlayer(Player p) {
    return MatchPreviewPlayer(
      name: p.nome,
      position: p.posLabel,
      overall: p.ovrCheio,
      faceAsset: p.faceAsset,
    );
  }

  String _buildMomentText(GameState gs) {
    if (gs.userWinStreak >= 3) {
      return '${gs.userClubName} chega embalado por uma sequência forte de vitórias. O ambiente é de confiança antes da partida.';
    }

    if (gs.userLoseStreak >= 2) {
      return '${gs.userClubName} entra pressionado após resultados ruins. A comissão busca uma resposta imediata em campo.';
    }

    if (gs.userDrawStreak >= 2) {
      return '${gs.userClubName} vem de empates seguidos. O time compete, mas precisa transformar equilíbrio em vitória.';
    }

    return '${gs.userClubName} chega para a rodada em momento estável. A comissão aposta na execução do plano de jogo.';
  }

  String _buildOpponentReport(GameState gs, Fixture fx) {
    final opponentId =
        fx.homeClubId == gs.userClubId ? fx.awayClubId : fx.homeClubId;

    final opponentName = gs.clubName(opponentId);
    final userPower = gs.clubPower10(gs.userClubId);
    final opponentPower = gs.clubPower10(opponentId);

    final diff = opponentPower - userPower;

    if (diff >= 0.8) {
      return '$opponentName chega como adversário perigoso e tecnicamente superior. Será preciso competir com organização e reduzir erros.';
    }

    if (diff <= -0.8) {
      return '$opponentName parece inferior no papel, mas ainda pode incomodar se encontrar espaços. Favoritismo precisa virar controle.';
    }

    return '$opponentName tem nível parecido e deve oferecer um jogo equilibrado. Detalhes podem decidir a partida.';
  }

  void _openMyClub() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyClubPage()),
    );
  }

  void _openStructures() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StructuresPage()),
    );
  }

  void _openMarket() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MarketPage()),
    );
  }

  void _openStandings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StandingsPage()),
    );
  }

  void _openMessages() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MessagesPage()),
    );
  }

  void _openCoach() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CoachPage()),
    );
  }

  void _openFinance() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FinancePage()),
    );
  }

  void _openObservation() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ObservationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GameState gs = ref.watch(gameStateProvider);

    _schedulePendingUiChecks();

    if (!gs.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final nextFx = _nextUserFixture(gs);
    final unreadMessages =
        gs.unreadNewsCount + gs.unreadDepartmentMessagesCount;

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
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Column(
            children: [
              _ClubHeroCard(gs: gs),
              const SizedBox(height: 8),
              _TopNextMatchCard(
                gs: gs,
                fx: nextFx,
              ),
              const SizedBox(height: 8),
              if (gs.seasonEnded && gs.lastSeasonReport != null) ...[
                _CompactAlertButton(
                  icon: Icons.emoji_events_rounded,
                  label: 'Fim de temporada — ver relatório',
                  onTap: () => _openSeasonReport(markAsShown: true),
                ),
                const SizedBox(height: 6),
              ],
              if (gs.pendingTransferOffer != null) ...[
                _CompactAlertButton(
                  icon: Icons.swap_calls_rounded,
                  label: 'Proposta em aberto — avaliar',
                  onTap: () async {
                    await _maybeShowTransferOfferModal();
                  },
                ),
                const SizedBox(height: 6),
              ],
              Expanded(
                child: _HubLaunchActionGrid(
                  unreadMessages: unreadMessages,
                  onMyClub: _openMyClub,
                  onMarket: _openMarket,
                  onMessages: _openMessages,
                  onStandings: _openStandings,
                  onObservation: _openObservation,
                  onStructures: _openStructures,
                  onFinance: _openFinance,
                  onCoach: _openCoach,
                ),
              ),
              const SizedBox(height: 6),
              _AdvanceRoundButton(
                seasonEnded: gs.seasonEnded,
                reportAvailable: gs.lastSeasonReport != null,
                reportShown: _seasonReportShownForCurrentSeasonEnd,
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

    final r = gs.roundIndex;
    for (final fx in gs.fixtures) {
      if (fx.round != r) continue;
      if (fx.homeClubId == gs.userClubId || fx.awayClubId == gs.userClubId) {
        return fx;
      }
    }

    return null;
  }
}

String _hubDivisionLabel(String divisionId) {
  switch (divisionId) {
    case 'brA':
      return 'Liga BR A';
    case 'brB':
      return 'Liga BR B';
    case 'brC':
      return 'Liga BR C';
    case 'brD':
      return 'Liga BR D';
    default:
      return 'Liga Nacional';
  }
}

String? _safeUserTablePosition(GameState gs) {
  try {
    final dynamic table = gs.table;
    final dynamic rows = table.rows;

    if (rows is! Iterable) return null;

    var index = 0;
    for (final dynamic row in rows) {
      String? clubId;

      try {
        final dynamic value = row.clubId;
        if (value is String) clubId = value;
      } catch (_) {}

      try {
        final dynamic value = row.teamId;
        if (clubId == null && value is String) clubId = value;
      } catch (_) {}

      try {
        final dynamic value = row.id;
        if (clubId == null && value is String) clubId = value;
      } catch (_) {}

      if (clubId == gs.userClubId) {
        return '${index + 1}º lugar';
      }

      index++;
    }
  } catch (_) {}

  return null;
}

String _seasonSummaryLine(GameState gs) {
  final division = _hubDivisionLabel(gs.divisionId);
  final position = _safeUserTablePosition(gs);
  final total = gs.totalRounds;

  final roundText = total > 0
      ? 'Rodada ${gs.roundDisplay} de $total'
      : 'Rodada ${gs.roundDisplay}';

  if (position == null || position.isEmpty) {
    return '$division • $roundText';
  }

  return '$division • $position • $roundText';
}

class _ClubHeroCard extends StatelessWidget {
  final GameState gs;

  const _ClubHeroCard({
    required this.gs,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final club = BrazilClubCatalog.byId(gs.userClubId);
    final badgePath = club?.badgeAsset ?? 'assets/faces/_placeholder.png';

    return SizedBox(
      height: 108,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          gradient: AppColors.actionGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.16),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Image.asset(
                  badgePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.shield_rounded,
                    color: AppColors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gs.userClubName.isEmpty ? 'Meu Clube' : gs.userClubName,
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
                    _seasonSummaryLine(gs),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.94),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      _HeroMiniPill(label: 'Temporada'),
                      const SizedBox(width: 6),
                      _HeroMiniPill(label: gs.dateStr),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMiniPill extends StatelessWidget {
  final String label;

  const _HeroMiniPill({
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

class _TopNextMatchCard extends StatelessWidget {
  final GameState gs;
  final Fixture? fx;

  const _TopNextMatchCard({
    required this.gs,
    required this.fx,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (fx == null) {
      return SizedBox(
        height: 110,
        child: _PremiumSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.sports_soccer_rounded,
                label: 'Próximo jogo',
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Temporada encerrada',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    }

    final homeName = gs.clubName(fx!.homeClubId);
    final awayName = gs.clubName(fx!.awayClubId);
    final isUserHome = fx!.homeClubId == gs.userClubId;
    final commandLabel = isUserHome ? 'Mandante' : 'Visitante';
    final opponentId = isUserHome ? fx!.awayClubId : fx!.homeClubId;
    final userPower = gs.clubPower10(gs.userClubId);
    final opponentPower = gs.clubPower10(opponentId);

    return SizedBox(
      height: 118,
      child: _PremiumSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.sports_soccer_rounded,
              label: 'Próximo jogo',
            ),
            const SizedBox(height: 7),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _MatchSide(
                      clubId: fx!.homeClubId,
                      name: homeName,
                      helper: isUserHome ? 'Seu clube' : 'Adversário',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      'VS',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _MatchSide(
                      clubId: fx!.awayClubId,
                      name: awayName,
                      helper: isUserHome ? 'Adversário' : 'Seu clube',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                    child: _InfoChip(label: _hubDivisionLabel(gs.divisionId))),
                const SizedBox(width: 5),
                Expanded(child: _InfoChip(label: 'Rod. ${fx!.round}')),
                const SizedBox(width: 5),
                Expanded(child: _InfoChip(label: commandLabel)),
                const SizedBox(width: 5),
                Expanded(
                  child: _InfoChip(
                    label:
                        '${userPower.toStringAsFixed(1)} x ${opponentPower.toStringAsFixed(1)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchSide extends StatelessWidget {
  final String clubId;
  final String name;
  final String helper;

  const _MatchSide({
    required this.clubId,
    required this.name,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.105),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          _ClubBadge(clubId: clubId),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8.5,
                    height: 1,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.68),
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

class _ClubBadge extends StatelessWidget {
  final String clubId;

  const _ClubBadge({
    required this.clubId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final club = BrazilClubCatalog.byId(clubId);
    final badgePath = club?.badgeAsset ?? 'assets/faces/_placeholder.png';

    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          badgePath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.shield_rounded,
            size: 24,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.16),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 8.6,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
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
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.075),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
        ),
      ],
    );
  }
}

class _HubLaunchActionGrid extends StatelessWidget {
  final int unreadMessages;
  final VoidCallback onMyClub;
  final VoidCallback onMarket;
  final VoidCallback onMessages;
  final VoidCallback onStandings;
  final VoidCallback onObservation;
  final VoidCallback onStructures;
  final VoidCallback onFinance;
  final VoidCallback onCoach;

  const _HubLaunchActionGrid({
    required this.unreadMessages,
    required this.onMyClub,
    required this.onMarket,
    required this.onMessages,
    required this.onStandings,
    required this.onObservation,
    required this.onStructures,
    required this.onFinance,
    required this.onCoach,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 7.0;
        final tileHeight =
            ((constraints.maxHeight - gap) / 2).clamp(62.0, 78.0).toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                _HubActionTile(
                  height: tileHeight,
                  icon: Icons.shield_rounded,
                  label: 'Meu clube',
                  subtitle: 'Elenco',
                  onTap: onMyClub,
                ),
                const SizedBox(width: 7),
                _HubActionTile(
                  height: tileHeight,
                  icon: Icons.storefront_rounded,
                  label: 'Mercado',
                  subtitle: 'Negócios',
                  onTap: onMarket,
                ),
                const SizedBox(width: 7),
                _HubActionTile(
                  height: tileHeight,
                  icon: Icons.mark_email_unread_rounded,
                  label: 'Mensagens',
                  subtitle: 'Notícias',
                  badge: unreadMessages,
                  onTap: onMessages,
                ),
                const SizedBox(width: 7),
                _HubActionTile(
                  height: tileHeight,
                  icon: Icons.leaderboard_rounded,
                  label: 'Tabela',
                  subtitle: 'Liga',
                  onTap: onStandings,
                ),
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: [
                _HubActionTile(
                  height: tileHeight,
                  icon: Icons.visibility_rounded,
                  label: 'Observação',
                  subtitle: 'Scout',
                  onTap: onObservation,
                ),
                const SizedBox(width: 7),
                _HubActionTile(
                  height: tileHeight,
                  icon: Icons.apartment_rounded,
                  label: 'Estruturas',
                  subtitle: 'Clube',
                  onTap: onStructures,
                ),
                const SizedBox(width: 7),
                _HubActionTile(
                  height: tileHeight,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Finanças',
                  subtitle: 'Caixa',
                  onTap: onFinance,
                ),
                const SizedBox(width: 7),
                _HubActionTile(
                  height: tileHeight,
                  icon: Icons.groups_rounded,
                  label: 'Comissão',
                  subtitle: 'Staff',
                  onTap: onCoach,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HubActionTile extends StatelessWidget {
  final double height;
  final IconData icon;
  final String label;
  final String subtitle;
  final int badge;
  final VoidCallback onTap;

  const _HubActionTile({
    required this.height,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.13),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.055),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10.2,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 8.3,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark.withOpacity(0.58),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (badge > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
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
      height: 38,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AdvanceRoundButton extends StatelessWidget {
  final bool seasonEnded;
  final bool reportAvailable;
  final bool reportShown;
  final VoidCallback onPressed;

  const _AdvanceRoundButton({
    required this.seasonEnded,
    required this.reportAvailable,
    required this.reportShown,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String label;

    if (!seasonEnded) {
      label = 'Assistir Partida';
    } else if (reportAvailable && !reportShown) {
      label = 'Ver Relatório da Temporada';
    } else {
      label = 'Próxima Temporada';
    }

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.play_arrow_rounded),
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
