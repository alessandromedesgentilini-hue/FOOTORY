// lib/services/career/career_state.dart
//
// Estado/persistência da carreira do usuário.
// - Chaveia por slug do clube + Estilo selecionado.
// - Robusto a múltiplos loads (idempotente) e a valores antigos de estilo.
// - API mínima compatível: load(), startNew(), clear(), getters.
//
// Observações:
// • Salva preferências via SharedPreferences (assíncrono).
// • Tenta entender estilo salvo em formatos antigos (name/slug/label).
// • Não depende de listeners; se precisar, você pode observar via polling
//   ou adaptar para ChangeNotifier no futuro sem quebrar a API pública.

import 'package:shared_preferences/shared_preferences.dart';
import '../../models/estilos.dart';

class CareerState {
  CareerState._();
  static final CareerState I = CareerState._();

  // ===== Chaves de persistência =====
  static const String _kClub = 'career.club';
  static const String _kEstilo = 'career.estilo';

  String? _clubSlug;
  Estilo? _estilo;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  String? get clubSlug => _clubSlug;
  Estilo? get estilo => _estilo;

  /// Atalho útil para checar se está tudo configurado.
  bool get isConfigured => _clubSlug != null && _estilo != null;

  /// Carrega do SharedPreferences. Idempotente por padrão.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;

    try {
      final sp = await SharedPreferences.getInstance();
      _clubSlug = sp.getString(_kClub);

      final raw = sp.getString(_kEstilo);
      _estilo = _parseEstilo(raw) ?? Estilo.transicao;

      _loaded = true;
    } catch (_) {
      // Em caso de falha, mantém estado parcial (não marca como loaded)
      // para permitir nova tentativa em chamada futura.
      _loaded = false;
    }
  }

  /// Inicia nova carreira e persiste imediatamente.
  Future<void> startNew(String clubSlug, Estilo estilo) async {
    _clubSlug = clubSlug;
    _estilo = estilo;

    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kClub, clubSlug);
      await sp.setString(_kEstilo, estilo.name);
      _loaded = true;
    } catch (_) {
      // Se falhar a persistência, mantemos em memória.
    }
  }

  /// Atualiza somente o clube (mantém estilo atual).
  Future<void> setClub(String clubSlug) async {
    _clubSlug = clubSlug;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kClub, clubSlug);
      _loaded = true;
    } catch (_) {}
  }

  /// Atualiza somente o estilo (mantém clube atual).
  Future<void> setEstilo(Estilo estilo) async {
    _estilo = estilo;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kEstilo, estilo.name);
      _loaded = true;
    } catch (_) {}
  }

  /// Limpa a carreira atual do dispositivo.
  Future<void> clear() async {
    _clubSlug = null;
    _estilo = null;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kClub);
      await sp.remove(_kEstilo);
    } catch (_) {}
    // Mantém _loaded no estado atual; um próximo load(force:true) repopula.
  }

  // ===== Internals =====

  /// Aceita estilos salvos por name/slug/label (migração suave).
  Estilo? _parseEstilo(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    // 1) Tentativa direta por enum.name atual
    for (final e in Estilo.values) {
      if (e.name == raw) return e;
    }

    // 2) Tentativa por slug conhecido
    for (final e in Estilo.values) {
      if (e.slug == raw) return e;
    }

    // 3) Tentativa por normalização (labels/sinônimos)
    try {
      // EstiloX.fromString(...) é estático na extensão definida em estilos.dart
      return EstiloX.fromString(raw, fallback: Estilo.transicao);
    } catch (_) {
      return null;
    }
  }
}
