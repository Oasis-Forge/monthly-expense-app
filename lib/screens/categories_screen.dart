import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

/// Add, rename, change the icon of, reorder, archive, and delete categories
/// (CAT-3, CAT-4).
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

enum _CategoryAction { archive, delete }

class _CategoriesScreenState extends State<CategoriesScreen> {
  TransactionType _type = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TransactionProvider>();
    final active = provider.categoriesFor(_type);
    final archived = provider.archivedCategoriesFor(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(l10n.expenseLabel),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(l10n.incomeLabel),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addCategoryTooltip,
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: ReorderableListView(
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.only(bottom: 88),
        onReorderItem: (oldIndex, newIndex) =>
            _run(() => provider.reorderCategories(_type, oldIndex, newIndex)),
        footer: archived.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      l10n.archivedHeader,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  for (final category in archived)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: categoryTint(category),
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(category.label(l10n)),
                      trailing: TextButton(
                        onPressed: () =>
                            _run(() => provider.unarchiveCategory(category.id)),
                        child: Text(l10n.unarchiveAction),
                      ),
                    ),
                ],
              ),
        children: [
          for (var i = 0; i < active.length; i++)
            ListTile(
              key: ValueKey(active[i].id),
              leading: CircleAvatar(
                backgroundColor: categoryTint(active[i]),
                child: Text(
                  active[i].icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              title: Text(active[i].label(l10n)),
              onTap: () => _edit(active[i]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Keep at least one active category per type.
                  if (active.length > 1)
                    PopupMenuButton<_CategoryAction>(
                      onSelected: (action) => _run(
                        () => action == _CategoryAction.archive
                            ? provider.archiveCategory(active[i].id)
                            : provider.deleteCategory(active[i].id),
                      ),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _CategoryAction.archive,
                          child: Text(l10n.archiveAction),
                        ),
                        if (!provider.isCategoryUsed(active[i].id))
                          PopupMenuItem(
                            value: _CategoryAction.delete,
                            child: Text(l10n.deleteAction),
                          ),
                      ],
                    ),
                  ReorderableDragStartListener(
                    index: i,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Runs a category change and reports a failure in a snack bar.
  Future<void> _run(Future<void> Function() change) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await change();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.categorySaveFailed)));
    }
  }

  Future<void> _add() async {
    final provider = context.read<TransactionProvider>();
    final type = _type;
    final taken = _namesInUse(provider, type);
    final result = await showDialog<(String, String, int)>(
      context: context,
      builder: (_) => CategoryDialog(
        takenNames: taken,
        initialColor: nextCategoryColor([
          ...provider.categoriesFor(TransactionType.expense),
          ...provider.categoriesFor(TransactionType.income),
        ]),
      ),
    );
    if (result == null || !mounted) return;
    final (name, icon, color) = result;
    await _run(
      () => provider.addCategory(
        type: type,
        name: name,
        icon: icon,
        color: color,
      ),
    );
  }

  Future<void> _edit(Category category) async {
    final provider = context.read<TransactionProvider>();
    final currentName = category.label(AppLocalizations.of(context));
    final taken = _namesInUse(provider, category.type, except: category.id);
    final result = await showDialog<(String, String, int)>(
      context: context,
      builder: (_) => CategoryDialog(
        category: category,
        initialName: currentName,
        takenNames: taken,
      ),
    );
    if (result == null || !mounted) return;
    final (name, icon, color) = result;
    await _run(
      () => provider.updateCategory(
        // An unchanged default name stays translated (CAT-1).
        category.copyWith(
          name: name == currentName ? category.name : name,
          icon: icon,
          color: color,
        ),
      ),
    );
  }

  /// Lowercase names of the other categories of [type].
  Set<String> _namesInUse(
    TransactionProvider provider,
    TransactionType type, {
    String? except,
  }) {
    final l10n = AppLocalizations.of(context);
    return {
      for (final category in [
        ...provider.categoriesFor(type),
        ...provider.archivedCategoriesFor(type),
      ])
        if (category.id != except) category.label(l10n).toLowerCase(),
    };
  }
}

/// Name, icon and colour for a new or edited category; pops
/// `(name, icon, color)`.
class CategoryDialog extends StatefulWidget {
  const CategoryDialog({
    super.key,
    this.category,
    this.initialName = '',
    this.initialColor,
    required this.takenNames,
  });

  final Category? category;
  final String initialName;

  /// The colour a new category opens on, ignored when editing an existing
  /// one (CAT-6).
  final int? initialColor;

  /// Lowercase names already used by other categories of the same type.
  final Set<String> takenNames;

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  static const _icons = [
    '🍔', '🛒', '☕', '🍽️', '🚗', '⛽', '🚌', '✈️', '🛍️', '👕', //
    '💡', '📱', '🏠', '🔧', '💊', '🏥', '📚', '🎓', '🎬', '🎮', //
    '🎵', '⚽', '🐶', '👶', '💇', '🎁', '❤️', '🌱', '💼', '🏢', //
    '📈', '💰', '💵', '💳', '🏦', '🧾', '📦',
  ];

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  late String _icon = widget.category?.icon ?? _icons.first;
  late int _color =
      widget.category?.color ?? widget.initialColor ?? categoryPalette.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((_name.text.trim(), _icon, _color));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final icons = [if (!_icons.contains(_icon)) _icon, ..._icons];

    return AlertDialog(
      title: Text(
        widget.category == null
            ? l10n.addCategoryTitle
            : l10n.editCategoryTitle,
      ),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.categoryNameLabel,
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) return l10n.categoryNameRequired;
                    if (widget.takenNames.contains(name.toLowerCase())) {
                      return l10n.categoryNameTaken;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final icon in icons)
                      ChoiceChip(
                        label: Text(icon, style: const TextStyle(fontSize: 20)),
                        selected: icon == _icon,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _icon = icon),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // The sixteen the app offers, and only those, so every
                // category stays legible against white (CAT-6).
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final color in categoryPalette)
                      InkWell(
                        onTap: () => setState(() => _color = color),
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(color),
                          child: color == _color
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.saveButton)),
      ],
    );
  }
}
