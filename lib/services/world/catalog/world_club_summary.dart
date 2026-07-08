class WorldClubSummary {
  final String id;
  final String name;

  final String continentId;
  final String continentName;
  final String continentFolder;

  final String countryId;
  final String countryName;
  final String countryFolder;

  final String leagueId;
  final String divisionFolder;
  final String badgeAsset;

  final double basePower;
  final int cpuCoachLevel;
  final int cpuStadiumLevel;

  const WorldClubSummary({
    required this.id,
    required this.name,
    required this.continentId,
    required this.continentName,
    required this.continentFolder,
    required this.countryId,
    required this.countryName,
    required this.countryFolder,
    required this.leagueId,
    required this.divisionFolder,
    required this.badgeAsset,
    required this.basePower,
    required this.cpuCoachLevel,
    required this.cpuStadiumLevel,
  });
}
