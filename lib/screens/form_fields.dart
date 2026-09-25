import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../l10n/app_localizations.dart';
import '../models/amount_expression.dart';
import '../models/money.dart';
import 'haptics.dart';

/// Amounts and expressions like `12.5+3` read left to right in every
/// language, but sit on the label's side in right-to-left layouts (LANG-5).
/// Use with `textDirection: TextDirection.ltr` on amount fields.
TextAlign amountTextAlign(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
    ? TextAlign.right
    : TextAlign.left;

/// Amount entry shared by the transaction and transfer forms (ADD-2): the
/// field accepts `+` and `−`, shows the result live, and on phones uses
/// [AmountKeypad] instead of the system keyboard.
mixin AmountEntry<T extends StatefulWidget> on State<T> {
  final amountController = TextEditingController();
  final amountFocus = FocusNode();

  /// Phones get the in-app keypad; desktops type on the keyboard.
  bool get useKeypad =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    amountController.addListener(_refresh);
    amountFocus.addListener(_refresh);
  }

  @override
  void dispose() {
    amountController.dispose();
    amountFocus.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// The evaluated amount, or null when the input isn't valid for [currency].
  Money? parsedAmount(NumberFormat currency) => evaluateAmount(
    amountController.text,
    maxDecimals: currency.maximumFractionDigits,
    decimalMark: currency.symbols.DECIMAL_SEP,
  );

  Widget amountField(
    NumberFormat currency,
    AppLocalizations l10n, {
    bool autofocus = false,
  }) {
    final result = parsedAmount(currency);
    return TextFormField(
      controller: amountController,
      focusNode: amountFocus,
      autofocus: autofocus,
      textDirection: TextDirection.ltr,
      textAlign: amountTextAlign(context),
      keyboardType: useKeypad
          ? TextInputType.none
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,+\-−]')),
      ],
      decoration: InputDecoration(
        labelText: l10n.amountLabel,
        border: const OutlineInputBorder(),
        prefixText: '${currency.currencySymbol} ',
        helperText: isAmountExpression(amountController.text) && result != null
            ? l10n.amountResult(currency.money(result))
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return l10n.amountRequired;
        final amount = parsedAmount(currency);
        if (amount == null || !amount.isPositive) return l10n.amountInvalid;
        return null;
      },
    );
  }

  /// The keypad to dock below the form while the amount has focus.
  Widget? amountKeypad() => useKeypad && amountFocus.hasFocus
      ? AmountKeypad(controller: amountController, onDone: amountFocus.unfocus)
      : null;
}

/// Digits, `+`, `−`, backspace, and a key to hide the keypad (ADD-2).
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.controller,
    required this.onDone,
  });

  final TextEditingController controller;
  final VoidCallback onDone;

  static const _keys = [
    '7', '8', '9', 'back', //
    '4', '5', '6', '-', //
    '1', '2', '3', '+', //
    '.', '0', '00', 'done',
  ];

  void _press(String key) {
    final text = controller.text;
    final next = key == 'back'
        ? (text.isEmpty ? text : text.substring(0, text.length - 1))
        : '$text$key';
    // HAP-1: a key that changes nothing says nothing, so that the tick keeps
    // meaning "that landed".
    if (next == text) return;
    keyFeedback();
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keyStyle = Theme.of(context).textTheme.titleLarge;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(4),
          // Number pads keep 7 8 9 left to right in every language (LANG-5).
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: GridView(
              // A fixed key height keeps the keypad compact on wide screens.
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 52,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final key in _keys)
                  switch (key) {
                    'back' => IconButton(
                      tooltip: l10n.backspaceTooltip,
                      onPressed: () => _press(key),
                      icon: const Icon(Icons.backspace_outlined),
                    ),
                    'done' => IconButton(
                      tooltip: l10n.hideKeypadTooltip,
                      onPressed: () {
                        keyFeedback();
                        onDone();
                      },
                      icon: const Icon(Icons.keyboard_hide_outlined),
                    ),
                    _ => TextButton(
                      onPressed: () => _press(key),
                      child: Text(key == '-' ? '−' : key, style: keyStyle),
                    ),
                  },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A date with arrows for the previous and next day; tapping the date opens
/// a picker (ADD-6). The time of day is kept.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.date,
    required this.onChanged,
    this.label,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  /// Defaults to "Date".
  final String? label;

  DateTime _withDay(int year, int month, int day) =>
      DateTime(year, month, day, date.hour, date.minute, date.second);

  /// The picker's usual range, widened to always bracket [date] itself.
  /// A row from an import or the arrows above (ADD-6, DATE-1) can carry a
  /// date outside 2015–2100 -- CSV import accepts any year -- and
  /// `showDatePicker` asserts `initialDate` falls within `firstDate` and
  /// `lastDate`, which would otherwise crash on open (rules-1-5#12).
  DateTime get _firstDate =>
      date.isBefore(DateTime(2015)) ? DateTime(date.year) : DateTime(2015);
  DateTime get _lastDate => date.isAfter(DateTime(2100))
      ? DateTime(date.year, 12, 31)
      : DateTime(2100);

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: _firstDate,
      lastDate: _lastDate,
    );
    if (picked != null) {
      onChanged(_withDay(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label ?? l10n.dateLabel,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(4),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.previousDayTooltip,
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                onChanged(_withDay(date.year, date.month, date.day - 1)),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => _pick(context),
              child: Text(DateFormat.yMMMEd(l10n.localeName).format(date)),
            ),
          ),
          IconButton(
            tooltip: l10n.nextDayTooltip,
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                onChanged(_withDay(date.year, date.month, date.day + 1)),
          ),
        ],
      ),
    );
  }
}

