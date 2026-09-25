import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'empty_state.dart';
import '../l10n/labels.dart';
import '../models/budget.dart';
import '../models/insights.dart';
import '../models/money.dart';
import '../models/period.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/ads_config.dart';
import 'account_filter_button.dart';
import 'ad_slot.dart';
import 'amount_style.dart';
import 'budget_progress.dart';
import 'budgets_screen.dart';
import 'note_form_screen.dart';
import 'period_selector.dart';
import 'report_screen.dart';
import 'transaction_detail_screen.dart';
import 'transaction_row_menu.dart';
import 'transfer_screen.dart';

/// Charts for the selected period: spending or income by category with
/// budgets, a calendar of daily totals, and the trend over recent periods
/// (INS-1–INS-3).
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, this.initialTab = 0});

  /// Which tab opens first: 0 categories, 1 calendar, 2 trend. Home's period
  /// label opens the calendar (INS-4).
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.insightsTitle),
          actions: [
            // ACC-6: which account these three views are for. Insights names
            // its own title, so a third action here doesn't squeeze anything
            // the way it would on Home (NAV-6).
            const AccountFilterAction(),
            IconButton(
              icon: const Icon(Icons.savings_outlined),
              tooltip: l10n.budgetsTooltip,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const BudgetsScreen())),
            ),
            // PDF-1: a report for the period Insights is showing.
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: l10n.exportPdfMenu,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ReportScreen())),
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
            // ACC-6: names the account while one is chosen, so a filtered
            // chart is never read as the whole of the money. Nothing at all
            // while every account is showing, so the usual case keeps the
            // room for the charts.
            AccountFilterBanner(),
            Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [_CategoriesTab(), _CalendarTab(), _TrendTab()],
              ),
            ),
          ],
        ),
        // The second of the two slots (ADS-1), outside the charts and above
        // the system navigation bar (ADS-3).
        bottomNavigationBar: const AdSlot(placement: AdPlacement.insights),
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
    // Resolved once: the slice and its line in the list below must read the
    // same colour, or the chart and the legend disagree (CAT-6).
    final swatches = [
      for (final entry in entries)
        categorySwatch(provider.categoryById(entry.key)),
    ];
    // INS-6: the same period a month back, counted the same way.
    final previous = isExpense
        ? provider.previousExpenseByCategory
        : provider.previousIncomeByCategory;
    final comparable = provider.hasEarlierRecords;
    final difference =
        total - previous.values.fold(Money.zero, (a, b) => a + b);
    final percent = NumberFormat.percentPattern(l10n.localeName)
      ..maximumFractionDigits = 0;

    /// The share a category has risen or fallen by (INS-6): "new" where it
    /// had nothing last period, and nothing at all where the change rounds
    /// away, since the amounts beside it already say more than "0%" would.
    String? changeLabel(String categoryId, Money now) {
      if (!comparable) return null;
      final share = shareChange(
        before: previous[categoryId] ?? Money.zero,
        now: now,
      );
      if (share == null) return l10n.categoryNewLabel;
      // A fall this small formats with intl's own minus, from the unrounded
      // value, even once "0%" would print for a rise of the same size — so
      // the magnitude, not the formatted string, decides whether to hide it.
      if (share.abs() * 100 < 0.5) return null;
      if (share < 0) return percent.format(share);
      // A rise: format the negated share so the language's own negative
      // pattern places the sign against its digits, then swap that minus for
      // a plus the same way signedMoney does, rather than paste one in front
      // where bidi could carry it off (LANG-5, CUR-5).
      return swapMinusForPlus(percent.format(-share), percent.locale);
    }

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
            BudgetProgress(status: status, currency: currency),
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
                      color: swatches[i],
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
                ? l10n.totalSpent(currency.money(total))
                : l10n.totalIncome(currency.money(total)),
            style: theme.textTheme.titleMedium,
          ),
          // INS-6: how the period compares with the one before it. The
          // earliest period on record has nothing behind it, and a
          // comparison against nothing would read as "you spent nothing".
          if (comparable)
            Text(switch (difference.thousandths) {
              0 => l10n.comparedSame,
              > 0 => l10n.comparedMore(currency.money(difference)),
              _ => l10n.comparedLess(currency.money(-difference)),
            }, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: swatches[i],
                child: Text(
                  provider.categoryById(entries[i].key)?.icon ?? '📦',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              title: Text(
                provider.categoryById(entries[i].key)?.label(l10n) ?? '',
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currency.money(entries[i].value), style: amountStyle()),
                  // INS-6: what it was doing last month, beside what it is
                  // doing now. Left in the ordinary colour: red and green
                  // already mean money out and money in (CUR-5), and a
                  // second meaning for them would cost the first.
                  if (changeLabel(entries[i].key, entries[i].value)
                      case final change?)
                    Text(
                      change,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ],
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
                // NOTE-5, INS-1: marks days with an open note due.
                hasNoteDue: provider.notesDueOn(day).isNotEmpty,
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
    required this.hasNoteDue,
    required this.onTap,
  });

  final String label;
  final DayTotals? totals;
  final CompactCurrencyFormat compact;
  final bool isToday;
  final bool isSelected;
  final bool isUpcoming;

  /// Marks the day with an open note due (NOTE-5, INS-1).
  final bool hasNoteDue;
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
        style: amountStyle(small).copyWith(color: color),
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
          child: Stack(
            children: [
              Opacity(
                // Upcoming days don't count yet, so their amounts are faint
                // (BAL-4).
                opacity: isUpcoming ? 0.5 : 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
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
                        amount(totals.expense, expenseColor(context)),
                      if (totals != null && totals.income.isPositive)
                        amount(totals.income, incomeColor(context)),
                    ],
                  ),
                ),
              ),
              if (hasNoteDue)
                PositionedDirectional(
                  top: 2,
                  end: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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
    String money(Money amount) => currency.money(amount);

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
                leading: CircleAvatar(
                  backgroundColor: categoryTint(category),
                  child: Text(category?.icon ?? '📦'),
                ),
                title: Text(tx.label(category, l10n)),
                subtitle: Text(
                  provider.isUpcoming(tx)
                      ? l10n.upcomingCategory(categoryName)
                      : categoryName,
                ),
                // ROW-1: the amount, then the row's own menu.
                trailing: TransactionRowTrailing(
                  transaction: tx,
                  amount: Text(
                    signedAmount(currency, tx.amount, isIncome: isIncome),
                    // The sign stays in front of the amount in Arabic
                    // (LANG-5, CUR-5).
                    style: amountStyle().copyWith(
                      color: signedColor(context, isIncome: isIncome),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () => open(TransactionDetailScreen(id: tx.id)),
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
            trailing: Text(money(transfer.amount), style: amountStyle()),
            onTap: () => open(TransferScreen(editing: transfer)),
          ),
        // NOTE-5, INS-1: open notes due this day.
        if (provider.notesDueOn(day).isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              l10n.dayNotesDueHeader,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        for (final note in provider.notesDueOn(day))
          ListTile(
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: Text(
              note.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => open(NoteFormScreen(editing: note)),
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

    // EMPTY-4: a trend needs a second period before it is a trend, and
    // nothing the person can do here makes one. Only time does, so this
    // says so and offers nothing.
    if (!provider.hasEarlierRecords) {
      return EmptyState(
        icon: Icons.show_chart_outlined,
        title: l10n.trendTab,
        message: l10n.trendNeedsMorePeriods,
      );
    }

    final trend = provider.trend(_count);
    String money(Money amount) => currency.money(amount);

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
        getTitlesWidget: (value, meta) {
          // The chart also labels the top of the axis, which is rarely a
          // round amount and can land on the gridline label just below it
          // (INS-5). The gridlines give the scale on their own.
          final steps = value / meta.appliedInterval;
          if (value == meta.max && (steps - steps.round()).abs() > 1e-6) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            child: Text(
              compact.format(value),
              style: small,
              maxLines: 1,
              softWrap: false,
            ),
          );
        },
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
                        currency.money(Money((rod.toY * 1000).round())),
                        amountStyle(
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
              style: amountStyle().copyWith(
                fontWeight: FontWeight.w600,
                // CUR-5: a net can fall either way, so it is coloured only
                // when it is below zero.
                color: balanceColor(context, totals.net),
              ),
            ),
          ),
      ],
    );
  }
}
