// lib/seeds/times_seed.dart
import '../models/time_model.dart';
import '../models/estilos.dart';

/// Semente simples de times para iniciar o jogo.
List<TimeModel> seedTimesPadrao() => [
      TimeModel.basico(nome: 'Inter Sul', estilo: Estilo.sulAmericano),
      TimeModel.basico(nome: 'Rubro Rio', estilo: Estilo.gegenpress),
      TimeModel.basico(nome: 'Azul Minas', estilo: Estilo.tikiTaka),
      TimeModel.basico(nome: 'Verde Norte', estilo: Estilo.transicaoRapida),
    ];
