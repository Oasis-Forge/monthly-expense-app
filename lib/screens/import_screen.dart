import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/csv_import.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart' show foldForSearch;
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/backup_service.dart';

/// Reads a CSV another app wrote and shows what importing it would do, before
/// any of it happens (IMP-1–IMP-8).
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  CsvTable? _table;

  /// Which column holds which field: matched from the header when the file is
  /// opened, then whatever the user corrects it to (IMP-3).
  Map<ImportField, int> _columns = const {};
  bool _dayFirst = true;
  bool _busy = false;

  /// What the user picked on the preview for a name this app hasn't got
  /// (IMP-7), by the name as the file wrote it.
  final Map<String, String> _categoryChoice = {};
  final Map<String, String> _accountChoice = {};

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    final service = context.read<BackupService>();
    setState(() => _busy = true);
    String? text;
    try {
      text = await service.openText();
    } catch (_) {
      if (mounted) _show(l10n.importReadFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (text == null || !mounted) return;
    final table = parseCsv(text);
    setState(() {
      _table = table;
      _columns = matchColumns(table.header);
      _categoryChoice.clear();
      _accountChoice.clear();
    });
  }

  /// The app's own category for a name in the file, matched on the name the
  /// user sees and on the built-in key, so an English export still lands in
  /// the right place in a translated app.
  String? _matchedCategoryId(
    String name,
    TransactionProvider provider,
    AppLocalizations l10n,
  ) {
    final wanted = foldForSearch(name).trim();
    if (wanted.isEmpty) return null;
    for (final category in provider.categories) {
      if (foldForSearch(category.label(l10n)).trim() == wanted ||
          category.defaultKey == wanted) {
        return category.id;
      }
    }
    return null;
  }

  String? _matchedAccountId(
    String name,
    TransactionProvider provider,
    AppLocalizations l10n,
  ) {
    final wanted = foldForSearch(name).trim();
    if (wanted.isEmpty) return null;
    for (final account in provider.accounts) {
      if (foldForSearch(account.label(l10n)).trim() == wanted ||
          account.defaultKey == wanted) {
        return account.id;
      }
    }
    return null;
  }

  /// Every category name the plan will import, against the ID it should use:
  /// what matched by name, overridden by what the user chose (IMP-7).
  Map<String, String> _categoryIds(
    ImportPlan plan,
    TransactionProvider provider,
    AppLocalizations l10n,
  ) {
    final ids = <String, String>{};
    for (final row in plan.importing) {
      final name = row.categoryName;
      if (name.isEmpty || ids.containsKey(name)) continue;
      final id =
          _categoryChoice[name] ?? _matchedCategoryId(name, provider, l10n);
      if (id != null) ids[name] = id;
    }
    return ids;
  }

  Map<String, String> _accountIds(
    ImportPlan plan,
    TransactionProvider provider,
    AppLocalizations l10n,
  ) {
    final ids = <String, String>{};
    for (final row in plan.importing) {
      for (final name in [row.accountName, row.toAccountName]) {
        if (name.isEmpty || ids.containsKey(name)) continue;
        final id =
            _accountChoice[name] ?? _matchedAccountId(name, provider, l10n);
        if (id != null) ids[name] = id;
      }
    }
    return ids;
  }

  Future<void> _import(ImportPlan plan) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TransactionProvider>();
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final written = await provider.applyImport(
        plan,
        categoryIds: _categoryIds(plan, provider, l10n),
        accountIds: _accountIds(plan, provider, l10n),
      );
      if (!mounted) return;
      _show(l10n.importDone(written));
      navigator.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _show(l10n.importFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final table = _table;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importTitle),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: table == null ? _intro(l10n) : _preview(context, table, l10n),
    );
  }

  Widget _intro(AppLocalizations l10n) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(l10n.importIntro),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: _busy ? null : _pick,
        icon: const Icon(Icons.upload_file_outlined),
        label: Text(l10n.importChooseFile),
      ),
    ],
  );

  Widget _preview(BuildContext context, CsvTable table, AppLocalizations l10n) {
    final provider = context.watch<TransactionProvider>();
    final currency = context.watch<SettingsProvider>().currencyFormat(
      l10n.localeName,
    );
    final plan = planImport(
      table: table,
      columns: _columns,
      dayFirst: _dayFirst,
      categoryIdFor: (name) => _matchedCategoryId(name, provider, l10n),
      accountIdFor: (name) => _matchedAccountId(name, provider, l10n),
      existingIdentities: provider.importIdentities,
    );
    final counts = plan.skipCounts;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (plan.refusal != null) _Refusal(refusal: plan.refusal!),

        Text(l10n.importColumnsHeader, style: _sectionStyle(context)),
        Text(l10n.importColumnsSubtitle, style: _mutedStyle(context)),
        const SizedBox(height: 12),
        for (final field in ImportField.values) ...[
          _ColumnField(
            field: field,
            header: table.header,
            column: _columns[field],
            onChanged: (column) => _setColumn(field, column),
          ),
          const SizedBox(height: 12),
        ],

        if (_columns.containsKey(ImportField.date)) ...[
          const SizedBox(height: 4),
          Text(l10n.importDateOrderLabel, style: _mutedStyle(context)),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(l10n.importDayFirst)),
              ButtonSegment(value: false, label: Text(l10n.importMonthFirst)),
            ],
            selected: {_dayFirst},
            onSelectionChanged: (chosen) =>
                setState(() => _dayFirst = chosen.first),
          ),
        ],

        if (plan.rows.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l10n.importCountsHeader, style: _sectionStyle(context)),
          const SizedBox(height: 8),
          Text(l10n.importWillImport(plan.importCount)),
          for (final reason in SkipReason.values)
            if (counts[reason] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _skipLine(l10n, reason, counts[reason]!),
                  style: _mutedStyle(context),
                ),
              ),
        ],

        if (plan.unknownCategories.isNotEmpty ||
            plan.unknownAccounts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l10n.importNamesHeader, style: _sectionStyle(context)),
          Text(l10n.importNamesSubtitle, style: _mutedStyle(context)),
          const SizedBox(height: 12),
          for (final MapEntry(key: name, value: type) in _unknownCategories(
            plan,
          ).entries) ...[
            _NameChoice(
              name: name,
              chosen: _categoryChoice[name] ?? provider.otherCategoryId(type),
              options: {
                for (final category in provider.categoriesFor(type))
                  category.id: category.label(l10n),
              },
              onChanged: (id) => setState(() => _categoryChoice[name] = id),
            ),
            const SizedBox(height: 12),
          ],
          for (final name in plan.unknownAccounts) ...[
            _NameChoice(
              name: name,
              chosen: _accountChoice[name] ?? provider.defaultAccountId(),
              options: {
                for (final account in provider.activeAccounts)
                  account.id: account.label(l10n),
              },
              onChanged: (id) => setState(() => _accountChoice[name] = id),
            ),
            const SizedBox(height: 12),
          ],
        ],

        if (plan.rows.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.importRowsHeader, style: _sectionStyle(context)),
          const SizedBox(height: 8),
          for (final row in plan.rows.take(_previewRows))
            _RowLine(
              row: row,
              rawDate: _rawCell(table, row, ImportField.date),
              currency: currency,
              skipLine: row.skipped == null
                  ? null
                  : _rowSkipLine(l10n, row.skipped!),
            ),
          if (plan.rows.length > _previewRows)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.importMoreRows(plan.rows.length - _previewRows),
                style: _mutedStyle(context),
              ),
            ),
        ],

        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy || plan.importCount == 0
              ? null
              : () => _import(plan),
          child: Text(l10n.importButton(plan.importCount)),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _pick,
          child: Text(l10n.importChooseAnother),
        ),
      ],
    );
  }

  /// How many rows the preview shows (IMP-5).
  static const _previewRows = 8;

  /// Gives [field] the column the user picked, taking it off whichever field
  /// had it, so two fields can't read the same column.
  void _setColumn(ImportField field, int? column) {
    setState(() {
      final columns = {..._columns};
      if (column == null) {
        columns.remove(field);
      } else {
        columns.removeWhere((_, taken) => taken == column);
        columns[field] = column;
      }
      _columns = columns;
    });
  }

  /// The cell a row was read from, for showing what the app couldn't make
  /// sense of rather than an empty space.
  String _rawCell(CsvTable table, ImportRow row, ImportField field) {
    final column = _columns[field];
    final index = row.line - 2;
    if (column == null || index < 0 || index >= table.rows.length) return '';
    final cells = table.rows[index];
    return column < cells.length ? cells[column] : '';
  }

  /// The category names the app hasn't got, in the order they first appear,
  /// each against the kind of category it needs: the rows using a name say
  /// whether it is spending or earning (IMP-7).
  Map<String, TransactionType> _unknownCategories(ImportPlan plan) {
    final unknown = <String, TransactionType>{};
    for (final row in plan.importing) {
      if (!plan.unknownCategories.contains(row.categoryName)) continue;
      unknown.putIfAbsent(
        row.categoryName,
        () => row.type == ImportedType.income
            ? TransactionType.income
            : TransactionType.expense,
      );
    }
    return unknown;
  }

  /// Why one row won't import, said the short way — the counts above the
  /// list already do the counting.
  String _rowSkipLine(AppLocalizations l10n, SkipReason reason) =>
      switch (reason) {
        SkipReason.unreadableDate => l10n.importRowUnreadableDate,
        SkipReason.unreadableAmount => l10n.importRowUnreadableAmount,
        SkipReason.zeroAmount => l10n.importRowZero,
        SkipReason.alreadyThere => l10n.importRowAlreadyThere,
        SkipReason.incompleteTransfer => l10n.importRowIncompleteTransfer,
      };

  String _skipLine(AppLocalizations l10n, SkipReason reason, int count) =>
      switch (reason) {
        SkipReason.unreadableDate => l10n.importSkippedDate(count),
        SkipReason.unreadableAmount => l10n.importSkippedAmount(count),
        SkipReason.zeroAmount => l10n.importSkippedZero(count),
        SkipReason.alreadyThere => l10n.importSkippedAlreadyThere(count),
        SkipReason.incompleteTransfer => l10n.importSkippedTransfer(count),
      };
}

