// lib/services/world/game_state.dart
//
// GameState (MVP) + compat + SAVE/LOAD + Finanças (domain)
// ✅ MERCADO (pool global offline)
// ✅ MERCADO (MVP v2): Listas fixas por JANELA (JAN/JUL) + Scout A/B/C/D com erro por nível
// ✅ EVOLUÇÃO (MVP)
//
// ✅ LOOP / MOTOR (MVP):
//   - avancarUmDia(): simula a rodada atual; se acabou temporada, inicia nova.
//   - dataStr / dia / mes / ano / isMatchDay: getters calculados (por rodada) pra UI.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

import '../team_power_service.dart';
import '../tier_service.dart';
import '../match_engine.dart';
import '../league_scheduler.dart';
import '../league_table_service.dart';

// ✅ NEWS (builder + service real)
import '../news/match_news_builder.dart';
import '../news/news_service.dart';
import '../../models/news/news_item.dart';

// Finance service (services/)
import '../finance/finance_rules_service.dart';

import '../../models/league_table.dart';
import '../../models/fixture.dart';
import '../../data/clubes_data.dart';

// Domínio
import '../../domain/models/clube_state.dart';
import '../../domain/models/financeiro_clube.dart';

// ✅ Mercado/jogadores
import '../../models/jogador.dart';
import '../../models/pe_preferencial.dart';
import '../club_squad_service.dart';

// ✅ RNG
import '../../core/seeded_rng.dart';

class AdversaryClub {
  final String id;
  final String nome;
  final String divisao; // A | B | C | D
  final double ata, mei, def, gk; // 1..10
  final String tendencia;
  final List<String> nomesPadrao;

  AdversaryClub({
    required this.id,
    required this.nome,
    required this.divisao,
    required this.ata,
    required this.mei,
    required this.def,
    required this.gk,
    required this.tendencia,
    required this.nomesPadrao,
  });

  double get idxEstruturas100 => (((ata + mei + def + gk) / 4.0) * 10.0);
  double get ovrMedia100Ai => idxEstruturas100;

  factory AdversaryClub.fromMap(Map<String, dynamic> m) {
    final s = m['setores'] as Map<String, dynamic>;
    return AdversaryClub(
      id: m['id'],
      nome: m['nome'],
      divisao: (m['divisao'] as String).toUpperCase(),
      ata: (s['ata'] as num).toDouble(),
      mei: (s['mei'] as num).toDouble(),
      def: (s['def'] as num).toDouble(),
      gk: (s['gk'] as num).toDouble(),
      tendencia: m['tendencia'] ?? 'centro',
      nomesPadrao: List<String>.from(m['nomes_padrao']),
    );
  }

  Map<String, dynamic> toSaveMap() => {
        'id': id,
        'nome': nome,
        'divisao': divisao,
        'ata': ata,
        'mei': mei,
        'def': def,
        'gk': gk,
        'tendencia': tendencia,
        'nomesPadrao': nomesPadrao,
      };

  factory AdversaryClub.fromSaveMap(Map<String, dynamic> m) {
    return AdversaryClub(
      id: m['id'],
      nome: m['nome'],
      divisao: (m['divisao'] as String).toUpperCase(),
      ata: (m['ata'] as num).toDouble(),
      mei: (m['mei'] as num).toDouble(),
      def: (m['def'] as num).toDouble(),
      gk: (m['gk'] as num).toDouble(),
      tendencia: m['tendencia'] ?? 'centro',
      nomesPadrao: List<String>.from((m['nomesPadrao'] as List?) ?? const []),
    );
  }
}

class WorldDataService {
  static final WorldDataService _i = WorldDataService._();
  WorldDataService._();
  factory WorldDataService() => _i;

  List<AdversaryClub>? _cache;

  Future<List<AdversaryClub>> loadAdversarios() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString('assets/data/adversarios.json');
      final map = json.decode(raw) as Map<String, dynamic>;
      _cache =
          (map['clubes'] as List).map((e) => AdversaryClub.fromMap(e)).toList();
    } catch (_) {
      _cache = [];
    }
    return _cache!;
  }
}

// =======================================================
// ✅ MERCADO (MVP v2) — Janelas + Scout
// =======================================================

enum MarketWindow { jan, jul, fora }

class ScoutResumo {
  final String ofe; // A/B/C/D
  final String def;
  final String tec;
  final String fis;
  final String men;

  const ScoutResumo({
    required this.ofe,
    required this.def,
    required this.tec,
    required this.fis,
    required this.men,
  });

  Map<String, dynamic> toJson() => {
        'ofe': ofe,
        'def': def,
        'tec': tec,
        'fis': fis,
        'men': men,
      };

  factory ScoutResumo.fromJson(Map<String, dynamic> m) => ScoutResumo(
        ofe: (m['ofe'] as String?) ?? 'C',
        def: (m['def'] as String?) ?? 'C',
        tec: (m['tec'] as String?) ?? 'C',
        fis: (m['fis'] as String?) ?? 'C',
        men: (m['men'] as String?) ?? 'C',
      );
}

class GameState {
  static final GameState I = GameState._();
  GameState._();

  String divisionId = 'D';

  String userClubId = 'meu-clube';
  String userClubName = 'Seu Clube';

  double userOvrMedia100 = 60;
  double userIdxEstruturas100 = 55;
  int userTaticaBonus = 5;
  List<String> userArtilheiros = const ['Atacante', 'Camisa 10', 'Ponta'];

  int temporadaAno = 2026;
  int rodadaAtual = 1;
  int seasonSeed = 12345;

  late List<AdversaryClub> _divClubs;
  late List<RoundFixtures> _fixtures;
  late LeagueTable _table;

  final LeagueTableService _tableSvc = LeagueTableService();
  final FinanceRulesService _financeSvc = const FinanceRulesService();

  // ✅ NEWS builder
  final MatchNewsBuilder _matchNewsBuilder = const MatchNewsBuilder();

  List<Map<String, dynamic>>? tabela;

  int? lastSeasonUserPos;
  String? lastSeasonFromDivision;
  String? lastSeasonToDivision;

  // FINANÇAS (estado por clube)
  final Map<String, ClubeState> _clubStates = {};
  ClubeState? get userClubState => _clubStates[userClubId];
  ClubeState? clubStateOf(String clubId) => _clubStates[clubId];
  Map<String, ClubeState> get clubStates => _clubStates;

  // ✅ Getters públicos pra UI
  List<RoundFixtures> get fixtures => _fixtures;
  List<AdversaryClub> get divClubs => _divClubs;

  int get totalRodadas => _fixtures.length;
  bool get temporadaEncerrada => rodadaAtual > totalRodadas;

  // =======================================================
  // ✅ DATA (MVP) — calculada por rodada, só pra UI ficar viva
  // =======================================================

