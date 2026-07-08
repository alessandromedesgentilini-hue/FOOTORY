enum CoachPrestige {
  regional,
  nacional,
  continental,
  internacional,
  lendario,
}

class CoachStaffMember {
  final String name;
  final String role;
  final String nationalityCode;
  final String imageAsset;

  const CoachStaffMember({
    required this.name,
    required this.role,
    required this.nationalityCode,
    required this.imageAsset,
  });
}

class CoachStaff {
  final String id;
  final String name;
  final String tacticalIdentityId;
  final String shortDescription;

  final CoachStaffMember coach;
  final CoachStaffMember assistant1;
  final CoachStaffMember assistant2;

  final int level;
  final int contractEndYear;
  final CoachPrestige prestige;

  const CoachStaff({
    required this.id,
    required this.name,
    required this.tacticalIdentityId,
    required this.shortDescription,
    required this.coach,
    required this.assistant1,
    required this.assistant2,
    this.level = 1,
    this.contractEndYear = 2027,
    this.prestige = CoachPrestige.regional,
  });

  String get prestigeLabel {
    switch (prestige) {
      case CoachPrestige.regional:
        return 'Regional';
      case CoachPrestige.nacional:
        return 'Nacional';
      case CoachPrestige.continental:
        return 'Continental';
      case CoachPrestige.internacional:
        return 'Internacional';
      case CoachPrestige.lendario:
        return 'Lendário';
    }
  }

  int get prestigeStars {
    switch (prestige) {
      case CoachPrestige.regional:
        return 1;
      case CoachPrestige.nacional:
        return 2;
      case CoachPrestige.continental:
        return 3;
      case CoachPrestige.internacional:
        return 4;
      case CoachPrestige.lendario:
        return 5;
    }
  }

  int get monthlySalary {
    switch (level.clamp(1, 10)) {
      case 1:
        return 180000;
      case 2:
        return 250000;
      case 3:
        return 350000;
      case 4:
        return 500000;
      case 5:
        return 700000;
      case 6:
        return 900000;
      case 7:
        return 1200000;
      case 8:
        return 1500000;
      case 9:
        return 1750000;
      case 10:
        return 2000000;
      default:
        return 180000;
    }
  }

  int get upgradeCost {
    switch ((level + 1).clamp(1, 10)) {
      case 2:
        return 50000;
      case 3:
        return 150000;
      case 4:
        return 350000;
      case 5:
        return 700000;
      case 6:
        return 1500000;
      case 7:
        return 3000000;
      case 8:
        return 7000000;
      case 9:
        return 15000000;
      case 10:
        return 25000000;
      default:
        return 0;
    }
  }

  String get contractLabel => '31/12/$contractEndYear';

  bool get canUpgrade => level < 10;

  CoachStaff copyWith({
    String? id,
    String? name,
    String? tacticalIdentityId,
    String? shortDescription,
    CoachStaffMember? coach,
    CoachStaffMember? assistant1,
    CoachStaffMember? assistant2,
    int? level,
    int? contractEndYear,
    CoachPrestige? prestige,
  }) {
    return CoachStaff(
      id: id ?? this.id,
      name: name ?? this.name,
      tacticalIdentityId: tacticalIdentityId ?? this.tacticalIdentityId,
      shortDescription: shortDescription ?? this.shortDescription,
      coach: coach ?? this.coach,
      assistant1: assistant1 ?? this.assistant1,
      assistant2: assistant2 ?? this.assistant2,
      level: level ?? this.level,
      contractEndYear: contractEndYear ?? this.contractEndYear,
      prestige: prestige ?? this.prestige,
    );
  }
}
