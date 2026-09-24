// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Настройки';

  @override
  String get transferTooltip => 'Перевод';

  @override
  String get searchTooltip => 'Поиск';

  @override
  String get addButton => 'Добавить';

  @override
  String get emptyPeriod => 'В этом периоде пока нет операций.';

  @override
  String get balanceLabel => 'Баланс';

  @override
  String get expandSummaryTooltip => 'Показать доходы и расходы';

  @override
  String get collapseSummaryTooltip => 'Показать только баланс';

  @override
  String get periodNetLabel => 'За этот период';

  @override
  String carriedForwardLine(String amount) {
    return 'Перенесено $amount';
  }

  @override
  String get incomeLabel => 'Доход';

  @override
  String get expenseLabel => 'Расход';

  @override
  String upcomingCategory(String category) {
    return '$category · Предстоящее';
  }

  @override
  String get upcomingLabel => 'Предстоящее';

  @override
  String detailAdded(String date) {
    return 'Добавлено $date';
  }

  @override
  String detailChanged(String date) {
    return 'Изменено $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пора провести $count повторяющихся операций',
      many: 'Пора провести $count повторяющихся операций',
      few: 'Пора провести $count повторяющиеся операции',
      one: 'Пора провести 1 повторяющуюся операцию',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: 'Потрачено $percent · $over превышено',
      many: 'Потрачено $percent · $over превышено',
      few: 'Потрачено $percent · $over превышено',
      one: 'Потрачено $percent · 1 превышен',
      zero: 'Потрачено $percent',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бюджетов задано',
      many: '$count бюджетов задано',
      few: '$count бюджета задано',
      one: '1 бюджет задан',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'Не удалось удалить операцию. Попробуйте ещё раз.';

  @override
  String get transactionDeleted => 'Операция удалена';

  @override
  String get transferDeleted => 'Перевод удалён';

  @override
  String get undoButton => 'Отменить';

  @override
  String get undoFailed => 'Не удалось отменить. Попробуйте ещё раз.';

  @override
  String get restoreFailed =>
      'Не удалось восстановить операцию. Попробуйте ещё раз.';

  @override
  String get restoreTransferFailed =>
      'Не удалось восстановить перевод. Попробуйте ещё раз.';

  @override
  String get addTransactionTitle => 'Новая операция';

  @override
  String get editTransactionTitle => 'Изменить операцию';

  @override
  String get transactionDetailTitle => 'Подробности';

  @override
  String get editTooltip => 'Изменить';

  @override
  String get deleteTooltip => 'Удалить';

  @override
  String get duplicateTooltip => 'Дублировать';

  @override
  String get rowMenuTooltip => 'Другие действия';

  @override
  String get deleteTransactionTitle => 'Удалить эту операцию?';

  @override
  String get deleteTransactionMessage =>
      'Она попадёт в корзину, откуда её можно вернуть в течение 30 дней.';

  @override
  String get discardChangesTitle => 'Отменить изменения?';

  @override
  String get discardChangesMessage => 'Введённое здесь не сохранено.';

  @override
  String get discardButton => 'Отменить';

  @override
  String get keepEditingButton => 'Продолжить';

  @override
  String get titleOptionalLabel => 'Заголовок (необязательно)';

  @override
  String get amountLabel => 'Сумма';

  @override
  String get amountRequired => 'Введите сумму';

  @override
  String get amountInvalid => 'Введите корректную сумму';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Стереть';

  @override
  String get hideKeypadTooltip => 'Скрыть клавиатуру';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get categoryRequired => 'Выберите категорию';

  @override
  String get accountLabel => 'Счёт';

  @override
  String get accountRequired => 'Выберите счёт';

  @override
  String get dateLabel => 'Дата';

  @override
  String get noteLabel => 'Заметка';

  @override
  String get previousDayTooltip => 'Предыдущий день';

  @override
  String get nextDayTooltip => 'Следующий день';

  @override
  String get noteOptionalLabel => 'Заметка (необязательно)';

  @override
  String get saveChangesButton => 'Сохранить изменения';

  @override
  String get addTransactionButton => 'Добавить операцию';

  @override
  String get saveAndAddAnotherButton => 'Сохранить и добавить ещё';

  @override
  String get transactionAdded => 'Операция добавлена';

  @override
  String get saveFailed => 'Не удалось сохранить операцию. Попробуйте ещё раз.';

  @override
  String get noExpensesInPeriod => 'В этом периоде пока нет расходов.';

  @override
  String totalSpent(String amount) {
    return 'Всего расходов: $amount';
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
  String get settingsTitle => 'Настройки';

  @override
  String get drawerAddHeader => 'Добавление';

  @override
  String get drawerAddExpense => 'Добавить расход';

  @override
  String get drawerAddIncome => 'Добавить доход';

  @override
  String get drawerPlanHeader => 'Планирование';

  @override
  String get drawerReviewHeader => 'Обзор';

  @override
  String get drawerSpending => 'Расходы по категориям';

  @override
  String get drawerManageHeader => 'Управление';

  @override
  String get drawerDataHeader => 'Данные';

  @override
  String get currencyLabel => 'Валюта';

  @override
  String get currencySearchHint => 'Поиск валют';

  @override
  String changeCurrencyTitle(String code) {
    return 'Сменить валюту на $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Суммы не изменятся, поменяется только обозначение валюты.';

  @override
  String get changeButton => 'Сменить';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get removeButton => 'Удалить';

  @override
  String get themeLabel => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get languageLabel => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get monthStartLabel => 'Первый день месяца';

  @override
  String get monthStartLastDay => 'Последний день';

  @override
  String get showCarriedForwardLabel => 'Переносить остаток';

  @override
  String get showCarriedForwardSubtitle =>
      'Каждый период начинается с остатка предыдущего';

  @override
  String get trashTitle => 'Корзина';

  @override
  String get trashEmpty => 'Корзина пуста.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'удалится навсегда через $days дней',
      many: 'удалится навсегда через $days дней',
      few: 'удалится навсегда через $days дня',
      one: 'удалится навсегда через 1 день',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Восстановить';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get addCategoryTooltip => 'Добавить категорию';

  @override
  String get addCategoryTitle => 'Добавить категорию';

  @override
  String get editCategoryTitle => 'Изменить категорию';

  @override
  String get categoryNameLabel => 'Название';

  @override
  String get categoryNameRequired => 'Введите название';

  @override
  String get categoryNameTaken => 'Это название уже используется';

  @override
  String get archiveAction => 'Архивировать';

  @override
  String get unarchiveAction => 'Вернуть из архива';

  @override
  String get deleteAction => 'Удалить';

  @override
  String get archivedHeader => 'В архиве';

  @override
  String get accountsTotalLabel => 'Итого';

  @override
  String get categorySaveFailed =>
      'Не удалось сохранить категорию. Попробуйте ещё раз.';

  @override
  String get accountsTitle => 'Счета';

  @override
  String get accountCash => 'Наличные';

  @override
  String get accountTypeLabel => 'Тип';

  @override
  String get accountTypeCash => 'Наличные';

  @override
  String get accountTypeBank => 'Банк';

  @override
  String get accountTypeCard => 'Карта';

  @override
  String get accountTypeOther => 'Другое';

  @override
  String get addAccountTooltip => 'Добавить счёт';

  @override
  String get addAccountTitle => 'Добавить счёт';

  @override
  String get editAccountTitle => 'Изменить счёт';

  @override
  String get openingBalanceLabel => 'Начальный баланс';

  @override
  String get openingDateLabel => 'Дата открытия';

  @override
  String get accountSaveFailed =>
      'Не удалось сохранить счёт. Попробуйте ещё раз.';

  @override
  String get transferTitle => 'Перевод';

  @override
  String get editTransferTitle => 'Изменить перевод';

  @override
  String get transferLabel => 'Перевод';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Откуда';

  @override
  String get toAccountLabel => 'Куда';

  @override
  String get sameAccountError => 'Выберите два разных счёта';

  @override
  String get needTwoAccounts =>
      'Добавьте второй счёт, чтобы переводить деньги между счетами.';

  @override
  String get addTransferButton => 'Добавить перевод';

  @override
  String get transferSaveFailed =>
      'Не удалось сохранить перевод. Попробуйте ещё раз.';

  @override
  String get searchHint => 'Поиск операций';

  @override
  String get allTypesFilter => 'Все';

  @override
  String get allCategoriesFilter => 'Все категории';

  @override
  String get allAccountsFilter => 'Все счета';

  @override
  String get allTimeFilter => 'За всё время';

  @override
  String get clearDatesTooltip => 'Сбросить даты';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count результатов',
      many: '$count результатов',
      few: '$count результата',
      one: '1 результат',
    );
    return '$_temp0 · Доход $income · Расход $expense';
  }

  @override
  String get noSearchResults => 'Подходящих операций не найдено.';

  @override
  String get budgetsTitle => 'Бюджеты';

  @override
  String get budgetsTooltip => 'Бюджеты';

  @override
  String get overallBudget => 'Общий';

  @override
  String get noBudget => 'Без бюджета';

  @override
  String budgetsHint(String period) {
    return 'Лимиты действуют с $period; в более ранних периодах — прежние.';
  }

  @override
  String get budgetLimitLabel => 'Лимит за период';

  @override
  String get budgetSaveFailed =>
      'Не удалось сохранить бюджет. Попробуйте ещё раз.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent из $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return 'Осталось $remaining · $perDay в день';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return 'Потрачено $amount · $perDay в день пока';
  }

  @override
  String get homeSetBudget => 'Задать месячный бюджет';

  @override
  String budgetLeft(String remaining) {
    return 'Осталось $remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Превышение на $amount';
  }

  @override
  String get budgetLimitReached => 'Лимит достигнут';

  @override
  String budgetLimitOnly(String limit) {
    return 'Лимит $limit';
  }

  @override
  String get recurringTitle => 'Повторяющиеся';

  @override
  String get addRecurringTooltip => 'Добавить повторение';

  @override
  String get addRecurringTitle => 'Добавить повторение';

  @override
  String get editRecurringTitle => 'Изменить повторение';

  @override
  String get dueHeader => 'К проведению';

  @override
  String get upcomingHeader => 'Ближайшие 30 дней';

  @override
  String get rulesHeader => 'Правила';

  @override
  String billsPerMonth(String amount) {
    return '$amount в месяц на счета';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Далее: $title, через $days дня',
      many: 'Далее: $title, через $days дней',
      few: 'Далее: $title, через $days дня',
      one: 'Далее: $title, завтра',
      zero: 'Далее: $title, сегодня',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'Ничего в ближайшие 30 дней.';

  @override
  String get noRules => 'Повторяющихся операций пока нет.';

  @override
  String get postButton => 'Провести';

  @override
  String get skipButton => 'Пропустить';

  @override
  String get postFailed => 'Не удалось провести операцию. Попробуйте ещё раз.';

  @override
  String get recurringSaveFailed =>
      'Не удалось сохранить повторяющуюся операцию. Попробуйте ещё раз.';

  @override
  String get everyLabel => 'Каждые';

  @override
  String get frequencyDays => 'Дни';

  @override
  String get frequencyWeeks => 'Недели';

  @override
  String get frequencyMonths => 'Месяцы';

  @override
  String get frequencyYears => 'Годы';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Каждые $count дней',
      many: 'Каждые $count дней',
      few: 'Каждые $count дня',
      one: 'Каждый день',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Каждые $count недель',
      many: 'Каждые $count недель',
      few: 'Каждые $count недели',
      one: 'Каждую неделю',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Каждые $count месяцев',
      many: 'Каждые $count месяцев',
      few: 'Каждые $count месяца',
      one: 'Каждый месяц',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Каждые $count лет',
      many: 'Каждые $count лет',
      few: 'Каждые $count года',
      one: 'Каждый год',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Приостановлено';
  }

  @override
  String get startsLabel => 'Начало';

  @override
  String get endsLabel => 'Конец';

  @override
  String get endNever => 'Никогда';

  @override
  String get endAfter => 'После';

  @override
  String get endOnDate => 'В дату';

  @override
  String get timesLabel => 'Раз';

  @override
  String get endsOnLabel => 'Дата окончания';

  @override
  String get wholeNumberInvalid => 'Введите целое число от 1';

  @override
  String get endDateInvalid => 'Дата окончания должна быть позже даты начала';

  @override
  String get autoPostLabel => 'Проводить автоматически';

  @override
  String get autoPostSubtitle => 'Иначе будет ждать в разделе «К проведению»';

  @override
  String get pauseTooltip => 'Приостановить';

  @override
  String get resumeTooltip => 'Возобновить';

  @override
  String get categoryFood => 'Еда';

  @override
  String get categoryGroceries => 'Продукты';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categoryShopping => 'Покупки';

  @override
  String get categoryBills => 'Платежи';

  @override
  String get categoryRent => 'Аренда';

  @override
  String get categoryHealth => 'Здоровье';

  @override
  String get categoryEducation => 'Образование';

  @override
  String get categoryEntertainment => 'Развлечения';

  @override
  String get categorySalary => 'Зарплата';

  @override
  String get categoryBusiness => 'Бизнес';

  @override
  String get categoryInvestment => 'Инвестиции';

  @override
  String get categoryGift => 'Подарки';

  @override
  String get categoryOther => 'Другое';

  @override
  String get previousPeriodTooltip => 'Предыдущий период';

  @override
  String get wholePeriodTooltip => 'Показать весь период';

  @override
  String get nextPeriodTooltip => 'Следующий период';

  @override
  String get insightsTooltip => 'Аналитика';

  @override
  String get insightsTitle => 'Аналитика';

  @override
  String get calendarTab => 'Календарь';

  @override
  String get trendTab => 'Динамика';

  @override
  String get noIncomeInPeriod => 'В этом периоде пока нет доходов.';

  @override
  String totalIncome(String amount) {
    return 'Всего доходов: $amount';
  }

  @override
  String get calendarHint => 'Нажмите на день, чтобы увидеть операции.';

  @override
  String get dayEmpty => 'В этот день ничего нет.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяцев',
      many: '$count месяцев',
      few: '$count месяца',
      one: '1 месяц',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Доход $income · Расход $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'В среднем за период · Доход $income · Расход $expense';
  }

  @override
  String get weekStartLabel => 'Первый день недели';

  @override
  String weekStartDefault(String day) {
    return 'По умолчанию ($day)';
  }

  @override
  String get firstRunTitle => 'Добро пожаловать в Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Учитывайте доходы и расходы. Данные хранятся только на этом устройстве.';

  @override
  String get addFirstTransactionButton => 'Добавить первую операцию';

  @override
  String get setupIntro =>
      'Выберите язык и валюту. Их можно будет изменить в настройках.';

  @override
  String get setupContinueButton => 'Продолжить';

  @override
  String get setupRestoreTitle => 'Восстановить из копии';

  @override
  String get setupRestoreSubtitle =>
      'Вернуть данные и настройки из файла резервной копии';

  @override
  String get walkthroughEntryTitle => 'Добавляйте за секунды';

  @override
  String get walkthroughEntryBody =>
      'Калькулятор для суммы, фото чека и голосовая заметка, если печатать некогда.';

  @override
  String get walkthroughPlanTitle => 'Планируйте месяц';

  @override
  String get walkthroughPlanBody =>
      'Бюджеты по категориям, платежи, которые повторяются сами, и заметки-напоминания.';

  @override
  String get walkthroughInsightsTitle => 'Смотрите, куда уходят деньги';

  @override
  String get walkthroughInsightsBody =>
      'Графики, календарь и отчёт в PDF или CSV за любой период.';

  @override
  String get walkthroughPrivacyTitle => 'Только ваше';

  @override
  String get walkthroughPrivacyBody =>
      'Без аккаунта. То, что вы записываете, остаётся на этом телефоне — реклама, которая оплачивает приложение, этого не видит.';

  @override
  String get walkthroughBringTitle => 'Перенесите то, что уже есть';

  @override
  String get walkthroughBringBody =>
      'Переходите из другого приложения или с другого телефона? Начните с резервной копии или CSV, а не с пустого приложения.';

  @override
  String get firstRunRestoreTitle => 'Восстановить эту копию?';

  @override
  String get firstRunRestoreMessage =>
      'Это заменит всё в приложении и вернёт язык и валюту, сохранённые в копии.';

  @override
  String get walkthroughNextButton => 'Далее';

  @override
  String get walkthroughStartButton => 'Начать';

  @override
  String get walkthroughDoneButton => 'Готово';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Страница $current из $total';
  }

  @override
  String get walkthroughReplayTitle => 'Показать введение снова';

  @override
  String get walkthroughReplaySubtitle =>
      'Четыре экрана, показанные при первом запуске';

  @override
  String get removeAdsTitle => 'Отключить рекламу';

  @override
  String get exportCsvMenu => 'Экспорт в CSV';

  @override
  String get exportCsvTooltip => 'Экспорт в CSV';

  @override
  String get csvExported => 'CSV сохранён';

  @override
  String get csvExportFailed =>
      'Не удалось экспортировать CSV. Попробуйте ещё раз.';

  @override
  String get backupTitle => 'Резервные копии';

  @override
  String get backupIntro =>
      'Резервная копия — это файл, который вы сохраняете сами. Ничего не отправляется автоматически.';

  @override
  String get backUpNowTitle => 'Создать копию сейчас';

  @override
  String lastBackupLine(String date) {
    return 'Последняя копия: $date';
  }

  @override
  String get neverBackedUp => 'Резервных копий ещё нет';

  @override
  String get backupSaved => 'Резервная копия сохранена';

  @override
  String get backupSaveFailed =>
      'Не удалось сохранить резервную копию. Попробуйте ещё раз.';

  @override
  String get restoreFromFileTitle => 'Восстановить из файла';

  @override
  String get restoreFromFileSubtitle =>
      'Объедините копию с текущими данными или замените их';

  @override
  String get backupReminderLabel => 'Напоминание о копии';

  @override
  String get backupReminderSubtitle => 'Каждые 30 дней, если операций уже 20';

  @override
  String get backupReminderNever =>
      'Сделайте резервную копию, чтобы не потерять данные';

  @override
  String backupReminderSince(String date) {
    return 'Последняя копия — $date. Пора сделать новую?';
  }

  @override
  String get notNowTooltip => 'Не сейчас';

  @override
  String get keptBackupsHeader => 'Автоматические копии';

  @override
  String get keptBackupsHint =>
      'Сохраняются на устройстве перед каждым восстановлением.';

  @override
  String get noKeptBackups => 'Пока нет.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count операций',
      many: '$count операций',
      few: '$count операции',
      one: '1 операция',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Восстановление копии';

  @override
  String get mergeOption => 'Объединить';

  @override
  String get mergeOptionSubtitle =>
      'Ваши данные сохранятся, а данные копии добавятся. Если запись есть в обоих местах, останется более новая версия.';

  @override
  String get replaceOption => 'Заменить';

  @override
  String get replaceOptionSubtitle =>
      'Текущие данные будут удалены, останутся только данные и настройки из копии.';

  @override
  String get restoreSafetyNote =>
      'Перед этим текущие данные будут сохранены в разделе «Автоматические копии».';

  @override
  String get restoreButton => 'Восстановить';

  @override
  String get restoreKeptTitle => 'Восстановить эту копию?';

  @override
  String restoreKeptMessage(String date) {
    return 'Текущие данные будут заменены копией от $date. Перед этим они будут сохранены.';
  }

  @override
  String get backupInvalid =>
      'Этот файл не является резервной копией Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Эта копия создана в более новой версии приложения. Обновите приложение и попробуйте снова.';

  @override
  String get backupOpenFailed => 'Не удалось открыть файл. Попробуйте ещё раз.';

  @override
  String get backupRestoreFailed =>
      'Не удалось восстановить копию. Ваши данные не изменились.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Восстановлено $count операций',
      many: 'Восстановлено $count операций',
      few: 'Восстановлено $count операции',
      one: 'Восстановлена 1 операция',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Объединено: добавлено $added, обновлено $updated, без изменений $unchanged';
  }

  @override
  String get appLockLabel => 'Блокировка приложения';

  @override
  String get appLockSubtitle =>
      'Разблокировка отпечатком, лицом или паролем устройства';

  @override
  String get appLockUnavailable =>
      'Настройте блокировку экрана устройства, чтобы использовать эту функцию';

  @override
  String get appLockReason => 'Разблокировать Monthly Expenses';

  @override
  String get appLockFailed =>
      'Не удалось подтвердить личность. Настройка блокировки не изменена.';

  @override
  String get lockedTitle => 'Monthly Expenses заблокировано';

  @override
  String get unlockButton => 'Разблокировать';

  @override
  String get widgetShowAmountsLabel => 'Показывать суммы в виджете';

  @override
  String get widgetShowAmountsSubtitle =>
      'Виджет скрывает их, пока включена блокировка приложения';

  @override
  String get widgetLeftLabel => 'Осталось';

  @override
  String get widgetAddExpense => 'Добавить расход';

  @override
  String get widgetAddIncome => 'Добавить доход';

  @override
  String get widgetAmountsHidden => 'Суммы скрыты блокировкой приложения';

  @override
  String get notesTitle => 'Заметки';

  @override
  String get addNoteTooltip => 'Добавить заметку';

  @override
  String get addNoteTitle => 'Добавить заметку';

  @override
  String get editNoteTitle => 'Изменить заметку';

  @override
  String get noteTextLabel => 'Заметка';

  @override
  String get noteTextRequired => 'Введите текст';

  @override
  String get noteAmountOptionalLabel => 'Сумма (необязательно)';

  @override
  String get noteDueDateToggle => 'Указать срок';

  @override
  String get noteDueDateLabel => 'Срок';

  @override
  String get noteReminderToggle => 'Напомнить';

  @override
  String get noteReminderTimeLabel => 'Время напоминания';

  @override
  String get noteReminderTimeUnset => 'Выберите время';

  @override
  String get noteCategoryOptionalLabel => 'Категория (необязательно)';

  @override
  String get noteCategoryNone => 'Нет';

  @override
  String get recordNoteButton => 'Записать как операцию';

  @override
  String get noteMarkDoneTooltip => 'Отметить выполненным';

  @override
  String get noteMarkOpenTooltip => 'Отметить невыполненным';

  @override
  String get notesEmptyTitle => 'Здесь пока пусто';

  @override
  String get notesEmptyMessage =>
      'Заметки напоминают о делах: с датой, суммой и категорией — по желанию.';

  @override
  String get addNoteButton => 'Добавить заметку';

  @override
  String get notesOpenHeader => 'Активные';

  @override
  String get notesDoneHeader => 'Выполненные';

  @override
  String get noteDeleted => 'Заметка удалена.';

  @override
  String get noteSaveFailed =>
      'Не удалось сохранить заметку. Попробуйте ещё раз.';

  @override
  String get noteDeleteFailed =>
      'Не удалось удалить заметку. Попробуйте ещё раз.';

  @override
  String get noteRestoreFailed =>
      'Не удалось восстановить заметку. Попробуйте ещё раз.';

  @override
  String get notesSearchHint => 'Поиск заметок';

  @override
  String get noteFilterAll => 'Все';

  @override
  String get noteFilterOverdue => 'Просроченные';

  @override
  String get noteFilterDueToday => 'Сегодня';

  @override
  String get noteFilterUpcoming => 'Предстоящие';

  @override
  String get noteFilterNoDate => 'Без даты';

  @override
  String get noNoteResults => 'Подходящих заметок не найдено.';

  @override
  String get noteLinkedTransactionLabel => 'Записано как операция';

  @override
  String get noteLinkedNoteLabel => 'Из заметки';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пора выполнить $count заметок',
      many: 'Пора выполнить $count заметок',
      few: 'Пора выполнить $count заметки',
      one: 'Пора выполнить 1 заметку',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Заметки на этот день';

  @override
  String get noteReminderTitle => 'Напоминание о заметке';

  @override
  String get noteReminderLockedTitle => 'Наступил срок заметки';

  @override
  String get noteReminderPermissionDenied =>
      'Включите уведомления в настройках системы, чтобы получать напоминания о заметках.';

  @override
  String reportRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String reportCreated(String when) {
    return 'Создан $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Страница $page из $pages';
  }

  @override
  String get reportNet => 'Итого';

  @override
  String get reportOpeningBalance => 'Начальный баланс';

  @override
  String get reportClosingBalance => 'Конечный баланс';

  @override
  String get reportSpendingHeader => 'Расходы по категориям';

  @override
  String get reportEarningHeader => 'Доходы по категориям';

  @override
  String get reportTrendHeader => 'Динамика';

  @override
  String get reportEntriesHeader => 'Операции';

  @override
  String get reportUpcomingHeader => 'Предстоящее';

  @override
  String get reportUpcomingNote =>
      'Датировано будущим числом, поэтому не учтено в итогах выше.';

  @override
  String get reportAmountColumn => 'Сумма';

  @override
  String get reportShareColumn => 'Доля';

  @override
  String get reportBudgetColumn => 'Бюджет';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used из $limit';
  }

  @override
  String get reportDetailsColumn => 'Подробности';

  @override
  String get reportEmpty => 'За эти даты нечего показать.';

  @override
  String get exportPdfMenu => 'Экспорт в PDF';

  @override
  String get reportTitle => 'Экспорт в PDF';

  @override
  String get reportNoFontTitle => 'Пока не на этом языке';

  @override
  String get reportNoFontBody =>
      'Отчёту нужен шрифт для его письменности, а китайский, японский и корейский слишком велики, чтобы носить их в приложении. В следующей версии их можно будет скачать.';

  @override
  String get reportPreviewTitle => 'Отчёт';

  @override
  String get reportCoversHeader => 'Что учитывается';

  @override
  String get reportRangePeriod => 'Текущий период';

  @override
  String get reportRangeCustom => 'Даты';

  @override
  String get reportRangeYear => 'Год';

  @override
  String get reportFromLabel => 'С';

  @override
  String get reportToLabel => 'По';

  @override
  String get reportYearLabel => 'Год';

  @override
  String get reportAccountLabel => 'Счёт';

  @override
  String get reportAllAccounts => 'Все счета';

  @override
  String get reportIncludeHeader => 'Что включить';

  @override
  String get reportIncludeSubtitle => 'Уберите то, чем не хотите делиться.';

  @override
  String get reportIncludeTransactions => 'Список операций';

  @override
  String get reportIncludeDetails => 'Заголовки и заметки';

  @override
  String get reportIncludeAccounts => 'Названия счетов';

  @override
  String get reportCreateButton => 'Создать отчёт';

  @override
  String get reportBuilding => 'Формирование отчёта';

  @override
  String get reportFailed => 'Не удалось создать отчёт. Попробуйте ещё раз.';

  @override
  String get reportRangeBackwards =>
      'Первая дата должна быть раньше последней.';

  @override
  String get importTitle => 'Импорт CSV';

  @override
  String get importSubtitle => 'Перенесите операции из другого приложения';

  @override
  String get importIntro =>
      'Выберите файл CSV — сначала вы увидите, как приложение его распознало, и только потом данные добавятся. Импорт только добавляет записи и никогда не заменяет и не удаляет то, что уже есть.';

  @override
  String get importChooseFile => 'Выбрать файл';

  @override
  String get importChooseAnother => 'Выбрать другой файл';

  @override
  String get importReadFailed =>
      'Не удалось прочитать файл. Попробуйте ещё раз.';

  @override
  String get importRefusedEmpty => 'В этом файле ничего нет.';

  @override
  String get importRefusedNoDate =>
      'Ни один столбец файла не удалось распознать как дату, поэтому импорт невозможен.';

  @override
  String get importRefusedNoAmount =>
      'Ни один столбец файла не удалось распознать как сумму, поэтому импорт невозможен.';

  @override
  String get importRefusedNoRows =>
      'Ни одну строку файла не удалось распознать, импортировать нечего.';

  @override
  String get importColumnsHeader => 'Столбцы';

  @override
  String get importColumnsSubtitle =>
      'Исправьте то, что приложение распознало неверно.';

  @override
  String get importColumnNone => 'Не используется';

  @override
  String get importFieldType => 'Тип';

  @override
  String get importFieldToAccount => 'Счёт назначения';

  @override
  String get importFieldTitle => 'Заголовок';

  @override
  String get importFieldNote => 'Заметка';

  @override
  String get importDateOrderLabel => 'Дата вида 03/04 означает';

  @override
  String get importDayFirst => 'Сначала день';

  @override
  String get importMonthFirst => 'Сначала месяц';

  @override
  String get importCountsHeader => 'Что произойдёт';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count строк',
      many: 'Импортировано $count строк',
      few: 'Импортировано $count строки',
      one: 'Импортирована 1 строка',
      zero: 'Ничего не будет импортировано',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count строк — дата не распознана',
      many: '$count строк — дата не распознана',
      few: '$count строки — дата не распознана',
      one: '1 строка — дата не распознана',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count строк — сумма не распознана',
      many: '$count строк — сумма не распознана',
      few: '$count строки — сумма не распознана',
      one: '1 строка — сумма не распознана',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count строк — без суммы',
      many: '$count строк — без суммы',
      few: '$count строки — без суммы',
      one: '1 строка — без суммы',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count строк уже есть в приложении',
      many: '$count строк уже есть в приложении',
      few: '$count строки уже есть в приложении',
      one: '1 строка уже есть в приложении',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count переводов указывают только один счёт',
      many: '$count переводов указывают только один счёт',
      few: '$count перевода указывают только один счёт',
      one: '1 перевод указывает только один счёт',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Дата не распознана';

  @override
  String get importRowUnreadableAmount => 'Сумма не распознана';

  @override
  String get importRowZero => 'Без суммы';

  @override
  String get importRowAlreadyThere => 'Уже есть в приложении';

  @override
  String get importRowIncompleteTransfer => 'Указан только один счёт';

  @override
  String get importNamesHeader => 'Незнакомые названия';

  @override
  String get importNamesSubtitle =>
      'Укажите, чем станет каждое. Импорт не создаёт категории и счета.';

  @override
  String get importRowsHeader => 'Первые строки, как их распознало приложение';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'и ещё $count строк',
      many: 'и ещё $count строк',
      few: 'и ещё $count строки',
      one: 'и ещё 1 строка',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировать $count строк',
      many: 'Импортировать $count строк',
      few: 'Импортировать $count строки',
      one: 'Импортировать 1 строку',
      zero: 'Нечего импортировать',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count записей',
      many: 'Импортировано $count записей',
      few: 'Импортировано $count записи',
      one: 'Импортирована 1 запись',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'Не удалось импортировать файл. Ничего не добавлено.';

  @override
  String get attachmentsLabel => 'Вложения';

  @override
  String get photoLabel => 'Фото';

  @override
  String get photoAdd => 'Добавить фото';

  @override
  String get photoTake => 'Сделать фото';

  @override
  String get photoChoose => 'Выбрать фото';

  @override
  String get photoRemove => 'Удалить фото';

  @override
  String get photoMissing => 'Это фото отсутствует.';

  @override
  String get voiceNoteLabel => 'Голосовая заметка';

  @override
  String get voiceRecord => 'Записать голосовую заметку';

  @override
  String voiceRecording(int seconds) {
    return 'Запись, осталось $seconds сек';
  }

  @override
  String get voiceStop => 'Остановить';

  @override
  String get voicePlay => 'Воспроизвести';

  @override
  String get voicePause => 'Пауза';

  @override
  String get voiceRemove => 'Удалить голосовую заметку';

  @override
  String get voiceMissing => 'Эта голосовая заметка отсутствует.';

  @override
  String get microphoneRefused => 'Микрофон отключён для этого приложения.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Включает вложения, $size МБ';
  }

  @override
  String get removeAdsBody =>
      'Скрывает всю рекламу за один платёж. Привязано к аккаунту в магазине, поэтому вернётся при смене телефона или переустановке.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Отключить рекламу за $price';
  }

  @override
  String get removeAdsOwned => 'Реклама отключена. Спасибо.';

  @override
  String get removeAdsPending => 'Ожидание ответа магазина…';

  @override
  String get removeAdsUnavailable =>
      'В магазине пока нечего купить. Повторите попытку позже.';

  @override
  String get removeAdsFailed =>
      'Операция не выполнена, деньги с вас не списаны.';

  @override
  String get restorePurchasesButton => 'Восстановить покупки';

  @override
  String get payNothingWithheld =>
      'Все функции остаются бесплатными, с рекламой или без неё.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Скоро';

  @override
  String get plusBody =>
      'Подключение к банку, которое само добавляет операции для подтверждения. Пока не готово, покупать нечего.';

  @override
  String get privacyOptionsTitle => 'Настройки конфиденциальности';

  @override
  String get privacyOptionsSubtitle =>
      'Изменить настройки персонализированной рекламы';

  @override
  String get dueEntryReminderTitle => 'Наступил срок записи';

  @override
  String dueEntryReminderOne(String title) {
    return 'Срок $title наступил сегодня, и запись всё ещё ждёт.';
  }

  @override
  String get dueEntryReminderUntitled =>
      'Срок повторяющейся записи наступил сегодня, и она всё ещё ждёт.';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count повторяющихся записей сегодня срок.',
      many: 'У $count повторяющихся записей сегодня срок.',
      few: 'У $count повторяющихся записей сегодня срок.',
      one: 'У 1 повторяющейся записи сегодня срок.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'Сегодня ничего не записано';

  @override
  String get emptyDayReminderBody =>
      'Добавьте расходы, пока ещё помните о них.';

  @override
  String get reminderLockedTitle => 'Кое-что ждёт';

  @override
  String get nudgeSettingsTitle => 'Напоминать в пустой день';

  @override
  String get nudgeSettingsSubtitle =>
      'Одно напоминание вечером, только в день без записей.';

  @override
  String get nudgeOfferTitle => 'Напоминание в дни, когда забываете?';

  @override
  String get nudgeOfferBody =>
      'Одно напоминание в выбранное время, только в день без записей. Можно отключить в любой момент.';

  @override
  String get nudgeOfferYes => 'Да, напоминайте';

  @override
  String get nudgeOfferNo => 'Нет';

  @override
  String get nudgeStoppedNotice =>
      'Напоминания остановлены после трёх без ответа. Включите их снова, когда захотите.';

  @override
  String get nudgePermissionDenied =>
      'Включите уведомления в настройках системы.';
}
