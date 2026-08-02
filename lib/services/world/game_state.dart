import 'package:flutter/foundation.dart';

import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/core/money_formatter.dart';

import 'package:footory26/models/coach_staff.dart';
import 'package:footory26/models/continental/atlas_champions_club_result.dart';
import 'package:footory26/models/continental/atlas_club_result.dart';
import 'package:footory26/models/continental/simon_bolivar_group_fixture.dart';
import 'package:footory26/models/continental/simon_bolivar_season_result.dart';
import 'package:footory26/models/continental/world_tournament_result.dart';
import 'package:footory26/models/cup_fixture.dart';
import 'package:footory26/models/director_career.dart';
import 'package:footory26/models/fixture.dart';
import 'package:footory26/models/football_director.dart';
import 'package:footory26/models/league_table.dart';
import 'package:footory26/models/match_live_event.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/models/scout/scout_target.dart';
import 'package:footory26/models/staff_department.dart';

import 'package:footory26/pages/messages/models/game_message.dart';

import 'package:footory26/services/negotiation/negotiation_service.dart';

import 'package:footory26/services/calendar/season_service.dart';
import 'package:footory26/services/club_status/club_status_runtime.dart';
import 'package:footory26/services/cup/cup_service.dart';
import 'package:footory26/services/department/department_message_service.dart';
import 'package:footory26/services/finance/finance_club_service.dart';
import 'package:footory26/services/finance/finance_rules_service.dart';
import 'package:footory26/services/finance/finance_runtime_service.dart';
import 'package:footory26/services/finance/finance_snapshot.dart';
import 'package:footory26/services/finance/ticket_revenue_service.dart';
import 'package:footory26/services/finance/sponsor_revenue_service.dart';
import 'package:footory26/services/finance/competition_prize_service.dart';
import 'package:footory26/services/league_table_service.dart';
import 'package:footory26/services/legacy/club_legacy.dart';
import 'package:footory26/services/legacy/legacy_runtime_service.dart';
import 'package:footory26/services/lineup/auto_lineup_service.dart';
import 'package:footory26/services/market/cpu_transfer_service.dart';
import 'package:footory26/services/market/market_service.dart';
import 'package:footory26/services/match_engine.dart';
import 'package:footory26/services/match_live/match_live_narrative_service.dart';
import 'package:footory26/services/match_narrative_service.dart';
import 'package:footory26/services/news/news_service.dart';
import 'package:footory26/services/narrative/season_narrative_context.dart';
import 'package:footory26/services/narrative/season_narrative_analyzer.dart';
import 'package:footory26/services/narrative/narrative_writer_service.dart';
import 'package:footory26/services/player/player_evolution_service.dart';
import 'package:footory26/services/player_factory.dart';
import 'package:footory26/services/reports/season_financial_report_service.dart';
import 'package:footory26/services/reports/season_report_builder.dart';
import 'package:footory26/services/save/save_storage_service.dart';
import 'package:footory26/services/scout/scout_service.dart';
import 'package:footory26/services/structures/structure_runtime_service.dart';
import 'package:footory26/services/team_power_service.dart';

import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
import 'package:footory26/services/world/catalog/club_structures_catalog.dart';
import 'package:footory26/services/world/catalog/coach_staff_catalog.dart';
import 'package:footory26/services/world/catalog/coach_tactical_catalog.dart';
import 'package:footory26/services/world/catalog/structure_costs_catalog.dart';
import 'package:footory26/services/world/catalog/south_america/south_america_club_catalog.dart';
import 'package:footory26/services/world/catalog/world_club_registry.dart';
import 'package:footory26/services/world/continental/competition_qualification_service.dart';
import 'package:footory26/services/world/continental/simon_bolivar_service.dart';
import 'package:footory26/services/world/continental/world_tournament_service.dart';

import 'package:footory26/services/season/season_checkpoint_service.dart';
import 'package:footory26/services/season/season_expectation_service.dart';
import 'package:footory26/services/season/season_expectation_snapshot.dart';

part 'handlers/game_state_market_models_handler.dart';
part 'handlers/game_state_runtime_handler.dart';
part 'handlers/game_state_finance_handler.dart';
part 'handlers/game_state_save_handler.dart';

part 'handlers/market_opportunity_handler.dart';
part 'handlers/monthly_finance_handler.dart';
part 'handlers/market_window_handler.dart';
part 'handlers/transfer_flow_handler.dart';
part 'handlers/loan_handler.dart';
part 'handlers/narrative_handler.dart';
part 'handlers/youth_handler.dart';
part 'handlers/evolution_handler.dart';
part 'handlers/season_flow_handler.dart';
part 'handlers/brazil_cup_handler.dart';
part 'handlers/simon_bolivar_handler.dart';
part 'handlers/world_bootstrap_handler.dart';
part 'handlers/world_tournament_handler.dart';
part 'handlers/season_analysis_handler.dart';
part 'handlers/runtime_helper_handler.dart';
part 'handlers/market_negotiation_handler.dart';

class GameState extends ChangeNotifier {
  bool isInitialized = false;
  String? initError;

  String divisionId = '';
  int seed = 0;

  String userClubId = '';
  String userClubName = '';
  String currentSaveSlotId = 'save_slot_1';

  FootballDirector? _footballDirector;

  FootballDirector? get footballDirector => _footballDirector;

  bool get hasFootballDirector {
    return _footballDirector?.hasRequiredData == true;
  }

