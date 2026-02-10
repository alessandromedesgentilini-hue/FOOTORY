class Contrato {
  /// Sempre termina em 31/12 (regra canônica)
  final DateTime fim;
  final int anos; // 1..3
  final bool formacao; // base até 2026

  Contrato({
    required this.fim,
    required this.anos,
    required this.formacao,
  });

  Map<String, dynamic> toJson() => {
        'fim': fim.toIso8601String(),
        'anos': anos,
        'formacao': formacao,
      };

  static Contrato fromJson(Map<String, dynamic> m) {
    return Contrato(
      fim: DateTime.parse(m['fim'] as String),
      anos: (m['anos'] as num).toInt(),
      formacao: (m['formacao'] as bool?) ?? false,
    );
  }
}
