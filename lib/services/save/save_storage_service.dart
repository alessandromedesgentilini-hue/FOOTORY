import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:footory26/models/save_slot_data.dart';
import 'package:footory26/services/finance/club_finance_profile_catalog.dart';
import 'package:footory26/services/finance/finance_rules_service.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
import 'package:footory26/services/world/catalog/club_structures_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

class SaveStorageService {
  static const String _slot1Key = 'save_slot_1';
  static const String _slot2Key = 'save_slot_2';
  static const String _slot3Key = 'save_slot_3';
  static const String _lastActiveSlotKey = 'last_active_save_slot';

  static const List<String> slotIds = <String>[
    _slot1Key,
    _slot2Key,
    _slot3Key,
  ];

  Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  String _slotStateKey(String slotId) => '${slotId}_state';

  Future<List<SaveSlotData?>> loadAllSlots() async {
    final prefs = await _prefs();

    return slotIds.map((slotId) {
      final raw = prefs.getString(slotId);
      if (raw == null || raw.isEmpty) return null;
      return SaveSlotData.fromJson(raw);
    }).toList();
  }

  Future<SaveSlotData?> loadSlot(String slotId) async {
    final prefs = await _prefs();
    final raw = prefs.getString(slotId);

    if (raw == null || raw.isEmpty) return null;

    return SaveSlotData.fromJson(raw);
  }

