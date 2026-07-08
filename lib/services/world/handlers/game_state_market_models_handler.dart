part of '../game_state.dart';

class TransferOffer {
  final String playerId;
  final String playerName;
  final String fromClubId;
  final String toClubId;
  final int offeredValue;
  final int playerOvr;

  const TransferOffer({
    required this.playerId,
    required this.playerName,
    required this.fromClubId,
    required this.toClubId,
    required this.offeredValue,
    required this.playerOvr,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerName': playerName,
        'fromClubId': fromClubId,
        'toClubId': toClubId,
        'offeredValue': offeredValue,
        'playerOvr': playerOvr,
      };

  static TransferOffer fromJson(Map<String, dynamic> json) {
    return TransferOffer(
      playerId: (json['playerId'] as String?) ?? '',
      playerName: (json['playerName'] as String?) ?? '',
      fromClubId: (json['fromClubId'] as String?) ?? '',
      toClubId: (json['toClubId'] as String?) ?? '',
      offeredValue: (json['offeredValue'] as num?)?.toInt() ?? 0,
      playerOvr: (json['playerOvr'] as num?)?.toInt() ?? 0,
    );
  }
}

class ObservedPlayer {
  final String id;
  final String nome;
  final int idade;
  final int ovr;
  final PosDet posDet;
  final String clubIdAtual;
  final int anosObservado;
  final String faceAsset;

  final int? lockedTransferYear;
  final int? lockedTransferMonth;

  const ObservedPlayer({
    required this.id,
    required this.nome,
    required this.idade,
    required this.ovr,
    required this.posDet,
    required this.clubIdAtual,
    required this.anosObservado,
    required this.faceAsset,
    this.lockedTransferYear,
    this.lockedTransferMonth,
  });

  bool isLockedInTransferWindow({
    required int year,
    required int month,
  }) {
    return lockedTransferYear == year && lockedTransferMonth == month;
  }

  bool isLockedInCurrentWindow({
    required DateTime currentDate,
  }) {
    return isLockedInTransferWindow(
      year: currentDate.year,
      month: currentDate.month,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'idade': idade,
        'ovr': ovr,
        'posDet': posDet.name,
        'clubIdAtual': clubIdAtual,
        'anosObservado': anosObservado,
        'faceAsset': faceAsset,
        'lockedTransferYear': lockedTransferYear,
        'lockedTransferMonth': lockedTransferMonth,
      };

  static ObservedPlayer fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?) ?? '';

    return ObservedPlayer(
      id: id,
      nome: (json['nome'] as String?) ?? '',
      idade: (json['idade'] as num?)?.toInt() ?? 18,
      ovr: (json['ovr'] as num?)?.toInt() ?? 50,
      posDet: _parsePosDet((json['posDet'] as String?) ?? 'mc'),
      clubIdAtual: (json['clubIdAtual'] as String?) ?? '',
      anosObservado: (json['anosObservado'] as num?)?.toInt() ?? 0,
      faceAsset: _safeFaceAsset(
        playerId: id,
        rawFaceAsset: (json['faceAsset'] as String?)?.trim(),
      ),
      lockedTransferYear: (json['lockedTransferYear'] as num?)?.toInt(),
      lockedTransferMonth: (json['lockedTransferMonth'] as num?)?.toInt(),
    );
  }

  ObservedPlayer copyWith({
    String? id,
    String? nome,
    int? idade,
    int? ovr,
    PosDet? posDet,
    String? clubIdAtual,
    int? anosObservado,
    String? faceAsset,
    int? lockedTransferYear,
    int? lockedTransferMonth,
    bool clearTransferLock = false,
  }) {
    return ObservedPlayer(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
      ovr: ovr ?? this.ovr,
      posDet: posDet ?? this.posDet,
      clubIdAtual: clubIdAtual ?? this.clubIdAtual,
      anosObservado: anosObservado ?? this.anosObservado,
      faceAsset: faceAsset ?? this.faceAsset,
      lockedTransferYear: clearTransferLock
          ? null
          : lockedTransferYear ?? this.lockedTransferYear,
      lockedTransferMonth: clearTransferLock
          ? null
          : lockedTransferMonth ?? this.lockedTransferMonth,
    );
  }

  static PosDet _parsePosDet(String raw) {
    try {
      return PosDet.values.byName(raw);
    } catch (_) {
      return PosDet.mc;
    }
  }

  static String _safeFaceAsset({
    required String playerId,
    required String? rawFaceAsset,
  }) {
    if (rawFaceAsset != null &&
        rawFaceAsset.isNotEmpty &&
        rawFaceAsset.startsWith('assets/faces/players/') &&
        rawFaceAsset.endsWith('.png')) {
      return rawFaceAsset;
    }

    return _faceAssetFromSeed(playerId);
  }

