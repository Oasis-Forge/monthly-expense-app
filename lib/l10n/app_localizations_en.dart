// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get statsTooltip => 'Stats';

  @override
  String get addButton => 'Add';

  @override
  String get emptyPeriod => 'No transactions in this period yet.';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get incomeLabel => 'Income';

  @override
  String get expenseLabel => 'Expense';

  @override
  String upcomingCategory(String category) {
    return '$category · Upcoming';
  }

  @override
  String get deleteFailed => 'Couldn\'t delete the transaction. Try again.';

  @override
  String get addTransactionTitle => 'Add Transaction';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get titleOptionalLabel => 'Title (optional)';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountRequired => 'Enter an amount';

  @override
  String get amountInvalid => 'Enter a valid amount';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryRequired => 'Choose a category';

  @override
  String get dateLabel => 'Date';

  @override
  String get noteOptionalLabel => 'Note (optional)';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get addTransactionButton => 'Add Transaction';

  @override
  String get saveFailed => 'Couldn\'t save the transaction. Try again.';

  @override
  String statsTitle(String period) {
    return 'Stats — $period';
  }

  @override
  String get noExpensesInPeriod => 'No expenses in this period yet.';

  @override
  String totalSpent(String amount) {
    return 'Total spent: $amount';
  }

  @override
  String periodRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryInvestment => 'Investment';

  @override
  String get categoryGift => 'Gift';

  @override
  String get categoryOther => 'Other';
}
