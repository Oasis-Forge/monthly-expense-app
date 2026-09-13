import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currency = NumberFormat.currency(symbol: '\$');
    final grouped = provider.groupedBySelectedDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'Stats',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          _MonthSelector(provider: provider),
          _SummaryCard(
            income: provider.monthlyIncome,
            expense: provider.monthlyExpense,
            balance: provider.monthlyBalance,
            currency: currency,
          ),
          const Divider(height: 1),
          Expanded(
            child: grouped.isEmpty
                ? const Center(child: Text('No transactions this month yet.'))
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
        label: const Text('Add'),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final TransactionProvider provider;

  const _MonthSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.previousMonth,
          ),
          Text(
            DateFormat.yMMMM().format(provider.selectedMonth),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.nextMonth,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final NumberFormat currency;

  const _SummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Balance', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              currency.format(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AmountTile(
                  label: 'Income',
                  amount: income,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                  currency: currency,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _AmountTile(
                  label: 'Expense',
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
  final double amount;
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
          currency.format(amount),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            DateFormat.yMMMd().format(day),
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
        final provider = context.read<TransactionProvider>();
        final messenger = ScaffoldMessenger.of(context);
        try {
          await provider.deleteTransaction(transaction.id);
          return true;
        } catch (_) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text("Couldn't delete the transaction. Try again."),
            ),
          );
          return false;
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            Categories.icons[transaction.category] ?? '📦',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(transaction.category),
        trailing: Text(
          '$sign${currency.format(transaction.amount)}',
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
