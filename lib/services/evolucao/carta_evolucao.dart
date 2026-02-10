// lib/services/evolucao/carta_evolucao.dart
//
// Modelo robusto de "Carta de Evolução".
// - Imutável, com copyWith(), toJson()/fromJson() e ==/hashCode.
// - Compatível com códigos numéricos (EvolucaoCodes) via fromCodigo().
// - ID em string (slug/uuid), para uso estável em savegames.
//
// Exemplo de uso:
//   final c1 = CartaEvolucao(id: 'mais_tecnica', titulo: 'Mais Técnica (+1)');
//   final c2 = CartaEvolucao.fromCodigo(EvolucaoCodes.cartaMaisTecnica);

import 'evolucao_codes.dart'; // <- mesmo diretório

class CartaEvolucao {
  /// Identificador estável (ex.: 'mais_tecnica', 'boost_fisico', uuid, etc.)
  final String id;

  /// Título curto exibível (ex.: 'Mais Técnica (+1)')
  final String titulo;

  /// Texto/descrição opcional da carta (ex.: efeito, duração, notas)
  final String? texto;

  const CartaEvolucao({
    required this.id,
    required this.titulo,
    this.texto,
  });

  /// Fábrica conveniente para cartas conhecidas por código numérico.
  /// Mantém compat com `EvolucaoCodes.*`.
  factory CartaEvolucao.fromCodigo(int codigo) {
    switch (codigo) {
      case EvolucaoCodes.cartaMaisTecnica:
        return const CartaEvolucao(
          id: 'mais_tecnica',
          titulo: 'Mais Técnica (+1)',
          texto: 'Concede +1 ponto no pilar técnico do(s) jogador(es) alvo(s).',
        );
      case EvolucaoCodes.cartaMaisPasse:
        return const CartaEvolucao(
          id: 'mais_passe',
          titulo: 'Mais Passe (+1)',
          texto: 'Concede +1 em atributos de passe/visão do(s) alvo(s).',
        );
      case EvolucaoCodes.cartaMaisMarcacao:
        return const CartaEvolucao(
          id: 'mais_marcacao',
          titulo: 'Mais Marcação (+1)',
          texto: 'Concede +1 em atributos defensivos/marcação do(s) alvo(s).',
        );
      default:
        return CartaEvolucao(
          id: 'carta_$codigo',
          titulo: 'Carta $codigo',
          texto: 'Carta de evolução (código $codigo).',
        );
    }
  }

  /// Cria uma cópia modificada.
  CartaEvolucao copyWith({
    String? id,
    String? titulo,
    String? texto,
  }) {
    return CartaEvolucao(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      texto: texto ?? this.texto,
    );
  }

  /// Serialização para persistência.
  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'texto': texto,
      };

  /// Desserialização a partir de JSON.
  factory CartaEvolucao.fromJson(Map<String, dynamic> json) {
    return CartaEvolucao(
      id: (json['id'] as String?) ?? '',
      titulo: (json['titulo'] as String?) ?? '',
      texto: json['texto'] as String?,
    );
  }

  @override
  String toString() => 'CartaEvolucao(id: $id, titulo: $titulo)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartaEvolucao &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          titulo == other.titulo &&
          texto == other.texto;

  @override
  int get hashCode => Object.hash(id, titulo, texto);
}
