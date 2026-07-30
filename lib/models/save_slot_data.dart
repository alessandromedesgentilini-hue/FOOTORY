import 'dart:convert';

class SaveSlotData {
  static const int minimumSeasonYear = 2026;
  static const int maximumSeasonYear = 2099;

  final String slotId;

  final String clubId;
  final String clubName;
  final String divisionId;

  final int seed;

  final String coachStaffId;
  final int coachLevel;
  final int contractEndYear;
  final String coachPrestige;

  final String? directorName;
  final String? directorPortraitId;

  final int seasonYear;
  final int roundIndex;

  final String savedAtIso;

  const SaveSlotData({
    required this.slotId,
    required this.clubId,
    required this.clubName,
    required this.divisionId,
    required this.seed,
    required this.coachStaffId,
    required this.coachLevel,
    required this.contractEndYear,
    required this.coachPrestige,
    required this.directorName,
    required this.directorPortraitId,
    required this.seasonYear,
    required this.roundIndex,
    required this.savedAtIso,
  });

  bool get hasDirectorSummary {
    return _hasText(directorName) && _hasText(directorPortraitId);
  }

  bool get hasValidCareerSummary {
    return _hasText(slotId) &&
        _hasText(clubId) &&
        _hasText(clubName) &&
        _hasText(divisionId);
  }

  String get normalizedDivisionId {
    return _normalizeDivisionId(divisionId);
  }

