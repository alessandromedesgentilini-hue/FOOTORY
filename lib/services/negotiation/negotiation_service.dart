import 'package:footory26/models/scout/scout_target.dart';

enum NegotiationDifficulty {
  facil,
  media,
  dificil,
  muitoDificil,
}

enum NegotiationOutcomeType {
  success,
  failed,
}

class NegotiationPreview {
  final bool canProceed;
  final MarketListType listType;
  final String playerName;

  final int marketValue;
  final int baseCost;
  final int negotiatedCost;

  final int fullSalary;
  final int negotiatedSalary;
  final double salaryShare;

  final String title;
  final String body;
  final String financeComment;

  final NegotiationDifficulty difficulty;
  final String difficultyLabel;
  final double successChance;
  final String difficultyComment;

  const NegotiationPreview({
    required this.canProceed,
    required this.listType,
    required this.playerName,
    required this.marketValue,
    required this.baseCost,
    required this.negotiatedCost,
    required this.fullSalary,
    required this.negotiatedSalary,
    required this.salaryShare,
    required this.title,
    required this.body,
    required this.financeComment,
    required this.difficulty,
    required this.difficultyLabel,
    required this.successChance,
    required this.difficultyComment,
  });
}

class NegotiationOutcome {
  final NegotiationOutcomeType type;
  final bool success;
  final String title;
  final String message;

  const NegotiationOutcome({
    required this.type,
    required this.success,
    required this.title,
    required this.message,
  });
}

class NegotiationService {
  const NegotiationService();

  NegotiationPreview buildPreview({
    required MarketListType listType,
    required String playerName,
    required int marketValue,
    required int baseCost,
    required int fullSalary,
    required int financeLevel,
    required String userDivisionId,
    required int userBalance,
    int playerOvr = 60,
  }) {
    final safeFinance = financeLevel.clamp(1, 10);

    final negotiatedCost = _negotiatedCost(
      listType: listType,
      baseCost: baseCost,
      financeLevel: safeFinance,
    );

    final salaryShare = _salaryShareForLoan(
      divisionId: userDivisionId,
      financeLevel: safeFinance,
    );

    final negotiatedSalary = listType == MarketListType.loan
        ? (fullSalary * salaryShare).round()
        : fullSalary;

    final canProceed = userBalance >= negotiatedCost;

    final difficulty = _difficultyFor(
      listType: listType,
      playerOvr: playerOvr,
      financeLevel: safeFinance,
      userDivisionId: userDivisionId,
    );

    final successChance = _successChanceFor(
      listType: listType,
      difficulty: difficulty,
      financeLevel: safeFinance,
      canProceed: canProceed,
    );

    final title = _titleFor(listType);
    final financeComment = _financeComment(
      financeLevel: safeFinance,
      listType: listType,
    );

    final body = _bodyFor(
      listType: listType,
      playerName: playerName,
      salaryShare: salaryShare,
    );

    return NegotiationPreview(
      canProceed: canProceed,
      listType: listType,
      playerName: playerName,
      marketValue: marketValue,
      baseCost: baseCost,
      negotiatedCost: negotiatedCost,
      fullSalary: fullSalary,
      negotiatedSalary: negotiatedSalary,
      salaryShare: salaryShare,
      title: title,
      body: body,
      financeComment: financeComment,
      difficulty: difficulty,
      difficultyLabel: _difficultyLabel(difficulty),
      successChance: successChance,
      difficultyComment: _difficultyComment(
        difficulty: difficulty,
        listType: listType,
      ),
    );
  }

  NegotiationOutcome resolveNegotiation({
    required NegotiationPreview preview,
    required double roll,
  }) {
    if (!preview.canProceed) {
      return const NegotiationOutcome(
        type: NegotiationOutcomeType.failed,
        success: false,
        title: 'Negociação travada',
        message:
            'O Departamento Financeiro não conseguiu avançar porque o clube não tem saldo suficiente para concluir a operação.',
      );
    }

    final success = roll <= preview.successChance;

    if (success) {
      return NegotiationOutcome(
        type: NegotiationOutcomeType.success,
        success: true,
        title: 'Negociação concluída',
        message: _successMessage(preview),
      );
    }

    return NegotiationOutcome(
      type: NegotiationOutcomeType.failed,
      success: false,
      title: 'Negociação frustrada',
      message: _failureMessage(preview),
    );
  }

