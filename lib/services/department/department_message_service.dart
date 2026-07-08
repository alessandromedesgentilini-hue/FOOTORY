import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/data/department_messages.dart';
import 'package:footory26/data/staff_department_data.dart';
import 'package:footory26/models/staff_department.dart';
import 'package:footory26/services/finance/finance_rules_service.dart';
import 'package:footory26/services/world/catalog/club_structures_catalog.dart';

class DepartmentMessageService {
  const DepartmentMessageService();

  DepartmentMessage generateFromStructures({
    required SeededRng rng,
    required ClubStructures structures,

    // CONTEXTO
    required FinanceHealth financeHealth,
    required int winStreak,
    required int drawStreak,
    required int loseStreak,
    required int tablePosition,
    required int totalTeams,
    required String divisionId,
  }) {
    final department = _pickDepartment(rng);

    final mood = _resolveMoodForDepartment(
      department: department,
      structures: structures,
    );

    return _buildMessage(
      rng: rng,
      department: department,
      mood: mood,
      financeHealth: financeHealth,
      winStreak: winStreak,
      drawStreak: drawStreak,
      loseStreak: loseStreak,
      tablePosition: tablePosition,
      totalTeams: totalTeams,
      divisionId: divisionId,
    );
  }

  DepartmentMessage generateForDepartment({
    required SeededRng rng,
    required ClubStructures structures,
    required DepartmentType department,

    // CONTEXTO
    required FinanceHealth financeHealth,
    required int winStreak,
    required int drawStreak,
    required int loseStreak,
    required int tablePosition,
    required int totalTeams,
    required String divisionId,
  }) {
    final mood = _resolveMoodForDepartment(
      department: department,
      structures: structures,
    );

    return _buildMessage(
      rng: rng,
      department: department,
      mood: mood,
      financeHealth: financeHealth,
      winStreak: winStreak,
      drawStreak: drawStreak,
      loseStreak: loseStreak,
      tablePosition: tablePosition,
      totalTeams: totalTeams,
      divisionId: divisionId,
    );
  }

  DepartmentType _pickDepartment(SeededRng rng) {
    const weightedDepartments = <DepartmentType>[
      DepartmentType.academy,
      DepartmentType.academy,
      DepartmentType.trainingCenter,
      DepartmentType.trainingCenter,
      DepartmentType.medical,
      DepartmentType.scouting,
      DepartmentType.finance,
      DepartmentType.marketing,
      DepartmentType.communication,
      DepartmentType.sportsComplex,
      DepartmentType.stadium,
    ];

    return weightedDepartments[rng.nextInt(weightedDepartments.length)];
  }

  DepartmentMoodLevel _resolveMoodForDepartment({
    required DepartmentType department,
    required ClubStructures structures,
  }) {
    final level = _departmentLevel(
      department: department,
      structures: structures,
    );

    if (level <= 2) return DepartmentMoodLevel.veryBad;
    if (level <= 4) return DepartmentMoodLevel.bad;
    if (level <= 6) return DepartmentMoodLevel.stable;
    if (level <= 8) return DepartmentMoodLevel.good;
    return DepartmentMoodLevel.excellent;
  }

  int _departmentLevel({
    required DepartmentType department,
    required ClubStructures structures,
  }) {
    switch (department) {
      case DepartmentType.sportsComplex:
        return structures.complexo;
      case DepartmentType.trainingCenter:
        return structures.ct;
      case DepartmentType.academy:
        return structures.base;
      case DepartmentType.scouting:
        return structures.scout;
      case DepartmentType.finance:
        return structures.financeiro;
      case DepartmentType.marketing:
        return structures.marketing;
      case DepartmentType.communication:
        return structures.comunicacao;
      case DepartmentType.medical:
        return structures.medico;
      case DepartmentType.stadium:
        return structures.estadio;
    }
  }

