import 'package:flutter/material.dart' show Color, IconData, Icons;
import 'package:intl/intl.dart' show DateFormat;

import '../models/account.dart';
import '../models/category.dart';
import '../models/period.dart';
import '../models/recurring_rule.dart';
import '../models/transaction.dart';
import 'app_localizations.dart';

extension CategoryLabel on Category {
  /// The user's name for the category, or the translated default (CAT-1).
  String label(AppLocalizations l10n) =>
      name ??
      switch (defaultKey) {
        'food' => l10n.categoryFood,
        'groceries' => l10n.categoryGroceries,
        'transport' => l10n.categoryTransport,
        'shopping' => l10n.categoryShopping,
        'bills' => l10n.categoryBills,
        'rent' => l10n.categoryRent,
        'health' => l10n.categoryHealth,
        'education' => l10n.categoryEducation,
        'entertainment' => l10n.categoryEntertainment,
        'salary' => l10n.categorySalary,
        'business' => l10n.categoryBusiness,
        'investment' => l10n.categoryInvestment,
        'gift' => l10n.categoryGift,
        _ => l10n.categoryOther,
      };
}

extension CategoryColor on Category {
  /// The category's own colour (CAT-6). It belongs to the category, not to
  /// its place in a list, so a category keeps it however the month turns out.
  ///
  /// A category made before colours existed, or restored from an older
  /// backup, falls back to a palette entry picked by its position in the
  /// list — stable for that category, and never nothing.
  Color get swatch =>
      Color(color ?? categoryPalette[sortOrder.abs() % categoryPalette.length]);
}

/// The colour to draw for a category that is no longer there. A transaction
/// keeps its category id after the category is deleted (CAT-4), so this is
/// the counterpart of the '📦' the screens already fall back to.
const deletedCategorySwatch = Color(0xFF90A4AE);

/// [Category.swatch], or [deletedCategorySwatch] when the category is gone.
Color categorySwatch(Category? category) =>
    category?.swatch ?? deletedCategorySwatch;

/// The name of a colour in [categoryPalette], read out by a screen reader
/// where a swatch, dot, or pie slice carries meaning by colour alone and no
/// text of its own (A11Y-2, rules-23-26-34#10). Null for anything not one of
/// the sixteen -- a category made before colours existed, or an older
/// migration's own frozen value (pr58#9) -- rather than guess a name for it.
String? categoryColorName(AppLocalizations l10n, int color) => switch (color) {
  0xFF6C5CE7 => l10n.categoryColorPurple,
  0xFF00897B => l10n.categoryColorTeal,
  0xFFD84315 => l10n.categoryColorRust,
  0xFF1E88E5 => l10n.categoryColorBlue,
  0xFFC2185B => l10n.categoryColorPink,
  0xFF2E7D32 => l10n.categoryColorGreen,
  0xFFA028BF => l10n.categoryColorMagenta,
  0xFF00838F => l10n.categoryColorCyan,
  0xFF835A4E => l10n.categoryColorBrown,
  0xFF4A5BC3 => l10n.categoryColorIndigo,
  0xFFE53935 => l10n.categoryColorRed,
  0xFF546E7A => l10n.categoryColorSlate,
  0xFFE65100 => l10n.categoryColorOrange,
  0xFF007365 => l10n.categoryColorEmerald,
  0xFF6C4BD3 => l10n.categoryColorViolet,
  0xFFBF1660 => l10n.categoryColorRaspberry,
  _ => null,
};

/// The circle behind a category's icon in a list (CAT-6). The colour is the
/// category's own, kept faint: a row is read for its title and its amount,
/// and sixteen solid discs down the screen would drown both.
Color categoryTint(Category? category) =>
    categorySwatch(category).withValues(alpha: 0.18);

extension AccountLabel on Account {
  /// The user's name for the account, or the translated default (ACC-2).
  String label(AppLocalizations l10n) =>
      name ?? (defaultKey == 'cash' ? l10n.accountCash : '');
}

String accountTypeLabel(AccountType type, AppLocalizations l10n) =>
    switch (type) {
      AccountType.cash => l10n.accountTypeCash,
      AccountType.bank => l10n.accountTypeBank,
      AccountType.card => l10n.accountTypeCard,
      AccountType.other => l10n.accountTypeOther,
    };

IconData accountTypeIcon(AccountType type) => switch (type) {
  AccountType.cash => Icons.payments_outlined,
  AccountType.bank => Icons.account_balance_outlined,
  AccountType.card => Icons.credit_card,
  AccountType.other => Icons.account_balance_wallet_outlined,
};

extension TransactionLabel on ExpenseTransaction {
  /// The title, else the note, else the category name (ADD-1).
  String label(Category? category, AppLocalizations l10n) =>
      title ?? note ?? category?.label(l10n) ?? '';
}

extension RecurringRuleLabel on RecurringRule {
  /// The title, else the note, else the category name, like a transaction.
  String label(Category? category, AppLocalizations l10n) =>
      title ?? note ?? category?.label(l10n) ?? '';
}

/// "Every month", "Every 2 weeks", and so on, with "Paused" when paused.
String scheduleLabel(RecurringRule rule, AppLocalizations l10n) {
  // An interval of one has a wording of its own — "Every day" rather than
  // "Every 1 days" — and it is a message rather than the plural's `=1` case:
  // gen_l10n compiles an explicit case into the CLDR category of the same
  // name, and Russian's "one" also holds 21 and 31, so a rule repeating
  // every 21 days used to describe itself as "Every day" (RCR-1, LANG-6).
  final schedule = rule.interval == 1
      ? switch (rule.frequency) {
          RecurrenceFrequency.day => l10n.scheduleEveryDay,
          RecurrenceFrequency.week => l10n.scheduleEveryWeek,
          RecurrenceFrequency.month => l10n.scheduleEveryMonth,
          RecurrenceFrequency.year => l10n.scheduleEveryYear,
        }
      : switch (rule.frequency) {
          RecurrenceFrequency.day => l10n.scheduleDays(rule.interval),
          RecurrenceFrequency.week => l10n.scheduleWeeks(rule.interval),
          RecurrenceFrequency.month => l10n.scheduleMonths(rule.interval),
          RecurrenceFrequency.year => l10n.scheduleYears(rule.interval),
        };
  return rule.isPaused ? l10n.pausedSchedule(schedule) : schedule;
}

/// "September 2026" for a calendar month, otherwise both dates, such as
/// "Aug 25 – Sep 24" (PER-3).
String periodLabel(Period period, AppLocalizations l10n) {
  if (period.isCalendarMonth) {
    return DateFormat.yMMMM(l10n.localeName).format(period.start);
  }
  final format = DateFormat.MMMd(l10n.localeName);
  return l10n.periodRange(
    format.format(period.start),
    format.format(period.lastDay),
  );
}
