import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/services/player_factory.dart';

class ClubSquad {
  final String clubId;

  /// Elenco profissional
  final List<Player> _pro;

  ClubSquad({
    required this.clubId,
    required List<Player> pro,
  }) : _pro = pro;

  /// Retorna lista imutável (protege o estado)
  List<Player> get pro => List.unmodifiable(_pro);

  void addPlayer(Player player) {
    if (_pro.any((p) => p.id == player.id)) return;
    _pro.add(player);
  }

  Map<String, dynamic> toJson() => {
        'clubId': clubId,
        'pro': _pro.map((e) => e.toJson()).toList(),
      };

  static ClubSquad fromJson(Map<String, dynamic> json) {
    return ClubSquad(
      clubId: json['clubId'] as String,
      pro: (json['pro'] as List)
          .map((e) => Player.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

/// Gerencia apenas o elenco PROFISSIONAL
class ClubSquadService {
  final SeededRng rng;
  final PlayerFactory playerFactory;

  final Map<String, ClubSquad> _cache = {};

  ClubSquadService({
    required this.rng,
    required this.playerFactory,
  });

  ClubSquad getOrCreateSquad({
    required String clubId,
    required String nacionalidadePadrao,
  }) {
    final cached = _cache[clubId];
    if (cached != null) return cached;

    final pro = _generateProSquad(nacionalidadePadrao);

    final squad = ClubSquad(
      clubId: clubId,
      pro: pro,
    );

    _cache[clubId] = squad;
    return squad;
  }

  ClubSquad? getCached(String clubId) => _cache[clubId];

  List<Player> getPro(String clubId) => _cache[clubId]?.pro ?? const <Player>[];

  /// Contratação / promoção para o profissional
  void addToPro({
    required String clubId,
    required Player player,
  }) {
    final squad = _cache[clubId];

    if (squad == null) {
      throw StateError('Squad não existe: $clubId');
    }

    squad.addPlayer(player);
  }

  Map<String, dynamic> toJson() => {
        'cache': _cache.map((k, v) => MapEntry(k, v.toJson())),
      };

  static ClubSquadService fromJson(
    Map<String, dynamic> json, {
    required SeededRng rng,
    required PlayerFactory playerFactory,
  }) {
    final svc = ClubSquadService(
      rng: rng,
      playerFactory: playerFactory,
    );

    final raw = (json['cache'] as Map?)?.cast<String, dynamic>() ?? {};

    for (final e in raw.entries) {
      svc._cache[e.key] =
          ClubSquad.fromJson((e.value as Map).cast<String, dynamic>());
    }

    return svc;
  }

  // -------------------------
  // Geração inicial (MVP)
  // -------------------------

  List<Player> _generateProSquad(String nac) {
    final list = <Player>[];

    // 3 Goleiros
    list.addAll(List.generate(
      3,
      (_) => playerFactory.criarJogador(
        posDet: PosDet.gol,
        nacionalidade: nac,
      ),
    ));

    // Defensores
    list.addAll(List.generate(
      4,
      (_) => playerFactory.criarJogador(posDet: PosDet.zag, nacionalidade: nac),
    ));
    list.addAll(List.generate(
      2,
      (_) => playerFactory.criarJogador(posDet: PosDet.ld, nacionalidade: nac),
    ));
    list.addAll(List.generate(
      2,
      (_) => playerFactory.criarJogador(posDet: PosDet.le, nacionalidade: nac),
    ));

    // Meio-campo
    list.addAll(List.generate(
      3,
      (_) => playerFactory.criarJogador(posDet: PosDet.vol, nacionalidade: nac),
    ));
    list.addAll(List.generate(
      2,
      (_) => playerFactory.criarJogador(posDet: PosDet.mc, nacionalidade: nac),
    ));
    list.addAll(List.generate(
      2,
      (_) => playerFactory.criarJogador(posDet: PosDet.mei, nacionalidade: nac),
    ));

    // Ataque
    list.addAll(List.generate(
      2,
      (_) => playerFactory.criarJogador(posDet: PosDet.pd, nacionalidade: nac),
    ));
    list.addAll(List.generate(
      2,
      (_) => playerFactory.criarJogador(posDet: PosDet.pe, nacionalidade: nac),
    ));
    list.addAll(List.generate(
      1,
      (_) => playerFactory.criarJogador(posDet: PosDet.ca, nacionalidade: nac),
    ));

    rng.shuffle(list);
    return list;
  }
}
