import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/budget.dart';
import '../models/insights.dart';
import '../models/money.dart';
import '../models/period.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'budgets_screen.dart';
import 'period_selector.dart';
import 'transfer_screen.dart';

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

/// Charts for the selected period: spending or income by category with
/// budgets, a calendar of daily totals, and the trend over recent periods
/// (INS-1–INS-3).
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.insightsTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.savings_outlined),
              tooltip: l10n.budgetsTooltip,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const BudgetsScreen())),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.categoriesTitle),
              Tab(text: l10n.calendarTab),
              Tab(text: l10n.trendTab),
            ],
          ),
        ),
        body: const Column(
          children: [
            PeriodSelector(),
            Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [_CategoriesTab(), _CalendarTab(), _TrendTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The category chart for expense or income, with budget bars for expense
/// (INS-3, BUD-2–BUD-6).
class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab();

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  TransactionType _type = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final isExpense = _type == TransactionType.expense;
    final byCategory = isExpense
        ? provider.expenseByCategory
        : provider.incomeByCategory;
    final total = byCategory.values.fold(Money.zero, (a, b) => a + b);
    final statuses = isExpense
        ? provider.budgetStatuses
        : const <BudgetStatus>[];
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.thousandths.compareTo(a.value.thousandths));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text(l10n.expenseLabel),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text(l10n.incomeLabel),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) =>
                setState(() => _type = selection.first),
          ),
        ),
        const SizedBox(height: 16),
        if (statuses.isNotEmpty) ...[
          Text(l10n.budgetsTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final status in statuses)
            _BudgetProgress(status: status, currency: currency),
          const Divider(height: 32),
        ],
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                isExpense ? l10n.noExpensesInPeriod : l10n.noIncomeInPeriod,
              ),
            ),
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
            isExpense
                ? l10n.totalSpent(currency.format(total.toDouble()))
                : l10n.totalIncome(currency.format(total.toDouble())),
            style: theme.textTheme.titleMedium,
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

/// A month grid of the selected period with each day's expense and income;
/// tapping a day lists its entries (INS-1, PER-4).
class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final compact = settings.compactCurrencyFormat(locale);
    final period = provider.period;
    final today = provider.today;
    // PER-4: the chosen first day of the week, else the locale's (0 is
    // Sunday).
    final firstWeekday =
        settings.weekStartDay ??
        MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final days = [
      for (
        var day = period.start;
        day.isBefore(period.end);
        day = DateTime(day.year, day.month, day.day + 1)
      )
        day,
    ];
    final leadingBlanks = (period.start.weekday % 7 - firstWeekday) % 7;
    final chosen = _selected;
    final selected = chosen != null && period.contains(chosen)
        ? chosen
        : period.contains(today)
        ? today
        : null;
    final weekdayFormat = DateFormat.E(locale);

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    // 1 January 2023 was a Sunday.
                    weekdayFormat.format(
                      DateTime(2023, 1, 1 + (firstWeekday + i) % 7),
                    ),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.75,
          children: [
            for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
            for (final day in days)
              _DayCell(
                label: day == period.start || day.day == 1
                    ? DateFormat.MMMd(locale).format(day)
                    : DateFormat.d(locale).format(day),
                totals: provider.dailyTotals[day],
                compact: compact,
                isToday: day == today,
                isSelected: day == selected,
                isUpcoming: provider.isUpcomingDate(day),
                onTap: () => setState(() => _selected = day),
              ),
          ],
        ),
        const Divider(height: 24),
        if (selected == null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.calendarHint, textAlign: TextAlign.center),
          )
        else
          _DayDetails(day: selected),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.totals,
    required this.compact,
    required this.isToday,
    required this.isSelected,
    required this.isUpcoming,
    required this.onTap,
  });

  final String label;
  final DayTotals? totals;
  final NumberFormat compact;
  final bool isToday;
  final bool isSelected;
  final bool isUpcoming;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final small = theme.textTheme.labelSmall;
    final totals = this.totals;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: isToday ? BorderSide(color: scheme.primary) : BorderSide.none,
    );

    Widget amount(Money value, Color color) => FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        compact.format(value.toDouble()),
        style: small?.copyWith(color: color),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: isSelected ? scheme.primaryContainer : Colors.transparent,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Opacity(
            // Upcoming days don't count yet, so their amounts are faint
            // (BAL-4).
            opacity: isUpcoming ? 0.5 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (totals != null && totals.expense.isPositive)
                    amount(totals.expense, Colors.red),
                  if (totals != null && totals.income.isPositive)
                    amount(totals.income, Colors.green),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The entries dated on [day], each opening its editor.
class _DayDetails extends StatelessWidget {
  const _DayDetails({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final transactions =
        provider.groupedByDay[day] ?? const <ExpenseTransaction>[];
    final transfers = provider.transfersByDay[day] ?? const <Transfer>[];
    final totals = provider.dailyTotals[day];
    String money(Money amount) => currency.format(amount.toDouble());

    void open(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            DateFormat.yMMMMEEEEd(l10n.localeName).format(day),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: totals == null
              ? null
              : Text(
                  l10n.incomeExpenseLine(
                    money(totals.income),
                    money(totals.expense),
                  ),
                ),
        ),
        if (transactions.isEmpty && transfers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.dayEmpty),
          ),
        for (final tx in transactions)
          Builder(
            builder: (context) {
              final category = provider.categoryById(tx.categoryId);
              final categoryName = category?.label(l10n) ?? '';
              final isIncome = tx.type == TransactionType.income;
              return ListTile(
                leading: CircleAvatar(child: Text(category?.icon ?? '📦')),
                title: Text(tx.label(category, l10n)),
                subtitle: Text(
                  provider.isUpcoming(tx)
                      ? l10n.upcomingCategory(categoryName)
                      : categoryName,
                ),
                trailing: Text(
                  '${isIncome ? '+' : '-'}${money(tx.amount)}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => open(AddTransactionScreen(editing: tx)),
              );
            },
          ),
        for (final transfer in transfers)
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
            title: Text(
              l10n.transferRoute(
                provider.accountById(transfer.fromAccountId)?.label(l10n) ?? '',
                provider.accountById(transfer.toAccountId)?.label(l10n) ?? '',
              ),
            ),
            trailing: Text(money(transfer.amount)),
            onTap: () => open(TransferScreen(editing: transfer)),
          ),
      ],
    );
  }
}

