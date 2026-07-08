enum MarketListType {
  transfer,
  loan,
  free,
}

class ScoutTarget {
  /// id do jogador (para localizar/remover no MarketService)
  final String jogadorId;

  /// Nome pronto para UI (UI não inventa)
  final String playerName;

  /// Posição curta pronta para UI (ex: GOL, ZAG, LE, VOL, MC, MEI, PD, PE, CA)
  final String posLabel;

  /// Qualidade estimada A/B/C/D/E (UI não calcula)
  final String qualityLabel;

  /// Tipo da lista onde o alvo está (transfer/loan/free)
  final MarketListType listType;

  /// Texto de contexto (ex: “Treinador pediu reforços: LE, VOL, MC.”)
  final String motivo;

  /// Retrato do jogador.
  final String faceAsset;

  const ScoutTarget({
    required this.jogadorId,
    required this.playerName,
    required this.posLabel,
    required this.qualityLabel,
    required this.listType,
    required this.motivo,
    required this.faceAsset,
  });

  Map<String, dynamic> toJson() => {
        'jogadorId': jogadorId,
        'playerName': playerName,
        'posLabel': posLabel,
        'qualityLabel': qualityLabel,
        'listType': listType.name,
        'motivo': motivo,
        'faceAsset': faceAsset,
      };

  static ScoutTarget fromJson(Map<String, dynamic> json) {
    final rawType = (json['listType'] as String? ?? 'transfer');

    MarketListType type;
    switch (rawType) {
      case 'loan':
        type = MarketListType.loan;
        break;
      case 'free':
        type = MarketListType.free;
        break;
      case 'transfer':
      default:
        type = MarketListType.transfer;
        break;
    }

    final jogadorId = json['jogadorId'] as String;

    return ScoutTarget(
      jogadorId: jogadorId,
      playerName: json['playerName'] as String,
      posLabel: json['posLabel'] as String,
      qualityLabel: json['qualityLabel'] as String,
      listType: type,
      motivo: (json['motivo'] as String?) ?? '',
      faceAsset: _safeFaceAsset(
        playerId: jogadorId,
        rawFaceAsset: (json['faceAsset'] as String?)?.trim(),
      ),
    );
  }

  static String _safeFaceAsset({
    required String playerId,
    required String? rawFaceAsset,
  }) {
    if (rawFaceAsset != null &&
        rawFaceAsset.isNotEmpty &&
        rawFaceAsset.startsWith('assets/faces/players/') &&
        rawFaceAsset.endsWith('.png')) {
      return rawFaceAsset;
    }

    return _faceAssetFromSeed(playerId);
  }

  static String _faceAssetFromSeed(String seed) {
    const folders = <String>[
      'latin',
      'afro',
      'european',
      'arab',
      'asian',
    ];

    final hash = seed.hashCode.abs();
    final folder = folders[hash % folders.length];
    final index = (hash % 29) + 1;
    final fileName = '${index.toString().padLeft(3, '0')}.png';

    return 'assets/faces/players/$folder/$fileName';
  }
}
