import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:footory26/models/save_slot_data.dart';
import 'package:footory26/services/finance/club_finance_profile_catalog.dart';
import 'package:footory26/services/finance/finance_rules_service.dart';
import 'package:footory26/services/world/catalog/club_structures_catalog.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
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

  Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  String _slotStateKey(String slotId) {
    return '${slotId}_state';
  }

  bool isValidSlotId(String slotId) {
    return slotIds.contains(slotId.trim());
  }

  Future<List<SaveSlotData?>> loadAllSlots() async {
    final prefs = await _prefs();
    final slots = <SaveSlotData?>[];

    for (final slotId in slotIds) {
      final raw = prefs.getString(slotId);

      if (raw == null || raw.trim().isEmpty) {
        slots.add(null);
        continue;
      }

      try {
        final slot = SaveSlotData.fromJson(raw);

        slots.add(
          slot.slotId.trim().isEmpty ? slot.copyWith(slotId: slotId) : slot,
        );
      } catch (error, stackTrace) {
        debugPrint(
          'Erro ao carregar resumo do slot $slotId: $error',
        );
        debugPrint('$stackTrace');

        slots.add(null);
      }
    }

    return slots;
  }

  Future<SaveSlotData?> loadSlot(String slotId) async {
    final normalizedSlotId = _requireValidSlotId(slotId);
    final prefs = await _prefs();

    final raw = prefs.getString(normalizedSlotId);

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final slot = SaveSlotData.fromJson(raw);

      if (slot.slotId.trim().isEmpty) {
        return slot.copyWith(
          slotId: normalizedSlotId,
        );
      }

      return slot;
    } catch (error, stackTrace) {
      debugPrint(
        'Erro ao carregar resumo do slot '
        '$normalizedSlotId: $error',
      );
      debugPrint('$stackTrace');

      return null;
    }
  }

  Future<Map<String, dynamic>?> loadSlotState(
    String slotId,
  ) async {
    final normalizedSlotId = _requireValidSlotId(slotId);
    final prefs = await _prefs();

    final raw = prefs.getString(
      _slotStateKey(normalizedSlotId),
    );

    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        return null;
      }

      return _toStringDynamicMap(decoded);
    } catch (error, stackTrace) {
      debugPrint(
        'Erro ao carregar estado completo do slot '
        '$normalizedSlotId: $error',
      );
      debugPrint('$stackTrace');

      return null;
    }
  }

  Future<void> saveSlot(SaveSlotData data) async {
    final normalizedSlotId = _requireValidSlotId(
      data.slotId,
    );

    final prefs = await _prefs();

    final normalizedData = data.slotId == normalizedSlotId
        ? data
        : data.copyWith(slotId: normalizedSlotId);

    final saved = await prefs.setString(
      normalizedSlotId,
      normalizedData.toJson(),
    );

    if (!saved) {
      throw StateError(
        'Não foi possível salvar o resumo do slot '
        '$normalizedSlotId.',
      );
    }

    await _setLastActiveSlotIdWithPrefs(
      prefs: prefs,
      slotId: normalizedSlotId,
    );
  }

  Future<void> saveSlotState({
    required String slotId,
    required Map<String, dynamic> payload,
  }) async {
    final normalizedSlotId = _requireValidSlotId(slotId);
    final prefs = await _prefs();

    final normalizedPayload = <String, dynamic>{
      ...payload,
      'slotId': normalizedSlotId,
    };

    final saved = await prefs.setString(
      _slotStateKey(normalizedSlotId),
      jsonEncode(normalizedPayload),
    );

    if (!saved) {
      throw StateError(
        'Não foi possível salvar o estado completo do slot '
        '$normalizedSlotId.',
      );
    }

    await _setLastActiveSlotIdWithPrefs(
      prefs: prefs,
      slotId: normalizedSlotId,
    );
  }

  Future<void> deleteSlot(String slotId) async {
    final normalizedSlotId = _requireValidSlotId(slotId);
    final prefs = await _prefs();

    await prefs.remove(normalizedSlotId);
    await prefs.remove(
      _slotStateKey(normalizedSlotId),
    );

    final lastActiveSlotId = prefs.getString(
      _lastActiveSlotKey,
    );

    if (lastActiveSlotId == normalizedSlotId) {
      await prefs.remove(_lastActiveSlotKey);
    }
  }

  Future<String?> loadLastActiveSlotId() async {
    final prefs = await _prefs();

    final savedSlotId = prefs.getString(_lastActiveSlotKey)?.trim();

    if (savedSlotId == null ||
        savedSlotId.isEmpty ||
        !isValidSlotId(savedSlotId)) {
      return null;
    }

    return savedSlotId;
  }

  Future<void> setLastActiveSlotId(String slotId) async {
    final normalizedSlotId = _requireValidSlotId(slotId);
    final prefs = await _prefs();

    await _setLastActiveSlotIdWithPrefs(
      prefs: prefs,
      slotId: normalizedSlotId,
    );
  }

  Future<void> saveFromGameState({
    required String slotId,
    required GameState gs,
  }) async {
    final normalizedSlotId = _requireValidSlotId(slotId);

    if (!gs.isInitialized) {
      throw StateError(
        'Não é possível salvar uma carreira não inicializada.',
      );
    }

    if (gs.userClubId.trim().isEmpty || gs.userClubName.trim().isEmpty) {
      throw StateError(
        'Não é possível salvar uma carreira sem clube.',
      );
    }

    if (!gs.hasSelectedCoachStaff) {
      throw StateError(
        'Não é possível salvar uma carreira sem comissão técnica.',
      );
    }

    final nowIso = DateTime.now().toIso8601String();

    final staff = gs.selectedCoachStaffOrFallback.copyWith(
      level: gs.userCoachLevel.clamp(1, 10),
    );

    final director = gs.footballDirector;

    final slotData = SaveSlotData(
      slotId: normalizedSlotId,
      clubId: gs.userClubId.trim(),
      clubName: gs.userClubName.trim(),
      divisionId: gs.divisionId.trim().toUpperCase(),
      seed: gs.seed,
      coachStaffId: staff.id,
      coachLevel: gs.userCoachLevel.clamp(1, 10),
      contractEndYear: staff.contractEndYear,
      coachPrestige: staff.prestige.name,
      directorName: director?.name.trim(),
      directorPortraitId: director?.portraitId.trim(),
      seasonYear: gs.seasonYear,
      roundIndex: gs.roundIndex,
      savedAtIso: nowIso,
    );

    final statePayload = gs.exportStateForSave();

    statePayload['slotId'] = normalizedSlotId;
    statePayload['savedAtIso'] = nowIso;

    final prefs = await _prefs();

    final summarySaved = await prefs.setString(
      normalizedSlotId,
      slotData.toJson(),
    );

    if (!summarySaved) {
      throw StateError(
        'Não foi possível salvar o resumo do slot '
        '$normalizedSlotId.',
      );
    }

    final stateSaved = await prefs.setString(
      _slotStateKey(normalizedSlotId),
      jsonEncode(statePayload),
    );

    if (!stateSaved) {
      throw StateError(
        'Não foi possível salvar o estado completo do slot '
        '$normalizedSlotId.',
      );
    }

    await _setLastActiveSlotIdWithPrefs(
      prefs: prefs,
      slotId: normalizedSlotId,
    );
  }

  Future<void> seedMissingStateFromCatalog({
    required String slotId,
    required SaveSlotData slot,
  }) async {
    final normalizedSlotId = _requireValidSlotId(slotId);

    final existingState = await loadSlotState(
      normalizedSlotId,
    );

    if (existingState != null) {
      return;
    }

    final structures = ClubStructuresCatalog.byId(
      slot.clubId,
    );

    final division = _parseDivision(
      slot.divisionId,
    );

    final profile = ClubFinanceProfileCatalog.byClubId(
      clubId: slot.clubId,
      division: division,
    );

    final health = _evaluateHealth(profile.debt);

    final fallbackState = <String, dynamic>{
      'saveVersion': 1,
      'slotId': normalizedSlotId,
      'savedAtIso': slot.savedAtIso,
      'clubId': slot.clubId,
      'clubName': slot.clubName,
      'divisionId': slot.divisionId,
      'seed': slot.seed,
      'seasonYear': slot.seasonYear,
      'roundIndex': slot.roundIndex,
      'dateStr': '',
      'seasonEnded': false,

      // Não criamos um Diretor incompleto usando somente o resumo.
      // Saves antigos serão encaminhados à criação do Diretor.
      'footballDirector': null,

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
      slotId: normalizedSlotId,
      payload: fallbackState,
    );
  }

  String _requireValidSlotId(String slotId) {
    final normalizedSlotId = slotId.trim();

    if (!isValidSlotId(normalizedSlotId)) {
      throw ArgumentError.value(
        slotId,
        'slotId',
        'O slot informado não é válido.',
      );
    }

    return normalizedSlotId;
  }

  Future<void> _setLastActiveSlotIdWithPrefs({
    required SharedPreferences prefs,
    required String slotId,
  }) async {
    final saved = await prefs.setString(
      _lastActiveSlotKey,
      slotId,
    );

    if (!saved) {
      throw StateError(
        'Não foi possível registrar o slot ativo.',
      );
    }
  }

  Map<String, dynamic> _toStringDynamicMap(Map raw) {
    try {
      return raw.cast<String, dynamic>();
    } catch (_) {
      final converted = <String, dynamic>{};

      for (final entry in raw.entries) {
        converted[entry.key.toString()] = entry.value;
      }

      return converted;
    }
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
        debugPrint(
          'Divisão inválida no save: "$raw". '
          'Utilizando Série D como compatibilidade.',
        );

        return DivisionId.brD;
    }
  }

  FinanceHealth _evaluateHealth(int debt) {
    if (debt <= 100000000) {
      return FinanceHealth.muitoSaudavel;
    }

    if (debt <= 300000000) {
      return FinanceHealth.saudavel;
    }

    if (debt <= 700000000) {
      return FinanceHealth.estavel;
    }

    if (debt <= 1200000000) {
      return FinanceHealth.pressionado;
    }

    if (debt <= 1500000000) {
      return FinanceHealth.critico;
    }

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

  String _financeHealthToString(
    FinanceHealth health,
  ) {
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
