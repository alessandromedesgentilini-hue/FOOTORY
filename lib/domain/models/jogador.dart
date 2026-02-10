import '../data/funcoes_map.dart';
import '../enums/atributo.dart';
import '../enums/funcao.dart';
import 'aprendizado_funcao.dart';
import 'contrato.dart';

class Jogador {
  final String id;
  String nome;

  int idade; // anos
  String nacionalidade;

  /// Funções já habilitadas (sem penalidade).
  final Set<Funcao> funcoesHabilitadas;

  /// Atributos base (1..10) - inclui os GK, mas podem estar “travados” dependendo do tipo.
  final Map<Atributo, int> atributos;

  /// XP acumulado (100 = 1 ponto manual)
  int xpAcumulado;

  /// Aprendizado ativo (1 por vez no MVP)
  AprendizadoFuncao? aprendizado;

  /// Clube atual (id do clube)
  String clubeId;

  /// Contrato atual
  Contrato contrato;

  /// Estado simples (MVP)
  bool lesionado;
  DateTime? lesionadoAte;
  bool suspenso;
  int suspensoPorJogos;

  Jogador({
    required this.id,
    required this.nome,
    required this.idade,
    required this.nacionalidade,
    required Set<Funcao> funcoesHabilitadas,
    required Map<Atributo, int> atributos,
    required this.xpAcumulado,
    required this.clubeId,
    required this.contrato,
    this.aprendizado,
    this.lesionado = false,
    this.lesionadoAte,
    this.suspenso = false,
    this.suspensoPorJogos = 0,
  })  : funcoesHabilitadas = {...funcoesHabilitadas},
        atributos = {...atributos};

  // -------------------------
  // OVR (A3)
  // -------------------------
  int ovrDaFuncao(Funcao f) {
    final keys = atributosPorFuncao[f]!;
    var soma = 0;
    for (final a in keys) {
      soma += (atributos[a] ?? 1).clamp(1, 10);
    }
    return soma.clamp(10, 100);
  }

  Funcao funcaoPrincipal({Funcao? principalAtual}) {
    // maior OVR entre habilitadas
    Funcao? melhor = principalAtual;
    var melhorOvr = melhor != null ? ovrDaFuncao(melhor) : -1;

    for (final f in funcoesHabilitadas) {
      final o = ovrDaFuncao(f);
      if (o > melhorOvr) {
        melhor = f;
        melhorOvr = o;
      }
    }
    // empate mantém a atual (se existir); senão pega qualquer habilitada
    return melhor ?? funcoesHabilitadas.first;
  }

  int ovrPrincipal({Funcao? principalAtual}) {
    final f = funcaoPrincipal(principalAtual: principalAtual);
    return ovrDaFuncao(f);
  }

  // -------------------------
  // In-game penalty (A3)
  // -------------------------
  /// Retorna os 10 atributos efetivos da função em campo, já aplicando penalidade se não habilitada.
  Map<Atributo, int> atributosEfetivosEmJogo({
    required Funcao funcaoEmCampo,
    required double fatorPenalidade, // 0.75 padrão, ou 0.70 se decidir
  }) {
    final keys = atributosPorFuncao[funcaoEmCampo]!;
    final habilitada = funcoesHabilitadas.contains(funcaoEmCampo);

    final out = <Atributo, int>{};
    for (final a in keys) {
      final base = (atributos[a] ?? 1).clamp(1, 10);
      if (habilitada) {
        out[a] = base;
      } else {
        final v = (base * fatorPenalidade);
        final arred = v.round().clamp(1, 10);
        out[a] = arred;
      }
    }
    return out;
  }

  int ovrEfetivoEmJogo({
    required Funcao funcaoEmCampo,
    required double fatorPenalidade,
  }) {
    final eff = atributosEfetivosEmJogo(
      funcaoEmCampo: funcaoEmCampo,
      fatorPenalidade: fatorPenalidade,
    );
    var soma = 0;
    for (final v in eff.values) {
      soma += v;
    }
    return soma.clamp(10, 100);
  }

