// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Configurações';

  @override
  String get transferTooltip => 'Transferência';

  @override
  String get searchTooltip => 'Buscar';

  @override
  String get addButton => 'Adicionar';

  @override
  String get emptyPeriod => 'Ainda não há transações neste período.';

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get expandSummaryTooltip => 'Mostrar receitas e despesas';

  @override
  String get collapseSummaryTooltip => 'Mostrar só o saldo';

  @override
  String get periodNetLabel => 'Este período';

  @override
  String carriedForwardLine(String amount) {
    return 'Transportado $amount';
  }

  @override
  String get incomeLabel => 'Receita';

  @override
  String get expenseLabel => 'Despesa';

  @override
  String upcomingCategory(String category) {
    return '$category · Futura';
  }

  @override
  String get upcomingLabel => 'Futura';

  @override
  String detailAdded(String date) {
    return 'Adicionada em $date';
  }

  @override
  String detailChanged(String date) {
    return 'Última alteração em $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transações recorrentes pendentes',
      one: '1 transação recorrente pendente',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent usado · $over acima do limite',
      one: '$percent usado · 1 acima do limite',
      zero: '$percent usado',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orçamentos definidos',
      one: '1 orçamento definido',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed =>
      'Não foi possível excluir a transação. Tente novamente.';

  @override
  String get transactionDeleted => 'Transação excluída';

  @override
  String get transferDeleted => 'Transferência excluída';

  @override
  String get undoButton => 'Desfazer';

  @override
  String get undoFailed => 'Não foi possível desfazer. Tente novamente.';

  @override
  String get restoreFailed =>
      'Não foi possível restaurar a transação. Tente novamente.';

  @override
  String get restoreTransferFailed =>
      'Não foi possível restaurar a transferência. Tente de novo.';

  @override
  String get addTransactionTitle => 'Adicionar transação';

  @override
  String get editTransactionTitle => 'Editar transação';

  @override
  String get transactionDetailTitle => 'Detalhes';

  @override
  String get editTooltip => 'Editar';

  @override
  String get deleteTooltip => 'Excluir';

  @override
  String get duplicateTooltip => 'Duplicar';

  @override
  String get rowMenuTooltip => 'Mais ações';

  @override
  String get deleteTransactionTitle => 'Excluir esta transação?';

  @override
  String get deleteTransactionMessage =>
      'Vai para a lixeira e pode ser restaurada por 30 dias.';

  @override
  String get discardChangesTitle => 'Descartar alterações?';

  @override
  String get discardChangesMessage => 'O que você digitou aqui não foi salvo.';

  @override
  String get discardButton => 'Descartar';

  @override
  String get keepEditingButton => 'Continuar editando';

  @override
  String get titleOptionalLabel => 'Título (opcional)';

  @override
  String get amountLabel => 'Valor';

  @override
  String get amountRequired => 'Informe um valor';

  @override
  String get amountInvalid => 'Informe um valor válido';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Apagar';

  @override
  String get hideKeypadTooltip => 'Ocultar teclado';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get categoryRequired => 'Escolha uma categoria';

  @override
  String get accountLabel => 'Conta';

  @override
  String get accountRequired => 'Escolha uma conta';

  @override
  String get dateLabel => 'Data';

  @override
  String get noteLabel => 'Nota';

  @override
  String get previousDayTooltip => 'Dia anterior';

  @override
  String get nextDayTooltip => 'Próximo dia';

  @override
  String get noteOptionalLabel => 'Nota (opcional)';

  @override
  String get saveChangesButton => 'Salvar alterações';

  @override
  String get addTransactionButton => 'Adicionar transação';

  @override
  String get saveAndAddAnotherButton => 'Salvar e adicionar outra';

  @override
  String get transactionAdded => 'Transação adicionada';

  @override
  String get saveFailed =>
      'Não foi possível salvar a transação. Tente novamente.';

  @override
  String get noExpensesInPeriod => 'Ainda não há despesas neste período.';

  @override
  String totalSpent(String amount) {
    return 'Total gasto: $amount';
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
  String get settingsTitle => 'Configurações';

  @override
  String get drawerAddHeader => 'Adicionar';

  @override
  String get drawerAddExpense => 'Adicionar despesa';

  @override
  String get drawerAddIncome => 'Adicionar receita';

  @override
  String get drawerPlanHeader => 'Planejar';

  @override
  String get drawerReviewHeader => 'Revisar';

  @override
  String get drawerSpending => 'Gastos por categoria';

  @override
  String get drawerManageHeader => 'Gerenciar';

  @override
  String get drawerDataHeader => 'Dados';

  @override
  String get currencyLabel => 'Moeda';

  @override
  String get currencySearchHint => 'Buscar moedas';

  @override
  String changeCurrencyTitle(String code) {
    return 'Mudar a moeda para $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Os valores continuam os mesmos; só muda o rótulo da moeda.';

  @override
  String get changeButton => 'Mudar';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Salvar';

  @override
  String get removeButton => 'Remover';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeBlack => 'Preto';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get monthStartLabel => 'Primeiro dia do mês';

  @override
  String get monthStartLastDay => 'Último dia';

  @override
  String get showCarriedForwardLabel => 'Transportar saldo';

  @override
  String get showCarriedForwardSubtitle =>
      'Cada período começa com o saldo anterior';

  @override
  String get trashTitle => 'Lixeira';

  @override
  String get trashEmpty => 'A lixeira está vazia.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'exclusão definitiva em $days dias',
      one: 'exclusão definitiva em 1 dia',
    );
    return '$amount · $_temp0';
  }

  @override
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'exclusão definitiva em $days dias',
      one: 'exclusão definitiva em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get restoreTooltip => 'Restaurar';

  @override
  String get categoriesTitle => 'Categorias';

  @override
  String get addCategoryTooltip => 'Adicionar categoria';

  @override
  String get addCategoryTitle => 'Adicionar categoria';

  @override
  String get editCategoryTitle => 'Editar categoria';

  @override
  String get categoryNameLabel => 'Nome';

  @override
  String get categoryNameRequired => 'Informe um nome';

  @override
  String get categoryNameTaken => 'Esse nome já está em uso';

  @override
  String get archiveAction => 'Arquivar';

  @override
  String get unarchiveAction => 'Desarquivar';

  @override
  String get deleteAction => 'Excluir';

  @override
  String get archivedHeader => 'Arquivadas';

  @override
  String get accountsTotalLabel => 'Total';

  @override
  String get categorySaveFailed =>
      'Não foi possível salvar a categoria. Tente novamente.';

  @override
  String get accountsTitle => 'Contas';

  @override
  String get accountCash => 'Dinheiro';

  @override
  String get accountTypeLabel => 'Tipo';

  @override
  String get accountTypeCash => 'Dinheiro';

  @override
  String get accountTypeBank => 'Banco';

  @override
  String get accountTypeCard => 'Cartão';

  @override
  String get accountTypeOther => 'Outro';

  @override
  String get addAccountTooltip => 'Adicionar conta';

  @override
  String get addAccountTitle => 'Adicionar conta';

  @override
  String get editAccountTitle => 'Editar conta';

  @override
  String get openingBalanceLabel => 'Saldo inicial';

  @override
  String get openingDateLabel => 'Data de abertura';

  @override
  String get accountSaveFailed =>
      'Não foi possível salvar a conta. Tente novamente.';

  @override
  String get transferTitle => 'Transferência';

  @override
  String get editTransferTitle => 'Editar transferência';

  @override
  String get transferLabel => 'Transferência';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'De';

  @override
  String get toAccountLabel => 'Para';

  @override
  String get sameAccountError => 'Escolha duas contas diferentes';

  @override
  String get needTwoAccounts =>
      'Adicione uma segunda conta para transferir dinheiro entre contas.';

  @override
  String get addTransferButton => 'Adicionar transferência';

  @override
  String get transferSaveFailed =>
      'Não foi possível salvar a transferência. Tente novamente.';

  @override
  String get searchHint => 'Buscar transações';

  @override
  String get allTypesFilter => 'Todos';

  @override
  String get allCategoriesFilter => 'Todas as categorias';

  @override
  String get allAccountsFilter => 'Todas as contas';

  @override
  String get allTimeFilter => 'Todo o período';

  @override
  String get clearDatesTooltip => 'Limpar datas';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0 · Receita $income · Despesa $expense';
  }

  @override
  String get noSearchResults => 'Nenhuma transação encontrada.';

  @override
  String get budgetsTitle => 'Orçamentos';

  @override
  String get budgetsTooltip => 'Orçamentos';

  @override
  String get overallBudget => 'Geral';

  @override
  String get noBudget => 'Sem orçamento';

  @override
  String budgetsHint(String period) {
    return 'Os limites valem a partir de $period; períodos anteriores mantêm os seus.';
  }

  @override
  String get budgetLimitLabel => 'Limite por período';

  @override
  String get budgetSaveFailed =>
      'Não foi possível salvar o orçamento. Tente novamente.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent de $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining restante · $perDay por dia';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return '$amount gastos · $perDay por dia até agora';
  }

  @override
  String get homeSetBudget => 'Definir orçamento mensal';

  @override
  String budgetLeft(String remaining) {
    return '$remaining restante';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Excedeu em $amount';
  }

  @override
  String get budgetLimitReached => 'Limite atingido';

  @override
  String budgetLimitOnly(String limit) {
    return 'Limite $limit';
  }

  @override
  String get recurringTitle => 'Recorrentes';

  @override
  String get addRecurringTooltip => 'Adicionar recorrente';

  @override
  String get addRecurringTitle => 'Adicionar recorrente';

  @override
  String get editRecurringTitle => 'Editar recorrente';

  @override
  String get dueHeader => 'Pendentes';

  @override
  String get upcomingHeader => 'Próximos 30 dias';

  @override
  String get rulesHeader => 'Regras';

  @override
  String billsPerMonth(String amount) {
    return '$amount por mês em contas';
  }

  @override
  String nextBillToday(String title) {
    return 'Próxima: $title, hoje';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'Próxima: $title, amanhã';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Próxima: $title, em $days dias',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'Nada nos próximos 30 dias.';

  @override
  String get noRules => 'Ainda não há transações recorrentes.';

  @override
  String get recurringEmptyMessage =>
      'As transações recorrentes lançam aluguel, salário ou uma assinatura na agenda que você define, e aguardam um toque para confirmar cada uma.';

  @override
  String get addRecurringButton => 'Adicionar transação recorrente';

  @override
  String get postButton => 'Lançar';

  @override
  String get skipButton => 'Pular';

  @override
  String get postFailed =>
      'Não foi possível lançar a transação. Tente novamente.';

  @override
  String get recurringSaveFailed =>
      'Não foi possível salvar a transação recorrente. Tente novamente.';

  @override
  String get recurringDeleted => 'Transação recorrente excluída';

  @override
  String get everyLabel => 'A cada';

  @override
  String get frequencyDays => 'Dias';

  @override
  String get frequencyWeeks => 'Semanas';

  @override
  String get frequencyMonths => 'Meses';

  @override
  String get frequencyYears => 'Anos';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count dias',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'Todo dia';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count semanas',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'Toda semana';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count meses',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'Todo mês';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A cada $count anos',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'Todo ano';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Pausada';
  }

  @override
  String get startsLabel => 'Início';

  @override
  String get endsLabel => 'Fim';

  @override
  String get endNever => 'Nunca';

  @override
  String get endAfter => 'Após';

  @override
  String get endOnDate => 'Numa data';

  @override
  String get timesLabel => 'Vezes';

  @override
  String get endsOnLabel => 'Termina em';

  @override
  String get wholeNumberInvalid => 'Informe um número inteiro a partir de 1';

  @override
  String wholeNumberRange(int max) {
    return 'Digite um número inteiro de 1 a $max';
  }

  @override
  String get endDateInvalid => 'A data final deve ser depois da inicial';

  @override
  String get autoPostLabel => 'Lançar automaticamente';

  @override
  String get autoPostSubtitle =>
      'Caso contrário, fica em Pendentes até você tocar';

  @override
  String get pauseTooltip => 'Pausar';

  @override
  String get resumeTooltip => 'Retomar';

  @override
  String get categoryFood => 'Alimentação';

  @override
  String get categoryGroceries => 'Mercado';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryBills => 'Contas';

  @override
  String get categoryRent => 'Aluguel';

  @override
  String get categoryHealth => 'Saúde';

  @override
  String get categoryEducation => 'Educação';

  @override
  String get categoryEntertainment => 'Entretenimento';

  @override
  String get categorySalary => 'Salário';

  @override
  String get categoryBusiness => 'Negócios';

  @override
  String get categoryInvestment => 'Investimento';

  @override
  String get categoryGift => 'Presente';

  @override
  String get categoryOther => 'Outro';

  @override
  String get previousPeriodTooltip => 'Período anterior';

  @override
  String get wholePeriodTooltip => 'Mostrar todo o período';

  @override
  String get nextPeriodTooltip => 'Próximo período';

  @override
  String get insightsTooltip => 'Análises';

  @override
  String get insightsTitle => 'Análises';

  @override
  String get calendarTab => 'Calendário';

  @override
  String get trendTab => 'Tendência';

  @override
  String get noIncomeInPeriod => 'Ainda não há receitas neste período.';

  @override
  String totalIncome(String amount) {
    return 'Total de receitas: $amount';
  }

  @override
  String comparedMore(String amount) {
    return '$amount a mais que no mês passado';
  }

  @override
  String comparedLess(String amount) {
    return '$amount a menos que no mês passado';
  }

  @override
  String get comparedSame => 'Igual ao mês passado';

  @override
  String get categoryNewLabel => 'novo';

  @override
  String get calendarHint => 'Toque em um dia para ver suas transações.';

  @override
  String get dayEmpty => 'Nada neste dia.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mês',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Receita $income · Despesa $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Média por período · Receita $income · Despesa $expense';
  }

  @override
  String get trendNeedsMorePeriods =>
      'Uma tendência precisa de mais de um período. Volte no próximo mês.';

  @override
  String get weekStartLabel => 'Primeiro dia da semana';

  @override
  String weekStartDefault(String day) {
    return 'Padrão ($day)';
  }

  @override
  String get firstRunTitle => 'Bem-vindo ao Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Registre o que você gasta e ganha. Seus dados ficam neste aparelho.';

  @override
  String get addFirstTransactionButton => 'Adicionar sua primeira transação';

  @override
  String get setupIntro =>
      'Escolha seu idioma e moeda. Você pode mudá-los depois em Configurações.';

  @override
  String get setupContinueButton => 'Continuar';

  @override
  String get setupRestoreTitle => 'Restaurar um backup';

  @override
  String get setupRestoreSubtitle =>
      'Traga de volta seus dados e configurações de um arquivo de backup';

  @override
  String get walkthroughEntryTitle => 'Registre em segundos';

  @override
  String get walkthroughEntryBody =>
      'Um teclado que soma, uma foto do recibo e uma nota de voz para quando digitar for mais lento.';

  @override
  String get walkthroughPlanTitle => 'Planeje o mês';

  @override
  String get walkthroughPlanBody =>
      'Orçamentos por categoria, contas que se repetem sozinhas e notas para te lembrar.';

  @override
  String get walkthroughInsightsTitle => 'Veja para onde vai';

  @override
  String get walkthroughInsightsBody =>
      'Gráficos, um calendário e um relatório em PDF ou CSV de qualquer período.';

  @override
  String get walkthroughPrivacyTitle => 'Só seu';

  @override
  String get walkthroughPrivacyBody =>
      'Sem conta. O que você registra fica neste telefone; os anúncios que sustentam o app nunca veem isso.';

  @override
  String get walkthroughBringTitle => 'Traga o que você já tem';

  @override
  String get walkthroughBringBody =>
      'Vindo de outro aplicativo ou celular? Comece a partir de um backup ou CSV em vez de um app vazio.';

  @override
  String get firstRunRestoreTitle => 'Restaurar este backup?';

  @override
  String get firstRunRestoreMessage =>
      'Isso substitui tudo no aplicativo e traz de volta o idioma e a moeda salvos nele.';

  @override
  String get walkthroughNextButton => 'Próximo';

  @override
  String get walkthroughStartButton => 'Começar';

  @override
  String get walkthroughDoneButton => 'Concluir';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get walkthroughReplayTitle => 'Rever a introdução';

  @override
  String get walkthroughReplaySubtitle =>
      'As quatro páginas mostradas na primeira abertura do app';

  @override
  String get removeAdsTitle => 'Remover anúncios';

  @override
  String get exportCsvMenu => 'Exportar CSV';

  @override
  String get exportCsvTooltip => 'Exportar CSV';

  @override
  String get csvExported => 'CSV salvo';

  @override
  String get csvExportFailed =>
      'Não foi possível exportar o CSV. Tente novamente.';

  @override
  String get backupTitle => 'Backup e restauração';

  @override
  String get backupIntro =>
      'Backups são arquivos salvos onde você escolher. Nada é enviado automaticamente.';

  @override
  String get backUpNowTitle => 'Fazer backup agora';

  @override
  String lastBackupLine(String date) {
    return 'Último backup em $date';
  }

  @override
  String get neverBackedUp => 'Ainda sem backup';

  @override
  String get backupSaved => 'Backup salvo';

  @override
  String get backupSaveFailed =>
      'Não foi possível salvar o backup. Tente novamente.';

  @override
  String get restoreFromFileTitle => 'Restaurar de um arquivo';

  @override
  String get restoreFromFileSubtitle =>
      'Mescle um backup aos seus dados ou substitua seus dados por ele';

  @override
  String get backupReminderLabel => 'Lembrete de backup';

  @override
  String get backupReminderSubtitle =>
      'A cada 30 dias, quando você tiver 20 transações';

  @override
  String get backupReminderNever =>
      'Faça backup dos seus dados para mantê-los seguros';

  @override
  String backupReminderSince(String date) {
    return 'Último backup em $date. Hora de fazer outro?';
  }

  @override
  String get notNowTooltip => 'Agora não';

  @override
  String get keptBackupsHeader => 'Backups automáticos';

  @override
  String get keptBackupsHint =>
      'Salvos neste aparelho antes de cada restauração.';

  @override
  String get noKeptBackups => 'Nenhum ainda.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transações',
      one: '1 transação',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Restaurar backup';

  @override
  String get mergeOption => 'Mesclar';

  @override
  String get mergeOptionSubtitle =>
      'Mantenha seus dados e adicione os do backup. Onde os dois têm o mesmo registro, vale a alteração mais recente.';

  @override
  String get replaceOption => 'Substituir';

  @override
  String get replaceOptionSubtitle =>
      'Exclua seus dados e use somente o backup, com as configurações dele.';

  @override
  String get restoreSafetyNote =>
      'Uma cópia dos seus dados atuais é salva antes em Backups automáticos.';

  @override
  String get restoreButton => 'Restaurar';

  @override
  String get restoreKeptTitle => 'Restaurar esta cópia?';

  @override
  String restoreKeptMessage(String date) {
    return 'Seus dados são substituídos pela cópia de $date. Uma cópia dos seus dados atuais é salva antes.';
  }

  @override
  String get backupInvalid =>
      'Este arquivo não é um backup do Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Este backup é de uma versão mais nova do app. Atualize o app e tente de novo.';

  @override
  String get backupOpenFailed =>
      'Não foi possível abrir o arquivo. Tente novamente.';

  @override
  String get backupRestoreFailed =>
      'Não foi possível restaurar o backup. Seus dados não foram alterados.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transações restauradas',
      one: '1 transação restaurada',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Mesclado: $added adicionadas, $updated atualizadas, $unchanged sem alteração';
  }

  @override
  String get appLockLabel => 'Bloqueio do app';

  @override
  String get appLockSubtitle =>
      'Desbloqueie com sua digital, rosto ou bloqueio de tela';

  @override
  String get appLockUnavailable =>
      'Configure um bloqueio de tela neste aparelho para usar o bloqueio do app';

  @override
  String get appLockReason => 'Desbloquear o Monthly Expenses';

  @override
  String get appLockFailed =>
      'Não foi possível confirmar que é você. O bloqueio do app não foi alterado.';

  @override
  String get lockedTitle => 'O Monthly Expenses está bloqueado';

  @override
  String get unlockButton => 'Desbloquear';

  @override
  String get widgetShowAmountsLabel => 'Mostrar valores no widget';

  @override
  String get widgetShowAmountsSubtitle =>
      'O widget da tela inicial os oculta enquanto o bloqueio do app está ativado';

  @override
  String get widgetLeftLabel => 'Restante';

  @override
  String get widgetAddExpense => 'Adicionar despesa';

  @override
  String get widgetAddIncome => 'Adicionar receita';

  @override
  String get widgetAmountsHidden =>
      'Os valores estão ocultos pelo bloqueio do app';

  @override
  String get notesTitle => 'Notas';

  @override
  String get addNoteTooltip => 'Adicionar nota';

  @override
  String get addNoteTitle => 'Adicionar nota';

  @override
  String get editNoteTitle => 'Editar nota';

  @override
  String get noteTextLabel => 'Nota';

  @override
  String get noteTextRequired => 'Digite um texto';

  @override
  String get noteAmountOptionalLabel => 'Valor (opcional)';

  @override
  String get noteDueDateToggle => 'Definir data de vencimento';

  @override
  String get noteDueDateLabel => 'Data de vencimento';

  @override
  String get noteReminderToggle => 'Lembrar-me';

  @override
  String get noteReminderTimeLabel => 'Horário do lembrete';

  @override
  String get noteReminderTimeUnset => 'Escolha um horário';

  @override
  String get reminderMayBeLate =>
      'Seu telefone pode atrasar isso alguns minutos.';

  @override
  String get noteCategoryOptionalLabel => 'Categoria (opcional)';

  @override
  String get noteCategoryNone => 'Nenhuma';

  @override
  String get recordNoteButton => 'Registrar como transação';

  @override
  String get noteMarkDoneTooltip => 'Marcar como concluída';

  @override
  String get noteMarkOpenTooltip => 'Marcar como aberta';

  @override
  String get notesEmptyTitle => 'Nada por aqui ainda';

  @override
  String get notesEmptyMessage =>
      'Notas lembram coisas para fazer ou conferir, com data, valor e categoria opcionais.';

  @override
  String get addNoteButton => 'Adicionar uma nota';

  @override
  String get notesOpenHeader => 'Abertas';

  @override
  String get notesDoneHeader => 'Concluídas';

  @override
  String get noteDeleted => 'Nota excluída.';

  @override
  String get noteSaveFailed =>
      'Não foi possível salvar a nota. Tente novamente.';

  @override
  String get noteDeleteFailed =>
      'Não foi possível excluir a nota. Tente novamente.';

  @override
  String get noteRestoreFailed =>
      'Não foi possível restaurar a nota. Tente novamente.';

  @override
  String get notesSearchHint => 'Buscar notas';

  @override
  String get noteFilterAll => 'Todas';

  @override
  String get noteFilterOverdue => 'Atrasadas';

  @override
  String get noteFilterDueToday => 'Vencem hoje';

  @override
  String get noteFilterUpcoming => 'Futuras';

  @override
  String get noteFilterNoDate => 'Sem data';

  @override
  String get noNoteResults => 'Nenhuma nota encontrada.';

  @override
  String get noteLinkedTransactionLabel => 'Registrada como transação';

  @override
  String get noteLinkedNoteLabel => 'De uma nota';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas venceram',
      one: '1 nota venceu',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Notas vencidas';

  @override
  String get noteReminderTitle => 'Lembrete de nota';

  @override
  String get noteReminderLockedTitle => 'Uma nota venceu';

  @override
  String get noteReminderPermissionDenied =>
      'Ative as notificações nas configurações do sistema para receber lembretes de notas.';

  @override
  String reportRange(String from, String to) {
    return '$from a $to';
  }

  @override
  String reportCreated(String when) {
    return 'Criado em $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Página $page de $pages';
  }

  @override
  String get reportNet => 'Líquido';

  @override
  String get reportOpeningBalance => 'Saldo inicial';

  @override
  String get reportClosingBalance => 'Saldo final';

  @override
  String get reportSpendingHeader => 'Gastos por categoria';

  @override
  String get reportEarningHeader => 'Receitas por categoria';

  @override
  String get reportTrendHeader => 'Tendência';

  @override
  String get reportEntriesHeader => 'Transações';

  @override
  String get reportUpcomingHeader => 'Futuras';

  @override
  String get reportUpcomingNote =>
      'Com data futura, por isso não entram nos totais acima.';

  @override
  String get reportAmountColumn => 'Valor';

  @override
  String get reportShareColumn => 'Participação';

  @override
  String get reportBudgetColumn => 'Orçamento';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used de $limit';
  }

  @override
  String get reportDetailsColumn => 'Detalhes';

  @override
  String get reportEmpty => 'Nada para exibir nessas datas.';

  @override
  String get exportPdfMenu => 'Exportar PDF';

  @override
  String get reportTitle => 'Exportar PDF';

  @override
  String get reportNoFontTitle => 'Ainda não neste idioma';

  @override
  String get reportNoFontBody =>
      'Um relatório precisa de uma fonte para a sua escrita, e as de chinês, japonês e coreano são grandes demais para vir no app. Uma versão futura vai oferecer o download.';

  @override
  String get reportPreviewTitle => 'Relatório';

  @override
  String get reportCoversHeader => 'O que ele abrange';

  @override
  String get reportRangePeriod => 'Este período';

  @override
  String get reportRangeCustom => 'Datas';

  @override
  String get reportRangeYear => 'Ano';

  @override
  String get reportFromLabel => 'De';

  @override
  String get reportToLabel => 'Até';

  @override
  String get reportYearLabel => 'Ano';

  @override
  String get reportAccountLabel => 'Conta';

  @override
  String get reportAllAccounts => 'Todas as contas';

  @override
  String get reportIncludeHeader => 'O que ele inclui';

  @override
  String get reportIncludeSubtitle =>
      'Deixe de fora o que preferir não compartilhar.';

  @override
  String get reportIncludeTransactions => 'A lista de transações';

  @override
  String get reportIncludeDetails => 'Títulos e notas';

  @override
  String get reportIncludeAccounts => 'Nomes das contas';

  @override
  String get reportCreateButton => 'Criar relatório';

  @override
  String get reportBuilding => 'Criando o relatório';

  @override
  String get reportFailed =>
      'Não foi possível criar o relatório. Tente novamente.';

  @override
  String get reportRangeBackwards =>
      'A primeira data precisa vir antes da última.';

  @override
  String get importTitle => 'Importar um CSV';

  @override
  String get importSubtitle => 'Traga transações de outro aplicativo';

  @override
  String get importIntro =>
      'Escolha um arquivo CSV e veja o que o app entendeu dele antes que algo seja adicionado. A importação só adiciona registros — ela nunca substitui ou exclui o que você já tem.';

  @override
  String get importChooseFile => 'Escolher um arquivo';

  @override
  String get importChooseAnother => 'Escolher outro arquivo';

  @override
  String get importReadFailed =>
      'Não foi possível ler esse arquivo. Tente novamente.';

  @override
  String get importRefusedEmpty => 'Não há nada nesse arquivo.';

  @override
  String get importRefusedNoDate =>
      'Nenhuma coluna desse arquivo pôde ser lida como data, então ele não pode ser importado.';

  @override
  String get importRefusedNoAmount =>
      'Nenhuma coluna desse arquivo pôde ser lida como valor, então ele não pode ser importado.';

  @override
  String get importRefusedNoRows =>
      'Nenhuma linha desse arquivo pôde ser lida, então não há nada para importar.';

  @override
  String get importColumnsHeader => 'Colunas';

  @override
  String get importColumnsSubtitle => 'Corrija o que o app leu errado.';

  @override
  String get importColumnNone => 'Não usada';

  @override
  String get importFieldType => 'Tipo';

  @override
  String get importFieldToAccount => 'Conta de destino';

  @override
  String get importFieldTitle => 'Título';

  @override
  String get importFieldNote => 'Nota';

  @override
  String get importDateOrderLabel => 'Datas como 03/04 significam';

  @override
  String get importDayFirst => 'Dia primeiro';

  @override
  String get importMonthFirst => 'Mês primeiro';

  @override
  String get importCountsHeader => 'O que vai acontecer';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas serão importadas',
      one: '1 linha será importada',
      zero: 'Nada será importado',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas têm uma data que o app não consegue ler',
      one: '1 linha tem uma data que o app não consegue ler',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas têm um valor que o app não consegue ler',
      one: '1 linha tem um valor que o app não consegue ler',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas não têm nenhum valor',
      one: '1 linha não tem nenhum valor',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas já estão no app',
      one: '1 linha já está no app',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transferências indicam só uma conta',
      one: '1 transferência indica só uma conta',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Não é possível ler a data';

  @override
  String get importRowUnreadableAmount => 'Não é possível ler o valor';

  @override
  String get importRowZero => 'Nenhum valor';

  @override
  String get importRowAlreadyThere => 'Já está no app';

  @override
  String get importRowIncompleteTransfer => 'Só uma conta indicada';

  @override
  String get importNamesHeader => 'Nomes que este app não tem';

  @override
  String get importNamesSubtitle =>
      'Escolha o que cada um vai virar. A importação nunca cria uma categoria ou conta.';

  @override
  String get importRowsHeader => 'As primeiras linhas, como o app as leu';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e mais $count',
      one: 'e mais 1',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count linhas',
      one: 'Importar 1 linha',
      zero: 'Nada para importar',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros importados',
      one: '1 registro importado',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'Não foi possível importar esse arquivo. Nada foi adicionado.';

  @override
  String get attachmentsLabel => 'Anexos';

  @override
  String get photoLabel => 'Foto';

  @override
  String get photoAdd => 'Adicionar uma foto';

  @override
  String get photoTake => 'Tirar uma foto';

  @override
  String get photoChoose => 'Escolher uma foto';

  @override
  String get photoRemove => 'Remover foto';

  @override
  String get photoMissing => 'Esta foto está faltando.';

  @override
  String get voiceNoteLabel => 'Nota de voz';

  @override
  String get voiceRecord => 'Gravar uma nota de voz';

  @override
  String voiceRecording(int seconds) {
    return 'Gravando, faltam ${seconds}s';
  }

  @override
  String get voiceStop => 'Parar';

  @override
  String get voicePlay => 'Reproduzir';

  @override
  String get voicePause => 'Pausar';

  @override
  String get voiceRemove => 'Remover nota de voz';

  @override
  String get voiceMissing => 'Esta nota de voz está faltando.';

  @override
  String get microphoneRefused => 'O microfone está desativado para este app.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Inclui anexos, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Oculta todos os anúncios com um único pagamento. Fica associado à sua conta da loja, por isso volta ao trocar de telefone ou reinstalar.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Remover anúncios por $price';
  }

  @override
  String get removeAdsOwned => 'Os anúncios estão desativados. Obrigado.';

  @override
  String get removeAdsPending => 'Aguardando resposta da loja…';

  @override
  String get removeAdsUnavailable =>
      'A loja ainda não tem nada para vender aqui. Tente novamente mais tarde.';

  @override
  String get removeAdsFailed =>
      'Isso não foi concluído e você não foi cobrado.';

  @override
  String get restorePurchasesButton => 'Restaurar compras';

  @override
  String get payNothingWithheld =>
      'Todos os recursos continuam gratuitos, com ou sem anúncios.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Em breve';

  @override
  String get plusBody =>
      'Uma conexão bancária que traz suas transações para você confirmar. Ainda não está pronta, então não há nada para comprar.';

  @override
  String get privacyOptionsTitle => 'Opções de privacidade';

  @override
  String get privacyPolicyTitle => 'Política de privacidade';

  @override
  String get privacyOptionsSubtitle =>
      'Altere sua escolha sobre anúncios personalizados';

  @override
  String get dueEntryReminderTitle => 'Um lançamento venceu';

  @override
  String dueEntryReminderOne(String title) {
    return '$title venceu hoje e ainda está pendente.';
  }

  @override
  String get dueEntryReminderUntitled =>
      'Um lançamento recorrente venceu hoje e ainda está pendente.';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lançamentos recorrentes venceram hoje.',
      one: '1 lançamento recorrente venceu hoje.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'Nada registrado hoje';

  @override
  String get emptyDayReminderBody =>
      'Adicione o que gastou enquanto ainda se lembra.';

  @override
  String get reminderLockedTitle => 'Algo está à espera';

  @override
  String get nudgeSettingsTitle => 'Lembrar-me em dias sem registro';

  @override
  String get nudgeSettingsSubtitle =>
      'Um lembrete à noite, apenas em dias sem nenhum registro.';

  @override
  String get nudgeOfferTitle => 'Um lembrete nos dias que esquece?';

  @override
  String get nudgeOfferBody =>
      'Um lembrete no horário que você escolher, apenas em dias sem registro. Pode desativar quando quiser.';

  @override
  String get nudgeOfferYes => 'Sim, lembrar-me';

  @override
  String get nudgeOfferNo => 'Não';

  @override
  String get nudgeStoppedNotice =>
      'Os lembretes pararam após três sem resposta. Reative-os quando quiser.';

  @override
  String get nudgePermissionDenied =>
      'Ative as notificações nas configurações do sistema.';

  @override
  String get updateDownloadedMessage => 'Uma atualização foi baixada.';

  @override
  String get updateRestartButton => 'Reiniciar';
}
