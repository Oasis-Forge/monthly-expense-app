import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/money.dart';
import '../models/widget_summary.dart';

/// Everything the home-screen widget draws, ready formatted.
///
/// The widget is native code with no access to the database, the app's
/// language, or its currency: it only paints the strings it is handed
/// (WID-5, WID-6). Building the payload here keeps one set of rules for
/// what a number means and how it reads.
///
/// The version lets a widget left over from an older install recognise a
/// payload it can't read, rather than drawing nonsense.
const homeWidgetPayloadVersion = 1;

/// The payload for [timeline], as plain JSON values.
///
/// The period's name needs [initializeDateFormatting] for the locale, which
/// [HomeWidgetUpdater] does before calling this; a screen would have it from
/// the Material delegate, but nothing here runs on a screen.
///
/// With [hideAmounts] the entries are left out altogether, not merely marked
/// hidden: under app lock the amounts should not leave the app at all
/// (WID-4, WID-5).
Map<String, Object?> buildHomeWidgetPayload({
  required List<WidgetSummary> timeline,
  required AppLocalizations l10n,
  required NumberFormat currency,
  required bool hideAmounts,
}) {
  return {
    'version': homeWidgetPayloadVersion,
    'hideAmounts': hideAmounts,
    'rtl': Bidi.isRtlLanguage(l10n.localeName),
    'title': l10n.appTitle,
    'labels': {
      'income': l10n.incomeLabel,
      'expense': l10n.expenseLabel,
      'balance': timeline.isNotEmpty && timeline.first.balanceIsNet
          ? l10n.periodNetLabel
          : l10n.balanceLabel,
      'budgetLeft': l10n.widgetLeftLabel,
      'addExpense': l10n.widgetAddExpense,
      'addIncome': l10n.widgetAddIncome,
      'hidden': l10n.widgetAmountsHidden,
    },
    'entries': [
      if (!hideAmounts)
        for (final entry in timeline)
          {
            'from': entry.from.millisecondsSinceEpoch,
            'period': periodLabel(entry.period, l10n),
            'income': currency.money(entry.income),
            'expense': currency.money(entry.expense),
            'balance': currency.money(entry.balance),
            if (entry.budgetLeft case final left?) ...{
              'budgetLeft': currency.money(left),
              'overBudget': entry.isOverBudget,
            },
          },
    ],
  };
}