  void assignFootballDirector(FootballDirector director) {
    if (!director.hasRequiredData) {
      throw ArgumentError.value(
        director,
        'director',
        'O Diretor de Futebol não possui todos os dados obrigatórios.',
      );
    }

    _footballDirector = director;
    notifyListeners();
  }

  void clearFootballDirector() {
    if (_footballDirector == null) return;

    _footballDirector = null;
    notifyListeners();
  }

  DirectorCareer? _directorCareer;

  DirectorCareer? get directorCareer => _directorCareer;

  bool get hasDirectorCareer => _directorCareer != null;

  DirectorCareer get directorCareerOrFallback {
    final current = _directorCareer;

    if (current != null) {
      return current;
    }

    return DirectorCareer.initial(
      seasonYear: _seasonYear,
      clubId: userClubId,
      clubName: userClubName,
    );
  }

  void initializeDirectorCareer({
    required int seasonYear,
    required String clubId,
    required String clubName,
  }) {
    final normalizedClubId = clubId.trim();
    final normalizedClubName = clubName.trim();

    if (normalizedClubId.isEmpty || normalizedClubName.isEmpty) {
      return;
    }

    _directorCareer = DirectorCareer.initial(
      seasonYear: seasonYear,
      clubId: normalizedClubId,
      clubName: normalizedClubName,
    ).openClubSpell(
      clubId: normalizedClubId,
      clubName: normalizedClubName,
      startYear: seasonYear,
    );

    notifyListeners();
  }

  void initializeDirectorCareerIfNeeded({
    required int seasonYear,
    required String clubId,
    required String clubName,
  }) {
    if (_directorCareer != null) return;

    initializeDirectorCareer(
      seasonYear: seasonYear,
      clubId: clubId,
      clubName: clubName,
    );
  }

  void restoreDirectorCareerFromSave(DirectorCareer? career) {
    _directorCareer = career;
    notifyListeners();
  }

  void clearDirectorCareer() {
    if (_directorCareer == null) return;

    _directorCareer = null;
    notifyListeners();
  }

  int roundIndex = 1;
  bool seasonEnded = false;

  String dateStr = '';
  String? lastUserMatch;
  String? lastUserMatchHomeClubName;
  String? lastUserMatchAwayClubName;

  UserMatchSummary? _lastUserMatchSummary;
  UserMatchSummary? get lastUserMatchSummary => _lastUserMatchSummary;

  List<MatchLiveEvent> _lastUserMatchLiveEvents = <MatchLiveEvent>[];
  List<MatchLiveEvent> get lastUserMatchLiveEvents =>
      List.unmodifiable(_lastUserMatchLiveEvents);

  int userWinStreak = 0;
  int userLoseStreak = 0;
  int userDrawStreak = 0;

  TransferOffer? _pendingTransferOffer;
  TransferOffer? get pendingTransferOffer => _pendingTransferOffer;

  final List<ObservedPlayer> _observedPlayers = <ObservedPlayer>[];
  List<ObservedPlayer> get observedPlayers =>
      List.unmodifiable(_observedPlayers);

  final List<FutureArrival> _futureArrivals = <FutureArrival>[];
  List<FutureArrival> get futureArrivals => List.unmodifiable(_futureArrivals);

  final List<Fixture> fixtures = <Fixture>[];
  final LeagueTable table = LeagueTable();

  final List<CupFixture> _brazilCupFixtures = <CupFixture>[];
  List<CupFixture> get brazilCupFixtures =>
      List.unmodifiable(_brazilCupFixtures);

  final List<SimonBolivarGroupFixture> _simonBolivarGroupFixtures =
      <SimonBolivarGroupFixture>[];
  List<SimonBolivarGroupFixture> get simonBolivarGroupFixtures =>
      List.unmodifiable(_simonBolivarGroupFixtures);

  final List<CupFixture> _simonBolivarKnockoutFixtures = <CupFixture>[];
  List<CupFixture> get simonBolivarKnockoutFixtures =>
      List.unmodifiable(_simonBolivarKnockoutFixtures);

  final List<SimonBolivarSeasonResult> _simonBolivarHistory =
      <SimonBolivarSeasonResult>[];
  List<SimonBolivarSeasonResult> get simonBolivarHistory =>
      List.unmodifiable(_simonBolivarHistory);

  final List<AtlasClubResult> _atlasClubHistory = <AtlasClubResult>[];
  List<AtlasClubResult> get atlasClubHistory =>
      List.unmodifiable(_atlasClubHistory);

  final List<AtlasChampionsClubResult> _atlasChampionsHistory =
      <AtlasChampionsClubResult>[];
  List<AtlasChampionsClubResult> get atlasChampionsHistory =>
      List.unmodifiable(_atlasChampionsHistory);

  final List<WorldTournamentResult> _worldTournamentHistory =
      <WorldTournamentResult>[];
  List<WorldTournamentResult> get worldTournamentHistory =>
      List.unmodifiable(_worldTournamentHistory);

  int _maxRound = 0;
  int get totalRounds => _maxRound;

  int get roundPlayed {
    if (_maxRound <= 0) return 0;
    final v = roundIndex - 1;
    return v.clamp(0, _maxRound);
  }

  int get roundDisplay {
    if (_maxRound <= 0) return 1;
    if (seasonEnded) return _maxRound;
    return roundIndex.clamp(1, _maxRound);
  }

  int _seasonYear = 2026;
  int get seasonYear => _seasonYear;

  int? _lastMarketRefreshYear;
  int? _lastMarketRefreshMonth;

  DateTime _currentDate = DateTime(2026, 1, 2);
  DateTime get currentDate => _currentDate;
  int get currentMonth => _currentDate.month;

