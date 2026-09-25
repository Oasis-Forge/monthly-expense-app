// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => '设置';

  @override
  String get transferTooltip => '转账';

  @override
  String get searchTooltip => '搜索';

  @override
  String get addButton => '添加';

  @override
  String get emptyPeriod => '本期暂无交易记录。';

  @override
  String get emptyPeriodFilteredByAccount => '本期该账户没有任何记录。';

  @override
  String get balanceLabel => '结余';

  @override
  String get expandSummaryTooltip => '显示收入和支出';

  @override
  String get collapseSummaryTooltip => '仅显示余额';

  @override
  String get periodNetLabel => '本期';

  @override
  String carriedForwardLine(String amount) {
    return '结转 $amount';
  }

  @override
  String get incomeLabel => '收入';

  @override
  String get expenseLabel => '支出';

  @override
  String upcomingCategory(String category) {
    return '$category · 未到账';
  }

  @override
  String get upcomingLabel => '未到账';

  @override
  String detailAdded(String date) {
    return '添加于 $date';
  }

  @override
  String detailChanged(String date) {
    return '最后修改于 $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有$count笔周期交易到期',
      one: '有1笔周期交易到期',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '已用 $percent · $over个超支',
      one: '已用 $percent · 1个超支',
      zero: '已用 $percent',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已设$count个预算',
      one: '已设1个预算',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => '无法删除该交易，请重试。';

  @override
  String get transactionDeleted => '交易已删除';

  @override
  String get transferDeleted => '转账已删除';

  @override
  String get undoButton => '撤销';

  @override
  String get undoFailed => '无法撤销，请重试。';

  @override
  String get restoreFailed => '无法恢复该交易，请重试。';

  @override
  String get restoreTransferFailed => '无法恢复这笔转账，请重试。';

  @override
  String get addTransactionTitle => '添加交易';

  @override
  String get editTransactionTitle => '编辑交易';

  @override
  String get transactionDetailTitle => '详情';

  @override
  String get editTooltip => '编辑';

  @override
  String get deleteTooltip => '删除';

  @override
  String get duplicateTooltip => '复制';

  @override
  String get rowMenuTooltip => '更多操作';

  @override
  String get deleteTransactionTitle => '删除这笔交易？';

  @override
  String get deleteTransactionMessage => '它会移入回收站，30 天内可以恢复。';

  @override
  String get discardChangesTitle => '放弃更改？';

  @override
  String get discardChangesMessage => '你在这里输入的内容尚未保存。';

  @override
  String get discardButton => '放弃';

  @override
  String get keepEditingButton => '继续编辑';

  @override
  String get titleOptionalLabel => '标题（选填）';

  @override
  String get amountLabel => '金额';

  @override
  String get amountRequired => '请输入金额';

  @override
  String get amountInvalid => '请输入有效金额';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => '退格';

  @override
  String get hideKeypadTooltip => '隐藏键盘';

  @override
  String get categoryLabel => '分类';

  @override
  String get categoryRequired => '请选择分类';

  @override
  String get accountLabel => '账户';

  @override
  String get accountRequired => '请选择账户';

  @override
  String get dateLabel => '日期';

  @override
  String get noteLabel => '备注';

  @override
  String get previousDayTooltip => '前一天';

  @override
  String get nextDayTooltip => '后一天';

  @override
  String get noteOptionalLabel => '备注（选填）';

  @override
  String get saveChangesButton => '保存更改';

  @override
  String get addTransactionButton => '添加交易';

  @override
  String get saveAndAddAnotherButton => '保存并继续添加';

  @override
  String get transactionAdded => '交易已添加';

  @override
  String get saveFailed => '无法保存该交易，请重试。';

  @override
  String get noExpensesInPeriod => '本期暂无支出记录。';

  @override
  String totalSpent(String amount) {
    return '共支出：$amount';
  }

  @override
  String periodRange(String start, String end) {
    return '$start 至 $end';
  }

  @override
  String categoryAndDate(String category, String date) {
    return '$category · $date';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get drawerAddHeader => '添加';

  @override
  String get drawerAddExpense => '添加支出';

  @override
  String get drawerAddIncome => '添加收入';

  @override
  String get drawerPlanHeader => '计划';

  @override
  String get drawerReviewHeader => '回顾';

  @override
  String get drawerSpending => '分类支出';

  @override
  String get drawerManageHeader => '管理';

  @override
  String get drawerDataHeader => '数据';

  @override
  String get currencyLabel => '货币';

  @override
  String get currencySearchHint => '搜索货币';

  @override
  String changeCurrencyTitle(String code) {
    return '将货币更改为 $code？';
  }

  @override
  String get changeCurrencyMessage => '金额保持不变，只更改货币单位。';

  @override
  String get changeButton => '更改';

  @override
  String get cancelButton => '取消';

  @override
  String get saveButton => '保存';

  @override
  String get removeButton => '移除';

  @override
  String get themeLabel => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeBlack => '黑色';

  @override
  String get languageLabel => '语言';

  @override
  String get languageSystem => '系统默认';

  @override
  String get monthStartLabel => '每月起始日';

  @override
  String get monthStartLastDay => '最后一天';

  @override
  String get showCarriedForwardLabel => '结转结余';

  @override
  String get showCarriedForwardSubtitle => '每期均从上期结余开始计算';

  @override
  String get trashTitle => '回收站';

  @override
  String get trashEmpty => '回收站为空。';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '将于$days天后彻底删除',
      one: '将于1天后彻底删除',
    );
    return '$amount · $_temp0';
  }

  @override
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '将于$days天后彻底删除',
      one: '将于1天后彻底删除',
    );
    return '$_temp0';
  }

  @override
  String get restoreTooltip => '恢复';

  @override
  String get categoriesTitle => '分类';

  @override
  String get addCategoryTooltip => '添加分类';

  @override
  String get addCategoryTitle => '添加分类';

  @override
  String get editCategoryTitle => '编辑分类';

  @override
  String get categoryNameLabel => '名称';

  @override
  String get categoryNameRequired => '请输入名称';

  @override
  String get categoryNameTaken => '该名称已被使用';

  @override
  String get archiveAction => '归档';

  @override
  String get unarchiveAction => '取消归档';

  @override
  String get deleteAction => '删除';

  @override
  String get archivedHeader => '已归档';

  @override
  String get accountsTotalLabel => '总计';

  @override
  String get categorySaveFailed => '无法保存该分类，请重试。';

  @override
  String get accountsTitle => '账户';

  @override
  String get accountCash => '现金';

  @override
  String get accountTypeLabel => '类型';

  @override
  String get accountTypeCash => '现金';

  @override
  String get accountTypeBank => '银行';

  @override
  String get accountTypeCard => '银行卡';

  @override
  String get accountTypeOther => '其他';

  @override
  String get addAccountTooltip => '添加账户';

  @override
  String get addAccountTitle => '添加账户';

  @override
  String get editAccountTitle => '编辑账户';

  @override
  String get openingBalanceLabel => '期初余额';

  @override
  String get openingDateLabel => '起始日期';

  @override
  String get accountSaveFailed => '无法保存该账户，请重试。';

  @override
  String get transferTitle => '转账';

  @override
  String get editTransferTitle => '编辑转账';

  @override
  String get transferLabel => '转账';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => '从';

  @override
  String get toAccountLabel => '到';

  @override
  String get sameAccountError => '请选择两个不同的账户';

  @override
  String get needTwoAccounts => '请再添加一个账户，才能在账户间转账。';

  @override
  String get addTransferButton => '添加转账';

  @override
  String get transferSaveFailed => '无法保存该转账，请重试。';

  @override
  String get searchHint => '搜索交易';

  @override
  String get allTypesFilter => '全部';

  @override
  String get allCategoriesFilter => '所有分类';

  @override
  String get allAccountsFilter => '所有账户';

  @override
  String get allTimeFilter => '所有时间';

  @override
  String get clearDatesTooltip => '清除日期';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count条结果',
      one: '1条结果',
    );
    return '$_temp0 · 收入 $income · 支出 $expense';
  }

  @override
  String get noSearchResults => '没有匹配的交易。';

  @override
  String get budgetsTitle => '预算';

  @override
  String get budgetsTooltip => '预算';

  @override
  String get overallBudget => '总预算';

  @override
  String get noBudget => '无预算';

  @override
  String budgetsHint(String period) {
    return '限额自 $period 起生效，此前各期维持原限额。';
  }

  @override
  String get budgetLimitLabel => '每期限额';

  @override
  String get budgetSaveFailed => '无法保存该预算，请重试。';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent / $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '剩余 $remaining · 每天 $perDay';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return '已花费 $amount · 至今每天 $perDay';
  }

  @override
  String get homeSetBudget => '设置每月预算';

  @override
  String budgetLeft(String remaining) {
    return '剩余 $remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return '超支 $amount';
  }

  @override
  String get budgetLimitReached => '已达限额';

  @override
  String budgetLimitOnly(String limit) {
    return '限额 $limit';
  }

  @override
  String get recurringTitle => '周期交易';

  @override
  String get addRecurringTooltip => '添加周期交易';

  @override
  String get addRecurringTitle => '添加周期交易';

  @override
  String get editRecurringTitle => '编辑周期交易';

  @override
  String get dueHeader => '到期';

  @override
  String get upcomingHeader => '未来30天';

  @override
  String get rulesHeader => '规则';

  @override
  String billsPerMonth(String amount) {
    return '每月账单共 $amount';
  }

  @override
  String nextBillToday(String title) {
    return '下一笔:$title,今天';
  }

  @override
  String nextBillTomorrow(String title) {
    return '下一笔:$title,明天';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '下一笔:$title,$days 天后',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => '未来30天内没有安排。';

  @override
  String get noRules => '暂无周期交易。';

  @override
  String get recurringEmptyMessage =>
      '周期交易会按你设置的时间安排自动记录房租、工资或订阅费,并等待你点一下确认每一笔。';

  @override
  String get addRecurringButton => '添加周期交易';

  @override
  String get postButton => '记账';

  @override
  String get skipButton => '跳过';

  @override
  String get postFailed => '无法记账，请重试。';

  @override
  String get recurringSaveFailed => '无法保存该周期交易，请重试。';

  @override
  String get recurringDeleted => '周期交易已删除';

  @override
  String get everyLabel => '每';

  @override
  String get frequencyDays => '天';

  @override
  String get frequencyWeeks => '周';

  @override
  String get frequencyMonths => '月';

  @override
  String get frequencyYears => '年';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每$count天',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => '每天';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每$count周',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => '每周';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每$count个月',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => '每月';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每$count年',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => '每年';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · 已暂停';
  }

  @override
  String get startsLabel => '开始';

  @override
  String get endsLabel => '结束';

  @override
  String get endNever => '永不';

  @override
  String get endAfter => '按次数';

  @override
  String get endOnDate => '按日期';

  @override
  String get timesLabel => '次数';

  @override
  String get endsOnLabel => '结束于';

  @override
  String get wholeNumberInvalid => '请输入不小于1的整数';

  @override
  String wholeNumberRange(int max) {
    return '请输入 1 到 $max 之间的整数';
  }

  @override
  String get endDateInvalid => '结束日期必须晚于开始日期';

  @override
  String get autoPostLabel => '自动记账';

  @override
  String get autoPostSubtitle => '否则将在「到期」中等待手动确认';

  @override
  String get pauseTooltip => '暂停';

  @override
  String get resumeTooltip => '恢复';

  @override
  String get categoryFood => '餐饮';

  @override
  String get categoryGroceries => '日用百货';

  @override
  String get categoryTransport => '交通';

  @override
  String get categoryShopping => '购物';

  @override
  String get categoryBills => '账单';

  @override
  String get categoryRent => '房租';

  @override
  String get categoryHealth => '医疗健康';

  @override
  String get categoryEducation => '教育';

  @override
  String get categoryEntertainment => '娱乐';

  @override
  String get categorySalary => '工资';

  @override
  String get categoryBusiness => '经营';

  @override
  String get categoryInvestment => '投资';

  @override
  String get categoryGift => '礼金';

  @override
  String get categoryOther => '其他';

  @override
  String get previousPeriodTooltip => '上一期';

  @override
  String get wholePeriodTooltip => '显示整期';

  @override
  String get nextPeriodTooltip => '下一期';

  @override
  String get insightsTooltip => '统计';

  @override
  String get insightsTitle => '统计';

  @override
  String get calendarTab => '日历';

  @override
  String get trendTab => '趋势';

  @override
  String get noIncomeInPeriod => '本期暂无收入记录。';

  @override
  String totalIncome(String amount) {
    return '共收入：$amount';
  }

  @override
  String comparedMore(String amount) {
    return '比上月多$amount';
  }

  @override
  String comparedLess(String amount) {
    return '比上月少$amount';
  }

  @override
  String get comparedSame => '与上月相同';

  @override
  String get categoryNewLabel => '新';

  @override
  String get calendarHint => '点按某天可查看当天的交易。';

  @override
  String get dayEmpty => '这一天没有记录。';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个月',
      one: '1个月',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return '收入 $income · 支出 $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return '每期平均 · 收入 $income · 支出 $expense';
  }

  @override
  String get trendNeedsMorePeriods => '趋势需要一期以上的数据。下个月再来看看。';

  @override
  String get weekStartLabel => '每周起始日';

  @override
  String weekStartDefault(String day) {
    return '默认（$day）';
  }

  @override
  String get firstRunTitle => '欢迎使用 Monthly Expenses';

  @override
  String get firstRunMessage => '记录你的收支，数据仅保存在本设备上。';

  @override
  String get addFirstTransactionButton => '添加第一笔交易';

  @override
  String get setupIntro => '选择语言和货币，之后可在设置中更改。';

  @override
  String get setupContinueButton => '继续';

  @override
  String get setupRestoreTitle => '恢复备份';

  @override
  String get setupRestoreSubtitle => '从备份文件中恢复数据和设置';

  @override
  String get walkthroughEntryTitle => '几秒钟完成记账';

  @override
  String get walkthroughEntryBody => '支持算式输入的键盘、小票拍照，打字慢时还能用语音备注。';

  @override
  String get walkthroughPlanTitle => '规划每月支出';

  @override
  String get walkthroughPlanBody => '按分类设置预算，账单自动周期入账，备忘录及时提醒你。';

  @override
  String get walkthroughInsightsTitle => '看清钱花在哪';

  @override
  String get walkthroughInsightsBody => '图表、日历视图，还能导出任意时期的 PDF 或 CSV 报告。';

  @override
  String get walkthroughPrivacyTitle => '只属于你';

  @override
  String get walkthroughPrivacyBody => '无需账户。你记录的内容只留在这部手机上，为本应用付费的广告永远看不到它。';

  @override
  String get walkthroughBringTitle => '带上你原有的数据';

  @override
  String get walkthroughBringBody => '从其他应用或手机迁移？可用备份或 CSV 文件导入，无需从零开始。';

  @override
  String get firstRunRestoreTitle => '恢复此备份？';

  @override
  String get firstRunRestoreMessage => '这将替换应用中的所有内容，并恢复备份保存时的语言和货币设置。';

  @override
  String get walkthroughNextButton => '下一步';

  @override
  String get walkthroughStartButton => '开始使用';

  @override
  String get walkthroughDoneButton => '完成';

  @override
  String walkthroughProgress(int current, int total) {
    return '第 $current 页，共 $total 页';
  }

  @override
  String get walkthroughReplayTitle => '重新查看引导';

  @override
  String get walkthroughReplaySubtitle => '首次打开应用时显示的四页引导';

  @override
  String get removeAdsTitle => '移除广告';

  @override
  String get exportCsvMenu => '导出 CSV';

  @override
  String get exportCsvTooltip => '导出 CSV';

  @override
  String get csvExported => 'CSV 已保存';

  @override
  String get csvExportFailed => '无法导出 CSV，请重试。';

  @override
  String get backupTitle => '备份与恢复';

  @override
  String get backupIntro => '备份文件保存在你指定的位置，不会自动上传或发送。';

  @override
  String get backUpNowTitle => '立即备份';

  @override
  String lastBackupLine(String date) {
    return '上次备份于 $date';
  }

  @override
  String get neverBackedUp => '尚未备份';

  @override
  String get backupSaved => '备份已保存';

  @override
  String get backupSaveFailed => '无法保存备份，请重试。';

  @override
  String get restoreFromFileTitle => '从文件恢复';

  @override
  String get restoreFromFileSubtitle => '将备份合并到现有数据，或用它替换现有数据';

  @override
  String get backupReminderLabel => '备份提醒';

  @override
  String get backupReminderSubtitle => '达到20笔交易后，每30天提醒一次';

  @override
  String get backupReminderNever => '备份数据以确保安全';

  @override
  String backupReminderSince(String date) {
    return '上次备份于 $date，该再备份一次了吧？';
  }

  @override
  String get notNowTooltip => '暂不';

  @override
  String get keptBackupsHeader => '自动备份';

  @override
  String get keptBackupsHint => '每次恢复前会自动保存在本设备。';

  @override
  String get noKeptBackups => '暂无。';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count笔交易',
      one: '1笔交易',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => '恢复备份';

  @override
  String get mergeOption => '合并';

  @override
  String get mergeOptionSubtitle => '保留现有数据并加入备份数据；若同一记录两边都有，以较新的修改为准。';

  @override
  String get replaceOption => '替换';

  @override
  String get replaceOptionSubtitle => '删除现有数据，改用备份中的数据和设置。';

  @override
  String get restoreSafetyNote => '系统会先将当前数据的副本保存到「自动备份」中。';

  @override
  String get restoreButton => '恢复';

  @override
  String get restoreKeptTitle => '恢复此副本？';

  @override
  String restoreKeptMessage(String date) {
    return '你的数据将被 $date 的副本替换，系统会先保存当前数据的副本。';
  }

  @override
  String get backupInvalid => '该文件不是 Monthly Expenses 的备份文件。';

  @override
  String get backupTooNew => '该备份来自更新版本的应用，请先更新应用后重试。';

  @override
  String get backupOpenFailed => '无法打开该文件，请重试。';

  @override
  String get backupRestoreFailed => '无法恢复备份，你的数据未受影响。';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已恢复$count笔交易',
      one: '已恢复1笔交易',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return '已合并：新增 $added 笔，更新 $updated 笔，未变 $unchanged 笔';
  }

  @override
  String get appLockLabel => '应用锁';

  @override
  String get appLockSubtitle => '使用指纹、面容或屏幕锁解锁';

  @override
  String get appLockUnavailable => '请先在设备上设置屏幕锁，才能使用应用锁';

  @override
  String get appLockReason => '解锁 Monthly Expenses';

  @override
  String get appLockPromptHint => '确认是你';

  @override
  String get appLockFailed => '无法确认身份，应用锁设置未更改。';

  @override
  String get lockedTitle => 'Monthly Expenses 已锁定';

  @override
  String get unlockButton => '解锁';

  @override
  String get widgetShowAmountsLabel => '在小组件上显示金额';

  @override
  String get widgetShowAmountsSubtitle => '开启应用锁后，桌面小组件将隐藏金额';

  @override
  String get widgetLeftLabel => '剩余';

  @override
  String get widgetAddExpense => '添加支出';

  @override
  String get widgetAddIncome => '添加收入';

  @override
  String get widgetAmountsHidden => '应用锁已隐藏金额';

  @override
  String get notesTitle => '备忘录';

  @override
  String get addNoteTooltip => '添加备忘';

  @override
  String get addNoteTitle => '添加备忘';

  @override
  String get editNoteTitle => '编辑备忘';

  @override
  String get noteTextLabel => '内容';

  @override
  String get noteTextRequired => '请输入内容';

  @override
  String get noteAmountOptionalLabel => '金额（选填）';

  @override
  String get noteDueDateToggle => '设置到期日期';

  @override
  String get noteDueDateLabel => '到期日期';

  @override
  String get noteReminderToggle => '提醒我';

  @override
  String get noteReminderTimeLabel => '提醒时间';

  @override
  String get noteReminderTimeUnset => '选择时间';

  @override
  String get reminderMayBeLate => '你的手机可能会晚几分钟送达。';

  @override
  String get noteCategoryOptionalLabel => '分类（选填）';

  @override
  String get noteCategoryNone => '无';

  @override
  String get recordNoteButton => '记为交易';

  @override
  String get noteMarkDoneTooltip => '标记完成';

  @override
  String get noteMarkOpenTooltip => '标记未完成';

  @override
  String get notesEmptyTitle => '暂时没有内容';

  @override
  String get notesEmptyMessage => '备忘录用于记住待办或待查事项，可选填日期、金额和分类。';

  @override
  String get addNoteButton => '添加备忘';

  @override
  String get notesOpenHeader => '未完成';

  @override
  String get notesDoneHeader => '已完成';

  @override
  String get noteDeleted => '备忘已删除。';

  @override
  String get noteSaveFailed => '无法保存备忘，请重试。';

  @override
  String get noteDeleteFailed => '无法删除备忘，请重试。';

  @override
  String get noteRestoreFailed => '无法恢复备忘，请重试。';

  @override
  String get notesSearchHint => '搜索备忘';

  @override
  String get noteFilterAll => '全部';

  @override
  String get noteFilterOverdue => '已逾期';

  @override
  String get noteFilterDueToday => '今日到期';

  @override
  String get noteFilterUpcoming => '即将到期';

  @override
  String get noteFilterNoDate => '无日期';

  @override
  String get noNoteResults => '没有匹配的备忘。';

  @override
  String get noteLinkedTransactionLabel => '已记为交易';

  @override
  String get noteLinkedNoteLabel => '来自备忘';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有$count条备忘到期',
      one: '有1条备忘到期',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => '到期备忘';

  @override
  String get noteReminderTitle => '备忘提醒';

  @override
  String get noteReminderLockedTitle => '有一条备忘到期';

  @override
  String get noteReminderChannelName => '备忘提醒';

  @override
  String get noteReminderPermissionDenied => '请在系统设置中开启通知权限，才能收到备忘提醒。';

  @override
  String reportRange(String from, String to) {
    return '$from 至 $to';
  }

  @override
  String reportCreated(String when) {
    return '创建于 $when';
  }

  @override
  String reportNarrowedTo(String description) {
    return '已缩小至：$description';
  }

  @override
  String reportPageOf(int page, int pages) {
    return '第 $page 页，共 $pages 页';
  }

  @override
  String get reportNet => '净额';

  @override
  String get reportMatchingIncome => '匹配的收入';

  @override
  String get reportMatchingExpense => '匹配的支出';

  @override
  String get reportMatchingNet => '匹配的净额';

  @override
  String get reportOpeningBalance => '期初余额';

  @override
  String get reportClosingBalance => '期末余额';

  @override
  String get reportSpendingHeader => '分类支出';

  @override
  String get reportEarningHeader => '分类收入';

  @override
  String get reportTrendHeader => '趋势';

  @override
  String get reportEntriesHeader => '交易记录';

  @override
  String get reportUpcomingHeader => '未到账';

  @override
  String get reportUpcomingNote => '日期在未来，未计入以上总额。';

  @override
  String get reportAmountColumn => '金额';

  @override
  String get reportShareColumn => '占比';

  @override
  String get reportBudgetColumn => '预算';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used / $limit';
  }

  @override
  String get reportDetailsColumn => '详情';

  @override
  String get reportEmpty => '所选日期范围内没有可报告的内容。';

  @override
  String get exportPdfMenu => '导出 PDF';

  @override
  String get reportTitle => '导出 PDF';

  @override
  String get reportNoFontTitle => '暂不支持此语言';

  @override
  String get reportNoFontBody =>
      '生成报表需要对应文字的字体，而中文、日文和韩文字体太大，无法随应用一起提供。后续版本将支持单独下载。';

  @override
  String get reportPreviewTitle => '报告';

  @override
  String get reportCoversHeader => '统计范围';

  @override
  String get reportNarrowedNotice => '此报告仍限定于您的搜索。';

  @override
  String get reportRangePeriod => '本期';

  @override
  String get reportRangeCustom => '自定义';

  @override
  String get reportRangeYear => '年度';

  @override
  String get reportFromLabel => '起始';

  @override
  String get reportToLabel => '结束';

  @override
  String get reportYearLabel => '年份';

  @override
  String get reportAccountLabel => '账户';

  @override
  String get reportAllAccounts => '所有账户';

  @override
  String get reportIncludeHeader => '包含内容';

  @override
  String get reportIncludeSubtitle => '可去除任何不想分享的内容。';

  @override
  String get reportIncludeTransactions => '交易列表';

  @override
  String get reportIncludeDetails => '标题和备注';

  @override
  String get reportIncludeAccounts => '账户名称';

  @override
  String get reportCreateButton => '生成报告';

  @override
  String get reportBuilding => '正在生成报告';

  @override
  String get reportFailed => '无法生成报告，请重试。';

  @override
  String get reportRangeBackwards => '起始日期必须早于结束日期。';

  @override
  String get importTitle => '导入 CSV';

  @override
  String get importSubtitle => '从其他应用导入交易';

  @override
  String get importIntro => '选择一个 CSV 文件，添加前可先查看应用的解析结果。导入只会新增记录，不会替换或删除已有数据。';

  @override
  String get importChooseFile => '选择文件';

  @override
  String get importChooseAnother => '选择其他文件';

  @override
  String get importReadFailed => '无法读取该文件，请重试。';

  @override
  String get importRefusedEmpty => '该文件中没有内容。';

  @override
  String get importRefusedNoDate => '该文件中没有可识别为日期的列，无法导入。';

  @override
  String get importRefusedNoAmount => '该文件中没有可识别为金额的列，无法导入。';

  @override
  String get importRefusedNoRows => '该文件中的所有行都无法读取，没有可导入的内容。';

  @override
  String get importColumnsHeader => '列';

  @override
  String get importColumnsSubtitle => '可修改应用识别有误的内容。';

  @override
  String get importColumnNone => '不使用';

  @override
  String get importFieldType => '类型';

  @override
  String get importFieldToAccount => '目标账户';

  @override
  String get importFieldTitle => '标题';

  @override
  String get importFieldNote => '备注';

  @override
  String get importDateOrderLabel => '像03/04这样的日期表示';

  @override
  String get importDayFirst => '日在前';

  @override
  String get importMonthFirst => '月在前';

  @override
  String get importCountsHeader => '导入结果预览';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将导入$count行',
      one: '将导入1行',
      zero: '不会导入任何内容',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有$count行的日期无法识别',
      one: '有1行的日期无法识别',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有$count行的金额无法识别',
      one: '有1行的金额无法识别',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有$count行金额为零',
      one: '有1行金额为零',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有$count行已存在于应用中',
      one: '有1行已存在于应用中',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有$count笔转账只填写了一个账户',
      one: '有1笔转账只填写了一个账户',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => '日期无法识别';

  @override
  String get importRowUnreadableAmount => '金额无法识别';

  @override
  String get importRowZero => '金额为零';

  @override
  String get importRowAlreadyThere => '已存在于应用中';

  @override
  String get importRowIncompleteTransfer => '只填写了一个账户';

  @override
  String get importNamesHeader => '应用中没有的名称';

  @override
  String get importNamesSubtitle => '为每一项选择对应内容。导入不会自动创建分类或账户。';

  @override
  String get importRowsHeader => '应用识别出的前几行';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还有$count条',
      one: '还有1条',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '导入$count行',
      one: '导入1行',
      zero: '无内容可导入',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入$count条记录',
      one: '已导入1条记录',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => '无法导入该文件，未添加任何内容。';

  @override
  String get attachmentsLabel => '附件';

  @override
  String get photoLabel => '照片';

  @override
  String get photoAdd => '添加照片';

  @override
  String get photoTake => '拍照';

  @override
  String get photoChoose => '选择照片';

  @override
  String get photoRemove => '移除照片';

  @override
  String get photoMissing => '该照片已丢失。';

  @override
  String get voiceNoteLabel => '语音备注';

  @override
  String get voiceRecord => '录制语音备注';

  @override
  String voiceRecording(int seconds) {
    return '录制中，剩余$seconds秒';
  }

  @override
  String get voiceStop => '停止';

  @override
  String get voicePlay => '播放';

  @override
  String get voicePause => '暂停';

  @override
  String get voiceRemove => '移除语音备注';

  @override
  String get voiceMissing => '该语音备注已丢失。';

  @override
  String get microphoneRefused => '该应用的麦克风权限已关闭。';

  @override
  String backupIncludesAttachments(String size) {
    return '含附件，共 $size MB';
  }

  @override
  String get removeAdsBody => '一次付费即可隐藏所有广告。它与你的商店账户绑定，换新手机或重新安装后仍会恢复。';

  @override
  String removeAdsBuyButton(String price) {
    return '以 $price 移除广告';
  }

  @override
  String get removeAdsOwned => '广告已关闭，谢谢支持。';

  @override
  String get removeAdsPending => '正在等待应用商店…';

  @override
  String get removeAdsUnavailable => '商店目前暂无此项目可供购买，请稍后再试。';

  @override
  String get removeAdsFailed => '交易未成功，你没有被扣款。';

  @override
  String get restorePurchasesButton => '恢复购买';

  @override
  String get payNothingWithheld => '无论有没有广告，所有功能都是免费的。';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => '即将推出';

  @override
  String get plusBody => '银行连接功能会导入你的交易记录供确认，目前尚未完成，暂时无法购买。';

  @override
  String get privacyOptionsTitle => '隐私选项';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyOptionsSubtitle => '更改你对个性化广告的选择';

  @override
  String get dueEntryReminderTitle => '有一笔记录到期';

  @override
  String get dueEntryChannelName => '到期的记录';

  @override
  String dueEntryReminderOne(String title) {
    return '$title今天到期，仍在等待处理。';
  }

  @override
  String get dueEntryReminderUntitled => '一笔重复记录今天到期，仍在等待处理。';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '今天有 $count 笔重复记录到期。',
      one: '今天有 $count 笔重复记录到期。',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => '今天没有记录';

  @override
  String get emptyDayChannelName => '没有记录的日子';

  @override
  String get emptyDayReminderBody => '趁还记得，把花费记下来吧。';

  @override
  String get reminderLockedTitle => '有一项内容在等待';

  @override
  String get nudgeSettingsTitle => '空白日提醒我';

  @override
  String get nudgeSettingsSubtitle => '仅在晚上提醒一次，且仅限当天没有任何记录时。';

  @override
  String get nudgeOfferTitle => '在你忘记的日子提醒一下？';

  @override
  String get nudgeOfferBody => '在你选择的时间提醒一次，仅限当天没有任何记录时。随时可以关闭。';

  @override
  String get nudgeOfferYes => '好的，提醒我';

  @override
  String get nudgeOfferNo => '不用了，谢谢';

  @override
  String get nudgeStoppedNotice => '连续三次未响应后提醒已停止，可随时重新开启。';

  @override
  String get nudgePermissionDenied => '请在系统设置中开启通知以接收提醒。';

  @override
  String get updateDownloadedMessage => '已下载更新。';

  @override
  String get updateRestartButton => '重启';
}