/// Income and expense of the last 6 or 12 periods, ending with the selected
/// one (INS-2).
class _TrendTab extends StatefulWidget {
  const _TrendTab();

  @override
  State<_TrendTab> createState() => _TrendTabState();
}

class _TrendTabState extends State<_TrendTab> {
  int _count = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final theme = Theme.of(context);
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final currency = settings.currencyFormat(locale);
    final compact = settings.compactCurrencyFormat(locale);
    final small = theme.textTheme.labelSmall;
    final trend = provider.trend(_count);
    String money(Money amount) => currency.format(amount.toDouble());

    // Periods that haven't started don't pull the averages down (INS-2).
    final started = [
      for (final totals in trend)
        if (totals.period.timingOn(provider.today) != PeriodTiming.future)
          totals,
    ];
    Money average(Money Function(PeriodTotals totals) pick) => started.isEmpty
        ? Money.zero
        : Money(
            started.fold(0, (sum, totals) => sum + pick(totals).thousandths) ~/
                started.length,
          );

    // A period is named after the month holding its middle day, so
    // "Aug 25 – Sep 24" reads as Sep.
    final monthFormat = DateFormat.MMM(locale);
    String shortLabel(Period period) => monthFormat.format(
      DateTime(
        period.start.year,
        period.start.month,
        period.start.day + period.end.difference(period.start).inDays ~/ 2,
      ),
    );
    final rodWidth = _count == 6 ? 10.0 : 5.0;
    // In right-to-left languages time runs right to left, and the amount
    // axis sits on the right (LANG-5).
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final bars = rtl ? trend.reversed.toList() : trend;
    final amountTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 48,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          child: Text(compact.format(value), style: small),
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SegmentedButton<int>(
            segments: [
              for (final count in const [6, 12])
                ButtonSegment(
                  value: count,
                  label: Text(l10n.trendMonths(count)),
                ),
            ],
            selected: {_count},
            onSelectionChanged: (selection) =>
                setState(() => _count = selection.first),
          ),
        ),
        const SizedBox(height: 24),
        AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              barGroups: [
                for (var i = 0; i < bars.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 2,
                    barRods: [
                      BarChartRodData(
                        toY: bars[i].income.toDouble(),
                        color: Colors.green,
                        width: rodWidth,
                      ),
                      BarChartRodData(
                        toY: bars[i].expense.toDouble(),
                        color: Colors.red,
                        width: rodWidth,
                      ),
                    ],
                  ),
              ],
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                leftTitles: rtl ? const AxisTitles() : amountTitles,
                rightTitles: rtl ? amountTitles : const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        shortLabel(bars[value.toInt()].period),
                        style: small,
                      ),
                    ),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                        currency.format(rod.toY),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.trendAverage(
            money(average((totals) => totals.income)),
            money(average((totals) => totals.expense)),
          ),
        ),
        const Divider(height: 24),
        for (final totals in trend.reversed)
          ListTile(
            title: Text(periodLabel(totals.period, l10n)),
            subtitle: Text(
              l10n.incomeExpenseLine(
                money(totals.income),
                money(totals.expense),
              ),
            ),
            trailing: Text(
              money(totals.net),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: totals.net.isNegative ? Colors.red : Colors.green,
              ),
            ),
          ),
      ],
    );
  }
}
