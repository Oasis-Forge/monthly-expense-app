import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/period.dart';
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