TextStyle? _sectionStyle(BuildContext context) =>
    Theme.of(context).textTheme.titleMedium;

TextStyle? _mutedStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

/// Why the file can't be imported as it stands (IMP-4).
class _Refusal extends StatelessWidget {
  const _Refusal({required this.refusal});

  final ImportRefusal refusal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(switch (refusal) {
                ImportRefusal.empty => l10n.importRefusedEmpty,
                ImportRefusal.noDateColumn => l10n.importRefusedNoDate,
                ImportRefusal.noAmountColumn => l10n.importRefusedNoAmount,
                ImportRefusal.noUsableRows => l10n.importRefusedNoRows,
              }, style: TextStyle(color: scheme.onErrorContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

/// One field of the import, and the column it reads (IMP-3).
class _ColumnField extends StatelessWidget {
  const _ColumnField({
    required this.field,
    required this.header,
    required this.column,
    required this.onChanged,
  });

  final ImportField field;
  final List<String> header;
  final int? column;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<int?>(
      initialValue: column,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: _fieldLabel(field, l10n),
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(child: Text(l10n.importColumnNone)),
        for (var i = 0; i < header.length; i++)
          DropdownMenuItem(
            value: i,
            child: Text(
              header[i].isEmpty ? '#${i + 1}' : header[i],
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

String _fieldLabel(ImportField field, AppLocalizations l10n) => switch (field) {
  ImportField.date => l10n.dateLabel,
  ImportField.amount => l10n.amountLabel,
  ImportField.type => l10n.importFieldType,
  ImportField.category => l10n.categoryLabel,
  ImportField.account => l10n.accountLabel,
  ImportField.toAccount => l10n.importFieldToAccount,
  ImportField.title => l10n.importFieldTitle,
  ImportField.note => l10n.importFieldNote,
};

/// A name in the file, and what it becomes here (IMP-7).
class _NameChoice extends StatelessWidget {
  const _NameChoice({
    required this.name,
    required this.chosen,
    required this.options,
    required this.onChanged,
  });

  final String name;
  final String? chosen;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: options.containsKey(chosen) ? chosen : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: name,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final option in options.entries)
          DropdownMenuItem(
            value: option.key,
            child: Text(option.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

/// One row of the file as the app read it, with why it won't import if it
/// won't (IMP-5).
class _RowLine extends StatelessWidget {
  const _RowLine({
    required this.row,
    required this.rawDate,
    required this.currency,
    required this.skipLine,
  });

  final ImportRow row;
  final String rawDate;
  final NumberFormat currency;
  final String? skipLine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final date = row.date;
    final amount = row.amount;
    final parts = [
      date == null
          ? (rawDate.isEmpty ? '—' : rawDate)
          : DateFormat.yMMMd(l10n.localeName).format(date),
      if (row.title.isNotEmpty) row.title,
      if (row.title.isEmpty && row.categoryName.isNotEmpty) row.categoryName,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parts.join(' · ')),
                if (skipLine != null)
                  Text(
                    skipLine!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.error),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount == null
                ? '—'
                : '${_sign(row.type)}${currency.format(amount.toDouble())}',
            style: TextStyle(
              color: skipLine == null ? null : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static String _sign(ImportedType type) => switch (type) {
    ImportedType.income => '+',
    ImportedType.expense => '−',
    ImportedType.transfer => '',
  };
}
