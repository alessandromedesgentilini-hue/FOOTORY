/// Catálogo oficial de clubes (offline-first).
///
/// - Mantém a verdade dos clubes por divisão.
/// - Guarda força base (1.0..10.0) que depois pode virar “média do elenco”.
/// - Define defaults de CPU (coach/stadium) para o MVP.
///
/// Importante:
/// - “Tupinambá” fica na Série B.
/// - Na Série C, “Manchester Catarinense” entra como clube oficial.
/// - “20 Novembro” é um clube fictício e pode ser um pouco mais forte.
/// - Na Série D, “Santa Maria” substitui o antigo “Araraguara-SP”.
///
/// Nota:
/// - `cpuCoachLevel` e `cpuStadiumLevel` são usados pela simulação.
/// - As estruturas completas do clube ficam em `club_structures_catalog.dart`.
library;

enum DivisionId {
  brA,
  brB,
  brC,
  brD,
}

extension DivisionIdAssetFolder on DivisionId {
  String get assetFolder {
    switch (this) {
      case DivisionId.brA:
        return 'league_a';
      case DivisionId.brB:
        return 'league_b';
      case DivisionId.brC:
        return 'league_c';
      case DivisionId.brD:
        return 'league_d';
    }
  }
}

class ClubEntry {
  final String id;
  final String name;
  final DivisionId division;

  /// Nome técnico do arquivo PNG do escudo, sem ".png".
  ///
  /// Use apenas quando o nome bonito do clube não bater 100% com o nome do asset.
  /// Exemplo:
  /// name: 'Bragança Paulista'
  /// badgeFileName: 'braganca_paulista'
  ///
  /// Se ficar null, o sistema usa automaticamente o slug do nome.
  final String? badgeFileName;

  /// Força base do clube (1.0..10.0).
  /// No MVP, isso dirige o motor de partida (para CPU, via catálogo).
  /// No futuro, pode ser substituído por “média do elenco” / “power curve”.
  final double basePower;

  /// CPU default (MVP)
  final int cpuCoachLevel; // 1..10
  final int cpuStadiumLevel; // 1..10

  const ClubEntry({
    required this.id,
    required this.name,
    required this.division,
    required this.basePower,
    required this.cpuCoachLevel,
    required this.cpuStadiumLevel,
    this.badgeFileName,
  });

  String get badgeAsset {
    final fileName = badgeFileName ?? BrazilClubCatalog.slug(name);
    return 'assets/clubs/world/south_america/brazil/${division.assetFolder}/$fileName.png';
  }
}

class BrazilClubCatalog {
  const BrazilClubCatalog._();

