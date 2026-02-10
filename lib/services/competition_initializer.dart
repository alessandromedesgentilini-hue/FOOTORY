// lib/services/competition_initializer.dart
//
// Inicializa uma competição (liga) de forma segura e compatível.
// - Mantém a assinatura que você já usa (com `participantes`).
// - Preenche campos básicos do CompetitionModel.
// - Tenta (de forma resiliente) injetar os participantes e semear calendário,
//   caso o CompetitionModel exponha métodos/propriedades para isso.
//
// Obs.: como CompetitionModel pode variar de projeto para projeto, usamos
// chamadas via `dynamic` dentro de try/catch para não quebrar o build
// se algum método/campo não existir.

import '../models/competition_model.dart';
import '../models/time_model.dart';

class CompetitionInitializer {
  /// Cria uma liga “padrão” com nome/ano/início.
  /// Se o seu CompetitionModel tiver APIs para receber os participantes
  /// (ex.: `setParticipantes`, `times`, etc.), tentamos preenchê-las.
  CompetitionModel criarLigaPadrao({
    required List<TimeModel> participantes, // mantido para compat
    DateTime? inicio,
    String? nome,
    int? ano,
  }) {
    final dataInicio = inicio ?? DateTime.now();
    final anoComp = ano ?? dataInicio.year;

    // Instância mínima (campos canônicos)
    final comp = CompetitionModel(
      id: CompetitionModel.gerarId(),
      nome: nome ?? 'Liga Padrão',
      ano: anoComp,
      inicio: dataInicio,
      rodadaAtual: 1,
    );

    // ===== Tentativas opcionais de acoplar participantes/calendário =====
    // Tudo protegido por try/catch para não travar caso a API não exista.

    // Campos que podem existir
    try {
      final d = comp as dynamic;
      d.participantes = participantes;
    } catch (_) {}
    try {
      final d = comp as dynamic;
      d.times = participantes;
    } catch (_) {}

    // Métodos frequentes para injetar times
    try {
      final d = comp as dynamic;
      d.setParticipantes?.call(participantes);
    } catch (_) {}
    try {
      final d = comp as dynamic;
      d.definirParticipantes?.call(participantes);
    } catch (_) {}
    try {
      final d = comp as dynamic;
      d.setTimes?.call(participantes);
    } catch (_) {}
    try {
      final d = comp as dynamic;
      d.definirTimes?.call(participantes);
    } catch (_) {}
    try {
      final d = comp as dynamic;
      d.addTimes?.call(participantes);
    } catch (_) {}

    // Métodos comuns para semear/gerar calendário
    try {
      final d = comp as dynamic;
      d.seedRoundRobin?.call(participantes);
    } catch (_) {}
    try {
      final d = comp as dynamic;
      d.gerarCalendarioRoundRobin?.call(participantes);
    } catch (_) {}
    try {
      final d = comp as dynamic;
      d.gerarCalendario?.call(participantes);
    } catch (_) {}
    try {
      final d = comp as dynamic;
      d.criarCalendario?.call();
    } catch (_) {}

    return comp;
  }

  /// Alias com a mesma assinatura que você já chamava:
  /// `criarLiga(participantes, [inicio, nome, ano])`
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