  int _userCoachLevel = 4;
  int get userCoachLevel => _userCoachLevel;

  int get userCoachMonthlySalary => _coachMonthlySalaryByLevel(_userCoachLevel);

  int get userCoachNextUpgradeCost {
    final current = _userCoachLevel.clamp(1, 10);
    if (current >= 10) return 0;

    return _coachUpgradeCostToLevel(current + 1);
  }

  CoachStaff? _selectedCoachStaff;
  CoachStaff? get selectedCoachStaff => _selectedCoachStaff;

  CoachStaff get selectedCoachStaffOrFallback {
    if (_selectedCoachStaff != null) return _selectedCoachStaff!;
    return CoachStaffCatalog.all.first.copyWith(
      level: _userCoachLevel.clamp(1, 10),
    );
  }

  bool get hasSelectedCoachStaff => _selectedCoachStaff != null;

  void chooseCoachStaff(CoachStaff staff) {
    final normalizedLevel = staff.level.clamp(1, 10);

    _userCoachLevel = normalizedLevel;
    _selectedCoachStaff = staff.copyWith(
      level: normalizedLevel,
    );

    notifyListeners();
  }

  void clearSelectedCoachStaff() {
    _selectedCoachStaff = null;
    notifyListeners();
  }

  bool upgradeCoachStaffLevel() {
    if (userClubId.trim().isEmpty) return false;

    final currentLevel = _userCoachLevel.clamp(1, 10);
    if (currentLevel >= 10) return false;

    final nextLevel = currentLevel + 1;

    if (nextLevel > userComplexoLevel) return false;

    final cost = _coachUpgradeCostToLevel(nextLevel);
    final finance = _ensureFinanceForClub(userClubId);

    if (finance.caixa < cost) return false;

    _userCoachLevel = nextLevel;

    final currentStaff = _selectedCoachStaff;
    if (currentStaff != null) {
      _selectedCoachStaff = currentStaff.copyWith(
        level: nextLevel,
      );
    }

    _financeByClub[userClubId] = _financeClubService.refreshHealth(
      finance.copyWith(
        caixa: finance.caixa - cost,
      ),
    );

    _insertNewsIfNew(
      'O clube investiu na evolução da comissão técnica para o nível $nextLevel.',
      category: GameMessageCategory.training,
    );

    notifyListeners();
    _autoSave();

    return true;
  }

  int _coachMonthlySalaryByLevel(int level) {
    final v = level.clamp(1, 10);

    return switch (v) {
      1 => 180000,
      2 => 250000,
      3 => 350000,
      4 => 500000,
      5 => 700000,
      6 => 900000,
      7 => 1200000,
      8 => 1500000,
      9 => 1750000,
      _ => 2000000,
    };
  }

  int _coachUpgradeCostToLevel(int nextLevel) {
    final v = nextLevel.clamp(1, 10);

    return switch (v) {
      2 => 50000,
      3 => 150000,
      4 => 350000,
      5 => 700000,
      6 => 1500000,
      7 => 3000000,
      8 => 7000000,
      9 => 15000000,
      10 => 25000000,
      _ => 0,
    };
  }

  ClubStructures _userClubStructures = const ClubStructures(
    complexo: 1,
    ct: 1,
    base: 1,
    scout: 1,
    financeiro: 1,
    marketing: 1,
    comunicacao: 1,
    medico: 1,
    estadio: 1,
  );

  ClubStructures get userClubStructures => _userClubStructures;

  double get userStructuralPower => _userClubStructures.structuralPower;
  int get userComplexoLevel => _userClubStructures.complexo;
  int get userCtLevel => _userClubStructures.ct;
  int get userBaseLevel => _userClubStructures.base;
  int get userScoutLevel => _userClubStructures.scout;
  int get userFinanceiroLevel => _userClubStructures.financeiro;
  int get userMarketingLevel => _userClubStructures.marketing;
  int get userComunicacaoLevel => _userClubStructures.comunicacao;
  int get userMedicoLevel => _userClubStructures.medico;
  int get userStadiumLevel => _userClubStructures.estadio;

  final List<ScoutTarget> _scoutTransfers = <ScoutTarget>[];
  final List<ScoutTarget> _scoutLoans = <ScoutTarget>[];
  final List<ScoutTarget> _scoutFrees = <ScoutTarget>[];

  List<ScoutTarget> get scoutTransfers => List.unmodifiable(_scoutTransfers);
  List<ScoutTarget> get scoutLoans => List.unmodifiable(_scoutLoans);
  List<ScoutTarget> get scoutFrees => List.unmodifiable(_scoutFrees);

  SeasonExpectationSnapshot? _expectations;
  SeasonExpectationSnapshot? get expectations => _expectations;

  SeasonCheckpoint? _pendingCheckpoint;
  SeasonCheckpoint? get pendingCheckpoint => _pendingCheckpoint;

  final List<String> _newsFeed = <String>[];
  List<String> get newsFeed => List.unmodifiable(_newsFeed);

  final Map<String, GameMessageCategory> _newsCategoryByText =
      <String, GameMessageCategory>{};

  Map<String, GameMessageCategory> get newsCategoryByText =>
      Map.unmodifiable(_newsCategoryByText);

  GameMessageCategory newsCategoryOf(String text) {
    final key = text.trim();
    if (key.isEmpty) return GameMessageCategory.season;

    return _newsCategoryByText[key] ?? GameMessageCategory.season;
  }

  final List<DepartmentMessage> _departmentMessages = <DepartmentMessage>[];
  List<DepartmentMessage> get departmentMessages =>
      List.unmodifiable(_departmentMessages);

