// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Ustawienia';

  @override
  String get transferTooltip => 'Przelew';

  @override
  String get searchTooltip => 'Szukaj';

  @override
  String get addButton => 'Dodaj';

  @override
  String get emptyPeriod => 'Brak transakcji w tym okresie.';

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get periodNetLabel => 'Ten okres';

  @override
  String carriedForwardLine(String amount) {
    return 'Przeniesiono $amount';
  }

  @override
  String get incomeLabel => 'Przychód';

  @override
  String get expenseLabel => 'Wydatek';

  @override
  String upcomingCategory(String category) {
    return '$category · Nadchodzące';
  }

  @override
  String get upcomingLabel => 'Nadchodzące';

  @override
  String detailAdded(String date) {
    return 'Dodano $date';
  }

  @override
  String detailChanged(String date) {
    return 'Ostatnia zmiana $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transakcji cyklicznych czeka na zaksięgowanie',
      many: '$count transakcji cyklicznych czeka na zaksięgowanie',
      few: '$count transakcje cykliczne czekają na zaksięgowanie',
      one: '1 transakcja cykliczna czeka na zaksięgowanie',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: 'Wykorzystano $percent · $over przekroczonych',
      many: 'Wykorzystano $percent · $over przekroczonych',
      few: 'Wykorzystano $percent · $over przekroczone',
      one: 'Wykorzystano $percent · 1 przekroczony',
      zero: 'Wykorzystano $percent',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budżetów ustalonych',
      many: '$count budżetów ustalonych',
      few: '$count budżety ustalone',
      one: '1 budżet ustalony',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed =>
      'Nie udało się usunąć transakcji. Spróbuj ponownie.';

  @override
  String get transactionDeleted => 'Transakcja usunięta';

  @override
  String get transferDeleted => 'Przelew usunięty';

  @override
  String get undoButton => 'Cofnij';

  @override
  String get undoFailed => 'Nie udało się cofnąć. Spróbuj ponownie.';

  @override
  String get restoreFailed =>
      'Nie udało się przywrócić transakcji. Spróbuj ponownie.';

  @override
  String get addTransactionTitle => 'Nowa transakcja';

  @override
  String get editTransactionTitle => 'Edytuj transakcję';

  @override
  String get transactionDetailTitle => 'Szczegóły';

  @override
  String get editTooltip => 'Edytuj';

  @override
  String get deleteTooltip => 'Usuń';

  @override
  String get duplicateTooltip => 'Duplikuj';

  @override
  String get rowMenuTooltip => 'Więcej akcji';

  @override
  String get deleteTransactionTitle => 'Usunąć tę transakcję?';

  @override
  String get deleteTransactionMessage =>
      'Trafi do kosza i przez 30 dni można ją przywrócić.';

  @override
  String get discardChangesTitle => 'Odrzucić zmiany?';

  @override
  String get discardChangesMessage =>
      'To, co tu wpisano, nie zostało zapisane.';

  @override
  String get discardButton => 'Odrzuć';

  @override
  String get keepEditingButton => 'Edytuj dalej';

  @override
  String get titleOptionalLabel => 'Tytuł (opcjonalnie)';

  @override
  String get amountLabel => 'Kwota';

  @override
  String get amountRequired => 'Podaj kwotę';

  @override
  String get amountInvalid => 'Podaj prawidłową kwotę';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Usuń znak';

  @override
  String get hideKeypadTooltip => 'Ukryj klawiaturę';

  @override
  String get categoryLabel => 'Kategoria';

  @override
  String get categoryRequired => 'Wybierz kategorię';

  @override
  String get accountLabel => 'Konto';

  @override
  String get accountRequired => 'Wybierz konto';

  @override
  String get dateLabel => 'Data';

  @override
  String get noteLabel => 'Notatka';

  @override
  String get previousDayTooltip => 'Poprzedni dzień';

  @override
  String get nextDayTooltip => 'Następny dzień';

  @override
  String get noteOptionalLabel => 'Notatka (opcjonalnie)';

  @override
  String get saveChangesButton => 'Zapisz zmiany';

  @override
  String get addTransactionButton => 'Dodaj transakcję';

  @override
  String get saveAndAddAnotherButton => 'Zapisz i dodaj kolejną';

  @override
  String get transactionAdded => 'Transakcja dodana';

  @override
  String get saveFailed =>
      'Nie udało się zapisać transakcji. Spróbuj ponownie.';

  @override
  String get noExpensesInPeriod => 'Brak wydatków w tym okresie.';

  @override
  String totalSpent(String amount) {
    return 'Wydano łącznie: $amount';
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
  String get settingsTitle => 'Ustawienia';

  @override
  String get drawerAddHeader => 'Dodaj';

  @override
  String get drawerAddExpense => 'Dodaj wydatek';

  @override
  String get drawerAddIncome => 'Dodaj przychód';

  @override
  String get drawerPlanHeader => 'Planuj';

  @override
  String get drawerReviewHeader => 'Przegląd';

  @override
  String get drawerSpending => 'Wydatki według kategorii';

  @override
  String get drawerManageHeader => 'Zarządzaj';

  @override
  String get drawerDataHeader => 'Dane';

  @override
  String get currencyLabel => 'Waluta';

  @override
  String get currencySearchHint => 'Szukaj waluty';

  @override
  String changeCurrencyTitle(String code) {
    return 'Zmienić walutę na $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Kwoty pozostają takie same, zmienia się tylko oznaczenie waluty.';

  @override
  String get changeButton => 'Zmień';

  @override
  String get cancelButton => 'Anuluj';

  @override
  String get saveButton => 'Zapisz';

  @override
  String get removeButton => 'Usuń';

  @override
  String get themeLabel => 'Motyw';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get languageLabel => 'Język';

  @override
  String get languageSystem => 'Domyślny systemowy';

  @override
  String get monthStartLabel => 'Pierwszy dzień miesiąca';

  @override
  String get monthStartLastDay => 'Ostatni dzień';

  @override
  String get showCarriedForwardLabel => 'Przenoś saldo';

  @override
  String get showCarriedForwardSubtitle =>
      'Każdy okres zaczyna się od poprzedniego salda';

  @override
  String get trashTitle => 'Kosz';

  @override
  String get trashEmpty => 'Kosz jest pusty.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'zostanie usunięte na stałe za $days dni',
      one: 'zostanie usunięte na stałe za 1 dzień',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Przywróć';

  @override
  String get categoriesTitle => 'Kategorie';

  @override
  String get addCategoryTooltip => 'Dodaj kategorię';

  @override
  String get addCategoryTitle => 'Dodaj kategorię';

  @override
  String get editCategoryTitle => 'Edytuj kategorię';

  @override
  String get categoryNameLabel => 'Nazwa';

  @override
  String get categoryNameRequired => 'Podaj nazwę';

  @override
  String get categoryNameTaken => 'Ta nazwa jest już używana';

  @override
  String get archiveAction => 'Archiwizuj';

  @override
  String get unarchiveAction => 'Przywróć z archiwum';

  @override
  String get deleteAction => 'Usuń';

  @override
  String get archivedHeader => 'Zarchiwizowane';

  @override
  String get categorySaveFailed =>
      'Nie udało się zapisać kategorii. Spróbuj ponownie.';

  @override
  String get accountsTitle => 'Konta';

  @override
  String get accountCash => 'Gotówka';

  @override
  String get accountTypeLabel => 'Typ';

  @override
  String get accountTypeCash => 'Gotówka';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCard => 'Karta';

  @override
  String get accountTypeOther => 'Inne';

  @override
  String get addAccountTooltip => 'Dodaj konto';

  @override
  String get addAccountTitle => 'Dodaj konto';

  @override
  String get editAccountTitle => 'Edytuj konto';

  @override
  String get openingBalanceLabel => 'Saldo początkowe';

  @override
  String get openingDateLabel => 'Data otwarcia';

  @override
  String get accountSaveFailed =>
      'Nie udało się zapisać konta. Spróbuj ponownie.';

  @override
  String get transferTitle => 'Przelew';

  @override
  String get editTransferTitle => 'Edytuj przelew';

  @override
  String get transferLabel => 'Przelew';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Z';

  @override
  String get toAccountLabel => 'Na';

  @override
  String get sameAccountError => 'Wybierz dwa różne konta';

  @override
  String get needTwoAccounts =>
      'Dodaj drugie konto, aby przelewać między kontami.';

  @override
  String get addTransferButton => 'Dodaj przelew';

  @override
  String get transferSaveFailed =>
      'Nie udało się zapisać przelewu. Spróbuj ponownie.';

  @override
  String get searchHint => 'Szukaj transakcji';

  @override
  String get allTypesFilter => 'Wszystkie';

  @override
  String get allCategoriesFilter => 'Wszystkie kategorie';

  @override
  String get allAccountsFilter => 'Wszystkie konta';

  @override
  String get allTimeFilter => 'Cały czas';

  @override
  String get clearDatesTooltip => 'Wyczyść daty';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wyników',
      many: '$count wyników',
      few: '$count wyniki',
      one: '1 wynik',
    );
    return '$_temp0 · Przychód $income · Wydatek $expense';
  }

  @override
  String get noSearchResults => 'Brak pasujących transakcji.';

  @override
  String get budgetsTitle => 'Budżety';

  @override
  String get budgetsTooltip => 'Budżety';

  @override
  String get overallBudget => 'Ogólny';

  @override
  String get noBudget => 'Brak budżetu';

  @override
  String budgetsHint(String period) {
    return 'Limity obowiązują od $period; wcześniejsze okresy zachowują swoje.';
  }

  @override
  String get budgetLimitLabel => 'Limit na okres';

  @override
  String get budgetSaveFailed =>
      'Nie udało się zapisać budżetu. Spróbuj ponownie.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent z $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return 'Pozostało $remaining · $perDay dziennie';
  }

  @override
  String budgetLeft(String remaining) {
    return 'Pozostało $remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Przekroczono o $amount';
  }

  @override
  String get budgetLimitReached => 'Limit osiągnięty';

  @override
  String budgetLimitOnly(String limit) {
    return 'Limit $limit';
  }

  @override
  String get recurringTitle => 'Cykliczne';

  @override
  String get addRecurringTooltip => 'Dodaj cykliczną';

  @override
  String get addRecurringTitle => 'Dodaj cykliczną transakcję';

  @override
  String get editRecurringTitle => 'Edytuj cykliczną transakcję';

  @override
  String get dueHeader => 'Do zaksięgowania';

  @override
  String get upcomingHeader => 'Następne 30 dni';

  @override
  String get rulesHeader => 'Reguły';

  @override
  String get nothingUpcoming => 'Nic w ciągu najbliższych 30 dni.';

  @override
  String get noRules => 'Brak cyklicznych transakcji.';

  @override
  String get postButton => 'Zaksięguj';

  @override
  String get skipButton => 'Pomiń';

  @override
  String get postFailed =>
      'Nie udało się zaksięgować transakcji. Spróbuj ponownie.';

  @override
  String get recurringSaveFailed =>
      'Nie udało się zapisać cyklicznej transakcji. Spróbuj ponownie.';

  @override
  String get everyLabel => 'Co';

  @override
  String get frequencyDays => 'Dni';

  @override
  String get frequencyWeeks => 'Tygodnie';

  @override
  String get frequencyMonths => 'Miesiące';

  @override
  String get frequencyYears => 'Lata';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Co $count dni',
      one: 'Co dzień',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Co $count tygodni',
      many: 'Co $count tygodni',
      few: 'Co $count tygodnie',
      one: 'Co tydzień',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Co $count miesięcy',
      many: 'Co $count miesięcy',
      few: 'Co $count miesiące',
      one: 'Co miesiąc',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Co $count lat',
      many: 'Co $count lat',
      few: 'Co $count lata',
      one: 'Co rok',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Wstrzymano';
  }

  @override
  String get startsLabel => 'Rozpoczyna się';

  @override
  String get endsLabel => 'Kończy się';

  @override
  String get endNever => 'Nigdy';

  @override
  String get endAfter => 'Po';

  @override
  String get endOnDate => 'W dniu';

  @override
  String get timesLabel => 'Razy';

  @override
  String get endsOnLabel => 'Kończy się dnia';

  @override
  String get wholeNumberInvalid => 'Podaj liczbę całkowitą od 1';

  @override
  String get endDateInvalid =>
      'Data zakończenia musi być późniejsza niż data rozpoczęcia';

  @override
  String get autoPostLabel => 'Księguj automatycznie';

  @override
  String get autoPostSubtitle =>
      'W przeciwnym razie czeka w sekcji „Do zaksięgowania”';

  @override
  String get pauseTooltip => 'Wstrzymaj';

  @override
  String get resumeTooltip => 'Wznów';

  @override
  String get categoryFood => 'Jedzenie';

  @override
  String get categoryGroceries => 'Zakupy spożywcze';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Zakupy';

  @override
  String get categoryBills => 'Rachunki';

  @override
  String get categoryRent => 'Czynsz';

  @override
  String get categoryHealth => 'Zdrowie';

  @override
  String get categoryEducation => 'Edukacja';

  @override
  String get categoryEntertainment => 'Rozrywka';

  @override
  String get categorySalary => 'Wynagrodzenie';

  @override
  String get categoryBusiness => 'Firma';

  @override
  String get categoryInvestment => 'Inwestycje';

  @override
  String get categoryGift => 'Prezent';

  @override
  String get categoryOther => 'Inne';

  @override
  String get previousPeriodTooltip => 'Poprzedni okres';

  @override
  String get wholePeriodTooltip => 'Pokaż cały okres';

  @override
  String get nextPeriodTooltip => 'Następny okres';

  @override
  String get insightsTooltip => 'Statystyki';

  @override
  String get insightsTitle => 'Statystyki';

  @override
  String get calendarTab => 'Kalendarz';

  @override
  String get trendTab => 'Trend';

  @override
  String get noIncomeInPeriod => 'Brak przychodów w tym okresie.';

  @override
  String totalIncome(String amount) {
    return 'Przychód łącznie: $amount';
  }

  @override
  String get calendarHint => 'Stuknij dzień, aby zobaczyć jego transakcje.';

  @override
  String get dayEmpty => 'Nic w tym dniu.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miesięcy',
      many: '$count miesięcy',
      few: '$count miesiące',
      one: '1 miesiąc',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Przychód $income · Wydatek $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Średnia na okres · Przychód $income · Wydatek $expense';
  }

  @override
  String get weekStartLabel => 'Pierwszy dzień tygodnia';

  @override
  String weekStartDefault(String day) {
    return 'Domyślny ($day)';
  }

  @override
  String get firstRunTitle => 'Witaj w Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Śledź swoje wydatki i przychody. Twoje dane zostają na tym urządzeniu.';

  @override
  String get addFirstTransactionButton => 'Dodaj pierwszą transakcję';

  @override
  String get setupIntro =>
      'Wybierz język i walutę. Możesz je później zmienić w ustawieniach.';

  @override
  String get setupContinueButton => 'Dalej';

  @override
  String get setupRestoreTitle => 'Przywróć kopię zapasową';

  @override
  String get setupRestoreSubtitle =>
      'Przywróć dane i ustawienia z pliku kopii zapasowej';

  @override
  String get walkthroughEntryTitle => 'Dodawaj w kilka sekund';

  @override
  String get walkthroughEntryBody =>
      'Klawiatura, która liczy za ciebie, zdjęcie paragonu i notatka głosowa, gdy nie chce się pisać.';

  @override
  String get walkthroughPlanTitle => 'Zaplanuj miesiąc';

  @override
  String get walkthroughPlanBody =>
      'Budżety według kategorii, rachunki, które powtarzają się same, i notatki, które o nich przypomną.';

  @override
  String get walkthroughInsightsTitle => 'Zobacz, gdzie znikają pieniądze';

  @override
  String get walkthroughInsightsBody =>
      'Wykresy, kalendarz i raport PDF lub CSV za dowolny okres.';

  @override
  String get walkthroughPrivacyTitle => 'Tylko twoje';

  @override
  String get walkthroughPrivacyBody =>
      'Bez konta. To, co zapisujesz, zostaje na tym telefonie — reklamy, które finansują aplikację, nigdy tego nie widzą.';

  @override
  String get walkthroughBringTitle => 'Przenieś to, co już masz';

  @override
  String get walkthroughBringBody =>
      'Przechodzisz z innej aplikacji lub telefonu? Zacznij od kopii zapasowej lub pliku CSV zamiast pustej aplikacji.';

  @override
  String get firstRunRestoreTitle => 'Przywrócić tę kopię zapasową?';

  @override
  String get firstRunRestoreMessage =>
      'Zastąpi to wszystko w aplikacji i przywróci język oraz walutę, z jakimi została zapisana.';

  @override
  String get walkthroughNextButton => 'Dalej';

  @override
  String get walkthroughStartButton => 'Zaczynajmy';

  @override
  String get walkthroughDoneButton => 'Gotowe';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Strona $current z $total';
  }

  @override
  String get walkthroughReplayTitle => 'Pokaż wprowadzenie ponownie';

  @override
  String get walkthroughReplaySubtitle =>
      'Cztery strony pokazywane przy pierwszym uruchomieniu';

  @override
  String get removeAdsTitle => 'Usuń reklamy';

  @override
  String get exportCsvMenu => 'Eksportuj CSV';

  @override
  String get exportCsvTooltip => 'Eksportuj CSV';

  @override
  String get csvExported => 'Zapisano CSV';

  @override
  String get csvExportFailed =>
      'Nie udało się wyeksportować CSV. Spróbuj ponownie.';

  @override
  String get backupTitle => 'Kopia zapasowa i przywracanie';

  @override
  String get backupIntro =>
      'Kopie zapasowe to pliki zapisywane tam, gdzie wybierzesz. Nic nie jest wysyłane automatycznie.';

  @override
  String get backUpNowTitle => 'Utwórz kopię zapasową teraz';

  @override
  String lastBackupLine(String date) {
    return 'Ostatnia kopia zapasowa: $date';
  }

  @override
  String get neverBackedUp => 'Brak kopii zapasowej';

  @override
  String get backupSaved => 'Kopia zapasowa zapisana';

  @override
  String get backupSaveFailed =>
      'Nie udało się zapisać kopii zapasowej. Spróbuj ponownie.';

  @override
  String get restoreFromFileTitle => 'Przywróć z pliku';

  @override
  String get restoreFromFileSubtitle =>
      'Scal kopię zapasową z danymi lub zastąp nią swoje dane';

  @override
  String get backupReminderLabel => 'Przypomnienie o kopii zapasowej';

  @override
  String get backupReminderSubtitle =>
      'Co 30 dni, gdy masz co najmniej 20 transakcji';

  @override
  String get backupReminderNever =>
      'Utwórz kopię zapasową, aby zabezpieczyć dane';

  @override
  String backupReminderSince(String date) {
    return 'Ostatnia kopia zapasowa: $date. Czas na nową?';
  }

  @override
  String get notNowTooltip => 'Nie teraz';

  @override
  String get keptBackupsHeader => 'Automatyczne kopie zapasowe';

  @override
  String get keptBackupsHint =>
      'Zapisywane na tym urządzeniu przed każdym przywróceniem.';

  @override
  String get noKeptBackups => 'Jeszcze żadnych.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transakcji',
      many: '$count transakcji',
      few: '$count transakcje',
      one: '1 transakcja',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Przywróć kopię zapasową';

  @override
  String get mergeOption => 'Scal';

  @override
  String get mergeOptionSubtitle =>
      'Zachowaj swoje dane i dodaj te z kopii zapasowej. Gdy oba mają ten sam rekord, wygrywa nowsza zmiana.';

  @override
  String get replaceOption => 'Zastąp';

  @override
  String get replaceOptionSubtitle =>
      'Usuń swoje dane i użyj tylko kopii zapasowej wraz z jej ustawieniami.';

  @override
  String get restoreSafetyNote =>
      'Kopia twoich obecnych danych jest najpierw zapisywana w sekcji Automatyczne kopie zapasowe.';

  @override
  String get restoreButton => 'Przywróć';

  @override
  String get restoreKeptTitle => 'Przywrócić tę kopię?';

  @override
  String restoreKeptMessage(String date) {
    return 'Twoje dane zostaną zastąpione kopią z $date. Kopia obecnych danych zostanie zapisana wcześniej.';
  }

  @override
  String get backupInvalid =>
      'Ten plik nie jest kopią zapasową Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Ta kopia zapasowa pochodzi z nowszej wersji aplikacji. Zaktualizuj aplikację i spróbuj ponownie.';

  @override
  String get backupOpenFailed =>
      'Nie udało się otworzyć pliku. Spróbuj ponownie.';

  @override
  String get backupRestoreFailed =>
      'Nie udało się przywrócić kopii zapasowej. Twoje dane nie zostały zmienione.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przywrócono $count transakcji',
      many: 'Przywrócono $count transakcji',
      few: 'Przywrócono $count transakcje',
      one: 'Przywrócono 1 transakcję',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Scalono: dodano $added, zaktualizowano $updated, bez zmian $unchanged';
  }

  @override
  String get appLockLabel => 'Blokada aplikacji';

  @override
  String get appLockSubtitle =>
      'Odblokuj odciskiem palca, twarzą lub blokadą ekranu';

  @override
  String get appLockUnavailable =>
      'Ustaw blokadę ekranu na tym urządzeniu, aby używać blokady aplikacji';

  @override
  String get appLockReason => 'Odblokuj Monthly Expenses';

  @override
  String get appLockFailed =>
      'Nie udało się potwierdzić tożsamości. Blokada aplikacji nie została zmieniona.';

  @override
  String get lockedTitle => 'Monthly Expenses jest zablokowane';

  @override
  String get unlockButton => 'Odblokuj';

  @override
  String get widgetShowAmountsLabel => 'Pokazuj kwoty na widżecie';

  @override
  String get widgetShowAmountsSubtitle =>
      'Widżet ekranu głównego ukrywa je, gdy blokada aplikacji jest włączona';

  @override
  String get widgetLeftLabel => 'Pozostało';

  @override
  String get widgetAddExpense => 'Dodaj wydatek';

  @override
  String get widgetAddIncome => 'Dodaj przychód';

  @override
  String get widgetAmountsHidden => 'Kwoty są ukryte przez blokadę aplikacji';

  @override
  String get notesTitle => 'Notatki';

  @override
  String get addNoteTooltip => 'Dodaj notatkę';

  @override
  String get addNoteTitle => 'Dodaj notatkę';

  @override
  String get editNoteTitle => 'Edytuj notatkę';

  @override
  String get noteTextLabel => 'Notatka';

  @override
  String get noteTextRequired => 'Wpisz treść';

  @override
  String get noteAmountOptionalLabel => 'Kwota (opcjonalnie)';

  @override
  String get noteDueDateToggle => 'Ustaw termin';

  @override
  String get noteDueDateLabel => 'Termin';

  @override
  String get noteReminderToggle => 'Przypomnij mi';

  @override
  String get noteReminderTimeLabel => 'Godzina przypomnienia';

  @override
  String get noteReminderTimeUnset => 'Wybierz godzinę';

  @override
  String get noteCategoryOptionalLabel => 'Kategoria (opcjonalnie)';

  @override
  String get noteCategoryNone => 'Brak';

  @override
  String get recordNoteButton => 'Zapisz jako transakcję';

  @override
  String get noteMarkDoneTooltip => 'Oznacz jako wykonane';

  @override
  String get noteMarkOpenTooltip => 'Oznacz jako otwarte';

  @override
  String get notesEmptyTitle => 'Jeszcze nic tu nie ma';

  @override
  String get notesEmptyMessage =>
      'Notatki przypominają o sprawach do zrobienia lub sprawdzenia, z opcjonalną datą, kwotą i kategorią.';

  @override
  String get addNoteButton => 'Dodaj notatkę';

  @override
  String get notesOpenHeader => 'Otwarte';

  @override
  String get notesDoneHeader => 'Wykonane';

  @override
  String get noteDeleted => 'Notatka usunięta.';

  @override
  String get noteSaveFailed =>
      'Nie udało się zapisać notatki. Spróbuj ponownie.';

  @override
  String get noteDeleteFailed =>
      'Nie udało się usunąć notatki. Spróbuj ponownie.';

  @override
  String get noteRestoreFailed =>
      'Nie udało się przywrócić notatki. Spróbuj ponownie.';

  @override
  String get notesSearchHint => 'Szukaj notatek';

  @override
  String get noteFilterAll => 'Wszystkie';

  @override
  String get noteFilterOverdue => 'Zaległe';

  @override
  String get noteFilterDueToday => 'Na dziś';

  @override
  String get noteFilterUpcoming => 'Nadchodzące';

  @override
  String get noteFilterNoDate => 'Bez daty';

  @override
  String get noNoteResults => 'Brak pasujących notatek.';

  @override
  String get noteLinkedTransactionLabel => 'Zapisano jako transakcję';

  @override
  String get noteLinkedNoteLabel => 'Z notatki';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notatek wymaga uwagi',
      many: '$count notatek wymaga uwagi',
      few: '$count notatki wymagają uwagi',
      one: '1 notatka wymaga uwagi',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Notatki na dziś';

  @override
  String get noteReminderTitle => 'Przypomnienie o notatce';

  @override
  String get noteReminderLockedTitle => 'Notatka wymaga uwagi';

  @override
  String get noteReminderPermissionDenied =>
      'Włącz powiadomienia w ustawieniach systemu, aby otrzymywać przypomnienia o notatkach.';

  @override
  String reportRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String reportCreated(String when) {
    return 'Utworzono $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Strona $page z $pages';
  }

  @override
  String get reportNet => 'Netto';

  @override
  String get reportOpeningBalance => 'Saldo początkowe';

  @override
  String get reportClosingBalance => 'Saldo końcowe';

  @override
  String get reportSpendingHeader => 'Wydatki według kategorii';

  @override
  String get reportEarningHeader => 'Przychody według kategorii';

  @override
  String get reportTrendHeader => 'Trend';

  @override
  String get reportEntriesHeader => 'Transakcje';

  @override
  String get reportUpcomingHeader => 'Nadchodzące';

  @override
  String get reportUpcomingNote =>
      'Data w przyszłości, więc nieujęte w powyższych sumach.';

  @override
  String get reportAmountColumn => 'Kwota';

  @override
  String get reportShareColumn => 'Udział';

  @override
  String get reportBudgetColumn => 'Budżet';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used z $limit';
  }

  @override
  String get reportDetailsColumn => 'Szczegóły';

  @override
  String get reportEmpty => 'Brak danych do raportu dla tych dat.';

  @override
  String get exportPdfMenu => 'Eksportuj PDF';

  @override
  String get reportTitle => 'Eksportuj PDF';

  @override
  String get reportNoFontTitle => 'Jeszcze nie w tym języku';

  @override
  String get reportNoFontBody =>
      'Raport potrzebuje czcionki dla swojego pisma, a chińska, japońska i koreańska są zbyt duże, by nosić je w aplikacji. Późniejsza wersja zaproponuje ich pobranie.';

  @override
  String get reportPreviewTitle => 'Raport';

  @override
  String get reportCoversHeader => 'Co obejmuje';

  @override
  String get reportRangePeriod => 'Ten okres';

  @override
  String get reportRangeCustom => 'Daty';

  @override
  String get reportRangeYear => 'Rok';

  @override
  String get reportFromLabel => 'Od';

  @override
  String get reportToLabel => 'Do';

  @override
  String get reportYearLabel => 'Rok';

  @override
  String get reportAccountLabel => 'Konto';

  @override
  String get reportAllAccounts => 'Wszystkie konta';

  @override
  String get reportIncludeHeader => 'Co zawiera';

  @override
  String get reportIncludeSubtitle =>
      'Pomiń wszystko, czym nie chcesz się dzielić.';

  @override
  String get reportIncludeTransactions => 'Listę transakcji';

  @override
  String get reportIncludeDetails => 'Tytuły i notatki';

  @override
  String get reportIncludeAccounts => 'Nazwy kont';

  @override
  String get reportCreateButton => 'Utwórz raport';

  @override
  String get reportBuilding => 'Tworzenie raportu';

  @override
  String get reportFailed =>
      'Nie udało się utworzyć raportu. Spróbuj ponownie.';

  @override
  String get reportRangeBackwards =>
      'Pierwsza data musi być wcześniejsza niż ostatnia.';

  @override
  String get importTitle => 'Importuj plik CSV';

  @override
  String get importSubtitle => 'Wczytaj transakcje z innej aplikacji';

  @override
  String get importIntro =>
      'Wybierz plik CSV, a zobaczysz, co z niego odczytano, zanim cokolwiek zostanie dodane. Import tylko dodaje rekordy — nigdy nie zastępuje ani nie usuwa tego, co już masz.';

  @override
  String get importChooseFile => 'Wybierz plik';

  @override
  String get importChooseAnother => 'Wybierz inny plik';

  @override
  String get importReadFailed =>
      'Nie udało się odczytać tego pliku. Spróbuj ponownie.';

  @override
  String get importRefusedEmpty => 'Ten plik jest pusty.';

  @override
  String get importRefusedNoDate =>
      'Żadnej kolumny w tym pliku nie udało się odczytać jako daty, więc nie można go zaimportować.';

  @override
  String get importRefusedNoAmount =>
      'Żadnej kolumny w tym pliku nie udało się odczytać jako kwoty, więc nie można go zaimportować.';

  @override
  String get importRefusedNoRows =>
      'Żadnego wiersza w tym pliku nie udało się odczytać, więc nie ma nic do zaimportowania.';

  @override
  String get importColumnsHeader => 'Kolumny';

  @override
  String get importColumnsSubtitle =>
      'Popraw wszystko, co aplikacja odczytała błędnie.';

  @override
  String get importColumnNone => 'Nieużywana';

  @override
  String get importFieldType => 'Typ';

  @override
  String get importFieldToAccount => 'Na konto';

  @override
  String get importFieldTitle => 'Tytuł';

  @override
  String get importFieldNote => 'Notatka';

  @override
  String get importDateOrderLabel => 'Daty w formacie 03/04 oznaczają';

  @override
  String get importDayFirst => 'Najpierw dzień';

  @override
  String get importMonthFirst => 'Najpierw miesiąc';

  @override
  String get importCountsHeader => 'Co się stanie';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zostanie zaimportowanych $count wierszy',
      many: 'Zostanie zaimportowanych $count wierszy',
      few: 'Zostaną zaimportowane $count wiersze',
      one: 'Zostanie zaimportowany 1 wiersz',
      zero: 'Nic nie zostanie zaimportowane',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wierszy ma datę, której aplikacja nie może odczytać',
      many: '$count wierszy ma datę, której aplikacja nie może odczytać',
      few: '$count wiersze mają datę, której aplikacja nie może odczytać',
      one: '1 wiersz ma datę, której aplikacja nie może odczytać',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wierszy ma kwotę, której aplikacja nie może odczytać',
      many: '$count wierszy ma kwotę, której aplikacja nie może odczytać',
      few: '$count wiersze mają kwotę, której aplikacja nie może odczytać',
      one: '1 wiersz ma kwotę, której aplikacja nie może odczytać',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wierszy nie dotyczy żadnej kwoty',
      many: '$count wierszy nie dotyczy żadnej kwoty',
      few: '$count wiersze nie dotyczą żadnej kwoty',
      one: '1 wiersz nie dotyczy żadnej kwoty',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wierszy jest już w aplikacji',
      many: '$count wierszy jest już w aplikacji',
      few: '$count wiersze są już w aplikacji',
      one: '1 wiersz jest już w aplikacji',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przelewów ma podane tylko jedno konto',
      many: '$count przelewów ma podane tylko jedno konto',
      few: '$count przelewy mają podane tylko jedno konto',
      one: '1 przelew ma podane tylko jedno konto',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Nie udało się odczytać daty';

  @override
  String get importRowUnreadableAmount => 'Nie udało się odczytać kwoty';

  @override
  String get importRowZero => 'Brak kwoty';

  @override
  String get importRowAlreadyThere => 'Już jest w aplikacji';

  @override
  String get importRowIncompleteTransfer => 'Podano tylko jedno konto';

  @override
  String get importNamesHeader => 'Nazwy, których nie ma w aplikacji';

  @override
  String get importNamesSubtitle =>
      'Wybierz, czym stanie się każda z nich. Import nigdy nie tworzy kategorii ani konta.';

  @override
  String get importRowsHeader =>
      'Pierwsze wiersze, tak jak odczytała je aplikacja';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'i jeszcze $count',
      one: 'i jeszcze 1',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importuj $count wierszy',
      many: 'Importuj $count wierszy',
      few: 'Importuj $count wiersze',
      one: 'Importuj 1 wiersz',
      zero: 'Nic do zaimportowania',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zaimportowano $count rekordów',
      many: 'Zaimportowano $count rekordów',
      few: 'Zaimportowano $count rekordy',
      one: 'Zaimportowano 1 rekord',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'Nie udało się zaimportować tego pliku. Nic nie zostało dodane.';

  @override
  String get attachmentsLabel => 'Załączniki';

  @override
  String get photoLabel => 'Zdjęcie';

  @override
  String get photoAdd => 'Dodaj zdjęcie';

  @override
  String get photoTake => 'Zrób zdjęcie';

  @override
  String get photoChoose => 'Wybierz zdjęcie';

  @override
  String get photoRemove => 'Usuń zdjęcie';

  @override
  String get photoMissing => 'Tego zdjęcia brakuje.';

  @override
  String get voiceNoteLabel => 'Notatka głosowa';

  @override
  String get voiceRecord => 'Nagraj notatkę głosową';

  @override
  String voiceRecording(int seconds) {
    return 'Nagrywanie, pozostało $seconds s';
  }

  @override
  String get voiceStop => 'Zatrzymaj';

  @override
  String get voicePlay => 'Odtwórz';

  @override
  String get voicePause => 'Wstrzymaj';

  @override
  String get voiceRemove => 'Usuń notatkę głosową';

  @override
  String get voiceMissing => 'Tej notatki głosowej brakuje.';

  @override
  String get microphoneRefused => 'Mikrofon jest wyłączony dla tej aplikacji.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Zawiera załączniki, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Ukrywa wszystkie reklamy za jedną opłatą. Jest powiązany z kontem sklepu, więc wraca po zmianie telefonu lub reinstalacji.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Usuń reklamy za $price';
  }

  @override
  String get removeAdsOwned => 'Reklamy są wyłączone. Dziękujemy.';

  @override
  String get removeAdsPending => 'Oczekiwanie na sklep…';

  @override
  String get removeAdsUnavailable =>
      'Sklep nie ma jeszcze nic do sprzedania. Spróbuj ponownie później.';

  @override
  String get removeAdsFailed =>
      'To się nie powiodło i nie zostałeś obciążony opłatą.';

  @override
  String get restorePurchasesButton => 'Przywróć zakupy';

  @override
  String get payNothingWithheld =>
      'Wszystkie funkcje pozostają darmowe, z reklamami czy bez.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Wkrótce';

  @override
  String get plusBody =>
      'Połączenie z bankiem, które pobiera Twoje transakcje do potwierdzenia. Nie jest gotowe, więc nie ma jeszcze czego kupować.';

  @override
  String get privacyOptionsTitle => 'Opcje prywatności';

  @override
  String get privacyOptionsSubtitle =>
      'Zmień ustawienia reklam spersonalizowanych';
}
