import 'package:footory26/services/season/season_expectation_snapshot.dart';

/// SeasonCheckpointService (MVP)
///
/// - Gera checkpoint narrativo em rodadas fixas (determinístico).
/// - NÃO mexe em dinheiro agora. Só devolve texto + tag.
/// - GameState chama e guarda o retorno.
/// - UI decide se mostra como modal (bloqueia) ou card/notificação.
///
/// Checkpoints sugeridos:
/// - Rodada 1 (briefing / início)
/// - Rodada 10
/// - Rodada 19
/// - Rodada 29
/// - Rodada max (fim)
class SeasonCheckpointService {
  const SeasonCheckpointService();

  bool isCheckpointRound(int round, {required int maxRound}) {
    if (maxRound <= 0) return false;
    if (round == 1) return true;
    if (round == 10) return true;
    if (round == 19) return true;
    if (round == 29) return true;
    if (round >= maxRound) return true;
    return false;
  }

  SeasonCheckpoint build({
    required int round,
    required int maxRound,
    required int position,
    required int points,
    required SeasonExpectationSnapshot snap,
  }) {
    final phase = _phase(round: round, maxRound: maxRound);
    final zone = _zone(position);
    final eval = _evalFromDelta(snap.delta);

    final title = _title(
      phase: phase,
      eval: eval,
      zone: zone,
    );

    final body = _body(
      phase: phase,
      eval: eval,
      zone: zone,
      position: position,
      points: points,
      snap: snap,
    );

    return SeasonCheckpoint(
      round: round,
      phase: phase.name,
      title: title,
      body: body,
      tag: _tagForEval(eval, zone),
    );
  }

  _Phase _phase({required int round, required int maxRound}) {
    if (round <= 1) return _Phase.preSeason;
    if (round <= 10) return _Phase.early;
    if (round <= 19) return _Phase.firstHalf;
    if (round <= 29) return _Phase.secondHalf;
    if (round >= maxRound) return _Phase.end;
    return _Phase.secondHalf;
  }

  _Zone _zone(int pos) {
    if (pos <= 4) return _Zone.top;
    if (pos <= 8) return _Zone.upper;
    if (pos <= 12) return _Zone.mid;
    if (pos <= 16) return _Zone.lower;
    return _Zone.bottom;
  }

  _Eval _evalFromDelta(int delta) {
    if (delta >= 1) return _Eval.above;
    if (delta <= -1) return _Eval.below;
    return _Eval.onTrack;
  }

  String _title({
    required _Phase phase,
    required _Eval eval,
    required _Zone zone,
  }) {
    if (phase == _Phase.preSeason) {
      return 'Briefing da diretoria';
    }

    if (phase == _Phase.end) {
      if (eval == _Eval.above) return 'Temporada acima do esperado';
      if (eval == _Eval.below) return 'Fim de temporada sob pressão';
      return 'Fim de temporada';
    }

    if (eval == _Eval.above) {
      if (zone == _Zone.top) return 'Campanha empolgante';
      return 'Você está acima do esperado';
    }

    if (eval == _Eval.below) {
      if (zone == _Zone.bottom) return 'Alerta máximo na temporada';
      return 'A pressão aumenta';
    }

    if (zone == _Zone.top) return 'Você está no pelotão da frente';
    if (zone == _Zone.upper) return 'Boa campanha até aqui';
    if (zone == _Zone.bottom) return 'Atenção à parte de baixo';
    return 'Temporada dentro do plano';
  }

  String _body({
    required _Phase phase,
    required _Eval eval,
    required _Zone zone,
    required int position,
    required int points,
    required SeasonExpectationSnapshot snap,
  }) {
    final posTxt = 'Você está em ${position}º lugar com $points pontos.';

    if (phase == _Phase.preSeason) {
      return 'A diretoria definiu a expectativa da temporada como ${snap.expectedLabel}. O objetivo agora é transformar potencial em campanha.';
    }

    if (phase == _Phase.end) {
      if (eval == _Eval.above) {
        return '$posTxt O clube encerra o ano acima da expectativa inicial (${snap.expectedLabel}), fechando a temporada com sensação de progresso real.';
      }

      if (eval == _Eval.below) {
        return '$posTxt O resultado final ficou abaixo da expectativa inicial (${snap.expectedLabel}) e o encerramento da temporada deixa cobrança no ar.';
      }

      return '$posTxt A campanha termina dentro do que era esperado (${snap.expectedLabel}), sem colapso, mas também sem grande salto.';
    }

    if (eval == _Eval.above) {
      if (zone == _Zone.top) {
        return '$posTxt O desempenho supera a expectativa (${snap.expectedLabel}) e o clube entra de vez na briga grande.';
      }

      return '$posTxt A campanha está acima da expectativa (${snap.expectedLabel}) e reforça a sensação de trabalho bem feito.';
    }

    if (eval == _Eval.below) {
      if (zone == _Zone.bottom) {
        return '$posTxt O desempenho está abaixo da expectativa (${snap.expectedLabel}) e a temporada começa a ficar perigosa.';
      }

      return '$posTxt A campanha ficou abaixo da expectativa (${snap.expectedLabel}) e a diretoria espera reação nas próximas rodadas.';
    }

    if (zone == _Zone.top) {
      return '$posTxt A campanha segue dentro do plano e o clube continua forte entre os primeiros.';
    }

    if (zone == _Zone.upper) {
      return '$posTxt O momento é positivo e a temporada segue aberta para voos maiores.';
    }

    if (zone == _Zone.mid) {
      return '$posTxt A campanha segue estável, mas ainda falta uma arrancada que mude o peso da temporada.';
    }

    if (zone == _Zone.lower) {
      return '$posTxt O clube ainda está dentro do plano geral, mas já precisa reagir para não se complicar.';
    }

    return '$posTxt A margem para erro diminui e qualquer tropeço pode empurrar a temporada para um cenário mais pesado.';
  }

  String _tagForEval(_Eval eval, _Zone zone) {
    if (eval == _Eval.above) return 'positive';
    if (eval == _Eval.below) return 'pressure';
    if (zone == _Zone.bottom) return 'warning';
    return 'neutral';
  }
}

class SeasonCheckpoint {
  final int round;
  final String phase;
  final String title;
  final String body;
  final String tag;

  const SeasonCheckpoint({
    required this.round,
    required this.phase,
    required this.title,
    required this.body,
    required this.tag,
  });

  Map<String, dynamic> toJson() => {
        'round': round,
        'phase': phase,
        'title': title,
        'body': body,
        'tag': tag,
      };

  static SeasonCheckpoint fromJson(Map<String, dynamic> json) {
    return SeasonCheckpoint(
      round: ((json['round'] as num?) ?? 1).toInt(),
      phase: (json['phase'] as String?) ?? 'early',
      title: (json['title'] as String?) ?? 'Checkpoint',
      body: (json['body'] as String?) ?? '',
      tag: (json['tag'] as String?) ?? 'neutral',
    );
  }
}

enum _Phase { preSeason, early, firstHalf, secondHalf, end }

enum _Zone { top, upper, mid, lower, bottom }

enum _Eval { above, onTrack, below }
