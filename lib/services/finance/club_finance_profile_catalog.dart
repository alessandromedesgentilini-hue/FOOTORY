import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class ClubFinanceProfile {
  final int caixa;
  final int operacional;
  final int debt;

  const ClubFinanceProfile({
    required this.caixa,
    required this.operacional,
    required this.debt,
  });
}

class ClubFinanceProfileCatalog {
  const ClubFinanceProfileCatalog._();

  static ClubFinanceProfile byClubId({
    required String clubId,
    required DivisionId division,
  }) {
    return _profiles[clubId] ?? fallbackByDivision(division);
  }

  static ClubFinanceProfile fallbackByDivision(DivisionId div) {
    switch (div) {
      case DivisionId.brA:
        return const ClubFinanceProfile(
          caixa: 60000000,
          operacional: 120000000,
          debt: 180000000,
        );
      case DivisionId.brB:
        return const ClubFinanceProfile(
          caixa: 18000000,
          operacional: 45000000,
          debt: 80000000,
        );
      case DivisionId.brC:
        return const ClubFinanceProfile(
          caixa: 6000000,
          operacional: 18000000,
          debt: 30000000,
        );
      case DivisionId.brD:
        return const ClubFinanceProfile(
          caixa: 2500000,
          operacional: 8000000,
          debt: 10000000,
        );
    }
  }

