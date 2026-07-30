class FootballDirector {
  final String name;
  final int age;
  final String countryCode;
  final String favoriteClubId;
  final String favoriteTacticalIdentityId;
  final String portraitId;

  const FootballDirector({
    required this.name,
    required this.age,
    required this.countryCode,
    required this.favoriteClubId,
    required this.favoriteTacticalIdentityId,
    required this.portraitId,
  });

  bool get hasRequiredData {
    return name.trim().isNotEmpty &&
        age > 0 &&
        countryCode.trim().isNotEmpty &&
        favoriteClubId.trim().isNotEmpty &&
        favoriteTacticalIdentityId.trim().isNotEmpty &&
        portraitId.trim().isNotEmpty;
  }

  FootballDirector copyWith({
    String? name,
    int? age,
    String? countryCode,
    String? favoriteClubId,
    String? favoriteTacticalIdentityId,
    String? portraitId,
  }) {
    return FootballDirector(
      name: name ?? this.name,
      age: age ?? this.age,
      countryCode: countryCode ?? this.countryCode,
      favoriteClubId: favoriteClubId ?? this.favoriteClubId,
      favoriteTacticalIdentityId:
          favoriteTacticalIdentityId ?? this.favoriteTacticalIdentityId,
      portraitId: portraitId ?? this.portraitId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name.trim(),
      'age': age,
      'countryCode': countryCode.trim().toUpperCase(),
      'favoriteClubId': favoriteClubId.trim(),
      'favoriteTacticalIdentityId': favoriteTacticalIdentityId.trim(),
      'portraitId': portraitId.trim(),
    };
  }

  factory FootballDirector.fromMap(Map<String, dynamic> map) {
    return FootballDirector(
      name: (map['name'] as String? ?? '').trim(),
      age: _readInt(map['age']),
      countryCode: (map['countryCode'] as String? ?? '').trim().toUpperCase(),
      favoriteClubId: (map['favoriteClubId'] as String? ?? '').trim(),
      favoriteTacticalIdentityId:
          (map['favoriteTacticalIdentityId'] as String? ?? '').trim(),
      portraitId: (map['portraitId'] as String? ?? '').trim(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FootballDirector &&
            runtimeType == other.runtimeType &&
            name == other.name &&
            age == other.age &&
            countryCode == other.countryCode &&
            favoriteClubId == other.favoriteClubId &&
            favoriteTacticalIdentityId == other.favoriteTacticalIdentityId &&
            portraitId == other.portraitId;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      age,
      countryCode,
      favoriteClubId,
      favoriteTacticalIdentityId,
      portraitId,
    );
  }

  @override
  String toString() {
    return 'FootballDirector('
        'name: $name, '
        'age: $age, '
        'countryCode: $countryCode, '
        'favoriteClubId: $favoriteClubId, '
        'favoriteTacticalIdentityId: $favoriteTacticalIdentityId, '
        'portraitId: $portraitId'
        ')';
  }
}
