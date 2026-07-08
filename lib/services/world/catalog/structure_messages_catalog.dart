import 'package:footory26/services/world/catalog/structure_costs_catalog.dart';

class StructureMessagesCatalog {
  const StructureMessagesCatalog._();

  static String phaseLabel(int level) {
    if (level >= 10) return 'Estrutura Mundial';
    if (level >= 8) return 'Elite';
    if (level >= 4) return 'Estrutura Sólida';
    return 'Estrutura Básica';
  }

  static String shortStatus(int level) {
    if (level >= 10) return 'Mundial';
    if (level >= 8) return 'Elite';
    if (level >= 4) return 'Sólida';
    return 'Básica';
  }

  static String upgradeTitle(ClubStructureType type, int newLevel) {
    final name = StructureCostsCatalog.labelOf(type);
    final phase = phaseLabel(newLevel);
    return '$name evoluiu para o nível $newLevel';
  }

  static String upgradeMessage(ClubStructureType type, int newLevel) {
    final phase = phaseLabel(newLevel);
    final specific = _specificEffect(type, newLevel);

    return '$specific\n\nStatus atual da estrutura: $phase.';
  }

  static String confirmMessage({
    required ClubStructureType type,
    required int currentLevel,
    required int nextLevel,
    required int upgradeCost,
    required int currentMaintenance,
    required int nextMaintenance,
  }) {
    final name = StructureCostsCatalog.labelOf(type);
    final deltaMaintenance = nextMaintenance - currentMaintenance;

    return '$name vai evoluir do nível $currentLevel para o nível $nextLevel.\n\n'
        'Custo: ${_money(upgradeCost)}\n'
        'Manutenção atual: ${_money(currentMaintenance)}/mês\n'
        'Nova manutenção: ${_money(nextMaintenance)}/mês\n'
        'Aumento mensal: ${_money(deltaMaintenance)}/mês\n\n'
        'Essa decisão não poderá ser revertida.';
  }

  static String _specificEffect(ClubStructureType type, int newLevel) {
    final tier = _tier(newLevel);

    switch (type) {
      case ClubStructureType.complexo:
        if (tier == 0) {
          return 'O complexo esportivo começa a se organizar. O clube ganha uma base física mais confiável para crescer.';
        }
        if (tier == 1) {
          return 'O complexo esportivo já sustenta um clube competitivo. A sensação de organização passa a fazer parte da rotina.';
        }
        if (tier == 2) {
          return 'O complexo esportivo entra em nível de elite. O clube passa a ter uma infraestrutura digna de grandes projetos.';
        }
        return 'O complexo esportivo atinge padrão internacional. O clube entra definitivamente em outro patamar estrutural.';
      case ClubStructureType.ct:
        if (tier == 0) {
          return 'O CT melhora e os jogadores já sentem condições mais decentes de treino e preparação.';
        }
        if (tier == 1) {
          return 'O CT se consolida como uma estrutura forte. O ambiente de evolução dos atletas muda de nível.';
        }
        if (tier == 2) {
          return 'O CT atinge nível de elite. O clube passa a oferecer preparação comparável à de grandes equipes.';
        }
        return 'O CT chega a padrão mundial. O salto de preparação é definitivo e o clube entra em outro patamar.';
      case ClubStructureType.base:
        if (tier == 0) {
          return 'A base começa a ganhar forma. Jovens atletas passam a ter um ambiente mais sério para desenvolvimento.';
        }
        if (tier == 1) {
          return 'A base do clube se torna sólida. A formação de talentos começa a parecer um projeto real.';
        }
        if (tier == 2) {
          return 'A base alcança nível de elite. O clube passa a ser visto como referência em formação.';
        }
        return 'A base atinge estrutura mundial. O clube agora tem potencial para formar talentos em outro patamar.';
      case ClubStructureType.scout:
        if (tier == 0) {
          return 'O departamento de scout melhora e os relatórios começam a ficar mais úteis.';
        }
        if (tier == 1) {
          return 'O scout se torna confiável. O clube passa a identificar melhor os perfis que realmente precisa.';
        }
        if (tier == 2) {
          return 'O scout alcança nível de elite. O clube passa a operar com observação altamente qualificada.';
        }
        return 'O scout chega a padrão mundial. O clube agora observa talentos com alcance e precisão de topo.';
      case ClubStructureType.financeiro:
        if (tier == 0) {
          return 'O departamento financeiro começa a se organizar. O clube passa a lidar melhor com seus recursos.';
        }
        if (tier == 1) {
          return 'O financeiro ganha consistência. A gestão começa a parecer a de um clube bem administrado.';
        }
        if (tier == 2) {
          return 'O financeiro atinge nível de elite. O clube passa a operar com muito mais eficiência e segurança.';
        }
        return 'O financeiro alcança padrão mundial. O clube entra em um novo nível de organização e controle.';
      case ClubStructureType.marketing:
        if (tier == 0) {
          return 'O marketing melhora e o clube começa a se apresentar de forma mais profissional.';
        }
        if (tier == 1) {
          return 'O marketing se consolida. A força da marca do clube passa a crescer de forma perceptível.';
        }
        if (tier == 2) {
          return 'O marketing atinge nível de elite. O clube passa a gerar mais impacto e valor de imagem.';
        }
        return 'O marketing chega a padrão mundial. O clube agora carrega uma marca de grande peso no cenário.';
      case ClubStructureType.comunicacao:
        if (tier == 0) {
          return 'A comunicação do clube melhora e a imagem institucional começa a ganhar mais estabilidade.';
        }
        if (tier == 1) {
          return 'A comunicação se torna sólida. O clube passa a controlar melhor sua narrativa e presença pública.';
        }
        if (tier == 2) {
          return 'A comunicação alcança nível de elite. O clube passa a se posicionar com força diante da imprensa.';
        }
        return 'A comunicação chega a padrão mundial. O clube entra em um novo nível de presença e influência.';
      case ClubStructureType.medico:
        if (tier == 0) {
          return 'O departamento médico melhora e o clube passa a oferecer cuidados mais confiáveis aos atletas.';
        }
        if (tier == 1) {
          return 'O departamento médico se consolida. A sensação de segurança física no elenco muda de nível.';
        }
        if (tier == 2) {
          return 'O departamento médico atinge nível de elite. O clube passa a operar com alto padrão de cuidado e recuperação.';
        }
        return 'O departamento médico alcança padrão mundial. O clube entra em outro patamar de suporte físico e profissional.';
      case ClubStructureType.estadio:
        if (tier == 0) {
          return 'O estádio melhora e o clube começa a oferecer uma casa mais digna para torcida e elenco.';
        }
        if (tier == 1) {
          return 'O estádio se consolida como uma verdadeira casa do clube. O ambiente ganha força e identidade.';
        }
        if (tier == 2) {
          return 'O estádio entra em nível de elite. O clube passa a ter um palco de respeito para grandes partidas.';
        }
        return 'O estádio atinge padrão mundial. O salto é definitivo e o clube entra em outro patamar diante de sua torcida.';
    }
  }

  static int _tier(int level) {
    if (level >= 10) return 3;
    if (level >= 8) return 2;
    if (level >= 4) return 1;
    return 0;
  }

  static String _money(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return 'R\$ ${buffer.toString().split('').reversed.join()}';
  }
}
