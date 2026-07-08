import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/money_formatter.dart';
import 'package:footory26/models/scout/scout_target.dart';
import 'package:footory26/services/negotiation/negotiation_service.dart';

enum MarketNegotiationDecision {
  confirm,
  cancel,
}

enum MarketNegotiationResultDecision {
  close,
  observe,
}

class MarketNegotiationDialog extends StatelessWidget {
  final NegotiationPreview preview;
  final ScoutTarget target;

  const MarketNegotiationDialog({
    super.key,
    required this.preview,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final marketValue = MoneyFormatter.formatCurrency(preview.marketValue);
    final cost = MoneyFormatter.formatCurrency(preview.negotiatedCost);
    final salary = MoneyFormatter.formatCurrency(preview.negotiatedSalary);
    final fullSalary = MoneyFormatter.formatCurrency(preview.fullSalary);
    final chancePct = (preview.successChance * 100).round();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(preview: preview),
                const SizedBox(height: 18),
                Text(
                  preview.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                _InfoTile(
                  icon: Icons.person_rounded,
                  label: 'Jogador',
                  value: '${target.playerName} — ${target.posLabel}',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.analytics_outlined,
                  label: 'Qualidade estimada',
                  value: 'Classe ${target.qualityLabel}',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.speed_rounded,
                  label: 'Dificuldade da negociação',
                  value: '${preview.difficultyLabel} • $chancePct% de chance',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  label: 'Leitura do departamento',
                  value: preview.difficultyComment,
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.attach_money_rounded,
                  label: 'Valor de mercado estimado',
                  value: marketValue,
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.payments_outlined,
                  label: _costLabel(preview.listType),
                  value: cost,
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: _salaryLabel(preview.listType),
                  value: preview.listType == MarketListType.loan
                      ? '$salary / mês (salário cheio: $fullSalary)'
                      : '$salary / mês',
                ),
                const SizedBox(height: 16),
                _FinanceComment(text: preview.financeComment),
                if (preview.listType != MarketListType.free) ...[
                  const SizedBox(height: 12),
                  const _InfoBox(
                    icon: Icons.event_available_rounded,
                    text:
                        'Se a negociação for fechada fora de janeiro ou julho, o valor do acordo é pago agora, mas o salário só entra na folha quando o jogador chegar na próxima janela.',
                  ),
                ],
                if (!preview.canProceed) ...[
                  const SizedBox(height: 12),
                  const _WarningBox(
                    text:
                        'O clube não tem saldo suficiente para concluir esta operação agora.',
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(
                        MarketNegotiationDecision.cancel,
                      );
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: preview.canProceed
                        ? () {
                            Navigator.of(context).pop(
                              MarketNegotiationDecision.confirm,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(_confirmLabel(preview.listType)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _costLabel(MarketListType type) {
    switch (type) {
      case MarketListType.transfer:
        return 'Valor final da transferência';
      case MarketListType.loan:
        return 'Custo inicial do empréstimo';
      case MarketListType.free:
        return 'Luvas / assinatura';
    }
  }

  String _salaryLabel(MarketListType type) {
    switch (type) {
      case MarketListType.transfer:
      case MarketListType.free:
        return 'Salário mensal';
      case MarketListType.loan:
        return 'Salário pago pelo clube';
    }
  }

  String _confirmLabel(MarketListType type) {
    switch (type) {
      case MarketListType.transfer:
        return 'Confirmar Acordo';
      case MarketListType.loan:
        return 'Confirmar Empréstimo';
      case MarketListType.free:
        return 'Confirmar Assinatura';
    }
  }
}

class MarketNegotiationResultDialog extends StatelessWidget {
  final NegotiationOutcome outcome;
  final NegotiationPreview preview;

  const MarketNegotiationResultDialog({
    super.key,
    required this.outcome,
    required this.preview,
  });

  bool get _success => outcome.success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cost = MoneyFormatter.formatCurrency(preview.negotiatedCost);
    final salary = MoneyFormatter.formatCurrency(preview.negotiatedSalary);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResultHeader(
                  success: _success,
                  title: outcome.title,
                ),
                const SizedBox(height: 18),
                Text(
                  outcome.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                _InfoTile(
                  icon: Icons.person_rounded,
                  label: 'Jogador',
                  value: preview.playerName,
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.speed_rounded,
                  label: 'Dificuldade da negociação',
                  value:
                      '${preview.difficultyLabel} • ${(preview.successChance * 100).round()}% de chance',
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  icon: Icons.payments_outlined,
                  label: _success
                      ? _successCostLabel(preview.listType)
                      : 'Operação não concluída',
                  value: _success ? cost : 'Nenhum valor foi pago',
                ),
                if (_success) ...[
                  const SizedBox(height: 10),
                  _InfoTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: preview.listType == MarketListType.loan
                        ? 'Salário acordado'
                        : 'Salário mensal acordado',
                    value: '$salary / mês',
                  ),
                ],
                const SizedBox(height: 16),
                _ResultMessageBox(
                  success: _success,
                  text: _success
                      ? _successFooter(preview.listType)
                      : 'A negociação não avançou. O jogador saiu da lista atual, mas pode ser mantido no radar do clube.',
                ),
                const SizedBox(height: 18),
                if (!_success) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(
                          MarketNegotiationResultDecision.observe,
                        );
                      },
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('Observar jogador'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(
                        MarketNegotiationResultDecision.close,
                      );
                    },
                    icon: Icon(
                      _success
                          ? Icons.check_circle_outline_rounded
                          : Icons.arrow_back_rounded,
                    ),
                    label: Text(
                      _success ? 'Finalizar' : 'Voltar ao mercado',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _successCostLabel(MarketListType type) {
    switch (type) {
      case MarketListType.transfer:
        return 'Acordo fechado por';
      case MarketListType.loan:
        return 'Custo inicial do empréstimo';
      case MarketListType.free:
        return 'Luvas / assinatura';
    }
  }

  String _successFooter(MarketListType type) {
    switch (type) {
      case MarketListType.transfer:
        return 'A operação foi acertada. Se a negociação aconteceu fora da janela, o jogador chegará na próxima janela; se a janela estiver aberta, ele já fica disponível.';
      case MarketListType.loan:
        return 'O empréstimo foi acertado. Se a negociação aconteceu fora da janela, o jogador chegará na próxima janela; se a janela estiver aberta, ele já fica disponível.';
      case MarketListType.free:
        return 'A assinatura foi concluída e o jogador já está disponível para o elenco.';
    }
  }
}

class _Header extends StatelessWidget {
  final NegotiationPreview preview;

  const _Header({
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.actionGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            _iconFor(preview.listType),
            color: AppColors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preview.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Departamento Financeiro',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconFor(MarketListType type) {
    switch (type) {
      case MarketListType.transfer:
        return Icons.swap_horiz_rounded;
      case MarketListType.loan:
        return Icons.compare_arrows_rounded;
      case MarketListType.free:
        return Icons.person_add_alt_1_rounded;
    }
  }
}

class _ResultHeader extends StatelessWidget {
  final bool success;
  final String title;

  const _ResultHeader({
    required this.success,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = success ? AppColors.success : AppColors.danger;
    final softColor = success
        ? AppColors.success.withOpacity(0.12)
        : AppColors.warning.withOpacity(0.12);

    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            success ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                success ? 'Acordo fechado' : 'Operação interrompida',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceComment extends StatelessWidget {
  final String text;

  const _FinanceComment({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brownSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_balance_rounded,
            color: AppColors.brown,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.brown,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBox({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultMessageBox extends StatelessWidget {
  final bool success;
  final String text;

  const _ResultMessageBox({
    required this.success,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = success ? AppColors.success : AppColors.danger;
    final bg = success
        ? AppColors.success.withOpacity(0.12)
        : AppColors.warning.withOpacity(0.12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            success ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String text;

  const _WarningBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