  static const Map<String, ClubFinanceProfile> _profiles =
      <String, ClubFinanceProfile>{
    // =========================================================
    // Série A
    // =========================================================

    // Atlético Belo Horizonte
    'BRA01': ClubFinanceProfile(
      caixa: 80000000,
      operacional: 160000000,
      debt: 1250000000,
    ),

    // Vila dos Pinheiros
    'BRA02': ClubFinanceProfile(
      caixa: 50000000,
      operacional: 110000000,
      debt: 480000000,
    ),

    // Baiano
    'BRA03': ClubFinanceProfile(
      caixa: 55000000,
      operacional: 130000000,
      debt: 360000000,
    ),

    // João Pereira Souza
    'BRA04': ClubFinanceProfile(
      caixa: 70000000,
      operacional: 150000000,
      debt: 1340000000,
    ),

    // Bragança Paulista
    'BRA05': ClubFinanceProfile(
      caixa: 110000000,
      operacional: 190000000,
      debt: 120000000,
    ),

    // Operários Paulista
    // Gigante quebrado: pouco caixa, operacional apertado e dívida agressiva.
    'BRA06': ClubFinanceProfile(
      caixa: 18000000,
      operacional: 55000000,
      debt: 1800000000,
    ),

    // Rio Criciúma
    'BRA07': ClubFinanceProfile(
      caixa: 22000000,
      operacional: 55000000,
      debt: 130000000,
    ),

    // Celeste BH
    'BRA08': ClubFinanceProfile(
      caixa: 65000000,
      operacional: 140000000,
      debt: 1150000000,
    ),

    // Cuiabano
    'BRA09': ClubFinanceProfile(
      caixa: 28000000,
      operacional: 70000000,
      debt: 70000000,
    ),

    // Rubro Rio
    // Potência financeira: caixa alto, operacional muito forte, dívida controlável.
    'BRA10': ClubFinanceProfile(
      caixa: 260000000,
      operacional: 420000000,
      debt: 280000000,
    ),

    // Vale das Laranjeiras
    'BRA11': ClubFinanceProfile(
      caixa: 90000000,
      operacional: 180000000,
      debt: 9220000000,
    ),

    // Forte Assunção CE
    'BRA12': ClubFinanceProfile(
      caixa: 45000000,
      operacional: 110000000,
      debt: 290000000,
    ),

    // Grêmio Eldorado
    'BRA13': ClubFinanceProfile(
      caixa: 55000000,
      operacional: 130000000,
      debt: 1050000000,
    ),

    // Inter Guaíba
    'BRA14': ClubFinanceProfile(
      caixa: 65000000,
      operacional: 140000000,
      debt: 1100000000,
    ),

    // Verde da Serra
    'BRA15': ClubFinanceProfile(
      caixa: 24000000,
      operacional: 60000000,
      debt: 80000000,
    ),

    // Palestra Itália
    // Potência financeira organizada.
    'BRA16': ClubFinanceProfile(
      caixa: 240000000,
      operacional: 400000000,
      debt: 220000000,
    ),

    // São Vicente
    'BRA17': ClubFinanceProfile(
      caixa: 95000000,
      operacional: 190000000,
      debt: 850000000,
    ),

    // Cruz Maltino
    // Clube grande pressionado por dívida.
    'BRA18': ClubFinanceProfile(
      caixa: 22000000,
      operacional: 50000000,
      debt: 900000000,
    ),

    // Vera Cruz
    'BRA19': ClubFinanceProfile(
      caixa: 30000000,
      operacional: 70000000,
      debt: 120000000,
    ),

    // Atlético Vila Boa
    'BRA20': ClubFinanceProfile(
      caixa: 26000000,
      operacional: 65000000,
      debt: 140000000,
    ),

    // =========================================================
    // Série B
    // =========================================================

    'BRB21': ClubFinanceProfile(
      caixa: 22000000,
      operacional: 52000000,
      debt: 120000000,
    ),
    'BRB22': ClubFinanceProfile(
      caixa: 14000000,
      operacional: 36000000,
      debt: 85000000,
    ),
    'BRB23': ClubFinanceProfile(
      caixa: 12000000,
      operacional: 32000000,
      debt: 70000000,
    ),
    'BRB24': ClubFinanceProfile(
      caixa: 8000000,
      operacional: 24000000,
      debt: 45000000,
    ),
    'BRB25': ClubFinanceProfile(
      caixa: 20000000,
      operacional: 50000000,
      debt: 95000000,
    ),
    'BRB26': ClubFinanceProfile(
      caixa: 14000000,
      operacional: 38000000,
      debt: 65000000,
    ),
    'BRB27': ClubFinanceProfile(
      caixa: 15000000,
      operacional: 40000000,
      debt: 90000000,
    ),
    'BRB28': ClubFinanceProfile(
      caixa: 18000000,
      operacional: 46000000,
      debt: 100000000,
    ),
    'BRB29': ClubFinanceProfile(
      caixa: 10000000,
      operacional: 32000000,
      debt: 55000000,
    ),
    'BRB30': ClubFinanceProfile(
      caixa: 9000000,
      operacional: 30000000,
      debt: 50000000,
    ),
    'BRB31': ClubFinanceProfile(
      caixa: 26000000,
      operacional: 60000000,
      debt: 60000000,
    ),
    'BRB32': ClubFinanceProfile(
      caixa: 16000000,
      operacional: 42000000,
      debt: 75000000,
    ),
    'BRB33': ClubFinanceProfile(
      caixa: 7000000,
      operacional: 25000000,
      debt: 40000000,
    ),
    'BRB34': ClubFinanceProfile(
      caixa: 8500000,
      operacional: 28000000,
      debt: 50000000,
    ),
    'BRB35': ClubFinanceProfile(
      caixa: 11000000,
      operacional: 34000000,
      debt: 65000000,
    ),
    'BRB36': ClubFinanceProfile(
      caixa: 35000000,
      operacional: 75000000,
      debt: 160000000,
    ),
    'BRB37': ClubFinanceProfile(
      caixa: 25000000,
      operacional: 62000000,
      debt: 140000000,
    ),
    'BRB38': ClubFinanceProfile(
      caixa: 7000000,
      operacional: 24000000,
      debt: 30000000,
    ),
    'BRB39': ClubFinanceProfile(
      caixa: 10000000,
      operacional: 32000000,
      debt: 70000000,
    ),
    'BRB40': ClubFinanceProfile(
      caixa: 20000000,
      operacional: 52000000,
      debt: 110000000,
    ),

    // =========================================================
    // Série C
    // =========================================================

    'BRC41': ClubFinanceProfile(
        caixa: 6000000, operacional: 18000000, debt: 35000000),
    'BRC42': ClubFinanceProfile(
        caixa: 7000000, operacional: 20000000, debt: 30000000),
    'BRC43': ClubFinanceProfile(
        caixa: 5000000, operacional: 16000000, debt: 25000000),
    'BRC44': ClubFinanceProfile(
        caixa: 6000000, operacional: 17000000, debt: 28000000),
    'BRC45': ClubFinanceProfile(
        caixa: 6000000, operacional: 18000000, debt: 30000000),
    'BRC46': ClubFinanceProfile(
        caixa: 4500000, operacional: 14000000, debt: 20000000),
    'BRC47': ClubFinanceProfile(
        caixa: 5000000, operacional: 15000000, debt: 24000000),
    'BRC48': ClubFinanceProfile(
        caixa: 8000000, operacional: 22000000, debt: 25000000),
    'BRC49': ClubFinanceProfile(
        caixa: 4000000, operacional: 13000000, debt: 18000000),
    'BRC50': ClubFinanceProfile(
        caixa: 6000000, operacional: 17000000, debt: 30000000),
    'BRC51': ClubFinanceProfile(
        caixa: 7000000, operacional: 19000000, debt: 38000000),
    'BRC52': ClubFinanceProfile(
        caixa: 3000000, operacional: 11000000, debt: 12000000),
    'BRC53': ClubFinanceProfile(
        caixa: 5000000, operacional: 16000000, debt: 26000000),
    'BRC54': ClubFinanceProfile(
        caixa: 3500000, operacional: 12000000, debt: 15000000),
    'BRC55': ClubFinanceProfile(
        caixa: 4000000, operacional: 13000000, debt: 18000000),
    'BRC56': ClubFinanceProfile(
        caixa: 9000000, operacional: 24000000, debt: 20000000),
    'BRC57': ClubFinanceProfile(
        caixa: 5000000, operacional: 15000000, debt: 24000000),
    'BRC58': ClubFinanceProfile(
        caixa: 4500000, operacional: 14000000, debt: 22000000),
    'BRC59': ClubFinanceProfile(
        caixa: 6000000, operacional: 18000000, debt: 28000000),
    'BRC60': ClubFinanceProfile(
        caixa: 3500000, operacional: 12000000, debt: 16000000),

    // =========================================================
    // Série D
    // =========================================================

    'BRD61': ClubFinanceProfile(
        caixa: 3000000, operacional: 9000000, debt: 14000000),
    'BRD62': ClubFinanceProfile(
        caixa: 2200000, operacional: 7000000, debt: 10000000),
    'BRD63':
        ClubFinanceProfile(caixa: 2500000, operacional: 7500000, debt: 9000000),
    'BRD64':
        ClubFinanceProfile(caixa: 1800000, operacional: 6000000, debt: 8000000),
    'BRD65': ClubFinanceProfile(
        caixa: 2200000, operacional: 7000000, debt: 10000000),
    'BRD66':
        ClubFinanceProfile(caixa: 1600000, operacional: 5500000, debt: 7000000),
    'BRD67': ClubFinanceProfile(
        caixa: 2800000, operacional: 8200000, debt: 12000000),
    'BRD68':
        ClubFinanceProfile(caixa: 1800000, operacional: 6000000, debt: 8000000),
    'BRD69': ClubFinanceProfile(
        caixa: 5000000, operacional: 12000000, debt: 10000000),
    'BRD70':
        ClubFinanceProfile(caixa: 2000000, operacional: 6500000, debt: 9000000),
    'BRD71':
        ClubFinanceProfile(caixa: 1800000, operacional: 6000000, debt: 8000000),
    'BRD72': ClubFinanceProfile(
        caixa: 3000000, operacional: 9000000, debt: 13000000),
    'BRD73':
        ClubFinanceProfile(caixa: 1500000, operacional: 5000000, debt: 7000000),
    'BRD74': ClubFinanceProfile(
        caixa: 2500000, operacional: 7500000, debt: 12000000),
    'BRD75':
        ClubFinanceProfile(caixa: 1500000, operacional: 5000000, debt: 6000000),
    'BRD76': ClubFinanceProfile(
        caixa: 2500000, operacional: 7500000, debt: 10000000),
    'BRD77':
        ClubFinanceProfile(caixa: 1800000, operacional: 6000000, debt: 8000000),
    'BRD78': ClubFinanceProfile(
        caixa: 6000000, operacional: 15000000, debt: 18000000),
    'BRD79':
        ClubFinanceProfile(caixa: 2200000, operacional: 7000000, debt: 9000000),
    'BRD80':
        ClubFinanceProfile(caixa: 1200000, operacional: 4500000, debt: 5000000),
  };
}
