// lib/models/time_model.dart
//
// Modelo de clube no FutSim.
// - Contém informações básicas (id, nome, estilo).
// - Gerencia elenco de jogadores.
// - Permite serializar/deserializar dados para salvar/recuperar estado.
//
// ✅ MVP ATUAL:
// - Jogador possui:
//    • ovrCheio (10..100)  -> soma dos 10 atributos da função
//    • estrelas (1..10)   -> média (arredondada .5)
//
// ⚠️ IMPORTANTE:
// - NÃO assume existência de ovrMedia10 no Jogador
// - TimeModel deriva tudo a partir do que já existe

import 'jogador.dart';
import 'estilos.dart';

class TimeModel {
  final String id; // Ex.: RUB-001
  final String nome; // Ex.: Rubro Rio
  final Estilo estilo; // Enum do estilo tático principal
  final int maxEstrangeiros;
  final List<Jogador> elenco;

  /// Resolver de nacionalidade do jogador (ISO3 como 'BRA', 'ARG', etc).
  /// Usado apenas para regras de inscrição.
  final String Function(Jogador) getNacionalidade;

  TimeModel({
    required this.id,
    required this.nome,
    required this.estilo,
    List<Jogador>? elenco,
    this.maxEstrangeiros = 9,
    String Function(Jogador)? getNacionalidade,
  })  : elenco = elenco ?? [],
        getNacionalidade = getNacionalidade ?? ((_) => 'BRA');

  // =========================================================
  // Getters gerais
  // =========================================================

  int get totalJogadores => elenco.length;

  /// ✅ OVR médio do time em escala 1..10 (derivado de estrelas)
  double get ovrMedio10 {
    if (elenco.isEmpty) return 0.0;
    final total = elenco.fold<double>(0.0, (sum, j) => sum + j.estrelas);
    return total / elenco.length;
  }

  /// ✅ OVR médio do time em escala 10..100
  double get ovrMedioCheio {
    if (elenco.isEmpty) return 0.0;
    final total = elenco.fold<int>(0, (sum, j) => sum + j.ovrCheio);
    return total / elenco.length;
  }

  /// 🔁 Compatibilidade com código antigo
  double get ovrMedio => ovrMedio10;

  /// Retorna todos os goleiros do elenco.
  List<Jogador> get goleiros =>
      elenco.where((j) => j.pos.toUpperCase() == 'GOL').toList();

  /// Retorna jogadores de linha.
  List<Jogador> get jogadoresDeLinha =>
      elenco.where((j) => j.pos.toUpperCase() != 'GOL').toList();

  /// Quantidade de estrangeiros no elenco.
  int get totalEstrangeiros =>
      elenco.where((j) => getNacionalidade(j).toUpperCase() != 'BRA').length;

  bool get temExcessoEstrangeiros => totalEstrangeiros > maxEstrangeiros;

  // =========================================================
  // Manipulação de elenco
  // =========================================================

  void adicionarJogador(Jogador jogador) {
    if (!elenco.any((j) => j.id == jogador.id)) {
      elenco.add(jogador);
    }
  }

  void removerJogador(String jogadorId) {
    elenco.removeWhere((j) => j.id == jogadorId);
  }

  void atualizarJogador(Jogador jogador) {
    final idx = elenco.indexWhere((j) => j.id == jogador.id);
    if (idx >= 0) {
      elenco[idx] = jogador;
    }
  }

  void limparElenco() => elenco.clear();

  // =========================================================
  // Serialização
  // =========================================================

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'estilo': estilo.slug,
        'maxEstrangeiros': maxEstrangeiros,
        'elenco': elenco.map((j) => j.toJson()).toList(),
      };

  factory TimeModel.fromJson(Map<String, dynamic> json) {
    return TimeModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      estilo: EstiloX.fromString(json['estilo'] as String),
      maxEstrangeiros: json['maxEstrangeiros'] as int? ?? 9,
      elenco: (json['elenco'] as List<dynamic>?)
              ?.map((e) => Jogador.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      '$nome (OVR ${ovrMedio10.toStringAsFixed(1)} | ${ovrMedioCheio.toStringAsFixed(0)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
