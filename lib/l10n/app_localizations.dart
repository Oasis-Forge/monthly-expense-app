import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses'**
  String get appTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @transferTooltip.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferTooltip;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @emptyPeriod.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period yet.'**
  String get emptyPeriod;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @periodNetLabel.
  ///
  /// In en, this message translates to:
  /// **'This period'**
  String get periodNetLabel;

  /// No description provided for @carriedForwardLine.
  ///
  /// In en, this message translates to:
  /// **'Carried forward {amount}'**
  String carriedForwardLine(String amount);

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @expenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseLabel;

  /// Subtitle of a future-dated row.
  ///
  /// In en, this message translates to:
  /// **'{category} · Upcoming'**
  String upcomingCategory(String category);

  /// No description provided for @recurringDueNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recurring transaction is due} other{{count} recurring transactions are due}}'**
  String recurringDueNotice(int count);

  /// No description provided for @budgetsOverNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 budget is over its limit} other{{count} budgets are over their limit}}'**
  String budgetsOverNotice(int count);

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the transaction. Try again.'**
  String get deleteFailed;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @transferDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transfer deleted'**
  String get transferDeleted;

  /// No description provided for @undoButton.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoButton;

  /// No description provided for @undoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t undo. Try again.'**
  String get undoFailed;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore the transaction. Try again.'**
  String get restoreFailed;

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionTitle;

  /// No description provided for @editTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransactionTitle;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @duplicateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicateTooltip;

  /// No description provided for @titleOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get titleOptionalLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get amountRequired;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get amountInvalid;

  /// Live result of an amount like 12.5+3.
  ///
  /// In en, this message translates to:
  /// **'= {amount}'**
  String amountResult(String amount);

  /// No description provided for @backspaceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get backspaceTooltip;

  /// No description provided for @hideKeypadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide keypad'**
  String get hideKeypadTooltip;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get categoryRequired;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @accountRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose an account'**
  String get accountRequired;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @previousDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDayTooltip;

  /// No description provided for @nextDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDayTooltip;

  /// No description provided for @noteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptionalLabel;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @addTransactionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionButton;

  /// No description provided for @saveAndAddAnotherButton.
  ///
  /// In en, this message translates to:
  /// **'Save & add another'**
  String get saveAndAddAnotherButton;

  /// No description provided for @transactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added'**
  String get transactionAdded;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the transaction. Try again.'**
  String get saveFailed;

  /// No description provided for @noExpensesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period yet.'**
  String get noExpensesInPeriod;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent: {amount}'**
  String totalSpent(String amount);

  /// A period that doesn't start on the 1st, e.g. 25 Aug – 24 Sep.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String periodRange(String start, String end);

  /// No description provided for @categoryAndDate.
  ///
  /// In en, this message translates to:
  /// **'{category} · {date}'**
  String categoryAndDate(String category, String date);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @currencySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search currencies'**
  String get currencySearchHint;

  /// No description provided for @changeCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Change currency to {code}?'**
  String changeCurrencyTitle(String code);

  /// No description provided for @changeCurrencyMessage.
  ///
  /// In en, this message translates to:
  /// **'Amounts stay the same; only their currency label changes.'**
  String get changeCurrencyMessage;

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @monthStartLabel.
  ///
  /// In en, this message translates to:
  /// **'First day of the month'**
  String get monthStartLabel;

  /// No description provided for @monthStartLastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get monthStartLastDay;

  /// No description provided for @showCarriedForwardLabel.
  ///
  /// In en, this message translates to:
  /// **'Carry balance forward'**
  String get showCarriedForwardLabel;

  /// No description provided for @showCarriedForwardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each period starts from the previous balance'**
  String get showCarriedForwardSubtitle;

  /// No description provided for @trashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty.'**
  String get trashEmpty;

  /// No description provided for @trashItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{amount} · {days, plural, =1{deleted for good in 1 day} other{deleted for good in {days} days}}'**
  String trashItemSubtitle(String amount, int days);

  /// No description provided for @restoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreTooltip;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @addCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryTooltip;

  /// No description provided for @addCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryTitle;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get categoryNameRequired;

  /// No description provided for @categoryNameTaken.
  ///
  /// In en, this message translates to:
  /// **'That name is already used'**
  String get categoryNameTaken;

  /// No description provided for @archiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveAction;

  /// No description provided for @unarchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchiveAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @archivedHeader.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedHeader;

  /// No description provided for @categorySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the category. Try again.'**
  String get categorySaveFailed;

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @accountCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountCash;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountTypeLabel;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountTypeBank;

  /// No description provided for @accountTypeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get accountTypeCard;

  /// No description provided for @accountTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// No description provided for @addAccountTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccountTooltip;

  /// No description provided for @addAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccountTitle;

  /// No description provided for @editAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccountTitle;

  /// No description provided for @openingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalanceLabel;

  /// No description provided for @openingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening date'**
  String get openingDateLabel;

  /// No description provided for @accountSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the account. Try again.'**
  String get accountSaveFailed;

  /// No description provided for @transferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferTitle;

  /// No description provided for @editTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transfer'**
  String get editTransferTitle;

  /// No description provided for @transferLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferLabel;

  /// No description provided for @transferRoute.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String transferRoute(String from, String to);

  /// No description provided for @fromAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromAccountLabel;

  /// No description provided for @toAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toAccountLabel;

  /// No description provided for @sameAccountError.
  ///
  /// In en, this message translates to:
  /// **'Choose two different accounts'**
  String get sameAccountError;

  /// No description provided for @needTwoAccounts.
  ///
  /// In en, this message translates to:
  /// **'Add a second account to move money between accounts.'**
  String get needTwoAccounts;

  /// No description provided for @addTransferButton.
  ///
  /// In en, this message translates to:
  /// **'Add Transfer'**
  String get addTransferButton;

  /// No description provided for @transferSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the transfer. Try again.'**
  String get transferSaveFailed;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get searchHint;

  /// No description provided for @allTypesFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTypesFilter;

  /// No description provided for @allCategoriesFilter.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategoriesFilter;

  /// No description provided for @allAccountsFilter.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get allAccountsFilter;

  /// No description provided for @allTimeFilter.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTimeFilter;

  /// No description provided for @clearDatesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get clearDatesTooltip;

  /// No description provided for @searchSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}} · Income {income} · Expense {expense}'**
  String searchSummary(int count, String income, String expense);

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions.'**
  String get noSearchResults;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @budgetsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTooltip;

  /// No description provided for @overallBudget.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overallBudget;

  /// No description provided for @noBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget'**
  String get noBudget;

  /// No description provided for @budgetsHint.
  ///
  /// In en, this message translates to:
  /// **'Limits apply from {period} on; earlier periods keep theirs.'**
  String budgetsHint(String period);

  /// No description provided for @budgetLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit per period'**
  String get budgetLimitLabel;

  /// No description provided for @budgetSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the budget. Try again.'**
  String get budgetSaveFailed;

  /// No description provided for @budgetSpentOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String budgetSpentOfLimit(String spent, String limit);

  /// No description provided for @budgetLeftPerDay.
  ///
  /// In en, this message translates to:
  /// **'{remaining} left · {perDay} a day'**
  String budgetLeftPerDay(String remaining, String perDay);

  /// No description provided for @budgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{remaining} left'**
  String budgetLeft(String remaining);

  /// No description provided for @budgetOverBy.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String budgetOverBy(String amount);

  /// No description provided for @budgetLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get budgetLimitReached;

  /// No description provided for @budgetLimitOnly.
  ///
  /// In en, this message translates to:
  /// **'Limit {limit}'**
  String budgetLimitOnly(String limit);

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurringTitle;

  /// No description provided for @addRecurringTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add recurring'**
  String get addRecurringTooltip;

  /// No description provided for @addRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Add recurring'**
  String get addRecurringTitle;

  /// No description provided for @editRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring'**
  String get editRecurringTitle;

  /// No description provided for @dueHeader.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueHeader;

  /// No description provided for @upcomingHeader.
  ///
  /// In en, this message translates to:
  /// **'Next 30 days'**
  String get upcomingHeader;

  /// No description provided for @rulesHeader.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rulesHeader;

  /// No description provided for @nothingUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the next 30 days.'**
  String get nothingUpcoming;

  /// No description provided for @noRules.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions yet.'**
  String get noRules;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @postFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post the transaction. Try again.'**
  String get postFailed;

  /// No description provided for @recurringSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the recurring transaction. Try again.'**
  String get recurringSaveFailed;

  /// No description provided for @everyLabel.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get everyLabel;

  /// No description provided for @frequencyDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get frequencyDays;

  /// No description provided for @frequencyWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get frequencyWeeks;

  /// No description provided for @frequencyMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get frequencyMonths;

  /// No description provided for @frequencyYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get frequencyYears;

  /// No description provided for @scheduleDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String scheduleDays(int count);

  /// No description provided for @scheduleWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String scheduleWeeks(int count);

  /// No description provided for @scheduleMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String scheduleMonths(int count);

  /// No description provided for @scheduleYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every year} other{Every {count} years}}'**
  String scheduleYears(int count);

  /// No description provided for @pausedSchedule.
  ///
  /// In en, this message translates to:
  /// **'{schedule} · Paused'**
  String pausedSchedule(String schedule);

  /// No description provided for @startsLabel.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startsLabel;

  /// No description provided for @endsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsLabel;

  /// No description provided for @endNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get endNever;

  /// No description provided for @endAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get endAfter;

  /// No description provided for @endOnDate.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get endOnDate;

  /// No description provided for @timesLabel.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get timesLabel;

  /// No description provided for @endsOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends on'**
  String get endsOnLabel;

  /// No description provided for @wholeNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 1'**
  String get wholeNumberInvalid;

  /// No description provided for @endDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'The end date must be after the start'**
  String get endDateInvalid;

  /// No description provided for @autoPostLabel.
  ///
  /// In en, this message translates to:
  /// **'Post automatically'**
  String get autoPostLabel;

  /// No description provided for @autoPostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Otherwise it waits in Due for a tap'**
  String get autoPostSubtitle;

  /// No description provided for @pauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTooltip;

  /// No description provided for @resumeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeTooltip;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categoryInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get categoryInvestment;

  /// No description provided for @categoryGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get categoryGift;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @previousPeriodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriodTooltip;

  /// No description provided for @nextPeriodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriodTooltip;

  /// No description provided for @insightsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTooltip;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @calendarTab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTab;

  /// No description provided for @trendTab.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendTab;

  /// No description provided for @noIncomeInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No income in this period yet.'**
  String get noIncomeInPeriod;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income: {amount}'**
  String totalIncome(String amount);

  /// No description provided for @calendarHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to see its transactions.'**
  String get calendarHint;

  /// No description provided for @dayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this day.'**
  String get dayEmpty;

  /// No description provided for @trendMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String trendMonths(int count);

  /// No description provided for @incomeExpenseLine.
  ///
  /// In en, this message translates to:
  /// **'Income {income} · Expense {expense}'**
  String incomeExpenseLine(String income, String expense);

  /// No description provided for @trendAverage.
  ///
  /// In en, this message translates to:
  /// **'Average per period · Income {income} · Expense {expense}'**
  String trendAverage(String income, String expense);

  /// No description provided for @weekStartLabel.
  ///
  /// In en, this message translates to:
  /// **'First day of the week'**
  String get weekStartLabel;

  /// The locale's first day of the week, used until the user picks one.
  ///
  /// In en, this message translates to:
  /// **'Default ({day})'**
  String weekStartDefault(String day);

  /// No description provided for @firstRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Monthly Expenses'**
  String get firstRunTitle;

  /// No description provided for @firstRunMessage.
  ///
  /// In en, this message translates to:
  /// **'Track what you spend and earn. Your data stays on this device.'**
  String get firstRunMessage;

  /// No description provided for @addFirstTransactionButton.
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction'**
  String get addFirstTransactionButton;

  /// No description provided for @exportCsvMenu.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvMenu;

  /// No description provided for @exportCsvTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvTooltip;

  /// No description provided for @csvExported.
  ///
  /// In en, this message translates to:
  /// **'CSV saved'**
  String get csvExported;

  /// No description provided for @csvExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the CSV. Try again.'**
  String get csvExportFailed;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupTitle;

  /// No description provided for @backupIntro.
  ///
  /// In en, this message translates to:
  /// **'Backups are files you save where you choose. Nothing is uploaded or sent automatically.'**
  String get backupIntro;

  /// No description provided for @backUpNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backUpNowTitle;

  /// No description provided for @lastBackupLine.
  ///
  /// In en, this message translates to:
  /// **'Last backup {date}'**
  String lastBackupLine(String date);

  /// No description provided for @neverBackedUp.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get neverBackedUp;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @backupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the backup. Try again.'**
  String get backupSaveFailed;

  /// No description provided for @restoreFromFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a file'**
  String get restoreFromFileTitle;

  /// No description provided for @restoreFromFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Merge a backup into your data, or replace your data with it'**
  String get restoreFromFileSubtitle;

  /// No description provided for @backupReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup reminder'**
  String get backupReminderLabel;

  /// No description provided for @backupReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every 30 days once you have 20 transactions'**
  String get backupReminderSubtitle;

  /// No description provided for @backupReminderNever.
  ///
  /// In en, this message translates to:
  /// **'Back up your data to keep it safe'**
  String get backupReminderNever;

  /// No description provided for @backupReminderSince.
  ///
  /// In en, this message translates to:
  /// **'Last backup {date}. Time for a new one?'**
  String backupReminderSince(String date);

  /// No description provided for @notNowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNowTooltip;

  /// No description provided for @keptBackupsHeader.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups'**
  String get keptBackupsHeader;

  /// No description provided for @keptBackupsHint.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device before each restore.'**
  String get keptBackupsHint;

  /// No description provided for @noKeptBackups.
  ///
  /// In en, this message translates to:
  /// **'None yet.'**
  String get noKeptBackups;

  /// No description provided for @backupSummary.
  ///
  /// In en, this message translates to:
  /// **'{date} · {count, plural, =1{1 transaction} other{{count} transactions}}'**
  String backupSummary(String date, int count);

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreTitle;

  /// No description provided for @mergeOption.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mergeOption;

  /// No description provided for @mergeOptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your data and add the backup\'s. Where both have a record, the newer change wins.'**
  String get mergeOptionSubtitle;

  /// No description provided for @replaceOption.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceOption;

  /// No description provided for @replaceOptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your data and use only the backup, with its settings.'**
  String get replaceOptionSubtitle;

  /// No description provided for @restoreSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'A copy of your current data is saved under Automatic backups first.'**
  String get restoreSafetyNote;

  /// No description provided for @restoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreButton;

  /// No description provided for @restoreKeptTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this copy?'**
  String get restoreKeptTitle;

  /// No description provided for @restoreKeptMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data is replaced by the copy from {date}. A copy of your current data is saved first.'**
  String restoreKeptMessage(String date);

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a Monthly Expenses backup.'**
  String get backupInvalid;

  /// No description provided for @backupTooNew.
  ///
  /// In en, this message translates to:
  /// **'This backup is from a newer version of the app. Update the app, then try again.'**
  String get backupTooNew;

  /// No description provided for @backupOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the file. Try again.'**
  String get backupOpenFailed;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore the backup. Your data wasn\'t changed.'**
  String get backupRestoreFailed;

  /// No description provided for @restoredReplace.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Restored 1 transaction} other{Restored {count} transactions}}'**
  String restoredReplace(int count);

  /// No description provided for @restoredMerge.
  ///
  /// In en, this message translates to:
  /// **'Merged: {added} added, {updated} updated, {unchanged} unchanged'**
  String restoredMerge(int added, int updated, int unchanged);

  /// No description provided for @appLockLabel.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLockLabel;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with your fingerprint, face, or screen lock'**
  String get appLockSubtitle;

  /// No description provided for @appLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set up a screen lock on this device to use app lock'**
  String get appLockUnavailable;

  /// No description provided for @appLockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Monthly Expenses'**
  String get appLockReason;

  /// No description provided for @appLockFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm it\'s you. App lock wasn\'t changed.'**
  String get appLockFailed;

  /// No description provided for @lockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses is locked'**
  String get lockedTitle;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @addNoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNoteTooltip;

  /// No description provided for @addNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNoteTitle;

  /// No description provided for @editNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNoteTitle;

  /// No description provided for @noteTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteTextLabel;

  /// No description provided for @noteTextRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter some text'**
  String get noteTextRequired;

  /// No description provided for @noteAmountOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (optional)'**
  String get noteAmountOptionalLabel;

  /// No description provided for @noteDueDateToggle.
  ///
  /// In en, this message translates to:
  /// **'Set a due date'**
  String get noteDueDateToggle;

  /// No description provided for @noteDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get noteDueDateLabel;

  /// No description provided for @noteReminderToggle.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get noteReminderToggle;

  /// No description provided for @noteReminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get noteReminderTimeLabel;

  /// No description provided for @noteReminderTimeUnset.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get noteReminderTimeUnset;

  /// No description provided for @noteCategoryOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get noteCategoryOptionalLabel;

  /// No description provided for @noteCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noteCategoryNone;

  /// No description provided for @recordNoteButton.
  ///
  /// In en, this message translates to:
  /// **'Record as transaction'**
  String get recordNoteButton;

  /// No description provided for @noteMarkDoneTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get noteMarkDoneTooltip;

  /// No description provided for @noteMarkOpenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark open'**
  String get noteMarkOpenTooltip;

  /// No description provided for @notesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get notesEmptyTitle;

  /// No description provided for @notesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Notes remember things to do or check on, with an optional date, amount, and category.'**
  String get notesEmptyMessage;

  /// No description provided for @addNoteButton.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addNoteButton;

  /// No description provided for @notesOpenHeader.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get notesOpenHeader;

  /// No description provided for @notesDoneHeader.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notesDoneHeader;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted.'**
  String get noteDeleted;

  /// No description provided for @noteSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the note. Try again.'**
  String get noteSaveFailed;

  /// No description provided for @noteDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the note. Try again.'**
  String get noteDeleteFailed;

  /// No description provided for @noteRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore the note. Try again.'**
  String get noteRestoreFailed;

  /// No description provided for @notesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get notesSearchHint;

  /// No description provided for @noteFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get noteFilterAll;

  /// No description provided for @noteFilterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get noteFilterOverdue;

  /// No description provided for @noteFilterDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get noteFilterDueToday;

  /// No description provided for @noteFilterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get noteFilterUpcoming;

  /// No description provided for @noteFilterNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noteFilterNoDate;

  /// No description provided for @noNoteResults.
  ///
  /// In en, this message translates to:
  /// **'No matching notes.'**
  String get noNoteResults;

  /// No description provided for @noteLinkedTransactionLabel.
  ///
  /// In en, this message translates to:
  /// **'Recorded as a transaction'**
  String get noteLinkedTransactionLabel;

  /// No description provided for @noteLinkedNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'From a note'**
  String get noteLinkedNoteLabel;

  /// No description provided for @notesDueNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note is due} other{{count} notes are due}}'**
  String notesDueNotice(int count);

  /// No description provided for @dayNotesDueHeader.
  ///
  /// In en, this message translates to:
  /// **'Notes due'**
  String get dayNotesDueHeader;

  /// No description provided for @noteReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Note reminder'**
  String get noteReminderTitle;

  /// No description provided for @noteReminderLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'A note is due'**
  String get noteReminderLockedTitle;

  /// No description provided for @noteReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications in system settings to get reminders for notes.'**
  String get noteReminderPermissionDenied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
