// lib/services/evolucao/plano_treino_info.dart
//
// Registry de planos de treino para UI.
// ✅ MVP-safe: não depende do evolucao_service.dart (evita undefined_class).
// Depois, se quiser, você move o model PlanoTreino para um arquivo próprio
// e importa aqui.

class PlanoTreino {
  final String id;

  /// Título exibido na UI
  final String titulo;

  /// Nome curto (opcional)
  final String nome;

  /// Quantos pontos “crus” gera por semana (ou por ciclo)
  final int pontosPorSemana;

  /// Pesos de atributos (chave -> peso). Ex.: {'passe_curto': 0.8}
  final Map<String, double> pesosAtributos;

  const PlanoTreino({
    required this.id,
    required this.titulo,
    required this.nome,
    required this.pontosPorSemana,
    required this.pesosAtributos,
  });

  factory PlanoTreino.ofensivo() {
    return const PlanoTreino(
      id: 'pt_ofensivo',
      titulo: 'Ofensivo',
      nome: 'Ofensivo',
      pontosPorSemana: 4,
      pesosAtributos: {
        'finalizacao': 1.0,
        'presenca_ofensiva': 0.7,
        'drible': 0.7,
        'dominio_conducao': 0.7,
        'passe_curto': 0.5,
        'velocidade': 0.4,
      },
    );
  }

  factory PlanoTreino.defensivo() {
    return const PlanoTreino(
      id: 'pt_defensivo',
      titulo: 'Defensivo',
      nome: 'Defensivo',
      pontosPorSemana: 4,
      pesosAtributos: {
        'marcacao': 1.0,
        'cobertura_defensiva': 0.8,
        'desarme': 0.8,
        'antecipacao': 0.6,
        'forca': 0.5,
        'resistencia': 0.4,
      },
    );
  }

  factory PlanoTreino.equilibrado() {
    return const PlanoTreino(
      id: 'pt_equilibrado',
      titulo: 'Equilibrado',
      nome: 'Equilibrado',
      pontosPorSemana: 4,
      pesosAtributos: {
        'passe_curto': 0.7,
        'passe_longo': 0.5,
        'tomada_decisao': 0.5,
        'resistencia': 0.5,
        'velocidade': 0.4,
        'marcacao': 0.4,
      },
    );
  }
}

class PlanoTreinoInfo {
  final String id;
  final String nome;
  final String? descricao;

  const PlanoTreinoInfo({
    required this.id,
    required this.nome,
    this.descricao,
  });
}

// Adaptador: Info -> PlanoTreino detalhado
extension PlanoTreinoInfoX on PlanoTreinoInfo {
  PlanoTreino toDetalhado() {
    switch (id) {
      case 'pt_ofensivo':
        return PlanoTreino.ofensivo();
      case 'pt_defensivo':
        return PlanoTreino.defensivo();
      case 'pt_equilibrado':
        return PlanoTreino.equilibrado();
      default:
        return const PlanoTreino(
          id: 'pt_custom',
          titulo: 'Personalizado',
          nome: 'Custom',
          pontosPorSemana: 4,
          pesosAtributos: {
            'passe_curto': 0.8,
            'marcacao': 0.5,
          },
        );
    }
  }
}

// Registry simples para listar na UI
const planosInfoPadrao = <PlanoTreinoInfo>[
  PlanoTreinoInfo(
    id: 'pt_ofensivo',
    nome: 'Ofensivo',
    descricao: 'Foco em ataque, finalização e construção.',
  ),
  PlanoTreinoInfo(
    id: 'pt_defensivo',
    nome: 'Defensivo',
    descricao: 'Ênfase em marcação, força e posicionamento.',
  ),
  PlanoTreinoInfo(
    id: 'pt_equilibrado',
    nome: 'Equilibrado',
    descricao: 'Distribuição homogênea dos treinos.',
  ),
];
