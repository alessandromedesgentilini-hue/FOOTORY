import 'package:footory26/services/world/catalog/club_structures_catalog.dart';
import 'package:footory26/services/world/catalog/structure_costs_catalog.dart';

class StructureUpgradeResult {
  final bool success;
  final ClubStructures updatedStructures;
  final int financeCost;
  final String? errorCode;

  const StructureUpgradeResult({
    required this.success,
    required this.updatedStructures,
    required this.financeCost,
    this.errorCode,
  });

  factory StructureUpgradeResult.failure({
    required ClubStructures currentStructures,
    required String errorCode,
  }) {
    return StructureUpgradeResult(
      success: false,
      updatedStructures: currentStructures,
      financeCost: 0,
      errorCode: errorCode,
    );
  }
}

class StructureRuntimeService {
  const StructureRuntimeService();

  ClubStructures clampByComplexo(ClubStructures s) {
    final complexo = s.complexo.clamp(1, 10);

    return ClubStructures(
      complexo: complexo,
      ct: s.ct.clamp(1, complexo),
      base: s.base.clamp(1, complexo),
      scout: s.scout.clamp(1, complexo),
      financeiro: s.financeiro.clamp(1, complexo),
      marketing: s.marketing.clamp(1, complexo),
      comunicacao: s.comunicacao.clamp(1, complexo),
      medico: s.medico.clamp(1, complexo),
      estadio: s.estadio.clamp(1, complexo),
    );
  }

  int getStructureLevel(
    ClubStructures structures,
    ClubStructureType type,
  ) {
    switch (type) {
      case ClubStructureType.complexo:
        return structures.complexo;
      case ClubStructureType.ct:
        return structures.ct;
      case ClubStructureType.base:
        return structures.base;
      case ClubStructureType.scout:
        return structures.scout;
      case ClubStructureType.financeiro:
        return structures.financeiro;
      case ClubStructureType.marketing:
        return structures.marketing;
      case ClubStructureType.comunicacao:
        return structures.comunicacao;
      case ClubStructureType.medico:
        return structures.medico;
      case ClubStructureType.estadio:
        return structures.estadio;
    }
  }

  bool canUpgrade(
    ClubStructures structures,
    ClubStructureType type,
  ) {
    final current = getStructureLevel(structures, type);

    if (type == ClubStructureType.complexo) {
      return current < 10;
    }

    return current < structures.complexo && current < 10;
  }

  StructureUpgradeResult tryUpgrade({
    required ClubStructures currentStructures,
    required ClubStructureType type,
    required int currentBalance,
  }) {
    if (!canUpgrade(currentStructures, type)) {
      return StructureUpgradeResult.failure(
        currentStructures: currentStructures,
        errorCode: 'blocked',
      );
    }

    final currentLevel = getStructureLevel(currentStructures, type);
    final rawUpgradeCost =
        StructureCostsCatalog.getUpgradeCost(type, currentLevel);
    final financeCost = toFinanceUnits(rawUpgradeCost);

    if (financeCost > 0 && currentBalance < financeCost) {
      return StructureUpgradeResult.failure(
        currentStructures: currentStructures,
        errorCode: 'insufficient_balance',
      );
    }

    final next = _applyUpgrade(currentStructures, type);
    final clamped = clampByComplexo(next);

    return StructureUpgradeResult(
      success: true,
      updatedStructures: clamped,
      financeCost: financeCost,
    );
  }

