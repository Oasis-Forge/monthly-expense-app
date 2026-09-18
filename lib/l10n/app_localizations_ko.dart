// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => '설정';

  @override
  String get transferTooltip => '이체';

  @override
  String get searchTooltip => '검색';

  @override
  String get addButton => '추가';

  @override
  String get emptyPeriod => '이 기간에는 아직 내역이 없어요.';

  @override
  String get balanceLabel => '잔액';

  @override
  String get periodNetLabel => '이번 기간';

  @override
  String carriedForwardLine(String amount) {
    return '이월 $amount';
  }

  @override
  String get incomeLabel => '수입';

  @override
  String get expenseLabel => '지출';

  @override
  String upcomingCategory(String category) {
    return '$category · 예정';
  }

  @override
  String get upcomingLabel => '예정';

  @override
  String detailAdded(String date) {
    return '$date에 추가됨';
  }

  @override
  String detailChanged(String date) {
    return '$date에 마지막 수정';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '반복 거래 $count건이 도래했어요',
      one: '반복 거래 1건이 도래했어요',
    );
    return '$_temp0';
  }

  @override
  String budgetsOverNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '예산 $count건이 한도를 초과했어요',
      one: '예산 1건이 한도를 초과했어요',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent 사용 · $over건 초과',
      one: '$percent 사용 · 1건 초과',
      zero: '$percent 사용',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '예산 $count건 설정됨',
      one: '예산 1건 설정됨',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => '거래를 삭제하지 못했어요. 다시 시도해 주세요.';

  @override
  String get transactionDeleted => '거래가 삭제되었어요';

  @override
  String get transferDeleted => '이체가 삭제되었어요';

  @override
  String get undoButton => '실행 취소';

  @override
  String get undoFailed => '실행 취소하지 못했어요. 다시 시도해 주세요.';

  @override
  String get restoreFailed => '거래를 복원하지 못했어요. 다시 시도해 주세요.';

  @override
  String get addTransactionTitle => '거래 추가';

  @override
  String get editTransactionTitle => '거래 수정';

  @override
  String get transactionDetailTitle => '상세 정보';

  @override
  String get editTooltip => '수정';

  @override
  String get deleteTooltip => '삭제';

  @override
  String get duplicateTooltip => '복제';

  @override
  String get titleOptionalLabel => '제목 (선택)';

  @override
  String get amountLabel => '금액';

  @override
  String get amountRequired => '금액을 입력하세요';

  @override
  String get amountInvalid => '올바른 금액을 입력하세요';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => '지우기';

  @override
  String get hideKeypadTooltip => '키패드 숨기기';

  @override
  String get categoryLabel => '카테고리';

  @override
  String get categoryRequired => '카테고리를 선택하세요';

  @override
  String get accountLabel => '계좌';

  @override
  String get accountRequired => '계좌를 선택하세요';

  @override
  String get dateLabel => '날짜';

  @override
  String get noteLabel => '메모';

  @override
  String get previousDayTooltip => '전날';

  @override
  String get nextDayTooltip => '다음 날';

  @override
  String get noteOptionalLabel => '메모 (선택)';

  @override
  String get saveChangesButton => '변경 사항 저장';

  @override
  String get addTransactionButton => '거래 추가';

  @override
  String get saveAndAddAnotherButton => '저장 후 계속 추가';

  @override
  String get transactionAdded => '거래가 추가되었어요';

  @override
  String get saveFailed => '거래를 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get noExpensesInPeriod => '이 기간에는 아직 지출이 없어요.';

  @override
  String totalSpent(String amount) {
    return '총 지출: $amount';
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
  String get settingsTitle => '설정';

  @override
  String get drawerAddHeader => '추가';

  @override
  String get drawerAddExpense => '지출 추가';

  @override
  String get drawerAddIncome => '수입 추가';

  @override
  String get drawerPlanHeader => '계획';

  @override
  String get drawerReviewHeader => '돌아보기';

  @override
  String get drawerSpending => '카테고리별 지출';

  @override
  String get drawerManageHeader => '관리';

  @override
  String get drawerDataHeader => '데이터';

  @override
  String get currencyLabel => '통화';

  @override
  String get currencySearchHint => '통화 검색';

  @override
  String changeCurrencyTitle(String code) {
    return '통화를 $code(으)로 변경할까요?';
  }

  @override
  String get changeCurrencyMessage => '금액은 그대로 유지되고 통화 표시만 바뀌어요.';

  @override
  String get changeButton => '변경';

  @override
  String get cancelButton => '취소';

  @override
  String get saveButton => '저장';

  @override
  String get removeButton => '제거';

  @override
  String get themeLabel => '테마';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get languageLabel => '언어';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get monthStartLabel => '매월 시작일';

  @override
  String get monthStartLastDay => '마지막 날';

  @override
  String get showCarriedForwardLabel => '잔액 이월';

  @override
  String get showCarriedForwardSubtitle => '각 기간이 이전 잔액에서 시작돼요';

  @override
  String get trashTitle => '휴지통';

  @override
  String get trashEmpty => '휴지통이 비어 있어요.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days일 후 완전히 삭제',
      one: '1일 후 완전히 삭제',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => '복원';

  @override
  String get categoriesTitle => '카테고리';

  @override
  String get addCategoryTooltip => '카테고리 추가';

  @override
  String get addCategoryTitle => '카테고리 추가';

  @override
  String get editCategoryTitle => '카테고리 수정';

  @override
  String get categoryNameLabel => '이름';

  @override
  String get categoryNameRequired => '이름을 입력하세요';

  @override
  String get categoryNameTaken => '이미 사용 중인 이름이에요';

  @override
  String get archiveAction => '보관';

  @override
  String get unarchiveAction => '보관 해제';

  @override
  String get deleteAction => '삭제';

  @override
  String get archivedHeader => '보관됨';

  @override
  String get categorySaveFailed => '카테고리를 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get accountsTitle => '계좌';

  @override
  String get accountCash => '현금';

  @override
  String get accountTypeLabel => '유형';

  @override
  String get accountTypeCash => '현금';

  @override
  String get accountTypeBank => '은행';

  @override
  String get accountTypeCard => '카드';

  @override
  String get accountTypeOther => '기타';

  @override
  String get addAccountTooltip => '계좌 추가';

  @override
  String get addAccountTitle => '계좌 추가';

  @override
  String get editAccountTitle => '계좌 수정';

  @override
  String get openingBalanceLabel => '시작 잔액';

  @override
  String get openingDateLabel => '시작일';

  @override
  String get accountSaveFailed => '계좌를 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get transferTitle => '이체';

  @override
  String get editTransferTitle => '이체 수정';

  @override
  String get transferLabel => '이체';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => '보내는 계좌';

  @override
  String get toAccountLabel => '받는 계좌';

  @override
  String get sameAccountError => '서로 다른 계좌 두 개를 선택하세요';

  @override
  String get needTwoAccounts => '계좌 간 이체를 하려면 두 번째 계좌를 추가하세요.';

  @override
  String get addTransferButton => '이체 추가';

  @override
  String get transferSaveFailed => '이체를 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get searchHint => '거래 검색';

  @override
  String get allTypesFilter => '전체';

  @override
  String get allCategoriesFilter => '모든 카테고리';

  @override
  String get allAccountsFilter => '모든 계좌';

  @override
  String get allTimeFilter => '전체 기간';

  @override
  String get clearDatesTooltip => '날짜 지우기';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '결과 $count건',
      one: '결과 1건',
    );
    return '$_temp0 · 수입 $income · 지출 $expense';
  }

  @override
  String get noSearchResults => '일치하는 거래가 없어요.';

  @override
  String get budgetsTitle => '예산';

  @override
  String get budgetsTooltip => '예산';

  @override
  String get overallBudget => '전체';

  @override
  String get noBudget => '예산 없음';

  @override
  String budgetsHint(String period) {
    return '한도는 $period부터 적용돼요. 이전 기간은 기존 한도를 유지해요.';
  }

  @override
  String get budgetLimitLabel => '기간별 한도';

  @override
  String get budgetSaveFailed => '예산을 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$limit 중 $spent';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining 남음 · 하루 $perDay';
  }

  @override
  String budgetLeft(String remaining) {
    return '$remaining 남음';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount 초과';
  }

  @override
  String get budgetLimitReached => '한도 도달';

  @override
  String budgetLimitOnly(String limit) {
    return '한도 $limit';
  }

  @override
  String get recurringTitle => '반복';

  @override
  String get addRecurringTooltip => '반복 추가';

  @override
  String get addRecurringTitle => '반복 추가';

  @override
  String get editRecurringTitle => '반복 수정';

  @override
  String get dueHeader => '도래';

  @override
  String get upcomingHeader => '앞으로 30일';

  @override
  String get rulesHeader => '규칙';

  @override
  String get nothingUpcoming => '앞으로 30일 안에는 없어요.';

  @override
  String get noRules => '아직 반복 거래가 없어요.';

  @override
  String get postButton => '등록';

  @override
  String get skipButton => '건너뛰기';

  @override
  String get postFailed => '거래를 등록하지 못했어요. 다시 시도해 주세요.';

  @override
  String get recurringSaveFailed => '반복 거래를 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get everyLabel => '매';

  @override
  String get frequencyDays => '일';

  @override
  String get frequencyWeeks => '주';

  @override
  String get frequencyMonths => '개월';

  @override
  String get frequencyYears => '년';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일마다',
      one: '매일',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count주마다',
      one: '매주',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개월마다',
      one: '매월',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count년마다',
      one: '매년',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · 일시중지';
  }

  @override
  String get startsLabel => '시작';

  @override
  String get endsLabel => '종료';

  @override
  String get endNever => '없음';

  @override
  String get endAfter => '횟수 지정';

  @override
  String get endOnDate => '날짜 지정';

  @override
  String get timesLabel => '횟수';

  @override
  String get endsOnLabel => '종료일';

  @override
  String get wholeNumberInvalid => '1 이상의 정수를 입력하세요';

  @override
  String get endDateInvalid => '종료일은 시작일 이후여야 해요';

  @override
  String get autoPostLabel => '자동 등록';

  @override
  String get autoPostSubtitle => '끄면 탭할 때까지 도래 목록에서 대기해요';

  @override
  String get pauseTooltip => '일시중지';

  @override
  String get resumeTooltip => '재개';

  @override
  String get categoryFood => '식비';

  @override
  String get categoryGroceries => '장보기';

  @override
  String get categoryTransport => '교통';

  @override
  String get categoryShopping => '쇼핑';

  @override
  String get categoryBills => '공과금';

  @override
  String get categoryRent => '월세';

  @override
  String get categoryHealth => '의료';

  @override
  String get categoryEducation => '교육';

  @override
  String get categoryEntertainment => '여가';

  @override
  String get categorySalary => '급여';

  @override
  String get categoryBusiness => '사업';

  @override
  String get categoryInvestment => '투자';

  @override
  String get categoryGift => '선물';

  @override
  String get categoryOther => '기타';

  @override
  String get previousPeriodTooltip => '이전 기간';

  @override
  String get nextPeriodTooltip => '다음 기간';

  @override
  String get insightsTooltip => '분석';

  @override
  String get insightsTitle => '분석';

  @override
  String get calendarTab => '달력';

  @override
  String get trendTab => '추이';

  @override
  String get noIncomeInPeriod => '이 기간에는 아직 수입이 없어요.';

  @override
  String totalIncome(String amount) {
    return '총 수입: $amount';
  }

  @override
  String get calendarHint => '날짜를 탭하면 그날의 거래를 볼 수 있어요.';

  @override
  String get dayEmpty => '이날은 내역이 없어요.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개월',
      one: '1개월',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return '수입 $income · 지출 $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return '기간당 평균 · 수입 $income · 지출 $expense';
  }

  @override
  String get weekStartLabel => '매주 시작 요일';

  @override
  String weekStartDefault(String day) {
    return '기본값 ($day)';
  }

  @override
  String get firstRunTitle => 'Monthly Expenses에 오신 것을 환영해요';

  @override
  String get firstRunMessage => '수입과 지출을 기록해 보세요. 데이터는 이 기기에만 저장돼요.';

  @override
  String get addFirstTransactionButton => '첫 거래 추가';

  @override
  String get setupIntro => '언어와 통화를 선택하세요. 나중에 설정에서 바꿀 수 있어요.';

  @override
  String get setupContinueButton => '계속';

  @override
  String get setupRestoreTitle => '백업 복원';

  @override
  String get setupRestoreSubtitle => '백업 파일에서 데이터와 설정을 복원해요';

  @override
  String get walkthroughEntryTitle => '몇 초 만에 추가';

  @override
  String get walkthroughEntryBody => '계산이 되는 키패드, 영수증 사진, 입력이 느릴 땐 음성 메모까지.';

  @override
  String get walkthroughPlanTitle => '한 달을 계획하기';

  @override
  String get walkthroughPlanBody => '카테고리별 예산, 저절로 반복되는 청구서, 알려주는 메모까지.';

  @override
  String get walkthroughInsightsTitle => '어디로 쓰였는지 확인';

  @override
  String get walkthroughInsightsBody => '차트, 달력, 원하는 기간의 PDF·CSV 보고서까지.';

  @override
  String get walkthroughPrivacyTitle => '오직 나만을 위해';

  @override
  String get walkthroughPrivacyBody =>
      '계정이 필요 없습니다. 기록한 내용은 이 휴대폰에만 남고, 앱을 지원하는 광고에는 전달되지 않습니다.';

  @override
  String get walkthroughBringTitle => '쓰던 데이터 그대로';

  @override
  String get walkthroughBringBody =>
      '다른 앱이나 다른 폰에서 오셨나요? 빈 앱 대신 백업이나 CSV로 시작하세요.';

  @override
  String get firstRunRestoreTitle => '이 백업을 복원할까요?';

  @override
  String get firstRunRestoreMessage => '앱의 모든 내용이 교체되고, 백업 당시의 언어와 통화로 돌아가요.';

  @override
  String get walkthroughNextButton => '다음';

  @override
  String get walkthroughStartButton => '시작하기';

  @override
  String get walkthroughDoneButton => '완료';

  @override
  String walkthroughProgress(int current, int total) {
    return '$total 중 $current페이지';
  }

  @override
  String get walkthroughReplayTitle => '둘러보기 다시 보기';

  @override
  String get walkthroughReplaySubtitle => '처음 앱을 켰을 때 보여준 네 페이지예요';

  @override
  String get removeAdsTitle => '광고 제거';

  @override
  String get exportCsvMenu => 'CSV 내보내기';

  @override
  String get exportCsvTooltip => 'CSV 내보내기';

  @override
  String get csvExported => 'CSV가 저장되었어요';

  @override
  String get csvExportFailed => 'CSV를 내보내지 못했어요. 다시 시도해 주세요.';

  @override
  String get backupTitle => '백업 및 복원';

  @override
  String get backupIntro => '백업은 원하는 위치에 저장하는 파일이에요. 자동으로 업로드되거나 전송되지 않아요.';

  @override
  String get backUpNowTitle => '지금 백업하기';

  @override
  String lastBackupLine(String date) {
    return '마지막 백업 $date';
  }

  @override
  String get neverBackedUp => '아직 백업이 없어요';

  @override
  String get backupSaved => '백업이 저장되었어요';

  @override
  String get backupSaveFailed => '백업을 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get restoreFromFileTitle => '파일에서 복원';

  @override
  String get restoreFromFileSubtitle => '백업을 기존 데이터와 병합하거나, 기존 데이터를 백업으로 교체해요';

  @override
  String get backupReminderLabel => '백업 알림';

  @override
  String get backupReminderSubtitle => '거래 20건이 넘으면 30일마다';

  @override
  String get backupReminderNever => '데이터를 안전하게 지키려면 백업하세요';

  @override
  String backupReminderSince(String date) {
    return '마지막 백업 $date. 새로 백업할까요?';
  }

  @override
  String get notNowTooltip => '나중에';

  @override
  String get keptBackupsHeader => '자동 백업';

  @override
  String get keptBackupsHint => '복원 전에 이 기기에 저장돼요.';

  @override
  String get noKeptBackups => '아직 없어요.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '거래 $count건',
      one: '거래 1건',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => '백업 복원';

  @override
  String get mergeOption => '병합';

  @override
  String get mergeOptionSubtitle =>
      '기존 데이터를 유지하면서 백업 데이터를 추가해요. 같은 기록이 있으면 더 최근에 바뀐 쪽이 남아요.';

  @override
  String get replaceOption => '교체';

  @override
  String get replaceOptionSubtitle => '기존 데이터를 지우고 백업 데이터와 설정만 사용해요.';

  @override
  String get restoreSafetyNote => '현재 데이터의 사본이 먼저 자동 백업에 저장돼요.';

  @override
  String get restoreButton => '복원';

  @override
  String get restoreKeptTitle => '이 사본을 복원할까요?';

  @override
  String restoreKeptMessage(String date) {
    return '데이터가 $date의 사본으로 교체돼요. 현재 데이터의 사본이 먼저 저장돼요.';
  }

  @override
  String get backupInvalid => '이 파일은 Monthly Expenses 백업이 아니에요.';

  @override
  String get backupTooNew => '이 백업은 더 최신 버전의 앱에서 만들어졌어요. 앱을 업데이트한 뒤 다시 시도하세요.';

  @override
  String get backupOpenFailed => '파일을 열지 못했어요. 다시 시도해 주세요.';

  @override
  String get backupRestoreFailed => '백업을 복원하지 못했어요. 데이터는 바뀌지 않았어요.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '거래 $count건을 복원했어요',
      one: '거래 1건을 복원했어요',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return '병합 완료: 추가 $added건, 수정 $updated건, 변경 없음 $unchanged건';
  }

  @override
  String get appLockLabel => '앱 잠금';

  @override
  String get appLockSubtitle => '지문, 얼굴, 또는 화면 잠금으로 잠금 해제해요';

  @override
  String get appLockUnavailable => '앱 잠금을 사용하려면 이 기기에 화면 잠금을 설정하세요';

  @override
  String get appLockReason => 'Monthly Expenses 잠금 해제';

  @override
  String get appLockFailed => '본인 확인에 실패했어요. 앱 잠금이 변경되지 않았어요.';

  @override
  String get lockedTitle => 'Monthly Expenses가 잠겨 있어요';

  @override
  String get unlockButton => '잠금 해제';

  @override
  String get widgetShowAmountsLabel => '위젯에 금액 표시';

  @override
  String get widgetShowAmountsSubtitle => '앱 잠금이 켜져 있으면 홈 화면 위젯에서 금액이 숨겨져요';

  @override
  String get widgetLeftLabel => '남음';

  @override
  String get widgetAddExpense => '지출 추가';

  @override
  String get widgetAddIncome => '수입 추가';

  @override
  String get widgetAmountsHidden => '앱 잠금으로 금액이 숨겨져 있어요';

  @override
  String get notesTitle => '메모';

  @override
  String get addNoteTooltip => '메모 추가';

  @override
  String get addNoteTitle => '메모 추가';

  @override
  String get editNoteTitle => '메모 수정';

  @override
  String get noteTextLabel => '메모';

  @override
  String get noteTextRequired => '내용을 입력하세요';

  @override
  String get noteAmountOptionalLabel => '금액 (선택)';

  @override
  String get noteDueDateToggle => '기한 설정';

  @override
  String get noteDueDateLabel => '기한';

  @override
  String get noteReminderToggle => '알림 받기';

  @override
  String get noteReminderTimeLabel => '알림 시간';

  @override
  String get noteReminderTimeUnset => '시간을 선택하세요';

  @override
  String get noteCategoryOptionalLabel => '카테고리 (선택)';

  @override
  String get noteCategoryNone => '없음';

  @override
  String get recordNoteButton => '거래로 기록';

  @override
  String get noteMarkDoneTooltip => '완료로 표시';

  @override
  String get noteMarkOpenTooltip => '미완료로 표시';

  @override
  String get notesEmptyTitle => '아직 아무것도 없어요';

  @override
  String get notesEmptyMessage =>
      '할 일이나 확인할 것을 메모로 남겨 두세요. 날짜, 금액, 카테고리는 선택 사항이에요.';

  @override
  String get addNoteButton => '메모 추가';

  @override
  String get notesOpenHeader => '미완료';

  @override
  String get notesDoneHeader => '완료';

  @override
  String get noteDeleted => '메모가 삭제되었어요.';

  @override
  String get noteSaveFailed => '메모를 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get noteDeleteFailed => '메모를 삭제하지 못했어요. 다시 시도해 주세요.';

  @override
  String get noteRestoreFailed => '메모를 복원하지 못했어요. 다시 시도해 주세요.';

  @override
  String get notesSearchHint => '메모 검색';

  @override
  String get noteFilterAll => '전체';

  @override
  String get noteFilterOverdue => '기한 지남';

  @override
  String get noteFilterDueToday => '오늘 마감';

  @override
  String get noteFilterUpcoming => '예정';

  @override
  String get noteFilterNoDate => '날짜 없음';

  @override
  String get noNoteResults => '일치하는 메모가 없어요.';

  @override
  String get noteLinkedTransactionLabel => '거래로 기록됨';

  @override
  String get noteLinkedNoteLabel => '메모에서 생성됨';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '메모 $count건이 도래했어요',
      one: '메모 1건이 도래했어요',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => '도래한 메모';

  @override
  String get noteReminderTitle => '메모 알림';

  @override
  String get noteReminderLockedTitle => '메모 기한이 되었어요';

  @override
  String get noteReminderPermissionDenied => '메모 알림을 받으려면 시스템 설정에서 알림을 켜세요.';

  @override
  String reportRange(String from, String to) {
    return '$from ~ $to';
  }

  @override
  String reportCreated(String when) {
    return '$when 생성됨';
  }

  @override
  String reportPageOf(int page, int pages) {
    return '$pages 중 $page페이지';
  }

  @override
  String get reportNet => '순액';

  @override
  String get reportOpeningBalance => '시작 잔액';

  @override
  String get reportClosingBalance => '마감 잔액';

  @override
  String get reportSpendingHeader => '카테고리별 지출';

  @override
  String get reportEarningHeader => '카테고리별 수입';

  @override
  String get reportTrendHeader => '추이';

  @override
  String get reportEntriesHeader => '거래 내역';

  @override
  String get reportUpcomingHeader => '예정';

  @override
  String get reportUpcomingNote => '날짜가 앞으로라서 위 합계에는 포함되지 않았어요.';

  @override
  String get reportAmountColumn => '금액';

  @override
  String get reportShareColumn => '비중';

  @override
  String get reportBudgetColumn => '예산';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$limit 중 $used';
  }

  @override
  String get reportDetailsColumn => '상세';

  @override
  String get reportEmpty => '이 날짜에는 보고할 내용이 없어요.';

  @override
  String get exportPdfMenu => 'PDF 내보내기';

  @override
  String get reportTitle => 'PDF 내보내기';

  @override
  String get reportNoFontTitle => '이 언어는 아직 지원되지 않습니다';

  @override
  String get reportNoFontBody =>
      '보고서에는 해당 문자의 글꼴이 필요하지만, 중국어·일본어·한국어 글꼴은 앱에 포함하기에 너무 큽니다. 다음 버전에서 내려받을 수 있게 할 예정입니다.';

  @override
  String get reportPreviewTitle => '보고서';

  @override
  String get reportCoversHeader => '포함 범위';

  @override
  String get reportRangePeriod => '이번 기간';

  @override
  String get reportRangeCustom => '날짜';

  @override
  String get reportRangeYear => '연도';

  @override
  String get reportFromLabel => '시작';

  @override
  String get reportToLabel => '종료';

  @override
  String get reportYearLabel => '연도';

  @override
  String get reportAccountLabel => '계좌';

  @override
  String get reportAllAccounts => '모든 계좌';

  @override
  String get reportIncludeHeader => '포함 항목';

  @override
  String get reportIncludeSubtitle => '공유하고 싶지 않은 항목은 빼세요.';

  @override
  String get reportIncludeTransactions => '거래 목록';

  @override
  String get reportIncludeDetails => '제목과 메모';

  @override
  String get reportIncludeAccounts => '계좌 이름';

  @override
  String get reportCreateButton => '보고서 만들기';

  @override
  String get reportBuilding => '보고서 만드는 중';

  @override
  String get reportFailed => '보고서를 만들지 못했어요. 다시 시도해 주세요.';

  @override
  String get reportRangeBackwards => '시작일이 종료일보다 앞서야 해요.';

  @override
  String get importTitle => 'CSV 가져오기';

  @override
  String get importSubtitle => '다른 앱에서 거래 데이터를 가져와요';

  @override
  String get importIntro =>
      'CSV 파일을 선택하면 추가되기 전에 앱이 어떻게 읽었는지 볼 수 있어요. 가져오기는 기록을 추가만 할 뿐, 기존 데이터를 교체하거나 삭제하지 않아요.';

  @override
  String get importChooseFile => '파일 선택';

  @override
  String get importChooseAnother => '다른 파일 선택';

  @override
  String get importReadFailed => '파일을 읽지 못했어요. 다시 시도해 주세요.';

  @override
  String get importRefusedEmpty => '그 파일에는 내용이 없어요.';

  @override
  String get importRefusedNoDate => '그 파일에서 날짜로 읽을 수 있는 열이 없어서 가져올 수 없어요.';

  @override
  String get importRefusedNoAmount => '그 파일에서 금액으로 읽을 수 있는 열이 없어서 가져올 수 없어요.';

  @override
  String get importRefusedNoRows => '그 파일의 행을 하나도 읽을 수 없어서 가져올 내용이 없어요.';

  @override
  String get importColumnsHeader => '열';

  @override
  String get importColumnsSubtitle => '앱이 잘못 읽은 부분을 바꾸세요.';

  @override
  String get importColumnNone => '사용 안 함';

  @override
  String get importFieldType => '유형';

  @override
  String get importFieldToAccount => '받는 계좌';

  @override
  String get importFieldTitle => '제목';

  @override
  String get importFieldNote => '메모';

  @override
  String get importDateOrderLabel => '03/04 같은 날짜는';

  @override
  String get importDayFirst => '일 먼저';

  @override
  String get importMonthFirst => '월 먼저';

  @override
  String get importCountsHeader => '진행될 내용';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 행을 가져와요',
      one: '1개 행을 가져와요',
      zero: '가져올 항목이 없어요',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 행의 날짜를 읽을 수 없어요',
      one: '1개 행의 날짜를 읽을 수 없어요',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 행의 금액을 읽을 수 없어요',
      one: '1개 행의 금액을 읽을 수 없어요',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 행은 금액이 전혀 없어요',
      one: '1개 행은 금액이 전혀 없어요',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 행은 이미 앱에 있어요',
      one: '1개 행은 이미 앱에 있어요',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이체 $count건에 계좌가 하나만 있어요',
      one: '이체 1건에 계좌가 하나만 있어요',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => '날짜를 읽을 수 없어요';

  @override
  String get importRowUnreadableAmount => '금액을 읽을 수 없어요';

  @override
  String get importRowZero => '금액이 전혀 없어요';

  @override
  String get importRowAlreadyThere => '이미 앱에 있어요';

  @override
  String get importRowIncompleteTransfer => '계좌가 하나만 있어요';

  @override
  String get importNamesHeader => '앱에 없는 이름';

  @override
  String get importNamesSubtitle =>
      '각 항목이 무엇이 될지 선택하세요. 가져오기는 카테고리나 계좌를 새로 만들지 않아요.';

  @override
  String get importRowsHeader => '앱이 읽은 첫 행들';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '외 $count개',
      one: '외 1개',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 행 가져오기',
      one: '1개 행 가져오기',
      zero: '가져올 항목 없음',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count건 가져왔어요',
      one: '1건 가져왔어요',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => '그 파일을 가져오지 못했어요. 아무것도 추가되지 않았어요.';

  @override
  String get attachmentsLabel => '첨부 파일';

  @override
  String get photoLabel => '사진';

  @override
  String get photoAdd => '사진 추가';

  @override
  String get photoTake => '사진 촬영';

  @override
  String get photoChoose => '사진 선택';

  @override
  String get photoRemove => '사진 제거';

  @override
  String get photoMissing => '이 사진을 찾을 수 없어요.';

  @override
  String get voiceNoteLabel => '음성 메모';

  @override
  String get voiceRecord => '음성 메모 녹음';

  @override
  String voiceRecording(int seconds) {
    return '녹음 중, $seconds초 남음';
  }

  @override
  String get voiceStop => '정지';

  @override
  String get voicePlay => '재생';

  @override
  String get voicePause => '일시정지';

  @override
  String get voiceRemove => '음성 메모 제거';

  @override
  String get voiceMissing => '이 음성 메모를 찾을 수 없어요.';

  @override
  String get microphoneRefused => '이 앱에서 마이크가 꺼져 있어요.';

  @override
  String backupIncludesAttachments(String size) {
    return '첨부 파일 포함, ${size}MB';
  }

  @override
  String get removeAdsBody =>
      '한 번 결제하면 모든 광고가 사라집니다. 스토어 계정에 연결되어 있어 기기를 바꾸거나 재설치해도 유지됩니다.';

  @override
  String removeAdsBuyButton(String price) {
    return '$price에 광고 제거';
  }

  @override
  String get removeAdsOwned => '광고가 꺼졌습니다. 감사합니다.';

  @override
  String get removeAdsPending => '스토어 응답을 기다리는 중…';

  @override
  String get removeAdsUnavailable => '현재 구매할 수 있는 상품이 없습니다. 나중에 다시 시도해 주세요.';

  @override
  String get removeAdsFailed => '결제가 완료되지 않았고, 요금도 청구되지 않았습니다.';

  @override
  String get restorePurchasesButton => '구매 복원';

  @override
  String get payNothingWithheld => '광고 유무와 상관없이 모든 기능은 무료로 이용할 수 있습니다.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => '출시 예정';

  @override
  String get plusBody =>
      '은행 계좌를 연결해 거래 내역을 가져와 확인할 수 있는 기능입니다. 아직 완성되지 않아 구매할 수 없습니다.';

  @override
  String get privacyOptionsTitle => '개인정보 보호 옵션';

  @override
  String get privacyOptionsSubtitle => '맞춤 광고 설정 변경';
}
