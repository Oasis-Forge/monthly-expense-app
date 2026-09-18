import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/csv_export.dart';
import '../models/money.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/ads_config.dart';
import 'accounts_screen.dart';
import 'ad_slot.dart';
import 'add_transaction_screen.dart';
import 'backup_screen.dart';
import 'budgets_screen.dart';
import 'categories_screen.dart';
import 'csv_export_action.dart';
import 'delete_snack_bar.dart';
import 'insights_screen.dart';
import 'notes_screen.dart';
import 'period_selector.dart';
import 'recurring_screen.dart';
import 'report_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'transaction_detail_screen.dart';
import 'transfer_screen.dart';
import 'trash_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  /// Exports the selected period's transactions and transfers (BAK-5).
  static Future<void> _exportPeriod(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final period = provider.period;
    return exportCsv(
      context,
      name: '${isoDate(period.start)}_${isoDate(period.lastDay)}',
      transactions: provider.periodTransactions,
      transfers: provider.periodTransfers,
    );
  }

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
    final dueCount = provider.dueOccurrences.length;
    final overCount = provider.budgetsOver;
    final dueNotesCount = provider.notesDueInPeriod.length;
    final lastBackup = settings.lastBackupAt;
    // RUN-1: before anything is recorded, Home offers one clear action.
    final firstRun =
        provider.isLoaded &&
        provider.transactions.isEmpty &&
        provider.transfers.isEmpty &&
        provider.deletedTransactions.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.searchTooltip,
            onPressed: () => _open(context, const SearchScreen()),
          ),
          // NAV-6: the toolbar keeps two actions so the name still fits at
          // large text; Insights has three named rows in the drawer instead.
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => _open(context, const SettingsScreen()),
          ),
        ],
      ),
      // Everything that isn't Home lives here, named and grouped, instead of
      // behind a three-dot menu nobody opened (NAV-1, NAV-2).
      drawer: const _HomeDrawer(),
      body: Column(
        children: [
          // INS-4: the label opens the calendar for the period it names.
          PeriodSelector(
            onLabelTap: () =>
                _open(context, const InsightsScreen(initialTab: 1)),
          ),
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
          if (dueCount > 0)
            _Notice(
              icon: Icons.event_repeat,
              color: Theme.of(context).colorScheme.primary,
              text: l10n.recurringDueNotice(dueCount),
              onTap: () => _open(context, const RecurringScreen()),
            ),
          if (overCount > 0)
            _Notice(
              icon: Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              text: l10n.budgetsOverNotice(overCount),
              onTap: () => _open(context, const InsightsScreen()),
            ),
          if (dueNotesCount > 0)
            _Notice(
              icon: Icons.sticky_note_2_outlined,
              color: Theme.of(context).colorScheme.primary,
              text: l10n.notesDueNotice(dueNotesCount),
              onTap: () => _open(context, const NotesScreen()),
            ),
          if (settings.backupReminderDue(provider.transactions.length))
            _Notice(
              icon: Icons.backup_outlined,
              color: Theme.of(context).colorScheme.tertiary,
              text: lastBackup == null
                  ? l10n.backupReminderNever
                  : l10n.backupReminderSince(
                      DateFormat.yMMMd(l10n.localeName).format(lastBackup),
                    ),
              onTap: () => _open(context, const BackupScreen()),
              onDismiss: settings.snoozeBackupReminder,
            ),
          const Divider(height: 1),
          Expanded(
            child: firstRun
                ? const _FirstRun()
                : days.isEmpty
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
      floatingActionButton: firstRun
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _open(context, const AddTransactionScreen()),
              icon: const Icon(Icons.add),
              label: Text(l10n.addButton),
            ),
      // ADS-1, ADS-3: the slot goes here rather than in the body, so it sits
      // outside the day list, above the system navigation bar, and the add
      // button lifts above it instead of sitting on top of it.
      bottomNavigationBar: const AdSlot(placement: AdPlacement.home),
    );
  }
}

