class FootballDirectorPortrait {
  final String id;
  final String assetPath;

  const FootballDirectorPortrait({
    required this.id,
    required this.assetPath,
  });
}

class FootballDirectorPortraitCatalog {
  static const String _baseAssetPath = 'assets/faces/directors';

  static const List<FootballDirectorPortrait> all = <FootballDirectorPortrait>[
    FootballDirectorPortrait(
      id: '01',
      assetPath: '$_baseAssetPath/01.png',
    ),
    FootballDirectorPortrait(
      id: '02',
      assetPath: '$_baseAssetPath/02.png',
    ),
    FootballDirectorPortrait(
      id: '03',
      assetPath: '$_baseAssetPath/03.png',
    ),
    FootballDirectorPortrait(
      id: '04',
      assetPath: '$_baseAssetPath/04.png',
    ),
    FootballDirectorPortrait(
      id: '05',
      assetPath: '$_baseAssetPath/05.png',
    ),
    FootballDirectorPortrait(
      id: '06',
      assetPath: '$_baseAssetPath/06.png',
    ),
  ];

  static FootballDirectorPortrait? byId(String id) {
    final normalizedId = id.trim();

    for (final portrait in all) {
      if (portrait.id == normalizedId) {
        return portrait;
      }
    }

    return null;
  }

  static bool containsId(String id) {
    return byId(id) != null;
  }

  static String assetOf(String id) {
    final portrait = byId(id);

    if (portrait != null) {
      return portrait.assetPath;
    }

    return all.first.assetPath;
  }
}
