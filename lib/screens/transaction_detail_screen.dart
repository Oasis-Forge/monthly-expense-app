import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/attachment_service.dart';
import 'add_transaction_screen.dart';
import 'delete_snack_bar.dart';
import 'note_form_screen.dart';

/// One transaction, read rather than edited (DET-1): the amount, what it was
/// for, and everything kept with it. Editing is a button away (DET-3), so a
/// tap on a list row can't change anything by accident.
///
/// It holds the [id] and not the transaction, so an edit, an undo, or a
/// change made anywhere else shows here at once (DET-6).
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.id});

  final String id;

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  /// Soft-deletes with Undo (DEL-2). The screen closes itself once the
  /// transaction is gone, so there is no pop to make here.
  Future<void> _delete(BuildContext context, ExpenseTransaction tx) async {
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await provider.deleteTransaction(tx.id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
      return;
    }
    showDeletedSnackBar(messenger, provider, l10n, tx.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final tx = provider.transactionById(id);

    // Deleted here, in the form, or from another screen: there is nothing
    // left to show, so the screen steps aside (DET-6).
    if (tx == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final currency = settings.currencyFormat(l10n.localeName);
    final category = provider.categoryById(tx.categoryId);
    final account = provider.accountById(tx.accountId);
    final income = tx.type == TransactionType.income;
    final color = income ? Colors.green.shade700 : Colors.red.shade700;
    final sign = income ? '+' : '-';
    final linkedNote = provider.noteForTransaction(tx.id);
    final dates = DateFormat.yMMMMEEEEd(l10n.localeName);
    final stamps = DateFormat.yMMMd(l10n.localeName);
    // Saving sets both, moments apart, so only a change on a later day is
    // worth a line of its own (DET-5).
    final added = stamps.format(tx.createdAt.toLocal());
    final changed = stamps.format(tx.updatedAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editTooltip,
            onPressed: () => _open(context, AddTransactionScreen(editing: tx)),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: l10n.duplicateTooltip,
            onPressed: () => _open(context, AddTransactionScreen(template: tx)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.deleteTooltip,
            onPressed: () => _delete(context, tx),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(
            label: tx.label(category, l10n),
            icon: category?.icon ?? '📦',
            amount: '$sign${currency.format(tx.amount.toDouble())}',
            type: income ? l10n.incomeLabel : l10n.expenseLabel,
            upcoming: provider.isUpcoming(tx),
            color: color,
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                _Row(
                  icon: Icons.category_outlined,
                  label: l10n.categoryLabel,
                  value: category?.label(l10n) ?? '',
                ),
                _Row(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.accountLabel,
                  value: account?.label(l10n) ?? '',
                ),
                _Row(
                  icon: Icons.event_outlined,
                  label: l10n.dateLabel,
                  value: dates.format(tx.date),
                ),
                if (tx.note case final note? when note.isNotEmpty)
                  _Row(
                    icon: Icons.notes_outlined,
                    label: l10n.noteLabel,
                    value: note,
                  ),
              ],
            ),
          ),
          if (tx.photoFile != null || tx.voiceFile != null) ...[
            const SizedBox(height: 16),
            _Attachments(photo: tx.photoFile, voice: tx.voiceFile),
          ],
          // The note this was recorded from, as the form shows it (NOTE-4).
          if (linkedNote != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.sticky_note_2_outlined),
                title: Text(l10n.noteLinkedNoteLabel),
                subtitle: Text(linkedNote.text),
                onTap: () =>
                    _open(context, NoteFormScreen(editing: linkedNote)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _Stamp(text: l10n.detailAdded(added)),
          if (changed != added) _Stamp(text: l10n.detailChanged(changed)),
        ],
      ),
    );
  }
}

/// The amount, in the colour of its kind, over what it was for (DET-2).
class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.icon,
    required this.amount,
    required this.type,
    required this.upcoming,
    required this.color,
  });

  final String label;
  final String icon;
  final String amount;
  final String type;
  final bool upcoming;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(icon, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 16),
        Text(
          amount,
          // The sign stays in front of the amount in Arabic (LANG-5).
          textDirection: TextDirection.ltr,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(type, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        // Dated ahead, so it isn't in this period's totals yet (DATE-3).
        if (upcoming) ...[
          const SizedBox(height: 8),
          Chip(
            label: Text(l10n.upcomingLabel),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }
}

/// One labelled line of the record. Long values wrap rather than being cut.
class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.labelMedium),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );
  }
}

/// The photo and the voice note, to look at and listen to but not to change
/// (DET-4): editing them is the form's job (ATT-1, ATT-4).
class _Attachments extends StatefulWidget {
  const _Attachments({this.photo, this.voice});

  final String? photo;
  final String? voice;

  @override
  State<_Attachments> createState() => _AttachmentsState();
}

class _AttachmentsState extends State<_Attachments> {
  bool _playing = false;

  AttachmentService get _attachments => context.read<AttachmentService>();

  @override
  void initState() {
    super.initState();
    _attachments.playing.listen((playing) {
      if (mounted) setState(() => _playing = playing);
    });
  }

  void _openPhoto(String path) => showDialog<void>(
    context: context,
    builder: (_) =>
        Dialog(child: InteractiveViewer(child: Image.file(File(path)))),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final photo = widget.photo;
    final voice = widget.voice;
    return Card(
      child: Column(
        children: [
          if (photo != null)
            FutureBuilder<String>(
              future: _attachments.path(photo),
              builder: (context, snapshot) {
                final path = snapshot.data;
                if (path == null) return const SizedBox(height: 96);
                return ListTile(
                  leading: Semantics(
                    label: l10n.photoLabel,
                    image: true,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(path),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        // The file can be gone after a restore (ATT-7).
                        errorBuilder: (context, _, _) =>
                            Text(l10n.photoMissing),
                      ),
                    ),
                  ),
                  title: Text(l10n.photoLabel),
                  onTap: () => _openPhoto(path),
                );
              },
            ),
          if (voice != null)
            FutureBuilder<bool>(
              future: _attachments.exists(voice),
              builder: (context, snapshot) {
                final missing = snapshot.data == false;
                return ListTile(
                  leading: IconButton(
                    tooltip: _playing ? l10n.voicePause : l10n.voicePlay,
                    onPressed: missing
                        ? null
                        : () => _playing
                              ? _attachments.pausePlaying()
                              : _attachments.play(voice),
                    icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                  ),
                  title: Text(
                    missing ? l10n.voiceMissing : l10n.voiceNoteLabel,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// When it was recorded, and when it was last changed (DET-5).
class _Stamp extends StatelessWidget {
  const _Stamp({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}