  static String slug(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Faixas aprovadas:
  /// A: 6.0..8.0
  /// B: 5.5..6.5
  /// C: 4.5..6.0
  /// D: 3.5..5.5
  static List<ClubEntry> all() => List.unmodifiable(_all);

  /// Retorna a lista da divisão de forma estável (ordenada por id)
  static List<ClubEntry> byDivision(DivisionId div) {
    final list = _all.where((c) => c.division == div).toList(growable: false);
    list.sort((a, b) => a.id.compareTo(b.id));
    return List.unmodifiable(list);
  }

  static ClubEntry? byId(String id) {
    for (final c in _all) {
      if (c.id == id) return c;
    }
    return null;
  }

  static const List<ClubEntry> _all = [
    // =========================
    // Série A (1–20) 6.0..8.0
    // =========================
    ClubEntry(
      id: 'BRA01',
      name: 'Atlético Belo Horizonte',
      division: DivisionId.brA,
      basePower: 7.4,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 6,
    ),
    ClubEntry(
      id: 'BRA02',
      name: 'Vila dos Pinheiros',
      division: DivisionId.brA,
      basePower: 7.0,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 5,
    ),
    ClubEntry(
      id: 'BRA03',
      name: 'Baiano',
      division: DivisionId.brA,
      basePower: 7.1,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 5,
    ),
    ClubEntry(
      id: 'BRA04',
      name: 'João Pereira Souza',
      division: DivisionId.brA,
      basePower: 7.2,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 5,
    ),
    ClubEntry(
      id: 'BRA05',
      name: 'Bragança Paulista',
      division: DivisionId.brA,
      basePower: 6.8,
      cpuCoachLevel: 5,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRA06',
      name: 'Operários Paulista',
      division: DivisionId.brA,
      basePower: 7.3,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
      badgeFileName: 'operarios_paulistas',
    ),
    ClubEntry(
      id: 'BRA07',
      name: 'Rio Criciúma',
      division: DivisionId.brA,
      basePower: 6.3,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRA08',
      name: 'Celeste BH',
      division: DivisionId.brA,
      basePower: 7.5,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 6,
      badgeFileName: 'celeste_bh',
    ),
    ClubEntry(
      id: 'BRA09',
      name: 'Cuiabano',
      division: DivisionId.brA,
      basePower: 6.4,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRA10',
      name: 'Rubro Rio',
      division: DivisionId.brA,
      basePower: 8.0,
      cpuCoachLevel: 8,
      cpuStadiumLevel: 7,
    ),
    ClubEntry(
      id: 'BRA11',
      name: 'Vale das Laranjeiras',
      division: DivisionId.brA,
      basePower: 7.3,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 6,
    ),
    ClubEntry(
      id: 'BRA12',
      name: 'Forte Assunção CE',
      division: DivisionId.brA,
      basePower: 6.9,
      cpuCoachLevel: 5,
      cpuStadiumLevel: 5,
      badgeFileName: 'forte_assuncao',
    ),
    ClubEntry(
      id: 'BRA13',
      name: 'Grêmio Eldorado',
      division: DivisionId.brA,
      basePower: 7.3,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 7,
    ),
    ClubEntry(
      id: 'BRA14',
      name: 'Inter Guaíba',
      division: DivisionId.brA,
      basePower: 7.3,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 7,
    ),
    ClubEntry(
      id: 'BRA15',
      name: 'Verde da Serra',
      division: DivisionId.brA,
      basePower: 6.2,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRA16',
      name: 'Palestra Itália',
      division: DivisionId.brA,
      basePower: 7.9,
      cpuCoachLevel: 8,
      cpuStadiumLevel: 7,
    ),
    ClubEntry(
      id: 'BRA17',
      name: 'São Vicente',
      division: DivisionId.brA,
      basePower: 7.5,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    ClubEntry(
      id: 'BRA18',
      name: 'Cruz Maltino',
      division: DivisionId.brA,
      basePower: 7.1,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 6,
    ),
    ClubEntry(
      id: 'BRA19',
      name: 'Vera Cruz',
      division: DivisionId.brA,
      basePower: 6.5,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRA20',
      name: 'Atlético Vila Boa',
      division: DivisionId.brA,
      basePower: 6.0,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 4,
    ),

    // =========================
    // Série B (21–40) 5.5..6.5
    // =========================
    ClubEntry(
      id: 'BRB21',
      name: 'Cidade de Minas',
      division: DivisionId.brB,
      basePower: 6.2,
      cpuCoachLevel: 5,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRB22',
      name: 'Independência da Ilha',
      division: DivisionId.brB,
      basePower: 5.8,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRB23',
      name: 'Vila Tibério',
      division: DivisionId.brB,
      basePower: 5.7,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRB24',
      name: 'São Luiz Gonzaga',
      division: DivisionId.brB,
      basePower: 5.6,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRB25',
      name: 'Cearense',
      division: DivisionId.brB,
      basePower: 6.0,
      cpuCoachLevel: 5,
      cpuStadiumLevel: 5,
    ),
    ClubEntry(
      id: 'BRB26',
      name: 'Chapecó',
      division: DivisionId.brB,
      basePower: 5.9,
      cpuCoachLevel: 5,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRB27',
      name: 'Alagoas',
      division: DivisionId.brB,
      basePower: 6.0,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRB28',
      name: 'Goiano',
      division: DivisionId.brB,
      basePower: 6.1,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRB29',
      name: 'Il Guarany',
      division: DivisionId.brB,
      basePower: 5.8,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 5,
    ),
    ClubEntry(
      id: 'BRB30',
      name: 'Atlético Sorocaba',
      division: DivisionId.brB,
      basePower: 5.7,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRB31',
      name: 'Tupinambá',
      division: DivisionId.brB,
      basePower: 6.1,
      cpuCoachLevel: 5,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRB32',
      name: 'Novo Horizonte',
      division: DivisionId.brB,
      basePower: 6.0,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRB33',
      name: 'Proletário PR',
      division: DivisionId.brB,
      basePower: 5.8,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRB34',
      name: 'Papão',
      division: DivisionId.brB,
      basePower: 5.7,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRB35',
      name: 'Ponte da Fumaça',
      division: DivisionId.brB,
      basePower: 5.8,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 5,
    ),
    ClubEntry(
      id: 'BRB36',
      name: 'Vila Santos',
      division: DivisionId.brB,
      basePower: 6.4,
      cpuCoachLevel: 6,
      cpuStadiumLevel: 6,
    ),
    ClubEntry(
      id: 'BRB37',
      name: 'Recife',
      division: DivisionId.brB,
      basePower: 6.3,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 5,
    ),
    ClubEntry(
      id: 'BRB38',
      name: 'Tombo Minas',
      division: DivisionId.brB,
      basePower: 5.6,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRB39',
      name: 'Vila Goiás',
      division: DivisionId.brB,
      basePower: 5.9,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRB40',
      name: 'Curitiba',
      division: DivisionId.brB,
      basePower: 6.1,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 5,
    ),

    // =========================
    // Série C (41–60) 4.5..6.0
    // =========================
    ClubEntry(
      id: 'BRC41',
      name: 'Rio Grande do Norte',
      division: DivisionId.brC,
      basePower: 5.6,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC42',
      name: 'Amazonas Norte',
      division: DivisionId.brC,
      basePower: 5.4,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRC43',
      name: 'Aparecida Goiás',
      division: DivisionId.brC,
      basePower: 5.2,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC44',
      name: 'João Pessoa',
      division: DivisionId.brC,
      basePower: 5.3,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC45',
      name: 'Real Alagoano',
      division: DivisionId.brC,
      basePower: 5.4,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC46',
      name: 'Manchester Catarinense',
      division: DivisionId.brC,
      basePower: 5.2,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRC47',
      name: 'Ferrim Ceará',
      division: DivisionId.brC,
      basePower: 5.1,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC48',
      name: 'Velha Figueira',
      division: DivisionId.brC,
      basePower: 5.0,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 4,
    ),
    ClubEntry(
      id: 'BRC49',
      name: 'Florestal',
      division: DivisionId.brC,
      basePower: 4.9,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC50',
      name: 'Londrinense',
      division: DivisionId.brC,
      basePower: 5.2,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC51',
      name: 'Capibaribe',
      division: DivisionId.brC,
      basePower: 5.1,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRC52',
      name: 'Rio Grande 1900',
      division: DivisionId.brC,
      basePower: 4.6,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRC53',
      name: 'Bernardo',
      division: DivisionId.brC,
      basePower: 5.4,
      cpuCoachLevel: 1,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC54',
      name: 'Real Zeca',
      division: DivisionId.brC,
      basePower: 4.9,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRC55',
      name: 'Roraima',
      division: DivisionId.brC,
      basePower: 4.8,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC56',
      name: '20 Novembro',
      division: DivisionId.brC,
      basePower: 5.8,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRC57',
      name: 'Arraial Rio',
      division: DivisionId.brC,
      basePower: 5.2,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRC58',
      name: 'Erechim',
      division: DivisionId.brC,
      basePower: 5.0,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRC59',
      name: 'Rio Negro',
      division: DivisionId.brC,
      basePower: 5.3,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRC60',
      name: 'São José dos Altos',
      division: DivisionId.brC,
      basePower: 4.8,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),

    // =========================
    // Série D (61–80) 3.5..5.5
    // =========================
    ClubEntry(
      id: 'BRD61',
      name: 'Caxiense',
      division: DivisionId.brD,
      basePower: 4.8,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRD62',
      name: 'Caruaruense',
      division: DivisionId.brD,
      basePower: 4.4,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD63',
      name: 'Santa Maria',
      division: DivisionId.brD,
      basePower: 4.6,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD64',
      name: 'Águia Branca',
      division: DivisionId.brD,
      basePower: 4.2,
      cpuCoachLevel: 1,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD65',
      name: 'Governador Valadares',
      division: DivisionId.brD,
      basePower: 4.5,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD66',
      name: 'Uniclinic',
      division: DivisionId.brD,
      basePower: 4.0,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD67',
      name: 'Paranaense',
      division: DivisionId.brD,
      basePower: 4.7,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD68',
      name: 'Campina',
      division: DivisionId.brD,
      basePower: 4.1,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD69',
      name: 'Nova Amsterdã',
      division: DivisionId.brD,
      basePower: 4.9,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 3,
    ),
    ClubEntry(
      id: 'BRD70',
      name: 'São Luís',
      division: DivisionId.brD,
      basePower: 4.3,
      cpuCoachLevel: 1,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD71',
      name: 'Feira',
      division: DivisionId.brD,
      basePower: 4.2,
      cpuCoachLevel: 1,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD72',
      name: 'Desportos',
      division: DivisionId.brD,
      basePower: 4.8,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRD73',
      name: 'Juazeiro do Norte',
      division: DivisionId.brD,
      basePower: 4.0,
      cpuCoachLevel: 1,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD74',
      name: 'Camaragibe',
      division: DivisionId.brD,
      basePower: 4.1,
      cpuCoachLevel: 4,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRD75',
      name: 'Ingazeira',
      division: DivisionId.brD,
      basePower: 3.9,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRD76',
      name: 'Caldas',
      division: DivisionId.brD,
      basePower: 4.6,
      cpuCoachLevel: 2,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD77',
      name: 'Maracapá',
      division: DivisionId.brD,
      basePower: 4.2,
      cpuCoachLevel: 1,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD78',
      name: 'Brasília Capital',
      division: DivisionId.brD,
      basePower: 5.2,
      cpuCoachLevel: 3,
      cpuStadiumLevel: 2,
    ),
    ClubEntry(
      id: 'BRD79',
      name: 'Nacional Manaus',
      division: DivisionId.brD,
      basePower: 4.4,
      cpuCoachLevel: 1,
      cpuStadiumLevel: 1,
    ),
    ClubEntry(
      id: 'BRD80',
      name: '1920',
      division: DivisionId.brD,
      basePower: 3.8,
      cpuCoachLevel: 1,
      cpuStadiumLevel: 1,
    ),
  ];
}
