import 'package:footory26/core/seeded_rng.dart';

class PlayerNameService {
  final SeededRng rng;

  PlayerNameService(this.rng);

  final List<String> _recentNames = <String>[];
  static const int _maxRecentNames = 80;

  String generate(String nationality) {
    final code = nationality.trim().toUpperCase();

    for (var i = 0; i < 40; i++) {
      final candidate = _clean(_buildFootballName(code));

      if (!_recentNames.contains(candidate)) {
        _rememberName(candidate);
        return candidate;
      }
    }

    final fallback = _clean(_buildFootballName(code));
    _rememberName(fallback);
    return fallback;
  }

  String _buildFootballName(String code) {
    final pool = _namePoolForNationality(code);
    final styleRoll = rng.rangeInt(1, 100);

    if (styleRoll <= 62) {
      return rng.pick(pool.shortNames);
    }

    if (styleRoll <= 92) {
      return '${rng.pick(pool.firstNames)} ${rng.pick(pool.lastNames)}';
    }

    return rng.pick(pool.heritageNames);
  }

  _FootballNamePool _namePoolForNationality(String code) {
    switch (code) {
      case 'AR':
      case 'UY':
      case 'PY':
      case 'CL':
      case 'CO':
      case 'PE':
      case 'VE':
      case 'EC':
      case 'BO':
      case 'MX':
      case 'CR':
        return _latamNames;

      case 'IT':
      case 'FR':
      case 'DE':
      case 'PT':
      case 'ES':
      case 'HR':
      case 'RS':
      case 'NL':
      case 'BE':
      case 'ENG':
      case 'GB':
      case 'IS':
        return _europeNames;

      case 'JP':
      case 'KR':
      case 'CN':
        return _asiaNames;

      case 'GH':
      case 'SN':
      case 'CI':
      case 'NG':
      case 'ML':
      case 'CM':
        return _africaNames;

      case 'US':
        return _usNames;

      case 'BR':
      default:
        return _brNames;
    }
  }

  void _rememberName(String name) {
    final clean = _clean(name);
    if (clean.isEmpty) return;

    _recentNames.add(clean);

    if (_recentNames.length > _maxRecentNames) {
      _recentNames.removeAt(0);
    }
  }

