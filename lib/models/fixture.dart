class Fixture {
  final int round;
  final String homeClubId;
  final String awayClubId;

  final int? homeGoals;
  final int? awayGoals;

  const Fixture({
    required this.round,
    required this.homeClubId,
    required this.awayClubId,
    this.homeGoals,
    this.awayGoals,
  });

  bool get played => homeGoals != null && awayGoals != null;

  Fixture copyWith({
    int? round,
    String? homeClubId,
    String? awayClubId,
    int? homeGoals,
    int? awayGoals,
    bool clearResult = false,
  }) {
    return Fixture(
      round: round ?? this.round,
      homeClubId: homeClubId ?? this.homeClubId,
      awayClubId: awayClubId ?? this.awayClubId,
      homeGoals: clearResult ? null : homeGoals ?? this.homeGoals,
      awayGoals: clearResult ? null : awayGoals ?? this.awayGoals,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'round': round,
      'homeClubId': homeClubId,
      'awayClubId': awayClubId,
      'homeGoals': homeGoals,
      'awayGoals': awayGoals,
    };
  }

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      round: _readInt(json['round'], fallback: 1),
      homeClubId: json['homeClubId'] as String? ?? '',
      awayClubId: json['awayClubId'] as String? ?? '',
      homeGoals: _readNullableInt(json['homeGoals']),
      awayGoals: _readNullableInt(json['awayGoals']),
    );
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static int? _readNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
