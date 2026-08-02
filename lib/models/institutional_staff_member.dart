enum InstitutionalStaffRole {
  president,
  chiefScout,
}

extension InstitutionalStaffRoleX on InstitutionalStaffRole {
  String get label {
    switch (this) {
      case InstitutionalStaffRole.president:
        return 'Presidente do Clube';

      case InstitutionalStaffRole.chiefScout:
        return 'Chefe de Recrutamento';
    }
  }
}

class InstitutionalStaffMember {
  final String id;
  final String name;
  final InstitutionalStaffRole role;
  final String portraitAsset;
  final String biography;
  final String jobDescription;

  const InstitutionalStaffMember({
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

  InstitutionalStaffMember copyWith({
    String? id,
    String? name,
    InstitutionalStaffRole? role,
    String? portraitAsset,
    String? biography,
    String? jobDescription,
  }) {
    return InstitutionalStaffMember(
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
        other is InstitutionalStaffMember &&
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
    return 'InstitutionalStaffMember('
        'id: $id, '
        'name: $name, '
        'role: ${role.name}, '
        'portraitAsset: $portraitAsset'
        ')';
  }
}
