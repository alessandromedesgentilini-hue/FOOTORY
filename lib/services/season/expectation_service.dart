/// ExpectationService
///
/// - Define “o que a diretoria espera” baseado na força do clube vs a liga.
/// - 100% determinístico e simples (MVP friendly).
///
/// Como usar:
/// - Você passa o power do clube (1..10) e o power médio da liga (1..10).
/// - E passa a divisão ("BR-A", "BR-B", etc.) só pra texto.
///
/// Retorna um pacote que a UI pode mostrar e que o Checkpoint pode usar.
class ExpectationService {
  const ExpectationService();

  ClubExpectation evaluate({
    required String divisionId,
    required double clubPower10,
    required double leagueAvgPower10,
  }) {
    final d = (clubPower10 - leagueAvgPower10);

    // thresholds bem “pé no chão”:
    // 0.60+ acima da média => candidato forte a topo
    // 0.20..0.59 => parte de cima
    // -0.19..0.19 => meio
    // -0.59..-0.20 => parte de baixo
    // <= -0.60 => luta pra não cair
    if (d >= 0.60) {
      return ClubExpectation(
        tier: ExpectationTier.titleOrAccess,
        title: _titleForTop(divisionId),
        short: 'Diretoria espera brigar no topo.',
      );
    }
    if (d >= 0.20) {
      return ClubExpectation(
        tier: ExpectationTier.upperTable,
        title: _titleForUpper(divisionId),
        short: 'Diretoria espera parte de cima.',
      );
    }
    if (d > -0.20) {
      return const ClubExpectation(
        tier: ExpectationTier.midTable,
        title: 'Meio de tabela',
        short: 'Diretoria espera campanha segura.',
      );
    }
    if (d > -0.60) {
      return const ClubExpectation(
        tier: ExpectationTier.lowerTable,
        title: 'Parte de baixo',
        short: 'Diretoria quer distância do Z4.',
      );
    }

    return const ClubExpectation(
      tier: ExpectationTier.avoidRelegation,
      title: 'Evitar rebaixamento',
      short: 'Diretoria quer sobreviver.',
    );
  }

  String _titleForTop(String divisionId) {
    // Série A: topo = título
    // B/C/D: topo = acesso
    if (divisionId.trim().toUpperCase() == 'BR-A') return 'Brigar pelo título';
    return 'Brigar pelo acesso';
  }

  String _titleForUpper(String divisionId) {
    if (divisionId.trim().toUpperCase() == 'BR-A') return 'Brigar por Top 4';
    return 'Brigar por Top 4 (acesso)';
  }
}

enum ExpectationTier {
  titleOrAccess,
  upperTable,
  midTable,
  lowerTable,
  avoidRelegation,
}

class ClubExpectation {
  final ExpectationTier tier;
  final String title; // ex: “Brigar pelo acesso”
  final String short; // 1 linha

  const ClubExpectation({
    required this.tier,
    required this.title,
    required this.short,
  });

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'title': title,
        'short': short,
      };

  static ClubExpectation fromJson(Map<String, dynamic> json) {
    final tierName = (json['tier'] as String?) ?? ExpectationTier.midTable.name;
    final tier = ExpectationTier.values.firstWhere((e) => e.name == tierName,
        orElse: () => ExpectationTier.midTable);

    return ClubExpectation(
      tier: tier,
      title: (json['title'] as String?) ?? 'Meio de tabela',
      short: (json['short'] as String?) ?? 'Diretoria espera campanha segura.',
    );
  }
}
