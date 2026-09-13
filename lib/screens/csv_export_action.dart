import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/csv_export.dart';
import '../models/transaction.dart';
import '../models/transfer.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/backup_service.dart';

/// Builds a CSV of the current view with the user's category and account
/// names, lets the user save it as `monthly-expenses-[name].csv`, and
/// reports the outcome (BAK-5, BAK-6).
Future<void> exportCsv(
  BuildContext context, {
  required String name,
  required List<ExpenseTransaction> transactions,
  List<Transfer> transfers = const [],
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final provider = context.read<TransactionProvider>();
  final csv = buildCsv(
    transactions: transactions,
    transfers: transfers,
    currencyCode: context.read<SettingsProvider>().currencyCode,
    categoryName: (id) => provider.categoryById(id)?.label(l10n) ?? '',
    accountName: (id) => provider.accountById(id)?.label(l10n) ?? '',
  );
  try {
    final saved = await context.read<BackupService>().saveCsv(
      'monthly-expenses-$name.csv',
      csv,
    );
    if (saved) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.csvExported)));
    }
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.csvExportFailed)));
  }
}
