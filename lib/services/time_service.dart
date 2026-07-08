// lib/services/time_service.dart
//
// Serviço central de gerenciamento de clubes (TimeModel).
// - Fonte única dos times carregados
// - CRUD de time e manipulação de elenco
// - Consultas (por id/nome/estilo) e utilidades (estrangeiros, OVR médio)
// - Seed/import/export simples
// - Singleton: TimeService.I
//
// ✅ Caminho B (atributos 1..10):
// - OVR canônico do jogador vem de:
//    • j.ovrCheio (10..100)  -> soma dos 10 atributos da função
//    • OVR médio 1..10 = j.ovrCheio / 10.0
//
// Obs: a maioria do projeto já usa `ovrCheio` e `estrelas` no Jogador.
// Aqui a gente NÃO depende de `ovrMedia10` existir no model, pra evitar erro.

import 'dart:collection';

import '../models/time_model.dart';
import '../models/jogador.dart';
import '../models/estilos.dart';

class TimeService {
  TimeService._();
  static final TimeService I = TimeService._();

  /// Mapa (id -> TimeModel) como fonte única de clubes.
  final Map<String, TimeModel> _byId = <String, TimeModel>{};

  /// Se true, impede que o mesmo jogador (mesmo id) exista em mais de um clube.
  bool enforceJogadorUnico = true;

  // ---------------------------------------------------------------------------
  // Leitura / Consulta
  // ---------------------------------------------------------------------------

  /// Lista imutável de todos os times.
  List<TimeModel> get todos =>
      UnmodifiableListView(_byId.values.toList(growable: false));

  /// Obtém por ID (lança caso não exista).
  TimeModel getById(String id) {
    final t = _byId[id];
    if (t == null) {
      throw StateError('Time "$id" não encontrado.');
    }
    return t;
  }

  /// Tenta obter por ID (null se não achar).
  TimeModel? tryGet(String id) => _byId[id];

  /// Busca por nome exato (case-insensitive). Retorna o primeiro ou null.
  TimeModel? findByNome(String nome) {
    final n = nome.trim().toLowerCase();
    for (final t in _byId.values) {
      if (t.nome.trim().toLowerCase() == n) return t;
    }
    return null;
  }

  /// Filtra por estilo tático.
  List<TimeModel> porEstilo(Estilo estilo) =>
      _byId.values.where((t) => t.estilo == estilo).toList(growable: false);

  // ---------------------------------------------------------------------------
  // Seed / Reset / Persistência
  // ---------------------------------------------------------------------------

  /// Substitui TODO o conjunto de times carregados.
  /// (sem usar "TODO" no comentário pra não virar warning do analyzer)
  void seedTimes(Iterable<TimeModel> times) {
    _byId
      ..clear()
      ..addEntries(times.map((t) => MapEntry(t.id, _defensiveClone(t))));
    _validarUnicidadeJogadores();
  }

  /// Adiciona ou substitui um time.
  void upsertTime(TimeModel time) {
    _byId[time.id] = _defensiveClone(time);
    _validarUnicidadeJogadores();
  }

  /// Remove um time (se existir). Retorna true se removeu.
  bool removerTime(String id) => _byId.remove(id) != null;

  /// Exporta todos os times (JSON leve).
  List<Map<String, dynamic>> exportarJson() =>
      _byId.values.map((t) => t.toJson()).toList(growable: false);

  /// Importa uma lista JSON de times (substitui ou funde).
  void importarJson(List<dynamic> listaJson, {bool substituir = true}) {
    final parsed = <TimeModel>[];
    for (final e in listaJson) {
      if (e is Map<String, dynamic>) {
        parsed.add(TimeModel.fromJson(e));
      }
    }
    if (substituir) {
      seedTimes(parsed);
    } else {
      for (final t in parsed) {
        upsertTime(t);
      }
    }
  }

  /// Limpa todos os times carregados.
  void reset() => _byId.clear();

  // ---------------------------------------------------------------------------
  // Elencos / Jogadores
  // ---------------------------------------------------------------------------

  /// Adiciona um jogador a um time (se não presente).
  void adicionarJogador(String timeId, Jogador jogador) {
    final t = getById(timeId);
    if (t.elenco.any((j) => j.id == jogador.id)) return;

    if (enforceJogadorUnico) {
      _assertJogadorNaoExisteEmOutroClube(jogador.id, except: timeId);
    }

    t.elenco.add(jogador);
  }

  /// Remove um jogador por ID do elenco.
  bool removerJogador(String timeId, String jogadorId) {
    final t = getById(timeId);
    final before = t.elenco.length;
    t.elenco.removeWhere((j) => j.id == jogadorId);
    final after = t.elenco.length;
    return after < before;
  }

  /// Atualiza/substitui um jogador do elenco (por ID).
  void atualizarJogador(String timeId, Jogador jogadorAtualizado) {
    final t = getById(timeId);
    final idx = t.elenco.indexWhere((j) => j.id == jogadorAtualizado.id);
    if (idx >= 0) {
      t.elenco[idx] = jogadorAtualizado;
    } else {
      adicionarJogador(timeId, jogadorAtualizado);
    }
  }