  int _negotiatedCost({
    required MarketListType listType,
    required int baseCost,
    required int financeLevel,
  }) {
    switch (listType) {
      case MarketListType.transfer:
        return (baseCost * _transferCostMultiplier(financeLevel)).round();

      case MarketListType.free:
        return (baseCost * _freeAgentCostMultiplier(financeLevel)).round();

      case MarketListType.loan:
        return baseCost;
    }
  }

  double _transferCostMultiplier(int financeLevel) {
    switch (financeLevel.clamp(1, 10)) {
      case 1:
      case 2:
        return 1.08;
      case 3:
      case 4:
        return 1.04;
      case 5:
      case 6:
        return 1.00;
      case 7:
      case 8:
        return 0.96;
      case 9:
      case 10:
        return 0.92;
      default:
        return 1.00;
    }
  }

  double _freeAgentCostMultiplier(int financeLevel) {
    switch (financeLevel.clamp(1, 10)) {
      case 1:
      case 2:
        return 1.06;
      case 3:
      case 4:
        return 1.03;
      case 5:
      case 6:
        return 1.00;
      case 7:
      case 8:
        return 0.97;
      case 9:
      case 10:
        return 0.94;
      default:
        return 1.00;
    }
  }

  double _salaryShareForLoan({
    required String divisionId,
    required int financeLevel,
  }) {
    final base = _baseLoanSalaryShareByDivision(divisionId);
    final adjustment = _loanSalaryShareAdjustmentByFinance(financeLevel);

    return (base + adjustment).clamp(0.25, 0.65);
  }

  double _baseLoanSalaryShareByDivision(String divisionId) {
    switch (divisionId.trim().toUpperCase()) {
      case 'BR-A':
        return 0.60;
      case 'BR-B':
        return 0.50;
      case 'BR-C':
        return 0.40;
      case 'BR-D':
        return 0.30;
      default:
        return 0.50;
    }
  }

  double _loanSalaryShareAdjustmentByFinance(int financeLevel) {
    switch (financeLevel.clamp(1, 10)) {
      case 1:
      case 2:
        return 0.05;
      case 3:
      case 4:
        return 0.03;
      case 5:
      case 6:
        return 0.00;
      case 7:
      case 8:
        return -0.03;
      case 9:
      case 10:
        return -0.05;
      default:
        return 0.00;
    }
  }

  NegotiationDifficulty _difficultyFor({
    required MarketListType listType,
    required int playerOvr,
    required int financeLevel,
    required String userDivisionId,
  }) {
    var score = 0;

    switch (listType) {
      case MarketListType.free:
        score += 0;
        break;
      case MarketListType.loan:
        score += 1;
        break;
      case MarketListType.transfer:
        score += 2;
        break;
    }

    if (playerOvr >= 80) {
      score += 3;
    } else if (playerOvr >= 74) {
      score += 2;
    } else if (playerOvr >= 68) {
      score += 1;
    }

    if (financeLevel >= 9) {
      score -= 2;
    } else if (financeLevel >= 7) {
      score -= 1;
    } else if (financeLevel <= 2) {
      score += 2;
    } else if (financeLevel <= 4) {
      score += 1;
    }

    switch (userDivisionId.trim().toUpperCase()) {
      case 'BR-A':
        score -= 1;
        break;
      case 'BR-D':
        score += 1;
        break;
    }

    if (score <= 0) return NegotiationDifficulty.facil;
    if (score <= 2) return NegotiationDifficulty.media;
    if (score <= 4) return NegotiationDifficulty.dificil;
    return NegotiationDifficulty.muitoDificil;
  }

  double _successChanceFor({
    required MarketListType listType,
    required NegotiationDifficulty difficulty,
    required int financeLevel,
    required bool canProceed,
  }) {
    if (!canProceed) return 0.0;

    double chance;

    switch (difficulty) {
      case NegotiationDifficulty.facil:
        chance = 0.88;
        break;
      case NegotiationDifficulty.media:
        chance = 0.72;
        break;
      case NegotiationDifficulty.dificil:
        chance = 0.52;
        break;
      case NegotiationDifficulty.muitoDificil:
        chance = 0.34;
        break;
    }

    switch (listType) {
      case MarketListType.free:
        chance += 0.06;
        break;
      case MarketListType.loan:
        chance += 0.02;
        break;
      case MarketListType.transfer:
        chance -= 0.03;
        break;
    }

    chance += (financeLevel - 5) * 0.025;

    return chance.clamp(0.18, 0.94);
  }

