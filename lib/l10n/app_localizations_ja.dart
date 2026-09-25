// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => '設定';

  @override
  String get transferTooltip => '振替';

  @override
  String get searchTooltip => '検索';

  @override
  String get addButton => '追加';

  @override
  String get emptyPeriod => 'この期間の取引はまだありません。';

  @override
  String get balanceLabel => '残高';

  @override
  String get expandSummaryTooltip => '収入と支出を表示';

  @override
  String get collapseSummaryTooltip => '残高のみ表示';

  @override
  String get periodNetLabel => '今期';

  @override
  String carriedForwardLine(String amount) {
    return '繰越 $amount';
  }

  @override
  String get incomeLabel => '収入';

  @override
  String get expenseLabel => '支出';

  @override
  String upcomingCategory(String category) {
    return '$category・予定';
  }

  @override
  String get upcomingLabel => '予定';

  @override
  String detailAdded(String date) {
    return '$dateに追加';
  }

  @override
  String detailChanged(String date) {
    return '$dateに変更';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '期日の定期取引が$count件あります',
      one: '期日の定期取引が1件あります',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent 使用 · $over件超過',
      one: '$percent 使用 · 1件超過',
      zero: '$percent 使用',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '予算$count件を設定済み',
      one: '予算1件を設定済み',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => '取引を削除できませんでした。もう一度お試しください。';

  @override
  String get transactionDeleted => '取引を削除しました';

  @override
  String get transferDeleted => '振替を削除しました';

  @override
  String get undoButton => '元に戻す';

  @override
  String get undoFailed => '元に戻せませんでした。もう一度お試しください。';

  @override
  String get restoreFailed => '取引を復元できませんでした。もう一度お試しください。';

  @override
  String get restoreTransferFailed => '振替を元に戻せませんでした。もう一度お試しください。';

  @override
  String get addTransactionTitle => '取引を追加';

  @override
  String get editTransactionTitle => '取引を編集';

  @override
  String get transactionDetailTitle => '詳細';

  @override
  String get editTooltip => '編集';

  @override
  String get deleteTooltip => '削除';

  @override
  String get duplicateTooltip => '複製';

  @override
  String get rowMenuTooltip => 'その他の操作';

  @override
  String get deleteTransactionTitle => 'この取引を削除しますか？';

  @override
  String get deleteTransactionMessage => 'ゴミ箱に移動し、30 日間は元に戻せます。';

  @override
  String get discardChangesTitle => '変更を破棄しますか？';

  @override
  String get discardChangesMessage => '入力した内容はまだ保存されていません。';

  @override
  String get discardButton => '破棄';

  @override
  String get keepEditingButton => '編集を続ける';

  @override
  String get titleOptionalLabel => 'タイトル(任意)';

  @override
  String get amountLabel => '金額';

  @override
  String get amountRequired => '金額を入力してください';

  @override
  String get amountInvalid => '正しい金額を入力してください';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'バックスペース';

  @override
  String get hideKeypadTooltip => 'キーパッドを隠す';

  @override
  String get categoryLabel => 'カテゴリー';

  @override
  String get categoryRequired => 'カテゴリーを選択してください';

  @override
  String get accountLabel => '口座';

  @override
  String get accountRequired => '口座を選択してください';

  @override
  String get dateLabel => '日付';

  @override
  String get noteLabel => 'メモ';

  @override
  String get previousDayTooltip => '前日';

  @override
  String get nextDayTooltip => '翌日';

  @override
  String get noteOptionalLabel => 'メモ(任意)';

  @override
  String get saveChangesButton => '変更を保存';

  @override
  String get addTransactionButton => '取引を追加';

  @override
  String get saveAndAddAnotherButton => '保存してもう1件追加';

  @override
  String get transactionAdded => '取引を追加しました';

  @override
  String get saveFailed => '取引を保存できませんでした。もう一度お試しください。';

  @override
  String get noExpensesInPeriod => 'この期間の支出はまだありません。';

  @override
  String totalSpent(String amount) {
    return '支出合計: $amount';
  }

  @override
  String periodRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String categoryAndDate(String category, String date) {
    return '$category・$date';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get drawerAddHeader => '記録';

  @override
  String get drawerAddExpense => '支出を追加';

  @override
  String get drawerAddIncome => '収入を追加';

  @override
  String get drawerPlanHeader => '計画';

  @override
  String get drawerReviewHeader => '振り返り';

  @override
  String get drawerSpending => 'カテゴリー別支出';

  @override
  String get drawerManageHeader => '管理';

  @override
  String get drawerDataHeader => 'データ';

  @override
  String get currencyLabel => '通貨';

  @override
  String get currencySearchHint => '通貨を検索';

  @override
  String changeCurrencyTitle(String code) {
    return '通貨を$codeに変更しますか?';
  }

  @override
  String get changeCurrencyMessage => '金額はそのままで、通貨表示のみが変わります。';

  @override
  String get changeButton => '変更';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get saveButton => '保存';

  @override
  String get removeButton => '削除';

  @override
  String get themeLabel => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeBlack => 'ブラック';

  @override
  String get languageLabel => '言語';

  @override
  String get languageSystem => 'システムの既定値';

  @override
  String get monthStartLabel => '月の開始日';

  @override
  String get monthStartLastDay => '末日';

  @override
  String get showCarriedForwardLabel => '残高を繰り越す';

  @override
  String get showCarriedForwardSubtitle => '各期間は前回の残高から始まります';

  @override
  String get trashTitle => 'ゴミ箱';

  @override
  String get trashEmpty => 'ゴミ箱は空です。';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'あと$days日で完全に削除されます',
      one: 'あと1日で完全に削除されます',
    );
    return '$amount・$_temp0';
  }

  @override
  String trashNoteSubtitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'あと$days日で完全に削除されます',
      one: 'あと1日で完全に削除されます',
    );
    return '$_temp0';
  }

  @override
  String get restoreTooltip => '復元';

  @override
  String get categoriesTitle => 'カテゴリー';

  @override
  String get addCategoryTooltip => 'カテゴリーを追加';

  @override
  String get addCategoryTitle => 'カテゴリーを追加';

  @override
  String get editCategoryTitle => 'カテゴリーを編集';

  @override
  String get categoryNameLabel => '名前';

  @override
  String get categoryNameRequired => '名前を入力してください';

  @override
  String get categoryNameTaken => 'その名前はすでに使われています';

  @override
  String get archiveAction => 'アーカイブ';

  @override
  String get unarchiveAction => 'アーカイブ解除';

  @override
  String get deleteAction => '削除';

  @override
  String get archivedHeader => 'アーカイブ済み';

  @override
  String get accountsTotalLabel => '合計';

  @override
  String get categorySaveFailed => 'カテゴリーを保存できませんでした。もう一度お試しください。';

  @override
  String get accountsTitle => '口座';

  @override
  String get accountCash => '現金';

  @override
  String get accountTypeLabel => '種類';

  @override
  String get accountTypeCash => '現金';

  @override
  String get accountTypeBank => '銀行';

  @override
  String get accountTypeCard => 'カード';

  @override
  String get accountTypeOther => 'その他';

  @override
  String get addAccountTooltip => '口座を追加';

  @override
  String get addAccountTitle => '口座を追加';

  @override
  String get editAccountTitle => '口座を編集';

  @override
  String get openingBalanceLabel => '開始残高';

  @override
  String get openingDateLabel => '開始日';

  @override
  String get accountSaveFailed => '口座を保存できませんでした。もう一度お試しください。';

  @override
  String get transferTitle => '振替';

  @override
  String get editTransferTitle => '振替を編集';

  @override
  String get transferLabel => '振替';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => '振替元';

  @override
  String get toAccountLabel => '振替先';

  @override
  String get sameAccountError => '異なる2つの口座を選択してください';

  @override
  String get needTwoAccounts => '口座間で資金を移動するには、2つ目の口座を追加してください。';

  @override
  String get addTransferButton => '振替を追加';

  @override
  String get transferSaveFailed => '振替を保存できませんでした。もう一度お試しください。';

  @override
  String get searchHint => '取引を検索';

  @override
  String get allTypesFilter => 'すべて';

  @override
  String get allCategoriesFilter => 'すべてのカテゴリー';

  @override
  String get allAccountsFilter => 'すべての口座';

  @override
  String get allTimeFilter => 'すべての期間';

  @override
  String get clearDatesTooltip => '日付をクリア';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件',
      one: '1件',
    );
    return '$_temp0・収入 $income・支出 $expense';
  }

  @override
  String get noSearchResults => '一致する取引がありません。';

  @override
  String get budgetsTitle => '予算';

  @override
  String get budgetsTooltip => '予算';

  @override
  String get overallBudget => '全体';

  @override
  String get noBudget => '予算なし';

  @override
  String budgetsHint(String period) {
    return '上限は$periodから適用され、それ以前の期間には従来の上限が適用されます。';
  }

  @override
  String get budgetLimitLabel => '期間ごとの上限';

  @override
  String get budgetSaveFailed => '予算を保存できませんでした。もう一度お試しください。';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$limitのうち$spent';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '残り$remaining・1日あたり$perDay';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return 'これまでに$amount使用・1日あたり$perDay';
  }

  @override
  String get homeSetBudget => '月の予算を設定';

  @override
  String budgetLeft(String remaining) {
    return '残り$remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount超過';
  }

  @override
  String get budgetLimitReached => '上限に到達';

  @override
  String budgetLimitOnly(String limit) {
    return '上限$limit';
  }

  @override
  String get recurringTitle => '定期';

  @override
  String get addRecurringTooltip => '定期取引を追加';

  @override
  String get addRecurringTitle => '定期取引を追加';

  @override
  String get editRecurringTitle => '定期取引を編集';

  @override
  String get dueHeader => '期日';

  @override
  String get upcomingHeader => '今後30日';

  @override
  String get rulesHeader => 'ルール';

  @override
  String billsPerMonth(String amount) {
    return '月々の請求額 $amount';
  }

  @override
  String nextBillToday(String title) {
    return '次回:$title、今日';
  }

  @override
  String nextBillTomorrow(String title) {
    return '次回:$title、明日';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '次回:$title、$days日後',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => '今後30日間の予定はありません。';

  @override
  String get noRules => '定期取引はまだありません。';

  @override
  String get recurringEmptyMessage =>
      '定期取引は、設定したスケジュールに沿って家賃、給与、サブスクリプションなどを記録し、確認のタップを待ちます。';

  @override
  String get addRecurringButton => '定期取引を追加';

  @override
  String get postButton => '登録';

  @override
  String get skipButton => 'スキップ';

  @override
  String get postFailed => '取引を登録できませんでした。もう一度お試しください。';

  @override
  String get recurringSaveFailed => '定期取引を保存できませんでした。もう一度お試しください。';

  @override
  String get recurringDeleted => '定期取引を削除しました';

  @override
  String get everyLabel => '間隔';

  @override
  String get frequencyDays => '日';

  @override
  String get frequencyWeeks => '週';

  @override
  String get frequencyMonths => '月';

  @override
  String get frequencyYears => '年';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日ごと',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => '毎日';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count週間ごと',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => '毎週';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countか月ごと',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => '毎月';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年ごと',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => '毎年';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule・一時停止中';
  }

  @override
  String get startsLabel => '開始日';

  @override
  String get endsLabel => '終了';

  @override
  String get endNever => 'なし';

  @override
  String get endAfter => '回数';

  @override
  String get endOnDate => '日付';

  @override
  String get timesLabel => '回数';

  @override
  String get endsOnLabel => '終了日';

  @override
  String get wholeNumberInvalid => '1以上の整数を入力してください';

  @override
  String wholeNumberRange(int max) {
    return '1〜$max の整数を入力してください';
  }

  @override
  String get endDateInvalid => '終了日は開始日より後にしてください';

  @override
  String get autoPostLabel => '自動登録';

  @override
  String get autoPostSubtitle => 'オフの場合、期日でタップするまで登録されません';

  @override
  String get pauseTooltip => '一時停止';

  @override
  String get resumeTooltip => '再開';

  @override
  String get categoryFood => '食費';

  @override
  String get categoryGroceries => '食料品';

  @override
  String get categoryTransport => '交通費';

  @override
  String get categoryShopping => '買い物';

  @override
  String get categoryBills => '公共料金';

  @override
  String get categoryRent => '家賃';

  @override
  String get categoryHealth => '医療費';

  @override
  String get categoryEducation => '教育費';

  @override
  String get categoryEntertainment => '娯楽費';

  @override
  String get categorySalary => '給与';

  @override
  String get categoryBusiness => '事業';

  @override
  String get categoryInvestment => '投資';

  @override
  String get categoryGift => '贈り物';

  @override
  String get categoryOther => 'その他';

  @override
  String get previousPeriodTooltip => '前の期間';

  @override
  String get wholePeriodTooltip => '期間全体を表示';

  @override
  String get nextPeriodTooltip => '次の期間';

  @override
  String get insightsTooltip => '分析';

  @override
  String get insightsTitle => '分析';

  @override
  String get calendarTab => 'カレンダー';

  @override
  String get trendTab => '推移';

  @override
  String get noIncomeInPeriod => 'この期間の収入はまだありません。';

  @override
  String totalIncome(String amount) {
    return '収入合計: $amount';
  }

  @override
  String comparedMore(String amount) {
    return '先月より$amount多い';
  }

  @override
  String comparedLess(String amount) {
    return '先月より$amount少ない';
  }

  @override
  String get comparedSame => '先月と同じ';

  @override
  String get categoryNewLabel => '新';

  @override
  String get calendarHint => '日付をタップすると、その日の取引が表示されます。';

  @override
  String get dayEmpty => 'この日の取引はありません。';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countか月',
      one: '1か月',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return '収入 $income・支出 $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return '期間平均・収入 $income・支出 $expense';
  }

  @override
  String get trendNeedsMorePeriods => '推移には複数の期間が必要です。来月また来てください。';

  @override
  String get weekStartLabel => '週の開始日';

  @override
  String weekStartDefault(String day) {
    return '既定($day)';
  }

  @override
  String get firstRunTitle => 'Monthly Expensesへようこそ';

  @override
  String get firstRunMessage => '収入と支出を記録しましょう。データはこの端末だけに保存されます。';

  @override
  String get addFirstTransactionButton => '最初の取引を追加';

  @override
  String get setupIntro => '言語と通貨を選択してください。あとから設定でいつでも変更できます。';

  @override
  String get setupContinueButton => '続ける';

  @override
  String get setupRestoreTitle => 'バックアップを復元';

  @override
  String get setupRestoreSubtitle => 'バックアップファイルからデータと設定を復元します';

  @override
  String get walkthroughEntryTitle => '数秒で入力';

  @override
  String get walkthroughEntryBody => '自動計算のキーパッド、レシート撮影、入力が面倒なときの音声メモ。';

  @override
  String get walkthroughPlanTitle => '月の計画を立てる';

  @override
  String get walkthroughPlanBody => 'カテゴリー別の予算、自動で繰り返す定期取引、思い出させてくれるメモ。';

  @override
  String get walkthroughInsightsTitle => '使い道がわかる';

  @override
  String get walkthroughInsightsBody => 'グラフ、カレンダー、好きな期間のPDFやCSVレポート。';

  @override
  String get walkthroughPrivacyTitle => 'あなただけのもの';

  @override
  String get walkthroughPrivacyBody =>
      'アカウント登録は不要です。記録したデータはこの端末に残り、アプリを支える広告に渡ることはありません。';

  @override
  String get walkthroughBringTitle => '今までのデータを引き継ぐ';

  @override
  String get walkthroughBringBody =>
      '他のアプリや機種からの乗り換えなら、空の状態からではなくバックアップやCSVから始められます。';

  @override
  String get firstRunRestoreTitle => 'このバックアップを復元しますか?';

  @override
  String get firstRunRestoreMessage => 'アプリ内のすべてのデータが置き換わり、保存時の言語と通貨も復元されます。';

  @override
  String get walkthroughNextButton => '次へ';

  @override
  String get walkthroughStartButton => 'はじめる';

  @override
  String get walkthroughDoneButton => '完了';

  @override
  String walkthroughProgress(int current, int total) {
    return '$totalページ中$currentページ目';
  }

  @override
  String get walkthroughReplayTitle => '使い方をもう一度見る';

  @override
  String get walkthroughReplaySubtitle => '初回起動時に表示された4ページ';

  @override
  String get removeAdsTitle => '広告を削除';

  @override
  String get exportCsvMenu => 'CSVを書き出す';

  @override
  String get exportCsvTooltip => 'CSVを書き出す';

  @override
  String get csvExported => 'CSVを保存しました';

  @override
  String get csvExportFailed => 'CSVを書き出せませんでした。もう一度お試しください。';

  @override
  String get backupTitle => 'バックアップと復元';

  @override
  String get backupIntro =>
      'バックアップは選んだ場所に保存するファイルです。自動でアップロードされたり送信されたりすることはありません。';

  @override
  String get backUpNowTitle => '今すぐバックアップ';

  @override
  String lastBackupLine(String date) {
    return '前回のバックアップ: $date';
  }

  @override
  String get neverBackedUp => 'バックアップはまだありません';

  @override
  String get backupSaved => 'バックアップを保存しました';

  @override
  String get backupSaveFailed => 'バックアップを保存できませんでした。もう一度お試しください。';

  @override
  String get restoreFromFileTitle => 'ファイルから復元';

  @override
  String get restoreFromFileSubtitle => 'バックアップをデータに統合するか、データを置き換えます';

  @override
  String get backupReminderLabel => 'バックアップの通知';

  @override
  String get backupReminderSubtitle => '取引が20件を超えると30日ごとに通知します';

  @override
  String get backupReminderNever => 'データを守るためにバックアップを取りましょう';

  @override
  String backupReminderSince(String date) {
    return '前回のバックアップ: $date。そろそろ新しいバックアップはいかがですか?';
  }

  @override
  String get notNowTooltip => '今はしない';

  @override
  String get keptBackupsHeader => '自動バックアップ';

  @override
  String get keptBackupsHint => '復元の前にこの端末へ保存されたものです。';

  @override
  String get noKeptBackups => 'まだありません。';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の取引',
      one: '1件の取引',
    );
    return '$date・$_temp0';
  }

  @override
  String get restoreTitle => 'バックアップを復元';

  @override
  String get mergeOption => '統合';

  @override
  String get mergeOptionSubtitle =>
      '今のデータを残したままバックアップの内容を追加します。同じ記録がある場合は新しい方が優先されます。';

  @override
  String get replaceOption => '置き換え';

  @override
  String get replaceOptionSubtitle => '今のデータを削除し、バックアップとその設定だけを使用します。';

  @override
  String get restoreSafetyNote => '復元前に、現在のデータのコピーが自動バックアップに保存されます。';

  @override
  String get restoreButton => '復元';

  @override
  String get restoreKeptTitle => 'このコピーを復元しますか?';

  @override
  String restoreKeptMessage(String date) {
    return 'データが$dateのコピーに置き換わります。復元前に現在のデータのコピーが保存されます。';
  }

  @override
  String get backupInvalid => 'このファイルはMonthly Expensesのバックアップではありません。';

  @override
  String get backupTooNew =>
      'このバックアップは新しいバージョンのアプリで作成されました。アプリを更新してからもう一度お試しください。';

  @override
  String get backupOpenFailed => 'ファイルを開けませんでした。もう一度お試しください。';

  @override
  String get backupRestoreFailed => 'バックアップを復元できませんでした。データは変更されていません。';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の取引を復元しました',
      one: '1件の取引を復元しました',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return '統合しました: 追加$added件、更新$updated件、変更なし$unchanged件';
  }

  @override
  String get appLockLabel => 'アプリロック';

  @override
  String get appLockSubtitle => '指紋、顔、または画面ロックで解除します';

  @override
  String get appLockUnavailable => 'アプリロックを使うには、この端末で画面ロックを設定してください';

  @override
  String get appLockReason => 'Monthly Expensesのロックを解除';

  @override
  String get appLockTitle => 'Monthly Expenses';

  @override
  String get appLockPromptHint => '本人確認をしてください';

  @override
  String get appLockFailed => '本人確認ができませんでした。アプリロックは変更されていません。';

  @override
  String get lockedTitle => 'Monthly Expensesはロックされています';

  @override
  String get unlockButton => 'ロック解除';

  @override
  String get widgetShowAmountsLabel => 'ウィジェットに金額を表示';

  @override
  String get widgetShowAmountsSubtitle => 'アプリロックが有効な間、ホーム画面ウィジェットでは金額を隠します';

  @override
  String get widgetLeftLabel => '残り';

  @override
  String get widgetAddExpense => '支出を追加';

  @override
  String get widgetAddIncome => '収入を追加';

  @override
  String get widgetAmountsHidden => 'アプリロックにより金額は非表示です';

  @override
  String get notesTitle => 'メモ';

  @override
  String get addNoteTooltip => 'メモを追加';

  @override
  String get addNoteTitle => 'メモを追加';

  @override
  String get editNoteTitle => 'メモを編集';

  @override
  String get noteTextLabel => 'メモ';

  @override
  String get noteTextRequired => '内容を入力してください';

  @override
  String get noteAmountOptionalLabel => '金額(任意)';

  @override
  String get noteDueDateToggle => '期日を設定';

  @override
  String get noteDueDateLabel => '期日';

  @override
  String get noteReminderToggle => '通知する';

  @override
  String get noteReminderTimeLabel => '通知時刻';

  @override
  String get noteReminderTimeUnset => '時刻を選択';

  @override
  String get reminderMayBeLate => 'お使いのスマホが数分遅れて届けることがあります。';

  @override
  String get noteCategoryOptionalLabel => 'カテゴリー(任意)';

  @override
  String get noteCategoryNone => 'なし';

  @override
  String get recordNoteButton => '取引として記録';

  @override
  String get noteMarkDoneTooltip => '完了にする';

  @override
  String get noteMarkOpenTooltip => '未完了に戻す';

  @override
  String get notesEmptyTitle => 'まだ何もありません';

  @override
  String get notesEmptyMessage => 'メモには、日付・金額・カテゴリーを添えてやることや確認事項を残せます。';

  @override
  String get addNoteButton => 'メモを追加';

  @override
  String get notesOpenHeader => '未完了';

  @override
  String get notesDoneHeader => '完了';

  @override
  String get noteDeleted => 'メモを削除しました。';

  @override
  String get noteSaveFailed => 'メモを保存できませんでした。もう一度お試しください。';

  @override
  String get noteDeleteFailed => 'メモを削除できませんでした。もう一度お試しください。';

  @override
  String get noteRestoreFailed => 'メモを復元できませんでした。もう一度お試しください。';

  @override
  String get notesSearchHint => 'メモを検索';

  @override
  String get noteFilterAll => 'すべて';

  @override
  String get noteFilterOverdue => '期限切れ';

  @override
  String get noteFilterDueToday => '今日が期日';

  @override
  String get noteFilterUpcoming => '予定';

  @override
  String get noteFilterNoDate => '日付なし';

  @override
  String get noNoteResults => '一致するメモがありません。';

  @override
  String get noteLinkedTransactionLabel => '取引として記録済み';

  @override
  String get noteLinkedNoteLabel => 'メモから作成';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '期日のメモが$count件あります',
      one: '期日のメモが1件あります',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => '期日のメモ';

  @override
  String get noteReminderTitle => 'メモの通知';

  @override
  String get noteReminderLockedTitle => '期日のメモがあります';

  @override
  String get noteReminderChannelName => 'メモの通知';

  @override
  String get noteReminderPermissionDenied =>
      'メモの通知を受け取るには、システム設定で通知を有効にしてください。';

  @override
  String reportRange(String from, String to) {
    return '$from から $to';
  }

  @override
  String reportCreated(String when) {
    return '$whenに作成';
  }

  @override
  String reportNarrowedTo(String description) {
    return '絞り込み: $description';
  }

  @override
  String reportPageOf(int page, int pages) {
    return '$pagesページ中$pageページ目';
  }

  @override
  String get reportNet => '収支';

  @override
  String get reportMatchingIncome => '一致する収入';

  @override
  String get reportMatchingExpense => '一致する支出';

  @override
  String get reportMatchingNet => '一致する差額';

  @override
  String get reportOpeningBalance => '開始残高';

  @override
  String get reportClosingBalance => '終了残高';

  @override
  String get reportSpendingHeader => 'カテゴリー別支出';

  @override
  String get reportEarningHeader => 'カテゴリー別収入';

  @override
  String get reportTrendHeader => '推移';

  @override
  String get reportEntriesHeader => '取引';

  @override
  String get reportUpcomingHeader => '予定';

  @override
  String get reportUpcomingNote => '先の日付のため、上記の合計には含まれていません。';

  @override
  String get reportAmountColumn => '金額';

  @override
  String get reportShareColumn => '割合';

  @override
  String get reportBudgetColumn => '予算';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$limitのうち$used';
  }

  @override
  String get reportDetailsColumn => '詳細';

  @override
  String get reportEmpty => 'この期間に該当するデータはありません。';

  @override
  String get exportPdfMenu => 'PDFを書き出す';

  @override
  String get reportTitle => 'PDFを書き出す';

  @override
  String get reportNoFontTitle => 'この言語はまだ利用できません';

  @override
  String get reportNoFontBody =>
      'レポートには文字体系に合ったフォントが必要ですが、中国語・日本語・韓国語のフォントはアプリに含めるには大きすぎます。今後のバージョンでダウンロードできるようにします。';

  @override
  String get reportPreviewTitle => 'レポート';

  @override
  String get reportCoversHeader => '対象期間';

  @override
  String get reportNarrowedNotice => 'このレポートは検索に絞り込まれたままです。';

  @override
  String get reportRangePeriod => '今期';

  @override
  String get reportRangeCustom => '日付指定';

  @override
  String get reportRangeYear => '年';

  @override
  String get reportFromLabel => '開始日';

  @override
  String get reportToLabel => '終了日';

  @override
  String get reportYearLabel => '年';

  @override
  String get reportAccountLabel => '口座';

  @override
  String get reportAllAccounts => 'すべての口座';

  @override
  String get reportIncludeHeader => '含める内容';

  @override
  String get reportIncludeSubtitle => '共有したくない項目は外してください。';

  @override
  String get reportIncludeTransactions => '取引一覧';

  @override
  String get reportIncludeDetails => 'タイトルとメモ';

  @override
  String get reportIncludeAccounts => '口座名';

  @override
  String get reportCreateButton => 'レポートを作成';

  @override
  String get reportBuilding => 'レポートを作成しています';

  @override
  String get reportFailed => 'レポートを作成できませんでした。もう一度お試しください。';

  @override
  String get reportRangeBackwards => '開始日は終了日より前にしてください。';

  @override
  String get importTitle => 'CSVを読み込む';

  @override
  String get importSubtitle => '他のアプリから取引を取り込みます';

  @override
  String get importIntro =>
      'CSVファイルを選ぶと、追加する前にアプリがどう読み取ったかを確認できます。読み込みは記録の追加のみを行い、既存のデータを置き換えたり削除したりすることはありません。';

  @override
  String get importChooseFile => 'ファイルを選択';

  @override
  String get importChooseAnother => '別のファイルを選択';

  @override
  String get importReadFailed => 'そのファイルを読み込めませんでした。もう一度お試しください。';

  @override
  String get importRefusedEmpty => 'そのファイルには何もありません。';

  @override
  String get importRefusedNoDate => '日付として読み取れる列がないため、読み込めません。';

  @override
  String get importRefusedNoAmount => '金額として読み取れる列がないため、読み込めません。';

  @override
  String get importRefusedNoRows => '読み取れる行がないため、読み込む内容がありません。';

  @override
  String get importColumnsHeader => '列';

  @override
  String get importColumnsSubtitle => 'アプリの読み取りが誤っている場合は変更してください。';

  @override
  String get importColumnNone => '使用しない';

  @override
  String get importFieldType => '種類';

  @override
  String get importFieldToAccount => '振替先口座';

  @override
  String get importFieldTitle => 'タイトル';

  @override
  String get importFieldNote => 'メモ';

  @override
  String get importDateOrderLabel => '03/04のような日付の意味';

  @override
  String get importDayFirst => '日が先';

  @override
  String get importMonthFirst => '月が先';

  @override
  String get importCountsHeader => '実行内容';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count行を読み込みます',
      one: '1行を読み込みます',
      zero: '読み込む内容はありません',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count行は日付が読み取れません',
      one: '1行は日付が読み取れません',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count行は金額が読み取れません',
      one: '1行は金額が読み取れません',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count行は金額が0です',
      one: '1行は金額が0です',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count行はすでにアプリにあります',
      one: '1行はすでにアプリにあります',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の振替は口座が1つしか指定されていません',
      one: '1件の振替は口座が1つしか指定されていません',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => '日付が読み取れません';

  @override
  String get importRowUnreadableAmount => '金額が読み取れません';

  @override
  String get importRowZero => '金額が0です';

  @override
  String get importRowAlreadyThere => 'すでにアプリにあります';

  @override
  String get importRowIncompleteTransfer => '口座が1つしか指定されていません';

  @override
  String get importNamesHeader => 'アプリにない名前';

  @override
  String get importNamesSubtitle =>
      'それぞれの扱いを選んでください。読み込みでカテゴリーや口座が新規作成されることはありません。';

  @override
  String get importRowsHeader => 'アプリが読み取った最初の行';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ほか$count件',
      one: 'ほか1件',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count行を読み込む',
      one: '1行を読み込む',
      zero: '読み込む内容がありません',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件を読み込みました',
      one: '1件を読み込みました',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'そのファイルを読み込めませんでした。何も追加されていません。';

  @override
  String get attachmentsLabel => '添付';

  @override
  String get photoLabel => '写真';

  @override
  String get photoAdd => '写真を追加';

  @override
  String get photoTake => '写真を撮る';

  @override
  String get photoChoose => '写真を選ぶ';

  @override
  String get photoRemove => '写真を削除';

  @override
  String get photoMissing => 'この写真は見つかりません。';

  @override
  String get voiceNoteLabel => '音声メモ';

  @override
  String get voiceRecord => '音声メモを録音';

  @override
  String voiceRecording(int seconds) {
    return '録音中、残り$seconds秒';
  }

  @override
  String get voiceStop => '停止';

  @override
  String get voicePlay => '再生';

  @override
  String get voicePause => '一時停止';

  @override
  String get voiceRemove => '音声メモを削除';

  @override
  String get voiceMissing => 'この音声メモは見つかりません。';

  @override
  String get microphoneRefused => 'このアプリはマイクの使用が許可されていません。';

  @override
  String backupIncludesAttachments(String size) {
    return '添付ファイルを含む、$size MB';
  }

  @override
  String get removeAdsBody =>
      '一度の支払いで、すべての広告を非表示にします。ストアアカウントに紐づくので、機種変更や再インストール後も引き継がれます。';

  @override
  String removeAdsBuyButton(String price) {
    return '$priceで広告を削除';
  }

  @override
  String get removeAdsOwned => '広告はオフになっています。ありがとうございます。';

  @override
  String get removeAdsPending => 'ストアの応答を待っています…';

  @override
  String get removeAdsUnavailable => '現在、購入可能な商品がありません。しばらくしてからもう一度お試しください。';

  @override
  String get removeAdsFailed => '処理は完了しませんでした。料金は発生していません。';

  @override
  String get restorePurchasesButton => '購入を復元';

  @override
  String get payNothingWithheld => '広告の有無にかかわらず、すべての機能は無料でご利用いただけます。';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => '近日公開';

  @override
  String get plusBody => '銀行口座と連携し、取引を自動で取り込んで確認できる機能です。まだ開発中のため、購入はできません。';

  @override
  String get privacyOptionsTitle => 'プライバシー設定';

  @override
  String get privacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get privacyOptionsSubtitle => 'パーソナライズ広告の設定を変更';

  @override
  String get dueEntryReminderTitle => '入力期限が来ました';

  @override
  String get dueEntryChannelName => '期限切れの入力';

  @override
  String dueEntryReminderOne(String title) {
    return '$titleは本日期限でしたが、まだ未対応です。';
  }

  @override
  String get dueEntryReminderUntitled => '定期入力の期限が今日でしたが、まだ未対応です。';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '本日期限の定期入力が$count件あります。',
      one: '本日期限の定期入力が$count件あります。',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => '今日は何も記録されていません';

  @override
  String get emptyDayChannelName => '記録のない日';

  @override
  String get emptyDayReminderBody => '忘れないうちに支出を記録しましょう。';

  @override
  String get reminderLockedTitle => '何かが待っています';

  @override
  String get nudgeSettingsTitle => '記録がない日に通知する';

  @override
  String get nudgeSettingsSubtitle => '夜に一度だけ、何も記録がない日に通知します。';

  @override
  String get nudgeOfferTitle => '忘れがちな日に、ひと押ししましょうか？';

  @override
  String get nudgeOfferBody => '好きな時間に一度だけ、何も記録がない日に通知します。いつでもオフにできます。';

  @override
  String get nudgeOfferYes => 'はい、通知してほしい';

  @override
  String get nudgeOfferNo => 'いいえ、結構です';

  @override
  String get nudgeStoppedNotice => '3回応答がなかったため通知を停止しました。いつでも再開できます。';

  @override
  String get nudgePermissionDenied => 'リマインダーには、設定で通知をオンにしてください。';

  @override
  String get updateDownloadedMessage => 'アップデートをダウンロードしました。';

  @override
  String get updateRestartButton => '再起動';
}
