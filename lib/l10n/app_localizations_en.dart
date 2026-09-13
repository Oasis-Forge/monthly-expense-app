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
  String get settingsTooltip => 'Settings';

  @override
  String get transferTooltip => 'Transfer';

  @override
  String get addButton => 'Add';

  @override
  String get emptyPeriod => 'No transactions in this period yet.';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get periodNetLabel => 'This period';

  @override
  String carriedForwardLine(String amount) {
    return 'Carried forward $amount';
  }

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
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transferDeleted => 'Transfer deleted';

  @override
  String get undoButton => 'Undo';

  @override
  String get undoFailed => 'Couldn\'t undo. Try again.';

  @override
  String get restoreFailed => 'Couldn\'t restore the transaction. Try again.';

  @override
  String get addTransactionTitle => 'Add Transaction';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get duplicateTooltip => 'Duplicate';

  @override
  String get titleOptionalLabel => 'Title (optional)';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountRequired => 'Enter an amount';

  @override
  String get amountInvalid => 'Enter a valid amount';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Backspace';

  @override
  String get hideKeypadTooltip => 'Hide keypad';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryRequired => 'Choose a category';

  @override
  String get accountLabel => 'Account';

  @override
  String get accountRequired => 'Choose an account';

  @override
  String get dateLabel => 'Date';

  @override
  String get previousDayTooltip => 'Previous day';

  @override
  String get nextDayTooltip => 'Next day';

  @override
  String get noteOptionalLabel => 'Note (optional)';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get addTransactionButton => 'Add Transaction';

  @override
  String get saveAndAddAnotherButton => 'Save & add another';

  @override
  String get transactionAdded => 'Transaction added';

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
  String get settingsTitle => 'Settings';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get currencySearchHint => 'Search currencies';

  @override
  String changeCurrencyTitle(String code) {
    return 'Change currency to $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Amounts stay the same; only their currency label changes.';

  @override
  String get changeButton => 'Change';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get monthStartLabel => 'First day of the month';

  @override
  String get monthStartLastDay => 'Last day';

  @override
  String get showCarriedForwardLabel => 'Carry balance forward';

  @override
  String get showCarriedForwardSubtitle =>
      'Each period starts from the previous balance';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashEmpty => 'Trash is empty.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'deleted for good in $days days',
      one: 'deleted for good in 1 day',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Restore';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get addCategoryTooltip => 'Add category';

  @override
  String get addCategoryTitle => 'Add category';

  @override
  String get editCategoryTitle => 'Edit category';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get categoryNameRequired => 'Enter a name';

  @override
  String get categoryNameTaken => 'That name is already used';

  @override
  String get archiveAction => 'Archive';

  @override
  String get unarchiveAction => 'Unarchive';

  @override
  String get deleteAction => 'Delete';

  @override
  String get archivedHeader => 'Archived';

  @override
  String get categorySaveFailed => 'Couldn\'t save the category. Try again.';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountCash => 'Cash';

  @override
  String get accountTypeLabel => 'Type';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCard => 'Card';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get addAccountTooltip => 'Add account';

  @override
  String get addAccountTitle => 'Add account';

  @override
  String get editAccountTitle => 'Edit account';

  @override
  String get openingBalanceLabel => 'Opening balance';

  @override
  String get openingDateLabel => 'Opening date';

  @override
  String get accountSaveFailed => 'Couldn\'t save the account. Try again.';

  @override
  String get transferTitle => 'Transfer';

  @override
  String get editTransferTitle => 'Edit transfer';

  @override
  String get transferLabel => 'Transfer';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'From';

  @override
  String get toAccountLabel => 'To';

  @override
  String get sameAccountError => 'Choose two different accounts';

  @override
  String get needTwoAccounts =>
      'Add a second account to move money between accounts.';

  @override
  String get addTransferButton => 'Add Transfer';

  @override
  String get transferSaveFailed => 'Couldn\'t save the transfer. Try again.';

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