  Future<Map<String, dynamic>?> loadSlotState(String slotId) async {
    final prefs = await _prefs();
    final raw = prefs.getString(_slotStateKey(slotId));

    if (raw == null || raw.isEmpty) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSlot(SaveSlotData data) async {
    final prefs = await _prefs();

    await prefs.setString(data.slotId, data.toJson());
    await prefs.setString(_lastActiveSlotKey, data.slotId);
  }

  Future<void> saveSlotState({
    required String slotId,
    required Map<String, dynamic> payload,
  }) async {
    final prefs = await _prefs();

    await prefs.setString(_slotStateKey(slotId), jsonEncode(payload));
    await prefs.setString(_lastActiveSlotKey, slotId);
  }

  Future<void> deleteSlot(String slotId) async {
    final prefs = await _prefs();

    await prefs.remove(slotId);
    await prefs.remove(_slotStateKey(slotId));

    final last = prefs.getString(_lastActiveSlotKey);

    if (last == slotId) {
      await prefs.remove(_lastActiveSlotKey);
    }
  }

  Future<String?> loadLastActiveSlotId() async {
    final prefs = await _prefs();
    return prefs.getString(_lastActiveSlotKey);
  }

  Future<void> setLastActiveSlotId(String slotId) async {
    final prefs = await _prefs();
    await prefs.setString(_lastActiveSlotKey, slotId);
  }

  Future<void> saveFromGameState({
    required String slotId,
    required GameState gs,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    final staff = gs.selectedCoachStaffOrFallback;

    final data = SaveSlotData(
      slotId: slotId,
      clubId: gs.userClubId,
      clubName: gs.userClubName,
      divisionId: gs.divisionId,
      seed: gs.seed,
      coachStaffId: staff.id,
      coachLevel: staff.level,
      contractEndYear: staff.contractEndYear,
      coachPrestige: staff.prestige.name,
      seasonYear: gs.seasonYear,
      roundIndex: gs.roundIndex,
      savedAtIso: nowIso,
    );

    final statePayload = gs.exportStateForSave();
    statePayload['slotId'] = slotId;
    statePayload['savedAtIso'] = nowIso;

    await saveSlot(data);
    await saveSlotState(
      slotId: slotId,
      payload: statePayload,
    );
  }

  Future<void> seedMissingStateFromCatalog({
    required String slotId,
    required SaveSlotData slot,
  }) async {
    final existing = await loadSlotState(slotId);
    if (existing != null) return;

    final structures = ClubStructuresCatalog.byId(slot.clubId);
    final division = _parseDivision(slot.divisionId);
    final profile = ClubFinanceProfileCatalog.byClubId(
      clubId: slot.clubId,
      division: division,
    );

    final health = _evaluateHealth(profile.debt);

    final fallback = <String, dynamic>{
      'saveVersion': 1,
      'slotId': slot.slotId,
      'savedAtIso': slot.savedAtIso,
      'clubId': slot.clubId,
      'clubName': slot.clubName,
      'divisionId': slot.divisionId,
      'seed': slot.seed,
      'seasonYear': slot.seasonYear,
      'roundIndex': slot.roundIndex,
      'dateStr': '',
      'seasonEnded': false,
      'coachStaffId': slot.coachStaffId,
      'userCoachLevel': slot.coachLevel,
      'coachStaff': <String, dynamic>{
        'id': slot.coachStaffId,
        'level': slot.coachLevel,
        'contractEndYear': slot.contractEndYear,
        'prestige': slot.coachPrestige,
      },
      'finance': <String, dynamic>{
        'caixa': profile.caixa,
        'operacional': profile.operacional,
        'balance': profile.caixa,
        'operationalCash': profile.operacional,
        'debt': profile.debt,
        'monthlyWage': 0,
        'health': _financeHealthToString(health),
        'structureMaintenance': 0,
        'totalMonthlyFixedCost': 0,
        'repassPercentage': _repassPercentage(health),
      },
      'structures': <String, dynamic>{
        'complexo': structures.complexo,
        'ct': structures.ct,
        'base': structures.base,
        'scout': structures.scout,
        'financeiro': structures.financeiro,
        'marketing': structures.marketing,
        'comunicacao': structures.comunicacao,
        'medico': structures.medico,
        'estadio': structures.estadio,
        'structuralPower': structures.structuralPower,
      },
      'userClubSummary': <String, dynamic>{
        'caixa': profile.caixa,
        'operacional': profile.operacional,
        'balance': profile.caixa,
        'debt': profile.debt,
        'monthlyWage': 0,
      },
    };

    await saveSlotState(
      slotId: slotId,
      payload: fallback,
    );
  }

  DivisionId _parseDivision(String raw) {
    switch (raw.trim().toUpperCase()) {
      case 'BR-A':
      case 'BRA':
        return DivisionId.brA;
      case 'BR-B':
      case 'BRB':
        return DivisionId.brB;
      case 'BR-C':
      case 'BRC':
        return DivisionId.brC;
      case 'BR-D':
      case 'BRD':
        return DivisionId.brD;
      default:
        return DivisionId.brD;
    }
  }

  FinanceHealth _evaluateHealth(int debt) {
    if (debt <= 100000000) return FinanceHealth.muitoSaudavel;
    if (debt <= 300000000) return FinanceHealth.saudavel;
    if (debt <= 700000000) return FinanceHealth.estavel;
    if (debt <= 1200000000) return FinanceHealth.pressionado;
    if (debt <= 1500000000) return FinanceHealth.critico;
    return FinanceHealth.colapsoFinanceiro;
  }

  double _repassPercentage(FinanceHealth health) {
    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return 0.90;
      case FinanceHealth.saudavel:
        return 0.80;
      case FinanceHealth.estavel:
        return 0.65;
      case FinanceHealth.pressionado:
        return 0.50;
      case FinanceHealth.critico:
        return 0.35;
      case FinanceHealth.colapsoFinanceiro:
        return 0.20;
    }
  }

  String _financeHealthToString(FinanceHealth health) {
    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return 'muitoSaudavel';
      case FinanceHealth.saudavel:
        return 'saudavel';
      case FinanceHealth.estavel:
        return 'estavel';
      case FinanceHealth.pressionado:
        return 'pressionado';
      case FinanceHealth.critico:
        return 'critico';
      case FinanceHealth.colapsoFinanceiro:
        return 'colapsoFinanceiro';
    }
  }
}