  DateTime? get savedAt {
    final normalizedValue = savedAtIso.trim();

    if (normalizedValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(normalizedValue);
  }

  SaveSlotData copyWith({
    String? slotId,
    String? clubId,
    String? clubName,
    String? divisionId,
    int? seed,
    String? coachStaffId,
    int? coachLevel,
    int? contractEndYear,
    String? coachPrestige,
    String? directorName,
    String? directorPortraitId,
    bool clearDirectorName = false,
    bool clearDirectorPortraitId = false,
    int? seasonYear,
    int? roundIndex,
    String? savedAtIso,
  }) {
    return SaveSlotData(
      slotId: slotId ?? this.slotId,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      divisionId: divisionId ?? this.divisionId,
      seed: seed ?? this.seed,
      coachStaffId: coachStaffId ?? this.coachStaffId,
      coachLevel: coachLevel ?? this.coachLevel,
      contractEndYear: contractEndYear ?? this.contractEndYear,
      coachPrestige: coachPrestige ?? this.coachPrestige,
      directorName:
          clearDirectorName ? null : directorName ?? this.directorName,
      directorPortraitId: clearDirectorPortraitId
          ? null
          : directorPortraitId ?? this.directorPortraitId,
      seasonYear: seasonYear ?? this.seasonYear,
      roundIndex: roundIndex ?? this.roundIndex,
      savedAtIso: savedAtIso ?? this.savedAtIso,
    );
  }

  Map<String, dynamic> toMap() {
    final normalizedSeasonYear = seasonYear.clamp(
      minimumSeasonYear,
      maximumSeasonYear,
    );

    final normalizedContractEndYear = contractEndYear.clamp(
      normalizedSeasonYear,
      maximumSeasonYear,
    );

    return <String, dynamic>{
      'slotId': slotId.trim(),
      'clubId': clubId.trim(),
      'clubName': clubName.trim(),
      'divisionId': _normalizeDivisionId(
        divisionId,
      ),
      'seed': seed,
      'coachStaffId': _normalizeCoachStaffId(
        coachStaffId,
      ),
      'coachLevel': coachLevel.clamp(1, 10),
      'contractEndYear': normalizedContractEndYear,
      'coachPrestige': _normalizeCoachPrestige(
        coachPrestige,
      ),
      'directorName': _nullableTrimmedString(
        directorName,
      ),
      'directorPortraitId': _nullableTrimmedString(
        directorPortraitId,
      ),
      'seasonYear': normalizedSeasonYear,
      'roundIndex': roundIndex.clamp(1, 9999),
      'savedAtIso': _normalizeSavedAtIso(
        savedAtIso,
      ),
    };
  }

  factory SaveSlotData.fromMap(
    Map<String, dynamic> map,
  ) {
    final seasonYear = _readInt(
      map['seasonYear'],
      fallback: minimumSeasonYear,
    ).clamp(
      minimumSeasonYear,
      maximumSeasonYear,
    );

    final footballDirectorMap = _readMap(
      map['footballDirector'],
    );

    final directorName = _firstNonEmptyString(
      <dynamic>[
        map['directorName'],
        footballDirectorMap?['name'],
      ],
    );

    final directorPortraitId = _firstNonEmptyString(
      <dynamic>[
        map['directorPortraitId'],
        footballDirectorMap?['portraitId'],
        footballDirectorMap?['avatarId'],
      ],
    );

    return SaveSlotData(
      slotId: _readString(
        map['slotId'],
      ),
      clubId: _readString(
        map['clubId'],
      ),
      clubName: _readString(
        map['clubName'],
      ),
      divisionId: _normalizeDivisionId(
        _readString(
          map['divisionId'],
        ),
      ),
      seed: _readInt(
        map['seed'],
        fallback: minimumSeasonYear,
      ),
      coachStaffId: _normalizeCoachStaffId(
        _readString(
          map['coachStaffId'],
          fallback: 'gegenpress',
        ),
      ),
      coachLevel: _readInt(
        map['coachLevel'],
        fallback: 1,
      ).clamp(1, 10),
      contractEndYear: _readInt(
        map['contractEndYear'],
        fallback: seasonYear + 2,
      ).clamp(
        seasonYear,
        maximumSeasonYear,
      ),
      coachPrestige: _normalizeCoachPrestige(
        _readString(
          map['coachPrestige'],
          fallback: 'regional',
        ),
      ),
      directorName: directorName,
      directorPortraitId: directorPortraitId,
      seasonYear: seasonYear,
      roundIndex: _readInt(
        map['roundIndex'],
        fallback: 1,
      ).clamp(1, 9999),
      savedAtIso: _normalizeSavedAtIso(
        _readString(
          map['savedAtIso'],
          fallback: DateTime.now().toIso8601String(),
        ),
      ),
    );
  }

  String toJson() {
    return jsonEncode(
      toMap(),
    );
  }

  factory SaveSlotData.fromJson(String source) {
    final normalizedSource = source.trim();

    if (normalizedSource.isEmpty) {
      throw const FormatException(
        'O conteúdo do slot está vazio.',
      );
    }

    final decoded = jsonDecode(
      normalizedSource,
    );

    if (decoded is! Map) {
      throw const FormatException(
        'O conteúdo do slot não possui um objeto JSON válido.',
      );
    }

    return SaveSlotData.fromMap(
      _mapFromDynamic(decoded),
    );
  }

  static Map<String, dynamic>? _readMap(
    dynamic value,
  ) {
    if (value is! Map) {
      return null;
    }

    return _mapFromDynamic(value);
  }

  static Map<String, dynamic> _mapFromDynamic(
    Map<dynamic, dynamic> value,
  ) {
    final result = <String, dynamic>{};

    for (final entry in value.entries) {
      result[entry.key.toString()] = entry.value;
    }

    return result;
  }

  static int _readInt(
    dynamic value, {
    required int fallback,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final parsedValue = int.tryParse(
        value.trim(),
      );

      if (parsedValue != null) {
        return parsedValue;
      }
    }

    return fallback;
  }

  static String _readString(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final normalizedValue = value.toString().trim();

    if (normalizedValue.isEmpty) {
      return fallback;
    }

    return normalizedValue;
  }

  static String? _firstNonEmptyString(
    Iterable<dynamic> values,
  ) {
    for (final value in values) {
      final normalizedValue = _readNullableString(
        value,
      );

      if (normalizedValue != null) {
        return normalizedValue;
      }
    }

    return null;
  }

  static String? _readNullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final normalizedValue = value.toString().trim();

    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  static String? _nullableTrimmedString(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final normalizedValue = value.trim();

    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String _normalizeCoachStaffId(
    String value,
  ) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      return 'gegenpress';
    }

    return normalizedValue;
  }

  static String _normalizeCoachPrestige(
    String value,
  ) {
    final normalizedValue = value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u');

    switch (normalizedValue) {
      case 'regional':
        return 'regional';
      case 'nacional':
        return 'nacional';
      case 'continental':
        return 'continental';
      case 'internacional':
        return 'internacional';
      case 'lendario':
        return 'lendario';
      default:
        return 'regional';
    }
  }

  static String _normalizeDivisionId(
    String value,
  ) {
    switch (value.trim().toUpperCase()) {
      case 'BRA':
      case 'BR-A':
        return 'BR-A';

      case 'BRB':
      case 'BR-B':
        return 'BR-B';

      case 'BRC':
      case 'BR-C':
        return 'BR-C';

      case 'BRD':
      case 'BR-D':
        return 'BR-D';

      default:
        return value.trim().toUpperCase();
    }
  }

  static String _normalizeSavedAtIso(
    String value,
  ) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      return DateTime.now().toIso8601String();
    }

    final parsedValue = DateTime.tryParse(
      normalizedValue,
    );

    if (parsedValue == null) {
      return DateTime.now().toIso8601String();
    }

    return parsedValue.toIso8601String();
  }
}