/// Every destination that isn't Home, grouped under headings and reached
/// from the toolbar's menu button or an edge swipe (NAV-1–NAV-3, NAV-5).
class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  /// Closes the drawer, then runs [go], so the drawer isn't left open behind
  /// the screen it opened (NAV-3).
  void _leave(BuildContext context, VoidCallback go) {
    Navigator.of(context).pop();
    go();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.read<TransactionProvider>();

    Widget header(String text) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 16, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    Widget row(IconData icon, String label, VoidCallback go) => ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => _leave(context, go),
    );

    void open(Widget screen) => HomeScreen._open(context, screen);

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(28, 24, 16, 8),
              child: Text(l10n.appTitle, style: theme.textTheme.titleLarge),
            ),
            header(l10n.drawerAddHeader),
            row(
              Icons.arrow_upward,
              l10n.drawerAddExpense,
              () => open(
                const AddTransactionScreen(startAs: TransactionType.expense),
              ),
            ),
            row(
              Icons.arrow_downward,
              l10n.drawerAddIncome,
              () => open(
                const AddTransactionScreen(startAs: TransactionType.income),
              ),
            ),
            row(
              Icons.swap_horiz,
              l10n.transferTitle,
              () => open(const TransferScreen()),
            ),
            header(l10n.drawerPlanHeader),
            row(
              Icons.savings_outlined,
              l10n.budgetsTitle,
              () => open(const BudgetsScreen()),
            ),
            row(
              Icons.event_repeat,
              l10n.recurringTitle,
              () => open(const RecurringScreen()),
            ),
            row(
              Icons.sticky_note_2_outlined,
              l10n.notesTitle,
              () => open(const NotesScreen()),
            ),
            header(l10n.drawerReviewHeader),
            // Each view of Insights is its own row, so the one being looked
            // for is reached in one tap rather than a tap and a tab (NAV-1).
            row(
              Icons.pie_chart_outline,
              l10n.drawerSpending,
              () => open(const InsightsScreen()),
            ),
            row(
              Icons.calendar_month_outlined,
              l10n.calendarTab,
              () => open(const InsightsScreen(initialTab: 1)),
            ),
            row(
              Icons.insights_outlined,
              l10n.trendTab,
              () => open(const InsightsScreen(initialTab: 2)),
            ),
            row(
              Icons.search,
              l10n.searchTooltip,
              () => open(const SearchScreen()),
            ),
            header(l10n.drawerManageHeader),
            row(
              Icons.account_balance_wallet_outlined,
              l10n.accountsTitle,
              () => open(const AccountsScreen()),
            ),
            row(
              Icons.category_outlined,
              l10n.categoriesTitle,
              () => open(const CategoriesScreen()),
            ),
            row(
              Icons.settings_outlined,
              l10n.settingsTitle,
              () => open(const SettingsScreen()),
            ),
            header(l10n.drawerDataHeader),
            row(
              Icons.table_view_outlined,
              l10n.exportCsvMenu,
              () => HomeScreen._exportPeriod(context, provider),
            ),
            row(
              Icons.picture_as_pdf_outlined,
              l10n.exportPdfMenu,
              () => open(const ReportScreen()),
            ),
            row(
              Icons.backup_outlined,
              l10n.backupTitle,
              () => open(const BackupScreen()),
            ),
            row(
              Icons.delete_outline,
              l10n.trashTitle,
              () => open(const TrashScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

/// The welcome shown until the first transaction is added (RUN-1).
class _FirstRun extends StatelessWidget {
  const _FirstRun();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.firstRunTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.firstRunMessage, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  HomeScreen._open(context, const AddTransactionScreen()),
              icon: const Icon(Icons.add),
              label: Text(l10n.addFirstTransactionButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable one-line notice under the balance card, optionally with a
/// button that dismisses it.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.text,
    required this.onTap,
    this.onDismiss,
  });

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      color: color.withValues(alpha: 0.12),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(text),
        trailing: onDismiss == null
            ? const Icon(Icons.chevron_right)
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: AppLocalizations.of(context).notNowTooltip,
                onPressed: onDismiss,
              ),
        onTap: onTap,
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
            // Each side gets half the card, so long labels and large amounts
            // fit at any text size and in every language (LANG-6).
            Row(
              children: [
                Expanded(
                  child: _AmountTile(
                    label: l10n.incomeLabel,
                    amount: income,
                    color: Colors.green,
                    icon: Icons.arrow_downward,
                    currency: currency,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: _AmountTile(
                    label: l10n.expenseLabel,
                    amount: expense,
                    color: Colors.red,
                    icon: Icons.arrow_upward,
                    currency: currency,
                  ),
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
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // A large amount shrinks to fit rather than breaking across lines.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            currency.format(amount.toDouble()),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
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
  alignment: AlignmentDirectional.centerEnd,
  padding: const EdgeInsetsDirectional.only(end: 20),
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
          // The sign stays in front of the amount in Arabic (LANG-5).
          textDirection: TextDirection.ltr,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(id: transaction.id),
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
