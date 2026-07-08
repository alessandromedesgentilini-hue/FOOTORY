import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/services/player/player_name_service.dart';
import 'package:footory26/services/ratings/attributes_contract.dart';

/// ÚNICO lugar que cria jogador procedural.
class PlayerFactory {
  final SeededRng rng;

  PlayerFactory(this.rng);

  late final PlayerNameService _nameService = PlayerNameService(rng);

  Player criarJogador({
    required PosDet posDet,
    required String nacionalidade,
    int? idade,
    String? nome,
    String? pe,
    String? faceAsset,
  }) {
    final finalIdade = idade ?? _idadePorPerfil(posDet);
    final finalNome = nome ?? _nameService.generate(nacionalidade);
    final finalPe = pe ?? _peAleatorio();
    final finalFace = faceAsset ?? _facePorNacionalidade(nacionalidade);

    final attrs10 = _gerarAttrs10(posDet);

    return Player(
      id: rng.id('P'),
      nome: finalNome,
      nacionalidade: nacionalidade,
      idade: finalIdade,
      posDet: posDet,
      pe: finalPe,
      faceAsset: finalFace,
      attrs10: attrs10,
      bolaParada: rng.rangeInt(1, 10),
      penalti: rng.rangeInt(1, 10),
      consistencia: rng.rangeInt(1, 10),
    );
  }

  Player criarJogadorComOvrCheioTarget({
    required PosDet posDet,
    required String nacionalidade,
    required int minOvrCheio,
    required int maxOvrCheio,
    required int idadeMin,
    required int idadeMax,
    String? nome,
    String? pe,
    String? faceAsset,
    int maxTries = 30,
  }) {
    final lo = minOvrCheio.clamp(10, 100);
    final hi = maxOvrCheio.clamp(10, 100);
    final minO = lo <= hi ? lo : hi;
    final maxO = lo <= hi ? hi : lo;

    final aMin = idadeMin.clamp(15, 45);
    final aMax = idadeMax.clamp(15, 45);
    final ageLo = aMin <= aMax ? aMin : aMax;
    final ageHi = aMin <= aMax ? aMax : aMin;

    final mid = (minO + maxO) / 2.0;

    Player? best;
    var bestDist = double.infinity;

    final tries = maxTries.clamp(1, 120);
    for (var i = 0; i < tries; i++) {
      final age = rng.rangeInt(ageLo, ageHi);

      final p = criarJogador(
        posDet: posDet,
        nacionalidade: nacionalidade,
        idade: age,
        nome: nome,
        pe: pe,
        faceAsset: faceAsset,
      );

      final o = p.ovrCheio;

      if (o >= minO && o <= maxO) return p;

      final dist = (o - mid).abs();
      if (dist < bestDist) {
        bestDist = dist;
        best = p;
      }
    }

    return best!;
  }

  int _idadePorPerfil(PosDet posDet) {
    if (posDet == PosDet.gol) return rng.rangeInt(18, 36);
    return rng.rangeInt(17, 34);
  }

  String _peAleatorio() {
    final roll = rng.rangeInt(1, 100);
    if (roll <= 70) return 'D';
    if (roll <= 90) return 'E';
    return 'A';
  }

  String _facePorNacionalidade(String nacionalidade) {
    final folder = _pastaFacePorNacionalidade(nacionalidade);
    final total = _totalFacesPorPasta(folder);
    final index = rng.rangeInt(1, total);
    final fileName = '${index.toString().padLeft(3, '0')}.png';

    return 'assets/faces/players/$folder/$fileName';
  }

