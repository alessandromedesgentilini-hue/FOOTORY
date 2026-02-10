import '../models/jogador.dart';

enum Lado { D, E, AMBOS }

class RosterSpec {
  final int tamanhoExato;
  final int gkMin;
  final int gkMax;
  final int zagueirosMin;
  final int volantesMin;
  final int meiasMin; // MC + MEI
  final int pontasMin;
  final int atacantesMin; // SA + ATA

  const RosterSpec({
    required this.tamanhoExato,
    required this.gkMin,
    required this.gkMax,
    required this.zagueirosMin,
    required this.volantesMin,
    required this.meiasMin,
    required this.pontasMin,
    required this.atacantesMin,
  });

  factory RosterSpec.brasilSerieA() => const RosterSpec(
        tamanhoExato: 25,
        gkMin: 2,
        gkMax: 3,
        zagueirosMin: 4,
        volantesMin: 3,
        meiasMin: 4,
        pontasMin: 3,
        atacantesMin: 2,
      );
}

class RosterValidator {
  static List<String> validar({
    required List<String> ids,
    required Map<String, Jogador> catalogo,
    Map<String, Lado>? ladoPorId,
    RosterSpec? spec,
  }) {
    final s = spec ?? RosterSpec.brasilSerieA();
    final erros = <String>[];

    if (ids.length != s.tamanhoExato) {
      erros.add(
          'Elenco com ${ids.length} jogadores (esperado: ${s.tamanhoExato}).');
    }

    int gk = 0, zag = 0, vol = 0, mc = 0, mei = 0, pon = 0, sa = 0, ata = 0;
    int latD = 0, latE = 0;

    for (final id in ids) {
      final j = catalogo[id];
      if (j == null) continue;
      switch (j.posicaoPrincipal) {
        case Posicao.GOL:
          gk++;
          break;
        case Posicao.ZAG:
          zag++;
          break;
        case Posicao.LAT:
          final lado = (ladoPorId ?? const <String, Lado>{})[id] ?? Lado.AMBOS;
          if (lado == Lado.D || lado == Lado.AMBOS) latD++;
          if (lado == Lado.E || lado == Lado.AMBOS) latE++;
          break;
        case Posicao.VOL:
          vol++;
          break;
        case Posicao.MC:
          mc++;
          break;
        case Posicao.MEI:
          mei++;
          break;
        case Posicao.PON:
          pon++;
          break;
        case Posicao.SA:
          sa++;
          break;
        case Posicao.ATA:
          ata++;
          break;
      }
    }

    if (gk < s.gkMin || gk > s.gkMax) {
      erros.add('Goleiros: $gk (esperado entre ${s.gkMin} e ${s.gkMax}).');
    }
    if (zag < s.zagueirosMin)
      erros.add('Zagueiros: $zag (mínimo ${s.zagueirosMin}).');
    if (vol < s.volantesMin)
      erros.add('Volantes: $vol (mínimo ${s.volantesMin}).');
    if (mc + mei < s.meiasMin)
      erros.add('Meias (MC+MEI): ${mc + mei} (mínimo ${s.meiasMin}).');
    if (pon < s.pontasMin) erros.add('Pontas: $pon (mínimo ${s.pontasMin}).');
    if (sa + ata < s.atacantesMin)
      erros.add('Atacantes (SA+ATA): ${sa + ata} (mínimo ${s.atacantesMin}).');

    if (latD < 2)
      erros.add('Laterais direitos: $latD (precisa de pelo menos 2).');
    if (latE < 2)
      erros.add('Laterais esquerdos: $latE (precisa de pelo menos 2).');

    for (final id in ids) {
      if (!catalogo.containsKey(id))
        erros.add('ID não encontrado no catálogo: $id');
    }

    return erros;
  }
}
