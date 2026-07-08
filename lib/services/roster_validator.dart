// lib/services/roster_validator.dart
import '../models/jogador.dart';

/// Valida composição mínima de elenco, mapeando cada jogador
/// para **uma única** categoria (evita dupla contagem).
class RosterValidator {
  final List<Jogador> elenco;
  RosterValidator(this.elenco);

  // --------- tags canônicos (const para evitar realocação) ---------
  static const List<String> _tagsGK = ['GOL', 'GK', 'GOLE'];
  static const List<String> _tagsLAT = [
    'LD',
    'LE',
    'RB',
    'LB',
    'LAT',
    'LAD',
    'LAE',
    'FB',
    'RWB',
    'LWB'
  ];
  static const List<String> _tagsZAG = ['ZAG', 'ZC', 'CB'];
  static const List<String> _tagsVOL = ['VOL', 'DM', 'CDM'];
  static const List<String> _tagsMEIA = [
    'MC',
    'MEI',
    'AM',
    'CM',
    'CAM',
    'LM',
    'RM',
    'MEIA'
  ];
  static const List<String> _tagsPONTA = [
    'PD',
    'PE',
    'PON',
    'EXT',
    'ALA',
    'RW',
    'LW'
  ];
  static const List<String> _tagsSegundoAt = ['SA', 'SS', 'SP', 'SEGUNDO'];
  static const List<String> _tagsCA = ['CA', 'ST', 'CF', 'N9', '9'];

  // --------- helpers de leitura/normalização ---------
  String _key(Jogador j) => (j.pos).toUpperCase().trim();

  bool _hasAny(String s, List<String> tags) {
    final n = s.toUpperCase();
    return tags.any((t) => n.contains(t.toUpperCase()));
  }

  // --------- classificação única por precedência ---------
  // Ordem importa: a primeira que casar define a categoria do jogador.
  _Cat _classificar(Jogador j) {
    final k = _key(j);

    // 1) Goleiro
    if (_hasAny(k, _tagsGK)) return _Cat.gk;

    // 2) Laterais (inclui alas)
    if (_hasAny(k, _tagsLAT)) return _Cat.lateral;

    // 3) Zagueiros (se vier genérico "DEF" e não bateu lateral, cai aqui)
    if (_hasAny(k, _tagsZAG) || k == 'DEF') return _Cat.zagueiro;

    // 4) Volantes (primeiro volante)
    if (_hasAny(k, _tagsVOL)) return _Cat.volante;

    // 5) Meias (segundo volante / meias)
    if (_hasAny(k, _tagsMEIA)) return _Cat.meia;

    // 6) Pontas
    if (_hasAny(k, _tagsPONTA)) return _Cat.ponta;

    // 7) Segundo atacante
    if (_hasAny(k, _tagsSegundoAt)) return _Cat.segundoAt;

    // 8) Centroavante / atacante central (macro “ATA” cai aqui por padrão)
    if (_hasAny(k, _tagsCA) || k == 'ATA') return _Cat.centroav;

    // Fallback razoável: meia
    return _Cat.meia;
  }

  // --------- contagem por categoria (sem duplicidade) ---------
  Map<_Cat, int> _contar() {
    final map = <_Cat, int>{};
    for (final j in elenco) {
      final c = _classificar(j);
      map[c] = (map[c] ?? 0) + 1;
    }
    return map;
  }

  /// Regras mínimas:
  /// - 2 goleiros
  /// - 4 zagueiros
  /// - 2 laterais
  /// - 6 meio-campistas (volantes + meias)
  /// - 4 atacantes (pontas + segundo atacante + centroavante)
  Map<String, String?> validar() {
    final c = _contar();

    int g(_Cat k) => c[k] ?? 0;

    final goleiros = g(_Cat.gk);
    final zags = g(_Cat.zagueiro);
    final lats = g(_Cat.lateral);
    final meios = g(_Cat.volante) + g(_Cat.meia);
    final atqs = g(_Cat.ponta) + g(_Cat.segundoAt) + g(_Cat.centroav);

    final erros = <String, String?>{};

    if (goleiros < 2) erros['goleiros'] = 'Precisa de pelo menos 2 GKs';
    if (zags < 4) erros['zagueiros'] = 'Precisa de 4 zagueiros';
    if (lats < 2) erros['laterais'] = 'Precisa de 2 laterais';
    if (meios < 6) erros['meio'] = 'Precisa de 6 meio-campistas (vol+meia)';
    if (atqs < 4) erros['ataque'] = 'Precisa de 4 atacantes (pontas/SA/CA)';

    return erros;
  }
}

enum _Cat { gk, zagueiro, lateral, volante, meia, ponta, segundoAt, centroav }
