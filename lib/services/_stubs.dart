// lib/services/_stubs.dart
library services_stubs;

// Ponto único que a UI importa para acessar os serviços.
// Mantemos tudo centralizado reexportando os tipos reais do módulo de evolução,
// evitando duplicação de classes e conflitos de nomes.
//
// Se no futuro surgirem novos tipos públicos em `evolucao_service.dart`,
// basta adicioná-los no `show` abaixo.

export 'evolucao/evolucao_service.dart'
    show PlanoTreino, CartaEvolucao, EvolucaoService;