  int _readNewsCount = 0;
  int _readDepartmentMessagesCount = 0;

  int _readMatchNewsCount = 0;
  int _readMarketNewsCount = 0;
  int _readWorldNewsCount = 0;
  int _readFinanceNewsCount = 0;
  int _readTrainingNewsCount = 0;
  int _readSeasonNewsCount = 0;

  int get readMatchNewsCount => _readMatchNewsCount;
  int get readMarketNewsCount => _readMarketNewsCount;
  int get readWorldNewsCount => _readWorldNewsCount;
  int get readFinanceNewsCount => _readFinanceNewsCount;
  int get readTrainingNewsCount => _readTrainingNewsCount;
  int get readSeasonNewsCount => _readSeasonNewsCount;

  int get unreadNewsCount {
    final value = _newsFeed.length - _readNewsCount;
    return value < 0 ? 0 : value;
  }

  int get unreadDepartmentMessagesCount {
    final value = _departmentMessages.length - _readDepartmentMessagesCount;
    return value < 0 ? 0 : value;
  }

  int get totalUnreadMessages =>
      unreadNewsCount + unreadDepartmentMessagesCount;
  bool get hasUnreadMessages => totalUnreadMessages > 0;

  final SeasonReportBuilder _seasonReportBuilder = const SeasonReportBuilder();
  final SeasonFinancialReportService _seasonFinancialReportService =
      const SeasonFinancialReportService();

  SeasonReport? lastSeasonReport;

  List<Player> _seasonStartSnapshot = <Player>[];
  FinanceSnapshot? _seasonStartFinanceSnapshot;
  final Set<int> _processedEvolutionMonths = <int>{};

  late SeededRng _rng;
  late PlayerFactory _playerFactory;
  late MarketService _marketService;
  late ScoutService _scoutService;

  final MatchEngine _matchEngine = const MatchEngine();
  final MatchLiveNarrativeService _matchLiveNarrativeService =
      MatchLiveNarrativeService();

  final LeagueTableService _tableService = const LeagueTableService();
  final TeamPowerService _teamPowerService = const TeamPowerService();
  final AutoLineupService _autoLineupService = const AutoLineupService();
  final SeasonService _seasonService = const SeasonService();
  final CupService _cupService = const CupService();
  final SimonBolivarService _simonBolivarService = const SimonBolivarService();
  final CompetitionQualificationService _competitionQualificationService =
      const CompetitionQualificationService();
  final DepartmentMessageService _departmentMessageService =
      const DepartmentMessageService();
  final CpuTransferService _cpuTransferService = const CpuTransferService();
  final SeasonExpectationService _seasonExpectationService =
      const SeasonExpectationService();
  final SeasonCheckpointService _checkpointService =
      const SeasonCheckpointService();

  final SeasonNarrativeAnalyzer _seasonNarrativeAnalyzer =
      const SeasonNarrativeAnalyzer();

  final NarrativeWriterService _narrativeWriterService =
      const NarrativeWriterService();

  final TicketRevenueService _ticketRevenueService =
      const TicketRevenueService();

  final SponsorRevenueService _sponsorRevenueService =
      const SponsorRevenueService();

  final CompetitionPrizeService _competitionPrizeService =
      const CompetitionPrizeService();

  final FinanceRulesService _financeRulesService = FinanceRulesService();
  late final FinanceClubService _financeClubService =
      FinanceClubService(_financeRulesService);
  late final FinanceRuntimeService _financeRuntimeService =
      FinanceRuntimeService(
    financeClubService: _financeClubService,
    financeRulesService: _financeRulesService,
  );

  final LegacyRuntimeService _legacyRuntimeService =
      const LegacyRuntimeService();

  final ClubStatusRuntimeService _clubStatusRuntimeService =
      const ClubStatusRuntimeService();

  final StructureRuntimeService _structureRuntimeService =
      const StructureRuntimeService();

  final Map<String, FinanceSnapshot> _financeByClub =
      <String, FinanceSnapshot>{};

  final Map<String, ClubLegacyEntry> _clubLegacy = <String, ClubLegacyEntry>{};
  Map<String, ClubLegacyEntry> get clubLegacy => Map.unmodifiable(_clubLegacy);

  final Map<String, List<Player>> _proSquads = <String, List<Player>>{};
  final Map<String, String> _clubNames = <String, String>{};
  final Map<String, ClubEntry> _clubs = <String, ClubEntry>{};

  final Map<DivisionId, List<String>> _clubIdsByDiv =
      <DivisionId, List<String>>{
    DivisionId.brA: <String>[],
    DivisionId.brB: <String>[],
    DivisionId.brC: <String>[],
    DivisionId.brD: <String>[],
  };

  final Map<String, double> _cpuClubPower10 = <String, double>{};
  final Map<DivisionId, LeagueSeasonBundle> _seasonByDiv =
      <DivisionId, LeagueSeasonBundle>{};
  final Map<DivisionId, LeagueTable> _tableByDiv = <DivisionId, LeagueTable>{};

  bool _annualYouthProcessed = false;

  FinanceSnapshot get userFinance =>
      _financeByClub[userClubId] ??
      const FinanceSnapshot(
        caixa: 0,
        operacional: 0,
        debt: 0,
        monthlyWage: 0,
        health: FinanceHealth.muitoSaudavel,
      );

  int get userBalance => userFinance.caixa;
  int get userCaixaLivre => userFinance.caixa;
  int get userOperationalCash => userFinance.operacional;
  int get userDebt => userFinance.debt;
  int get userMonthlyWage => userFinance.monthlyWage;

