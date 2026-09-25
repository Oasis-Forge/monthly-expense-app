// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'การตั้งค่า';

  @override
  String get transferTooltip => 'โอนเงิน';

  @override
  String get searchTooltip => 'ค้นหา';

  @override
  String get addButton => 'เพิ่ม';

  @override
  String get emptyPeriod => 'ยังไม่มีรายการในงวดนี้';

  @override
  String get balanceLabel => 'ยอดคงเหลือ';

  @override
  String get expandSummaryTooltip => 'แสดงรายรับและรายจ่าย';

  @override
  String get collapseSummaryTooltip => 'แสดงเฉพาะยอดคงเหลือ';

  @override
  String get periodNetLabel => 'งวดนี้';

  @override
  String carriedForwardLine(String amount) {
    return 'ยกยอดมา $amount';
  }

  @override
  String get incomeLabel => 'รายรับ';

  @override
  String get expenseLabel => 'รายจ่าย';

  @override
  String upcomingCategory(String category) {
    return '$category · กำลังจะถึง';
  }

  @override
  String get upcomingLabel => 'กำลังจะถึง';

  @override
  String detailAdded(String date) {
    return 'เพิ่มเมื่อ $date';
  }

  @override
  String detailChanged(String date) {
    return 'แก้ไขล่าสุดเมื่อ $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'มีรายการประจำครบกำหนด $count รายการ',
      one: 'มีรายการประจำครบกำหนด 1 รายการ',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: 'ใช้ไป $percent · เกิน $over รายการ',
      one: 'ใช้ไป $percent · เกิน 1 รายการ',
      zero: 'ใช้ไป $percent',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ตั้งงบประมาณ $count รายการ',
      one: 'ตั้งงบประมาณ 1 รายการ',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'ลบรายการไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get transactionDeleted => 'ลบรายการแล้ว';

  @override
  String get transferDeleted => 'ลบรายการโอนแล้ว';

  @override
  String get undoButton => 'เลิกทำ';

  @override
  String get undoFailed => 'เลิกทำไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get restoreFailed => 'กู้คืนรายการไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get restoreTransferFailed => 'กู้คืนการโอนไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get addTransactionTitle => 'เพิ่มรายการ';

  @override
  String get editTransactionTitle => 'แก้ไขรายการ';

  @override
  String get transactionDetailTitle => 'รายละเอียด';

  @override
  String get editTooltip => 'แก้ไข';

  @override
  String get deleteTooltip => 'ลบ';

  @override
  String get duplicateTooltip => 'ทำสำเนา';

  @override
  String get rowMenuTooltip => 'การทำงานอื่น';

  @override
  String get deleteTransactionTitle => 'ลบรายการนี้ไหม';

  @override
  String get deleteTransactionMessage =>
      'จะย้ายไปถังขยะ และกู้คืนได้ภายใน 30 วัน';

  @override
  String get discardChangesTitle => 'ละทิ้งการเปลี่ยนแปลงไหม';

  @override
  String get discardChangesMessage => 'สิ่งที่คุณพิมพ์ไว้ยังไม่ได้บันทึก';

  @override
  String get discardButton => 'ละทิ้ง';

  @override
  String get keepEditingButton => 'แก้ไขต่อ';

  @override
  String get titleOptionalLabel => 'ชื่อรายการ (ไม่บังคับ)';

  @override
  String get amountLabel => 'จำนวนเงิน';

  @override
  String get amountRequired => 'กรอกจำนวนเงิน';

  @override
  String get amountInvalid => 'กรอกจำนวนเงินให้ถูกต้อง';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'ลบตัวอักษร';

  @override
  String get hideKeypadTooltip => 'ซ่อนแป้นตัวเลข';

  @override
  String get categoryLabel => 'หมวดหมู่';

  @override
  String get categoryRequired => 'เลือกหมวดหมู่';

  @override
  String get accountLabel => 'บัญชี';

  @override
  String get accountRequired => 'เลือกบัญชี';

  @override
  String get dateLabel => 'วันที่';

  @override
  String get noteLabel => 'โน้ต';

  @override
  String get previousDayTooltip => 'วันก่อนหน้า';

  @override
  String get nextDayTooltip => 'วันถัดไป';

  @override
  String get noteOptionalLabel => 'โน้ต (ไม่บังคับ)';

  @override
  String get saveChangesButton => 'บันทึกการแก้ไข';

  @override
  String get addTransactionButton => 'เพิ่มรายการ';

  @override
  String get saveAndAddAnotherButton => 'บันทึกและเพิ่มอีก';

  @override
  String get transactionAdded => 'เพิ่มรายการแล้ว';

  @override
  String get saveFailed => 'บันทึกรายการไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get noExpensesInPeriod => 'ยังไม่มีรายจ่ายในงวดนี้';

  @override
  String totalSpent(String amount) {
    return 'ใช้จ่ายรวม: $amount';
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
  String get settingsTitle => 'การตั้งค่า';

  @override
  String get drawerAddHeader => 'เพิ่ม';

  @override
  String get drawerAddExpense => 'เพิ่มรายจ่าย';

  @override
  String get drawerAddIncome => 'เพิ่มรายรับ';

  @override
  String get drawerPlanHeader => 'วางแผน';

  @override
  String get drawerReviewHeader => 'ย้อนดู';

  @override
  String get drawerSpending => 'รายจ่ายตามหมวดหมู่';

  @override
  String get drawerManageHeader => 'จัดการ';

  @override
  String get drawerDataHeader => 'ข้อมูล';

  @override
  String get currencyLabel => 'สกุลเงิน';

  @override
  String get currencySearchHint => 'ค้นหาสกุลเงิน';

  @override
  String changeCurrencyTitle(String code) {
    return 'เปลี่ยนสกุลเงินเป็น $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'ยอดเงินจะไม่เปลี่ยนแปลง เปลี่ยนเฉพาะป้ายสกุลเงินเท่านั้น';

  @override
  String get changeButton => 'เปลี่ยน';

  @override
  String get cancelButton => 'ยกเลิก';

  @override
  String get saveButton => 'บันทึก';

  @override
  String get removeButton => 'นำออก';

  @override
  String get themeLabel => 'ธีม';

  @override
  String get themeSystem => 'ตามระบบ';

  @override
  String get themeLight => 'สว่าง';

  @override
  String get themeDark => 'มืด';

  @override
  String get themeBlack => 'ดำ';

  @override
  String get languageLabel => 'ภาษา';

  @override
  String get languageSystem => 'ค่าเริ่มต้นของระบบ';

  @override
  String get monthStartLabel => 'วันเริ่มต้นเดือน';

  @override
  String get monthStartLastDay => 'วันสุดท้าย';

  @override
  String get showCarriedForwardLabel => 'ยกยอดคงเหลือ';

  @override
  String get showCarriedForwardSubtitle =>
      'แต่ละงวดเริ่มต้นด้วยยอดคงเหลือจากงวดก่อนหน้า';

  @override
  String get trashTitle => 'ถังขยะ';

  @override
  String get trashEmpty => 'ถังขยะว่างเปล่า';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'ลบถาวรใน $days วัน',
      one: 'ลบถาวรใน 1 วัน',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'กู้คืน';

  @override
  String get categoriesTitle => 'หมวดหมู่';

  @override
  String get addCategoryTooltip => 'เพิ่มหมวดหมู่';

  @override
  String get addCategoryTitle => 'เพิ่มหมวดหมู่';

  @override
  String get editCategoryTitle => 'แก้ไขหมวดหมู่';

  @override
  String get categoryNameLabel => 'ชื่อ';

  @override
  String get categoryNameRequired => 'กรอกชื่อ';

  @override
  String get categoryNameTaken => 'ชื่อนี้ถูกใช้ไปแล้ว';

  @override
  String get archiveAction => 'เก็บถาวร';

  @override
  String get unarchiveAction => 'เลิกเก็บถาวร';

  @override
  String get deleteAction => 'ลบ';

  @override
  String get archivedHeader => 'เก็บถาวรแล้ว';

  @override
  String get accountsTotalLabel => 'รวม';

  @override
  String get categorySaveFailed => 'บันทึกหมวดหมู่ไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get accountsTitle => 'บัญชี';

  @override
  String get accountCash => 'เงินสด';

  @override
  String get accountTypeLabel => 'ประเภท';

  @override
  String get accountTypeCash => 'เงินสด';

  @override
  String get accountTypeBank => 'ธนาคาร';

  @override
  String get accountTypeCard => 'บัตร';

  @override
  String get accountTypeOther => 'อื่นๆ';

  @override
  String get addAccountTooltip => 'เพิ่มบัญชี';

  @override
  String get addAccountTitle => 'เพิ่มบัญชี';

  @override
  String get editAccountTitle => 'แก้ไขบัญชี';

  @override
  String get openingBalanceLabel => 'ยอดคงเหลือเริ่มต้น';

  @override
  String get openingDateLabel => 'วันที่เริ่มต้น';

  @override
  String get accountSaveFailed => 'บันทึกบัญชีไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get transferTitle => 'โอนเงิน';

  @override
  String get editTransferTitle => 'แก้ไขการโอนเงิน';

  @override
  String get transferLabel => 'โอนเงิน';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'จาก';

  @override
  String get toAccountLabel => 'ไปยัง';

  @override
  String get sameAccountError => 'เลือกบัญชีสองบัญชีที่ต่างกัน';

  @override
  String get needTwoAccounts => 'เพิ่มบัญชีที่สองเพื่อโอนเงินระหว่างบัญชี';

  @override
  String get addTransferButton => 'เพิ่มการโอนเงิน';

  @override
  String get transferSaveFailed => 'บันทึกการโอนเงินไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get searchHint => 'ค้นหารายการ';

  @override
  String get allTypesFilter => 'ทั้งหมด';

  @override
  String get allCategoriesFilter => 'ทุกหมวดหมู่';

  @override
  String get allAccountsFilter => 'ทุกบัญชี';

  @override
  String get allTimeFilter => 'ทุกช่วงเวลา';

  @override
  String get clearDatesTooltip => 'ล้างวันที่';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ผลลัพธ์',
      one: '1 ผลลัพธ์',
    );
    return '$_temp0 · รายรับ $income · รายจ่าย $expense';
  }

  @override
  String get noSearchResults => 'ไม่พบรายการที่ตรงกัน';

  @override
  String get budgetsTitle => 'งบประมาณ';

  @override
  String get budgetsTooltip => 'งบประมาณ';

  @override
  String get overallBudget => 'ภาพรวม';

  @override
  String get noBudget => 'ไม่มีงบประมาณ';

  @override
  String budgetsHint(String period) {
    return 'วงเงินมีผลตั้งแต่ $period เป็นต้นไป งวดก่อนหน้ายังคงใช้วงเงินเดิม';
  }

  @override
  String get budgetLimitLabel => 'วงเงินต่องวด';

  @override
  String get budgetSaveFailed => 'บันทึกงบประมาณไม่สำเร็จ ลองอีกครั้ง';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent จาก $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return 'เหลือ $remaining · วันละ $perDay';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return 'ใช้ไป $amount · วันละ $perDay จนถึงตอนนี้';
  }

  @override
  String get homeSetBudget => 'ตั้งงบประมาณรายเดือน';

  @override
  String budgetLeft(String remaining) {
    return 'เหลือ $remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return 'เกินวงเงิน $amount';
  }

  @override
  String get budgetLimitReached => 'ถึงวงเงินแล้ว';

  @override
  String budgetLimitOnly(String limit) {
    return 'วงเงิน $limit';
  }

  @override
  String get recurringTitle => 'รายการประจำ';

  @override
  String get addRecurringTooltip => 'เพิ่มรายการประจำ';

  @override
  String get addRecurringTitle => 'เพิ่มรายการประจำ';

  @override
  String get editRecurringTitle => 'แก้ไขรายการประจำ';

  @override
  String get dueHeader => 'ครบกำหนด';

  @override
  String get upcomingHeader => 'อีก 30 วันข้างหน้า';

  @override
  String get rulesHeader => 'กฎ';

  @override
  String billsPerMonth(String amount) {
    return '$amount ต่อเดือนสำหรับบิล';
  }

  @override
  String nextBillToday(String title) {
    return 'ถัดไป: $title, วันนี้';
  }

  @override
  String nextBillTomorrow(String title) {
    return 'ถัดไป: $title, พรุ่งนี้';
  }

  @override
  String nextBill(int days, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'ถัดไป: $title, อีก $days วัน',
    );
    return '$_temp0';
  }

  @override
  String get nothingUpcoming => 'ไม่มีรายการในอีก 30 วันข้างหน้า';

  @override
  String get noRules => 'ยังไม่มีรายการประจำ';

  @override
  String get recurringEmptyMessage =>
      'รายการประจำจะบันทึกค่าเช่า เงินเดือน หรือค่าสมัครสมาชิกตามกำหนดเวลาที่คุณตั้งไว้ และรอการแตะเพื่อยืนยันแต่ละรายการ';

  @override
  String get addRecurringButton => 'เพิ่มรายการประจำ';

  @override
  String get postButton => 'บันทึกรายการ';

  @override
  String get skipButton => 'ข้าม';

  @override
  String get postFailed => 'บันทึกรายการไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get recurringSaveFailed => 'บันทึกรายการประจำไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get everyLabel => 'ทุก';

  @override
  String get frequencyDays => 'วัน';

  @override
  String get frequencyWeeks => 'สัปดาห์';

  @override
  String get frequencyMonths => 'เดือน';

  @override
  String get frequencyYears => 'ปี';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ทุก $count วัน',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryDay => 'ทุกวัน';

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ทุก $count สัปดาห์',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryWeek => 'ทุกสัปดาห์';

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ทุก $count เดือน',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryMonth => 'ทุกเดือน';

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ทุก $count ปี',
    );
    return '$_temp0';
  }

  @override
  String get scheduleEveryYear => 'ทุกปี';

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · หยุดชั่วคราว';
  }

  @override
  String get startsLabel => 'เริ่ม';

  @override
  String get endsLabel => 'สิ้นสุด';

  @override
  String get endNever => 'ไม่มีกำหนด';

  @override
  String get endAfter => 'หลังจาก';

  @override
  String get endOnDate => 'ในวันที่';

  @override
  String get timesLabel => 'ครั้ง';

  @override
  String get endsOnLabel => 'สิ้นสุดวันที่';

  @override
  String get wholeNumberInvalid => 'กรอกจำนวนเต็มตั้งแต่ 1 ขึ้นไป';

  @override
  String get endDateInvalid => 'วันที่สิ้นสุดต้องอยู่หลังวันที่เริ่มต้น';

  @override
  String get autoPostLabel => 'บันทึกอัตโนมัติ';

  @override
  String get autoPostSubtitle => 'ไม่เช่นนั้นจะรอในครบกำหนดจนกว่าคุณจะแตะ';

  @override
  String get pauseTooltip => 'หยุดชั่วคราว';

  @override
  String get resumeTooltip => 'ดำเนินการต่อ';

  @override
  String get categoryFood => 'อาหาร';

  @override
  String get categoryGroceries => 'ของชำ';

  @override
  String get categoryTransport => 'เดินทาง';

  @override
  String get categoryShopping => 'ช้อปปิ้ง';

  @override
  String get categoryBills => 'บิล';

  @override
  String get categoryRent => 'ค่าเช่า';

  @override
  String get categoryHealth => 'สุขภาพ';

  @override
  String get categoryEducation => 'การศึกษา';

  @override
  String get categoryEntertainment => 'บันเทิง';

  @override
  String get categorySalary => 'เงินเดือน';

  @override
  String get categoryBusiness => 'ธุรกิจ';

  @override
  String get categoryInvestment => 'ลงทุน';

  @override
  String get categoryGift => 'ของขวัญ';

  @override
  String get categoryOther => 'อื่นๆ';

  @override
  String get previousPeriodTooltip => 'งวดก่อนหน้า';

  @override
  String get wholePeriodTooltip => 'แสดงทั้งงวด';

  @override
  String get nextPeriodTooltip => 'งวดถัดไป';

  @override
  String get insightsTooltip => 'อินไซต์';

  @override
  String get insightsTitle => 'อินไซต์';

  @override
  String get calendarTab => 'ปฏิทิน';

  @override
  String get trendTab => 'แนวโน้ม';

  @override
  String get noIncomeInPeriod => 'ยังไม่มีรายรับในงวดนี้';

  @override
  String totalIncome(String amount) {
    return 'รายรับรวม: $amount';
  }

  @override
  String comparedMore(String amount) {
    return 'มากกว่าเดือนที่แล้ว $amount';
  }

  @override
  String comparedLess(String amount) {
    return 'น้อยกว่าเดือนที่แล้ว $amount';
  }

  @override
  String get comparedSame => 'เท่ากับเดือนที่แล้ว';

  @override
  String get categoryNewLabel => 'ใหม่';

  @override
  String get calendarHint => 'แตะวันที่เพื่อดูรายการ';

  @override
  String get dayEmpty => 'ไม่มีรายการในวันนี้';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count เดือน',
      one: '1 เดือน',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'รายรับ $income · รายจ่าย $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'เฉลี่ยต่องวด · รายรับ $income · รายจ่าย $expense';
  }

  @override
  String get trendNeedsMorePeriods =>
      'แนวโน้มต้องการมากกว่าหนึ่งงวด กลับมาดูใหม่เดือนหน้า';

  @override
  String get weekStartLabel => 'วันเริ่มต้นสัปดาห์';

  @override
  String weekStartDefault(String day) {
    return 'ค่าเริ่มต้น ($day)';
  }

  @override
  String get firstRunTitle => 'ยินดีต้อนรับสู่ Monthly Expenses';

  @override
  String get firstRunMessage =>
      'บันทึกรายรับรายจ่ายของคุณ ข้อมูลจะถูกเก็บไว้ในอุปกรณ์นี้เท่านั้น';

  @override
  String get addFirstTransactionButton => 'เพิ่มรายการแรกของคุณ';

  @override
  String get setupIntro =>
      'เลือกภาษาและสกุลเงินของคุณ คุณสามารถเปลี่ยนได้ภายหลังในการตั้งค่า';

  @override
  String get setupContinueButton => 'ดำเนินการต่อ';

  @override
  String get setupRestoreTitle => 'กู้คืนข้อมูลสำรอง';

  @override
  String get setupRestoreSubtitle =>
      'นำข้อมูลและการตั้งค่ากลับมาจากไฟล์สำรองข้อมูล';

  @override
  String get walkthroughEntryTitle => 'เพิ่มรายการในไม่กี่วินาที';

  @override
  String get walkthroughEntryBody =>
      'แป้นตัวเลขที่คำนวณให้ ถ่ายรูปใบเสร็จ และบันทึกเสียงเมื่อพิมพ์ไม่ทัน';

  @override
  String get walkthroughPlanTitle => 'วางแผนแต่ละเดือน';

  @override
  String get walkthroughPlanBody =>
      'งบประมาณตามหมวดหมู่ บิลที่เกิดขึ้นซ้ำเอง และโน้ตที่คอยเตือนคุณ';

  @override
  String get walkthroughInsightsTitle => 'ดูว่าเงินไปไหน';

  @override
  String get walkthroughInsightsBody =>
      'กราฟ ปฏิทิน และรายงาน PDF หรือ CSV สำหรับทุกงวด';

  @override
  String get walkthroughPrivacyTitle => 'เป็นของคุณเท่านั้น';

  @override
  String get walkthroughPrivacyBody =>
      'ไม่ต้องมีบัญชี ข้อมูลที่คุณบันทึกจะอยู่ในเครื่องนี้เท่านั้น โฆษณาที่สนับสนุนแอปจะไม่มีวันเห็นข้อมูลนี้';

  @override
  String get walkthroughBringTitle => 'นำข้อมูลเดิมมาด้วย';

  @override
  String get walkthroughBringBody =>
      'มาจากแอปอื่นหรือโทรศัพท์เครื่องอื่น? เริ่มต้นจากไฟล์สำรองข้อมูลหรือ CSV แทนแอปเปล่าๆ';

  @override
  String get firstRunRestoreTitle => 'กู้คืนไฟล์สำรองนี้หรือไม่';

  @override
  String get firstRunRestoreMessage =>
      'การกู้คืนจะแทนที่ข้อมูลทั้งหมดในแอป และนำภาษากับสกุลเงินตอนที่บันทึกไว้กลับมาด้วย';

  @override
  String get walkthroughNextButton => 'ถัดไป';

  @override
  String get walkthroughStartButton => 'เริ่มต้นใช้งาน';

  @override
  String get walkthroughDoneButton => 'เสร็จสิ้น';

  @override
  String walkthroughProgress(int current, int total) {
    return 'หน้า $current จาก $total';
  }

  @override
  String get walkthroughReplayTitle => 'ดูคำแนะนำอีกครั้ง';

  @override
  String get walkthroughReplaySubtitle =>
      'สี่หน้าที่แสดงตอนเริ่มใช้แอปครั้งแรก';

  @override
  String get removeAdsTitle => 'ลบโฆษณา';

  @override
  String get exportCsvMenu => 'ส่งออก CSV';

  @override
  String get exportCsvTooltip => 'ส่งออก CSV';

  @override
  String get csvExported => 'บันทึก CSV แล้ว';

  @override
  String get csvExportFailed => 'ส่งออก CSV ไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get backupTitle => 'สำรองและกู้คืนข้อมูล';

  @override
  String get backupIntro =>
      'ไฟล์สำรองข้อมูลจะถูกบันทึกในที่ที่คุณเลือกเอง ไม่มีการอัปโหลดหรือส่งข้อมูลโดยอัตโนมัติ';

  @override
  String get backUpNowTitle => 'สำรองข้อมูลตอนนี้';

  @override
  String lastBackupLine(String date) {
    return 'สำรองข้อมูลล่าสุดเมื่อ $date';
  }

  @override
  String get neverBackedUp => 'ยังไม่เคยสำรองข้อมูล';

  @override
  String get backupSaved => 'บันทึกไฟล์สำรองข้อมูลแล้ว';

  @override
  String get backupSaveFailed => 'บันทึกไฟล์สำรองข้อมูลไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get restoreFromFileTitle => 'กู้คืนจากไฟล์';

  @override
  String get restoreFromFileSubtitle =>
      'ผสานไฟล์สำรองข้อมูลเข้ากับข้อมูลของคุณ หรือแทนที่ข้อมูลของคุณด้วยไฟล์นั้น';

  @override
  String get backupReminderLabel => 'แจ้งเตือนให้สำรองข้อมูล';

  @override
  String get backupReminderSubtitle => 'ทุก 30 วันเมื่อมีรายการครบ 20 รายการ';

  @override
  String get backupReminderNever => 'สำรองข้อมูลของคุณไว้เพื่อความปลอดภัย';

  @override
  String backupReminderSince(String date) {
    return 'สำรองข้อมูลล่าสุดเมื่อ $date ถึงเวลาสำรองใหม่หรือยัง';
  }

  @override
  String get notNowTooltip => 'ไว้ทีหลัง';

  @override
  String get keptBackupsHeader => 'ไฟล์สำรองข้อมูลอัตโนมัติ';

  @override
  String get keptBackupsHint => 'บันทึกไว้ในอุปกรณ์นี้ก่อนการกู้คืนแต่ละครั้ง';

  @override
  String get noKeptBackups => 'ยังไม่มี';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count รายการ',
      one: '1 รายการ',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'กู้คืนข้อมูลสำรอง';

  @override
  String get mergeOption => 'ผสาน';

  @override
  String get mergeOptionSubtitle =>
      'เก็บข้อมูลเดิมไว้และเพิ่มข้อมูลจากไฟล์สำรอง หากรายการซ้ำกัน จะใช้การแก้ไขล่าสุด';

  @override
  String get replaceOption => 'แทนที่';

  @override
  String get replaceOptionSubtitle =>
      'ลบข้อมูลเดิมและใช้เฉพาะข้อมูลจากไฟล์สำรอง พร้อมการตั้งค่าของไฟล์นั้น';

  @override
  String get restoreSafetyNote =>
      'ระบบจะบันทึกสำเนาข้อมูลปัจจุบันของคุณไว้ในไฟล์สำรองข้อมูลอัตโนมัติก่อน';

  @override
  String get restoreButton => 'กู้คืน';

  @override
  String get restoreKeptTitle => 'กู้คืนสำเนานี้หรือไม่';

  @override
  String restoreKeptMessage(String date) {
    return 'ข้อมูลของคุณจะถูกแทนที่ด้วยสำเนาจากวันที่ $date ระบบจะบันทึกสำเนาข้อมูลปัจจุบันไว้ก่อน';
  }

  @override
  String get backupInvalid =>
      'ไฟล์นี้ไม่ใช่ไฟล์สำรองข้อมูลของ Monthly Expenses';

  @override
  String get backupTooNew =>
      'ไฟล์สำรองนี้มาจากแอปเวอร์ชันใหม่กว่า กรุณาอัปเดตแอปแล้วลองอีกครั้ง';

  @override
  String get backupOpenFailed => 'เปิดไฟล์ไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get backupRestoreFailed =>
      'กู้คืนไฟล์สำรองไม่สำเร็จ ข้อมูลของคุณไม่มีการเปลี่ยนแปลง';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'กู้คืนแล้ว $count รายการ',
      one: 'กู้คืนแล้ว 1 รายการ',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'ผสานข้อมูลแล้ว: เพิ่ม $added รายการ อัปเดต $updated รายการ ไม่เปลี่ยนแปลง $unchanged รายการ';
  }

  @override
  String get appLockLabel => 'ล็อกแอป';

  @override
  String get appLockSubtitle =>
      'ปลดล็อกด้วยลายนิ้วมือ ใบหน้า หรือรหัสล็อกหน้าจอ';

  @override
  String get appLockUnavailable =>
      'ตั้งค่าการล็อกหน้าจอบนอุปกรณ์นี้เพื่อใช้ล็อกแอป';

  @override
  String get appLockReason => 'ปลดล็อก Monthly Expenses';

  @override
  String get appLockFailed =>
      'ยืนยันตัวตนไม่สำเร็จ การล็อกแอปไม่มีการเปลี่ยนแปลง';

  @override
  String get lockedTitle => 'Monthly Expenses ถูกล็อกอยู่';

  @override
  String get unlockButton => 'ปลดล็อก';

  @override
  String get widgetShowAmountsLabel => 'แสดงจำนวนเงินบนวิดเจ็ต';

  @override
  String get widgetShowAmountsSubtitle =>
      'วิดเจ็ตหน้าจอหลักจะซ่อนจำนวนเงินเมื่อเปิดล็อกแอปไว้';

  @override
  String get widgetLeftLabel => 'เหลือ';

  @override
  String get widgetAddExpense => 'เพิ่มรายจ่าย';

  @override
  String get widgetAddIncome => 'เพิ่มรายรับ';

  @override
  String get widgetAmountsHidden => 'จำนวนเงินถูกซ่อนโดยการล็อกแอป';

  @override
  String get notesTitle => 'โน้ต';

  @override
  String get addNoteTooltip => 'เพิ่มโน้ต';

  @override
  String get addNoteTitle => 'เพิ่มโน้ต';

  @override
  String get editNoteTitle => 'แก้ไขโน้ต';

  @override
  String get noteTextLabel => 'โน้ต';

  @override
  String get noteTextRequired => 'กรอกข้อความ';

  @override
  String get noteAmountOptionalLabel => 'จำนวนเงิน (ไม่บังคับ)';

  @override
  String get noteDueDateToggle => 'กำหนดวันครบกำหนด';

  @override
  String get noteDueDateLabel => 'วันครบกำหนด';

  @override
  String get noteReminderToggle => 'เตือนฉัน';

  @override
  String get noteReminderTimeLabel => 'เวลาที่แจ้งเตือน';

  @override
  String get noteReminderTimeUnset => 'เลือกเวลา';

  @override
  String get reminderMayBeLate =>
      'โทรศัพท์ของคุณอาจส่งข้อความนี้ช้าไปสองสามนาที';

  @override
  String get noteCategoryOptionalLabel => 'หมวดหมู่ (ไม่บังคับ)';

  @override
  String get noteCategoryNone => 'ไม่มี';

  @override
  String get recordNoteButton => 'บันทึกเป็นรายการ';

  @override
  String get noteMarkDoneTooltip => 'ทำเครื่องหมายเสร็จ';

  @override
  String get noteMarkOpenTooltip => 'ทำเครื่องหมายค้างไว้';

  @override
  String get notesEmptyTitle => 'ยังไม่มีอะไรที่นี่';

  @override
  String get notesEmptyMessage =>
      'โน้ตช่วยจำสิ่งที่ต้องทำหรือตรวจสอบ พร้อมวันที่ จำนวนเงิน และหมวดหมู่ที่ไม่บังคับ';

  @override
  String get addNoteButton => 'เพิ่มโน้ต';

  @override
  String get notesOpenHeader => 'ค้างอยู่';

  @override
  String get notesDoneHeader => 'เสร็จแล้ว';

  @override
  String get noteDeleted => 'ลบโน้ตแล้ว';

  @override
  String get noteSaveFailed => 'บันทึกโน้ตไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get noteDeleteFailed => 'ลบโน้ตไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get noteRestoreFailed => 'กู้คืนโน้ตไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get notesSearchHint => 'ค้นหาโน้ต';

  @override
  String get noteFilterAll => 'ทั้งหมด';

  @override
  String get noteFilterOverdue => 'เลยกำหนด';

  @override
  String get noteFilterDueToday => 'ครบกำหนดวันนี้';

  @override
  String get noteFilterUpcoming => 'กำลังจะถึง';

  @override
  String get noteFilterNoDate => 'ไม่มีวันที่';

  @override
  String get noNoteResults => 'ไม่พบโน้ตที่ตรงกัน';

  @override
  String get noteLinkedTransactionLabel => 'บันทึกเป็นรายการแล้ว';

  @override
  String get noteLinkedNoteLabel => 'มาจากโน้ต';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'มีโน้ตครบกำหนด $count รายการ',
      one: 'มีโน้ตครบกำหนด 1 รายการ',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'โน้ตที่ครบกำหนด';

  @override
  String get noteReminderTitle => 'การแจ้งเตือนโน้ต';

  @override
  String get noteReminderLockedTitle => 'มีโน้ตครบกำหนด';

  @override
  String get noteReminderPermissionDenied =>
      'เปิดการแจ้งเตือนในการตั้งค่าระบบเพื่อรับการแจ้งเตือนโน้ต';

  @override
  String reportRange(String from, String to) {
    return '$from ถึง $to';
  }

  @override
  String reportCreated(String when) {
    return 'สร้างเมื่อ $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'หน้า $page จาก $pages';
  }

  @override
  String get reportNet => 'ยอดสุทธิ';

  @override
  String get reportOpeningBalance => 'ยอดยกมา';

  @override
  String get reportClosingBalance => 'ยอดคงเหลือปลายงวด';

  @override
  String get reportSpendingHeader => 'รายจ่ายตามหมวดหมู่';

  @override
  String get reportEarningHeader => 'รายรับตามหมวดหมู่';

  @override
  String get reportTrendHeader => 'แนวโน้ม';

  @override
  String get reportEntriesHeader => 'รายการ';

  @override
  String get reportUpcomingHeader => 'กำลังจะถึง';

  @override
  String get reportUpcomingNote =>
      'นับวันที่ล่วงหน้า จึงไม่รวมอยู่ในยอดรวมด้านบน';

  @override
  String get reportAmountColumn => 'จำนวนเงิน';

  @override
  String get reportShareColumn => 'สัดส่วน';

  @override
  String get reportBudgetColumn => 'งบประมาณ';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used จาก $limit';
  }

  @override
  String get reportDetailsColumn => 'รายละเอียด';

  @override
  String get reportEmpty => 'ไม่มีข้อมูลสำหรับช่วงวันที่นี้';

  @override
  String get exportPdfMenu => 'ส่งออก PDF';

  @override
  String get reportTitle => 'ส่งออก PDF';

  @override
  String get reportNoFontTitle => 'ยังไม่รองรับภาษานี้';

  @override
  String get reportNoFontBody =>
      'รายงานต้องใช้ฟอนต์ของอักษรนั้น แต่ฟอนต์จีน ญี่ปุ่น และเกาหลีใหญ่เกินกว่าจะรวมมากับแอป เวอร์ชันถัดไปจะให้ดาวน์โหลดได้';

  @override
  String get reportPreviewTitle => 'รายงาน';

  @override
  String get reportCoversHeader => 'ครอบคลุมช่วงใด';

  @override
  String get reportRangePeriod => 'งวดนี้';

  @override
  String get reportRangeCustom => 'วันที่';

  @override
  String get reportRangeYear => 'ปี';

  @override
  String get reportFromLabel => 'จาก';

  @override
  String get reportToLabel => 'ถึง';

  @override
  String get reportYearLabel => 'ปี';

  @override
  String get reportAccountLabel => 'บัญชี';

  @override
  String get reportAllAccounts => 'ทุกบัญชี';

  @override
  String get reportIncludeHeader => 'รวมอะไรบ้าง';

  @override
  String get reportIncludeSubtitle => 'ไม่ต้องเลือกสิ่งที่คุณไม่อยากแชร์';

  @override
  String get reportIncludeTransactions => 'รายการทั้งหมด';

  @override
  String get reportIncludeDetails => 'ชื่อรายการและโน้ต';

  @override
  String get reportIncludeAccounts => 'ชื่อบัญชี';

  @override
  String get reportCreateButton => 'สร้างรายงาน';

  @override
  String get reportBuilding => 'กำลังสร้างรายงาน';

  @override
  String get reportFailed => 'สร้างรายงานไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get reportRangeBackwards => 'วันที่แรกต้องมาก่อนวันที่สุดท้าย';

  @override
  String get importTitle => 'นำเข้า CSV';

  @override
  String get importSubtitle => 'นำรายการเข้าจากแอปอื่น';

  @override
  String get importIntro =>
      'เลือกไฟล์ CSV แล้วคุณจะเห็นผลลัพธ์ที่แอปอ่านได้ก่อนที่จะเพิ่มข้อมูลใดๆ การนำเข้าจะเพิ่มรายการใหม่เท่านั้น ไม่แทนที่หรือลบข้อมูลที่มีอยู่';

  @override
  String get importChooseFile => 'เลือกไฟล์';

  @override
  String get importChooseAnother => 'เลือกไฟล์อื่น';

  @override
  String get importReadFailed => 'อ่านไฟล์นั้นไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get importRefusedEmpty => 'ไม่มีข้อมูลในไฟล์นั้น';

  @override
  String get importRefusedNoDate =>
      'ไม่มีคอลัมน์ในไฟล์นั้นที่อ่านเป็นวันที่ได้ จึงนำเข้าไม่ได้';

  @override
  String get importRefusedNoAmount =>
      'ไม่มีคอลัมน์ในไฟล์นั้นที่อ่านเป็นจำนวนเงินได้ จึงนำเข้าไม่ได้';

  @override
  String get importRefusedNoRows =>
      'ไม่สามารถอ่านแถวใดในไฟล์นั้นได้ จึงไม่มีอะไรให้นำเข้า';

  @override
  String get importColumnsHeader => 'คอลัมน์';

  @override
  String get importColumnsSubtitle => 'แก้ไขส่วนที่แอปอ่านผิดพลาด';

  @override
  String get importColumnNone => 'ไม่ใช้';

  @override
  String get importFieldType => 'ประเภท';

  @override
  String get importFieldToAccount => 'ไปยังบัญชี';

  @override
  String get importFieldTitle => 'ชื่อรายการ';

  @override
  String get importFieldNote => 'โน้ต';

  @override
  String get importDateOrderLabel => 'วันที่แบบ 03/04 หมายถึง';

  @override
  String get importDayFirst => 'วันก่อน';

  @override
  String get importMonthFirst => 'เดือนก่อน';

  @override
  String get importCountsHeader => 'จะเกิดอะไรขึ้น';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'จะนำเข้า $count แถว',
      one: 'จะนำเข้า 1 แถว',
      zero: 'จะไม่มีการนำเข้าใดๆ',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count แถวมีวันที่ที่แอปอ่านไม่ได้',
      one: '1 แถวมีวันที่ที่แอปอ่านไม่ได้',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count แถวมีจำนวนเงินที่แอปอ่านไม่ได้',
      one: '1 แถวมีจำนวนเงินที่แอปอ่านไม่ได้',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count แถวไม่มีจำนวนเงินเลย',
      one: '1 แถวไม่มีจำนวนเงินเลย',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count แถวมีอยู่ในแอปแล้ว',
      one: '1 แถวมีอยู่ในแอปแล้ว',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count การโอนเงินระบุบัญชีเดียว',
      one: '1 การโอนเงินระบุบัญชีเดียว',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'อ่านวันที่ไม่ได้';

  @override
  String get importRowUnreadableAmount => 'อ่านจำนวนเงินไม่ได้';

  @override
  String get importRowZero => 'ไม่มีจำนวนเงินเลย';

  @override
  String get importRowAlreadyThere => 'มีอยู่ในแอปแล้ว';

  @override
  String get importRowIncompleteTransfer => 'ระบุบัญชีเดียวเท่านั้น';

  @override
  String get importNamesHeader => 'ชื่อที่แอปยังไม่มี';

  @override
  String get importNamesSubtitle =>
      'เลือกว่าแต่ละชื่อจะกลายเป็นอะไร การนำเข้าจะไม่สร้างหมวดหมู่หรือบัญชีใหม่';

  @override
  String get importRowsHeader => 'แถวแรกๆ ตามที่แอปอ่านได้';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'และอีก $count รายการ',
      one: 'และอีก 1 รายการ',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'นำเข้า $count แถว',
      one: 'นำเข้า 1 แถว',
      zero: 'ไม่มีอะไรให้นำเข้า',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'นำเข้าแล้ว $count รายการ',
      one: 'นำเข้าแล้ว 1 รายการ',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'นำเข้าไฟล์นั้นไม่สำเร็จ ไม่มีข้อมูลถูกเพิ่ม';

  @override
  String get attachmentsLabel => 'ไฟล์แนบ';

  @override
  String get photoLabel => 'รูปภาพ';

  @override
  String get photoAdd => 'เพิ่มรูปภาพ';

  @override
  String get photoTake => 'ถ่ายรูป';

  @override
  String get photoChoose => 'เลือกรูปภาพ';

  @override
  String get photoRemove => 'นำรูปภาพออก';

  @override
  String get photoMissing => 'ไม่พบรูปภาพนี้';

  @override
  String get voiceNoteLabel => 'บันทึกเสียง';

  @override
  String get voiceRecord => 'อัดบันทึกเสียง';

  @override
  String voiceRecording(int seconds) {
    return 'กำลังอัด เหลืออีก $seconds วินาที';
  }

  @override
  String get voiceStop => 'หยุด';

  @override
  String get voicePlay => 'เล่น';

  @override
  String get voicePause => 'หยุดชั่วคราว';

  @override
  String get voiceRemove => 'นำบันทึกเสียงออก';

  @override
  String get voiceMissing => 'ไม่พบบันทึกเสียงนี้';

  @override
  String get microphoneRefused => 'ไมโครโฟนถูกปิดสำหรับแอปนี้';

  @override
  String backupIncludesAttachments(String size) {
    return 'รวมไฟล์แนบ $size MB';
  }

  @override
  String get removeAdsBody =>
      'ซ่อนโฆษณาทั้งหมดด้วยการจ่ายเงินครั้งเดียว ผูกกับบัญชีร้านค้าของคุณ จึงกลับมาใช้ได้แม้เปลี่ยนเครื่องหรือติดตั้งใหม่';

  @override
  String removeAdsBuyButton(String price) {
    return 'ลบโฆษณาในราคา $price';
  }

  @override
  String get removeAdsOwned => 'ปิดโฆษณาแล้ว ขอบคุณ';

  @override
  String get removeAdsPending => 'กำลังรอร้านค้า…';

  @override
  String get removeAdsUnavailable =>
      'ร้านค้ายังไม่มีสินค้าให้ซื้อตอนนี้ กรุณาลองใหม่ภายหลัง';

  @override
  String get removeAdsFailed =>
      'การทำรายการไม่สำเร็จ และคุณยังไม่ถูกเรียกเก็บเงิน';

  @override
  String get restorePurchasesButton => 'เรียกคืนการซื้อ';

  @override
  String get payNothingWithheld =>
      'ทุกฟีเจอร์ใช้งานได้ฟรีเสมอ ไม่ว่าจะมีโฆษณาหรือไม่';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'เร็วๆ นี้';

  @override
  String get plusBody =>
      'การเชื่อมต่อธนาคารที่ดึงรายการธุรกรรมมาให้คุณยืนยัน ยังพัฒนาไม่เสร็จ จึงยังไม่มีอะไรให้ซื้อ';

  @override
  String get privacyOptionsTitle => 'ตัวเลือกความเป็นส่วนตัว';

  @override
  String get privacyPolicyTitle => 'นโยบายความเป็นส่วนตัว';

  @override
  String get privacyOptionsSubtitle =>
      'เปลี่ยนตัวเลือกเกี่ยวกับโฆษณาที่ปรับให้เหมาะกับคุณ';

  @override
  String get dueEntryReminderTitle => 'รายการถึงกำหนดแล้ว';

  @override
  String dueEntryReminderOne(String title) {
    return '$title ถึงกำหนดวันนี้และยังคงรอดำเนินการ';
  }

  @override
  String get dueEntryReminderUntitled =>
      'รายการที่เกิดซ้ำถึงกำหนดวันนี้และยังคงรอดำเนินการ';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'มีรายการที่เกิดซ้ำถึงกำหนดวันนี้ $count รายการ',
      one: 'มีรายการที่เกิดซ้ำถึงกำหนดวันนี้ $count รายการ',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'วันนี้ยังไม่มีการบันทึก';

  @override
  String get emptyDayReminderBody => 'บันทึกค่าใช้จ่ายไว้ตอนที่ยังจำได้';

  @override
  String get reminderLockedTitle => 'มีบางอย่างกำลังรออยู่';

  @override
  String get nudgeSettingsTitle => 'เตือนฉันในวันที่ไม่มีการบันทึก';

  @override
  String get nudgeSettingsSubtitle =>
      'เตือนหนึ่งครั้งตอนเย็น เฉพาะวันที่ไม่มีการบันทึกเลย';

  @override
  String get nudgeOfferTitle => 'เตือนในวันที่คุณลืมไหม';

  @override
  String get nudgeOfferBody =>
      'เตือนหนึ่งครั้งตามเวลาที่คุณเลือก เฉพาะวันที่ไม่มีการบันทึก ปิดได้ทุกเมื่อ';

  @override
  String get nudgeOfferYes => 'ใช่ เตือนฉันด้วย';

  @override
  String get nudgeOfferNo => 'ไม่ ขอบคุณ';

  @override
  String get nudgeStoppedNotice =>
      'การเตือนหยุดหลังไม่มีการตอบสนองสามครั้ง เปิดใหม่ได้ทุกเมื่อ';

  @override
  String get nudgePermissionDenied => 'เปิดการแจ้งเตือนในการตั้งค่าระบบ';

  @override
  String get updateDownloadedMessage => 'ดาวน์โหลดการอัปเดตแล้ว';

  @override
  String get updateRestartButton => 'รีสตาร์ท';
}
