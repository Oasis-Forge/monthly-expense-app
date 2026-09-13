import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

/// Searches every transaction as you type, with filters for type, category,
/// account, and dates (SRCH-1–SRCH-3).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  TransactionType? _type;
  String? _categoryId;
  String? _accountId;
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final range = _range;
    final result = provider.search(
      TransactionFilter(
        query: _query,
        type: _type,
        categoryId: _categoryId,
        accountId: _accountId,
        from: range?.start,
        to: range?.end,
      ),
      categoryName: (category) => category.label(l10n),
      accountName: (account) => account.label(l10n),
    );
    final categories = [
      for (final type in TransactionType.values)
        if (_type == null || _type == type) ...provider.categoriesFor(type),
    ];
    final dateFormat = DateFormat.MMMd(l10n.localeName);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final (label, type) in <(String, TransactionType?)>[
                  (l10n.allTypesFilter, null),
                  (l10n.expenseLabel, TransactionType.expense),
                  (l10n.incomeLabel, TransactionType.income),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _type == type,
                      onSelected: (_) => setState(() {
                        _type = type;
                        _categoryId = null;
                      }),
                    ),
                  ),
                DropdownButton<String?>(
                  value: categories.any((c) => c.id == _categoryId)
                      ? _categoryId
                      : null,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(child: Text(l10n.allCategoriesFilter)),
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text('${category.icon} ${category.label(l10n)}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                if (provider.accounts.length > 1) ...[
                  const SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: _accountId,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(child: Text(l10n.allAccountsFilter)),
                      for (final account in provider.accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.label(l10n)),
                        ),
                    ],
                    onChanged: (value) => setState(() => _accountId = value),
                  ),
                ],
                const SizedBox(width: 12),
                InputChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    range == null
                        ? l10n.allTimeFilter
                        : l10n.periodRange(
                            dateFormat.format(range.start),
                            dateFormat.format(range.end),
                          ),
                  ),
                  onPressed: _pickRange,
                  onDeleted: range == null
                      ? null
                      : () => setState(() => _range = null),
                  deleteButtonTooltipMessage: l10n.clearDatesTooltip,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.searchSummary(
                  result.transactions.length,
                  currency.format(result.income.toDouble()),
                  currency.format(result.expense.toDouble()),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: result.transactions.isEmpty
                ? Center(child: Text(l10n.noSearchResults))
                : ListView(
                    children: [
                      for (final tx in result.transactions)
                        _ResultTile(transaction: tx, currency: currency),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.transaction, required this.currency});

  final ExpenseTransaction transaction;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final category = provider.categoryById(transaction.categoryId);
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(category?.icon ?? '📦'),
      ),
      title: Text(transaction.label(category, l10n)),
      subtitle: Text(
        l10n.categoryAndDate(
          category?.label(l10n) ?? '',
          DateFormat.yMMMd(l10n.localeName).format(transaction.date),
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${currency.format(transaction.amount.toDouble())}',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddTransactionScreen(editing: transaction),
        ),
      ),
    );
  }
}
