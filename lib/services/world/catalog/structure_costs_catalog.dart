enum ClubStructureType {
  complexo,
  ct,
  base,
  scout,
  financeiro,
  marketing,
  comunicacao,
  medico,
  estadio,
}

class StructureCostsCatalog {
  const StructureCostsCatalog._();

  static const Map<ClubStructureType, Map<int, int>> _costsByLevel = {
    ClubStructureType.complexo: {
      1: 1000000,
      2: 2000000,
      3: 4000000,
      4: 5000000,
      5: 6000000,
      6: 10000000,
      7: 15000000,
      8: 30000000,
      9: 40000000,
      10: 50000000,
    },
    ClubStructureType.ct: {
      1: 1000000,
      2: 2000000,
      3: 3000000,
      4: 4000000,
      5: 6000000,
      6: 10000000,
      7: 15000000,
      8: 25000000,
      9: 40000000,
      10: 100000000,
    },
    ClubStructureType.base: {
      1: 2000000,
      2: 3000000,
      3: 4000000,
      4: 6000000,
      5: 10000000,
      6: 15000000,
      7: 25000000,
      8: 50000000,
      9: 100000000,
      10: 200000000,
    },
    ClubStructureType.scout: {
      1: 1000000,
      2: 2000000,
      3: 4000000,
      4: 5000000,
      5: 7000000,
      6: 15000000,
      7: 20000000,
      8: 30000000,
      9: 45000000,
      10: 100000000,
    },
    ClubStructureType.financeiro: {
      1: 1000000,
      2: 2000000,
      3: 4000000,
      4: 5000000,
      5: 10000000,
      6: 15000000,
      7: 25000000,
      8: 45000000,
      9: 75000000,
      10: 120000000,
    },
    ClubStructureType.marketing: {
      1: 1000000,
      2: 2000000,
      3: 3000000,
      4: 4000000,
      5: 5000000,
      6: 10000000,
      7: 15000000,
      8: 20000000,
      9: 30000000,
      10: 40000000,
    },
    ClubStructureType.comunicacao: {
      1: 1000000,
      2: 2000000,
      3: 3000000,
      4: 4000000,
      5: 5000000,
      6: 8000000,
      7: 10000000,
      8: 15000000,
      9: 20000000,
      10: 25000000,
    },
    ClubStructureType.medico: {
      1: 1000000,
      2: 2000000,
      3: 3000000,
      4: 4000000,
      5: 5000000,
      6: 8000000,
      7: 15000000,
      8: 20000000,
      9: 25000000,
      10: 35000000,
    },
    ClubStructureType.estadio: {
      1: 2000000,
      2: 4000000,
      3: 6000000,
      4: 10000000,
      5: 15000000,
      6: 30000000,
      7: 100000000,
      8: 250000000,
      9: 350000000,
      10: 500000000,
    },
  };

  static const Map<ClubStructureType, String> _labels = {
    ClubStructureType.complexo: 'Complexo Esportivo',
    ClubStructureType.ct: 'CT',
    ClubStructureType.base: 'Base',
    ClubStructureType.scout: 'Scout',
    ClubStructureType.financeiro: 'Departamento Financeiro',
    ClubStructureType.marketing: 'Marketing',
    ClubStructureType.comunicacao: 'Comunicação',
    ClubStructureType.medico: 'Departamento Médico',
    ClubStructureType.estadio: 'Estádio',
  };

  static String labelOf(ClubStructureType type) {
    return _labels[type] ?? type.name;
  }

  static List<ClubStructureType> allTypes() {
    return List.unmodifiable(ClubStructureType.values);
  }

  static Map<int, int> costsOf(ClubStructureType type) {
    return Map.unmodifiable(_costsByLevel[type] ?? const <int, int>{});
  }

  static int getLevelCost(ClubStructureType type, int level) {
    final safeLevel = level.clamp(1, 10);
    return _costsByLevel[type]?[safeLevel] ?? 0;
  }

  /// Custo para ficar no nível atual.
  static int getCurrentLevelCost(ClubStructureType type, int currentLevel) {
    return getLevelCost(type, currentLevel);
  }

  /// Custo para subir do nível atual para o próximo.
  /// Exemplo: se está no 4, retorna o custo do nível 5.
  static int getUpgradeCost(ClubStructureType type, int currentLevel) {
    if (currentLevel >= 10) return 0;
    final nextLevel = (currentLevel + 1).clamp(1, 10);
    return getLevelCost(type, nextLevel);
  }

  static bool canUpgrade(int currentLevel) {
    return currentLevel >= 1 && currentLevel < 10;
  }

  /// Regra oficial do jogo:
  /// manutenção mensal = 1% do custo do nível atual
  static int getMonthlyMaintenance(ClubStructureType type, int currentLevel) {
    final cost = getCurrentLevelCost(type, currentLevel);
    return (cost * 0.01).round();
  }

  static int getTotalMonthlyMaintenance(
    Map<ClubStructureType, int> currentLevels,
  ) {
    var total = 0;
    for (final entry in currentLevels.entries) {
      total += getMonthlyMaintenance(entry.key, entry.value);
    }
    return total;
  }

  static String debugSummary(ClubStructureType type, int currentLevel) {
    final currentCost = getCurrentLevelCost(type, currentLevel);
    final upgradeCost = getUpgradeCost(type, currentLevel);
    final monthly = getMonthlyMaintenance(type, currentLevel);

    return '${labelOf(type)} | nível $currentLevel | '
        'custo atual: $currentCost | '
        'próximo upgrade: $upgradeCost | '
        'manutenção mensal: $monthly';
  }
}
