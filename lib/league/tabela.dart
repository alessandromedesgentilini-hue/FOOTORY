// lib/league/tabela.dart
//
// Tabela de classificação com atualização incremental a partir dos resultados
// das partidas. Inclui getters “apelidos” (pts, j, v, e, d, gp, gc, saldo)
// para compat com telas/dev utilities.
//
// Versão final (robusta e extensível):
// • API compatível com a versão anterior (LinhaTabela.aplica, Tabela.registra/linhasOrdenadas)
// • Critérios de desempate configuráveis e estáveis (pontos, vitórias, saldo, gols pró, menos derrotas, menos gols contra, nome)
// • Suporte a deduções de pontos por time (sanções administrativas)
// • Snapshot com posição 1-based para logs e telas (classificacaoComPos)
// • Helpers de reset/merge e serialização leve para depuração
//
// Observação: “confronto direto” não está implementado aqui pois exige
// armazenar/consultar a malha completa de confrontos. Caso você queira, podemos
// evoluir com uma estrutura de head-to-head por grupos empatados.

import '../models/time_model.dart';
import '../sim/simulador.dart';

/// Critérios de desempate suportados (em ordem de prioridade).
enum Tiebreaker {
  pontos, // maior
  vitorias, // maior
  saldo, // maior
  golsPro, // maior
  menosDerrotas, // menor
  menosGolsContra, // menor
  nome, // A-Z (estável e deterministic)
}

class LinhaTabela {
  final TimeModel time;

  int pontos = 0;
  int vitorias = 0;
  int empates = 0;
  int derrotas = 0;
  int golsPro = 0;
  int golsContra = 0;

  /// Deduções administrativas (ex.: punições). Valor pode ser negativo.
  /// Esse campo é somado ao total de pontos *após* partidas.
  int deducaoPontos = 0;

  LinhaTabela(this.time);

  // ---- Derivados / aliases (compat com logs/telas) ----
  int get saldo => golsPro - golsContra;

  int get pts => pontos + deducaoPontos;
  int get v => vitorias;
  int get e => empates;
  int get d => derrotas;
  int get gp => golsPro;
  int get gc => golsContra;
  int get j => vitorias + empates + derrotas;

  /// Aplica o resultado desta partida à linha deste time.
  void aplica(ResultadoPartida r) {
    final souMandante = identical(r.mandante, time);
    final gf = souMandante ? r.golsMandante : r.golsVisitante;
    final ga = souMandante ? r.golsVisitante : r.golsMandante;

    golsPro += gf;
    golsContra += ga;

    if (gf > ga) {
      vitorias += 1;
      pontos += 3;
    } else if (gf == ga) {
      empates += 1;
      pontos += 1;
    } else {
      derrotas += 1;
    }
  }

  /// Aplica uma dedução direta ao total (ex.: -3 pontos).
  void aplicarDeducao(int delta) {
    deducaoPontos += delta;
  }

  @override
  String toString() =>
      '${time.nome}: $pts pts, J:$j V:$v E:$e D:$d GP:$gp GC:$gc SG:$saldo'
      '${deducaoPontos != 0 ? ' (inclui dedução $deducaoPontos)' : ''}';

  Map<String, dynamic> toJson() => {
        'time': time.nome,
        'pts': pts,
        'j': j,
        'v': v,
        'e': e,
        'd': d,
        'gp': gp,
        'gc': gc,
        'sg': saldo,
        'deducao': deducaoPontos,
      };
}

class Tabela {
  final Map<TimeModel, LinhaTabela> _linhas = {};
  final List<Tiebreaker> criterios;

  /// Construtor com critérios padrão do projeto:
  /// pontos, vitórias, saldo, gols pró. (desempates adicionais estáveis)
  Tabela({
    List<Tiebreaker>? criterios,
  }) : criterios = criterios ??
            const [
              Tiebreaker.pontos,
              Tiebreaker.vitorias,
              Tiebreaker.saldo,
              Tiebreaker.golsPro,
              // Extras para estabilidade:
              Tiebreaker.menosDerrotas,
              Tiebreaker.menosGolsContra,
              Tiebreaker.nome,
            ];

  /// Linhas ordenadas pelos [criterios] configurados.
  List<LinhaTabela> get linhasOrdenadas {
    final ls = _linhas.values.toList();

    int cmp(LinhaTabela a, LinhaTabela b) {
      for (final c in criterios) {
        int d = 0;
        switch (c) {
          case Tiebreaker.pontos:
            d = b.pts.compareTo(a.pts);
            break;
          case Tiebreaker.vitorias:
            d = b.v.compareTo(a.v);
            break;
          case Tiebreaker.saldo:
            d = b.saldo.compareTo(a.saldo);
            break;
          case Tiebreaker.golsPro:
            d = b.gp.compareTo(a.gp);
            break;
          case Tiebreaker.menosDerrotas:
            d = a.d.compareTo(b.d);
            break;
          case Tiebreaker.menosGolsContra:
            d = a.gc.compareTo(b.gc);
            break;
          case Tiebreaker.nome:
            d = a.time.nome.compareTo(b.time.nome);
            break;
        }
        if (d != 0) return d;
      }
      return 0;
    }

    ls.sort(cmp);
    return ls;
  }

  /// Registra um resultado (atualiza as duas linhas).
  void registra(ResultadoPartida r) {
    _linha(r.mandante).aplica(r);
    _linha(r.visitante).aplica(r);
  }

  /// Registra vários resultados em sequência.
  void registraTodos(Iterable<ResultadoPartida> resultados) {
    for (final r in resultados) {
      registra(r);
    }
  }

  /// Aplica dedução de pontos a um time (valor pode ser negativo).
  void aplicarDeducao(TimeModel t, int delta) {
    _linha(t).aplicarDeducao(delta);
  }

  /// Retorna (ou cria) a linha para o time.
  LinhaTabela linha(TimeModel t) => _linha(t);

  LinhaTabela _linha(TimeModel t) =>
      _linhas.putIfAbsent(t, () => LinhaTabela(t));

  /// Snapshot da classificação com posição (1-based).
  /// Útil para logs/relatórios rápidos.
  List<({int pos, LinhaTabela row})> classificacaoComPos() {
    final ord = linhasOrdenadas;
    final out = <({int pos, LinhaTabela row})>[];
    for (var i = 0; i < ord.length; i++) {
      out.add((pos: i + 1, row: ord[i]));
    }
    return out;
  }

  /// Remove todos os dados (mantém a configuração de critérios).
  void reset() => _linhas.clear();

  /// Mescla outra tabela (soma estatísticas por time).
  /// Útil para consolidar fases (ex.: fase 1 + fase 2).
  void mergeFrom(Tabela other) {
    for (final lt in other._linhas.values) {
      final dst = _linha(lt.time);
      dst.pontos += lt.pontos;
      dst.vitorias += lt.vitorias;
      dst.empates += lt.empates;
      dst.derrotas += lt.derrotas;
      dst.golsPro += lt.golsPro;
      dst.golsContra += lt.golsContra;
      dst.deducaoPontos += lt.deducaoPontos;
    }
  }

  /// Serialização leve (debug).
  List<Map<String, dynamic>> toJsonList() =>
      linhasOrdenadas.map((e) => e.toJson()).toList();
}
