import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/backup.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/backup_service.dart';
import 'import_screen.dart';

/// Four pages on what the app does, after setup and before Home: quick
/// entry, planning, insights, and privacy. Every page can skip to the end,
/// and Settings can play it again (RUN-4, RUN-5).
class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key, this.replay = false});

  /// Opened from Settings rather than on a first launch: it closes instead of
  /// opening Home.
  final bool replay;

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Restores a backup over the empty app and opens Home. The backup carries
  /// the language and currency it was saved with, so the user is told before
  /// it replaces what setup just chose (RUN-4, BAK-2).
  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final service = context.read<BackupService>();
    final settings = context.read<SettingsProvider>();
    final transactions = context.read<TransactionProvider>();
    BackupData? backup;
    // Only the work shows progress; the question in between is the user's
    // own time.
    setState(() => _busy = true);
    try {
      backup = await service.openBackup();
    } on BackupException catch (e) {
      _show(switch (e.problem) {
        BackupProblem.invalid => l10n.backupInvalid,
        BackupProblem.tooNew => l10n.backupTooNew,
      });
      return;
    } catch (_) {
      _show(l10n.backupOpenFailed);
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (backup == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.firstRunRestoreTitle),
        content: Text(l10n.firstRunRestoreMessage),
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
    if (!(confirmed ?? false) || !mounted) return;

    setState(() => _busy = true);
    try {
      try {
        await service.restore(backup, RestoreMode.replace, settings);
      } catch (_) {
        _show(l10n.backupRestoreFailed);
        return;
      }
      await transactions.load();
      transactions.setStartDay(settings.startDay);
      await settings.completeWalkthrough();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Imports a CSV from another app, then stays here: unlike a backup it
  /// brings no settings and nothing to jump over (IMP-1).
  Future<void> _importCsv() =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ImportScreen()));

  /// Each page's icon, title, and text.
  List<(IconData, String, String)> _pages(AppLocalizations l10n) => [
    (
      Icons.bolt_outlined,
      l10n.walkthroughEntryTitle,
      l10n.walkthroughEntryBody,
    ),
    (
      Icons.event_repeat_outlined,
      l10n.walkthroughPlanTitle,
      l10n.walkthroughPlanBody,
    ),
    (
      Icons.insights_outlined,
      l10n.walkthroughInsightsTitle,
      l10n.walkthroughInsightsBody,
    ),
    (
      Icons.lock_outline,
      l10n.walkthroughPrivacyTitle,
      l10n.walkthroughPrivacyBody,
    ),
  ];

  /// Ends the walkthrough, read or skipped: it has had its turn (RUN-5).
  Future<void> _finish() async {
    if (widget.replay) {
      Navigator.of(context).pop();
      return;
    }
    await context.read<SettingsProvider>().completeWalkthrough();
  }

  Future<void> _next(int pageCount) async {
    if (_page >= pageCount - 1) return _finish();
    // A device asking for less movement gets none (RUN-4).
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(_page + 1);
    } else {
      await _controller.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pages = _pages(l10n);
    // The way in from another app or phone closes the first launch, but has
    // no place in a replay: Backup & restore is a tap away by then (RUN-4).
    final count = pages.length + (widget.replay ? 0 : 1);
    final last = _page == count - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_busy) const LinearProgressIndicator(),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    widget.replay
                        ? l10n.walkthroughDoneButton
                        : l10n.skipButton,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: count,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) {
                  if (index == pages.length) {
                    return _BringPage(
                      busy: _busy,
                      onRestore: _restore,
                      onImport: _importCsv,
                    );
                  }
                  final (icon, title, body) = pages[index];
                  return _Page(icon: icon, title: title, body: body);
                },
              ),
            ),
            Semantics(
              container: true,
              label: l10n.walkthroughProgress(_page + 1, count),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var page = 0; page < count; page++)
                    Container(
                      width: page == _page ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: page == _page
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : () => _next(count),
                  child: Text(
                    !last
                        ? l10n.walkthroughNextButton
                        : widget.replay
                        ? l10n.walkthroughDoneButton
                        : l10n.walkthroughStartButton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The last page of a first launch: the two ways in for someone who already
/// has their records somewhere else (RUN-4, BAK-2, IMP-1).
class _BringPage extends StatelessWidget {
  const _BringPage({
    required this.busy,
    required this.onRestore,
    required this.onImport,
  });

  final bool busy;
  final VoidCallback onRestore;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.move_to_inbox_outlined,
              size: 88,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.walkthroughBringTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.walkthroughBringBody,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore),
              title: Text(l10n.setupRestoreTitle),
              subtitle: Text(l10n.setupRestoreSubtitle),
              enabled: !busy,
              onTap: onRestore,
            ),
            ListTile(
              leading: const Icon(Icons.table_view_outlined),
              title: Text(l10n.importTitle),
              subtitle: Text(l10n.importSubtitle),
              enabled: !busy,
              onTap: onImport,
            ),
          ],
        ),
      ),
    );
  }
}

/// One walkthrough page, its content in the middle of the page. It scrolls
/// instead when large text needs the room (LANG-6).
class _Page extends StatelessWidget {
  const _Page({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 88, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
