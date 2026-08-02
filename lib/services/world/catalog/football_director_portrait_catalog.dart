class FootballDirectorPortrait {
  final String id;
  final String assetPath;
  final int suggestedAge;

  const FootballDirectorPortrait({
    required this.id,
    required this.assetPath,
    required this.suggestedAge,
  });
}

class FootballDirectorPortraitCatalog {
  static const String _baseAssetPath = 'assets/faces/directors';

  static const int minimumAllowedAge = 28;
  static const int maximumAllowedAge = 35;
  static const int defaultSuggestedAge = 31;

  static const List<FootballDirectorPortrait> all = <FootballDirectorPortrait>[
    FootballDirectorPortrait(
      id: '01',
      assetPath: '$_baseAssetPath/01.png',
      suggestedAge: 31,
    ),
    FootballDirectorPortrait(
      id: '02',
      assetPath: '$_baseAssetPath/02.png',
      suggestedAge: 34,
    ),
    FootballDirectorPortrait(
      id: '03',
      assetPath: '$_baseAssetPath/03.png',
      suggestedAge: 30,
    ),
    FootballDirectorPortrait(
      id: '04',
      assetPath: '$_baseAssetPath/04.png',
      suggestedAge: 33,
    ),
    FootballDirectorPortrait(
      id: '05',
      assetPath: '$_baseAssetPath/05.png',
      suggestedAge: 29,
    ),
    FootballDirectorPortrait(
      id: '06',
      assetPath: '$_baseAssetPath/06.png',
      suggestedAge: 32,
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

  static int suggestedAgeOf(String id) {
    final portrait = byId(id);

    if (portrait != null) {
      return portrait.suggestedAge
          .clamp(
            minimumAllowedAge,
            maximumAllowedAge,
          )
          .toInt();
    }

    return defaultSuggestedAge;
  }

  static bool isAllowedAge(int age) {
    return age >= minimumAllowedAge && age <= maximumAllowedAge;
  }

  static int normalizeAge(
    int age, {
    int fallback = defaultSuggestedAge,
  }) {
    if (isAllowedAge(age)) {
      return age;
    }

    if (isAllowedAge(fallback)) {
      return fallback;
    }

    return defaultSuggestedAge;
  }
}