  DepartmentMessage _buildMessage({
    required SeededRng rng,
    required DepartmentType department,
    required DepartmentMoodLevel mood,

    // CONTEXTO
    required FinanceHealth financeHealth,
    required int winStreak,
    required int drawStreak,
    required int loseStreak,
    required int tablePosition,
    required int totalTeams,
    required String divisionId,
  }) {
    final staff = getStaffByDepartment(department);

    final opening = _pickOpening(
      rng: rng,
      department: department,
      mood: mood,
    );

    final selectedText = _pickDepartmentText(
      rng: rng,
      department: department,
      mood: mood,
    );

    final contextualText = _buildContextualLayer(
      rng: rng,
      financeHealth: financeHealth,
      winStreak: winStreak,
      drawStreak: drawStreak,
      loseStreak: loseStreak,
      tablePosition: tablePosition,
      totalTeams: totalTeams,
      divisionId: divisionId,
    );

    final fullText = _joinText(
      opening: opening,
      body: selectedText,
      contextual: contextualText,
    );

    final type = _resolveMessageType(mood);

    return DepartmentMessage(
      type: type,
      departmentType: department,
      title: _buildTitle(
        department: department,
        mood: mood,
      ),
      authorName: staff.name,
      authorRole: staff.role,
      faceAsset: staff.faceAsset,
      text: fullText,
      subtitle: '${department.emoji} ${department.label}',
      tag: _buildTag(
        department: department,
        mood: mood,
      ),
      roundLabel: null,
    );
  }

  String _pickOpening({
    required SeededRng rng,
    required DepartmentType department,
    required DepartmentMoodLevel mood,
  }) {
    final custom = _customOpenings(
      department: department,
      mood: mood,
    );

    if (custom.isNotEmpty) {
      return custom[rng.nextInt(custom.length)].trim();
    }

    if (messageOpenings.isEmpty) return '';
    return messageOpenings[rng.nextInt(messageOpenings.length)].trim();
  }

  List<String> _customOpenings({
    required DepartmentType department,
    required DepartmentMoodLevel mood,
  }) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return [
          'O setor voltou a acender um sinal de alerta.',
          'Há preocupação interna com o momento atual do setor.',
          'A avaliação mais recente trouxe pontos de atenção.',
        ];

      case DepartmentMoodLevel.bad:
        return [
          'O setor segue funcionando, mas abaixo do ideal.',
          'A leitura interna indica que ainda faltam ajustes.',
          'A avaliação do momento é de desempenho irregular.',
        ];

      case DepartmentMoodLevel.stable:
        return [
          'O setor mantém funcionamento dentro do esperado.',
          'A situação atual é considerada controlada.',
          'O departamento segue operando com estabilidade.',
        ];

      case DepartmentMoodLevel.good:
        return [
          'O setor apresenta sinais positivos nas últimas avaliações.',
          'A leitura interna do momento é boa.',
          'O departamento vive um período de evolução consistente.',
        ];

