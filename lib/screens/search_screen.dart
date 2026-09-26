import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/csv_export.dart';
import '../models/money.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'amount_style.dart';
import 'csv_export_action.dart';
import 'report_screen.dart';
import 'transaction_detail_screen.dart';
import 'transaction_row_menu.dart';

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

  /// The oldest and newest date across every loaded transaction and
  /// transfer, so the range picker can always reach a record an import or
  /// restore carried in from outside 2015-2100 (SRCH-2). `DateTime(2015)`
  /// and `DateTime(2100)` are the fallback with nothing loaded, and stay
  /// the bound whenever the data doesn't need it widened -- reusing
  /// TransactionProvider's already-loaded lists rather than a new query.
  /// Both lists sort newest first, so the oldest is the last entry and the
  /// newest is the first.
  (DateTime, DateTime) _dateBounds(TransactionProvider provider) {
    var firstDate = DateTime(2015);
    var lastDate = DateTime(2100);
    final transactions = provider.transactions;
    final transfers = provider.transfers;
    DateTime? oldest = transactions.isNotEmpty ? transactions.last.date : null;
    DateTime? newest = transactions.isNotEmpty ? transactions.first.date : null;
    if (transfers.isNotEmpty) {
      final oldestTransfer = transfers.last.date;
      final newestTransfer = transfers.first.date;
      if (oldest == null || oldestTransfer.isBefore(oldest)) {
        oldest = oldestTransfer;
      }
      if (newest == null || newestTransfer.isAfter(newest)) {
        newest = newestTransfer;
      }
    }
    if (oldest != null && oldest.isBefore(firstDate)) {
      firstDate = DateTime(oldest.year);
    }
    if (newest != null && newest.isAfter(lastDate)) {
      lastDate = DateTime(newest.year, 12, 31);
    }
    // Widen further to bracket a range picked earlier, since
    // showDateRangePicker asserts initialDateRange falls within the two
    // (as showDatePicker does for DateField, rules-1-5#12) -- the bounds
    // above can shrink between openings if the record that justified them
    // is deleted while a range built from it is still selected.
    final range = _range;
    if (range != null) {
      if (range.start.isBefore(firstDate)) {
        firstDate = DateTime(range.start.year);
      }
      if (range.end.isAfter(lastDate)) {
        lastDate = DateTime(range.end.year, 12, 31);
      }
    }
    return (firstDate, lastDate);
  }

  Future<void> _pickRange() async {
    final provider = context.read<TransactionProvider>();
    final (firstDate, lastDate) = _dateBounds(provider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
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
    final filter = TransactionFilter(
      query: _query,
      type: _type,
      categoryId: _categoryId,
      accountId: _accountId,
      from: range?.start,
      to: range?.end,
    );
    final result = provider.search(
      filter,
      categoryName: (category) => category.label(l10n),
      accountName: (account) => account.label(l10n),
      decimalMark: currency.symbols.DECIMAL_SEP,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: l10n.exportCsvTooltip,
            // BAK-5: exports exactly the matches listed below.
            onPressed: result.transactions.isEmpty
                ? null
                : () => exportCsv(
                    context,
                    name: 'search-${isoDate(provider.today)}',
                    transactions: result.transactions,
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l10n.exportPdfMenu,
            // PDF-1: the report opens on the dates being searched.
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ReportScreen(filter: filter)),
            ),
          ),
        ],
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
                    padding: const EdgeInsetsDirectional.only(end: 8),
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
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.searchSummary(
                  result.transactions.length,
                  currency.money(result.income),
                  currency.money(result.expense),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: result.transactions.isEmpty
                ? Center(child: Text(l10n.noSearchResults))
                : ListView.builder(
                    // Builds only the rows on screen, rather than every
                    // match at once (SRCH-1, lifecycle-perf#10).
                    itemCount: result.transactions.length,
                    itemBuilder: (context, index) => _ResultTile(
                      transaction: result.transactions[index],
                      currency: currency,
                    ),
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
    final color = signedColor(context, isIncome: isIncome);

    return ListTile(
      // The category's colour (CAT-6); the amount carries income and expense.
      leading: CircleAvatar(
        backgroundColor: categoryTint(category),
        child: Text(category?.icon ?? '📦'),
      ),
      title: Text(transaction.label(category, l10n)),
      subtitle: Text(
        l10n.categoryAndDate(
          category?.label(l10n) ?? '',
          DateFormat.yMMMd(l10n.localeName).format(transaction.date),
        ),
      ),
      // ROW-1: the amount, then the row's own menu.
      trailing: TransactionRowTrailing(
        transaction: transaction,
        amount: Text(
          signedAmount(currency, transaction.amount, isIncome: isIncome),
          // The sign stays in front of the amount in Arabic (LANG-5, CUR-5).
          style: amountStyle(
            TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(id: transaction.id),
        ),
      ),
    );
  }
}
