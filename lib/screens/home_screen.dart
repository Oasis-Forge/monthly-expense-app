import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = NumberFormat.currency(symbol: '\$');
    final grouped = provider.groupedByDay;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: l10n.statsTooltip,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          _PeriodSelector(provider: provider),
          _SummaryCard(
            income: provider.periodIncome,
            expense: provider.periodExpense,
            balance: provider.periodNet,
            currency: currency,
          ),
          const Divider(height: 1),
          Expanded(
            child: grouped.isEmpty
                ? Center(child: Text(l10n.emptyPeriod))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      for (final entry in grouped.entries)
                        _DaySection(
                          day: entry.key,
                          transactions: entry.value,
                          currency: currency,
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        icon: const Icon(Icons.add),
        label: Text(l10n.addButton),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final TransactionProvider provider;

  const _PeriodSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.previousPeriod,
          ),
          Text(
            periodLabel(provider.period, AppLocalizations.of(context)),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.nextPeriod,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Money income;
  final Money expense;
  final Money balance;
  final NumberFormat currency;

  const _SummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              l10n.balanceLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              currency.format(balance.toDouble()),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: balance.isNegative ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AmountTile(
                  label: l10n.incomeLabel,
                  amount: income,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                  currency: currency,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _AmountTile(
                  label: l10n.expenseLabel,
                  amount: expense,
                  color: Colors.red,
                  icon: Icons.arrow_upward,
                  currency: currency,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  final String label;
  final Money amount;
  final Color color;
  final IconData icon;
  final NumberFormat currency;

  const _AmountTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          currency.format(amount.toDouble()),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<ExpenseTransaction> transactions;
  final NumberFormat currency;

  const _DaySection({
    required this.day,
    required this.transactions,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            DateFormat.yMMMd(l10n.localeName).format(day),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: Colors.grey.shade600),
          ),
        ),
        for (final tx in transactions)
          _TransactionTile(transaction: tx, currency: currency),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final ExpenseTransaction transaction;
  final NumberFormat currency;

  const _TransactionTile({required this.transaction, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final category = provider.categoryById(transaction.categoryId);
    final categoryName = category?.label(l10n) ?? '';
    final isIncome = transaction.type == TransactionType.income;
    final sign = isIncome ? '+' : '-';
    final color = isIncome ? Colors.green : Colors.red;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      // Delete before the row animates away; if that fails, it slides back.
      confirmDismiss: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await provider.deleteTransaction(transaction.id);
          return true;
        } catch (_) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
          return false;
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            category?.icon ?? '📦',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        // ADD-1: the title, else the note, else the category name.
        title: Text(transaction.title ?? transaction.note ?? categoryName),
        subtitle: Text(
          provider.isUpcoming(transaction)
              ? l10n.upcomingCategory(categoryName)
              : categoryName,
        ),
        trailing: Text(
          '$sign${currency.format(transaction.amount.toDouble())}',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(editing: transaction),
          ),
        ),
      ),
    );
  }
}
