import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/backup.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/backup_service.dart';
import 'import_screen.dart';

/// Saves backup files, restores them by merging or replacing, lists the
/// automatic backups kept before each restore, and holds the backup
/// reminder setting (BAK-1–BAK-4, BAK-6, BAK-7).
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  late Future<List<KeptBackup>> _kept;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _kept = context.read<BackupService>().keptBackups();
  }

  void _refreshKept() {
    setState(() {
      _kept = context.read<BackupService>().keptBackups();
    });
  }

  /// Shows a progress bar while [work] runs. Dialogs stay outside it.
  Future<T> _whileBusy<T>(Future<T> Function() work) async {
    setState(() => _busy = true);
    try {
      return await work();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String message) {
    // The newest message replaces any still showing.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _backUp() async {
    final l10n = AppLocalizations.of(context);
    final service = context.read<BackupService>();
    final settings = context.read<SettingsProvider>();
    try {
      final saved = await _whileBusy(() => service.saveBackup(settings));
      if (saved && mounted) _show(l10n.backupSaved);
    } catch (_) {
      if (mounted) _show(l10n.backupSaveFailed);
    }
  }

  Future<void> _restoreFromFile() async {
    final l10n = AppLocalizations.of(context);
    final service = context.read<BackupService>();
    final BackupData? backup;
    try {
      backup = await _whileBusy(service.openBackup);
    } on BackupException catch (e) {
      if (mounted) {
        _show(switch (e.problem) {
          BackupProblem.invalid => l10n.backupInvalid,
          BackupProblem.tooNew => l10n.backupTooNew,
        });
      }
      return;
    } catch (_) {
      if (mounted) _show(l10n.backupOpenFailed);
      return;
    }
    if (backup == null || !mounted) return;
    final mode = await showDialog<RestoreMode>(
      context: context,
      builder: (_) => _RestoreDialog(backup: backup!),
    );
    if (mode != null) await _restore(backup, mode);
  }

  Future<void> _restoreKept(KeptBackup kept) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreKeptTitle),
        content: Text(
          l10n.restoreKeptMessage(_backupDate(context, kept.backup)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.restoreButton),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await _restore(kept.backup, RestoreMode.replace);
  }

  Future<void> _restore(BackupData backup, RestoreMode mode) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final service = context.read<BackupService>();
    final settings = context.read<SettingsProvider>();
    final transactions = context.read<TransactionProvider>();
    final RestoreResult result;
    try {
      result = await _whileBusy(() => service.restore(backup, mode, settings));
    } catch (_) {
      if (mounted) {
        _show(l10n.backupRestoreFailed);
        _refreshKept();
      }
      return;
    }
    await transactions.load();
    transactions.setStartDay(settings.startDay);
    if (!mounted) return;
    _show(switch (result.mode) {
      RestoreMode.replace => l10n.restoredReplace(result.transactionCount),
      RestoreMode.merge => l10n.restoredMerge(
        result.added,
        result.updated,
        result.unchanged,
      ),
    });
    _refreshKept();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final lastBackup = settings.lastBackupAt;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupTitle),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l10n.backupIntro),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.backUpNowTitle),
            subtitle: Text(
              lastBackup == null
                  ? l10n.neverBackedUp
                  : l10n.lastBackupLine(
                      DateFormat.yMMMd(l10n.localeName)
                          .add_jm()
                          .format(lastBackup.toLocal()),
                    ),
            ),
            enabled: !_busy,
            onTap: _backUp,
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: Text(l10n.restoreFromFileTitle),
            subtitle: Text(l10n.restoreFromFileSubtitle),
            enabled: !_busy,
            onTap: _restoreFromFile,
          ),
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: Text(l10n.importTitle),
            subtitle: Text(l10n.importSubtitle),
            enabled: !_busy,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ImportScreen())),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.backupReminderLabel),
            subtitle: Text(l10n.backupReminderSubtitle),
            value: settings.backupReminder,
            onChanged: settings.setBackupReminder,
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.keptBackupsHeader,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(l10n.keptBackupsHint),
          ),
          FutureBuilder<List<KeptBackup>>(
            future: _kept,
            builder: (context, snapshot) {
              final kept = snapshot.data;
              if (kept == null || kept.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    snapshot.connectionState == ConnectionState.done
                        ? l10n.noKeptBackups
                        : '',
                  ),
                );
              }
              return Column(
                children: [
                  for (final backup in kept)
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(
                        l10n.backupSummary(
                          _backupDate(context, backup.backup),
                          backup.backup.transactionCount,
                        ),
                      ),
                      enabled: !_busy,
                      onTap: () => _restoreKept(backup),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

String _backupDate(BuildContext context, BackupData backup) =>
    DateFormat.yMMMd(AppLocalizations.of(context).localeName)
        .add_jm()
        .format(backup.createdAt.toLocal());

/// Asks how to restore [backup] and pops the chosen [RestoreMode]. Merge is
/// selected first because it keeps the current data.
class _RestoreDialog extends StatefulWidget {
  const _RestoreDialog({required this.backup});

  final BackupData backup;

  @override
  State<_RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<_RestoreDialog> {
  RestoreMode _mode = RestoreMode.merge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.restoreTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.backupSummary(
                _backupDate(context, widget.backup),
                widget.backup.transactionCount,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<RestoreMode>(
              segments: [
                ButtonSegment(
                  value: RestoreMode.merge,
                  label: Text(l10n.mergeOption),
                ),
                ButtonSegment(
                  value: RestoreMode.replace,
                  label: Text(l10n.replaceOption),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) =>
                  setState(() => _mode = selection.first),
            ),
            const SizedBox(height: 12),
            Text(
              _mode == RestoreMode.merge
                  ? l10n.mergeOptionSubtitle
                  : l10n.replaceOptionSubtitle,
            ),
            const SizedBox(height: 12),
            Text(l10n.restoreSafetyNote, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_mode),
          child: Text(l10n.restoreButton),
        ),
      ],
    );
  }
}