  String _pastaFacePorNacionalidade(String nacionalidade) {
    final code = nacionalidade.trim().toUpperCase();

    switch (code) {
      case 'BR':
        return _weightedFolder(
          latin: 45,
          afro: 30,
          european: 18,
          arab: 4,
          asian: 3,
        );

      case 'AR':
      case 'UY':
      case 'CL':
        return _weightedFolder(
          latin: 60,
          european: 30,
          afro: 6,
          arab: 2,
          asian: 2,
        );

      case 'CO':
      case 'VE':
      case 'EC':
      case 'PE':
      case 'PY':
      case 'BO':
      case 'MX':
      case 'CR':
        return _weightedFolder(
          latin: 72,
          afro: 14,
          european: 10,
          arab: 2,
          asian: 2,
        );

      case 'FR':
      case 'ENG':
      case 'NL':
      case 'BE':
        return _weightedFolder(
          european: 55,
          afro: 22,
          arab: 14,
          latin: 7,
          asian: 2,
        );

      case 'PT':
      case 'ES':
        return _weightedFolder(
          european: 68,
          latin: 18,
          afro: 8,
          arab: 5,
          asian: 1,
        );

      case 'DE':
      case 'IT':
      case 'HR':
      case 'RS':
      case 'CH':
      case 'AT':
      case 'DK':
      case 'SE':
      case 'NO':
      case 'PL':
        return _weightedFolder(
          european: 78,
          afro: 8,
          arab: 7,
          latin: 5,
          asian: 2,
        );

      case 'US':
      case 'CA':
        return _weightedFolder(
          european: 45,
          afro: 25,
          latin: 18,
          asian: 8,
          arab: 4,
        );

      case 'NG':
      case 'CI':
      case 'SN':
      case 'GH':
      case 'CM':
      case 'ML':
      case 'ZA':
        return _weightedFolder(
          afro: 88,
          arab: 5,
          european: 4,
          latin: 2,
          asian: 1,
        );

      case 'MA':
      case 'DZ':
      case 'TN':
      case 'EG':
      case 'SA':
      case 'QA':
      case 'IR':
      case 'IQ':
      case 'AE':
      case 'TR':
        return _weightedFolder(
          arab: 78,
          afro: 10,
          european: 8,
          latin: 2,
          asian: 2,
        );

      case 'JP':
      case 'KR':
      case 'CN':
        return _weightedFolder(
          asian: 94,
          european: 3,
          latin: 1,
          afro: 1,
          arab: 1,
        );

      default:
        return _weightedFolder(
          latin: 35,
          european: 30,
          afro: 20,
          arab: 10,
          asian: 5,
        );
    }
  }

  String _weightedFolder({
    int latin = 0,
    int afro = 0,
    int european = 0,
    int arab = 0,
    int asian = 0,
  }) {
    final total = latin + afro + european + arab + asian;
    if (total <= 0) return 'latin';

    final roll = rng.rangeInt(1, total);
    var cursor = 0;

    cursor += latin;
    if (roll <= cursor) return 'latin';

    cursor += afro;
    if (roll <= cursor) return 'afro';

    cursor += european;
    if (roll <= cursor) return 'european';

    cursor += arab;
    if (roll <= cursor) return 'arab';

    return 'asian';
  }

  int _totalFacesPorPasta(String folder) {
    switch (folder) {
      case 'afro':
        return 32;
      case 'arab':
        return 13;
      case 'asian':
        return 12;
      case 'european':
        return 33;
      case 'latin':
        return 40;
      default:
        return 12;
    }
  }

  Map<String, int> _gerarAttrs10(PosDet posDet) {
    final keys = AttributesContract.keysForPosition(posDet);
    final map = <String, int>{};

    final base = _basePorPos(posDet);

    for (final key in keys) {
      final value = (base + rng.rangeInt(-2, 2)).clamp(1, 10);
      map[key] = value;
    }

    return map;
  }

  int _basePorPos(PosDet posDet) {
    switch (posDet) {
      case PosDet.gol:
        return rng.rangeInt(4, 8);
      case PosDet.ld:
      case PosDet.le:
      case PosDet.zag:
      case PosDet.vol:
      case PosDet.mc:
      case PosDet.mei:
      case PosDet.pd:
      case PosDet.pe:
      case PosDet.ca:
        return rng.rangeInt(4, 8);
    }
  }
}
