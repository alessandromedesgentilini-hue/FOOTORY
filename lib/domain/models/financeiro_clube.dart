// lib/domain/models/financeiro_clube.dart
//
// Modelo financeiro mínimo do clube (MVP).
// Domínio puro: sem dependência de UI.
//
// Responsabilidades:
// - Guardar caixa e dívida
// - Serializar (save/load)
// - Helpers simples para movimentação (opcional, mas útil)
//
// Observação: regras (repasse, premiação, etc) ficam em services.
// Aqui é só estado + operações básicas.

class FinanceiroClube {
  double caixa; // dinheiro disponível
  double divida; // dívida total

  FinanceiroClube({
    required this.caixa,
    required this.divida,
  });

  // =========================================================
  // HELPERS (MVP)
  // =========================================================

  /// Adiciona dinheiro ao caixa
  void adicionarCaixa(double valor) {
    if (valor <= 0) return;
    caixa += valor;
  }

  /// Remove dinheiro do caixa (não deixa negativo)
  /// Retorna quanto conseguiu pagar de fato.
  double removerCaixa(double valor) {
    if (valor <= 0) return 0;
    final pago = valor > caixa ? caixa : valor;
    caixa -= pago;
    return pago;
  }

  /// Aumenta dívida
  void adicionarDivida(double valor) {
    if (valor <= 0) return;
    divida += valor;
  }

  /// Paga dívida usando caixa (não deixa negativo)
  /// Retorna quanto amortizou.
  double pagarDivida(double valor) {
    if (valor <= 0) return 0;
    if (divida <= 0) return 0;

    final alvo = valor > divida ? divida : valor;
    final pago = removerCaixa(alvo);
    divida -= pago;

    if (divida < 0) divida = 0;
    return pago;
  }

  // =========================================================
  // SAVE / LOAD
  // =========================================================

  Map<String, dynamic> toJson() => {
        'caixa': caixa,
        'divida': divida,
      };

  static FinanceiroClube fromJson(Map<String, dynamic> m) {
    return FinanceiroClube(
      caixa: ((m['caixa'] as num?) ?? 0).toDouble(),
      divida: ((m['divida'] as num?) ?? 0).toDouble(),
    );
  }
}
