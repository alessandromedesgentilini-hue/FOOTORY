import 'package:footory26/models/permanent_staff_member.dart';

class PermanentStaffCatalog {
  PermanentStaffCatalog._();

  static const PermanentStaffMember assistantCoach = PermanentStaffMember(
    id: 'permanent_assistant_coach',
    name: 'Emanuel Braga',
    role: PermanentStaffRole.assistantCoach,
    portraitAsset: 'assets/faces/permanent_staff/assistant_coach.png',
    biography:
        'Emanuel Braga passou por inúmeros clubes menores e exerceu diferentes '
        'funções dentro do futebol. Conheceu vestiários difíceis, projetos '
        'curtos e realidades muito distintas antes de perceber que seu maior '
        'talento estava em apoiar treinadores, organizar o ambiente e dar '
        'estabilidade ao trabalho diário. Experiente e respeitado nos '
        'bastidores, encontrou na função de auxiliar técnico o lugar onde '
        'melhor consegue contribuir.',
    jobDescription:
        'Trabalha diariamente ao lado do treinador e participa da preparação '
        'dos treinamentos, da análise dos adversários e da organização da '
        'rotina esportiva. Atua como ligação entre a comissão técnica, o '
        'elenco e a direção de futebol, ajudando a transformar decisões '
        'estratégicas em trabalho de campo.',
  );

  static const PermanentStaffMember performanceAnalyst = PermanentStaffMember(
    id: 'permanent_performance_analyst',
    name: 'Paulina Ferreira',
    role: PermanentStaffRole.performanceAnalyst,
    portraitAsset: 'assets/faces/permanent_staff/performance_analyst.png',
    biography: 'Paulina Ferreira cresceu acompanhando o avô, uma figura muito '
        'respeitada no futebol amador de sua região. Desde pequena aprendeu a '
        'observar o jogo com atenção e desenvolveu uma capacidade incomum de '
        'perceber detalhes, padrões e comportamentos que frequentemente '
        'passam despercebidos. Hoje transforma essa leitura particular em '
        'análises claras para a comissão técnica e para a direção de futebol.',
    jobDescription:
        'Observa partidas, treinamentos e indicadores de desempenho para '
        'identificar padrões, pontos fortes, fragilidades e oportunidades de '
        'melhoria. Seus relatórios ajudam a comissão técnica e a direção de '
        'futebol a avaliar o rendimento coletivo e individual dos atletas.',
  );

  static const PermanentStaffMember fitnessCoach = PermanentStaffMember(
    id: 'permanent_fitness_coach',
    name: 'Win Wei',
    role: PermanentStaffRole.fitnessCoach,
    portraitAsset: 'assets/faces/permanent_staff/fitness_coach.png',
    biography:
        'Win Wei foi ginasta olímpica e construiu sua formação em ambientes de '
        'altíssimo rendimento. Após se aposentar, mudou-se para Portugal para '
        'trabalhar com preparação esportiva e acabou encontrando no futebol '
        'uma nova paixão. Aprendeu português e desenvolveu uma metodologia que '
        'combina disciplina, ciência e cuidado humano. No Brasil, começa a '
        'ganhar reconhecimento por exigir muito dos atletas sem esquecer que, '
        'antes de tudo, eles são pessoas.',
    jobDescription:
        'Planeja o trabalho físico do elenco durante toda a temporada, '
        'equilibrando intensidade, condicionamento, recuperação e prevenção '
        'de lesões. Também acompanha o bem-estar dos atletas para garantir que '
        'a busca por desempenho respeite os limites humanos de cada jogador.',
  );

  static const PermanentStaffMember goalkeeperCoach = PermanentStaffMember(
    id: 'permanent_goalkeeper_coach',
    name: 'Javier Cárdenas',
    role: PermanentStaffRole.goalkeeperCoach,
    portraitAsset: 'assets/faces/permanent_staff/goalkeeping_coach.png',
    biography: 'Javier Cárdenas foi goleiro da seleção peruana e construiu uma '
        'carreira marcada por disciplina, seriedade e regularidade. Uma grave '
        'lesão no joelho interrompeu sua trajetória dentro de campo, mas não '
        'sua ligação com o futebol. Depois de se aposentar, dedicou-se ao '
        'estudo técnico da posição e tornou-se treinador de goleiros. '
        'Reservado e extremamente focado, acredita que grandes goleiros são '
        'formados tanto pela técnica quanto pela força mental.',
    jobDescription:
        'É responsável pelo desenvolvimento técnico, tático e mental dos '
        'goleiros do clube. Trabalha fundamentos específicos da posição, '
        'posicionamento, reflexos, tomada de decisão, jogo com os pés e '
        'preparação para situações de pressão.',
  );

  static const List<PermanentStaffMember> all = <PermanentStaffMember>[
    assistantCoach,
    performanceAnalyst,
    fitnessCoach,
    goalkeeperCoach,
  ];

  static PermanentStaffMember? byId(String id) {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) return null;

    for (final member in all) {
      if (member.id == normalizedId) {
        return member;
      }
    }

    return null;
  }

  static PermanentStaffMember? byRole(
    PermanentStaffRole role,
  ) {
    for (final member in all) {
      if (member.role == role) {
        return member;
      }
    }

    return null;
  }

  static List<PermanentStaffMember> validateCatalog() {
    return all
        .where((member) => !member.hasRequiredData)
        .toList(growable: false);
  }
}
