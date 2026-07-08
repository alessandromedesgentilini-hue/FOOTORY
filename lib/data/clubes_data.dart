// lib/data/clubes_data.dart
//
// Fonte: lista oficial travada (80 clubes, 4 divisões A–D)
// Padrões:
// - nomes sem hífen
// - shortName para UI
// - slug ASCII para persistência/rotas
//
// Observação: Estes dados são “travados” no MVP. Alterar só se o usuário pedir.

enum Divisao { a, b, c, d }

class ClubeSeed {
  final int id; // 1..80
  final Divisao divisao;
  final String name; // nome oficial exibido
  final String shortName; // nome curto (tabelas, placar)
  final String slug; // identificador estável (ASCII, sem espaços/acentos)

  const ClubeSeed({
    required this.id,
    required this.divisao,
    required this.name,
    required this.shortName,
    required this.slug,
  });
}

const List<ClubeSeed> clubesSeeds = [
  // ======================
  // Série A (1–20)
  // ======================
  ClubeSeed(
      id: 1,
      divisao: Divisao.a,
      name: 'Atlético Belo Horizonte',
      shortName: 'Atl BH',
      slug: 'atletico_belo_horizonte'),
  ClubeSeed(
      id: 2,
      divisao: Divisao.a,
      name: 'Vila dos Pinheiros',
      shortName: 'V. Pinheiros',
      slug: 'vila_dos_pinheiros'),
  ClubeSeed(
      id: 3,
      divisao: Divisao.a,
      name: 'Baiano',
      shortName: 'Baiano',
      slug: 'baiano'),
  ClubeSeed(
      id: 4,
      divisao: Divisao.a,
      name: 'João Pereira Souza',
      shortName: 'JP Souza',
      slug: 'joao_pereira_souza'),
  ClubeSeed(
      id: 5,
      divisao: Divisao.a,
      name: 'Bragança Paulista',
      shortName: 'Bragança',
      slug: 'braganca_paulista'),
  ClubeSeed(
      id: 6,
      divisao: Divisao.a,
      name: 'Operários Paulista',
      shortName: 'Operários',
      slug: 'operarios_paulista'),
  ClubeSeed(
      id: 7,
      divisao: Divisao.a,
      name: 'Rio Criciúma',
      shortName: 'Rio Criciúma',
      slug: 'rio_criciuma'),
  ClubeSeed(
      id: 8,
      divisao: Divisao.a,
      name: 'Celeste BH',
      shortName: 'Celeste',
      slug: 'celeste_bh'),
  ClubeSeed(
      id: 9,
      divisao: Divisao.a,
      name: 'Cuiabano',
      shortName: 'Cuiabano',
      slug: 'cuiabano'),
  ClubeSeed(
      id: 10,
      divisao: Divisao.a,
      name: 'Rubro Rio',
      shortName: 'Rubro Rio',
      slug: 'rubro_rio'),
  ClubeSeed(
      id: 11,
      divisao: Divisao.a,
      name: 'Vale das Laranjeiras',
      shortName: 'V. Laranjeiras',
      slug: 'vale_das_laranjeiras'),
  ClubeSeed(
      id: 12,
      divisao: Divisao.a,
      name: 'Forte Assunção CE',
      shortName: 'F. Assunção',
      slug: 'forte_assuncao_ce'),
  ClubeSeed(
      id: 13,
      divisao: Divisao.a,
      name: 'Grêmio Eldorado',
      shortName: 'G. Eldorado',
      slug: 'gremio_eldorado'),
  ClubeSeed(
      id: 14,
      divisao: Divisao.a,
      name: 'Inter Guaíba',
      shortName: 'Inter',
      slug: 'inter_guaiba'),
  ClubeSeed(
      id: 15,
      divisao: Divisao.a,
      name: 'Verde da Serra',
      shortName: 'V. Serra',
      slug: 'verde_da_serra'),
  ClubeSeed(
      id: 16,
      divisao: Divisao.a,
      name: 'Palestra Itália',
      shortName: 'Palestra',
      slug: 'palestra_italia'),
  ClubeSeed(
      id: 17,
      divisao: Divisao.a,
      name: 'São Vicente',
      shortName: 'São Vicente',
      slug: 'sao_vicente'),
  ClubeSeed(
      id: 18,
      divisao: Divisao.a,
      name: 'Cruz Maltino',
      shortName: 'Cruz M.',
      slug: 'cruz_maltino'),
  ClubeSeed(
      id: 19,
      divisao: Divisao.a,
      name: 'Vera Cruz',
      shortName: 'Vera Cruz',
      slug: 'vera_cruz'),
  ClubeSeed(
      id: 20,
      divisao: Divisao.a,
      name: 'Atlético Vila Boa',
      shortName: 'Atl Vila',
      slug: 'atletico_vila_boa'),

  // ======================
  // Série B (21–40)
  // ======================
  ClubeSeed(
      id: 21,
      divisao: Divisao.b,
      name: 'Cidade de Minas',
      shortName: 'C. Minas',
      slug: 'cidade_de_minas'),
  ClubeSeed(
      id: 22,
      divisao: Divisao.b,
      name: 'Independência da Ilha',
      shortName: 'Indep. Ilha',
      slug: 'independencia_da_ilha'),
  ClubeSeed(
      id: 23,
      divisao: Divisao.b,
      name: 'Vila Tibério',
      shortName: 'V. Tibério',
      slug: 'vila_tiberio'),
  ClubeSeed(
      id: 24,
      divisao: Divisao.b,
      name: 'São Luiz Gonzaga',
      shortName: 'SL Gonzaga',
      slug: 'sao_luiz_gonzaga'),
  ClubeSeed(
      id: 25,
      divisao: Divisao.b,
      name: 'Cearense do Norte',
      shortName: 'Cearense N.',
      slug: 'cearense_do_norte'),
  ClubeSeed(
      id: 26,
      divisao: Divisao.b,
      name: 'Chapecó',
      shortName: 'Chapecó',
      slug: 'chapeco'),
  ClubeSeed(
      id: 27,
      divisao: Divisao.b,
      name: 'Alagoas FC',
      shortName: 'Alagoas',
      slug: 'alagoas_fc'),
  ClubeSeed(
      id: 28,
      divisao: Divisao.b,
      name: 'Goiano',
      shortName: 'Goiano',
      slug: 'goiano'),
  ClubeSeed(
      id: 29,
      divisao: Divisao.b,
      name: 'Il Guarany Campinas',
      shortName: 'Guarany',
      slug: 'il_guarany_campinas'),
  ClubeSeed(
      id: 30,
      divisao: Divisao.b,
      name: 'Atlética Sorocabana',
      shortName: 'Sorocabana',
      slug: 'atletica_sorocabana'),
  ClubeSeed(
      id: 31,
      divisao: Divisao.b,
      name: 'Matarona',
      shortName: 'Matarona',
      slug: 'matarona'),
  ClubeSeed(
      id: 32,
      divisao: Divisao.b,
      name: 'Novo Horizonte',
      shortName: 'Novo Horiz.',
      slug: 'novo_horizonte'),
  ClubeSeed(
      id: 33,
      divisao: Divisao.b,
      name: 'Proletário Paraná',
      shortName: 'Proletário',
      slug: 'proletario_parana'),
  ClubeSeed(
      id: 34,
      divisao: Divisao.b,
      name: 'Papão',
      shortName: 'Papão',
      slug: 'papao'),
  ClubeSeed(
      id: 35,
      divisao: Divisao.b,
      name: 'Ponte da Fumaça Campinas',
      shortName: 'Ponte F.',
      slug: 'ponte_da_fumaca_campinas'),
  ClubeSeed(
      id: 36,
      divisao: Divisao.b,
      name: 'Villa de Santos',
      shortName: 'Villa',
      slug: 'villa_de_santos'),
  ClubeSeed(
      id: 37,
      divisao: Divisao.b,
      name: 'Recife',
      shortName: 'Recife',
      slug: 'recife'),
  ClubeSeed(
      id: 38,
      divisao: Divisao.b,
      name: 'Tombo Minas',
      shortName: 'Tombo MG',
      slug: 'tombo_minas'),
  ClubeSeed(
      id: 39,
      divisao: Divisao.b,
      name: 'Vila Goiás',
      shortName: 'Vila GO',
      slug: 'vila_goias'),
  ClubeSeed(
      id: 40,
      divisao: Divisao.b,
      name: 'Curitiba Capital',
      shortName: 'Curitiba',
      slug: 'curitiba_capital'),

  // ======================
  // Série C (41–60)
  // ======================
  ClubeSeed(
      id: 41,
      divisao: Divisao.c,
      name: 'Rio Grande do Norte',
      shortName: 'RG Norte',
      slug: 'rio_grande_do_norte'),
  ClubeSeed(
      id: 42,
      divisao: Divisao.c,
      name: 'Amazonas Norte',
      shortName: 'AM Norte',
      slug: 'amazonas_norte'),
  ClubeSeed(
      id: 43,
      divisao: Divisao.c,
      name: 'Aparecida GO',
      shortName: 'Aparecida',
      slug: 'aparecida_go'),
  ClubeSeed(
      id: 44,
      divisao: Divisao.c,
      name: 'João Pessoa',
      shortName: 'João Pessoa',
      slug: 'joao_pessoa'),
  ClubeSeed(
      id: 45,
      divisao: Divisao.c,
      name: 'Real Alagoano',
      shortName: 'Real A.',
      slug: 'real_alagoano'),
  ClubeSeed(
      id: 46,
      divisao: Divisao.c,
      name: 'Dragão Sergipano',
      shortName: 'Dragão',
      slug: 'dragao_sergipano'),
  ClubeSeed(
      id: 47,
      divisao: Divisao.c,
      name: 'Ferrim Ceará',
      shortName: 'Ferrim',
      slug: 'ferrim_ceara'),
  ClubeSeed(
      id: 48,
      divisao: Divisao.c,
      name: 'Velha Figueira SC',
      shortName: 'V. Figueira',
      slug: 'velha_figueira_sc'),
  ClubeSeed(
      id: 49,
      divisao: Divisao.c,
      name: 'Florestal',
      shortName: 'Florestal',
      slug: 'florestal'),
  ClubeSeed(
      id: 50,
      divisao: Divisao.c,
      name: 'Londrinense',
      shortName: 'Londrinense',
      slug: 'londrinense'),
  ClubeSeed(
      id: 51,
      divisao: Divisao.c,
      name: 'Capibaribe PE',
      shortName: 'Capibaribe',
      slug: 'capibaribe_pe'),
  ClubeSeed(
      id: 52,
      divisao: Divisao.c,
      name: 'Azulão Pará',
      shortName: 'Azulão',
      slug: 'azulao_para'),
  ClubeSeed(
      id: 53,
      divisao: Divisao.c,
      name: 'Bernardo SP',
      shortName: 'Bernardo',
      slug: 'bernardo_sp'),
  ClubeSeed(
      id: 54,
      divisao: Divisao.c,
      name: 'Real Zeca',
      shortName: 'Real Zeca',
      slug: 'real_zeca'),
  ClubeSeed(
      id: 55,
      divisao: Divisao.c,
      name: 'Roraima FC',
      shortName: 'Roraima',
      slug: 'roraima_fc'),
  ClubeSeed(
      id: 56,
      divisao: Divisao.c,
      name: 'Tombo do Vale',
      shortName: 'Tombo V.',
      slug: 'tombo_do_vale'),
  ClubeSeed(
      id: 57,
      divisao: Divisao.c,
      name: 'Arraial Rio',
      shortName: 'Arraial',
      slug: 'arraial_rio'),
  ClubeSeed(
      id: 58,
      divisao: Divisao.c,
      name: 'Erechim',
      shortName: 'Erechim',
      slug: 'erechim'),
  ClubeSeed(
      id: 59,
      divisao: Divisao.c,
      name: 'Rio Negro AM',
      shortName: 'Rio Negro',
      slug: 'rio_negro_am'),
  ClubeSeed(
      id: 60,
      divisao: Divisao.c,
      name: 'São José dos Altos PI',
      shortName: 'SJ Altos',
      slug: 'sao_jose_dos_altos_pi'),

  // ======================
  // Série D (61–80)
  // ======================
  ClubeSeed(
      id: 61,
      divisao: Divisao.d,
      name: 'Caxiense',
      shortName: 'Caxiense',
      slug: 'caxiense'),
  ClubeSeed(
      id: 62,
      divisao: Divisao.d,
      name: 'Caruaruense',
      shortName: 'Caruaru',
      slug: 'caruaruense'),
  ClubeSeed(
      id: 63,
      divisao: Divisao.d,
      name: 'Araraquara SP',
      shortName: 'Araraquara',
      slug: 'araraquara_sp'),
  ClubeSeed(
      id: 64,
      divisao: Divisao.d,
      name: 'Águia Branca',
      shortName: 'Águia',
      slug: 'aguia_branca'),
  ClubeSeed(
      id: 65,
      divisao: Divisao.d,
      name: 'Governador Valadares',
      shortName: 'Gov. Valad.',
      slug: 'governador_valadares'),
  ClubeSeed(
      id: 66,
      divisao: Divisao.d,
      name: 'Uniclinic',
      shortName: 'Uniclinic',
      slug: 'uniclinic'),
  ClubeSeed(
      id: 67,
      divisao: Divisao.d,
      name: 'Paranaense',
      shortName: 'Paranaense',
      slug: 'paranaense'),
  ClubeSeed(
      id: 68,
      divisao: Divisao.d,
      name: 'Campina PB',
      shortName: 'Campina',
      slug: 'campina_pb'),
  ClubeSeed(
      id: 69,
      divisao: Divisao.d,
      name: 'Nova Amsterdã',
      shortName: 'N. Amsterdã',
      slug: 'nova_amsterda'),
  ClubeSeed(
      id: 70,
      divisao: Divisao.d,
      name: 'São Luís',
      shortName: 'São Luís',
      slug: 'sao_luis'),
  ClubeSeed(
      id: 71,
      divisao: Divisao.d,
      name: 'Feira BA',
      shortName: 'Feira',
      slug: 'feira_ba'),
  ClubeSeed(
      id: 72,
      divisao: Divisao.d,
      name: 'Desportos SP',
      shortName: 'Desportos',
      slug: 'desportos_sp'),
  ClubeSeed(
      id: 73,
      divisao: Divisao.d,
      name: 'Juazeiro do Norte',
      shortName: 'Juazeiro',
      slug: 'juazeiro_do_norte'),
  ClubeSeed(
      id: 74,
      divisao: Divisao.d,
      name: 'Camaragibe',
      shortName: 'Camaragibe',
      slug: 'camaragibe'),
  ClubeSeed(
      id: 75,
      divisao: Divisao.d,
      name: 'Ingazeira',
      shortName: 'Ingazeira',
      slug: 'ingazeira'),
  ClubeSeed(
      id: 76,
      divisao: Divisao.d,
      name: 'Caldas MG',
      shortName: 'Caldas',
      slug: 'caldas_mg'),
  ClubeSeed(
      id: 77,
      divisao: Divisao.d,
      name: 'Maracapá',
      shortName: 'Maracapá',
      slug: 'maracapa'),
  ClubeSeed(
      id: 78,
      divisao: Divisao.d,
      name: 'Brasília Capital',
      shortName: 'Brasília',
      slug: 'brasilia_capital'),
  ClubeSeed(
      id: 79,
      divisao: Divisao.d,
      name: 'Nacional Manaus',
      shortName: 'Nac. Manaus',
      slug: 'nacional_manaus'),
  ClubeSeed(
      id: 80,
      divisao: Divisao.d,
      name: '1920 AC',
      shortName: '1920',
      slug: '1920_ac'),
];
