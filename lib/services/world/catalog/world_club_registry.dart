import 'africa/africa_club_catalog.dart';
import 'asia/asia_club_catalog.dart';
import 'central_america/central_america_club_catalog.dart';
import 'europe/europe_club_catalog.dart';
import 'north_america/north_america_club_catalog.dart';
import 'oceania/oceania_club_catalog.dart';
import 'south_america/south_america_club_catalog.dart';
import 'world_club_summary.dart';

class WorldClubRegistry {
  const WorldClubRegistry._();

  static List<WorldClubSummary> southAmericaInternationalOnly() {
    return List.unmodifiable(
      SouthAmericaClubCatalog.internationalOnly().map(
        (club) {
          return WorldClubSummary(
            id: club.id,
            name: club.name,
            continentId: 'SOUTH_AMERICA',
            continentName: 'América do Sul',
            continentFolder: 'south_america',
            countryId: club.countryId,
            countryName: club.countryName,
            countryFolder: club.countryFolder,
            leagueId: club.leagueId,
            divisionFolder: club.divisionFolder,
            badgeAsset: club.badgeAsset,
            basePower: club.basePower,
            cpuCoachLevel: club.cpuCoachLevel,
            cpuStadiumLevel: club.cpuStadiumLevel,
          );
        },
      ),
    );
  }

  static List<WorldClubSummary> europe() {
    return List.unmodifiable(
      EuropeClubCatalog.all().map(
        (club) {
          return WorldClubSummary(
            id: club.id,
            name: club.name,
            continentId: 'EUROPE',
            continentName: 'Europa',
            continentFolder: 'europe',
            countryId: club.countryId,
            countryName: club.countryName,
            countryFolder: club.countryFolder,
            leagueId: club.leagueId,
            divisionFolder: club.divisionFolder,
            badgeAsset: club.badgeAsset,
            basePower: club.basePower,
            cpuCoachLevel: club.cpuCoachLevel,
            cpuStadiumLevel: club.cpuStadiumLevel,
          );
        },
      ),
    );
  }

  static List<WorldClubSummary> asia() {
    return List.unmodifiable(
      AsiaClubCatalog.all().map(
        (club) {
          return WorldClubSummary(
            id: club.id,
            name: club.name,
            continentId: 'ASIA',
            continentName: 'Ásia',
            continentFolder: 'asia',
            countryId: club.countryId,
            countryName: club.countryName,
            countryFolder: club.countryFolder,
            leagueId: club.leagueId,
            divisionFolder: club.divisionFolder,
            badgeAsset: club.badgeAsset,
            basePower: club.basePower,
            cpuCoachLevel: club.cpuCoachLevel,
            cpuStadiumLevel: club.cpuStadiumLevel,
          );
        },
      ),
    );
  }

  static List<WorldClubSummary> africa() {
    return List.unmodifiable(
      AfricaClubCatalog.all().map(
        (club) {
          return WorldClubSummary(
            id: club.id,
            name: club.name,
            continentId: 'AFRICA',
            continentName: 'África',
            continentFolder: 'africa',
            countryId: club.countryId,
            countryName: club.countryName,
            countryFolder: club.countryFolder,
            leagueId: club.leagueId,
            divisionFolder: club.divisionFolder,
            badgeAsset: club.badgeAsset,
            basePower: club.basePower,
            cpuCoachLevel: club.cpuCoachLevel,
            cpuStadiumLevel: club.cpuStadiumLevel,
          );
        },
      ),
    );
  }

  static List<WorldClubSummary> northAmerica() {
    return List.unmodifiable(
      NorthAmericaClubCatalog.all().map(
        (club) {
          return WorldClubSummary(
            id: club.id,
            name: club.name,
            continentId: 'NORTH_AMERICA',
            continentName: 'América do Norte',
            continentFolder: 'north_america',
            countryId: club.countryId,
            countryName: club.countryName,
            countryFolder: club.countryFolder,
            leagueId: club.leagueId,
            divisionFolder: club.divisionFolder,
            badgeAsset: club.badgeAsset,
            basePower: club.basePower,
            cpuCoachLevel: club.cpuCoachLevel,
            cpuStadiumLevel: club.cpuStadiumLevel,
          );
        },
      ),
    );
  }

  static List<WorldClubSummary> centralAmerica() {
    return List.unmodifiable(
      CentralAmericaClubCatalog.all().map(
        (club) {
          return WorldClubSummary(
            id: club.id,
            name: club.name,
            continentId: 'CENTRAL_AMERICA',
            continentName: 'América Central',
            continentFolder: 'central_america',
            countryId: club.countryId,
            countryName: club.countryName,
            countryFolder: club.countryFolder,
            leagueId: club.leagueId,
            divisionFolder: club.divisionFolder,
            badgeAsset: club.badgeAsset,
            basePower: club.basePower,
            cpuCoachLevel: club.cpuCoachLevel,
            cpuStadiumLevel: club.cpuStadiumLevel,
          );
        },
      ),
    );
  }

  static List<WorldClubSummary> oceania() {
    return List.unmodifiable(
      OceaniaClubCatalog.all().map(
        (club) {
          return WorldClubSummary(
            id: club.id,
            name: club.name,
            continentId: 'OCEANIA',
            continentName: 'Oceania',
            continentFolder: 'oceania',
            countryId: club.countryId,
            countryName: club.countryName,
            countryFolder: club.countryFolder,
            leagueId: club.leagueId,
            divisionFolder: club.divisionFolder,
            badgeAsset: club.badgeAsset,
            basePower: club.basePower,
            cpuCoachLevel: club.cpuCoachLevel,
            cpuStadiumLevel: club.cpuStadiumLevel,
          );
        },
      ),
    );
  }

  static List<WorldClubSummary> allOutsideSouthAmerica() {
    return List.unmodifiable([
      ...europe(),
      ...asia(),
      ...africa(),
      ...northAmerica(),
      ...centralAmerica(),
      ...oceania(),
    ]);
  }

  static List<WorldClubSummary> allInternational() {
    return List.unmodifiable([
      ...southAmericaInternationalOnly(),
      ...allOutsideSouthAmerica(),
    ]);
  }

  static WorldClubSummary? byId(String id) {
    final target = id.trim();

    if (target.isEmpty) return null;

    for (final club in allInternational()) {
      if (club.id == target) return club;
    }

    return null;
  }

  static List<WorldClubSummary> byContinent(String continentId) {
    final target = continentId.trim().toUpperCase();

    return List.unmodifiable(
      allInternational().where((club) => club.continentId == target),
    );
  }

  static List<WorldClubSummary> byCountry(String countryId) {
    final target = countryId.trim().toUpperCase();

    return List.unmodifiable(
      allInternational().where((club) => club.countryId == target),
    );
  }
}