      case DepartmentMoodLevel.excellent:
        return [
          'O setor vive um dos melhores momentos desde o início do projeto.',
          'A avaliação interna do departamento é extremamente positiva.',
          'Os resultados recentes colocam o setor em destaque dentro do clube.',
        ];
    }
  }

  String _pickDepartmentText({
    required SeededRng rng,
    required DepartmentType department,
    required DepartmentMoodLevel mood,
  }) {
    final candidates = stateMessagesByDepartment[department]?[mood] ?? const [];

    if (candidates.isEmpty) {
      return 'Sem atualizações relevantes no momento.';
    }

    return candidates[rng.nextInt(candidates.length)].trim();
  }

  String _buildContextualLayer({
    required SeededRng rng,
    required FinanceHealth financeHealth,
    required int winStreak,
    required int drawStreak,
    required int loseStreak,
    required int tablePosition,
    required int totalTeams,
    required String divisionId,
  }) {
    final contextPool = <String>[];

    // =========================================================
    // FORMA
    // =========================================================

    if (winStreak >= 5) {
      contextPool.addAll(
        contextualMessages['good_form'] ?? const [],
      );

      contextPool.add(
        'O elenco vive uma sequência extremamente positiva nas últimas rodadas.',
      );
    } else if (winStreak >= 3) {
      contextPool.add(
        'A sequência recente de vitórias melhorou bastante o ambiente interno.',
      );
    }

    if (loseStreak >= 5) {
      contextPool.addAll(
        contextualMessages['bad_form'] ?? const [],
      );

      contextPool.add(
        'A pressão interna aumentou bastante após os últimos resultados.',
      );
    } else if (loseStreak >= 3) {
      contextPool.add(
        'A sequência negativa recente elevou a cobrança sobre o clube.',
      );
    }

    // =========================================================
    // FINANÇAS
    // =========================================================

    switch (financeHealth) {
      case FinanceHealth.muitoSaudavel:
        contextPool.add(
          'O bom momento financeiro ajuda o clube a trabalhar com mais estabilidade.',
        );
        break;

      case FinanceHealth.saudavel:
        contextPool.add(
          'As contas seguem relativamente organizadas neste momento.',
        );
        break;

      case FinanceHealth.estavel:
        contextPool.add(
          'O clube mantém equilíbrio financeiro, mas ainda exige cautela.',
        );
        break;

      case FinanceHealth.pressionado:
        contextPool.add(
          'A situação financeira já começa a limitar algumas decisões internas.',
        );
        break;

      case FinanceHealth.critico:
        contextPool.add(
          'O cenário financeiro atual exige bastante controle do clube.',
        );
        break;

      case FinanceHealth.colapsoFinanceiro:
        contextPool.add(
          'O ambiente financeiro do clube segue extremamente delicado.',
        );
        break;
    }

    // =========================================================
    // TABELA
    // =========================================================

    final topZone = tablePosition <= 4;
    final dangerZone = tablePosition > totalTeams - 4;

    if (topZone) {
      contextPool.add(
        'A posição atual na tabela aumentou o otimismo dentro do clube.',
      );
    }

    if (dangerZone) {
      contextPool.add(
        'A situação na tabela começa a gerar preocupação internamente.',
      );
    }

    if (contextPool.isEmpty) {
      return '';
    }

    return contextPool[rng.nextInt(contextPool.length)];
  }

  String _joinText({
    required String opening,
    required String body,
    required String contextual,
  }) {
    final parts = <String>[
      opening.trim(),
      body.trim(),
      contextual.trim(),
    ];

    parts.removeWhere((e) => e.isEmpty);

    return parts.join(' ');
  }

  DepartmentMessageType _resolveMessageType(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return DepartmentMessageType.alert;
      case DepartmentMoodLevel.bad:
        return DepartmentMessageType.note;
      case DepartmentMoodLevel.stable:
        return DepartmentMessageType.report;
      case DepartmentMoodLevel.good:
        return DepartmentMessageType.goodNews;
      case DepartmentMoodLevel.excellent:
        return DepartmentMessageType.achievement;
    }
  }

  String _buildTitle({
    required DepartmentType department,
    required DepartmentMoodLevel mood,
  }) {
    switch (department) {
      case DepartmentType.academy:
        return _academyTitle(mood);
      case DepartmentType.trainingCenter:
        return _ctTitle(mood);
      case DepartmentType.medical:
        return _medicalTitle(mood);
      case DepartmentType.scouting:
        return _scoutTitle(mood);
      case DepartmentType.finance:
        return _financeTitle(mood);
      case DepartmentType.marketing:
        return _marketingTitle(mood);
      case DepartmentType.communication:
        return _communicationTitle(mood);
      case DepartmentType.sportsComplex:
        return _complexTitle(mood);
      case DepartmentType.stadium:
        return _stadiumTitle(mood);
    }
  }

  String _buildTag({
    required DepartmentType department,
    required DepartmentMoodLevel mood,
  }) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Alerta interno';
      case DepartmentMoodLevel.bad:
        return 'Ponto de atenção';
      case DepartmentMoodLevel.stable:
        return 'Relatório interno';
      case DepartmentMoodLevel.good:
        return 'Boa atualização';
      case DepartmentMoodLevel.excellent:
        return 'Destaque do setor';
    }
  }

  String _academyTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Base em alerta';
      case DepartmentMoodLevel.bad:
        return 'Base abaixo do ideal';
      case DepartmentMoodLevel.stable:
        return 'Relatório da Base';
      case DepartmentMoodLevel.good:
        return 'Boa fase da Base';
      case DepartmentMoodLevel.excellent:
        return 'Base em destaque';
    }
  }

  String _ctTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'CT sob pressão';
      case DepartmentMoodLevel.bad:
        return 'CT abaixo do ideal';
      case DepartmentMoodLevel.stable:
        return 'Relatório do CT';
      case DepartmentMoodLevel.good:
        return 'CT em evolução';
      case DepartmentMoodLevel.excellent:
        return 'CT em grande fase';
    }
  }

  String _medicalTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Departamento Médico em alerta';
      case DepartmentMoodLevel.bad:
        return 'Médico abaixo do esperado';
      case DepartmentMoodLevel.stable:
        return 'Relatório Médico';
      case DepartmentMoodLevel.good:
        return 'Boa atualização médica';
      case DepartmentMoodLevel.excellent:
        return 'Departamento Médico em destaque';
    }
  }

  String _scoutTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Scout em alerta';
      case DepartmentMoodLevel.bad:
        return 'Scout abaixo do ideal';
      case DepartmentMoodLevel.stable:
        return 'Relatório do Scout';
      case DepartmentMoodLevel.good:
        return 'Scout em boa fase';
      case DepartmentMoodLevel.excellent:
        return 'Scout em grande fase';
    }
  }

  String _financeTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Financeiro sob alerta';
      case DepartmentMoodLevel.bad:
        return 'Financeiro pressionado';
      case DepartmentMoodLevel.stable:
        return 'Relatório Financeiro';
      case DepartmentMoodLevel.good:
        return 'Financeiro em boa fase';
      case DepartmentMoodLevel.excellent:
        return 'Financeiro em destaque';
    }
  }

  String _marketingTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Marketing em alerta';
      case DepartmentMoodLevel.bad:
        return 'Marketing abaixo do ideal';
      case DepartmentMoodLevel.stable:
        return 'Relatório do Marketing';
      case DepartmentMoodLevel.good:
        return 'Marketing em boa fase';
      case DepartmentMoodLevel.excellent:
        return 'Marketing em grande fase';
    }
  }

  String _communicationTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Comunicação sob pressão';
      case DepartmentMoodLevel.bad:
        return 'Comunicação abaixo do ideal';
      case DepartmentMoodLevel.stable:
        return 'Relatório da Comunicação';
      case DepartmentMoodLevel.good:
        return 'Comunicação em boa fase';
      case DepartmentMoodLevel.excellent:
        return 'Comunicação em destaque';
    }
  }

  String _complexTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Complexo em alerta';
      case DepartmentMoodLevel.bad:
        return 'Complexo abaixo do ideal';
      case DepartmentMoodLevel.stable:
        return 'Relatório do Complexo';
      case DepartmentMoodLevel.good:
        return 'Complexo em boa fase';
      case DepartmentMoodLevel.excellent:
        return 'Complexo em grande fase';
    }
  }

  String _stadiumTitle(DepartmentMoodLevel mood) {
    switch (mood) {
      case DepartmentMoodLevel.veryBad:
        return 'Estádio em alerta';
      case DepartmentMoodLevel.bad:
        return 'Estádio abaixo do ideal';
      case DepartmentMoodLevel.stable:
        return 'Relatório do Estádio';
      case DepartmentMoodLevel.good:
        return 'Estádio em boa fase';
      case DepartmentMoodLevel.excellent:
        return 'Estádio em destaque';
    }
  }
}
