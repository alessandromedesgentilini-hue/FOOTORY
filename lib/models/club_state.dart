/// Estado do clube do usuário (MVP).
///
/// Filosofia:
/// - É só DADO (estado). Sem lógica pesada.
/// - GameState guarda e atualiza.
/// - Services calculam (expectativa, checkpoints, finanças, etc.).
///
/// Tudo 1..10 (níveis) e poder 1.0..10.0 (double).
class ClubState {
  final String clubId;
  final String clubName;
  final String divisionId; // ex: "BR-A", "BR-B", ...

  /// Nível do treinador (1..10)
  final int coachLevel;

  /// Nível do estádio (1..10)
  final int stadiumLevel;

  /// Força atual do clube para UI (1.0..10.0).
  /// No MVP: calculada do elenco do usuário (média do elenco).
  /// CPU: vem do catálogo.
  final double squadPower10;

  /// Estrelas (0..5) para UI (visual compacta)
  final int stars5;

  /// Nível (0..10) por floor, para referência interna/labels
  final int stars10;

  const ClubState({
    required this.clubId,
    required this.clubName,
    required this.divisionId,
    required this.coachLevel,
    required this.stadiumLevel,
    required this.squadPower10,
    required this.stars5,
    required this.stars10,
  });

  ClubState copyWith({
    String? clubId,
    String? clubName,
    String? divisionId,
    int? coachLevel,
    int? stadiumLevel,
    double? squadPower10,
    int? stars5,
    int? stars10,
  }) {
    return ClubState(
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      divisionId: divisionId ?? this.divisionId,
      coachLevel: coachLevel ?? this.coachLevel,
      stadiumLevel: stadiumLevel ?? this.stadiumLevel,
      squadPower10: squadPower10 ?? this.squadPower10,
      stars5: stars5 ?? this.stars5,
      stars10: stars10 ?? this.stars10,
    );
  }

  Map<String, dynamic> toJson() => {
        'clubId': clubId,
        'clubName': clubName,
        'divisionId': divisionId,
        'coachLevel': coachLevel,
        'stadiumLevel': stadiumLevel,
        'squadPower10': squadPower10,
        'stars5': stars5,
        'stars10': stars10,
      };

  static ClubState fromJson(Map<String, dynamic> json) {
    return ClubState(
      clubId: (json['clubId'] as String?) ?? '',
      clubName: (json['clubName'] as String?) ?? '',
      divisionId: (json['divisionId'] as String?) ?? 'BR-D',
      coachLevel: ((json['coachLevel'] as num?) ?? 4).toInt().clamp(1, 10),
      stadiumLevel: ((json['stadiumLevel'] as num?) ?? 5).toInt().clamp(1, 10),
      squadPower10: ((json['squadPower10'] as num?) ?? 4.5).toDouble(),
      stars5: ((json['stars5'] as num?) ?? 2).toInt().clamp(0, 5),
      stars10: ((json['stars10'] as num?) ?? 4).toInt().clamp(0, 10),
    );
  }
}
