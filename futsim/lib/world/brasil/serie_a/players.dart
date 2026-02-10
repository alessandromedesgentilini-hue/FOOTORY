import '../../../models/jogador.dart';

class _Club {
  final String slug;
  final String nome;
  final String code; // prefixo de ID
  const _Club(this.slug, this.nome, this.code);
}

// Série A – 20 clubes (tua lista)
const List<_Club> _clubs = [
  _Club('atletico-bh',       'Atlético Belo Horizonte', 'ABH'),
  _Club('vila-dos-pinheiros','Vila dos Pinheiros',      'VDP'),
  _Club('baiano',            'Baiano',                   'BAI'),
  _Club('joao-pereira-souza','João Pereira Souza',       'JPS'),
  _Club('braganca-paulista', 'Bragança-Paulista',        'BGP'),
  _Club('operarios-paulista','Operarios-Paulista',       'OPL'),
  _Club('rio-criciuma',      'Rio Criciúma',             'RCR'),
  _Club('celeste-bh',        'Celeste-BH',               'CBH'),
  _Club('cuiabano',          'Cuiabano',                 'CUI'),
  _Club('rubro-rio',         'Rubro-Rio',                'RBR'),
  _Club('vale-das-laranjeiras','Vale das Laranjeiras',   'VDL'),
  _Club('forte-assuncao-ce', 'Forte assunção-CE',        'FAC'),
  _Club('gremio-eldorado',   'Grêmio-Eldorado',          'GEL'),
  _Club('inter-guaiba',      'Inter-Guaiba',             'IGB'),
  _Club('verde-da-serra',    'Verde-da-Serra',           'VDS'),
  _Club('palestra-italia',   'Palestra-Itália',          'PAL'),
  _Club('sao-vicente',       'São Vicente',              'SVI'),
  _Club('cruz-maltino',      'Cruz-Maltino',             'CRM'),
  _Club('vera-cruz',         'Vera Cruz',                'VCR'),
  _Club('atletico-vila-boa', 'Atlético-Vila Boa',        'AVB'),
];

// composição padrão: 25 jogadores
// 3 GOL, 4 LAT, 4 ZAG, 3 VOL, 3 MC, 2 MEI, 3 PON, 1 SA, 2 ATA
const Map<Posicao, int> _defaultComp = {
  Posicao.GOL: 3,
  Posicao.LAT: 4,
  Posicao.ZAG: 4,
  Posicao.VOL: 3,
  Posicao.MC:  3,
  Posicao.MEI: 2,
  Posicao.PON: 3,
  Posicao.SA:  1,
  Posicao.ATA: 2,
};

Map<String, int> _baseAtsFor(Posicao p, {int nivel = 6}) {
  final perfil = kPerfisPosicao[p]!;
  return { for (final k in perfil.chaves) k: nivel };
}

String _num3(int i) => i.toString().padLeft(3, '0');

Map<String, Jogador> _genTeamPlayers(_Club c) {
  final out = <String, Jogador>{};
  int seq = 0;

  Jogador add(Posicao pos, String marcador, {int idade = 24, String nac = 'BR', int nivel = 6}) {
    seq += 1;
    final id = '${c.code}-${_num3(seq)}';
    return out[id] = Jogador(
      id: id,
      nome: '${c.nome} $marcador ${_num3(seq)}',
      idade: idade,
      nacionalidade: nac,
      posicaoPrincipal: pos,
      atributos: _baseAtsFor(pos, nivel: nivel),
    );
  }

  for (int i = 0; i < _defaultComp[Posicao.GOL]!: i++) add(Posicao.GOL, 'GK');
  for (int i = 0; i < _defaultComp[Posicao.LAT]!: i++) add(Posicao.LAT, (i % 2 == 0) ? 'LD' : 'LE');
  for (int i = 0; i < _defaultComp[Posicao.ZAG]!: i++) add(Posicao.ZAG, 'ZAG');
  for (int i = 0; i < _defaultComp[Posicao.VOL]!: i++) add(Posicao.VOL, 'VOL');
  for (int i = 0; i < _defaultComp[Posicao.MC]!: i++)  add(Posicao.MC,  'MC');
  for (int i = 0; i < _defaultComp[Posicao.MEI]!: i++) add(Posicao.MEI, 'MEI');
  for (int i = 0; i < _defaultComp[Posicao.PON]!: i++) add(Posicao.PON, 'PON');
  for (int i = 0; i < _defaultComp[Posicao.SA]!: i++)  add(Posicao.SA,  'SA');
  for (int i = 0; i < _defaultComp[Posicao.ATA]!: i++) add(Posicao.ATA, 'ATA');

  return out;
}

/// Todos os jogadores da Série A (500) com atributos base.
/// Depois aplique seus nomes/OVRs no arquivo de overrides, se preferir.
Map<String, Jogador> playersBRSerieA2025() {
  final all = <String, Jogador>{};
  for (final c in _clubs) {
    all.addAll(_genTeamPlayers(c));
  }
  return all;
}