  int get userStructureMaintenance =>
      _structureRuntimeService.structureMaintenanceOfClub(
        clubId: userClubId,
        userClubId: userClubId,
        userStructures: _userClubStructures,
        catalogResolver: ClubStructuresCatalog.byId,
      );

  int get userTotalMonthlyFixedCost =>
      userMonthlyWage + userStructureMaintenance + userCoachMonthlySalary;

  FinanceHealth get userFinanceHealth => userFinance.health;

  double get userRepassPercentage =>
      _financeRulesService.repassPercentage(userFinance.health);

  ClubLegacyEntry? getUserClubLegacy() {
    return _legacyRuntimeService.getClubLegacy(_clubLegacy, userClubId);
  }

  int get userLegacyPoints => getUserClubLegacy()?.totalPoints ?? 0;
  int get userLegacySeasons => getUserClubLegacy()?.seasons ?? 0;

  String get userLegacyLabel => ClubLegacyHelper.label(userLegacyPoints);
  String get userLegacyShortLabel =>
      ClubLegacyHelper.shortLabel(userLegacyPoints);
  String get userLegacyPressureLabel =>
      ClubLegacyHelper.pressureLabel(userLegacyPoints);
  String get userLegacyEmotionalContext =>
      ClubLegacyHelper.emotionalContext(userLegacyPoints);

  String get userLegacySummaryLine {
    final seasons = userLegacySeasons;

    if (seasons <= 0) {
      return 'O projeto esportivo ainda está começando e não possui histórico consolidado no clube.';
    }

    return '$userLegacyLabel após $seasons temporada(s). $userLegacyEmotionalContext';
  }

  ClubStatusSnapshot get userClubStatus {
    return _clubStatusRuntimeService.build(
      historicalSize: _userHistoricalSize(),
      clubPower10: clubPower10(userClubId),
      legacyPoints: userLegacyPoints,
      divisionId: _userDiv(),
    );
  }

  String get userClubStatusLabel => userClubStatus.label;
  String get userClubStatusPressure => userClubStatus.pressure;
  String get userClubStatusExpectation => userClubStatus.expectation;
  String get userClubStatusNarrativeContext => userClubStatus.narrativeContext;
  int get userClubStatusScore => userClubStatus.statusScore;
  ClubStatusTier get userClubStatusTier => userClubStatus.currentTier;
  ClubHistoricalSize get userClubHistoricalSize =>
      userClubStatus.historicalSize;

  ClubHistoricalSize _userHistoricalSize() {
    final basePower = clubCpuPower10(userClubId);

    if (basePower >= 7.0) return ClubHistoricalSize.big;
    if (basePower >= 5.2) return ClubHistoricalSize.medium;
    return ClubHistoricalSize.small;
  }

  void startSeason({
    required String division,
    required int seed,
    required String userClubId,
    required String userClubName,
  }) {
    _startSeasonInternal(
      division: division,
      seed: seed,
      userClubId: userClubId,
      userClubName: userClubName,
    );

    initializeDirectorCareer(
      seasonYear: _seasonYear,
      clubId: this.userClubId,
      clubName: this.userClubName,
    );

    _seedFinanceForWorldIfNeeded();
    _recalculateMonthlyWagesForWorld();

    _seasonStartFinanceSnapshot = userFinance;

    _autoSave();
  }

  void startSeasonFromSave({
    required String division,
    required int seed,
    required String userClubId,
    required String userClubName,
  }) {
    _startSeasonInternal(
      division: division,
      seed: seed,
      userClubId: userClubId,
      userClubName: userClubName,
    );

    _seedFinanceForWorldIfNeeded();
    _recalculateMonthlyWagesForWorld();

    _seasonStartFinanceSnapshot = userFinance;
  }

  void simulateRound() {
    _simulateRoundInternal();
    _autoSave();
  }

  void startNextSeason() {
    _startNextSeasonInternal();
    _seedFinanceForWorldIfNeeded();
    _recalculateMonthlyWagesForWorld();

    _seasonStartFinanceSnapshot = userFinance;

    _autoSave();
  }

  void setUserClubStructures(ClubStructures value) {
    _userClubStructures = _structureRuntimeService.clampByComplexo(value);
    notifyListeners();
  }

  int getStructureLevel(ClubStructureType type) {
    return _structureRuntimeService.getStructureLevel(
      _userClubStructures,
      type,
    );
  }

  bool canUpgradeStructure(ClubStructureType type) {
    return _structureRuntimeService.canUpgrade(
      _userClubStructures,
      type,
    );
  }

  bool upgradeUserStructure(ClubStructureType type) {
    final currentBalance =
        userClubId.isNotEmpty ? _ensureFinanceForClub(userClubId).caixa : 0;

    final result = _structureRuntimeService.tryUpgrade(
      currentStructures: _userClubStructures,
      type: type,
      currentBalance: currentBalance,
    );

    if (!result.success) return false;

    _userClubStructures = result.updatedStructures;

    if (userClubId.isNotEmpty && result.financeCost > 0) {
      final finance = _ensureFinanceForClub(userClubId);
      final updated = finance.copyWith(
        caixa: finance.caixa - result.financeCost,
      );
      _financeByClub[userClubId] = _financeClubService.refreshHealth(updated);
    }

    notifyListeners();
    return true;
  }

  ClubStructures _clampStructuresByComplexo(ClubStructures s) {
    return _structureRuntimeService.clampByComplexo(s);
  }

