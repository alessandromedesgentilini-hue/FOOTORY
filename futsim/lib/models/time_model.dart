// lib/models/time_model.dart
import 'jogador.dart';
import 'estilos.dart';

// Limites de nível
const int kNivelMin = 1;
const int kNivelMax = 5;

class TimeModel {
  // ── Identidade/estado básico ────────────────────────────────────────────────
  final String id; // pode ser 'auto' em seeds/MVP
  final String nome;
  List<Jogador> elenco;
  int pontos;

  // Estilo/variação por temporada
  Estilo estiloAtual; // escolhido no início da temporada
  VariacaoTatica variacao; // pode mudar jogo a jogo (def/equ/of)
  int _nivelExecucao; // 1..5 (força do time pra executar o estilo)

  // Consistência por manter o mesmo estilo
  int _temporadasMesmoEstilo; // conta temporadas consecutivas
  final List<Estilo> historicoEstilos;

  // ── Ctor ────────────────────────────────────────────────────────────────────
  TimeModel({
    this.id = 'auto',
    required this.nome,
    required this.elenco,
    this.pontos = 0,
    Estilo? estiloAtual, // mantém o nome p/ compat com seeds & world
    this.variacao = VariacaoTatica.equilibrado,
    int nivelExecucao = 3,
    int temporadasMesmoEstilo = 1,
    List<Estilo>? historicoEstilos,
  })  : estiloAtual = estiloAtual ?? Estilo.posse,
        _nivelExecucao = _clampNivel(nivelExecucao),
        _temporadasMesmoEstilo =
            temporadasMesmoEstilo < 1 ? 1 : temporadasMesmoEstilo,
        historicoEstilos =
            (historicoEstilos == null || historicoEstilos.isEmpty)
                ? <Estilo>[estiloAtual ?? Estilo.posse]
                : List<Estilo>.from(historicoEstilos);

  /// Factory de conveniência pra criar time “vazio” rápido
  factory TimeModel.basico({
    String id = 'auto',
    required String nome,
    Estilo? estilo,
    VariacaoTatica variacao = VariacaoTatica.equilibrado,
    int nivelExecucao = 3,
  }) {
    return TimeModel(
      id: id,
      nome: nome,
      elenco: <Jogador>[],
      estiloAtual: estilo ?? Estilo.posse,
      variacao: variacao,
      nivelExecucao: nivelExecucao,
    );
  }

  // ── Getters/Setters seguros ────────────────────────────────────────────────
  int get nivelExecucao => _nivelExecucao; // 1..5
  set nivelExecucao(int v) => _nivelExecucao = _clampNivel(v);

  int get temporadasMesmoEstilo => _temporadasMesmoEstilo;

  // Bônus cumulativo por consistência (teto ~8%).
  double bonusConsistenciaPct() {
    final t = _temporadasMesmoEstilo;
    if (t <= 0) return 0.0;
    if (t <= 3) return t * 1.0; // 1..3%
    if (t <= 6) return 3 + (t - 3) * 1.0; // 4..6%
    if (t <= 10) return 6 + (t - 6) * 0.5; // 6.5..8%
    return 8.0;
  }

  int get bonusConsistenciaInt => bonusConsistenciaPct().round();

  // ── Operações de temporada ─────────────────────────────────────────────────
  void definirEstiloParaTemporada(Estilo novo) {
    if (historicoEstilos.isEmpty || historicoEstilos.last != novo) {
      estiloAtual = novo;
      variacao = VariacaoTatica.equilibrado; // default ao trocar
    }
  }

  void fecharTemporadaEAtualizarConsistencia() {
    if (historicoEstilos.isEmpty) {
      historicoEstilos.add(estiloAtual);
      _temporadasMesmoEstilo = 1;
      return;
    }
    final ultimo = historicoEstilos.last;
    historicoEstilos.add(estiloAtual);
    _temporadasMesmoEstilo =
        (ultimo == estiloAtual) ? (_temporadasMesmoEstilo + 1) : 1;
  }

  void definirVariacao(VariacaoTatica nova) {
    variacao = nova;
  }

  // ── Efetividade tática ─────────────────────────────────────────────────────
  /// Aceita 1 ou 2 posicionais (compat com chamadas antigas).
  int efetividadeContra(Estilo adversario, [int nivelAdversario = 3]) {
    return eficaciaEfetiva(
      meu: estiloAtual,
      meuNivel: _nivelExecucao,
      variacao: variacao,
      adversario: adversario,
      nivelAdversario: nivelAdversario,
      bonusContinuidadePct: bonusConsistenciaInt,
    );
  }

  int efetividadeContraTime(TimeModel adv) {
    return eficaciaEfetiva(
      meu: estiloAtual,
      meuNivel: _nivelExecucao,
      variacao: variacao,
      adversario: adv.estiloAtual,
      nivelAdversario: adv.nivelExecucao,
      bonusContinuidadePct: bonusConsistenciaInt,
    );
  }

  // ── Utilidades de elenco (MVP) ─────────────────────────────────────────────
  void adicionarJogador(Jogador j) => elenco.add(j);

  bool removerJogadorPorId(String jogadorId) {
    final idx = elenco.indexWhere((j) => j.id == jogadorId);
    if (idx >= 0) {
      elenco.removeAt(idx);
      return true;
    }
    return false;
  }

  @override
  String toString() =>
      'TimeModel($nome, estilo=${estiloAtual.label}, nivel=$_nivelExecucao, var=$variacao, bonus=${bonusConsistenciaInt}%)';
}

// ── Helpers internos ─────────────────────────────────────────────────────────
int _clampNivel(int v) {
  if (v < kNivelMin) return kNivelMin;
  if (v > kNivelMax) return kNivelMax;
  return v;
}

// ── Shim (placeholder) para o motor tático real ──────────────────────────────
int eficaciaEfetiva({
  required Estilo meu,
  required int meuNivel,
  required VariacaoTatica variacao,
  required Estilo adversario,
  required int nivelAdversario,
  int bonusContinuidadePct = 0,
}) {
  const int base = 45;
  int ajusteVariacao = 0;
  switch (variacao) {
    case VariacaoTatica.defensiva:
      ajusteVariacao = -2;
      break;
    case VariacaoTatica.equilibrado:
      ajusteVariacao = 0;
      break;
    case VariacaoTatica.ofensiva:
      ajusteVariacao = 2;
      break;
  }

  final int total =
      base + (meuNivel * 4) + ajusteVariacao + (bonusContinuidadePct ~/ 2);

  if (total < 25) return 25;
  if (total > 95) return 95;
  return total;
}