  // -------------------------
  // Aprendizado (A4)
  // -------------------------
  static int jogosNecessariosParaNFuncao(int n) {
    // 2ª = 20, 3ª = 40, 4ª = 80, 5ª = 160...
    // n = total de funções habilitadas após aprender
    if (n <= 1) return 0;
    final exp = n - 2;
    return 20 * (1 << exp);
  }

  void iniciarAprendizado(Funcao alvo) {
    final nFuturo = funcoesHabilitadas.length + 1;
    aprendizado = AprendizadoFuncao(
      alvo: alvo,
      progressoJogos: 0,
      jogosNecessarios: jogosNecessariosParaNFuncao(nFuturo),
    );
  }

  /// Chamado quando “entrou em campo” (qualquer minuto conta).
  void registrarEntradaEmCampoParaAprendizado() {
    final ap = aprendizado;
    if (ap == null) return;
    ap.progressoJogos += 1;
    if (ap.completo) {
      funcoesHabilitadas.add(ap.alvo);
      aprendizado = null;
    }
  }

  // -------------------------
  // XP e evolução (A5)
  // -------------------------
  void addXp(int xp) {
    xpAcumulado += xp;
    if (xpAcumulado < 0) xpAcumulado = 0;
  }

  int get pontosDisponiveis => xpAcumulado ~/ 100;

  void gastarPontoEm(Atributo a) {
    if (pontosDisponiveis <= 0) return;
    final atual = (atributos[a] ?? 1).clamp(1, 10);
    if (atual >= 10) return;

    atributos[a] = atual + 1;
    xpAcumulado -= 100;
    if (xpAcumulado < 0) xpAcumulado = 0;
  }

  // -------------------------
  // Serialização (Hive/JSON)
  // -------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'idade': idade,
      'nacionalidade': nacionalidade,
      'clubeId': clubeId,
      'contrato': contrato.toJson(),
      'xp': xpAcumulado,
      'funcoes': funcoesHabilitadas.map((f) => f.key).toList(),
      'atributos': {
        for (final e in atributos.entries) e.key.key: e.value,
      },
      'aprendizado': aprendizado?.toJson(),
      'lesionado': lesionado,
      'lesionadoAte': lesionadoAte?.toIso8601String(),
      'suspenso': suspenso,
      'suspensoPorJogos': suspensoPorJogos,
    };
  }

  static Jogador fromJson(Map<String, dynamic> m) {
    final funcoesRaw = (m['funcoes'] as List<dynamic>? ?? const []);
    final funcoes = <Funcao>{};
    for (final x in funcoesRaw) {
      final f = FuncaoX.fromKey(x as String);
      if (f != null) funcoes.add(f);
    }

    final attrsRaw = (m['atributos'] as Map<String, dynamic>? ?? const {});
    final attrs = <Atributo, int>{};
    for (final e in attrsRaw.entries) {
      final a = AtributoX.fromKey(e.key);
      if (a != null) {
        attrs[a] = (e.value as num).toInt();
      }
    }

    return Jogador(
      id: m['id'] as String,
      nome: m['nome'] as String,
      idade: (m['idade'] as num).toInt(),
      nacionalidade: (m['nacionalidade'] as String?) ?? 'BR',
      clubeId: (m['clubeId'] as String?) ?? 'unknown',
      contrato: Contrato.fromJson(m['contrato'] as Map<String, dynamic>),
      xpAcumulado: (m['xp'] as num?)?.toInt() ?? 0,
      funcoesHabilitadas: funcoes.isEmpty ? {Funcao.meioCentro} : funcoes,
      atributos: attrs,
      aprendizado: AprendizadoFuncao.fromJson(
        m['aprendizado'] as Map<String, dynamic>?,
      ),
      lesionado: (m['lesionado'] as bool?) ?? false,
      lesionadoAte: (m['lesionadoAte'] as String?) != null
          ? DateTime.parse(m['lesionadoAte'] as String)
          : null,
      suspenso: (m['suspenso'] as bool?) ?? false,
      suspensoPorJogos: (m['suspensoPorJogos'] as num?)?.toInt() ?? 0,
    );
  }
}
