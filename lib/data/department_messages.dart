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
      'Temos vários jogadores com problemas físicos no momento.',
      'O departamento médico lida com uma carga alta de situações físicas no elenco.',
      'A condição física do grupo preocupa e exige atenção redobrada.',
    ],
    DepartmentMoodLevel.bad: [
      'Alguns atletas ainda precisam de atenção médica.',
      'O elenco carrega algumas pendências físicas que pedem cautela.',
      'Ainda há jogadores sob observação física no departamento médico.',
    ],
    DepartmentMoodLevel.stable: [
      'A situação física do elenco está sob controle.',
      'O departamento médico considera o quadro geral estável no momento.',
      'Fisicamente, o elenco segue em condição administrável.',
    ],
    DepartmentMoodLevel.good: [
      'A maioria dos jogadores está em boas condições físicas.',
      'O quadro físico atual do elenco é positivo para a sequência.',
      'O departamento médico vê o grupo em situação confortável neste momento.',
    ],
    DepartmentMoodLevel.excellent: [
      'O elenco está em excelente condição física.',
      'O departamento médico considera o momento físico do grupo muito forte.',
      'A condição atlética do elenco está em um dos melhores níveis da temporada.',
    ],
  },
  DepartmentType.marketing: {
    DepartmentMoodLevel.veryBad: [
      'O interesse do público pelo clube caiu nas últimas semanas.',
      'As ações recentes do clube geraram pouco impacto junto aos torcedores.',
      'O engajamento em torno da marca do clube caiu e preocupa o setor.',
    ],
    DepartmentMoodLevel.bad: [
      'Precisamos melhorar nossa presença junto aos torcedores.',
      'O clube ainda não conseguiu gerar a conexão esperada com seu público recente.',
      'O marketing entende que falta mais força na relação com a torcida.',
    ],
    DepartmentMoodLevel.stable: [
      'O interesse pelo clube segue estável.',
      'A presença do clube junto ao público se mantém sem grandes oscilações.',
      'O marketing vê um cenário controlado, mas ainda sem crescimento real.',
    ],
    DepartmentMoodLevel.good: [
      'O clube tem mantido boa visibilidade entre os torcedores.',
      'A imagem do clube segue positiva e com boa presença pública.',
      'As últimas ações mantiveram o clube em boa evidência entre os torcedores.',
    ],
    DepartmentMoodLevel.excellent: [
      'A popularidade do clube cresceu bastante recentemente.',
      'O clube vive uma fase muito forte de imagem e presença junto ao público.',
      'O marketing avalia que a marca do clube ganhou força real nas últimas semanas.',
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
      'O mercado está difícil no momento.',
      'As últimas observações trouxeram poucas oportunidades realmente interessantes.',
      'O scout enfrenta um período fraco de mercado nas análises recentes.',
    ],
    DepartmentMoodLevel.bad: [
      'Ainda não encontramos boas oportunidades no mercado.',
      'Os relatórios recentes indicam poucas opções realmente animadoras.',
      'O setor segue procurando, mas sem alvos que empolguem até aqui.',
    ],
    DepartmentMoodLevel.stable: [
      'O mercado segue sendo monitorado normalmente.',
      'O scout mantém rotina estável de observação sem grandes destaques recentes.',
      'O setor continua trabalhando de forma constante na leitura do mercado.',
    ],
    DepartmentMoodLevel.good: [
      'Encontramos alguns jogadores interessantes recentemente.',
      'Os últimos relatórios apontaram nomes que podem valer acompanhamento maior.',
      'O scout começou a reunir opções mais promissoras nas observações recentes.',
    ],
    DepartmentMoodLevel.excellent: [
      'Identificamos um jogador muito promissor no mercado.',
      'Um nome observado recentemente elevou bastante o entusiasmo do scout.',
      'O setor encontrou uma oportunidade que pode ter grande valor esportivo.',
    ],
  },
  DepartmentType.sportsComplex: {
    DepartmentMoodLevel.veryBad: [
      'Algumas áreas da infraestrutura precisam de melhorias urgentes.',
      'A estrutura atual do clube apresenta limitações que já incomodam o trabalho diário.',
      'O complexo do clube começa a mostrar sinais claros de desgaste operacional.',
    ],
    DepartmentMoodLevel.bad: [
      'A estrutura atual apresenta algumas limitações.',
      'O funcionamento geral do complexo segue, mas com restrições perceptíveis.',
      'Alguns setores da infraestrutura já pedem intervenção para render melhor.',
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
      'O complexo do clube vive um momento muito forte em termos de estrutura.',
      'O padrão atual da infraestrutura é visto internamente como um grande diferencial.',
    ],
  },
  DepartmentType.stadium: {
    DepartmentMoodLevel.veryBad: [
      'O estádio apresenta problemas que precisam ser resolvidos.',
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
      'O estádio tem recebido boa presença de público.',
      'O ambiente do estádio segue positivo e com boa resposta da torcida.',
      'O estádio vive um momento saudável, com presença consistente de público.',
    ],
    DepartmentMoodLevel.excellent: [
      'O estádio vive grande momento com forte presença de torcedores.',
      'A casa do clube atravessa fase muito positiva em ambiente e ocupação.',
      'O estádio se consolidou como um dos pontos fortes do momento do clube.',
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

const Map<DepartmentType, List<String>> rareEventMessagesByDepartment = {
  DepartmentType.academy: [
    'Encontramos um talento excepcional nas categorias de base.',
    'Um jovem com potencial gigantesco surgiu na base.',
    'Um nome muito acima da média apareceu nos relatórios mais recentes da base.',
  ],
  DepartmentType.medical: [
    'Nosso departamento médico implementou um novo protocolo de recuperação.',
    'Uma nova abordagem no acompanhamento físico começou a gerar respostas positivas.',
  ],
  DepartmentType.marketing: [
    'Uma nova oportunidade comercial surgiu para o clube.',
    'O clube abriu conversa com uma oportunidade que pode fortalecer sua imagem.',
  ],
  DepartmentType.communication: [
    'A última vitória teve grande destaque na imprensa.',
    'O clube entrou em pauta positiva nos principais espaços de cobertura esportiva.',
  ],
  DepartmentType.finance: [
    'Uma nova fonte de receita foi identificada para o clube.',
    'O financeiro encontrou uma possibilidade concreta de reforço nas entradas do clube.',
  ],
  DepartmentType.scouting: [
    'Encontramos um jogador muito interessante no mercado.',
    'Um talento pouco conhecido chamou nossa atenção recentemente.',
    'Um nome observado recentemente passou a ser tratado como oportunidade real.',
  ],
  DepartmentType.sportsComplex: [
    'As melhorias estruturais começaram a elevar o padrão do clube.',
    'A evolução da infraestrutura já começa a ser percebida na rotina interna.',
  ],
  DepartmentType.stadium: [
    'Tivemos lotação máxima no último jogo.',
    'O estádio viveu recentemente um de seus melhores ambientes da temporada.',
  ],
  DepartmentType.trainingCenter: [
    'Alguns jogadores mostraram grande evolução nos últimos treinos.',
    'O CT registrou recentemente um salto forte de intensidade e resposta do elenco.',
  ],
};

const Map<DepartmentType, List<String>> structureUpgradeMessagesByDepartment = {
  DepartmentType.academy: [
    'A nova estrutura vai ajudar muito no desenvolvimento dos jovens.',
    'As melhorias da base tendem a elevar a qualidade da formação a médio prazo.',
  ],
  DepartmentType.medical: [
    'As melhorias no departamento médico vão acelerar a recuperação dos atletas.',
    'A estrutura médica passa a oferecer mais segurança e agilidade ao elenco.',
  ],
  DepartmentType.marketing: [
    'As melhorias no setor devem fortalecer a marca do clube.',
    'O marketing ganha estrutura para ampliar a presença do clube junto ao público.',
  ],
  DepartmentType.communication: [
    'A comunicação do clube tende a ganhar mais alcance e organização.',
    'O setor de comunicação agora tem base melhor para controlar imagem e exposição.',
  ],
  DepartmentType.finance: [
    'A nova estrutura deve melhorar nossa gestão financeira.',
    'O financeiro ganha melhores condições para controlar e planejar o clube.',
  ],
  DepartmentType.scouting: [
    'Com essa melhoria, teremos melhores condições para observar o mercado.',
    'O scout passa a operar com base melhor para ampliar a busca por oportunidades.',
  ],
  DepartmentType.sportsComplex: [
    'A nova estrutura melhora o funcionamento geral do clube.',
    'O complexo passa a oferecer um padrão mais alto para a rotina interna.',
  ],
  DepartmentType.stadium: [
    'As melhorias no estádio devem elevar a experiência do torcedor.',
    'O estádio recebe base melhor para oferecer ambiente mais forte ao público.',
  ],
  DepartmentType.trainingCenter: [
    'As melhorias no CT já começam a ajudar no trabalho diário.',
    'O centro de treinamento passa a dar suporte melhor para a evolução do elenco.',
  ],
};

const Map<String, List<String>> contextualMessages = {
  'recent_win': [
    'A vitória da última rodada aumentou o interesse em torno do clube.',
    'O resultado recente ajudou a melhorar o ambiente do clube.',
    'O bom resultado recente trouxe mais confiança para o ambiente interno.',
  ],
  'recent_loss': [
    'A última derrota trouxe alguma pressão ao ambiente.',
    'O resultado recente aumentou a cobrança sobre o clube.',
    'O tropeço mais recente deixou o ambiente interno mais sensível.',
  ],
  'good_form': [
    'A boa fase do time tem fortalecido o ambiente interno.',
    'O momento positivo ajuda a dar mais confiança ao trabalho.',
    'A fase recente aumenta a sensação de estabilidade dentro do clube.',
  ],
  'bad_form': [
    'A fase atual exige mais atenção de todos os setores.',
    'O momento recente pede respostas rápidas dentro do clube.',
    'O clube vive um trecho que exige mais firmeza de todas as áreas.',
  ],
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
