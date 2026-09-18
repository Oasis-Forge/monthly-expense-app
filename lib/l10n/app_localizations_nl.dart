// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Instellingen';

  @override
  String get transferTooltip => 'Overboeking';

  @override
  String get searchTooltip => 'Zoeken';

  @override
  String get addButton => 'Toevoegen';

  @override
  String get emptyPeriod => 'Nog geen transacties in deze periode.';

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get periodNetLabel => 'Deze periode';

  @override
  String carriedForwardLine(String amount) {
    return 'Overgedragen $amount';
  }

  @override
  String get incomeLabel => 'Inkomsten';

  @override
  String get expenseLabel => 'Uitgave';

  @override
  String upcomingCategory(String category) {
    return '$category · Binnenkort';
  }

  @override
  String get upcomingLabel => 'Binnenkort';

  @override
  String detailAdded(String date) {
    return 'Toegevoegd op $date';
  }

  @override
  String detailChanged(String date) {
    return 'Laatst gewijzigd op $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terugkerende transacties zijn te boeken',
      one: '1 terugkerende transactie is te boeken',
    );
    return '$_temp0';
  }

  @override
  String budgetsOverNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgetten zijn over de limiet',
      one: '1 budget is over de limiet',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent gebruikt · $over over de limiet',
      one: '$percent gebruikt · 1 over de limiet',
      zero: '$percent gebruikt',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgetten ingesteld',
      one: '1 budget ingesteld',
    );
    return '$_temp0';
  }

  @override
  String get editBudgetsButton => 'Budgetten bewerken';

  @override
  String get deleteFailed =>
      'Kan de transactie niet verwijderen. Probeer het opnieuw.';

  @override
  String get transactionDeleted => 'Transactie verwijderd';

  @override
  String get transferDeleted => 'Overboeking verwijderd';

  @override
  String get undoButton => 'Ongedaan maken';

  @override
  String get undoFailed => 'Kan niet ongedaan maken. Probeer het opnieuw.';

  @override
  String get restoreFailed =>
      'Kan de transactie niet herstellen. Probeer het opnieuw.';

  @override
  String get addTransactionTitle => 'Transactie toevoegen';

  @override
  String get editTransactionTitle => 'Transactie bewerken';

  @override
  String get transactionDetailTitle => 'Details';

  @override
  String get editTooltip => 'Bewerken';

  @override
  String get deleteTooltip => 'Verwijderen';

  @override
  String get duplicateTooltip => 'Dupliceren';

  @override
  String get titleOptionalLabel => 'Titel (optioneel)';

  @override
  String get amountLabel => 'Bedrag';

  @override
  String get amountRequired => 'Vul een bedrag in';

  @override
  String get amountInvalid => 'Vul een geldig bedrag in';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Backspace';

  @override
  String get hideKeypadTooltip => 'Toetsenbord verbergen';

  @override
  String get categoryLabel => 'Categorie';

  @override
  String get categoryRequired => 'Kies een categorie';

  @override
  String get accountLabel => 'Rekening';

  @override
  String get accountRequired => 'Kies een rekening';

  @override
  String get dateLabel => 'Datum';

  @override
  String get noteLabel => 'Notitie';

  @override
  String get previousDayTooltip => 'Vorige dag';

  @override
  String get nextDayTooltip => 'Volgende dag';

  @override
  String get noteOptionalLabel => 'Notitie (optioneel)';

  @override
  String get saveChangesButton => 'Wijzigingen opslaan';

  @override
  String get addTransactionButton => 'Transactie toevoegen';

  @override
  String get saveAndAddAnotherButton => 'Opslaan & nog een';

  @override
  String get transactionAdded => 'Transactie toegevoegd';

  @override
  String get saveFailed =>
      'Kan de transactie niet opslaan. Probeer het opnieuw.';

  @override
  String get noExpensesInPeriod => 'Nog geen uitgaven in deze periode.';

  @override
  String totalSpent(String amount) {
    return 'Totaal uitgegeven: $amount';
  }

  @override
  String periodRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String categoryAndDate(String category, String date) {
    return '$category · $date';
  }

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get drawerAddHeader => 'Toevoegen';

  @override
  String get drawerAddExpense => 'Uitgave toevoegen';

  @override
  String get drawerAddIncome => 'Inkomsten toevoegen';

  @override
  String get drawerPlanHeader => 'Plannen';

  @override
  String get drawerReviewHeader => 'Terugblik';

  @override
  String get drawerSpending => 'Uitgaven per categorie';

  @override
  String get drawerManageHeader => 'Beheer';

  @override
  String get drawerDataHeader => 'Gegevens';

  @override
  String get currencyLabel => 'Valuta';

  @override
  String get currencySearchHint => 'Zoek valuta';

  @override
  String changeCurrencyTitle(String code) {
    return 'Valuta wijzigen naar $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Bedragen blijven gelijk; alleen het valutalabel verandert.';

  @override
  String get changeButton => 'Wijzigen';

  @override
  String get cancelButton => 'Annuleren';

  @override
  String get saveButton => 'Opslaan';

  @override
  String get removeButton => 'Verwijderen';

  @override
  String get themeLabel => 'Thema';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get languageLabel => 'Taal';

  @override
  String get languageSystem => 'Systeemstandaard';

  @override
  String get monthStartLabel => 'Eerste dag van de maand';

  @override
  String get monthStartLastDay => 'Laatste dag';

  @override
  String get showCarriedForwardLabel => 'Saldo overdragen';

  @override
  String get showCarriedForwardSubtitle =>
      'Elke periode begint met het vorige saldo';

  @override
  String get trashTitle => 'Prullenbak';

  @override
  String get trashEmpty => 'Prullenbak is leeg.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'definitief verwijderd over $days dagen',
      one: 'definitief verwijderd over 1 dag',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Herstellen';

  @override
  String get categoriesTitle => 'Categorieën';

  @override
  String get addCategoryTooltip => 'Categorie toevoegen';

  @override
  String get addCategoryTitle => 'Categorie toevoegen';

  @override
  String get editCategoryTitle => 'Categorie bewerken';

  @override
  String get categoryNameLabel => 'Naam';

  @override
  String get categoryNameRequired => 'Vul een naam in';

  @override
  String get categoryNameTaken => 'Die naam is al in gebruik';

  @override
  String get archiveAction => 'Archiveren';

  @override
  String get unarchiveAction => 'Dearchiveren';

  @override
  String get deleteAction => 'Verwijderen';

  @override
  String get archivedHeader => 'Gearchiveerd';

  @override
  String get categorySaveFailed =>
      'Kan de categorie niet opslaan. Probeer het opnieuw.';

  @override
  String get accountsTitle => 'Rekeningen';

  @override
  String get accountCash => 'Contant';

  @override
  String get accountTypeLabel => 'Type';

  @override
  String get accountTypeCash => 'Contant';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCard => 'Kaart';

  @override
  String get accountTypeOther => 'Overig';

  @override
  String get addAccountTooltip => 'Rekening toevoegen';

  @override
  String get addAccountTitle => 'Rekening toevoegen';

  @override
  String get editAccountTitle => 'Rekening bewerken';

  @override
  String get openingBalanceLabel => 'Beginsaldo';

  @override
  String get openingDateLabel => 'Openingsdatum';

  @override
  String get accountSaveFailed =>
      'Kan de rekening niet opslaan. Probeer het opnieuw.';

  @override
  String get transferTitle => 'Overboeking';

  @override
  String get editTransferTitle => 'Overboeking bewerken';

  @override
  String get transferLabel => 'Overboeking';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Van';

  @override
  String get toAccountLabel => 'Naar';

  @override
  String get sameAccountError => 'Kies twee verschillende rekeningen';

  @override
  String get needTwoAccounts =>
      'Voeg een tweede rekening toe om geld tussen rekeningen te verplaatsen.';

  @override
  String get addTransferButton => 'Overboeking toevoegen';

  @override
  String get transferSaveFailed =>
      'Kan de overboeking niet opslaan. Probeer het opnieuw.';

  @override
  String get searchHint => 'Zoek transacties';

  @override
  String get allTypesFilter => 'Alle';

  @override
  String get allCategoriesFilter => 'Alle categorieën';

  @override
  String get allAccountsFilter => 'Alle rekeningen';

  @override
  String get allTimeFilter => 'Altijd';

  @override
  String get clearDatesTooltip => 'Datums wissen';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultaten',
      one: '1 resultaat',
    );
    return '$_temp0 · Inkomsten $income · Uitgave $expense';
  }

  @override
  String get noSearchResults => 'Geen overeenkomende transacties.';

  @override
  String get budgetsTitle => 'Budgetten';

  @override
  String get budgetsTooltip => 'Budgetten';

  @override
  String get overallBudget => 'Totaal';

  @override
  String get noBudget => 'Geen budget';

  @override
  String budgetsHint(String period) {
    return 'Limieten gelden vanaf $period; eerdere periodes behouden de hunne.';
  }

  @override
  String get budgetLimitLabel => 'Limiet per periode';

  @override
  String get budgetSaveFailed =>
      'Kan het budget niet opslaan. Probeer het opnieuw.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent van $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining over · $perDay per dag';
  }

  @override
  String budgetLeft(String remaining) {
    return '$remaining over';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount boven de limiet';
  }

  @override
  String get budgetLimitReached => 'Limiet bereikt';

  @override
  String budgetLimitOnly(String limit) {
    return 'Limiet $limit';
  }

  @override
  String get recurringTitle => 'Terugkerend';

  @override
  String get addRecurringTooltip => 'Terugkerend toevoegen';

  @override
  String get addRecurringTitle => 'Terugkerend toevoegen';

  @override
  String get editRecurringTitle => 'Terugkerend bewerken';

  @override
  String get dueHeader => 'Te boeken';

  @override
  String get upcomingHeader => 'Komende 30 dagen';

  @override
  String get rulesHeader => 'Regels';

  @override
  String get nothingUpcoming => 'Niets in de komende 30 dagen.';

  @override
  String get noRules => 'Nog geen terugkerende transacties.';

  @override
  String get postButton => 'Boeken';

  @override
  String get skipButton => 'Overslaan';

  @override
  String get postFailed =>
      'Kan de transactie niet boeken. Probeer het opnieuw.';

  @override
  String get recurringSaveFailed =>
      'Kan de terugkerende transactie niet opslaan. Probeer het opnieuw.';

  @override
  String get everyLabel => 'Elke';

  @override
  String get frequencyDays => 'Dagen';

  @override
  String get frequencyWeeks => 'Weken';

  @override
  String get frequencyMonths => 'Maanden';

  @override
  String get frequencyYears => 'Jaren';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elke $count dagen',
      one: 'Elke dag',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elke $count weken',
      one: 'Elke week',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elke $count maanden',
      one: 'Elke maand',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elke $count jaar',
      one: 'Elk jaar',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Gepauzeerd';
  }

  @override
  String get startsLabel => 'Begint';

  @override
  String get endsLabel => 'Eindigt';

  @override
  String get endNever => 'Nooit';

  @override
  String get endAfter => 'Na';

  @override
  String get endOnDate => 'Op datum';

  @override
  String get timesLabel => 'Keer';

  @override
  String get endsOnLabel => 'Eindigt op';

  @override
  String get wholeNumberInvalid => 'Vul een heel getal vanaf 1 in';

  @override
  String get endDateInvalid => 'De einddatum moet na de startdatum liggen';

  @override
  String get autoPostLabel => 'Automatisch boeken';

  @override
  String get autoPostSubtitle => 'Anders wacht deze in Te boeken op een tik';

  @override
  String get pauseTooltip => 'Pauzeren';

  @override
  String get resumeTooltip => 'Hervatten';

  @override
  String get categoryFood => 'Eten';

  @override
  String get categoryGroceries => 'Boodschappen';

  @override
  String get categoryTransport => 'Vervoer';

  @override
  String get categoryShopping => 'Winkelen';

  @override
  String get categoryBills => 'Facturen';

  @override
  String get categoryRent => 'Huur';

  @override
  String get categoryHealth => 'Gezondheid';

  @override
  String get categoryEducation => 'Onderwijs';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categorySalary => 'Salaris';

  @override
  String get categoryBusiness => 'Zakelijk';

  @override
  String get categoryInvestment => 'Belegging';

  @override
  String get categoryGift => 'Cadeau';

  @override
  String get categoryOther => 'Overig';

  @override
  String get previousPeriodTooltip => 'Vorige periode';

  @override
  String get nextPeriodTooltip => 'Volgende periode';

  @override
  String get insightsTooltip => 'Inzichten';

  @override
  String get insightsTitle => 'Inzichten';

  @override
  String get calendarTab => 'Kalender';

  @override
  String get trendTab => 'Trend';

  @override
  String get noIncomeInPeriod => 'Nog geen inkomsten in deze periode.';

  @override
  String totalIncome(String amount) {
    return 'Totale inkomsten: $amount';
  }

  @override
  String get calendarHint => 'Tik op een dag voor de transacties van die dag.';

  @override
  String get dayEmpty => 'Niets op deze dag.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maanden',
      one: '1 maand',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Inkomsten $income · Uitgave $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Gemiddeld per periode · Inkomsten $income · Uitgave $expense';
  }

  @override
  String get weekStartLabel => 'Eerste dag van de week';

  @override
  String weekStartDefault(String day) {
    return 'Standaard ($day)';
  }

  @override
  String get firstRunTitle => 'Welkom bij Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Houd bij wat je uitgeeft en verdient. Je gegevens blijven op dit apparaat.';

  @override
  String get addFirstTransactionButton => 'Voeg je eerste transactie toe';

  @override
  String get setupIntro =>
      'Kies je taal en valuta. Je kunt dit later wijzigen in Instellingen.';

  @override
  String get setupContinueButton => 'Doorgaan';

  @override
  String get setupRestoreTitle => 'Back-up herstellen';

  @override
  String get setupRestoreSubtitle =>
      'Herstel je gegevens en instellingen vanuit een back-upbestand';

  @override
  String get walkthroughEntryTitle => 'Binnen seconden toevoegen';

  @override
  String get walkthroughEntryBody =>
      'Een toetsenbord dat optelt, een foto van de bon, en een spraaknotitie als typen te traag gaat.';

  @override
  String get walkthroughPlanTitle => 'Plan de maand';

  @override
  String get walkthroughPlanBody =>
      'Budgetten per categorie, rekeningen die zichzelf herhalen, en notities die je ergens aan herinneren.';

  @override
  String get walkthroughInsightsTitle => 'Zie waar het heen gaat';

  @override
  String get walkthroughInsightsBody =>
      'Grafieken, een kalender, en een pdf- of csv-rapport voor elke periode.';

  @override
  String get walkthroughPrivacyTitle => 'Alleen van jou';

  @override
  String get walkthroughPrivacyBody =>
      'Geen account nodig. Wat je invoert, blijft op deze telefoon; de advertenties die de app betalen, zien het nooit.';

  @override
  String get walkthroughBringTitle => 'Breng mee wat je hebt';

  @override
  String get walkthroughBringBody =>
      'Kom je van een andere app of telefoon? Begin met een back-up of csv in plaats van een lege app.';

  @override
  String get firstRunRestoreTitle => 'Deze back-up herstellen?';

  @override
  String get firstRunRestoreMessage =>
      'Dit vervangt alles in de app, en herstelt de taal en valuta waarmee de back-up is opgeslagen.';

  @override
  String get walkthroughNextButton => 'Volgende';

  @override
  String get walkthroughStartButton => 'Aan de slag';

  @override
  String get walkthroughDoneButton => 'Klaar';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Pagina $current van $total';
  }

  @override
  String get walkthroughReplayTitle => 'Rondleiding opnieuw bekijken';

  @override
  String get walkthroughReplaySubtitle =>
      'De vier pagina\'s die je zag toen de app nieuw was';

  @override
  String get removeAdsTitle => 'Advertenties verwijderen';

  @override
  String get exportCsvMenu => 'CSV exporteren';

  @override
  String get exportCsvTooltip => 'CSV exporteren';

  @override
  String get csvExported => 'CSV opgeslagen';

  @override
  String get csvExportFailed =>
      'Kan de csv niet exporteren. Probeer het opnieuw.';

  @override
  String get backupTitle => 'Back-up & herstel';

  @override
  String get backupIntro =>
      'Back-ups zijn bestanden die je zelf opslaat. Er wordt niets automatisch geüpload of verzonden.';

  @override
  String get backUpNowTitle => 'Nu back-uppen';

  @override
  String lastBackupLine(String date) {
    return 'Laatste back-up $date';
  }

  @override
  String get neverBackedUp => 'Nog geen back-up';

  @override
  String get backupSaved => 'Back-up opgeslagen';

  @override
  String get backupSaveFailed =>
      'Kan de back-up niet opslaan. Probeer het opnieuw.';

  @override
  String get restoreFromFileTitle => 'Herstellen vanuit een bestand';

  @override
  String get restoreFromFileSubtitle =>
      'Voeg een back-up samen met je gegevens, of vervang je gegevens ermee';

  @override
  String get backupReminderLabel => 'Back-upherinnering';

  @override
  String get backupReminderSubtitle =>
      'Elke 30 dagen zodra je 20 transacties hebt';

  @override
  String get backupReminderNever =>
      'Maak een back-up om je gegevens veilig te stellen';

  @override
  String backupReminderSince(String date) {
    return 'Laatste back-up $date. Tijd voor een nieuwe?';
  }

  @override
  String get notNowTooltip => 'Niet nu';

  @override
  String get keptBackupsHeader => 'Automatische back-ups';

  @override
  String get keptBackupsHint =>
      'Opgeslagen op dit apparaat voor elke herstelactie.';

  @override
  String get noKeptBackups => 'Nog geen.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacties',
      one: '1 transactie',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Back-up herstellen';

  @override
  String get mergeOption => 'Samenvoegen';

  @override
  String get mergeOptionSubtitle =>
      'Behoud je gegevens en voeg die van de back-up toe. Bij een dubbele record wint de nieuwste wijziging.';

  @override
  String get replaceOption => 'Vervangen';

  @override
  String get replaceOptionSubtitle =>
      'Verwijder je gegevens en gebruik alleen de back-up, met bijbehorende instellingen.';

  @override
  String get restoreSafetyNote =>
      'Eerst wordt een kopie van je huidige gegevens opgeslagen bij Automatische back-ups.';

  @override
  String get restoreButton => 'Herstellen';

  @override
  String get restoreKeptTitle => 'Deze kopie herstellen?';

  @override
  String restoreKeptMessage(String date) {
    return 'Je gegevens worden vervangen door de kopie van $date. Eerst wordt een kopie van je huidige gegevens opgeslagen.';
  }

  @override
  String get backupInvalid =>
      'Dit bestand is geen back-up van Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Deze back-up komt van een nieuwere versie van de app. Werk de app bij en probeer het opnieuw.';

  @override
  String get backupOpenFailed =>
      'Kan het bestand niet openen. Probeer het opnieuw.';

  @override
  String get backupRestoreFailed =>
      'Kan de back-up niet herstellen. Je gegevens zijn niet gewijzigd.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacties hersteld',
      one: '1 transactie hersteld',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Samengevoegd: $added toegevoegd, $updated bijgewerkt, $unchanged ongewijzigd';
  }

  @override
  String get appLockLabel => 'App-vergrendeling';

  @override
  String get appLockSubtitle =>
      'Ontgrendel met je vingerafdruk, gezicht of schermvergrendeling';

  @override
  String get appLockUnavailable =>
      'Stel een schermvergrendeling in op dit apparaat om app-vergrendeling te gebruiken';

  @override
  String get appLockReason => 'Ontgrendel Monthly Expenses';

  @override
  String get appLockFailed =>
      'Kan niet bevestigen dat jij het bent. App-vergrendeling is niet gewijzigd.';

  @override
  String get lockedTitle => 'Monthly Expenses is vergrendeld';

  @override
  String get unlockButton => 'Ontgrendelen';

  @override
  String get widgetShowAmountsLabel => 'Bedragen tonen op de widget';

  @override
  String get widgetShowAmountsSubtitle =>
      'De widget op het beginscherm verbergt ze zolang app-vergrendeling aan staat';

  @override
  String get widgetLeftLabel => 'Over';

  @override
  String get widgetAddExpense => 'Uitgave toevoegen';

  @override
  String get widgetAddIncome => 'Inkomsten toevoegen';

  @override
  String get widgetAmountsHidden =>
      'Bedragen zijn verborgen door app-vergrendeling';

  @override
  String get notesTitle => 'Notities';

  @override
  String get addNoteTooltip => 'Notitie toevoegen';

  @override
  String get addNoteTitle => 'Notitie toevoegen';

  @override
  String get editNoteTitle => 'Notitie bewerken';

  @override
  String get noteTextLabel => 'Notitie';

  @override
  String get noteTextRequired => 'Vul een tekst in';

  @override
  String get noteAmountOptionalLabel => 'Bedrag (optioneel)';

  @override
  String get noteDueDateToggle => 'Vervaldatum instellen';

  @override
  String get noteDueDateLabel => 'Vervaldatum';

  @override
  String get noteReminderToggle => 'Herinner mij';

  @override
  String get noteReminderTimeLabel => 'Herinneringstijd';

  @override
  String get noteReminderTimeUnset => 'Kies een tijd';

  @override
  String get noteCategoryOptionalLabel => 'Categorie (optioneel)';

  @override
  String get noteCategoryNone => 'Geen';

  @override
  String get recordNoteButton => 'Vastleggen als transactie';

  @override
  String get noteMarkDoneTooltip => 'Voltooien';

  @override
  String get noteMarkOpenTooltip => 'Heropenen';

  @override
  String get notesEmptyTitle => 'Nog niets hier';

  @override
  String get notesEmptyMessage =>
      'Notities onthouden dingen om te doen of te checken, met een optionele datum, bedrag en categorie.';

  @override
  String get addNoteButton => 'Notitie toevoegen';

  @override
  String get notesOpenHeader => 'Open';

  @override
  String get notesDoneHeader => 'Klaar';

  @override
  String get noteDeleted => 'Notitie verwijderd.';

  @override
  String get noteSaveFailed =>
      'Kan de notitie niet opslaan. Probeer het opnieuw.';

  @override
  String get noteDeleteFailed =>
      'Kan de notitie niet verwijderen. Probeer het opnieuw.';

  @override
  String get noteRestoreFailed =>
      'Kan de notitie niet herstellen. Probeer het opnieuw.';

  @override
  String get notesSearchHint => 'Zoek notities';

  @override
  String get noteFilterAll => 'Alle';

  @override
  String get noteFilterOverdue => 'Verlopen';

  @override
  String get noteFilterDueToday => 'Vandaag';

  @override
  String get noteFilterUpcoming => 'Binnenkort';

  @override
  String get noteFilterNoDate => 'Geen datum';

  @override
  String get noNoteResults => 'Geen overeenkomende notities.';

  @override
  String get noteLinkedTransactionLabel => 'Vastgelegd als transactie';

  @override
  String get noteLinkedNoteLabel => 'Vanuit een notitie';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notities vervallen',
      one: '1 notitie vervalt',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Vervallende notities';

  @override
  String get noteReminderTitle => 'Notitieherinnering';

  @override
  String get noteReminderLockedTitle => 'Een notitie vervalt';

  @override
  String get noteReminderPermissionDenied =>
      'Zet meldingen aan in de systeeminstellingen om herinneringen voor notities te ontvangen.';

  @override
  String reportRange(String from, String to) {
    return '$from tot $to';
  }

  @override
  String reportCreated(String when) {
    return 'Gemaakt op $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Pagina $page van $pages';
  }

  @override
  String get reportNet => 'Netto';

  @override
  String get reportOpeningBalance => 'Beginsaldo';

  @override
  String get reportClosingBalance => 'Eindsaldo';

  @override
  String get reportSpendingHeader => 'Uitgaven per categorie';

  @override
  String get reportEarningHeader => 'Inkomsten per categorie';

  @override
  String get reportTrendHeader => 'Trend';

  @override
  String get reportEntriesHeader => 'Transacties';

  @override
  String get reportUpcomingHeader => 'Binnenkort';

  @override
  String get reportUpcomingNote =>
      'Gedateerd in de toekomst, dus niet meegeteld in de totalen hierboven.';

  @override
  String get reportAmountColumn => 'Bedrag';

  @override
  String get reportShareColumn => 'Aandeel';

  @override
  String get reportBudgetColumn => 'Budget';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used van $limit';
  }

  @override
  String get reportDetailsColumn => 'Details';

  @override
  String get reportEmpty => 'Niets te rapporteren voor deze datums.';

  @override
  String get exportPdfMenu => 'PDF exporteren';

  @override
  String get reportTitle => 'PDF exporteren';

  @override
  String get reportNoFontTitle => 'Nog niet in deze taal';

  @override
  String get reportNoFontBody =>
      'Een rapport heeft een lettertype voor zijn schrift nodig, en die voor Chinees, Japans en Koreaans zijn te groot om mee te leveren. Een latere versie biedt aan er een te downloaden.';

  @override
  String get reportPreviewTitle => 'Rapport';

  @override
  String get reportCoversHeader => 'Wat het omvat';

  @override
  String get reportRangePeriod => 'Deze periode';

  @override
  String get reportRangeCustom => 'Datums';

  @override
  String get reportRangeYear => 'Jaar';

  @override
  String get reportFromLabel => 'Van';

  @override
  String get reportToLabel => 'Tot';

  @override
  String get reportYearLabel => 'Jaar';

  @override
  String get reportAccountLabel => 'Rekening';

  @override
  String get reportAllAccounts => 'Alle rekeningen';

  @override
  String get reportIncludeHeader => 'Wat het bevat';

  @override
  String get reportIncludeSubtitle => 'Laat weg wat je liever niet deelt.';

  @override
  String get reportIncludeTransactions => 'De transactielijst';

  @override
  String get reportIncludeDetails => 'Titels en notities';

  @override
  String get reportIncludeAccounts => 'Rekeningnamen';

  @override
  String get reportCreateButton => 'Rapport maken';

  @override
  String get reportBuilding => 'Rapport wordt gemaakt';

  @override
  String get reportFailed => 'Kan het rapport niet maken. Probeer het opnieuw.';

  @override
  String get reportRangeBackwards =>
      'De eerste datum moet voor de laatste liggen.';

  @override
  String get importTitle => 'Een csv importeren';

  @override
  String get importSubtitle => 'Breng transacties over vanuit een andere app';

  @override
  String get importIntro =>
      'Kies een csv-bestand en bekijk wat de app ervan maakt voordat er iets wordt toegevoegd. Importeren voegt alleen records toe — het vervangt of verwijdert nooit wat je al hebt.';

  @override
  String get importChooseFile => 'Kies een bestand';

  @override
  String get importChooseAnother => 'Kies een ander bestand';

  @override
  String get importReadFailed =>
      'Kan dat bestand niet lezen. Probeer het opnieuw.';

  @override
  String get importRefusedEmpty => 'Dat bestand is leeg.';

  @override
  String get importRefusedNoDate =>
      'Geen enkele kolom in dat bestand kon als datum worden gelezen, dus importeren is niet mogelijk.';

  @override
  String get importRefusedNoAmount =>
      'Geen enkele kolom in dat bestand kon als bedrag worden gelezen, dus importeren is niet mogelijk.';

  @override
  String get importRefusedNoRows =>
      'Geen van de rijen in dat bestand kon worden gelezen, dus er is niets om te importeren.';

  @override
  String get importColumnsHeader => 'Kolommen';

  @override
  String get importColumnsSubtitle =>
      'Pas aan wat de app verkeerd heeft gelezen.';

  @override
  String get importColumnNone => 'Niet gebruikt';

  @override
  String get importFieldType => 'Type';

  @override
  String get importFieldToAccount => 'Naar rekening';

  @override
  String get importFieldTitle => 'Titel';

  @override
  String get importFieldNote => 'Notitie';

  @override
  String get importDateOrderLabel => 'Datums zoals 03/04 betekenen';

  @override
  String get importDayFirst => 'Dag eerst';

  @override
  String get importMonthFirst => 'Maand eerst';

  @override
  String get importCountsHeader => 'Wat er gaat gebeuren';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rijen worden geïmporteerd',
      one: '1 rij wordt geïmporteerd',
      zero: 'Er wordt niets geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rijen hebben een datum die de app niet kan lezen',
      one: '1 rij heeft een datum die de app niet kan lezen',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rijen hebben een bedrag dat de app niet kan lezen',
      one: '1 rij heeft een bedrag dat de app niet kan lezen',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rijen zijn voor geen enkel bedrag',
      one: '1 rij is voor geen enkel bedrag',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rijen staan al in de app',
      one: '1 rij staat al in de app',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overboekingen noemen maar één rekening',
      one: '1 overboeking noemt maar één rekening',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Datum kan niet worden gelezen';

  @override
  String get importRowUnreadableAmount => 'Bedrag kan niet worden gelezen';

  @override
  String get importRowZero => 'Geen enkel bedrag';

  @override
  String get importRowAlreadyThere => 'Staat al in de app';

  @override
  String get importRowIncompleteTransfer => 'Maar één rekening genoemd';

  @override
  String get importNamesHeader => 'Namen die de app nog niet kent';

  @override
  String get importNamesSubtitle =>
      'Kies wat elke naam wordt. Importeren maakt nooit een categorie of rekening aan.';

  @override
  String get importRowsHeader =>
      'De eerste rijen, zoals de app ze heeft gelezen';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en nog $count',
      one: 'en nog 1',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rijen importeren',
      one: '1 rij importeren',
      zero: 'Niets om te importeren',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records geïmporteerd',
      one: '1 record geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'Kan dat bestand niet importeren. Er is niets toegevoegd.';

  @override
  String get attachmentsLabel => 'Bijlagen';

  @override
  String get photoLabel => 'Foto';

  @override
  String get photoAdd => 'Foto toevoegen';

  @override
  String get photoTake => 'Foto maken';

  @override
  String get photoChoose => 'Foto kiezen';

  @override
  String get photoRemove => 'Foto verwijderen';

  @override
  String get photoMissing => 'Deze foto ontbreekt.';

  @override
  String get voiceNoteLabel => 'Spraaknotitie';

  @override
  String get voiceRecord => 'Spraaknotitie opnemen';

  @override
  String voiceRecording(int seconds) {
    return 'Bezig met opnemen, nog ${seconds}s';
  }

  @override
  String get voiceStop => 'Stop';

  @override
  String get voicePlay => 'Afspelen';

  @override
  String get voicePause => 'Pauzeren';

  @override
  String get voiceRemove => 'Spraaknotitie verwijderen';

  @override
  String get voiceMissing => 'Deze spraaknotitie ontbreekt.';

  @override
  String get microphoneRefused => 'De microfoon staat uit voor deze app.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Inclusief bijlagen, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Verbergt alle advertenties met één betaling. Dit is gekoppeld aan je store-account, dus het keert terug bij een nieuwe telefoon of herinstallatie.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Advertenties verwijderen voor $price';
  }

  @override
  String get removeAdsOwned => 'Advertenties staan uit. Bedankt.';

  @override
  String get removeAdsPending => 'Wachten op de store…';

  @override
  String get removeAdsUnavailable =>
      'De store heeft hier nog niets te koop. Probeer het later opnieuw.';

  @override
  String get removeAdsFailed =>
      'Dat is niet gelukt en er is niets in rekening gebracht.';

  @override
  String get restorePurchasesButton => 'Aankopen herstellen';

  @override
  String get payNothingWithheld =>
      'Alle functies blijven gratis, met of zonder advertenties.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Binnenkort beschikbaar';

  @override
  String get plusBody =>
      'Een bankkoppeling die je transacties ophaalt zodat je ze kunt bevestigen. Nog niet klaar, dus er is nog niets te koop.';

  @override
  String get privacyOptionsTitle => 'Privacyopties';

  @override
  String get privacyOptionsSubtitle =>
      'Wijzig je keuze over gepersonaliseerde advertenties';
}