  void consumePendingCheckpoint() {
    if (_pendingCheckpoint == null) return;
    _pendingCheckpoint = null;
    notifyListeners();
  }

  void markAllMessagesAsRead() {
    _readNewsCount = _newsFeed.length;
    _readDepartmentMessagesCount = _departmentMessages.length;

    _readMatchNewsCount = _countNewsInCategory(GameMessageCategory.match);
    _readMarketNewsCount = _countNewsInCategory(GameMessageCategory.market) +
        _countNewsInCategory(GameMessageCategory.transfer) +
        _countNewsInCategory(GameMessageCategory.scout);
    _readWorldNewsCount = _countNewsInCategory(GameMessageCategory.world);
    _readFinanceNewsCount = _countNewsInCategory(GameMessageCategory.finance);
    _readTrainingNewsCount = _countNewsInCategory(GameMessageCategory.training);
    _readSeasonNewsCount = _countNewsInCategory(GameMessageCategory.season) +
        _countNewsInCategory(GameMessageCategory.competition) +
        _countNewsInCategory(GameMessageCategory.legacy) +
        _countNewsInCategory(GameMessageCategory.board) +
        _countNewsInCategory(GameMessageCategory.club) +
        _countNewsInCategory(GameMessageCategory.system) +
        _countNewsInCategory(GameMessageCategory.department);

    notifyListeners();
  }

  void markNewsAsRead() {
    _readNewsCount = _newsFeed.length;

    _readMatchNewsCount = _countNewsInCategory(GameMessageCategory.match);
    _readMarketNewsCount = _countNewsInCategory(GameMessageCategory.market) +
        _countNewsInCategory(GameMessageCategory.transfer) +
        _countNewsInCategory(GameMessageCategory.scout);
    _readWorldNewsCount = _countNewsInCategory(GameMessageCategory.world);
    _readFinanceNewsCount = _countNewsInCategory(GameMessageCategory.finance);
    _readTrainingNewsCount = _countNewsInCategory(GameMessageCategory.training);
    _readSeasonNewsCount = _countNewsInCategory(GameMessageCategory.season) +
        _countNewsInCategory(GameMessageCategory.competition) +
        _countNewsInCategory(GameMessageCategory.legacy) +
        _countNewsInCategory(GameMessageCategory.board) +
        _countNewsInCategory(GameMessageCategory.club) +
        _countNewsInCategory(GameMessageCategory.system) +
        _countNewsInCategory(GameMessageCategory.department);

    notifyListeners();
  }

