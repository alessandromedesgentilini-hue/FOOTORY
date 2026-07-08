class ClubLegacyEntry {
  final String clubId;
  final int totalPoints;
  final int seasons;

  const ClubLegacyEntry({
    required this.clubId,
    required this.totalPoints,
    required this.seasons,
  });

  ClubLegacyEntry copyWith({
    String? clubId,
    int? totalPoints,
    int? seasons,
  }) {
    return ClubLegacyEntry(
      clubId: clubId ?? this.clubId,
      totalPoints: totalPoints ?? this.totalPoints,
      seasons: seasons ?? this.seasons,
    );
  }
}

class ClubLegacyHelper {
  const ClubLegacyHelper._();

  static String label(int points) {
    if (points >= 70) return 'Lenda eterna do clube';
    if (points >= 50) return 'Ídolo histórico';
    if (points >= 35) return 'Nome marcante da era recente';
    if (points >= 22) return 'Figura importante';
    if (points >= 12) return 'Passagem relevante';
    if (points >= 4) return 'Trabalho em construção';
    if (points >= 0) return 'Passagem discreta';
    if (points >= -8) return 'Passagem pressionada';
    return 'Passagem contestada';
  }

  static String shortLabel(int points) {
    if (points >= 70) return 'Lenda';
    if (points >= 50) return 'Ídolo';
    if (points >= 35) return 'Era marcante';
    if (points >= 22) return 'Importante';
    if (points >= 12) return 'Relevante';
    if (points >= 4) return 'Em construção';
    if (points >= 0) return 'Discreto';
    if (points >= -8) return 'Pressionado';
    return 'Contestado';
  }

  static String seasonSummary(int points) {
    if (points >= 14) return 'Campanha lendária';
    if (points >= 10) return 'Campanha histórica';
    if (points >= 6) return 'Grande campanha';
    if (points >= 3) return 'Boa campanha';
    if (points >= 1) return 'Campanha positiva';
    if (points == 0) return 'Campanha dentro do esperado';
    if (points >= -2) return 'Abaixo do esperado';
    if (points >= -4) return 'Campanha ruim';
    return 'Desastre na temporada';
  }

  static String pressureLabel(int points) {
    if (points >= 35) return 'confiança muito alta';
    if (points >= 18) return 'confiança alta';
    if (points >= 8) return 'confiança moderada';
    if (points >= 0) return 'confiança neutra';
    if (points >= -6) return 'pressão crescente';
    return 'pressão forte';
  }

  static String emotionalContext(int points) {
    if (points >= 70) {
      return 'O trabalho já faz parte da história mais importante do clube.';
    }

    if (points >= 50) {
      return 'A passagem já é tratada como uma das mais fortes da história recente.';
    }

    if (points >= 35) {
      return 'O clube começa a construir uma era esportiva reconhecida pela torcida.';
    }

    if (points >= 22) {
      return 'O projeto ganhou respeito e já deixou marcas claras no clube.';
    }

    if (points >= 12) {
      return 'A passagem começa a ter peso positivo na memória recente do clube.';
    }

    if (points >= 4) {
      return 'O trabalho ainda está em construção, mas já apresenta sinais de evolução.';
    }

    if (points >= 0) {
      return 'A passagem ainda é discreta e precisa de campanhas mais fortes para ganhar memória.';
    }

    if (points >= -8) {
      return 'A passagem acumula cobrança e precisa de resposta esportiva.';
    }

    return 'A relação com a torcida e a diretoria está desgastada pela sequência de resultados.';
  }
}
