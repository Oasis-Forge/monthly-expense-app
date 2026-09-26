import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/budget.dart';
import '../models/money.dart';
import '../models/period.dart';
import '../providers/transaction_provider.dart';

/// The colour a budget's level is drawn in, shared by this bar and Home's
/// budgets card (BUD-8) so the two never drift apart. "Ok" and "warning" are
/// app-owned colours pinned against the wallpaper (THEME-4); "over" keeps
/// following the theme's error colour.
Color budgetLevelColor(BuildContext context, BudgetLevel level) {
  final theme = Theme.of(context);
  final dark = theme.brightness == Brightness.dark;
  return switch (level) {
    BudgetLevel.ok => Color(dark ? budgetOkDark : budgetOkLight),
    BudgetLevel.warning => Color(dark ? budgetWarningDark : budgetWarningLight),
    BudgetLevel.over => theme.colorScheme.error,
  };
}

/// One budget's bar: spent against the limit, the share used, and what's
/// left or over (BUD-2–BUD-4, BUD-6), as Insights shows it. The budgets card
/// on Home shows a [compact] one (BUD-8).
class BudgetProgress extends StatelessWidget {
  const BudgetProgress({
    super.key,
    required this.status,
    required this.currency,
    this.compact = false,
  });

  final BudgetStatus status;
  final NumberFormat currency;

  /// The name, the amounts with the share used, and the bar, without the
  /// line under it; what's left per day or how much is over stays in
  /// Insights (BUD-8).
  final bool compact;

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
    final color = budgetLevelColor(context, status.level);
    String money(Money amount) => currency.money(amount);
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
    final percent = NumberFormat.percentPattern(l10n.localeName)
        .format(status.progress);
    final spentOfLimit = l10n.budgetSpentOfLimit(
      money(status.spent),
      money(status.limit),
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
              if (compact && isFuture)
                // A future period has only its limits (BUD-6).
                Text(l10n.budgetLimitOnly(money(status.limit)))
              else if (compact)
                // One text, so it wraps as a whole at large sizes.
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: spentOfLimit),
                      const TextSpan(text: '   '),
                      TextSpan(
                        text: percent,
                        style: TextStyle(
                          color: status.level == BudgetLevel.ok ? null : color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (!isFuture)
                Text(spentOfLimit),
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
          if (!compact) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(detail, style: detailStyle)),
                // A future period has only its limits (BUD-6).
                if (!isFuture) ...[
                  const SizedBox(width: 8),
                  Text(percent, style: detailStyle),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
