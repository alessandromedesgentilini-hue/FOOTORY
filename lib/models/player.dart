class Player {
  final String id;
  final String nome;

  final String nacionalidade;
  final int idade;
  final PosDet posDet;
  final String pe;
  final String faceAsset;

  final bool isLoan;
  final String? loanOriginClubId;

  final int contractEndYear;
  final PlayerMarketStatus marketStatus;

  final Map<String, int> attrs10;

  final int bolaParada;
  final int penalti;
  final int consistencia;

  final int temporadaJogos;
  final int temporadaGols;
  final int temporadaAssistencias;
  final int temporadaDestaques;

  Player({
    required this.id,
    required this.nome,
    required this.nacionalidade,
    required this.idade,
    required this.posDet,
    required this.pe,
    required this.faceAsset,
    required this.attrs10,
    required this.bolaParada,
    required this.penalti,
    required this.consistencia,
    this.temporadaJogos = 0,
    this.temporadaGols = 0,
    this.temporadaAssistencias = 0,
    this.temporadaDestaques = 0,
    this.isLoan = false,
    this.loanOriginClubId,
    this.contractEndYear = 2027,
    this.marketStatus = PlayerMarketStatus.normal,
  }) {
    if (attrs10.length != 10) {
      throw ArgumentError('attrs10 precisa ter exatamente 10 atributos');
    }
  }

  PosMacro get posMacro {
    switch (posDet) {
      case PosDet.gol:
        return PosMacro.gol;
      case PosDet.ld:
      case PosDet.le:
      case PosDet.zag:
        return PosMacro.def;
      case PosDet.vol:
      case PosDet.mc:
      case PosDet.mei:
        return PosMacro.mei;
      case PosDet.pd:
      case PosDet.pe:
      case PosDet.ca:
        return PosMacro.ata;
    }
  }

  String get posLabel {
    switch (posDet) {
      case PosDet.gol:
        return 'GOL';
      case PosDet.ld:
        return 'LD';
      case PosDet.le:
        return 'LE';
      case PosDet.zag:
        return 'ZAG';
      case PosDet.vol:
        return 'VOL';
      case PosDet.mc:
        return 'MC';
      case PosDet.mei:
        return 'MEI';
      case PosDet.pd:
        return 'PD';
      case PosDet.pe:
        return 'PE';
      case PosDet.ca:
        return 'CA';
    }
  }

  String get contractEndLabel => '31/12/$contractEndYear';

  bool isContractExpiredInSeason(int seasonYear) {
    return contractEndYear <= seasonYear;
  }

  bool isContractExpiringInSeason(int seasonYear) {
    return contractEndYear == seasonYear;
  }

  int contractYearsRemainingFrom(int seasonYear) {
    return (contractEndYear - seasonYear).clamp(0, 99);
  }

  bool get isTransferListed =>
      marketStatus == PlayerMarketStatus.transferListed;

  bool get isLoanListed => marketStatus == PlayerMarketStatus.loanListed;

  bool get isTransferOrLoan =>
      marketStatus == PlayerMarketStatus.transferOrLoan;

  bool get isUntouchable => marketStatus == PlayerMarketStatus.untouchable;

  bool get isReleasePlanned =>
      marketStatus == PlayerMarketStatus.releasePlanned;

  String get marketStatusLabel {
    switch (marketStatus) {
      case PlayerMarketStatus.transferListed:
        return 'À venda';
      case PlayerMarketStatus.loanListed:
        return 'Empréstimo';
      case PlayerMarketStatus.transferOrLoan:
        return 'Venda ou empréstimo';
      case PlayerMarketStatus.untouchable:
        return 'Intransferível';
      case PlayerMarketStatus.releasePlanned:
        return 'Rescisão planejada';
      case PlayerMarketStatus.normal:
        return 'Normal';
    }
  }

  int get ovrCheio {
    var sum = 0;
    for (final v in attrs10.values) {
      sum += v;
    }
    return sum;
  }

  double get rating10 => (ovrCheio / 10.0).clamp(1.0, 10.0);

  int get ovr10 => rating10.floor().clamp(0, 10);

  int get stars10 => ovr10;

  int get stars5 => ((stars10 / 2).floor()).clamp(0, 5);

  String get label10 => '$stars10 / 10';

  int get participacoesEmGol => temporadaGols + temporadaAssistencias;

  bool get temParticipacaoDiretaNaTemporada =>
      temporadaGols > 0 || temporadaAssistencias > 0;

  String get resumoTemporadaCurto {
    if (temporadaGols <= 0 &&
        temporadaAssistencias <= 0 &&
        temporadaDestaques <= 0) {
      return '$temporadaJogos jogo(s) na temporada';
    }

    return '$temporadaJogos jogo(s) • '
        '$temporadaGols gol(s) • '
        '$temporadaAssistencias assistência(s)';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'nacionalidade': nacionalidade,
        'idade': idade,
        'posDet': posDet.name,
        'pe': pe,
        'faceAsset': faceAsset,
        'attrs10': attrs10,
        'bolaParada': bolaParada,
        'penalti': penalti,
        'consistencia': consistencia,
        'temporadaJogos': temporadaJogos,
        'temporadaGols': temporadaGols,
        'temporadaAssistencias': temporadaAssistencias,
        'temporadaDestaques': temporadaDestaques,
        'isLoan': isLoan,
        'loanOriginClubId': loanOriginClubId,
        'contractEndYear': contractEndYear,
        'marketStatus': marketStatus.name,
      };

  static Player fromJson(Map<String, dynamic> json) {
    final rawAttrs = (json['attrs10'] as Map).cast<String, dynamic>();
    final attrs = <String, int>{};

    for (final e in rawAttrs.entries) {
      attrs[e.key] = (e.value as num).toInt();
    }

    final id = json['id'] as String;
    final rawFaceAsset = (json['faceAsset'] as String?)?.trim();

    return Player(
      id: id,
      nome: json['nome'] as String,
      nacionalidade: json['nacionalidade'] as String,
      idade: (json['idade'] as num).toInt(),
      posDet: PosDet.values.byName(json['posDet'] as String),
      pe: (json['pe'] as String?) ?? 'D',
      faceAsset: _safeFaceAsset(
        playerId: id,
        rawFaceAsset: rawFaceAsset,
      ),
      attrs10: attrs,
      bolaParada: (json['bolaParada'] as num).toInt(),
      penalti: (json['penalti'] as num).toInt(),
      consistencia: (json['consistencia'] as num).toInt(),
      temporadaJogos: (json['temporadaJogos'] as num?)?.toInt() ?? 0,
      temporadaGols: (json['temporadaGols'] as num?)?.toInt() ?? 0,
      temporadaAssistencias:
          (json['temporadaAssistencias'] as num?)?.toInt() ?? 0,
      temporadaDestaques: (json['temporadaDestaques'] as num?)?.toInt() ?? 0,
      isLoan: json['isLoan'] as bool? ?? false,
      loanOriginClubId: json['loanOriginClubId'] as String?,
      contractEndYear: (json['contractEndYear'] as num?)?.toInt() ?? 2027,
      marketStatus: _marketStatusFromJson(json['marketStatus']),
    );
  }

  static PlayerMarketStatus _marketStatusFromJson(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return PlayerMarketStatus.normal;
    }

    for (final status in PlayerMarketStatus.values) {
      if (status.name == value) {
        return status;
      }
    }

    return PlayerMarketStatus.normal;
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

  Player copyWith({
    String? id,
    String? nome,
    String? nacionalidade,
    int? idade,
    PosDet? posDet,
    String? pe,
    String? faceAsset,
    Map<String, int>? attrs10,
    int? bolaParada,
    int? penalti,
    int? consistencia,
    int? temporadaJogos,
    int? temporadaGols,
    int? temporadaAssistencias,
    int? temporadaDestaques,
    bool? isLoan,
    String? loanOriginClubId,
    int? contractEndYear,
    PlayerMarketStatus? marketStatus,
  }) {
    return Player(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nacionalidade: nacionalidade ?? this.nacionalidade,
      idade: idade ?? this.idade,
      posDet: posDet ?? this.posDet,
      pe: pe ?? this.pe,
      faceAsset: faceAsset ?? this.faceAsset,
      attrs10: attrs10 ?? Map<String, int>.from(this.attrs10),
      bolaParada: bolaParada ?? this.bolaParada,
      penalti: penalti ?? this.penalti,
      consistencia: consistencia ?? this.consistencia,
      temporadaJogos: temporadaJogos ?? this.temporadaJogos,
      temporadaGols: temporadaGols ?? this.temporadaGols,
      temporadaAssistencias:
          temporadaAssistencias ?? this.temporadaAssistencias,
      temporadaDestaques: temporadaDestaques ?? this.temporadaDestaques,
      isLoan: isLoan ?? this.isLoan,
      loanOriginClubId: loanOriginClubId ?? this.loanOriginClubId,
      contractEndYear: contractEndYear ?? this.contractEndYear,
      marketStatus: marketStatus ?? this.marketStatus,
    );
  }

  Player renewContractUntil(int newEndYear) {
    if (newEndYear <= contractEndYear) return this;

    return copyWith(
      contractEndYear: newEndYear,
    );
  }

  Player changeMarketStatus(PlayerMarketStatus status) {
    return copyWith(
      marketStatus: status,
    );
  }

  Player addJogo({bool foiDestaque = false}) {
    return copyWith(
      temporadaJogos: temporadaJogos + 1,
      temporadaDestaques:
          foiDestaque ? temporadaDestaques + 1 : temporadaDestaques,
    );
  }

  Player addGol({int quantidade = 1}) {
    return copyWith(
      temporadaGols: temporadaGols + quantidade.clamp(0, 99),
    );
  }

  Player addAssistencia({int quantidade = 1}) {
    return copyWith(
      temporadaAssistencias: temporadaAssistencias + quantidade.clamp(0, 99),
    );
  }

  Player resetSeasonStats() {
    return copyWith(
      temporadaJogos: 0,
      temporadaGols: 0,
      temporadaAssistencias: 0,
      temporadaDestaques: 0,
    );
  }
}

enum PosDet {
  gol,
  ld,
  le,
  zag,
  vol,
  mc,
  mei,
  pd,
  pe,
  ca,
}

enum PosMacro {
  gol,
  def,
  mei,
  ata,
}

enum PlayerMarketStatus {
  normal,
  transferListed,
  loanListed,
  transferOrLoan,
  untouchable,
  releasePlanned,
}
