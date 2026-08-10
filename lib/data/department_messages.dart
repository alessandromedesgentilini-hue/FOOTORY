import 'package:footory26/models/staff_department.dart';

const List<String> messageOpenings = [
  'Atualização interna:',
  'Relatório do setor:',
  'Resumo mais recente:',
  'Ponto de atenção:',
  'Nova leitura do departamento:',
];

const Map<DepartmentType, String> departmentTitles = {
  DepartmentType.sportsComplex: 'Infraestrutura do clube',
  DepartmentType.trainingCenter: 'Situação do CT',
  DepartmentType.academy: 'Relatório da Base',
  DepartmentType.scouting: 'Relatório de Observação',
  DepartmentType.finance: 'Atualização Financeira',
  DepartmentType.marketing: 'Atualização de Marketing',
  DepartmentType.communication: 'Relatório de Comunicação',
  DepartmentType.medical: 'Situação do Elenco',
  DepartmentType.stadium: 'Situação do Estádio',
};

const Map<DepartmentType, Map<DepartmentMoodLevel, List<String>>>
    stateMessagesByDepartment = {
  DepartmentType.academy: {
    DepartmentMoodLevel.veryBad: [
      'Estamos com dificuldade para desenvolver nomes realmente promissores na base.',
      'A safra atual da base ainda não entregou o nível de talento que esperávamos.',
      'O desenvolvimento dos jovens segue abaixo do ideal e exige mais atenção.',
    ],
    DepartmentMoodLevel.bad: [
      'Alguns jovens estão evoluindo mais lentamente do que imaginávamos.',
      'A base até mantém atividade, mas ainda sem grandes respostas técnicas.',
      'Os relatórios mais recentes mostram progresso abaixo do esperado entre os jovens.',
    ],
    DepartmentMoodLevel.stable: [
      'A base segue trabalhando normalmente no desenvolvimento dos atletas.',
      'Os jovens mantêm uma rotina estável de formação dentro do clube.',
      'A evolução da base ocorre de forma controlada, sem grandes picos no momento.',
    ],
    DepartmentMoodLevel.good: [
      'Temos alguns jovens promissores evoluindo bem na base.',
      'A comissão da base vê sinais positivos em alguns nomes do elenco jovem.',
      'Os relatórios internos mostram uma geração com bons indícios de crescimento.',
    ],
    DepartmentMoodLevel.excellent: [
      'Um jovem muito promissor chamou atenção nos últimos treinos da base.',
      'A base revelou recentemente um nome que empolgou bastante os avaliadores internos.',
      'Há forte otimismo com um talento da base que começou a se destacar acima do restante.',
    ],
  },
  DepartmentType.medical: {
    DepartmentMoodLevel.veryBad: [
      'Nossa capacidade de prevenção ainda é bastante limitada.',
      'A estrutura atual deixa o setor mais exposto a ocorrências que exigem atendimento durante os jogos.',
      'O nível atual ainda está abaixo do padrão que considero adequado para o setor.',
    ],
    DepartmentMoodLevel.bad: [
      'Ainda temos limitações importantes na capacidade preventiva do departamento.',
      'A estrutura precisa evoluir para reduzir melhor a incidência de atendimentos durante as partidas.',
      'O setor funciona, mas ainda com uma margem grande para melhorar a prevenção.',
    ],
    DepartmentMoodLevel.stable: [
      'O departamento opera hoje com uma capacidade preventiva intermediária.',
      'A estrutura atual permite um trabalho médico estável, dentro do nível disponível.',
      'O setor já oferece uma base funcional de prevenção para as partidas.',
    ],
    DepartmentMoodLevel.good: [
      'Nossa estrutura já oferece uma boa capacidade de prevenção.',
      'O nível atual reduz de forma importante a incidência de situações que exigem atendimento.',
      'O departamento trabalha hoje com uma estrutura segura e eficiente para sua função.',
    ],
    DepartmentMoodLevel.excellent: [
      'Nossa capacidade preventiva está entre os níveis mais altos possíveis.',
      'A estrutura atual permite ao setor trabalhar com um padrão médico muito alto.',
      'O departamento dispõe hoje de sua melhor capacidade para reduzir ocorrências médicas durante os jogos.',
    ],
  },
  DepartmentType.marketing: {
    DepartmentMoodLevel.veryBad: [
      'Nossa estrutura comercial ainda limita bastante o potencial de receita do clube.',
      'Hoje trabalhamos com capacidade reduzida tanto em patrocínio quanto na atração de público.',
      'O nível atual do Marketing deixa pouco espaço para explorar o potencial comercial do clube.',
    ],
    DepartmentMoodLevel.bad: [
      'A estrutura ainda precisa evoluir para ampliar nossa capacidade comercial.',
      'Nosso nível atual ainda limita o retorno que conseguimos gerar com patrocínio e público.',
      'Ainda temos uma margem importante de crescimento na capacidade do setor.',
    ],
    DepartmentMoodLevel.stable: [
      'O Marketing opera hoje em um nível intermediário de capacidade comercial.',
      'A estrutura atual já sustenta uma geração razoável de receita e público.',
      'Temos uma base funcional, mas ainda há bastante espaço para ampliar o potencial comercial.',
    ],
    DepartmentMoodLevel.good: [
      'Nossa estrutura já oferece boa capacidade para gerar receita comercial.',
      'O nível atual do Marketing já amplia bastante nosso potencial de patrocínio e público.',
      'Hoje o setor trabalha com uma estrutura forte e consegue entregar um retorno comercial relevante.',
    ],
    DepartmentMoodLevel.excellent: [
      'O Marketing trabalha hoje com capacidade comercial de primeiro nível.',
      'A estrutura atual permite explorar quase todo o potencial de patrocínio e atração de público do clube.',
      'Temos uma estrutura capaz de gerar um retorno comercial muito alto para o tamanho atual do clube.',
    ],
  },
  DepartmentType.communication: {
    DepartmentMoodLevel.veryBad: [
      'A imprensa tem sido bastante crítica ao clube.',
      'A cobertura recente da mídia aumentou a pressão sobre o ambiente interno.',
      'O clube vive um momento de exposição negativa na imprensa.',
    ],
    DepartmentMoodLevel.bad: [
      'Algumas críticas da imprensa surgiram após os últimos resultados.',
      'A comunicação monitora um aumento recente na cobrança da mídia.',
      'A imagem externa do clube sofreu desgaste depois dos resultados mais recentes.',
    ],
    DepartmentMoodLevel.stable: [
      'A cobertura da imprensa segue neutra no momento.',
      'O clube não vive pressão especial da mídia neste momento.',
      'A leitura externa do momento é equilibrada e sem grandes extremos.',
    ],
    DepartmentMoodLevel.good: [
      'A imprensa tem destacado pontos positivos do clube.',
      'A cobertura recente passou a reconhecer aspectos positivos do trabalho.',
      'O noticiário em torno do clube ganhou tom mais favorável nas últimas semanas.',
    ],
    DepartmentMoodLevel.excellent: [
      'O clube tem recebido ótima repercussão na mídia.',
      'A comunicação avalia que a imagem externa do clube está em alta.',
      'O momento do clube vem sendo muito bem recebido pela imprensa.',
    ],
  },
  DepartmentType.finance: {
    DepartmentMoodLevel.veryBad: [
      'A situação financeira exige atenção urgente.',
      'Os números recentes colocam o financeiro em estado de alerta.',
      'O controle financeiro do clube passa por um momento bastante delicado.',
    ],
    DepartmentMoodLevel.bad: [
      'Precisamos controlar melhor nossos gastos.',
      'O financeiro entende que o clube precisa agir com mais cautela nas despesas.',
      'O momento pede mais cuidado com o equilíbrio das contas.',
    ],
    DepartmentMoodLevel.stable: [
      'As finanças do clube estão equilibradas.',
      'O clube mantém suas contas em condição estável no momento.',
      'A situação financeira segue controlada, sem grandes sobressaltos.',
    ],
    DepartmentMoodLevel.good: [
      'O clube apresenta uma boa saúde financeira.',
      'As contas do clube mostram um quadro positivo para a sequência.',
      'O departamento financeiro vê margem confortável para seguir com estabilidade.',
    ],
    DepartmentMoodLevel.excellent: [
      'As finanças do clube estão em excelente forma.',
      'O momento financeiro do clube é um dos pontos fortes da estrutura atual.',
      'O clube atravessa um cenário financeiro muito saudável.',
    ],
  },
  DepartmentType.scouting: {
    DepartmentMoodLevel.veryBad: [
      'A capacidade de observação do setor está limitada pela escassez de oportunidades no mercado atual.',
      'A qualidade dos relatórios recentes foi prejudicada pela ausência de alvos relevantes em nosso raio de atuação.',
      'A eficiência da leitura de mercado do setor está reduzida devido às condições atuais de observação.',
    ],
    DepartmentMoodLevel.bad: [
      'O alcance de nossa observação ainda não identificou alvos com potencial suficiente para justificar recomendações.',
      'A análise recente das observações indicou baixa densidade de perfis com características alinhadas ao que precisamos.',
      'O setor mantém sua capacidade de monitoramento, mas ainda não foi possível identificar perfis que atendam aos requisitos mínimos.',
    ],
    DepartmentMoodLevel.stable: [
      'O mercado segue sendo monitorado normalmente.',
      'A eficiência da observação se mantém estável, sem variações significativas na qualidade das leituras realizadas.',
      'O setor continua trabalhando de forma constante na leitura do mercado.',
    ],
    DepartmentMoodLevel.good: [
      'A capacidade de identificação de perfis relevantes melhorou nas últimas observações realizadas.',
      'A qualidade dos relatórios recentes indica uma melhora na precisão da leitura de mercado.',
      'A leitura de mercado tem se mostrado mais alinhada com os requisitos técnicos definidos para o elenco.',
    ],
    DepartmentMoodLevel.excellent: [
      'A capacidade de observação do setor alcançou seu nível mais alto nos últimos levantamentos realizados.',
      'A precisão dos rastreamentos recentes alcançou nível superior, permitindo leituras mais detalhadas de potenciais.',
      'A eficiência da observação do setor atingiu patamar excepcional, com leituras de alta consistência sobre os alvos monitorados.',
    ],
  },
  DepartmentType.sportsComplex: {
    DepartmentMoodLevel.veryBad: [
      'A infraestrutura atual limita bastante a capacidade de crescimento do clube.',
      'A estrutura atual do clube apresenta limitações que já incomodam o trabalho diário.',
      'O nível atual do Complexo impõe limitações importantes às demais estruturas.',
    ],
    DepartmentMoodLevel.bad: [
      'A estrutura atual apresenta algumas limitações.',
      'O funcionamento geral do complexo segue, mas com restrições perceptíveis.',
      'Algumas áreas do clube já estão próximas do limite permitido pelo Complexo atual.',
    ],
    DepartmentMoodLevel.stable: [
      'A infraestrutura está funcionando normalmente.',
      'O complexo do clube mantém operação estável dentro do esperado.',
      'A estrutura geral do clube segue atendendo sem maiores problemas.',
    ],
    DepartmentMoodLevel.good: [
      'A estrutura do clube atende bem às necessidades atuais.',
      'O complexo esportivo oferece boa base de trabalho para a rotina do clube.',
      'A avaliação atual da infraestrutura é positiva e funcional.',
    ],
    DepartmentMoodLevel.excellent: [
      'A infraestrutura do clube está em excelente estado.',
      'O complexo do clube oferece hoje uma estrutura de nível muito alto.',
      'O padrão atual da infraestrutura é visto internamente como um grande diferencial.',
    ],
  },
  DepartmentType.stadium: {
    DepartmentMoodLevel.veryBad: [
      'A capacidade física do estádio limita bastante nossa capacidade de receber público.',
      'A estrutura do estádio já começa a limitar mais do que deveria.',
      'O estádio atravessa um momento de funcionamento abaixo do ideal.',
    ],
    DepartmentMoodLevel.bad: [
      'Algumas melhorias no estádio seriam importantes.',
      'O estádio ainda atende, mas com limitações que já merecem atenção.',
      'Há pontos no estádio que poderiam ser melhorados para elevar o padrão atual.',
    ],
    DepartmentMoodLevel.stable: [
      'O estádio está funcionando normalmente.',
      'A operação do estádio segue estável no momento.',
      'O estádio cumpre bem seu papel dentro do padrão atual do clube.',
    ],
    DepartmentMoodLevel.good: [
      'A estrutura atual já oferece boa capacidade para receber público.',
      'O estádio já oferece uma estrutura sólida para os jogos do clube.',
      'O nível atual coloca o estádio em um padrão bastante competitivo.',
    ],
    DepartmentMoodLevel.excellent: [
      'O estádio alcançou uma capacidade muito alta para receber a torcida.',
      'A estrutura atual coloca a casa do clube entre seus principais ativos.',
      'O estádio é hoje um dos pontos fortes da estrutura do clube.',
    ],
  },
  DepartmentType.trainingCenter: {
    DepartmentMoodLevel.veryBad: [
      'Os treinos não estão rendendo como esperado.',
      'A comissão percebe perda de intensidade e resposta abaixo do ideal no CT.',
      'O trabalho diário no CT atravessa um momento preocupante.',
    ],
    DepartmentMoodLevel.bad: [
      'Precisamos melhorar a intensidade dos treinos.',
      'O CT ainda não conseguiu alcançar o nível de resposta esperado.',
      'Há sensação interna de que o trabalho diário pode render mais.',
    ],
    DepartmentMoodLevel.stable: [
      'Os treinos seguem normalmente no CT.',
      'O funcionamento do CT está dentro da rotina prevista.',
      'A preparação no centro de treinamento segue em linha estável.',
    ],
    DepartmentMoodLevel.good: [
      'Os jogadores têm respondido bem aos treinos.',
      'A comissão observa boa resposta do elenco ao trabalho no CT.',
      'O desempenho do grupo nos treinos tem sido positivo recentemente.',
    ],
    DepartmentMoodLevel.excellent: [
      'O nível de intensidade dos treinos está muito alto.',
      'O CT vive um momento excelente de resposta, concentração e intensidade.',
      'A comissão avalia que o rendimento diário do grupo está em alto nível.',
    ],
  },
};

