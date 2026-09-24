import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/note.dart';
import '../models/transaction_filter.dart' show foldForSearch;
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import 'delete_snack_bar.dart';
import 'haptics.dart';
import 'note_form_screen.dart';

enum _StatusFilter { open, done }

enum _DueFilter { overdue, dueToday, upcoming, noDate }

DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Notes: open first (overdue, then by due date, then dateless by last
/// edit), Done below, searchable and filterable (NOTE-2, NOTE-3).
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _query = '';
  _StatusFilter? _status;
  _DueFilter? _due;

  bool _matchesDue(Note note, DateTime today) {
    final filter = _due;
    if (filter == null) return true;
    final date = note.dueDate == null ? null : _dayOnly(note.dueDate!);
    return switch (filter) {
      _DueFilter.noDate => date == null,
      _DueFilter.overdue => date != null && date.isBefore(today),
      _DueFilter.dueToday => date == today,
      _DueFilter.upcoming => date != null && date.isAfter(today),
    };
  }

  /// Notes from [source] matching the search and due-date filters; every
  /// count on screen comes from this (NOTE-3).
  List<Note> _filtered(List<Note> source, DateTime today) {
    final query = foldForSearch(_query.trim());
    return [
      for (final note in source)
        if (_matchesDue(note, today) &&
            (query.isEmpty || foldForSearch(note.text).contains(query)))
          note,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final currency = settings.currencyFormat(l10n.localeName);
    final today = provider.today;

    final status = _status;
    final open = status == _StatusFilter.done
        ? const <Note>[]
        : _filtered(provider.openNotes, today);
    final done = status == _StatusFilter.open
        ? const <Note>[]
        : _filtered(provider.doneNotes, today);
    final hasAnyNotes = provider.notes.isNotEmpty;
    final hasResults = open.isNotEmpty || done.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesTitle)),
      body: !hasAnyNotes
          ? _EmptyNotes(l10n: l10n)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.notesSearchHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      for (final (label, value) in <(String, _StatusFilter?)>[
                        (l10n.noteFilterAll, null),
                        (l10n.notesOpenHeader, _StatusFilter.open),
                        (l10n.notesDoneHeader, _StatusFilter.done),
                      ])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _status == value,
                            onSelected: (_) => setState(
                              () => _status = _status == value ? null : value,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 4),
                        child: VerticalDivider(
                          width: 1,
                          indent: 4,
                          endIndent: 4,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      for (final (label, value) in <(String, _DueFilter?)>[
                        (l10n.noteFilterOverdue, _DueFilter.overdue),
                        (l10n.noteFilterDueToday, _DueFilter.dueToday),
                        (l10n.noteFilterUpcoming, _DueFilter.upcoming),
                        (l10n.noteFilterNoDate, _DueFilter.noDate),
                      ])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _due == value,
                            onSelected: (_) => setState(
                              () => _due = _due == value ? null : value,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: !hasResults
                      ? Center(child: Text(l10n.noNoteResults))
                      : ListView(
                          children: [
                            if (open.isNotEmpty) ...[
                              _Header(
                                '${l10n.notesOpenHeader} (${open.length})',
                              ),
                              for (final note in open)
                                _NoteTile(note: note, currency: currency),
                            ],
                            if (done.isNotEmpty) ...[
                              _Header(
                                '${l10n.notesDoneHeader} (${done.length})',
                              ),
                              for (final note in done)
                                _NoteTile(note: note, currency: currency),
                            ],
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addNoteTooltip,
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const NoteFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}

/// The empty state before any note exists, with one clear action (NOTE-2).
class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.notesEmptyTitle,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.notesEmptyMessage, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const NoteFormScreen())),
              icon: const Icon(Icons.add),
              label: Text(l10n.addNoteButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.currency});

  final Note note;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final today = provider.today;
    final category = note.categoryId == null
        ? null
        : provider.categoryById(note.categoryId!);
    final due = note.dueDate;
    final overdue =
        due != null && !note.isDone && _dayOnly(due).isBefore(_dayOnly(today));

    final parts = [
      if (due != null)
        overdue
            ? l10n.noteFilterOverdue
            : DateFormat.yMMMEd(l10n.localeName).format(due),
      if (category != null) category.label(l10n),
      if (note.amount != null) currency.format(note.amount!.toDouble()),
    ];

    return Dismissible(
      key: ValueKey('note-${note.id}'),
      direction: DismissDirection.endToStart,
      // HAP-3: as on the day list's rows.
      onUpdate: swipeUpdate,
      background: Container(
        color: Colors.red,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        final locale = Localizations.localeOf(context);
        try {
          await provider.deleteNote(note.id);
        } catch (_) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.noteDeleteFailed)),
          );
          return false;
        }
        showUndoSnackBar(
          messenger,
          message: l10n.noteDeleted,
          undoLabel: l10n.undoButton,
          failedMessage: l10n.noteRestoreFailed,
          onUndo: () => provider.restoreNote(
            note.id,
            appLockOn: settings.appLock,
            locale: locale,
          ),
        );
        return true;
      },
      child: ListTile(
        leading: Checkbox(
          value: note.isDone,
          onChanged: (value) async {
            final messenger = ScaffoldMessenger.of(context);
            final locale = Localizations.localeOf(context);
            try {
              await provider.setNoteDone(
                note.id,
                value ?? false,
                appLockOn: settings.appLock,
                locale: locale,
              );
            } catch (_) {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.noteSaveFailed)),
              );
            }
          },
        ),
        title: Text(
          note.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: note.isDone
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: parts.isEmpty
            ? null
            : Text(
                parts.join(' · '),
                style: overdue
                    ? TextStyle(color: Theme.of(context).colorScheme.error)
                    : null,
              ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NoteFormScreen(editing: note)),
        ),
      ),
    );
  }
}
