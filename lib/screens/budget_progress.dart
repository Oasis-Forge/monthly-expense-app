import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/budget.dart';
import '../models/money.dart';
import '../models/period.dart';
import '../providers/transaction_provider.dart';

/// One budget's bar: spent against the limit, the share used, and what's
/// left or over (BUD-2–BUD-4, BUD-6). Insights and the budgets card on Home
/// both show budgets this way (BUD-8).
class BudgetProgress extends StatelessWidget {
  const BudgetProgress({
    super.key,
    required this.status,
    required this.currency,
  });

  final BudgetStatus status;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.watch<TransactionProvider>();
    final categoryId = status.categoryId;
    final category = categoryId == null
        ? null
        : provider.categoryById(categoryId);
    final isFuture = status.timing == PeriodTiming.future;
    final color = switch (status.level) {
      BudgetLevel.ok => theme.colorScheme.primary,
      BudgetLevel.warning => Colors.orange,
      BudgetLevel.over => theme.colorScheme.error,
    };
    String money(Money amount) => currency.format(amount.toDouble());
    final perDay = status.perDayAllowance;
    final detail = isFuture
        ? l10n.budgetLimitOnly(money(status.limit))
        : status.remaining.isNegative
        ? l10n.budgetOverBy(money(-status.remaining))
        : !status.remaining.isPositive
        ? l10n.budgetLimitReached
        : perDay != null
        ? l10n.budgetLeftPerDay(money(status.remaining), money(perDay))
        : l10n.budgetLeft(money(status.remaining));
    final detailStyle = theme.textTheme.bodySmall?.copyWith(
      color: status.level == BudgetLevel.ok || isFuture ? null : color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wraps, so long names and amounts move to a second line instead of
          // overflowing (LANG-6).
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            children: [
              Text(
                category == null
                    ? l10n.overallBudget
                    : '${category.icon} ${category.label(l10n)}',
                style: theme.textTheme.titleSmall,
              ),
              if (!isFuture)
                Text(
                  l10n.budgetSpentOfLimit(
                    money(status.spent),
                    money(status.limit),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: isFuture
                ? 0
                : status.progress > 1
                ? 1
                : status.progress,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(detail, style: detailStyle)),
              // A future period has only its limits (BUD-6).
              if (!isFuture) ...[
                const SizedBox(width: 8),
                Text(
                  NumberFormat.percentPattern(l10n.localeName)
                      .format(status.progress),
                  style: detailStyle,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