  ClubStructures _applyUpgrade(
    ClubStructures current,
    ClubStructureType type,
  ) {
    switch (type) {
      case ClubStructureType.complexo:
        return ClubStructures(
          complexo: (current.complexo + 1).clamp(1, 10),
          ct: current.ct,
          base: current.base,
          scout: current.scout,
          financeiro: current.financeiro,
          marketing: current.marketing,
          comunicacao: current.comunicacao,
          medico: current.medico,
          estadio: current.estadio,
        );

      case ClubStructureType.ct:
        return ClubStructures(
          complexo: current.complexo,
          ct: (current.ct + 1).clamp(1, 10),
          base: current.base,
          scout: current.scout,
          financeiro: current.financeiro,
          marketing: current.marketing,
          comunicacao: current.comunicacao,
          medico: current.medico,
          estadio: current.estadio,
        );

      case ClubStructureType.base:
        return ClubStructures(
          complexo: current.complexo,
          ct: current.ct,
          base: (current.base + 1).clamp(1, 10),
          scout: current.scout,
          financeiro: current.financeiro,
          marketing: current.marketing,
          comunicacao: current.comunicacao,
          medico: current.medico,
          estadio: current.estadio,
        );

      case ClubStructureType.scout:
        return ClubStructures(
          complexo: current.complexo,
          ct: current.ct,
          base: current.base,
          scout: (current.scout + 1).clamp(1, 10),
          financeiro: current.financeiro,
          marketing: current.marketing,
          comunicacao: current.comunicacao,
          medico: current.medico,
          estadio: current.estadio,
        );

      case ClubStructureType.financeiro:
        return ClubStructures(
          complexo: current.complexo,
          ct: current.ct,
          base: current.base,
          scout: current.scout,
          financeiro: (current.financeiro + 1).clamp(1, 10),
          marketing: current.marketing,
          comunicacao: current.comunicacao,
          medico: current.medico,
          estadio: current.estadio,
        );

      case ClubStructureType.marketing:
        return ClubStructures(
          complexo: current.complexo,
          ct: current.ct,
          base: current.base,
          scout: current.scout,
          financeiro: current.financeiro,
          marketing: (current.marketing + 1).clamp(1, 10),
          comunicacao: current.comunicacao,
          medico: current.medico,
          estadio: current.estadio,
        );

      case ClubStructureType.comunicacao:
        return ClubStructures(
          complexo: current.complexo,
          ct: current.ct,
          base: current.base,
          scout: current.scout,
          financeiro: current.financeiro,
          marketing: current.marketing,
          comunicacao: (current.comunicacao + 1).clamp(1, 10),
          medico: current.medico,
          estadio: current.estadio,
        );

      case ClubStructureType.medico:
        return ClubStructures(
          complexo: current.complexo,
          ct: current.ct,
          base: current.base,
          scout: current.scout,
          financeiro: current.financeiro,
          marketing: current.marketing,
          comunicacao: current.comunicacao,
          medico: (current.medico + 1).clamp(1, 10),
          estadio: current.estadio,
        );

      case ClubStructureType.estadio:
        return ClubStructures(
          complexo: current.complexo,
          ct: current.ct,
          base: current.base,
          scout: current.scout,
          financeiro: current.financeiro,
          marketing: current.marketing,
          comunicacao: current.comunicacao,
          medico: current.medico,
          estadio: (current.estadio + 1).clamp(1, 10),
        );
    }
  }

  Map<ClubStructureType, int> structureLevelsOfClub({
    required String clubId,
    required String userClubId,
    required ClubStructures userStructures,
    required ClubStructures Function(String clubId) catalogResolver,
  }) {
    final structures =
        clubId == userClubId ? userStructures : catalogResolver(clubId);

    return <ClubStructureType, int>{
      ClubStructureType.complexo: structures.complexo,
      ClubStructureType.ct: structures.ct,
      ClubStructureType.base: structures.base,
      ClubStructureType.scout: structures.scout,
      ClubStructureType.financeiro: structures.financeiro,
      ClubStructureType.marketing: structures.marketing,
      ClubStructureType.comunicacao: structures.comunicacao,
      ClubStructureType.medico: structures.medico,
      ClubStructureType.estadio: structures.estadio,
    };
  }

  int structureMaintenanceOfClub({
    required String clubId,
    required String userClubId,
    required ClubStructures userStructures,
    required ClubStructures Function(String clubId) catalogResolver,
  }) {
    if (clubId.trim().isEmpty) return 0;

    final levels = structureLevelsOfClub(
      clubId: clubId,
      userClubId: userClubId,
      userStructures: userStructures,
      catalogResolver: catalogResolver,
    );

    final rawTotal = StructureCostsCatalog.getTotalMonthlyMaintenance(levels);
    return toFinanceUnits(rawTotal);
  }

  int toFinanceUnits(int rawValue) {
    return rawValue;
  }
}