  String _difficultyLabel(NegotiationDifficulty difficulty) {
    switch (difficulty) {
      case NegotiationDifficulty.facil:
        return 'Fácil';
      case NegotiationDifficulty.media:
        return 'Média';
      case NegotiationDifficulty.dificil:
        return 'Difícil';
      case NegotiationDifficulty.muitoDificil:
        return 'Muito difícil';
    }
  }

  String _difficultyComment({
    required NegotiationDifficulty difficulty,
    required MarketListType listType,
  }) {
    switch (difficulty) {
      case NegotiationDifficulty.facil:
        return 'A negociação parece bem encaminhada. O Departamento Financeiro vê boa chance de concluir.';
      case NegotiationDifficulty.media:
        return 'A negociação exige atenção, mas está dentro da realidade do clube.';
      case NegotiationDifficulty.dificil:
        return 'A operação é complicada. O clube precisará vencer resistência nas condições finais.';
      case NegotiationDifficulty.muitoDificil:
        return 'A negociação é muito difícil. Outros interesses, valores altos ou resistência do lado oposto podem pesar.';
    }
  }

  String _titleFor(MarketListType listType) {
    switch (listType) {
      case MarketListType.transfer:
        return 'Proposta de transferência';
      case MarketListType.loan:
        return 'Proposta de empréstimo';
      case MarketListType.free:
        return 'Proposta para jogador livre';
    }
  }

  String _bodyFor({
    required MarketListType listType,
    required String playerName,
    required double salaryShare,
  }) {
    final salaryPct = (salaryShare * 100).round();

    switch (listType) {
      case MarketListType.transfer:
        return 'O Departamento Financeiro voltou com os valores finais para tentar fechar a contratação de $playerName.';

      case MarketListType.loan:
        return 'O Departamento Financeiro negociou as condições de empréstimo de $playerName. O clube pagará $salaryPct% do salário mensal durante o período.';

      case MarketListType.free:
        return 'O Departamento Financeiro negociou luvas e salário para assinar com $playerName.';
    }
  }

  String _financeComment({
    required int financeLevel,
    required MarketListType listType,
  }) {
    if (financeLevel <= 2) {
      return 'Nosso Departamento Financeiro ainda é limitado. A negociação avançou, mas provavelmente não extraímos a melhor condição possível.';
    }

    if (financeLevel <= 4) {
      return 'O Departamento Financeiro conduziu a negociação de forma segura, mas sem grande poder de barganha.';
    }

    if (financeLevel <= 6) {
      return 'O Departamento Financeiro conseguiu uma condição equilibrada para o nível atual do clube.';
    }

    if (financeLevel <= 8) {
      return 'O Departamento Financeiro trabalhou bem e conseguiu reduzir parte do peso financeiro da operação.';
    }

    return 'O Departamento Financeiro mostrou alto poder de negociação e conseguiu uma condição muito favorável para o clube.';
  }

  static String _successMessage(NegotiationPreview preview) {
    switch (preview.difficulty) {
      case NegotiationDifficulty.facil:
        return 'A negociação avançou sem grandes obstáculos e o Departamento Financeiro fechou a operação.';
      case NegotiationDifficulty.media:
        return 'O Departamento Financeiro conduziu bem a conversa e conseguiu concluir a negociação.';
      case NegotiationDifficulty.dificil:
        return 'Mesmo com uma negociação difícil, o Departamento Financeiro venceu a resistência e fechou o acordo.';
      case NegotiationDifficulty.muitoDificil:
        return 'Foi uma negociação improvável, mas o Departamento Financeiro conseguiu superar a concorrência e fechar um acordo muito importante.';
    }
  }

  static String _failureMessage(NegotiationPreview preview) {
    switch (preview.difficulty) {
      case NegotiationDifficulty.facil:
        return 'Mesmo com cenário favorável, a negociação esfriou nos detalhes finais e não avançou.';
      case NegotiationDifficulty.media:
        return 'A negociação chegou perto, mas as condições finais não agradaram e a operação foi interrompida.';
      case NegotiationDifficulty.dificil:
        return 'O clube encontrou resistência forte na mesa e não conseguiu chegar aos valores esperados.';
      case NegotiationDifficulty.muitoDificil:
        return 'A operação era complicada desde o início. Outros interesses e valores altos travaram a negociação.';
    }
  }
}
