// lib/services/evolucao/evolucao_service.dart
//
// Evolução (MVP)
// ✅ Janeiro automático (fora daqui)
// ✅ BAÚ manual (custo progressivo)
// ✅ Atualiza Jogador no cache do ClubSquadService

import '../../models/jogador.dart';
import '../club_squad_service.dart';

class EvolucaoService {
  EvolucaoService._();
  static final EvolucaoService I = EvolucaoService._();

  // -----------------------------
  // Custo progressivo
  // -----------------------------
  int custoParaUpar(int valorAtual1a10) {
    final v = valorAtual1a10.clamp(1, 10);
    if (v <= 6) return 1; // 1..6 -> +1 custa 1
    if (v == 7) return 2; // 7->8
    if (v == 8) return 3; // 8->9
    if (v == 9) return 5; // 9->10
    return 9999; // 10 não upa
  }

  // -----------------------------
  // Atualiza atributos do Jogador (safe)
  // -----------------------------
  Jogador withAttrDelta(Jogador j, String key, int delta) {
    final attrs = Map<String, int>.from(_readAtributos(j));
    final cur = (attrs[key] ?? 1).clamp(1, 10);
    final next = (cur + delta).clamp(1, 10);
    attrs[key] = next;

    // tenta copyWith(atributos:)
    try {
      final out = (j as dynamic).copyWith(atributos: attrs);
      if (out is Jogador) return out;
    } catch (_) {}

    // tenta via JSON (bem compatível)
    try {
      final m = Map<String, dynamic>.from((j as dynamic).toJson());
      m['atributos'] = attrs;
      final out = Jogador.fromJson(m);
      return out;
    } catch (_) {}

    // fallback final
    return _rebuildBestEffort(j, attrs);
  }

  Jogador _rebuildBestEffort(
    Jogador j,
    Map<String, int> attrs,
  ) {
    dynamic dj = j as dynamic;

    String safeStr(String Function() fn, String fallback) {
      try {
        final v = fn();
        if (v.trim().isNotEmpty) return v;
      } catch (_) {}
      return fallback;
    }

    int safeInt(int Function() fn, int fallback) {
      try {
        return fn();
      } catch (_) {
        return fallback;
      }
    }

    final id = safeStr(() => dj.id as String, j.id);
    final nome = safeStr(() => dj.nome as String, j.nome);
    final pos = safeStr(() => dj.pos as String, j.pos);
    final posDet = safeStr(() => dj.posDet as String, j.posDet);
    final idade = safeInt(() => dj.idade as int, j.idade);

    final pe = (() {
      try {
        return dj.pe;
      } catch (_) {
        return null;
      }
    })();

    // ✅ FIX: faceAsset pode ser String? no teu model
    final faceAsset = (() {
      try {
        final v = dj.faceAsset;
        if (v is String) return v;
      } catch (_) {}
      try {
        final v = j.faceAsset;
        if (v is String) return v;
      } catch (_) {}
      return '';
    })();

    final salarioMensal =
        safeInt(() => dj.salarioMensal as int, j.salarioMensal);
    final valorMercado = safeInt(() => dj.valorMercado as int, j.valorMercado);
    final anosContrato = safeInt(() => dj.anosContrato as int, j.anosContrato);

    // pilares legacy (se existirem)
    final ofensivo = (() {
      try {
        return dj.ofensivo;
      } catch (_) {
        return null;
      }
    })();
    final defensivo = (() {
      try {
        return dj.defensivo;
      } catch (_) {
        return null;
      }
    })();
    final tecnico = (() {
      try {
        return dj.tecnico;
      } catch (_) {
        return null;
      }
    })();
    final mental = (() {
      try {
        return dj.mental;
      } catch (_) {
        return null;
      }
    })();
    final fisico = (() {
      try {
        return dj.fisico;
      } catch (_) {
        return null;
      }
    })();

    return Jogador(
      id: id,
      nome: nome,
      pos: pos,
      posDet: posDet,
      idade: idade,
      pe: pe,
      atributos: attrs,
      ofensivo: ofensivo,
      defensivo: defensivo,
      tecnico: tecnico,
      mental: mental,
      fisico: fisico,
      faceAsset: faceAsset,
      salarioMensal: salarioMensal,
      valorMercado: valorMercado,
      anosContrato: anosContrato,
    );
  }

  Map<String, int> _readAtributos(Jogador j) {
    try {
      final v = (j as dynamic).atributos;
      if (v is Map<String, int>) return v;
      if (v is Map) {
        return v.map((k, val) => MapEntry(k.toString(), (val as num).toInt()));
      }
    } catch (_) {}
    return const {};
  }

  // -----------------------------
  // Atualiza jogador no cache (PRO/Base)
  // -----------------------------
  bool replaceInSquads({
    required String clubId,
    required Jogador updated,
  }) {
    var changed = false;

    final pro = ClubSquadService.I.getProSquad(clubId);
    final pi = pro.indexWhere((x) => x.id == updated.id);
    if (pi >= 0) {
      pro[pi] = updated;
      changed = true;
    }

    final base = ClubSquadService.I.getBaseSquad(clubId);
    final bi = base.indexWhere((x) => x.id == updated.id);
    if (bi >= 0) {
      base[bi] = updated;
      changed = true;
    }

    return changed;
  }
}
