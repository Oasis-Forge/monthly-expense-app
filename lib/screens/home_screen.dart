import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'delete_snack_bar.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final currency = settings.currencyFormat(l10n.localeName);
    final days = {
      ...provider.groupedByDay.keys,
      ...provider.transfersByDay.keys,
    }.toList()..sort((a, b) => b.compareTo(a));

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
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: l10n.transferTooltip,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TransferScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTooltip,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          _PeriodSelector(provider: provider),
          _SummaryCard(
            income: provider.periodIncome,
            expense: provider.periodExpense,
            // BAL-3: the closing balance, unless carrying forward is off.
            balance: settings.showCarriedForward
                ? provider.closingBalance
                : provider.periodNet,
            carriedForward: settings.showCarriedForward
                ? provider.carriedForward
                : null,
            currency: currency,
          ),
          const Divider(height: 1),
          Expanded(
            child: days.isEmpty
                ? Center(child: Text(l10n.emptyPeriod))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      for (final day in days)
                        _DaySection(
                          day: day,
                          transactions: provider.groupedByDay[day] ?? const [],
                          transfers: provider.transfersByDay[day] ?? const [],
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

  /// Shown under the balance when carrying forward is on (BAL-2).
  final Money? carriedForward;
  final NumberFormat currency;

  const _SummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.carriedForward,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final carried = carriedForward;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              carried == null ? l10n.periodNetLabel : l10n.balanceLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              currency.format(balance.toDouble()),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: balance.isNegative ? Colors.red : Colors.green,
              ),
            ),
            if (carried != null)
              Text(
                l10n.carriedForwardLine(currency.format(carried.toDouble())),
                style: Theme.of(context).textTheme.bodySmall,
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
  final List<Transfer> transfers;
  final NumberFormat currency;

  const _DaySection({
    required this.day,
    required this.transactions,
    required this.transfers,
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
        for (final transfer in transfers)
          _TransferTile(transfer: transfer, currency: currency),
      ],
    );
  }
}

/// A red swipe background shared by transaction and transfer rows.
Widget _deleteBackground() => Container(
  color: Colors.red,
  alignment: Alignment.centerRight,
  padding: const EdgeInsets.only(right: 20),
  child: const Icon(Icons.delete, color: Colors.white),
);

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
      background: _deleteBackground(),
      // Delete before the row animates away; if that fails, it slides back.
      confirmDismiss: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await provider.deleteTransaction(transaction.id);
        } catch (_) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
          return false;
        }
        showDeletedSnackBar(messenger, provider, l10n, transaction.id);
        return true;
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            category?.icon ?? '📦',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(transaction.label(category, l10n)),
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

/// A transfer row: never income or expense, so it has no sign (ACC-3).
class _TransferTile extends StatelessWidget {
  final Transfer transfer;
  final NumberFormat currency;

  const _TransferTile({required this.transfer, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final from = provider.accountById(transfer.fromAccountId)?.label(l10n);
    final to = provider.accountById(transfer.toAccountId)?.label(l10n);
    final description = transfer.note ?? l10n.transferLabel;

    return Dismissible(
      key: ValueKey('transfer-${transfer.id}'),
      direction: DismissDirection.endToStart,
      background: _deleteBackground(),
      confirmDismiss: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await provider.deleteTransfer(transfer.id);
        } catch (_) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.transferSaveFailed)),
          );
          return false;
        }
        showTransferDeletedSnackBar(messenger, provider, l10n, transfer.id);
        return true;
      },
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
        title: Text(l10n.transferRoute(from ?? '', to ?? '')),
        subtitle: Text(
          provider.isUpcomingDate(transfer.date)
              ? l10n.upcomingCategory(description)
              : description,
        ),
        trailing: Text(
          currency.format(transfer.amount.toDouble()),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TransferScreen(editing: transfer)),
        ),
      ),
    );
  }
}
