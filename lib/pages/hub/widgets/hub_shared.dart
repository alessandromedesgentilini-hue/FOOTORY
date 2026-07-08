import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/services/team_power_service.dart';

class HubPowerSnap {
  final int stars10;
  final int stars5;
  final String label10;

  const HubPowerSnap({
    required this.stars10,
    required this.stars5,
    required this.label10,
  });
}

HubPowerSnap snapFromPower10(double power10) {
  final tp = const TeamPowerService();
  final s10 = tp.stars10FromRating(power10).clamp(0, 10);
  final s5 = tp.stars5FromStars10(s10).clamp(0, 5);

  return HubPowerSnap(
    stars10: s10,
    stars5: s5,
    label10: '$s10 / 10',
  );
}

class HubStars5 extends StatelessWidget {
  final int filled;
  final double size;

  const HubStars5({
    super.key,
    required this.filled,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    final f = filled.clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final on = i < f;
        return Icon(
          on ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: on ? AppColors.star : AppColors.textMuted,
        );
      }),
    );
  }
}

class ClubBadgeResolver {
  const ClubBadgeResolver._();

  static String resolve({
    required String divisionId,
    required String clubName,
  }) {
    final folder = _folderForDivision(divisionId);
    final fileName = _fileNameForClub(clubName);
    return 'assets/clubs/$folder/$fileName.png';
  }

  static String _folderForDivision(String divisionId) {
    switch (divisionId.trim().toUpperCase()) {
      case 'BR-A':
        return 'league_a';
      case 'BR-B':
        return 'league_b';
      case 'BR-C':
        return 'league_c';
      case 'BR-D':
      default:
        return 'league_d';
    }
  }

  static String _fileNameForClub(String clubName) {
    final special = <String, String>{
      'Atlético Belo Horizonte': 'atletico_belo_horizonte',
      'Atlético-Vila Boa': 'atletico_vila_boa',
      'Baiano': 'baiano',
      'Bragança-Paulista': 'braganca_paulista',
      'Celeste-BH': 'celeste_bh',
      'Cruz-Maltino': 'cruz_maltino',
      'Cuiabano': 'cuiabano',
      'Forte Assunção-CE': 'forte_assuncao',
      'Grêmio-Eldorado': 'gremio_eldorado',
      'Inter-Guaiba': 'inter_guaiba',
      'João Pereira Souza': 'joao_pereira_souza',
      'Operarios-Paulista': 'operarios_paulistas',
      'Palestra-Itália': 'palestra_italia',
      'Rio Criciúma': 'rio_criciuma',
      'Rubro-Rio': 'rubro_rio',
      'São Vicente': 'sao_vicente',
      'Vale das Laranjeiras': 'vale_das_laranjeiras',
      'Vera Cruz': 'vera_cruz',
      'Verde-da-Serra': 'verde_da_serra',
      'Vila dos Pinheiros': 'vila_dos_pinheiros',
      'Alagoas FC': 'alagoas',
      'Atlética Sorocabana': 'atletico_sorocaba',
      'Cearense': 'cearense',
      'Chapecó': 'chapeco',
      'Cidade de Minas': 'cidade_de_minas',
      'Curitiba': 'curitiba',
      'Goiano': 'goiano',
      'Il Guarany-Campinas': 'il_guarany',
      'Independência da Ilha': 'independencia_da_ilha',
      'Novo-Horizonte': 'novo_horizonte',
      'Papão': 'papao',
      'Ponte da Fumaça-Campinas': 'ponte_da_fumaca',
      'Proletário-Paraná': 'proletario_pr',
      'Recife': 'recife',
      'São Luiz Gonzaga': 'sao_luis_gonzaga',
      'Tombo-Minas': 'tombo_minas',
      'Tupinambá': 'tupinamba',
      'Vila-Goiás': 'vila_goias',
      'Villa de Santos': 'villa_santos',
      'Vila Tibério': 'vila_tiberio',
      '20 Novembro': '20_novembro',
      'Amazonas-Norte': 'amazonas_norte',
      'Aparecida-GO': 'aparecida_goias',
      'Arraial Rio': 'arraial_rio',
      'Bernardo-SP': 'bernardo',
      'Capibaribe-PE': 'capibaribe',
      'Erechim': 'erechim',
      'Ferrim-Ceará': 'ferrim_ceara',
      'Florestal': 'florestal',
      'João Pessoa': 'joao_pessoa',
      'Londrinense': 'londrinense',
      'Manchester Catarinense': 'manchester_catarinense',
      'Real Alagoano': 'real_alagoano',
      'Real Zeca': 'real_zeca',
      'Rio Grande 1900': 'rio_grande_1900',
      'Rio Grande Do Norte': 'rio_grande_do_norte',
      'Rio Negro-AM': 'rio_negro',
      'Roraima FC': 'roraima',
      'São Jose dos Altos-PI': 'sao_jose_dos_altos',
      'Velha Figueira-SC': 'velha_figueira',
      '1920-AC': '1920',
      'Águia Branca': 'aguia_branca',
      'Brasília-Capital': 'brasilia_capital',
      'Caldas-MG': 'caldas',
      'Camaragibe': 'camaragibe',
      'Campina-PB': 'campina',
      'Caruaruense': 'caruarense',
      'Caxiense': 'caxiense',
      'Desportos-SP': 'desportos',
      'Feira-BA': 'feira',
      'Governador Valadares': 'governador_valadares',
      'Ingazeira': 'ingazeira',
      'Juazeiro do Norte': 'juazeiro_do_norte',
      'Maracapá': 'maracapa',
      'Nacional Manaus': 'nacional_manaus',
      'Nova Amsterdã': 'nova_amsterda',
      'Paranaense': 'paranaense',
      'Santa Maria': 'santa_maria',
      'São Luís': 'sao_luis',
      'Uniclinic': 'uniclinic',
    };

    final mapped = special[clubName];
    if (mapped != null) return mapped;

    return _slugify(clubName);
  }

  static String _slugify(String input) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
    const to = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';

    var out = input;
    for (int i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }

    out = out.toLowerCase();
    out = out.replaceAll('-', '_');
    out = out.replaceAll(' ', '_');
    out = out.replaceAll('.', '');
    out = out.replaceAll("'", '');
    out = out.replaceAll('/', '_');

    while (out.contains('__')) {
      out = out.replaceAll('__', '_');
    }

    return out;
  }
}