const Map<DepartmentType, List<String>> preMatchMessagesByDepartment = {
  DepartmentType.communication: [
    'A imprensa está acompanhando a partida com atenção.',
    'O jogo gerou expectativa externa acima do normal.',
  ],
  DepartmentType.trainingCenter: [
    'Os jogadores chegam bem preparados para a partida.',
    'O CT entende que o grupo chega em condição boa para competir.',
  ],
};

const Map<DepartmentType, List<String>> postMatchMessagesByDepartment = {
  DepartmentType.communication: [
    'A vitória teve boa repercussão entre os torcedores.',
    'A derrota gerou críticas da imprensa.',
    'O jogo recente teve impacto direto na leitura externa do clube.',
  ],
  DepartmentType.medical: [
    'Vamos monitorar a situação física do elenco após a partida.',
    'O departamento médico acompanha de perto a resposta física do grupo após o jogo.',
  ],
};

const Map<DepartmentType, List<String>> achievementMessagesByDepartment = {
  DepartmentType.communication: [
    'O clube entrou em destaque após a conquista recente.',
    'A conquista recente ampliou a exposição positiva do clube.',
  ],
  DepartmentType.finance: [
    'A conquista fortalece a imagem e o valor do clube.',
    'O resultado relevante tende a gerar reflexos positivos fora de campo.',
  ],
};

const String departmentMonthlyCostDescription =
    'O custo mensal inclui manutenção e salários da equipe responsável pelo setor.';
