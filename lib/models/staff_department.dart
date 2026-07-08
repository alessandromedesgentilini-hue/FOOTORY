enum DepartmentType {
  sportsComplex,
  trainingCenter,
  academy,
  scouting,
  finance,
  marketing,
  communication,
  medical,
  stadium,
}

enum DepartmentMoodLevel {
  veryBad,
  bad,
  stable,
  good,
  excellent,
}

enum DepartmentMessageType {
  info,
  alert,
  goodNews,
  report,
  note,
  rareEvent,
  structureUpgrade,
  preMatch,
  postMatch,
  achievement,
}

class StaffDepartment {
  final String name;
  final String role;
  final String faceAsset;
  final DepartmentType departmentType;

  const StaffDepartment({
    required this.name,
    required this.role,
    required this.faceAsset,
    required this.departmentType,
  });
}

class DepartmentMessage {
  final DepartmentMessageType type;
  final DepartmentType departmentType;
  final String title;
  final String authorName;
  final String authorRole;
  final String faceAsset;
  final String text;

  // Campos leves para melhorar UI/organização
  final String? subtitle;
  final String? tag;
  final String? roundLabel;

  const DepartmentMessage({
    required this.type,
    required this.departmentType,
    required this.title,
    required this.authorName,
    required this.authorRole,
    required this.faceAsset,
    required this.text,
    this.subtitle,
    this.tag,
    this.roundLabel,
  });

  String get displayTitle {
    final value = title.trim();
    if (value.isNotEmpty) return value;
    return 'Atualização de Departamento';
  }

  String get displayAuthorName {
    final value = authorName.trim();
    if (value.isNotEmpty) return value;
    return departmentType.label;
  }

  String get displayAuthorRole {
    final value = authorRole.trim();
    if (value.isNotEmpty) return value;
    return 'Equipe interna';
  }

  String get displaySubtitle {
    final custom = subtitle?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }

    final round = roundLabel?.trim();
    if (round != null && round.isNotEmpty) {
      return '${departmentType.emoji} ${departmentType.label} • $round';
    }

    return '${departmentType.emoji} ${departmentType.label}';
  }

  String get displayMetaLine {
    final name = displayAuthorName;
    final role = displayAuthorRole;

    if (name.isEmpty && role.isEmpty) {
      return departmentType.label;
    }

    if (role.isEmpty) return name;
    if (name.isEmpty) return role;

    return '$name • $role';
  }

  String get displayTag {
    final custom = tag?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    return type.shortLabel;
  }

  String get preview {
    final value = text.trim();
    if (value.isEmpty) return 'Sem conteúdo.';
    if (value.length <= 110) return value;
    return '${value.substring(0, 107).trimRight()}...';
  }

  bool get isPriority {
    switch (type) {
      case DepartmentMessageType.alert:
      case DepartmentMessageType.rareEvent:
      case DepartmentMessageType.achievement:
      case DepartmentMessageType.structureUpgrade:
        return true;
      case DepartmentMessageType.info:
      case DepartmentMessageType.goodNews:
      case DepartmentMessageType.report:
      case DepartmentMessageType.note:
      case DepartmentMessageType.preMatch:
      case DepartmentMessageType.postMatch:
        return false;
    }
  }

  bool get isPositive {
    switch (type) {
      case DepartmentMessageType.goodNews:
      case DepartmentMessageType.achievement:
      case DepartmentMessageType.rareEvent:
      case DepartmentMessageType.structureUpgrade:
        return true;
      case DepartmentMessageType.info:
      case DepartmentMessageType.alert:
      case DepartmentMessageType.report:
      case DepartmentMessageType.note:
      case DepartmentMessageType.preMatch:
      case DepartmentMessageType.postMatch:
        return false;
    }
  }

  bool get isNegative {
    switch (type) {
      case DepartmentMessageType.alert:
        return true;
      case DepartmentMessageType.info:
      case DepartmentMessageType.goodNews:
      case DepartmentMessageType.report:
      case DepartmentMessageType.note:
      case DepartmentMessageType.rareEvent:
      case DepartmentMessageType.structureUpgrade:
      case DepartmentMessageType.preMatch:
      case DepartmentMessageType.postMatch:
      case DepartmentMessageType.achievement:
        return false;
    }
  }
}

extension DepartmentTypeExtension on DepartmentType {
  String get key {
    switch (this) {
      case DepartmentType.sportsComplex:
        return 'sportsComplex';
      case DepartmentType.trainingCenter:
        return 'trainingCenter';
      case DepartmentType.academy:
        return 'academy';
      case DepartmentType.scouting:
        return 'scouting';
      case DepartmentType.finance:
        return 'finance';
      case DepartmentType.marketing:
        return 'marketing';
      case DepartmentType.communication:
        return 'communication';
      case DepartmentType.medical:
        return 'medical';
      case DepartmentType.stadium:
        return 'stadium';
    }
  }

  String get label {
    switch (this) {
      case DepartmentType.sportsComplex:
        return 'Complexo Esportivo';
      case DepartmentType.trainingCenter:
        return 'CT';
      case DepartmentType.academy:
        return 'Base';
      case DepartmentType.scouting:
        return 'Scout';
      case DepartmentType.finance:
        return 'Financeiro';
      case DepartmentType.marketing:
        return 'Marketing';
      case DepartmentType.communication:
        return 'Comunicação';
      case DepartmentType.medical:
        return 'Médico';
      case DepartmentType.stadium:
        return 'Estádio';
    }
  }

  String get emoji {
    switch (this) {
      case DepartmentType.sportsComplex:
        return '🏗️';
      case DepartmentType.trainingCenter:
        return '🏋️';
      case DepartmentType.academy:
        return '🧒';
      case DepartmentType.scouting:
        return '🔎';
      case DepartmentType.finance:
        return '💰';
      case DepartmentType.marketing:
        return '📣';
      case DepartmentType.communication:
        return '🎙️';
      case DepartmentType.medical:
        return '🏥';
      case DepartmentType.stadium:
        return '🏟️';
    }
  }
}

extension DepartmentMessageTypeExtension on DepartmentMessageType {
  String get label {
    switch (this) {
      case DepartmentMessageType.info:
        return 'Informação';
      case DepartmentMessageType.alert:
        return 'Alerta';
      case DepartmentMessageType.goodNews:
        return 'Boa notícia';
      case DepartmentMessageType.report:
        return 'Relatório';
      case DepartmentMessageType.note:
        return 'Observação';
      case DepartmentMessageType.rareEvent:
        return 'Destaque';
      case DepartmentMessageType.structureUpgrade:
        return 'Evolução de estrutura';
      case DepartmentMessageType.preMatch:
        return 'Pré-jogo';
      case DepartmentMessageType.postMatch:
        return 'Pós-jogo';
      case DepartmentMessageType.achievement:
        return 'Conquista';
    }
  }

  String get shortLabel {
    switch (this) {
      case DepartmentMessageType.info:
        return 'Info';
      case DepartmentMessageType.alert:
        return 'Alerta';
      case DepartmentMessageType.goodNews:
        return 'Boa notícia';
      case DepartmentMessageType.report:
        return 'Relatório';
      case DepartmentMessageType.note:
        return 'Observação';
      case DepartmentMessageType.rareEvent:
        return 'Destaque';
      case DepartmentMessageType.structureUpgrade:
        return 'Estrutura';
      case DepartmentMessageType.preMatch:
        return 'Pré-jogo';
      case DepartmentMessageType.postMatch:
        return 'Pós-jogo';
      case DepartmentMessageType.achievement:
        return 'Conquista';
    }
  }
}
