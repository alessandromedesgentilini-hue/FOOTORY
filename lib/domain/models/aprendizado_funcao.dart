import '../enums/funcao.dart';

class AprendizadoFuncao {
  final Funcao alvo;
  int progressoJogos; // entrou em campo = +1
  int jogosNecessarios;

  AprendizadoFuncao({
    required this.alvo,
    required this.progressoJogos,
    required this.jogosNecessarios,
  });

  double get pct => jogosNecessarios <= 0
      ? 0
      : (progressoJogos / jogosNecessarios).clamp(0.0, 1.0);

  bool get completo => progressoJogos >= jogosNecessarios;

  Map<String, dynamic> toJson() => {
        'alvo': alvo.key,
        'progresso': progressoJogos,
        'necessarios': jogosNecessarios,
      };

  static AprendizadoFuncao? fromJson(Map<String, dynamic>? m) {
    if (m == null) return null;
    final alvo = FuncaoX.fromKey(m['alvo'] as String);
    if (alvo == null) return null;
    return AprendizadoFuncao(
      alvo: alvo,
      progressoJogos: (m['progresso'] as num).toInt(),
      jogosNecessarios: (m['necessarios'] as num).toInt(),
    );
  }
}
