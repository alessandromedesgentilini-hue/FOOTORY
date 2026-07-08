import 'dart:convert';

class SaveSlotData {
  final String slotId;
  final String clubId;
  final String clubName;
  final String divisionId;

  final int seed;

  final String coachStaffId;

  // NOVO
  final int coachLevel;
  final int contractEndYear;
  final String coachPrestige;

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
    required this.seasonYear,
    required this.roundIndex,
    required this.savedAtIso,
  });

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
      seasonYear: seasonYear ?? this.seasonYear,
      roundIndex: roundIndex ?? this.roundIndex,
      savedAtIso: savedAtIso ?? this.savedAtIso,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'slotId': slotId,
      'clubId': clubId,
      'clubName': clubName,
      'divisionId': divisionId,
      'seed': seed,
      'coachStaffId': coachStaffId,
      'coachLevel': coachLevel,
      'contractEndYear': contractEndYear,
      'coachPrestige': coachPrestige,
      'seasonYear': seasonYear,
      'roundIndex': roundIndex,
      'savedAtIso': savedAtIso,
    };
  }

  factory SaveSlotData.fromMap(Map<String, dynamic> map) {
    return SaveSlotData(
      slotId: map['slotId'] as String? ?? '',
      clubId: map['clubId'] as String? ?? '',
      clubName: map['clubName'] as String? ?? '',
      divisionId: map['divisionId'] as String? ?? '',

      seed: (map['seed'] as num?)?.toInt() ?? 2026,

      coachStaffId: map['coachStaffId'] as String? ?? 'gegenpress',

      // compatibilidade com saves antigos
      coachLevel: (map['coachLevel'] as num?)?.toInt() ?? 1,

      contractEndYear: (map['contractEndYear'] as num?)?.toInt() ?? 2028,

      coachPrestige: map['coachPrestige'] as String? ?? 'regional',

      seasonYear: (map['seasonYear'] as num?)?.toInt() ?? 2026,

      roundIndex: (map['roundIndex'] as num?)?.toInt() ?? 1,

      savedAtIso:
          map['savedAtIso'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SaveSlotData.fromJson(String source) {
    return SaveSlotData.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }
}
