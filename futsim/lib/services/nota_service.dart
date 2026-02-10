// FutSim – Serviço de Nota de Jogo (Spring 1)
// Calcula FIT (ajuste por grupos) + boosts de estilo + mentais + consistência + encaixe.

import 'dart:math';
import '../models/jogador.dart';
import '../config/balanceamento.dart';

class NotaResultado {
  final double fit; // 1..10 (ajuste por grupos e posição)
  final double notaBase; // antes de mentais/ruído/penalidade
  final double bonusMentais; // ajuste por mentais
  final double sigma; // variância pela consistência
  final double notaFinal; // clamp 4.5..9.5
  NotaResultado({
    required this.fit,
    required this.notaBase,
    required this.bonusMentais,
    required this.sigma,
    required this.notaFinal,
  });
}

class NotaService {
  static double _mediaGrupo(Map<String, int> ats, List<String> chaves) {
    if (chaves.isEmpty) return 1.0;
    double soma = 0.0;
    for (final k in chaves) {
      soma += (ats[k] ?? 1).toDouble();
    }
    return soma / chaves.length; // 1..10
  }

  static Map<Grupo, double> _mediasGrupos(Map<String, int> ats) => {
        Grupo.ofensivo: _mediaGrupo(ats, Grupos.ofensivo),
        Grupo.defensivo: _mediaGrupo(ats, Grupos.defensivo),
        Grupo.tecnico: _mediaGrupo(ats, Grupos.tecnico),
        Grupo.fisico: _mediaGrupo(ats, Grupos.fisico),
        Grupo.mental: _mediaGrupo(ats, Grupos.mental),
      };

  static Map<Grupo, double> _aplicarBoostsGrupo(
      Map<Grupo, double> base, EstiloJogo estilo) {
    final boosts = Balanceamento.boostPorEstilo[estilo]!;
    return base.map((g, v) => MapEntry(g, v * (1.0 + (boosts[g] ?? 0.0))));
  }

  static double _fitPorPosicao(Map<Grupo, double> medias, Posicao p) {
    final w = Balanceamento.pesosPorPosicao[p]!;
    return medias[Grupo.ofensivo]! * w.of +
        medias[Grupo.defensivo]! * w.def +
        medias[Grupo.tecnico]! * w.tec +
        medias[Grupo.fisico]! * w.fis +
        medias[Grupo.mental]! * w.ment; // 1..10
  }

  static double _bonusMentais(Map<String, int> ats) {
    final td = (ats[Atrib.tomadaDecisao] ?? 5).toDouble();
    final lt = (ats[Atrib.leituraTatica] ?? 5).toDouble();
    final fr = (ats[Atrib.frieza] ?? 5).toDouble();
    final ep = (ats[Atrib.espiritoProtagonista] ?? 5).toDouble();
    // pesos leves (total 0.40) → impacto típico ~[-0.08..+0.08]
    return 0.15 * ((td - 5) / 5) +
        0.10 * ((lt - 5) / 5) +
        0.10 * ((fr - 5) / 5) +
        0.05 * ((ep - 5) / 5);
  }

  /// Calcula a nota final (não persiste estado)
  static NotaResultado calcular({
    required Jogador j,
    required Posicao posJogada,
    required EstiloJogo estilo,
    required int consistencia, // 0..10
    double ajusteEncaixe = 0.0, // use Balanceamento.ajusteEncaixeBom/Ruim
    Random? rng,
  }) {
    final ats = j.atributosValidados;

    // Temperos por estilo
    final temp = Balanceamento.temperos[estilo] ?? const {};
    final atsTemperado = Map<String, int>.from(ats);
    temp.forEach((ch, mult) {
      final v = atsTemperado[ch] ?? 1;
      final boosted = (v * (1.0 + mult));
      atsTemperado[ch] = boosted.clamp(1.0, 10.0).round();
    });

    // Médias por grupo + boosts
    final medias = _mediasGrupos(atsTemperado);
    final mediasBoost = _aplicarBoostsGrupo(medias, estilo);

    // FIT pela posição
    final fit = _fitPorPosicao(mediasBoost, posJogada);

    // Base de nota: 6.3 no centro; ~0.3 por ponto de FIT
    final notaBase = 6.3 + 0.30 * (fit - 6.0);

    // Mentais
    final bMentais = _bonusMentais(atsTemperado);

    // Penalidade fora de posição
    final fora = !(posJogada == j.posicaoPrincipal ||
        j.funcoesSecundarias.contains(posJogada));
    final penal = fora ? -0.8 : 0.0;

    // Consistência → ruído
    final sigma = Balanceamento.sigmaPorConsistencia(consistencia);
    final r = rng ?? Random();
    final ruido = r.nextDouble() * 2 * sigma - sigma; // [-sigma, +sigma]

    double nota = notaBase + bMentais + ajusteEncaixe + penal + ruido;
    if (nota < 4.5) nota = 4.5;
    if (nota > 9.5) nota = 9.5;

    return NotaResultado(
      fit: double.parse(fit.toStringAsFixed(2)),
      notaBase: double.parse(notaBase.toStringAsFixed(2)),
      bonusMentais: double.parse(bMentais.toStringAsFixed(2)),
      sigma: double.parse(sigma.toStringAsFixed(2)),
      notaFinal: double.parse(nota.toStringAsFixed(2)),
    );
  }
}
