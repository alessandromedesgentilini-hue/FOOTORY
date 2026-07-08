import 'package:footory26/services/team_power_service.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
import 'package:footory26/services/season/season_expectation_snapshot.dart';

/// SeasonExpectationService (MVP)
///
/// Band (0..4):
/// 0 = Título / topo
/// 1 = G4 / acesso / competições continentais
/// 2 = Meio de tabela
/// 3 = Parte de baixo
/// 4 = Z4 / rebaixamento
///
/// Regra principal:
/// - A expectativa inicial da temporada deve ser congelada DENTRO da temporada.
/// - Ao mudar de temporada/divisão, a expectativa inicial deve ser recalculada.
/// - A régua principal é força relativa dentro da divisão atual.
/// - Melhorar o time durante a temporada é mérito do usuário, não obrigação retroativa.
class SeasonExpectationService {
  const SeasonExpectationService();

  int bandFromPosition(int position) {
    final p = position.clamp(1, 20);

    if (p <= 4) return 0;
    if (p <= 8) return 1;
    if (p <= 12) return 2;
    if (p <= 16) return 3;
    return 4;
  }

  int expectedBandFromDivisionPowers({
    required List<double> divisionPowers,
    required double targetPower,
  }) {
    if (divisionPowers.isEmpty) return 2;

    final tp = _clamp10(targetPower);

    final powers = divisionPowers.map(_clamp10).toList()
      ..sort((a, b) => b.compareTo(a));

    int rank = 1;
    bool foundClose = false;

    for (int i = 0; i < powers.length; i++) {
      if ((powers[i] - tp).abs() < 0.0001) {
        rank = i + 1;
        foundClose = true;
        break;
      }
    }

    if (!foundClose) {
      int better = 0;
      for (final p in powers) {
        if (p > tp) better++;
      }
      rank = better + 1;
    }

    return bandFromPosition(rank.clamp(1, 20));
  }

  String bandLabel({
    required DivisionId division,
    required int band,
  }) {
    final b = band.clamp(0, 4);

    final secondBandLabel = division == DivisionId.brA
        ? 'Briga na Parte Alta'
        : 'Briga pelo Acesso';

    switch (b) {
      case 0:
        return 'Briga pelo Título';
      case 1:
        return secondBandLabel;
      case 2:
        return 'Meio de Tabela';
      case 3:
        return 'Parte de Baixo';
      case 4:
      default:
        return 'Zona de Rebaixamento';
    }
  }

  String statusLabelFromDelta(int delta) {
    if (delta >= 2) return 'Muito acima do esperado';
    if (delta == 1) return 'Acima do esperado';
    if (delta == 0) return 'Dentro do esperado';
    if (delta == -1) return 'Abaixo do esperado';
    return 'Muito abaixo do esperado';
  }

  int currentBandFromPosition(int position) {
    return bandFromPosition(position);
  }

  int delta({
    required int expectedBand,
    required int currentBand,
  }) {
    return expectedBand.clamp(0, 4) - currentBand.clamp(0, 4);
  }

  SeasonExpectationSnapshot buildSnapshot({
    required DivisionId division,
    required List<double> divisionPowers,
    required double userPower10,
    required int userTablePosition,
    TeamPowerService teamPowerService = const TeamPowerService(),
    SeasonExpectationSnapshot? previous,
  }) {
    final power = _clamp10(userPower10);

    final dynamicExpectedBand = expectedBandFromDivisionPowers(
      divisionPowers: divisionPowers,
      targetPower: power,
    );

    final currentBand = currentBandFromPosition(userTablePosition.clamp(1, 20));

    final canReuseInitialExpectation =
        previous != null && previous.division == division;

    final initialExpectedBand = canReuseInitialExpectation
        ? previous.initialExpectedBand
        : dynamicExpectedBand;

    final initialExpectedLabel = canReuseInitialExpectation
        ? previous.initialExpectedLabel
        : bandLabel(
            division: division,
            band: initialExpectedBand,
          );

    final initialUserPower10 =
        canReuseInitialExpectation ? previous.initialUserPower10 : power;

    final d = delta(
      expectedBand: initialExpectedBand,
      currentBand: currentBand,
    );

    final userStars10 = teamPowerService.stars10FromRating(power);
    final userStars5 = teamPowerService.stars5FromStars10(userStars10);

    final expectedLabel = bandLabel(
      division: division,
      band: dynamicExpectedBand,
    );

    final currentLabel = bandLabel(
      division: division,
      band: currentBand,
    );

    final statusLabel = statusLabelFromDelta(d);

    return SeasonExpectationSnapshot(
      division: division,
      userPower10: power,
      initialUserPower10: initialUserPower10,
      userStars10: userStars10,
      userStars5: userStars5,
      initialExpectedBand: initialExpectedBand,
      initialExpectedLabel: initialExpectedLabel,
      expectedBand: dynamicExpectedBand,
      currentBand: currentBand,
      expectedLabel: expectedLabel,
      currentLabel: currentLabel,
      statusLabel: statusLabel,
      delta: d,
    );
  }

  double _clamp10(double v) {
    if (v.isNaN || v.isInfinite) return 1.0;
    if (v < 1.0) return 1.0;
    if (v > 10.0) return 10.0;
    return v;
  }
}