  void markMatchNewsAsRead(int total) {
    _readMatchNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markMarketNewsAsRead(int total) {
    _readMarketNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markWorldNewsAsRead(int total) {
    _readWorldNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markFinanceNewsAsRead(int total) {
    _readFinanceNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markTrainingNewsAsRead(int total) {
    _readTrainingNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markSeasonNewsAsRead(int total) {
    _readSeasonNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void _syncReadNewsCountFromCategories() {
    _readNewsCount = _readMatchNewsCount +
        _readMarketNewsCount +
        _readWorldNewsCount +
        _readFinanceNewsCount +
        _readTrainingNewsCount +
        _readSeasonNewsCount;

    if (_readNewsCount > _newsFeed.length) {
      _readNewsCount = _newsFeed.length;
    }
  }

  void _normalizeReadCountersAfterLoad() {
    final matchCount = _countNewsInCategory(GameMessageCategory.match);
    final marketCount = _countNewsInCategory(GameMessageCategory.market) +
        _countNewsInCategory(GameMessageCategory.transfer) +
        _countNewsInCategory(GameMessageCategory.scout);
    final worldCount = _countNewsInCategory(GameMessageCategory.world);
    final financeCount = _countNewsInCategory(GameMessageCategory.finance);
    final trainingCount = _countNewsInCategory(GameMessageCategory.training);
    final seasonCount = _countNewsInCategory(GameMessageCategory.season) +
        _countNewsInCategory(GameMessageCategory.competition) +
        _countNewsInCategory(GameMessageCategory.legacy) +
        _countNewsInCategory(GameMessageCategory.board) +
        _countNewsInCategory(GameMessageCategory.club) +
        _countNewsInCategory(GameMessageCategory.system) +
        _countNewsInCategory(GameMessageCategory.department);

    _readMatchNewsCount = _readMatchNewsCount.clamp(0, matchCount);
    _readMarketNewsCount = _readMarketNewsCount.clamp(0, marketCount);
    _readWorldNewsCount = _readWorldNewsCount.clamp(0, worldCount);
    _readFinanceNewsCount = _readFinanceNewsCount.clamp(0, financeCount);
    _readTrainingNewsCount = _readTrainingNewsCount.clamp(0, trainingCount);
    _readSeasonNewsCount = _readSeasonNewsCount.clamp(0, seasonCount);

    _readNewsCount = _readMatchNewsCount +
        _readMarketNewsCount +
        _readWorldNewsCount +
        _readFinanceNewsCount +
        _readTrainingNewsCount +
        _readSeasonNewsCount;

    if (_readNewsCount > _newsFeed.length) {
      _readNewsCount = _newsFeed.length;
    }

    _readDepartmentMessagesCount =
        _readDepartmentMessagesCount.clamp(0, _departmentMessages.length);
  }

  int _countNewsInCategory(GameMessageCategory category) {
    var count = 0;
    for (final text in _newsFeed) {
      final key = text.trim();
      if (key.isEmpty) continue;
      if (_newsCategoryByText[key] == category) {
        count++;
      }
    }
    return count;
  }

  void _restoreLegacyCategoryReadCounters(int legacyReadNewsCount) {
    _readMatchNewsCount = 0;
    _readMarketNewsCount = 0;
    _readWorldNewsCount = 0;
    _readFinanceNewsCount = 0;
    _readTrainingNewsCount = 0;
    _readSeasonNewsCount = 0;

    final normalizedReadCount =
        legacyReadNewsCount.clamp(0, _newsFeed.length);

    if (normalizedReadCount == 0) return;

    final firstReadIndex = _newsFeed.length - normalizedReadCount;

    for (int i = firstReadIndex; i < _newsFeed.length; i++) {
      final text = _newsFeed[i].trim();
      if (text.isEmpty) continue;

      final category = newsCategoryOf(text);

      switch (category) {
        case GameMessageCategory.match:
          _readMatchNewsCount++;
          break;
        case GameMessageCategory.market:
        case GameMessageCategory.transfer:
        case GameMessageCategory.scout:
          _readMarketNewsCount++;
          break;
        case GameMessageCategory.world:
          _readWorldNewsCount++;
          break;
        case GameMessageCategory.finance:
          _readFinanceNewsCount++;
          break;
        case GameMessageCategory.training:
          _readTrainingNewsCount++;
          break;
        case GameMessageCategory.season:
        case GameMessageCategory.competition:
        case GameMessageCategory.legacy:
        case GameMessageCategory.board:
        case GameMessageCategory.club:
        case GameMessageCategory.system:
        case GameMessageCategory.department:
          _readSeasonNewsCount++;
          break;
      }
    }
  }

  void markDepartmentMessagesAsRead() {
    _readDepartmentMessagesCount = _departmentMessages.length;
    notifyListeners();
  }

  void _resetUnreadState() {
    _readNewsCount = 0;
    _readDepartmentMessagesCount = 0;

    _readMatchNewsCount = 0;
    _readMarketNewsCount = 0;
    _readWorldNewsCount = 0;
    _readFinanceNewsCount = 0;
    _readTrainingNewsCount = 0;
    _readSeasonNewsCount = 0;
  }

  List<Player> getProSquad() {
    return List.unmodifiable(_proSquads[userClubId] ?? const <Player>[]);
  }

  Player? _findPlayerInUserSquad(String playerKey) {
    final squad = _proSquads[userClubId];
    if (squad == null) return null;

    for (final player in squad) {
      if (player.id == playerKey || player.nome == playerKey) {
        return player;
      }
    }

    return null;
  }

  void _replacePlayerInUserSquad(Player updatedPlayer) {
    final squad = _proSquads[userClubId];
    if (squad == null) return;

    final index = squad.indexWhere(
      (player) => player.id == updatedPlayer.id,
    );

    if (index < 0) return;

    squad[index] = updatedPlayer;
  }

  PlayerMarketStatus _playerMarketStatusFromString(String status) {
    for (final value in PlayerMarketStatus.values) {
      if (value.name == status) return value;
    }

    return PlayerMarketStatus.normal;
  }

  String _contractMarketStatusNewsLabel(PlayerMarketStatus status) {
    switch (status) {
      case PlayerMarketStatus.transferListed:
        return 'à venda';
      case PlayerMarketStatus.loanListed:
        return 'disponível para empréstimo';
      case PlayerMarketStatus.transferOrLoan:
        return 'disponível para venda ou empréstimo';
      case PlayerMarketStatus.untouchable:
        return 'intransferível';
      case PlayerMarketStatus.releasePlanned:
        return 'marcado para rescisão';
      case PlayerMarketStatus.normal:
        return 'em situação normal';
    }
  }

  void setPlayerMarketStatus(String playerKey, String status) {
    final player = _findPlayerInUserSquad(playerKey);
    if (player == null) return;

    final marketStatus = _playerMarketStatusFromString(status);
    final updatedPlayer = player.changeMarketStatus(marketStatus);

    _replacePlayerInUserSquad(updatedPlayer);

    _insertNewsIfNew(
      '${player.nome} agora está ${_contractMarketStatusNewsLabel(marketStatus)}.',
      category: GameMessageCategory.market,
    );

    notifyListeners();
    _autoSave();
  }

  void renewPlayerContract(String playerKey, int newEndYear) {
    final player = _findPlayerInUserSquad(playerKey);
    if (player == null) return;

    final normalizedYear = newEndYear.clamp(_seasonYear, _seasonYear + 8);
    final updatedPlayer = player.renewContractUntil(normalizedYear);

    _replacePlayerInUserSquad(updatedPlayer);

    _insertNewsIfNew(
      '${player.nome} renovou contrato até 31/12/$normalizedYear.',
      category: GameMessageCategory.market,
    );

    _recalculateMonthlyWageForClub(userClubId);

    notifyListeners();
    _autoSave();
  }

  FinanceSnapshot? financeOfClub(String clubId) => _financeByClub[clubId];

  void restoreClubLegacyFromSave(Map<String, ClubLegacyEntry> value) {
    _legacyRuntimeService.restoreLegacyMap(
      target: _clubLegacy,
      source: value,
    );
    notifyListeners();
  }

  void setFinanceForClub(String clubId, FinanceSnapshot snapshot) {
    if (clubId.trim().isEmpty) return;

    _financeRuntimeService.setFinanceForClub(
      financeByClub: _financeByClub,
      clubId: clubId,
      snapshot: snapshot,
    );

    notifyListeners();
  }

  void applySeasonLegacy({
    required String clubId,
    required int points,
  }) {
    if (clubId.trim().isEmpty) return;

    final current = _clubLegacy[clubId];

    if (current == null) {
      _clubLegacy[clubId] = ClubLegacyEntry(
        clubId: clubId,
        totalPoints: points,
        seasons: 1,
      );
    } else {
      _clubLegacy[clubId] = current.copyWith(
        totalPoints: current.totalPoints + points,
        seasons: current.seasons + 1,
      );
    }

    notifyListeners();
  }

  int _calculateSeasonPerformancePoints() {
    return _legacyRuntimeService.calculateSeasonPerformancePoints(
      clubId: userClubId,
      divisionId: _userDiv(),
      tablesByDivision: _tableByDiv,
    );
  }

  int estimatePlayerValueForUserClub(Player player) {
    return _estimatePlayerValueForClub(
      player: player,
      clubId: userClubId,
    );
  }

  int calculatePlayerSalaryForUserClub(Player player) {
    return _calculatePlayerSalaryForClub(
      player: player,
      clubId: userClubId,
    );
  }

  void recalculateUserMonthlyWage() {
    _recalculateMonthlyWageForClub(userClubId);
    notifyListeners();
  }

  void applyUserFullRevenue(int value) {
    if (userClubId.isEmpty || value <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyFullRevenue(
      current: current,
      value: value,
    );

    notifyListeners();
  }

  void applyUserRestrictedRevenue(int value) {
    if (userClubId.isEmpty || value <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyRestrictedRevenue(
      current: current,
      value: value,
    );

    notifyListeners();
  }

  void applyUserTransferExpense({
    required int transferCost,
    required Player player,
  }) {
    if (userClubId.isEmpty) return;

    final current = _ensureFinanceForClub(userClubId);

    final salary = _calculatePlayerSalaryForClub(
      player: player,
      clubId: userClubId,
    );

    _financeByClub[userClubId] = _financeRuntimeService.applyTransferExpense(
      current: current,
      transferCost: transferCost,
      salary: salary,
    );

    notifyListeners();
  }

  void applyUserSaleFinance({
    required int value,
    required Player player,
  }) {
    if (userClubId.isEmpty) return;

    final current = _ensureFinanceForClub(userClubId);

    final salary = _calculatePlayerSalaryForClub(
      player: player,
      clubId: userClubId,
    );

    _financeByClub[userClubId] = _financeRuntimeService.applySale(
      current: current,
      value: value,
      salaryRemoved: salary,
    );

    notifyListeners();
  }

  void restoreCareerMetaFromSave({
    required int seasonYear,
    required int roundIndex,
    required bool seasonEnded,
    required String dateStr,
    String? currentDateIso,
  }) {
    _seasonYear = seasonYear;
    this.roundIndex = roundIndex;
    this.seasonEnded = seasonEnded;
    this.dateStr = dateStr;

    if (currentDateIso != null && currentDateIso.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(currentDateIso);
      if (parsed != null) {
        _currentDate = parsed;
        this.dateStr = _formatDate(_currentDate);
      }
    }

    notifyListeners();
  }

  FinanceSnapshot _ensureFinanceForClub(String clubId) {
    return _financeRuntimeService.ensureClubFinance(
      financeByClub: _financeByClub,
      clubId: clubId,
      factory: () => _financeRuntimeService.buildInitialFinanceForClub(
        clubId: clubId,
        divisionId: _divisionIdOfClub(clubId),
      ),
    );
  }

  void _seedFinanceForWorldIfNeeded() {
    _financeRuntimeService.seedFinanceForWorldIfNeeded(
      clubIdsByDiv: _clubIdsByDiv,
      financeByClub: _financeByClub,
      userClubId: userClubId,
      divisionResolver: _divisionIdOfClub,
    );
  }

  void _recalculateMonthlyWagesForWorld() {
    _financeRuntimeService.recalculateMonthlyWagesForWorld(
      financeByClub: _financeByClub,
      squadsByClub: _proSquads,
      salaryCalculator: (clubId, player) => _calculatePlayerSalaryForClub(
        player: player,
        clubId: clubId,
      ),
    );
  }

  void _recalculateMonthlyWageForClub(String clubId) {
    if (clubId.trim().isEmpty) return;

    final snapshot = _ensureFinanceForClub(clubId);
    final squad = _proSquads[clubId] ?? const <Player>[];

    final total = _financeRuntimeService.recalculateMonthlyWage(
      squad: squad,
      salaryCalculator: (player) => _calculatePlayerSalaryForClub(
        player: player,
        clubId: clubId,
      ),
    );

    _financeByClub[clubId] = _financeClubService.refreshHealth(
      snapshot.copyWith(monthlyWage: total),
    );
  }

  int _calculatePlayerSalaryForClub({
    required Player player,
    required String clubId,
  }) {
    final finance = _ensureFinanceForClub(clubId);
    final level = clubId == userClubId ? userFinanceiroLevel : 5;

    final value = _estimatePlayerValueForClub(
      player: player,
      clubId: clubId,
    );

    return _financeRuntimeService.calculatePlayerSalary(
      finance: finance,
      financeLevel: level,
      playerValue: value,
    );
  }

  int _estimatePlayerValueForClub({
    required Player player,
    required String clubId,
  }) {
    return _financeRuntimeService.estimatePlayerValue(
      playerOvr: player.ovrCheio,
      playerAge: player.idade,
      divisionId: _divisionIdOfClub(clubId),
    );
  }

  int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  DivisionId _divisionIdOfClub(String clubId) {
    for (final entry in _clubIdsByDiv.entries) {
      if (entry.value.contains(clubId)) {
        return entry.key;
      }
    }

    return _userDiv();
  }
}