  static String _faceAssetFromSeed(String seed) {
    const folders = <String>[
      'latin',
      'afro',
      'european',
      'arab',
      'asian',
    ];

    final hash = seed.hashCode.abs();
    final folder = folders[hash % folders.length];
    final index = (hash % 29) + 1;
    final fileName = '${index.toString().padLeft(3, '0')}.png';

    return 'assets/faces/players/$folder/$fileName';
  }
}

class FutureArrival {
  final Player player;
  final MarketListType listType;
  final int agreedCost;
  final int agreedSalary;
  final int marketValue;
  final int arrivalYear;
  final int arrivalMonth;
  final bool isOpportunity;
  final double discount;

  const FutureArrival({
    required this.player,
    required this.listType,
    required this.agreedCost,
    required this.agreedSalary,
    required this.marketValue,
    required this.arrivalYear,
    required this.arrivalMonth,
    this.isOpportunity = false,
    this.discount = 0.0,
  });

  String get arrivalLabel {
    final month = arrivalMonth == 7 ? 'julho' : 'janeiro';
    return '$month/$arrivalYear';
  }

  String get typeLabel {
    switch (listType) {
      case MarketListType.transfer:
        return 'Transferência';
      case MarketListType.loan:
        return 'Empréstimo';
      case MarketListType.free:
        return 'Agente livre';
    }
  }

  Map<String, dynamic> toJson() => {
        'player': player.toJson(),
        'listType': listType.name,
        'agreedCost': agreedCost,
        'agreedSalary': agreedSalary,
        'marketValue': marketValue,
        'arrivalYear': arrivalYear,
        'arrivalMonth': arrivalMonth,
        'isOpportunity': isOpportunity,
        'discount': discount,
      };

  static FutureArrival fromJson(Map<String, dynamic> json) {
    final rawType = (json['listType'] as String?) ?? 'transfer';

    MarketListType type;
    switch (rawType) {
      case 'loan':
        type = MarketListType.loan;
        break;
      case 'free':
        type = MarketListType.free;
        break;
      case 'transfer':
      default:
        type = MarketListType.transfer;
        break;
    }

    final playerMap = (json['player'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return FutureArrival(
      player: Player.fromJson(playerMap),
      listType: type,
      agreedCost: (json['agreedCost'] as num?)?.toInt() ?? 0,
      agreedSalary: (json['agreedSalary'] as num?)?.toInt() ?? 0,
      marketValue: (json['marketValue'] as num?)?.toInt() ?? 0,
      arrivalYear: (json['arrivalYear'] as num?)?.toInt() ?? 2026,
      arrivalMonth: (json['arrivalMonth'] as num?)?.toInt() ?? 7,
      isOpportunity: json['isOpportunity'] == true,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

extension GameStateMarketModelsHandler on GameState {
  bool isObservedPlayerLockedThisWindow(ObservedPlayer player) {
    return player.isLockedInTransferWindow(
      year: _currentDate.year,
      month: _currentDate.month,
    );
  }

  bool canNegotiateObservedPlayer(ObservedPlayer player) {
    if (isObservedPlayerLockedThisWindow(player)) return false;
    return true;
  }

  bool get isJanuaryTransferWindow => currentMonth == 1;
  bool get isJulyTransferWindow => currentMonth == 7;

  bool get isTransferWindowOpen =>
      isJanuaryTransferWindow || isJulyTransferWindow;

  String get transferWindowLabel {
    if (isJanuaryTransferWindow) return 'Janela de Janeiro';
    if (isJulyTransferWindow) return 'Janela de Julho';
    return 'Fora da janela';
  }

  String get nextTransferWindowLabel {
    final next = _nextTransferWindowDate();
    final month = next.month == 7 ? 'julho' : 'janeiro';
    return '$month/${next.year}';
  }

  bool canNegotiateScoutTarget(MarketListType type) {
    switch (type) {
      case MarketListType.free:
      case MarketListType.transfer:
      case MarketListType.loan:
        return true;
    }
  }

  bool _shouldRefreshMarketForCurrentWindow() {
    if (!isTransferWindowOpen) return false;

    return _lastMarketRefreshYear != _currentDate.year ||
        _lastMarketRefreshMonth != _currentDate.month;
  }

  void _markMarketRefreshedForCurrentWindow() {
    _lastMarketRefreshYear = _currentDate.year;
    _lastMarketRefreshMonth = _currentDate.month;
  }

  void _resetMarketWindowControl() {
    _lastMarketRefreshYear = null;
    _lastMarketRefreshMonth = null;
  }

  DateTime _nextTransferWindowDate() {
    final year = _currentDate.year;
    final month = _currentDate.month;

    if (month < 7) {
      return DateTime(year, 7, 1);
    }

    if (month == 7) {
      return DateTime(year, 7, 1);
    }

    return DateTime(year + 1, 1, 1);
  }
}
