// lib/services/competition_initializer.dart
import '../models/competition_model.dart';
import '../models/time_model.dart';

class CompetitionInitializer {
  CompetitionModel criarLigaPadrao({
    required List<TimeModel>
        participantes, // mantido para compat com chamadas existentes
    DateTime? inicio,
    String? nome,
    int? ano,
  }) {
    final dataInicio = inicio ?? DateTime.now();
    final anoComp = ano ?? dataInicio.year;

    return CompetitionModel(
      id: CompetitionModel.gerarId(),
      nome: nome ?? 'Liga Padrão',
      ano: anoComp,
      inicio: dataInicio,
      rodadaAtual: 1,
    );
  }

  CompetitionModel criarLiga(
    List<TimeModel> participantes, [
    DateTime? inicio,
    String? nome,
    int? ano,
  ]) {
    return criarLigaPadrao(
      participantes: participantes,
      inicio: inicio,
      nome: nome,
      ano: ano,
    );
  }
}
