import 'package:flutter/material.dart' show IconData, Icons, TextDirection;
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
  final schedule = switch (rule.frequency) {
    RecurrenceFrequency.day => l10n.scheduleDays(rule.interval),
    RecurrenceFrequency.week => l10n.scheduleWeeks(rule.interval),
    RecurrenceFrequency.month => l10n.scheduleMonths(rule.interval),
    RecurrenceFrequency.year => l10n.scheduleYears(rule.interval),
  };
  return rule.isPaused ? l10n.pausedSchedule(schedule) : schedule;
}

/// Keeps [text], such as a signed amount, in one left-to-right run inside
/// right-to-left text, so `-$12.00` doesn't become `$12.00-` (LANG-5).
/// Left-to-right layouts get [text] unchanged.
String isolateLeftToRight(String text, TextDirection direction) =>
    direction == TextDirection.rtl
    ? '${String.fromCharCode(0x2066)}$text${String.fromCharCode(0x2069)}'
    : text;

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