  /// Transfere um jogador entre clubes (remove do origem, adiciona no destino).
  void transferirJogador({
    required String fromTimeId,
    required String toTimeId,
    required String jogadorId,
  }) {
    if (fromTimeId == toTimeId) return;
    final from = getById(fromTimeId);
    final to = getById(toTimeId);

    final idx = from.elenco.indexWhere((j) => j.id == jogadorId);
    if (idx < 0) {
      throw StateError(
        'Jogador "$jogadorId" não encontrado no elenco de ${from.nome}.',
      );
    }
    final jogador = from.elenco.removeAt(idx);

    if (enforceJogadorUnico) {
      _assertJogadorNaoExisteEmOutroClube(jogador.id, except: toTimeId);
    }

    to.elenco.add(jogador);
  }

  /// Substitui o elenco inteiro do clube por [novoElenco].
  void substituirElenco(String timeId, List<Jogador> novoElenco) {
    if (enforceJogadorUnico) {
      for (final j in novoElenco) {
        _assertJogadorNaoExisteEmOutroClube(j.id, except: timeId);
      }
    }
    final t = getById(timeId);
    t.elenco
      ..clear()
      ..addAll(novoElenco);
  }

  /// Lê nacionalidade do jogador com tolerância a esquemas diferentes.
  /// Aceita campos: nacionalidade / pais / countryCode. Default: 'BRA'.
  String _nac(Jogador j) {
    try {
      final v = (j as dynamic).nacionalidade as String?;
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {}
    try {
      final v = (j as dynamic).pais as String?;
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {}
    try {
      final v = (j as dynamic).countryCode as String?;
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {}
    return 'BRA';
  }

  /// Total de estrangeiros do elenco (com base em nacionalidade != 'BRA').
  int totalEstrangeiros(String timeId) {
    final t = getById(timeId);
    return t.elenco.where((j) => _nac(j) != 'BRA').length;
  }

  /// Verifica se o clube excede o limite de estrangeiros.
  bool excedeLimiteEstrangeiros(String timeId) {
    final t = getById(timeId);
    return totalEstrangeiros(timeId) > t.maxEstrangeiros;
  }

  // ---------------------------------------------------------------------------
  // OVR do time (Caminho B)
  // ---------------------------------------------------------------------------

  double _ovrMedia10Jogador(Jogador j) {
    // canônico: soma dos 10 / 10
    final ovrCheio = j.ovrCheio;
    if (ovrCheio <= 0) return 0.0;
    return (ovrCheio / 10.0).clamp(1.0, 10.0);
  }

  /// ✅ OVR médio canônico (1..10) = média de (j.ovrCheio/10)
  double ovrMedio10(String timeId) {
    final t = getById(timeId);
    if (t.elenco.isEmpty) return 0.0;
    final soma =
        t.elenco.fold<double>(0.0, (a, j) => a + _ovrMedia10Jogador(j));
    return soma / t.elenco.length;
  }

  /// ✅ OVR médio “cheio” (10..100), baseado na soma dos 10 atributos da função:
  double ovrMedioCheio(String timeId) {
    final t = getById(timeId);
    if (t.elenco.isEmpty) return 0.0;
    final soma = t.elenco.fold<int>(0, (a, j) => a + j.ovrCheio);
    return soma / t.elenco.length;
  }

  /// Compat: mantém assinatura antiga
  double ovrMedio(String timeId) => ovrMedio10(timeId);

  // ---------------------------------------------------------------------------
  // Estilo / Metadados de Time
  // ---------------------------------------------------------------------------

  void setEstilo(String timeId, Estilo estilo) {
    final t = getById(timeId);
    _byId[timeId] = TimeModel(
      id: t.id,
      nome: t.nome,
      estilo: estilo,
      elenco: List<Jogador>.from(t.elenco),
      maxEstrangeiros: t.maxEstrangeiros,
    );
  }

  void renomear(String timeId, String novoNome) {
    final t = getById(timeId);
    _byId[timeId] = TimeModel(
      id: t.id,
      nome: novoNome,
      estilo: t.estilo,
      elenco: List<Jogador>.from(t.elenco),
      maxEstrangeiros: t.maxEstrangeiros,
    );
  }

  void setLimiteEstrangeiros(String timeId, int maxEstrangeiros) {
    final t = getById(timeId);
    _byId[timeId] = TimeModel(
      id: t.id,
      nome: t.nome,
      estilo: t.estilo,
      elenco: List<Jogador>.from(t.elenco),
      maxEstrangeiros: maxEstrangeiros,
    );
  }

  // ---------------------------------------------------------------------------
  // Validações / Internos
  // ---------------------------------------------------------------------------

  void _validarUnicidadeJogadores() {
    if (!enforceJogadorUnico) return;
    final seen = <String, String>{}; // jogadorId -> timeId
    _byId.forEach((timeId, t) {
      for (final j in t.elenco) {
        final other = seen[j.id];
        if (other != null && other != timeId) {
          throw StateError(
            'Jogador "${j.id}" aparece em dois clubes: $other e $timeId.',
          );
        }
        seen[j.id] = timeId;
      }
    });
  }

  void _assertJogadorNaoExisteEmOutroClube(String jogadorId, {String? except}) {
    for (final entry in _byId.entries) {
      final tid = entry.key;
      if (tid == except) continue;
      if (entry.value.elenco.any((j) => j.id == jogadorId)) {
        throw StateError(
          'Jogador "$jogadorId" já pertence ao clube "$tid".',
        );
      }
    }
  }

  TimeModel _defensiveClone(TimeModel t) => TimeModel(
        id: t.id,
        nome: t.nome,
        estilo: t.estilo,
        elenco: List<Jogador>.from(t.elenco),
        maxEstrangeiros: t.maxEstrangeiros,
      );
}
