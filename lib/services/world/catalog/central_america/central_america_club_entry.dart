class CentralAmericaClubEntry {
  final String id;
  final String name;

  final String countryId;
  final String countryName;
  final String countryFolder;

  final String leagueId;
  final String divisionFolder;

  /// Nome técnico do arquivo PNG do escudo, sem ".png".
  final String badgeFileName;

  /// Força base do clube (1.0..10.0).
  final double basePower;

  final int cpuCoachLevel;
  final int cpuStadiumLevel;

  const CentralAmericaClubEntry({
    required this.id,
    required this.name,
    required this.countryId,
    required this.countryName,
    required this.countryFolder,
    required this.leagueId,
    required this.divisionFolder,
    required this.badgeFileName,
    required this.basePower,
    required this.cpuCoachLevel,
    required this.cpuStadiumLevel,
  });

  String get badgeAsset {
    return 'assets/clubs/world/central_america/$countryFolder/$divisionFolder/$badgeFileName.png';
  }
}
