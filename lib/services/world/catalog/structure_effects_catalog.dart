import 'package:footory26/services/world/catalog/structure_costs_catalog.dart';

class StructureEffectsCatalog {
  const StructureEffectsCatalog._();

  static String effectOf(ClubStructureType type, int level) {
    switch (type) {
      case ClubStructureType.base:
        return _base(level);

      case ClubStructureType.ct:
        return _ct(level);

      case ClubStructureType.scout:
        return _scout(level);

      case ClubStructureType.medico:
        return _medico(level);

      case ClubStructureType.financeiro:
        return _financeiro(level);

      case ClubStructureType.marketing:
        return _marketing(level);

      case ClubStructureType.estadio:
        return _estadio(level);

      case ClubStructureType.complexo:
        return _complexo(level);

      case ClubStructureType.comunicacao:
        return _comunicacao(level);
    }
  }

  static String _base(int level) {
    if (level <= 2) {
      return 'Revela 1–2 jogadores por ano. Overall possível: 30–65. Chance baixa de talentos fortes.';
    }

    if (level <= 4) {
      return 'Revela 1–2 jogadores por ano. Overall possível: 35–65.';
    }

    if (level <= 6) {
      return 'Revela 2–3 jogadores por ano. Overall possível: 42–65.';
    }

    if (level <= 8) {
      return 'Revela 3–5 jogadores por ano. Overall possível: 50–65.';
    }

    return 'Revela 4–7 jogadores por ano. Overall possível: 59–65.';
  }

  static String _ct(int level) {
    if (level <= 2) {
      return 'Treinos básicos. Evolução média de jogadores: +2%.';
    }

    if (level <= 4) {
      return 'Treinos organizados. Evolução média: +3%.';
    }

    if (level <= 6) {
      return 'Centro de treinamento estruturado. Evolução média: +4%.';
    }

    if (level <= 8) {
      return 'Centro de treinamento avançado. Evolução média: +5%.';
    }

    return 'Centro de treinamento de elite. Evolução média: +6%.';
  }

  static String _scout(int level) {
    if (level <= 2) {
      return 'Observação limitada. Baixa precisão de análise.';
    }

    if (level <= 4) {
      return 'Rede básica de observação. Precisão moderada.';
    }

    if (level <= 6) {
      return 'Boa rede de scouting. Chance maior de encontrar jogadores fortes.';
    }

    if (level <= 8) {
      return 'Scouting avançado. Alta precisão de análise.';
    }

    return 'Scouting de elite. Grande chance de encontrar talentos fortes.';
  }

  static String _medico(int level) {
    if (level <= 2) {
      return 'Departamento médico básico. Capacidade preventiva limitada.';
    }

    if (level <= 4) {
      return 'Estrutura médica em desenvolvimento. Reduz parte das ocorrências durante as partidas.';
    }

    if (level <= 6) {
      return 'Boa capacidade de prevenção e atendimento.';
    }

    if (level <= 8) {
      return 'Estrutura médica avançada, com baixa incidência de atendimentos.';
    }

    return 'Departamento médico de elite, com máxima capacidade preventiva.';
  }

  static String _financeiro(int level) {
    if (level <= 2) {
      return 'Gestão financeira básica. Contratos menos eficientes.';
    }

    if (level <= 4) {
      return 'Melhor controle de custos e negociações mais seguras.';
    }

    if (level <= 6) {
      return 'Gestão financeira eficiente. Maior estabilidade do clube.';
    }

    if (level <= 8) {
      return 'Administração moderna e altamente organizada.';
    }

    return 'Departamento financeiro de elite. Máxima eficiência contratual.';
  }

  static String _marketing(int level) {
    if (level <= 2) {
      return 'Marketing limitado. Baixo potencial de público.';
    }

    if (level <= 4) {
      return 'Divulgação moderada do clube. Capacidade comercial intermediária.';
    }

    if (level <= 6) {
      return 'Boa presença de marketing. Potencial de público maior.';
    }

    if (level <= 8) {
      return 'Estrutura comercial forte. Alta capacidade de geração de receita.';
    }

    return 'Marketing de elite. Alto potencial de público e patrocínio.';
  }

  static String _estadio(int level) {
    if (level <= 2) {
      return 'Estádio pequeno com baixa capacidade.';
    }

    if (level <= 4) {
      return 'Capacidade moderada de público.';
    }

    if (level <= 6) {
      return 'Boa capacidade de torcida.';
    }

    if (level <= 8) {
      return 'Grande arena moderna.';
    }

    return 'Estádio de elite com alta capacidade.';
  }

  static String _complexo(int level) {
    if (level <= 2) {
      return 'Estrutura geral básica. Limita bastante o crescimento do clube.';
    }

    if (level <= 4) {
      return 'Estrutura organizada. Libera evolução inicial das demais áreas.';
    }

    if (level <= 6) {
      return 'Complexo profissional que sustenta crescimento do clube.';
    }

    if (level <= 8) {
      return 'Complexo muito forte. Libera estruturas avançadas.';
    }

    return 'Complexo de elite. Libera o potencial máximo do clube.';
  }

  static String _comunicacao(int level) {
    if (level <= 2) {
      return 'Comunicação institucional limitada.';
    }

    if (level <= 4) {
      return 'Relação mais estável com imprensa e torcida.';
    }

    if (level <= 6) {
      return 'Boa gestão de comunicação do clube.';
    }

    if (level <= 8) {
      return 'Imagem institucional forte.';
    }

    return 'Comunicação de elite e ambiente institucional sólido.';
  }
}