  String _clean(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _FootballNamePool {
  final List<String> shortNames;
  final List<String> firstNames;
  final List<String> lastNames;
  final List<String> heritageNames;

  const _FootballNamePool({
    required this.shortNames,
    required this.firstNames,
    required this.lastNames,
    required this.heritageNames,
  });
}

const _brNames = _FootballNamePool(
  shortNames: [
    'Alex',
    'Alê',
    'Alessandro',
    'André',
    'Beto',
    'Biel',
    'Breno',
    'Bruno',
    'Bruninho',
    'Cadu',
    'Caio',
    'Cauã',
    'Chico',
    'Danilo',
    'Davi',
    'Diego',
    'Dudu',
    'Edu',
    'Felipe',
    'Fernando',
    'Gabriel',
    'Gui',
    'Guga',
    'Gustavo',
    'Henrique',
    'Igor',
    'Japa',
    'João',
    'Juninho',
    'Kadu',
    'Kauã',
    'Kauê',
    'Keno',
    'Léo',
    'Leandro',
    'Luan',
    'Lucas',
    'Luizão',
    'Marcinho',
    'Marcos',
    'Matheus',
    'Maycon',
    'Murilo',
    'Nando',
    'Natan',
    'Nenê',
    'Neto',
    'Nicolas',
    'Pablo',
    'Paulinho',
    'Pedrinho',
    'Pipico',
    'Rafael',
    'Rafinha',
    'Renan',
    'Renato',
    'Rodrigo',
    'Romarinho',
    'Rony',
    'Thiago',
    'Thiaguinho',
    'Tinga',
    'Vitão',
    'Vitor',
    'Vitinho',
    'Wesley',
    'Yuri',
    'Zé',
    'Zeca',
    'Cardoso',
    'Castro',
    'Costa',
    'Cunha',
    'Duarte',
    'Farias',
    'Leite',
    'Lima',
    'Machado',
    'Moreira',
    'Rezende',
    'Rocha',
    'Tavares',
  ],
  firstNames: [
    'Adriano',
    'Alex',
    'Alessandro',
    'André',
    'Antonio',
    'Breno',
    'Bruno',
    'Caio',
    'Carlos',
    'Cauã',
    'Danilo',
    'Davi',
    'Diego',
    'Edu',
    'Felipe',
    'Gabriel',
    'Gustavo',
    'Henrique',
    'Igor',
    'João',
    'José',
    'Kauã',
    'Lucas',
    'Luiz',
    'Marcos',
    'Matheus',
    'Murilo',
    'Natan',
    'Nicolas',
    'Pablo',
    'Paulo',
    'Rafael',
    'Renan',
    'Roberto',
    'Rodrigo',
    'Sérgio',
    'Thiago',
    'Valdir',
    'Vitor',
    'Wesley',
    'Yuri',
  ],
  lastNames: [
    'Alves',
    'Araújo',
    'Assis',
    'Barbosa',
    'Batista',
    'Borges',
    'Brandão',
    'Campos',
    'Cardoso',
    'Carvalho',
    'Castro',
    'Coelho',
    'Correia',
    'Costa',
    'Cunha',
    'Duarte',
    'Farias',
    'Ferreira',
    'Freitas',
    'Gomes',
    'Leite',
    'Lima',
    'Macedo',
    'Machado',
    'Melo',
    'Monteiro',
    'Moreira',
    'Neves',
    'Nogueira',
    'Oliveira',
    'Peixoto',
    'Pereira',
    'Pinto',
    'Queiroz',
    'Rezende',
    'Ribeiro',
    'Rocha',
    'Santos',
    'Silva',
    'Souza',
    'Tavares',
    'Teixeira',
    'Vieira',
  ],
  heritageNames: [
    'Akira',
    'Chan',
    'Chen',
    'Hassan',
    'Hong',
    'Kenji',
    'Kim',
    'Kobayashi',
    'Kowalski',
    'Li',
    'Matsuda',
    'Nakamura',
    'Okamoto',
    'Park',
    'Pieroni',
    'Rossi',
    'Sato',
    'Tanaka',
    'Yamada',
    'Yamamoto',
  ],
);

const _latamNames = _FootballNamePool(
  shortNames: [
    'Acuña',
    'Adrián',
    'Agustín',
    'Almada',
    'Álvaro',
    'Barrios',
    'Benítez',
    'Cabrera',
    'Cano',
    'Cristian',
    'Cuéllar',
    'Diego',
    'Díaz',
    'Enzo',
    'Facundo',
    'Franco',
    'Galarza',
    'Ibarra',
    'Joaquín',
    'Juan',
    'Julián',
    'Leo',
    'López',
    'Lucho',
    'Martín',
    'Mateo',
    'Medina',
    'Molina',
    'Montiel',
    'Nacho',
    'Nico',
    'Ocampo',
    'Ortega',
    'Pablo',
    'Paredes',
    'Pato',
    'Paz',
    'Pipa',
    'Quintero',
    'Ramiro',
    'Rojas',
    'Sosa',
    'Suárez',
    'Toto',
    'Tucu',
    'Valdez',
    'Vargas',
    'Zapata',
  ],
  firstNames: [
    'Adrián',
    'Agustín',
    'Cristian',
    'Diego',
    'Enzo',
    'Facundo',
    'Franco',
    'Joaquín',
    'Juan',
    'Julián',
    'Lucho',
    'Martín',
    'Mateo',
    'Nico',
    'Pablo',
    'Ramiro',
    'Santiago',
    'Tomás',
  ],
  lastNames: [
    'Acosta',
    'Aguilar',
    'Almada',
    'Barrios',
    'Benítez',
    'Cabrera',
    'Cardozo',
    'Castro',
    'Fernández',
    'Gómez',
    'Herrera',
    'Ibarra',
    'López',
    'Martínez',
    'Medina',
    'Mendoza',
    'Molina',
    'Morales',
    'Navarro',
    'Ocampo',
    'Ortega',
    'Paz',
    'Peralta',
    'Quispe',
    'Ramírez',
    'Rojas',
    'Sosa',
    'Suárez',
    'Torres',
    'Valdez',
    'Vargas',
  ],
  heritageNames: [
    'Acuña',
    'Almada',
    'Barrios',
    'Borré',
    'Cano',
    'Cuéllar',
    'Díaz',
    'Gaitán',
    'Galarza',
    'Medina',
    'Montiel',
    'Ocampo',
    'Paredes',
    'Quintero',
    'Valdez',
    'Zapata',
  ],
);

const _europeNames = _FootballNamePool(
  shortNames: [
    'Alessio',
    'Bauer',
    'Becker',
    'Bianchi',
    'Conti',
    'Dario',
    'Dekker',
    'Dubois',
    'Emil',
    'Enzo',
    'Fabio',
    'Felix',
    'Fischer',
    'Florian',
    'Hugo',
    'Iker',
    'Jansen',
    'Jonas',
    'Keller',
    'Kovac',
    'Kowalski',
    'Lars',
    'Leon',
    'Luca',
    'Marco',
    'Matteo',
    'Milan',
    'Müller',
    'Navarro',
    'Nico',
    'Noah',
    'Pieroni',
    'Pietro',
    'Ricci',
    'Rossi',
    'Theo',
    'Van Dijk',
    'Vidal',
    'Vieri',
    'Weber',
    'Zanetti',
  ],
  firstNames: [
    'Alessio',
    'Dario',
    'Emil',
    'Enzo',
    'Fabio',
    'Felix',
    'Florian',
    'Hugo',
    'Iker',
    'Jonas',
    'Lars',
    'Leon',
    'Luca',
    'Marco',
    'Matteo',
    'Milan',
    'Nico',
    'Noah',
    'Pietro',
    'Theo',
  ],
  lastNames: [
    'Bauer',
    'Becker',
    'Bernard',
    'Bianchi',
    'Conti',
    'Dubois',
    'Fischer',
    'Fontaine',
    'Jansen',
    'Keller',
    'Kovac',
    'Kramer',
    'Mercier',
    'Moreau',
    'Müller',
    'Pieroni',
    'Ricci',
    'Romano',
    'Rossi',
    'Schneider',
    'Van Dijk',
    'Weber',
    'Zanetti',
  ],
  heritageNames: [
    'Dekker',
    'Kowalski',
    'Navarro',
    'Pieroni',
    'Rossi',
    'Van Dijk',
    'Vidal',
    'Vieri',
    'Zanetti',
  ],
);

const _asiaNames = _FootballNamePool(
  shortNames: [
    'Akira',
    'Chan',
    'Chen',
    'Daichi',
    'Hao',
    'Haruto',
    'Hong',
    'Hyun',
    'Ito',
    'Jin',
    'Jun',
    'Kai',
    'Kaito',
    'Kang',
    'Ken',
    'Kenji',
    'Kim',
    'Lee',
    'Li',
    'Min-Jun',
    'Nakamura',
    'Park',
    'Ren',
    'Riku',
    'Ryu',
    'Sato',
    'Sho',
    'Sora',
    'Tanaka',
    'Tao',
    'Wei',
    'Yamamoto',
    'Yuta',
  ],
  firstNames: [
    'Akira',
    'Daichi',
    'Hao',
    'Haruto',
    'Hyun',
    'Jin',
    'Jun',
    'Kaito',
    'Kenji',
    'Min-Jun',
    'Ren',
    'Riku',
    'Sho',
    'Sora',
    'Tao',
    'Wei',
    'Yuta',
  ],
  lastNames: [
    'Chan',
    'Chen',
    'Hong',
    'Ito',
    'Kang',
    'Kim',
    'Kobayashi',
    'Lee',
    'Li',
    'Nakamura',
    'Park',
    'Sato',
    'Suzuki',
    'Tanaka',
    'Wang',
    'Yamada',
    'Yamamoto',
    'Zhang',
  ],
  heritageNames: [
    'Akira',
    'Chan',
    'Chen',
    'Hong',
    'Kenji',
    'Kim',
    'Li',
    'Min-Jun',
    'Nakamura',
    'Park',
    'Tanaka',
    'Yamamoto',
  ],
);

const _africaNames = _FootballNamePool(
  shortNames: [
    'Adama',
    'Aurier',
    'Balde',
    'Bamba',
    'Boateng',
    'Camara',
    'Diallo',
    'Diop',
    'Fofana',
    'Keita',
    'Koffi',
    'Konate',
    'Kone',
    'Kouamé',
    'Mamadou',
    'Mensah',
    'Moses',
    'Ndiaye',
    'Ousmane',
    'Samuel',
    'Sangare',
    'Seydou',
    'Sissoko',
    'Sow',
    'Toure',
    'Traore',
    'Yaya',
  ],
  firstNames: [
    'Adama',
    'Amadou',
    'Bakary',
    'Boubacar',
    'Ibrahim',
    'Ismael',
    'Kader',
    'Koffi',
    'Mamadou',
    'Moussa',
    'Ousmane',
    'Samuel',
    'Seydou',
    'Victor',
    'Yaya',
  ],
  lastNames: [
    'Aurier',
    'Balde',
    'Bamba',
    'Camara',
    'Coulibaly',
    'Diallo',
    'Diop',
    'Doumbia',
    'Fofana',
    'Keita',
    'Konate',
    'Kone',
    'Kouamé',
    'Mensah',
    'Ndiaye',
    'Sangare',
    'Sissoko',
    'Sow',
    'Toure',
    'Traore',
  ],
  heritageNames: [
    'Boateng',
    'Camara',
    'Diop',
    'Fofana',
    'Keita',
    'Konate',
    'Kouamé',
    'Mensah',
    'Ndiaye',
    'Traore',
  ],
);

const _usNames = _FootballNamePool(
  shortNames: [
    'Aiden',
    'Anderson',
    'Brown',
    'Carter',
    'Clark',
    'Cole',
    'Connor',
    'Davis',
    'Dylan',
    'Ethan',
    'Harris',
    'Jackson',
    'James',
    'Johnson',
    'King',
    'Liam',
    'Logan',
    'Mason',
    'Miller',
    'Noah',
    'Parker',
    'Reed',
    'Ryan',
    'Smith',
    'Taylor',
    'Tyler',
    'Walker',
    'Wilson',
  ],
  firstNames: [
    'Aiden',
    'Connor',
    'Dylan',
    'Ethan',
    'James',
    'Liam',
    'Logan',
    'Mason',
    'Noah',
    'Ryan',
    'Tyler',
  ],
  lastNames: [
    'Anderson',
    'Brown',
    'Carter',
    'Clark',
    'Cole',
    'Davis',
    'Harris',
    'Jackson',
    'Johnson',
    'King',
    'Miller',
    'Parker',
    'Reed',
    'Smith',
    'Taylor',
    'Walker',
    'Wilson',
  ],
  heritageNames: [
    'Brown',
    'Carter',
    'Cole',
    'Davis',
    'King',
    'Lewis',
    'Miller',
    'Parker',
    'Reed',
    'Walker',
  ],
);