  static const List<int> _rodadasPorMes = [4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
  static const List<String> _mesNomes = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  int get ano => temporadaAno;

  int _safeRodadaParaData() {
    final upper = totalRodadas <= 0 ? 1 : totalRodadas;
    return rodadaAtual.clamp(1, upper).toInt();
  }

  /// 1..12 (calculado a partir da rodadaAtual)
  int get mes {
    final r = _safeRodadaParaData();
    var acc = 0;
    for (var i = 0; i < _rodadasPorMes.length; i++) {
      acc += _rodadasPorMes[i];
      if (r <= acc) return i + 1;
    }
    return 12;
  }

  int get dia {
    final r = _safeRodadaParaData();
    var acc = 0;
    for (var i = 0; i < _rodadasPorMes.length; i++) {
      final qtd = _rodadasPorMes[i];
      final start = acc + 1;
      final end = acc + qtd;
      if (r >= start && r <= end) {
        final idxNoMes = r - start; // 0..qtd-1
        if (qtd == 4) {
          const dias = [5, 12, 19, 26];
          return dias[idxNoMes];
        } else {
          const dias = [7, 17, 27]; // qtd=3
          return dias[idxNoMes];
        }
      }
      acc = end;
    }
    return 1;
  }

  String get mesNome => _mesNomes[(mes - 1).clamp(0, 11).toInt()];

  String get dataStr =>
      '${dia.toString().padLeft(2, '0')}/${mes.toString().padLeft(2, '0')}/$ano • Rodada ${rodadaAtual.clamp(1, max(1, totalRodadas)).toInt()}/$totalRodadas';

  bool get isMatchDay => !temporadaEncerrada;

  Future<void> avancarUmDia() async {
    if (!temporadaEncerrada) {
      await simularRodada();
      return;
    }
    await iniciarNovaTemporada();
  }

  // =======================================================
  // ✅ NEWS — FIX "Sem mensagens" (robusto) + FIX id/createdAtMs obrigatórios
  // =======================================================

  void _pushNewsSafe({
    required NewsType type,
    required String title,
    required String body,
    String? clubId,
  }) {
    final svc = NewsService.I;

    // 1) tenta push() padrão com clubId
    try {
      (svc as dynamic).push(
        type: type,
        title: title,
        body: body,
        clubId: clubId,
      );
      try {
        (svc as dynamic).notifyListeners();
      } catch (_) {}
      return;
    } catch (_) {}

    // 2) tenta push() sem clubId (muitas implementações não têm esse param)
    try {
      (svc as dynamic).push(
        type: type,
        title: title,
        body: body,
      );
      try {
        (svc as dynamic).notifyListeners();
      } catch (_) {}
      return;
    } catch (_) {}

    // 3) tenta addItem/add com NewsItem (caso teu service trabalhe com objeto)
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final item = NewsItem(
        id: 'n_${now}_${type.name}_${clubId ?? 'all'}',
        createdAtMs: now,
        type: type,
        title: title,
        body: body,
        clubId: clubId,
      );
      try {
        (svc as dynamic).addItem(item);
      } catch (_) {
        (svc as dynamic).add(item);
      }
      try {
        (svc as dynamic).notifyListeners();
      } catch (_) {}
      return;
    } catch (_) {}

    // 4) última tentativa: se o service expõe uma lista mutável "items" / "itens"
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final item = NewsItem(
        id: 'n_${now}_${type.name}_${clubId ?? 'all'}',
        createdAtMs: now,
        type: type,
        title: title,
        body: body,
        clubId: clubId,
      );
      try {
        final items = (svc as dynamic).items as List;
        items.add(item);
      } catch (_) {
        final itens = (svc as dynamic).itens as List;
        itens.add(item);
      }
      try {
        (svc as dynamic).notifyListeners();
      } catch (_) {}
    } catch (_) {
      // sem mais o que fazer aqui sem mexer no NewsService.
    }
  }

  // =======================================================
  // ✅ MERCADO (pool global)
  // =======================================================

  final List<Jogador> mercadoPool = <Jogador>[];
  int? ultimoValorPagoCompra;

  // =======================================================
  // ✅ MERCADO (MVP v2): Listas fixas por janela + Scout
  // =======================================================

  final List<Jogador> alvosTransferencia = <Jogador>[];
  final List<Jogador> alvosEmprestimo = <Jogador>[];
  final List<Jogador> alvosFreeAgent = <Jogador>[];

  final Map<String, String> scoutMotivoPorJogadorId = <String, String>{};
  final Map<String, ScoutResumo> scoutResumoPorJogadorId =
      <String, ScoutResumo>{};

  String? _marketWindowKeyGerada;

  // ✅ Free agents sempre disponíveis: gera/atualiza por mês
  String? _freeAgentsKeyGerada;

  int _ultimoMesObservado = 1;

  MarketWindow get janelaAtual {
    if (mes == 1) return MarketWindow.jan;
    if (mes == 7) return MarketWindow.jul;
    return MarketWindow.fora;
  }

  bool get podeNegociarTransferenciasAgora =>
      janelaAtual == MarketWindow.jan || janelaAtual == MarketWindow.jul;

  int get scoutNivel {
    final cs = userClubState;
    if (cs == null) return 1;
    try {
      final dyn = (cs as dynamic);
      final v = dyn.deptFutebol?.nivelScout;
      if (v is int) return v.clamp(1, 5);
    } catch (_) {}
    return 1;
  }

  int get nivelFinanceiro {
    final cs = userClubState;
    if (cs == null) return 1;
    try {
      final dyn = (cs as dynamic);
      final v = dyn.deptFinanceiro?.nivel;
      if (v is int) return v.clamp(1, 5);
    } catch (_) {}
    return 1;
  }

  // ✅ FIX CENTRAL: quando contrata, some de TODAS as listas + scout (e evita reaparecer)
  void _removerDasListasMercado(String jogadorId) {
    alvosTransferencia.removeWhere((j) => j.id == jogadorId);
    alvosEmprestimo.removeWhere((j) => j.id == jogadorId);
    alvosFreeAgent.removeWhere((j) => j.id == jogadorId);
    scoutMotivoPorJogadorId.remove(jogadorId);
    scoutResumoPorJogadorId.remove(jogadorId);
  }

  void _removerDoPoolGlobal(String jogadorId) {
    mercadoPool.removeWhere((j) => j.id == jogadorId);
  }

  // ✅ Tick único: sempre gera Free Agents; e gera Transf/Loan só em Jan/Jul
  void _tickMercadoSeNecessario() {
    final mesAtual = mes;
    _ultimoMesObservado = mesAtual;

    _gerarFreeAgentsSeNecessario(mesAtual: mesAtual);

    final w = janelaAtual;
    if (w == MarketWindow.fora) return;

    final key = '${w == MarketWindow.jan ? 'JAN' : 'JUL'}-$ano';
    if (_marketWindowKeyGerada == key) return;

    _gerarListasMercadoParaJanela(key: key);
  }

  void _gerarFreeAgentsSeNecessario({required int mesAtual}) {
    final key = 'FREE-$ano-$mesAtual';
    if (_freeAgentsKeyGerada == key && alvosFreeAgent.isNotEmpty) return;

    _freeAgentsKeyGerada = key;

    alvosFreeAgent.clear();

    final rng = SeededRng((seasonSeed ^ key.hashCode) & 0x7fffffff);

    const qtdFree = 6;
    final picksF = _pickFreeAgents(
      rng: rng,
      count: qtdFree,
      pool: mercadoPool,
    );
    alvosFreeAgent.addAll(picksF);

    final needs = _detectarNecessidadesPorPosicao();
    for (final j in alvosFreeAgent) {
      scoutMotivoPorJogadorId[j.id] =
          _motivoParaJogador(needs: needs, j: j, rng: rng);
      scoutResumoPorJogadorId[j.id] = _gerarResumoScout(j, rng: rng);
    }
  }

  void _gerarListasMercadoParaJanela({required String key}) {
    _marketWindowKeyGerada = key;

    alvosTransferencia.clear();
    alvosEmprestimo.clear();

    final rng = SeededRng((seasonSeed ^ key.hashCode) & 0x7fffffff);

    const qtdTransf = 6;
    const qtdLoan = 3;

    final needs = _detectarNecessidadesPorPosicao();

    final picksT = _pickPorNeed(
      rng: rng,
      needs: needs,
      count: qtdTransf,
      pool: mercadoPool,
      allowGoalkeeper: true,
    );

    final picksL = _pickPorNeed(
      rng: rng,
      needs: needs,
      count: qtdLoan,
      pool: mercadoPool,
      allowGoalkeeper: true,
    );

    alvosTransferencia.addAll(picksT);
    alvosEmprestimo.addAll(picksL);

    for (final j in [...alvosTransferencia, ...alvosEmprestimo]) {
      scoutMotivoPorJogadorId[j.id] =
          _motivoParaJogador(needs: needs, j: j, rng: rng);
      scoutResumoPorJogadorId[j.id] = _gerarResumoScout(j, rng: rng);
    }
  }

  /// ✅ compat: pega posMacro sem quebrar se Jogador.pos for String ou String?
  String _posMacroSafe(Jogador j, {String fallback = 'MC'}) {
    try {
      final raw = (j as dynamic).pos;
      if (raw is String && raw.trim().isNotEmpty) return raw;
    } catch (_) {}
    return fallback;
  }

  Map<String, int> _detectarNecessidadesPorPosicao() {
    final pro = ClubSquadService.I.getProSquad(userClubId);
    final cnt = <String, int>{};

    for (final j in pro) {
      final p = (j.posDet.isNotEmpty) ? j.posDet : _posMacroSafe(j);
      cnt[p] = (cnt[p] ?? 0) + 1;
    }

    int score(String posDet) {
      final c = cnt[posDet] ?? 0;
      final alvoMin = (posDet == 'GOL') ? 2 : 3;
      return max(0, alvoMin - c);
    }

    return {
      'GOL': score('GOL'),
      'ZAG': score('ZAG'),
      'LD': score('LD'),
      'LE': score('LE'),
      'VOL': score('VOL'),
      'MC': score('MC'),
      'MEI': score('MEI'),
      'ME': score('ME'),
      'MD': score('MD'),
      'PE': score('PE'),
      'PD': score('PD'),
      'CA': score('CA'),
    };
  }

  List<Jogador> _pickPorNeed({
    required SeededRng rng,
    required Map<String, int> needs,
    required int count,
    required List<Jogador> pool,
    required bool allowGoalkeeper,
  }) {
    final out = <Jogador>[];
    if (pool.isEmpty) return out;

    final weightedPos = <String>[];
    needs.forEach((pos, sc) {
      if (!allowGoalkeeper && pos == 'GOL') return;
      final w = sc.clamp(0, 4);
      for (var i = 0; i < w; i++) {
        weightedPos.add(pos);
      }
    });

    String pickPos() {
      if (weightedPos.isEmpty) return _randomPosDet(rng);
      return weightedPos[rng.intInRange(0, weightedPos.length - 1)];
    }

    final minOvr = _minOvrSugeridoPorDivisao();
    final maxOvr = _maxOvrSugeridoPorDivisao();

    var safety = 0;
    while (out.length < count && safety < 500) {
      safety++;

      final pos = pickPos();

      final candidatos = pool.where((j) {
        final p =
            (j.posDet.isNotEmpty) ? j.posDet : _posMacroSafe(j, fallback: '');
        if (p != pos) return false;

        final ovr = _ovrCheio(p, j.atributos);
        if (scoutNivel >= 4) {
          return ovr >= minOvr && ovr <= maxOvr;
        }
        if (scoutNivel >= 2) {
          return ovr >= (minOvr - 10).clamp(10, 100) &&
              ovr <= (maxOvr + 10).clamp(10, 100);
        }
        return true;
      }).toList();

      if (candidatos.isEmpty) continue;

      final pick = candidatos[rng.intInRange(0, candidatos.length - 1)];

      if (out.any((e) => e.id == pick.id)) continue;
      out.add(pick);
    }

    if (out.length < count) {
      final shuffled = List<Jogador>.from(pool);
      for (final j in shuffled) {
        if (out.any((e) => e.id == j.id)) continue;
        out.add(j);
        if (out.length >= count) break;
      }
      if (out.length > count) return out.take(count).toList();
      return out;
    }

    return out;
  }

  List<Jogador> _pickFreeAgents({
    required SeededRng rng,
    required int count,
    required List<Jogador> pool,
  }) {
    final out = <Jogador>[];
    if (pool.isEmpty) return out;

    final minOvr = (_minOvrSugeridoPorDivisao() - 10).clamp(10, 100);
    final maxOvr = (_maxOvrSugeridoPorDivisao() - 5).clamp(10, 100);

    var safety = 0;
    while (out.length < count && safety < 500) {
      safety++;

      final pick = pool[rng.intInRange(0, pool.length - 1)];
      final pos = (pick.posDet.isNotEmpty) ? pick.posDet : _posMacroSafe(pick);
      final ovr = _ovrCheio(pos, pick.atributos);

      if (ovr < minOvr || ovr > maxOvr) continue;

      if (out.any((e) => e.id == pick.id)) continue;
      out.add(pick);
    }

    if (out.length < count) {
      for (final j in pool) {
        if (out.any((e) => e.id == j.id)) continue;
        out.add(j);
        if (out.length >= count) break;
      }
    }

    if (out.length > count) return out.take(count).toList();
    return out;
  }

  int _minOvrSugeridoPorDivisao() {
    switch (divisionId.toUpperCase()) {
      case 'A':
        return 70;
      case 'B':
        return 63;
      case 'C':
        return 56;
      default:
        return 50;
    }
  }

  int _maxOvrSugeridoPorDivisao() {
    switch (divisionId.toUpperCase()) {
      case 'A':
        return 88;
      case 'B':
        return 80;
      case 'C':
        return 74;
      default:
        return 68;
    }
  }

  String _motivoParaJogador({
    required Map<String, int> needs,
    required Jogador j,
    required SeededRng rng,
  }) {
    final p = (j.posDet.isNotEmpty) ? j.posDet : _posMacroSafe(j);
    final need = (needs[p] ?? 0);

    final motivosNeed = <String>[
      'Treinador pediu reforço para o setor ($p).',
      'CAPA identificou carência no elenco ($p).',
      'Relatório interno: precisamos de mais opções em $p.',
    ];

    final motivosOportunidade = <String>[
      'CAPA achou oportunidade de mercado (perfil encaixa no time).',
      'Scout viu potencial e custo-benefício.',
      'Jogador está no radar há semanas, bom encaixe.',
    ];

    final motivosFree = <String>[
      'Free agent: custo baixo e pode compor elenco.',
      'Free agent: opção rápida para completar o grupo.',
      'Free agent: perfil experiente para rotação.',
    ];

    final isFree = alvosFreeAgent.any((e) => e.id == j.id);
    if (isFree) return motivosFree[rng.intInRange(0, motivosFree.length - 1)];

    if (need > 0) return motivosNeed[rng.intInRange(0, motivosNeed.length - 1)];
    return motivosOportunidade[
        rng.intInRange(0, motivosOportunidade.length - 1)];
  }

  ScoutResumo _gerarResumoScout(Jogador j, {required SeededRng rng}) {
    final t = _trueResumo(j);

    int maxErr;
    int chanceErr;
    switch (scoutNivel) {
      case 1:
        maxErr = 2;
        chanceErr = 70;
        break;
      case 2:
        maxErr = 2;
        chanceErr = 45;
        break;
      case 3:
        maxErr = 1;
        chanceErr = 30;
        break;
      case 4:
        maxErr = 1;
        chanceErr = 12;
        break;
      default:
        maxErr = 0;
        chanceErr = 0;
        break;
    }

    String perturb(String grade) {
      if (maxErr == 0) return grade;
      final roll = rng.intInRange(1, 100);
      if (roll > chanceErr) return grade;

      final idx = _gradeToIndex(grade);
      final err = rng.intInRange(-maxErr, maxErr);
      final newIdx = (idx + err).clamp(0, 3);
      return _indexToGrade(newIdx);
    }

    return ScoutResumo(
      ofe: perturb(t.ofe),
      def: perturb(t.def),
      tec: perturb(t.tec),
      fis: perturb(t.fis),
      men: perturb(t.men),
    );
  }

  ScoutResumo _trueResumo(Jogador j) {
    int safeInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return 0;
    }

    int of = 0, de = 0, te = 0, fi = 0, me = 0;

    try {
      final dyn = (j as dynamic);
      of = safeInt(dyn.ofensivo);
      de = safeInt(dyn.defensivo);
      te = safeInt(dyn.tecnico);
      me = safeInt(dyn.mental);
      fi = safeInt(dyn.fisico);
    } catch (_) {}

    if (of == 0 && de == 0 && te == 0 && fi == 0 && me == 0) {
      final p = (j.posDet.isNotEmpty) ? j.posDet : _posMacroSafe(j);
      final ovr = _ovrCheio(p, j.atributos);
      final g = _gradeFromOvrCheio(ovr);
      return ScoutResumo(ofe: g, def: g, tec: g, fis: g, men: g);
    }

    return ScoutResumo(
      ofe: _gradeFrom0to100(of),
      def: _gradeFrom0to100(de),
      tec: _gradeFrom0to100(te),
      fis: _gradeFrom0to100(fi),
      men: _gradeFrom0to100(me),
    );
  }

  String _gradeFrom0to100(int v) {
    final x = v.clamp(0, 100);
    if (x >= 80) return 'A';
    if (x >= 65) return 'B';
    if (x >= 50) return 'C';
    return 'D';
  }

  String _gradeFromOvrCheio(int ovrCheio) {
    final x = ovrCheio.clamp(10, 100);
    if (x >= 80) return 'A';
    if (x >= 65) return 'B';
    if (x >= 50) return 'C';
    return 'D';
  }

  int _gradeToIndex(String g) {
    switch (g.toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      default:
        return 3;
    }
  }

  String _indexToGrade(int idx) {
    switch (idx.clamp(0, 3)) {
      case 0:
        return 'A';
      case 1:
        return 'B';
      case 2:
        return 'C';
      default:
        return 'D';
    }
  }

  // =======================================================
  // ✅ EVOLUÇÃO (MVP)
  // =======================================================

  int bauEvolucaoPontos = 0;
  final Map<String, int> janeiroPendentesPorJogador = <String, int>{};

  int _ultimoMesEvolucao = 1;

  void prepararJaneiroEvolucao() {
    final clubId = userClubId;

    final pro = ClubSquadService.I.getProSquad(clubId);
    final base = ClubSquadService.I.getBaseSquad(clubId);
    final all = <Jogador>[...pro, ...base];

    janeiroPendentesPorJogador.clear();

    for (final j in all) {
      final idade = j.idade;

      int delta;
      if (idade <= 18) {
        delta = 3;
      } else if (idade <= 20) {
        delta = 2;
      } else if (idade <= 24) {
        delta = 1;
      } else if (idade <= 28) {
        delta = 0;
      } else if (idade <= 32) {
        delta = -1;
      } else if (idade <= 35) {
        delta = -3;
      } else {
        delta = -5;
      }

      janeiroPendentesPorJogador[j.id] = delta;
    }
  }

  void _tickEvolucaoSeMudouMes(
      {required int mesAntes, required int mesDepois}) {
    if (mesDepois == mesAntes) return;

    _ultimoMesEvolucao = mesDepois;

    if (mesDepois == 1) {
      prepararJaneiroEvolucao();
    }

    int pontos = 1;
    try {
      final cs = userClubState;
      final dyn = (cs as dynamic);
      final ct = dyn.deptFutebol?.nivelCT;
      if (ct is int) {
        pontos = ct.clamp(1, 5);
      }
    } catch (_) {}
    bauEvolucaoPontos += pontos;
  }

  // =======================================================

  String clubName(String id) {
    for (final c in _divClubs) {
      if (c.id == id) return c.nome;
    }
    return id;
  }

  void registerUserClub({
    required String id,
    required String nome,
    required double ovrMedia100,
    required double idxEstruturas100,
    required int taticaBonus,
    List<String>? artilheiros,
  }) {
    userClubId = id;
    userClubName = nome;
    userOvrMedia100 = ovrMedia100;
    userIdxEstruturas100 = idxEstruturas100;
    userTaticaBonus = taticaBonus;
    userArtilheiros = artilheiros ?? userArtilheiros;
  }

  Future<void> iniciarTemporada({String? divisao, int seed = 12345}) async {
    if (divisao != null) divisionId = divisao.toUpperCase();
    seasonSeed = seed;

    final todos = await WorldDataService().loadAdversarios();

    var daDivisao = todos
        .where((c) => c.divisao == divisionId && c.id != userClubId)
        .toList();

    if (daDivisao.length < 19) {
      daDivisao = _buildAdversariosFromSeeds(
        divisionId: divisionId,
        count: 19,
        seed: seed,
        excludeIds: {userClubId},
      );
    } else {
      daDivisao = daDivisao.take(19).toList();
    }

    final userClub = AdversaryClub(
      id: userClubId,
      nome: userClubName,
      divisao: divisionId,
      ata: userIdxEstruturas100 / 10,
      mei: userIdxEstruturas100 / 10,
      def: userIdxEstruturas100 / 10,
      gk: userIdxEstruturas100 / 10,
      tendencia: 'centro',
      nomesPadrao: userArtilheiros,
    );

    _divClubs = [...daDivisao, userClub];

    _ensureClubStatesForDivision(seed: seasonSeed);

    final clubIds = _divClubs.map((c) => c.id).toList();

    _fixtures = LeagueScheduler.generateDoubleRoundRobin(
      clubIds: clubIds,
      seed: seed,
    );

    _table = _tableSvc.createInitialTable(
      divisionId: divisionId,
      clubs: _divClubs.map((c) => {'id': c.id, 'name': c.nome}).toList(),
    );

    rodadaAtual = 1;
    _publicarTabela();

    _ensureMercadoPool(seed: seasonSeed);

    _ultimoMesEvolucao = mes;
    if (mes == 1 && janeiroPendentesPorJogador.isEmpty) {
      prepararJaneiroEvolucao();
    }

    _ultimoMesObservado = mes;
    _tickMercadoSeNecessario();
  }

  Future<void> iniciarNovaTemporada({int? seed}) async {
    lastSeasonFromDivision = divisionId;

    if (temporadaEncerrada) {
      lastSeasonUserPos = _posicaoDoUsuario();
      final nextDiv = _calcularProximaDivisaoDoUsuario(
        atual: divisionId,
        posicao: lastSeasonUserPos ?? -1,
      );
      divisionId = nextDiv;
      lastSeasonToDivision = nextDiv;
    }

    temporadaAno += 1;

    final u = _clubStates[userClubId];
    if (u != null) {
      u.nome = userClubName;
      u.divisao = divisionId;
    }

    final s = seed ?? (DateTime.now().microsecondsSinceEpoch & 0x7fffffff);
    await iniciarTemporada(divisao: divisionId, seed: s);
  }

  Future<void> simularRodada() async {
    if (temporadaEncerrada) return;

    final mesAntes = mes;

    final idx = rodadaAtual - 1;
    if (idx < 0 || idx >= _fixtures.length) return;

    final rodada = _fixtures[idx];

    bool userJogou = false;
    MatchResult? lastUserResult;
    bool lastUserMandante = false;
    String? lastUserAdversarioNome;

    for (final m in rodada.matches) {
      final home = _divClubs.firstWhere((c) => c.id == m.homeId);
      final away = _divClubs.firstWhere((c) => c.id == m.awayId);

      final mHome = _calcM(home, true, idx);
      final mAway = _calcM(away, false, idx);

      final tier = const TierService().tier(mHome - mAway);

      final result = await const MatchEngine().simular(
        MatchEngineContext(
          mA: mHome,
          mB: mAway,
          tier: tier.index,
          nomesAdversario:
              away.id == userClubId ? home.nomesPadrao : away.nomesPadrao,
          seusArtilheiros: home.id == userClubId ? userArtilheiros : const [],
          seed: (seasonSeed ^ idx ^ m.homeId.hashCode ^ m.awayId.hashCode) &
              0x7fffffff,
        ),
      );

      _tableSvc.applyMatch(
        table: _table,
        homeId: home.id,
        awayId: away.id,
        golsHome: result.golsA,
        golsAway: result.golsB,
      );

      final userIsHome = home.id == userClubId;
      final userIsAway = away.id == userClubId;

      if (userIsHome || userIsAway) {
        userJogou = true;
        lastUserResult = result;
        lastUserMandante = userIsHome;
        lastUserAdversarioNome = userIsHome ? away.nome : home.nome;
      }
    }

    // ✅ FINANÇAS pós-rodada (usuário)
    final cs = userClubState;
    if (cs != null && userJogou) {
      _financeSvc.aplicarPosRodadaUsuario(
        clube: cs,
        divisao: divisionId,
      );
    }

    // ✅ NEWS da partida do usuário (imprensa/torcida)
    if (userJogou && lastUserResult != null && lastUserAdversarioNome != null) {
      final res = lastUserResult;
      final adversarioNome = lastUserAdversarioNome;

      final golsPro = lastUserMandante ? res!.golsA : res!.golsB;
      final golsContra = lastUserMandante ? res.golsB : res.golsA;

      final item = _matchNewsBuilder.build(
        clubId: userClubId,
        clubNome: userClubName,
        adversarioNome: adversarioNome!,
        rodada: rodadaAtual,
        golsPro: golsPro,
        golsContra: golsContra,
        mandante: lastUserMandante,
      );

      _pushNewsSafe(
        type: NewsType.match,
        title: item.title,
        body: item.body,
        clubId: userClubId,
      );
    }

    rodadaAtual += 1;
    if (rodadaAtual > _fixtures.length) {
      rodadaAtual = _fixtures.length + 1;
    }

    _publicarTabela();

    final mesDepois = mes;
    _tickEvolucaoSeMudouMes(mesAntes: mesAntes, mesDepois: mesDepois);

    _tickMercadoSeNecessario();
  }

  // =======================================================
  // ✅ CONTRATAÇÕES (MVP) — métodos esperados pelo MercadoPage
  // =======================================================

  bool contratarTransferenciaDaLista(Jogador j, {required int anosContrato}) {
    if (!podeNegociarTransferenciasAgora) return false;

    final ok = _fecharContratacao(
      j,
      anosContrato: anosContrato,
      tipo: _DealType.transfer,
    );

    return ok;
  }

  bool contratarEmprestimoDaLista(Jogador j) {
    if (!podeNegociarTransferenciasAgora) return false;

    final ok = _fecharContratacao(
      j,
      anosContrato: 1,
      tipo: _DealType.loan,
    );

    return ok;
  }

  bool contratarFreeAgent(Jogador j, {required int anosContrato}) {
    // free agent pode contratar fora da janela (MVP)
    final ok = _fecharContratacao(
      j,
      anosContrato: anosContrato,
      tipo: _DealType.free,
    );

    return ok;
  }

  bool _fecharContratacao(
    Jogador j, {
    required int anosContrato,
    required _DealType tipo,
  }) {
    final cs = userClubState;
    if (cs == null) return false;

    // 1) calcula valor
    final base = (j.valorMercado).toDouble();

    // multipliers MVP
    double mult;
    switch (tipo) {
      case _DealType.transfer:
        mult = 1.00;
        break;
      case _DealType.loan:
        // MVP: ainda “compra” (você disse que depois vira taxa)
        mult = 0.85;
        break;
      case _DealType.free:
        // luvas / signing fee (MVP leve)
        mult = 0.55;
        break;
    }

    // desconto simples pelo nível financeiro (quanto maior, mais barato)
    // N1=0%, N2=5%, N3=8%, N4=12%, N5=15%
    final nf = nivelFinanceiro.clamp(1, 5);
    final desconto = switch (nf) {
      1 => 0.00,
      2 => 0.05,
      3 => 0.08,
      4 => 0.12,
      _ => 0.15,
    };

    final valorFinal = (base * mult * (1.0 - desconto)).round().toDouble();
    ultimoValorPagoCompra = valorFinal.round();

    // 2) aplica no financeiro (se faltar caixa vira dívida)
    final fin = cs.financeiro;
    final caixa = fin.caixa;
    if (caixa >= valorFinal) {
      fin.caixa = caixa - valorFinal;
    } else {
      final falta = valorFinal - caixa;
      fin.caixa = 0;
      fin.divida = fin.divida + falta;
    }

    // 3) configura anos/salário (sem quebrar se for final)
    final salario = _calcSalarioMensalMvp(valorFinal);
    try {
      (j as dynamic).anosContrato = anosContrato;
    } catch (_) {}
    try {
      (j as dynamic).salarioMensal = salario;
    } catch (_) {}

    // 4) adiciona no elenco do usuário
    try {
      ClubSquadService.I.addToProSquad(userClubId, j);
    } catch (_) {
      // fallback: se não tiver addToProSquad, tenta um método comum
      try {
        (ClubSquadService.I as dynamic).addPro(userClubId, j);
      } catch (_) {}
    }

    // 5) limpa listas + remove do pool global
    _removerDasListasMercado(j.id);
    _removerDoPoolGlobal(j.id);

    return true;
  }

  double _calcSalarioMensalMvp(double valorTransfer) {
    // regra simples MVP: ~5% do valor ao ano / 12
    final anual = valorTransfer * 0.05;
    return (anual / 12.0);
  }

  // =======================================================
  // Mercado: geração inicial simples (offline)
  // =======================================================

  void _ensureMercadoPool({required int seed}) {
    if (mercadoPool.isNotEmpty) return;

    const int poolSize = 120;

    final rng = SeededRng(seed ^ 0x51A7);
    final usedIds = <String>{};

    for (var i = 0; i < poolSize; i++) {
      final posDet = _randomPosDet(rng);
      final idade = rng.intInRange(18, 34);

      final min10 = idade <= 20 ? 4 : 5;
      final max10 = idade <= 20 ? 7 : 8;

      final attrs = _generateAttrsForMarket(
        rng: rng,
        posDet: posDet,
        min10: min10,
        max10: max10,
      );

      final ovr = _ovrCheio(posDet, attrs);

      final j = Jogador(
        id: _uniqueMarketId(usedIds, i, seed),
        nome: _randomName(rng),
        posDet: posDet,
        idade: idade,
        pe: _randomPe(rng),
        atributos: attrs,
        faceAsset: 'faces/placeholder.png',
        valorMercado: _calcValorMercadoFromOvr(ovrCheio: ovr, idade: idade),
        salarioMensal: 0,
        anosContrato: rng.intInRange(1, 4),
      );

      mercadoPool.add(j);
    }
  }

  String _uniqueMarketId(Set<String> used, int i, int seed) {
    var id = 'mkt_${seed}_$i';
    var k = 0;
    while (used.contains(id)) {
      k++;
      id = 'mkt_${seed}_${i}_$k';
    }
    used.add(id);
    return id;
  }

  String _randomPosDet(SeededRng rng) {
    final v = rng.intInRange(1, 100);
    if (v <= 10) return 'GOL';
    if (v <= 30) return (rng.intInRange(0, 1) == 0) ? 'LD' : 'LE';
    if (v <= 45) return 'ZAG';
    if (v <= 60) return 'VOL';
    if (v <= 75) return 'MC';
    if (v <= 82) return 'MEI';
    if (v <= 88) return (rng.intInRange(0, 1) == 0) ? 'MD' : 'ME';
    if (v <= 94) return (rng.intInRange(0, 1) == 0) ? 'PD' : 'PE';
    return 'CA';
  }

  Map<String, int> _generateAttrsForMarket({
    required SeededRng rng,
    required String posDet,
    required int min10,
    required int max10,
  }) {
    int roll() => rng.intInRange(min10, max10).clamp(1, 10);

    final m = Jogador.coreDefault(value: max(1, min10 - 2));
    for (final k in Jogador.coreKeys) {
      m[k] = roll();
    }

    final keys10 =
        Jogador.roleKeysByPosDet[posDet] ?? Jogador.roleKeysByPosDet['MC']!;
    for (final k in keys10) {
      final base = (m[k] ?? roll());
      final bump = rng.intInRange(0, 2);
      final bumped = base + bump;
      m[k] = (bumped > 10) ? 10 : bumped;
    }

    return m.map((k, v) => MapEntry(k, v.clamp(1, 10)));
  }

  int _ovrCheio(String posDet, Map<String, int> attrs) {
    final keys10 =
        Jogador.roleKeysByPosDet[posDet] ?? Jogador.roleKeysByPosDet['MC']!;
    var sum = 0;
    for (final k in keys10) {
      sum += (attrs[k] ?? 1).clamp(1, 10);
    }
    return sum.clamp(10, 100);
  }

  int _calcValorMercadoFromOvr({required int ovrCheio, required int idade}) {
    final base = ovrCheio * 100000;

    double mult;
    if (idade <= 20) {
      mult = 1.25;
    } else if (idade <= 24) {
      mult = 1.15;
    } else if (idade <= 29) {
      mult = 1.00;
    } else if (idade <= 33) {
      mult = 0.85;
    } else {
      mult = 0.70;
    }

    return (base * mult).round().clamp(200000, 500000000);
  }

  PePreferencial _randomPe(SeededRng rng) {
    final v = rng.intInRange(0, 99);
    if (v < 15) return PePreferencial.ambos;
    if (v < 65) return PePreferencial.direito;
    return PePreferencial.esquerdo;
  }

  String _randomName(SeededRng rng) {
    const nomes = [
      'Carlos',
      'João',
      'Pedro',
      'Lucas',
      'Mateus',
      'Rafael',
      'Bruno',
      'Diego',
      'Gabriel',
      'Gustavo',
      'Henrique',
      'Vitor',
      'Caio',
      'Fábio',
      'Renan',
      'Arthur',
      'Samuel',
      'Davi',
      'André',
      'Felipe',
      'Igor',
      'Daniel',
      'Thiago',
      'Murilo',
    ];
    const sobrenomes = [
      'Silva',
      'Souza',
      'Santos',
      'Oliveira',
      'Pereira',
      'Costa',
      'Rodrigues',
      'Almeida',
      'Nascimento',
      'Ferreira',
      'Carvalho',
      'Gomes',
      'Martins',
      'Araújo',
      'Barbosa',
      'Ribeiro',
      'Cardoso',
      'Melo',
      'Teixeira',
    ];

    final n = nomes[rng.intInRange(0, nomes.length - 1)];
    final s = sobrenomes[rng.intInRange(0, sobrenomes.length - 1)];
    return '$n $s';
  }

  double _calcM(AdversaryClub c, bool mandante, int idx) {
    final isUser = c.id == userClubId;
    return const TeamPowerService().calcularM(
      TeamPowerContext(
        ovrMedia100: isUser ? userOvrMedia100 : c.ovrMedia100Ai,
        idxEstruturas100: isUser ? userIdxEstruturas100 : c.idxEstruturas100,
        taticaBonus: isUser ? userTaticaBonus : 5,
        mandante: mandante,
        seed: seasonSeed ^ idx ^ c.id.hashCode,
      ),
    );
  }

  void _publicarTabela() {
    tabela = _table.rowsSorted
        .map((r) => {
              'timeNome': r.clubName,
              'pts': r.points,
              'j': r.played,
              'v': r.wins,
              'e': r.draws,
              'd': r.losses,
              'gp': r.gf,
              'gc': r.ga,
              'saldo': r.gd,
            })
        .toList();
  }

  int _posicaoDoUsuario() {
    final rows = _table.rowsSorted;
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].clubId == userClubId) return i + 1;
    }
    return -1;
  }

  String _calcularProximaDivisaoDoUsuario({
    required String atual,
    required int posicao,
  }) {
    final d = atual.toUpperCase();
    if (posicao < 1) return d;

    final sobe = posicao <= 4;
    final cai = posicao >= 17;

    String up(String div) {
      switch (div) {
        case 'D':
          return 'C';
        case 'C':
          return 'B';
        case 'B':
          return 'A';
        default:
          return 'A';
      }
    }

    String down(String div) {
      switch (div) {
        case 'A':
          return 'B';
        case 'B':
          return 'C';
        case 'C':
          return 'D';
        default:
          return 'D';
      }
    }

    if (sobe && d != 'A') return up(d);
    if (cai && d != 'D') return down(d);
    return d;
  }

  List<AdversaryClub> _buildAdversariosFromSeeds({
    required String divisionId,
    required int count,
    required int seed,
    required Set<String> excludeIds,
  }) {
    final rng = Random(seed);

    double base = divisionId == 'A'
        ? 7.2
        : divisionId == 'B'
            ? 6.5
            : divisionId == 'C'
                ? 5.8
                : 5.1;

    final pool = clubesSeeds
        .where((c) => c.divisao.name.toUpperCase() == divisionId)
        .toList();

    final out = <AdversaryClub>[];

    while (out.length < count) {
      final pick = pool[rng.nextInt(pool.length)];
      if (excludeIds.contains(pick.slug)) continue;
      excludeIds.add(pick.slug);

      double jitter() => rng.nextDouble() - 0.5;
      double clamp(double v) => v.clamp(1.0, 10.0);

      out.add(
        AdversaryClub(
          id: pick.slug,
          nome: pick.name,
          divisao: divisionId,
          ata: clamp(base + jitter()),
          mei: clamp(base + jitter()),
          def: clamp(base + jitter()),
          gk: clamp(base + jitter()),
          tendencia: ['esquerda', 'centro', 'direita'][rng.nextInt(3)],
          nomesPadrao: const ['Atacante', 'Camisa 10', 'Ponta'],
        ),
      );
    }

    return out;
  }

  void _ensureClubStatesForDivision({required int seed}) {
    final rng = Random(seed);

    final existingUser = _clubStates[userClubId];
    if (existingUser != null) {
      existingUser.nome = userClubName;
      existingUser.divisao = divisionId;
    } else {
      _clubStates[userClubId] = ClubeState(
        id: userClubId,
        nome: userClubName,
        divisao: divisionId,
        financeiro: _financeiroInicialPorDivisao(divisionId, rng),
      );
    }

    for (final c in _divClubs) {
      if (c.id == userClubId) continue;

      final existing = _clubStates[c.id];
      if (existing != null) {
        existing.nome = c.nome;
        existing.divisao = c.divisao;
      } else {
        _clubStates[c.id] = ClubeState(
          id: c.id,
          nome: c.nome,
          divisao: c.divisao,
          financeiro: _financeiroInicialPorDivisao(c.divisao, rng),
        );
      }
    }

    final idsAtuais = _divClubs.map((c) => c.id).toSet();
    _clubStates.removeWhere((id, _) => !idsAtuais.contains(id));
  }

  FinanceiroClube _financeiroInicialPorDivisao(String div, Random rng) {
    double caixaBase;
    double dividaBase;

    switch (div.toUpperCase()) {
      case 'A':
        caixaBase = 120000000;
        dividaBase = 180000000;
        break;
      case 'B':
        caixaBase = 60000000;
        dividaBase = 220000000;
        break;
      case 'C':
        caixaBase = 35000000;
        dividaBase = 260000000;
        break;
      default:
        caixaBase = 20000000;
        dividaBase = 300000000;
        break;
    }

    double jitter(double v) => v * (0.90 + rng.nextDouble() * 0.20);

    return FinanceiroClube(
      caixa: jitter(caixaBase),
      divida: jitter(dividaBase),
    );
  }

  Map<String, dynamic> _rowToSaveMap(TableRowEntry r) {
    return {
      'clubId': r.clubId,
      'played': r.played,
      'wins': r.wins,
      'draws': r.draws,
      'losses': r.losses,
      'gf': r.gf,
      'ga': r.ga,
    };
  }

  void _hydrateTable(List<dynamic> rowsRaw) {
    final byId = <String, Map<String, dynamic>>{};
    for (final e in rowsRaw) {
      final m = e as Map<String, dynamic>;
      final id = (m['clubId'] as String?) ?? '';
      if (id.isNotEmpty) byId[id] = m;
    }

    for (final id in byId.keys) {
      try {
        final entry = _table.rowOf(id);
        final s = byId[id]!;
        entry.played = (s['played'] as int?) ?? 0;
        entry.wins = (s['wins'] as int?) ?? 0;
        entry.draws = (s['draws'] as int?) ?? 0;
        entry.losses = (s['losses'] as int?) ?? 0;
        entry.gf = (s['gf'] as int?) ?? 0;
        entry.ga = (s['ga'] as int?) ?? 0;
      } catch (_) {}
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'v': 6,
      'divisionId': divisionId,
      'temporadaAno': temporadaAno,
      'rodadaAtual': rodadaAtual,
      'seasonSeed': seasonSeed,
      'userClubId': userClubId,
      'userClubName': userClubName,
      'userOvrMedia100': userOvrMedia100,
      'userIdxEstruturas100': userIdxEstruturas100,
      'userTaticaBonus': userTaticaBonus,
      'userArtilheiros': userArtilheiros,
      'lastSeasonUserPos': lastSeasonUserPos,
      'lastSeasonFromDivision': lastSeasonFromDivision,
      'lastSeasonToDivision': lastSeasonToDivision,
      'divClubs': _divClubs.map((c) => c.toSaveMap()).toList(),
      'tableRows': _table.rowsSorted.map(_rowToSaveMap).toList(),
      'clubStates': _clubStates.values.map((c) => c.toJson()).toList(),
      'mercadoPool': mercadoPool.map((j) => j.toJson()).toList(),
      'bauEvolucaoPontos': bauEvolucaoPontos,
      'janeiroPendentesPorJogador': janeiroPendentesPorJogador,
      'marketWindowKeyGerada': _marketWindowKeyGerada,
      'freeAgentsKeyGerada': _freeAgentsKeyGerada,
      'alvosTransferencia': alvosTransferencia.map((j) => j.toJson()).toList(),
      'alvosEmprestimo': alvosEmprestimo.map((j) => j.toJson()).toList(),
      'alvosFreeAgent': alvosFreeAgent.map((j) => j.toJson()).toList(),
      'scoutMotivos': scoutMotivoPorJogadorId,
      'scoutResumo':
          scoutResumoPorJogadorId.map((k, v) => MapEntry(k, v.toJson())),
      'ultimoMesObservado': _ultimoMesObservado,
      'ultimoMesEvolucao': _ultimoMesEvolucao,
    };
  }

  void loadFromJsonMap(Map<String, dynamic> map) {
    divisionId = (map['divisionId'] as String?)?.toUpperCase() ?? 'D';
    temporadaAno = (map['temporadaAno'] as int?) ?? 2026;
    rodadaAtual = (map['rodadaAtual'] as int?) ?? 1;
    seasonSeed = (map['seasonSeed'] as int?) ?? 12345;

    userClubId = (map['userClubId'] as String?) ?? 'meu-clube';
    userClubName = (map['userClubName'] as String?) ?? 'Seu Clube';
    userOvrMedia100 = ((map['userOvrMedia100'] as num?) ?? 60).toDouble();
    userIdxEstruturas100 =
        ((map['userIdxEstruturas100'] as num?) ?? 55).toDouble();
    userTaticaBonus = (map['userTaticaBonus'] as int?) ?? 5;
    userArtilheiros = List<String>.from(
      (map['userArtilheiros'] as List<dynamic>?) ??
          const ['Atacante', 'Camisa 10', 'Ponta'],
    );

    lastSeasonUserPos = map['lastSeasonUserPos'] as int?;
    lastSeasonFromDivision = map['lastSeasonFromDivision'] as String?;
    lastSeasonToDivision = map['lastSeasonToDivision'] as String?;

    final clubsRaw = (map['divClubs'] as List<dynamic>?) ?? const [];
    _divClubs = clubsRaw
        .map((e) => AdversaryClub.fromSaveMap(e as Map<String, dynamic>))
        .toList();

    if (_divClubs.length < 2) {
      throw StateError('Save inválido: clubes insuficientes.');
    }

    final clubIds = _divClubs.map((c) => c.id).toList();
    _fixtures = LeagueScheduler.generateDoubleRoundRobin(
      clubIds: clubIds,
      seed: seasonSeed,
    );

    _table = _tableSvc.createInitialTable(
      divisionId: divisionId,
      clubs: _divClubs.map((c) => {'id': c.id, 'name': c.nome}).toList(),
    );

    final rowsRaw = (map['tableRows'] as List<dynamic>?) ?? const [];
    _hydrateTable(rowsRaw);

    _clubStates.clear();
    final csRaw = (map['clubStates'] as List<dynamic>?) ?? const [];
    for (final e in csRaw) {
      try {
        final c = ClubeState.fromJson(e as Map<String, dynamic>);
        _clubStates[c.id] = c;
      } catch (_) {}
    }

    _ensureClubStatesForDivision(seed: seasonSeed);

    mercadoPool.clear();
    final mercadoRaw = (map['mercadoPool'] as List<dynamic>?) ?? const [];
    for (final e in mercadoRaw) {
      try {
        mercadoPool.add(Jogador.fromJson(e as Map<String, dynamic>));
      } catch (_) {}
    }
    _ensureMercadoPool(seed: seasonSeed);

    bauEvolucaoPontos = (map['bauEvolucaoPontos'] as int?) ?? 0;

    janeiroPendentesPorJogador.clear();
    final janRaw = map['janeiroPendentesPorJogador'];
    if (janRaw is Map) {
      janRaw.forEach((k, v) {
        final id = k.toString();
        final val = (v as num?)?.toInt() ?? 0;
        janeiroPendentesPorJogador[id] = val;
      });
    }

    _marketWindowKeyGerada = map['marketWindowKeyGerada'] as String?;
    _freeAgentsKeyGerada = map['freeAgentsKeyGerada'] as String?;
    _ultimoMesObservado = (map['ultimoMesObservado'] as int?) ?? mes;

    _ultimoMesEvolucao = (map['ultimoMesEvolucao'] as int?) ?? mes;

    alvosTransferencia.clear();
    final at = (map['alvosTransferencia'] as List<dynamic>?) ?? const [];
    for (final e in at) {
      try {
        alvosTransferencia.add(Jogador.fromJson(e as Map<String, dynamic>));
      } catch (_) {}
    }

    alvosEmprestimo.clear();
    final al = (map['alvosEmprestimo'] as List<dynamic>?) ?? const [];
    for (final e in al) {
      try {
        alvosEmprestimo.add(Jogador.fromJson(e as Map<String, dynamic>));
      } catch (_) {}
    }

    alvosFreeAgent.clear();
    final af = (map['alvosFreeAgent'] as List<dynamic>?) ?? const [];
    for (final e in af) {
      try {
        alvosFreeAgent.add(Jogador.fromJson(e as Map<String, dynamic>));
      } catch (_) {}
    }

    scoutMotivoPorJogadorId.clear();
    final motivos = map['scoutMotivos'];
    if (motivos is Map) {
      motivos.forEach((k, v) {
        scoutMotivoPorJogadorId[k.toString()] = v.toString();
      });
    }

    scoutResumoPorJogadorId.clear();
    final resumo = map['scoutResumo'];
    if (resumo is Map) {
      resumo.forEach((k, v) {
        if (v is Map) {
          scoutResumoPorJogadorId[k.toString()] = ScoutResumo.fromJson(
            v.map((kk, vv) => MapEntry(kk.toString(), vv)),
          );
        }
      });
    }

    _publicarTabela();

    if (rodadaAtual < 1) rodadaAtual = 1;
    if (rodadaAtual > _fixtures.length + 1) {
      rodadaAtual = _fixtures.length + 1;
    }

    _tickMercadoSeNecessario();

    if (mes == 1 && janeiroPendentesPorJogador.isEmpty) {
      prepararJaneiroEvolucao();
    }
  }

  static Future<void> seedSerieA() async {
    await I.iniciarTemporada(divisao: 'A');
  }

  Future<List<AdversaryClub>> clubesPublicos([String? divisao]) async {
    final todos = await WorldDataService().loadAdversarios();
    if (divisao == null) return todos;
    return todos.where((c) => c.divisao == divisao.toUpperCase()).toList();
  }

  Map<String, dynamic>? get lastUserMatch {
    if (_fixtures.isEmpty) return null;

    final lastPlayedIndex = (rodadaAtual - 2).clamp(-1, _fixtures.length - 1);
    if (lastPlayedIndex < 0) return null;

    for (var r = lastPlayedIndex; r >= 0; r--) {
      final rodada = _fixtures[r];
      for (final m in rodada.matches) {
        if (m.homeId == userClubId || m.awayId == userClubId) {
          return {
            'rodada': r + 1,
            'homeId': m.homeId,
            'awayId': m.awayId,
            'homeNome': clubName(m.homeId),
            'awayNome': clubName(m.awayId),
          };
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? get proximaPartidaUsuarioInfo {
    if (_fixtures.isEmpty) return null;

    final start = (rodadaAtual - 1).clamp(0, _fixtures.length - 1);
    for (var r = start; r < _fixtures.length; r++) {
      final rodada = _fixtures[r];
      for (final m in rodada.matches) {
        if (m.homeId == userClubId || m.awayId == userClubId) {
          return {
            'rodada': r + 1,
            'homeId': m.homeId,
            'awayId': m.awayId,
            'homeNome': clubName(m.homeId),
            'awayNome': clubName(m.awayId),
          };
        }
      }
    }
    return null;
  }

  String get proximaPartidaUsuarioInfoStr {
    final info = proximaPartidaUsuarioInfo;
    if (info == null) return 'Sem próxima partida (temporada encerrada).';
    final r = info['rodada'];
    final h = info['homeNome'];
    final a = info['awayNome'];
    return 'Rodada $r: $h x $a';
  }

  // ✅ FIX: essas telas precisam dos elencos reais
  List<dynamic> get elencos => ClubSquadService.I.getProSquad(userClubId);
  List<dynamic> get baseElencos => ClubSquadService.I.getBaseSquad(userClubId);
}

enum _DealType { transfer, loan, free }
