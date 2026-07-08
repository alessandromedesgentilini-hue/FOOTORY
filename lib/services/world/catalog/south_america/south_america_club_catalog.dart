import 'argentina_club_catalog.dart';
import 'bolivia_club_catalog.dart';
import 'chile_club_catalog.dart';
import 'colombia_club_catalog.dart';
import 'ecuador_club_catalog.dart';
import 'paraguay_club_catalog.dart';
import 'peru_club_catalog.dart';
import 'south_america_club_entry.dart';
import 'uruguay_club_catalog.dart';
import 'venezuela_club_catalog.dart';

class SouthAmericaClubCatalog {
  const SouthAmericaClubCatalog._();

  /// Clubes internacionais sul-americanos já prontos para competições.
  ///
  /// Brasil fica fora daqui por enquanto porque já possui catálogo próprio,
  /// divisões nacionais, Copa Brasileira, tabela e regras especiais.
  static List<SouthAmericaClubEntry> internationalOnly() {
    return List.unmodifiable([
      ...ArgentinaClubCatalog.all(),
      ...UruguayClubCatalog.all(),
      ...ChileClubCatalog.all(),
      ...ColombiaClubCatalog.all(),
      ...EcuadorClubCatalog.all(),
      ...ParaguayClubCatalog.all(),
      ...BoliviaClubCatalog.all(),
      ...PeruClubCatalog.all(),
      ...VenezuelaClubCatalog.all(),
    ]);
  }

  /// Classificados internacionais fixos para a Taça Simón Bolívar no MVP.
  ///
  /// Total internacional atual: 27 clubes.
  /// Com Brasil adicionando 5 vagas depois, fecha 32 clubes.
  static List<SouthAmericaClubEntry> simonBolivarInternationalQualified() {
    return List.unmodifiable([
      ...ArgentinaClubCatalog.simonBolivarQualified(),
      ...UruguayClubCatalog.simonBolivarQualified(),
      ...ChileClubCatalog.simonBolivarQualified(),
      ...ColombiaClubCatalog.simonBolivarQualified(),
      ...EcuadorClubCatalog.simonBolivarQualified(),
      ...ParaguayClubCatalog.simonBolivarQualified(),
      ...BoliviaClubCatalog.simonBolivarQualified(),
      ...PeruClubCatalog.simonBolivarQualified(),
      ...VenezuelaClubCatalog.simonBolivarQualified(),
    ]);
  }

  static SouthAmericaClubEntry? byId(String id) {
    final target = id.trim();

    if (target.isEmpty) return null;

    for (final club in internationalOnly()) {
      if (club.id == target) return club;
    }

    return null;
  }

  static List<SouthAmericaClubEntry> byCountry(String countryId) {
    final target = countryId.trim().toUpperCase();

    return List.unmodifiable(
      internationalOnly().where((club) => club.countryId == target),
    );
  }
}
