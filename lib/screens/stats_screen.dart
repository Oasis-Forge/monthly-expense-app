import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/budget.dart';
import '../models/money.dart';
import '../models/period.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'budgets_screen.dart';

const List<Color> _chartColors = [
  Color(0xFF6C5CE7),
  Color(0xFF00B894),
  Color(0xFFE17055),
  Color(0xFF0984E3),
  Color(0xFFFDCB6E),
  Color(0xFFD63031),
  Color(0xFF00CEC9),
  Color(0xFFE84393),
  Color(0xFF636E72),
  Color(0xFFA29BFE),
];

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final byCategory = provider.expenseByCategory;
    final total = byCategory.values.fold(Money.zero, (a, b) => a + b);
    final statuses = provider.budgetStatuses;

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.thousandths.compareTo(a.value.thousandths));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle(periodLabel(provider.period, l10n))),
        actions: [
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: l10n.budgetsTooltip,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const BudgetsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (statuses.isNotEmpty) ...[
            Text(
              l10n.budgetsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final status in statuses)
              _BudgetProgress(status: status, currency: currency),
            const Divider(height: 32),
          ],
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text(l10n.noExpensesInPeriod)),
            )
          else ...[
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value.toDouble(),
                        color: _chartColors[i % _chartColors.length],
                        title:
                            '${(entries[i].value.thousandths / total.thousandths * 100).toStringAsFixed(0)}%',
                        radius: 70,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.totalSpent(currency.format(total.toDouble())),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < entries.length; i++)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _chartColors[i % _chartColors.length],
                  child: Text(
                    provider.categoryById(entries[i].key)?.icon ?? '📦',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                title: Text(
                  provider.categoryById(entries[i].key)?.label(l10n) ?? '',
                ),
                trailing: Text(currency.format(entries[i].value.toDouble())),
              ),
          ],
        ],
      ),
    );
  }
}

/// One budget's bar: spent against the limit, and what's left or over
/// (BUD-2–BUD-4, BUD-6).
class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.status, required this.currency});

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category == null
                      ? l10n.overallBudget
                      : '${category.icon} ${category.label(l10n)}',
                  style: theme.textTheme.titleSmall,
                ),
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
          Text(
            detail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: status.level == BudgetLevel.ok || isFuture ? null : color,
            ),
          ),
        ],
      ),
    );
  }
}
