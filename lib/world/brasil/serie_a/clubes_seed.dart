import 'package:flutter/material.dart';

enum TeamStyle { posse, transicao, gegenpress, sulAmericano, bolaParada }

class ClubSeed {
  final String slug;
  final String nome;
  final double nivel; // 1..5
  final TeamStyle estilo;
  final Color cor1;
  final Color cor2;
  const ClubSeed({
    required this.slug,
    required this.nome,
    required this.nivel,
    required this.estilo,
    required this.cor1,
    required this.cor2,
  });
}

const serieA2025 = <ClubSeed>[
  ClubSeed(
    slug: 'atletico-bh',
    nome: 'Atlético Belo Horizonte',
    nivel: 3.5,
    estilo: TeamStyle.bolaParada,
    cor1: Color(0xFF000000),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'vila-dos-pinheiros',
    nome: 'Vila dos Pinheiros',
    nivel: 2.5,
    estilo: TeamStyle.transicao,
    cor1: Color(0xFFCC0000),
    cor2: Color(0xFF000000),
  ),
  ClubSeed(
    slug: 'baiano',
    nome: 'Baiano',
    nivel: 3.0,
    estilo: TeamStyle.posse,
    cor1: Color(0xFF0033AA),
    cor2: Color(0xFFFFFF00),
  ),
  ClubSeed(
    slug: 'joao-pereira-souza',
    nome: 'João Pereira Souza',
    nivel: 3.5,
    estilo: TeamStyle.transicao,
    cor1: Color(0xFF000000),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'braganca-paulista',
    nome: 'Bragança-Paulista',
    nivel: 2.5,
    estilo: TeamStyle.gegenpress,
    cor1: Color(0xFFCC0000),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'operarios-paulistas',
    nome: 'Operarios-Paulista',
    nivel: 3.0,
    estilo: TeamStyle.sulAmericano,
    cor1: Color(0xFF000000),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'rio-criciuma',
    nome: 'Rio Criciúma',
    nivel: 2.0,
    estilo: TeamStyle.bolaParada,
    cor1: Color(0xFFFFCC00),
    cor2: Color(0xFF000000),
  ),
  ClubSeed(
    slug: 'celeste-bh',
    nome: 'Celeste-BH',
    nivel: 3.5,
    estilo: TeamStyle.posse,
    cor1: Color(0xFF0033CC),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'cuiabano',
    nome: 'Cuiabano',
    nivel: 2.0,
    estilo: TeamStyle.bolaParada,
    cor1: Color(0xFF006633),
    cor2: Color(0xFFFFFF00),
  ),
  ClubSeed(
    slug: 'rubro-rio',
    nome: 'Rubro-Rio',
    nivel: 4.0,
    estilo: TeamStyle.posse,
    cor1: Color(0xFFCC0000),
    cor2: Color(0xFF000000),
  ),
  ClubSeed(
    slug: 'vale-das-laranjeiras',
    nome: 'Vale das Laranjeiras',
    nivel: 3.5,
    estilo: TeamStyle.posse,
    cor1: Color(0xFF00AA88),
    cor2: Color(0xFFAA2200),
  ),
  ClubSeed(
    slug: 'forte-assuncao',
    nome: 'Forte Assunção-CE',
    nivel: 3.0,
    estilo: TeamStyle.gegenpress,
    cor1: Color(0xFF003399),
    cor2: Color(0xFFFF0000),
  ),
  ClubSeed(
    slug: 'gremio-eldorado',
    nome: 'Grêmio-Eldorado',
    nivel: 2.5,
    estilo: TeamStyle.bolaParada,
    cor1: Color(0xFF00AADD),
    cor2: Color(0xFF000000),
  ),
  ClubSeed(
    slug: 'inter-guaiba',
    nome: 'Inter-Guaiba',
    nivel: 3.0, // fixo em 3
    estilo: TeamStyle.transicao,
    cor1: Color(0xFFCC0000), cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'verde-da-serra',
    nome: 'Verde-da-Serra',
    nivel: 2.0,
    estilo: TeamStyle.bolaParada,
    cor1: Color(0xFF117733),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'palestra-italia',
    nome: 'Palestra-Itália',
    nivel: 4.0,
    estilo: TeamStyle.transicao,
    cor1: Color(0xFF006633),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'sao-vicente',
    nome: 'São Vicente',
    nivel: 3.0, // fixo em 3
    estilo: TeamStyle.transicao,
    cor1: Color(0xFF990000), cor2: Color(0xFFFFFF00),
  ),
  ClubSeed(
    slug: 'cruz-maltino',
    nome: 'Cruz-Maltino',
    nivel: 2.5,
    estilo: TeamStyle.transicao,
    cor1: Color(0xFF000000),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'vera-cruz',
    nome: 'Vera Cruz',
    nivel: 2.0,
    estilo: TeamStyle.bolaParada,
    cor1: Color(0xFFCC0000),
    cor2: Color(0xFFFFFFFF),
  ),
  ClubSeed(
    slug: 'atletico-vila-boa',
    nome: 'Atlético-Vila Boa',
    nivel: 2.0,
    estilo: TeamStyle.bolaParada,
    cor1: Color(0xFFCC0000),
    cor2: Color(0xFF000000),
  ),
];