/// The guarded form currently on screen, if any (there is ever at most one
/// at a time): set while it is mounted, so a shortcut or widget tap that
/// would otherwise silently replace it can ask the same ADD-9 question the
/// back button does, instead of dropping unsaved edits without a word
/// (pr57#3).
UnsavedFormGuard? activeUnsavedFormGuard;

/// What a shortcut or widget tap needs from the form currently on screen,
/// without depending on its State type.
class UnsavedFormGuard {
  UnsavedFormGuard({
    required this.hasUnsavedEdits,
    required this.confirmDiscard,
  });

  /// Whether there's something on the form to lose right now.
  final bool Function() hasUnsavedEdits;

  /// Shows the same "Discard changes?" question the back button does
  /// (ADD-9). Resolves to true once it's fine to replace the form, false to
  /// keep it as it is.
  final Future<bool> Function() confirmDiscard;
}

/// Back on a form: the keypad first, then a question before edits are
/// dropped (ADD-9). A form carries a snapshot of how it opened, so a form
/// nothing was typed into leaves without a word.
mixin UnsavedGuard<T extends StatefulWidget> on AmountEntry<T> {
  String? _opened;

  late final UnsavedFormGuard _formGuard = UnsavedFormGuard(
    hasUnsavedEdits: () => hasUnsavedEdits,
    confirmDiscard: _confirmDiscard,
  );

  @override
  void initState() {
    super.initState();
    activeUnsavedFormGuard = _formGuard;
  }

  @override
  void dispose() {
    if (identical(activeUnsavedFormGuard, _formGuard)) {
      activeUnsavedFormGuard = null;
    }
    super.dispose();
  }

  /// Every value the user can change, in one string. Each form writes its
  /// own; two snapshots that differ mean there is something to lose.
  String formSnapshot();

  /// Takes the snapshot the next Back compares against: once the form is
  /// built, and again whenever it is deliberately emptied (ADD-4).
  void snapshotForm() => _opened = formSnapshot();

  bool get hasUnsavedEdits => _opened != null && formSnapshot() != _opened;

  /// Wraps the form so system Back and the toolbar's arrow both go through
  /// [handleBack]. Saving and deleting pop directly, so they are untouched.
  Widget guardBack({required Widget child}) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) handleBack();
    },
    child: child,
  );

  Future<bool> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepEditingButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.discardButton),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> handleBack() async {
    // The keypad or the keyboard goes first, and the form stays (ADD-9).
    final typing =
        amountFocus.hasFocus || MediaQuery.viewInsetsOf(context).bottom > 0;
    if (typing) {
      FocusScope.of(context).unfocus();
      return;
    }
    final navigator = Navigator.of(context);
    if (!hasUnsavedEdits) {
      navigator.pop();
      return;
    }
    final discard = await _confirmDiscard();
    if (discard && mounted) navigator.pop();
  }
}
