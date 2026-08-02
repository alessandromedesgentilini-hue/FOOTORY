enum PermanentStaffRole {
  assistantCoach,
  performanceAnalyst,
  fitnessCoach,
  goalkeeperCoach,
}

extension PermanentStaffRoleX on PermanentStaffRole {
  String get label {
    switch (this) {
      case PermanentStaffRole.assistantCoach:
        return 'Auxiliar Técnico';

      case PermanentStaffRole.performanceAnalyst:
        return 'Analista de Desempenho';

      case PermanentStaffRole.fitnessCoach:
        return 'Preparadora Física';

      case PermanentStaffRole.goalkeeperCoach:
        return 'Treinador de Goleiros';
    }
  }
}

class PermanentStaffMember {
  final String id;
  final String name;
  final PermanentStaffRole role;
  final String portraitAsset;

  /// História e trajetória profissional.
  final String biography;

  /// Explica qual é a função desse profissional dentro do clube.
  final String jobDescription;

  const PermanentStaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.portraitAsset,
    required this.biography,
    required this.jobDescription,
  });

  String get roleLabel => role.label;

  bool get hasRequiredData {
    return id.trim().isNotEmpty &&
        name.trim().isNotEmpty &&
        portraitAsset.trim().isNotEmpty &&
        biography.trim().isNotEmpty &&
        jobDescription.trim().isNotEmpty;
  }

  PermanentStaffMember copyWith({
    String? id,
    String? name,
    PermanentStaffRole? role,
    String? portraitAsset,
    String? biography,
    String? jobDescription,
  }) {
    return PermanentStaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      portraitAsset: portraitAsset ?? this.portraitAsset,
      biography: biography ?? this.biography,
      jobDescription: jobDescription ?? this.jobDescription,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PermanentStaffMember &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            role == other.role &&
            portraitAsset == other.portraitAsset &&
            biography == other.biography &&
            jobDescription == other.jobDescription;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      role,
      portraitAsset,
      biography,
      jobDescription,
    );
  }

  @override
  String toString() {
    return 'PermanentStaffMember('
        'id: $id, '
        'name: $name, '
        'role: ${role.name}, '
        'portraitAsset: $portraitAsset'
        ')';
  }
}
