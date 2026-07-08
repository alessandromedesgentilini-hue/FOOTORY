// lib/services/_stubs.dart
//
// Em vez de duplicar tipos/assinaturas, reexporta os serviços reais
// para a UI usar as mesmas assinaturas.

export 'evolucao/evolucao_service.dart'
    show PlanoTreino, CartaEvolucao, EvolucaoService;

// (Se precisar no futuro, reexporte outros serviços aqui também.)
// Nada de imports não usados aqui pra não gerar warnings.
