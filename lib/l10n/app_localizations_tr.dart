// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Ayarlar';

  @override
  String get transferTooltip => 'Transfer';

  @override
  String get searchTooltip => 'Ara';

  @override
  String get addButton => 'Ekle';

  @override
  String get emptyPeriod => 'Bu dönemde henüz işlem yok.';

  @override
  String get balanceLabel => 'Bakiye';

  @override
  String get periodNetLabel => 'Bu dönem';

  @override
  String carriedForwardLine(String amount) {
    return 'Devreden $amount';
  }

  @override
  String get incomeLabel => 'Gelir';

  @override
  String get expenseLabel => 'Gider';

  @override
  String upcomingCategory(String category) {
    return '$category · Yaklaşan';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tekrarlanan işlemin zamanı geldi',
      one: '1 tekrarlanan işlemin zamanı geldi',
    );
    return '$_temp0';
  }

  @override
  String budgetsOverNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bütçe limitini aştı',
      one: '1 bütçe limitini aştı',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'İşlem silinemedi. Tekrar deneyin.';

  @override
  String get transactionDeleted => 'İşlem silindi';

  @override
  String get transferDeleted => 'Transfer silindi';

  @override
  String get undoButton => 'Geri al';

  @override
  String get undoFailed => 'Geri alınamadı. Tekrar deneyin.';

  @override
  String get restoreFailed => 'İşlem geri yüklenemedi. Tekrar deneyin.';

  @override
  String get addTransactionTitle => 'İşlem Ekle';

  @override
  String get editTransactionTitle => 'İşlemi Düzenle';

  @override
  String get deleteTooltip => 'Sil';

  @override
  String get duplicateTooltip => 'Çoğalt';

  @override
  String get titleOptionalLabel => 'Başlık (isteğe bağlı)';

  @override
  String get amountLabel => 'Tutar';

  @override
  String get amountRequired => 'Bir tutar girin';

  @override
  String get amountInvalid => 'Geçerli bir tutar girin';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Geri sil';

  @override
  String get hideKeypadTooltip => 'Tuş takımını gizle';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get categoryRequired => 'Bir kategori seçin';

  @override
  String get accountLabel => 'Hesap';

  @override
  String get accountRequired => 'Bir hesap seçin';

  @override
  String get dateLabel => 'Tarih';

  @override
  String get previousDayTooltip => 'Önceki gün';

  @override
  String get nextDayTooltip => 'Sonraki gün';

  @override
  String get noteOptionalLabel => 'Not (isteğe bağlı)';

  @override
  String get saveChangesButton => 'Değişiklikleri Kaydet';

  @override
  String get addTransactionButton => 'İşlem Ekle';

  @override
  String get saveAndAddAnotherButton => 'Kaydet ve yeni ekle';

  @override
  String get transactionAdded => 'İşlem eklendi';

  @override
  String get saveFailed => 'İşlem kaydedilemedi. Tekrar deneyin.';

  @override
  String get noExpensesInPeriod => 'Bu dönemde henüz gider yok.';

  @override
  String totalSpent(String amount) {
    return 'Toplam harcama: $amount';
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
  String get settingsTitle => 'Ayarlar';

  @override
  String get currencyLabel => 'Para birimi';

  @override
  String get currencySearchHint => 'Para birimi ara';

  @override
  String changeCurrencyTitle(String code) {
    return 'Para birimi $code olarak değiştirilsin mi?';
  }

  @override
  String get changeCurrencyMessage =>
      'Tutarlar aynı kalır; yalnızca para birimi etiketi değişir.';

  @override
  String get changeButton => 'Değiştir';

  @override
  String get cancelButton => 'İptal';

  @override
  String get saveButton => 'Kaydet';

  @override
  String get removeButton => 'Kaldır';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get languageLabel => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get monthStartLabel => 'Ayın ilk günü';

  @override
  String get monthStartLastDay => 'Son gün';

  @override
  String get showCarriedForwardLabel => 'Bakiyeyi devret';

  @override
  String get showCarriedForwardSubtitle => 'Her dönem önceki bakiyeden başlar';

  @override
  String get trashTitle => 'Çöp kutusu';

  @override
  String get trashEmpty => 'Çöp kutusu boş.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün içinde kalıcı olarak silinecek',
      one: '1 gün içinde kalıcı olarak silinecek',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Geri yükle';

  @override
  String get categoriesTitle => 'Kategoriler';

  @override
  String get addCategoryTooltip => 'Kategori ekle';

  @override
  String get addCategoryTitle => 'Kategori ekle';

  @override
  String get editCategoryTitle => 'Kategoriyi düzenle';

  @override
  String get categoryNameLabel => 'Ad';

  @override
  String get categoryNameRequired => 'Bir ad girin';

  @override
  String get categoryNameTaken => 'Bu ad zaten kullanılıyor';

  @override
  String get archiveAction => 'Arşivle';

  @override
  String get unarchiveAction => 'Arşivden çıkar';

  @override
  String get deleteAction => 'Sil';

  @override
  String get archivedHeader => 'Arşivlenenler';

  @override
  String get categorySaveFailed => 'Kategori kaydedilemedi. Tekrar deneyin.';

  @override
  String get accountsTitle => 'Hesaplar';

  @override
  String get accountCash => 'Nakit';

  @override
  String get accountTypeLabel => 'Tür';

  @override
  String get accountTypeCash => 'Nakit';

  @override
  String get accountTypeBank => 'Banka';

  @override
  String get accountTypeCard => 'Kart';

  @override
  String get accountTypeOther => 'Diğer';

  @override
  String get addAccountTooltip => 'Hesap ekle';

  @override
  String get addAccountTitle => 'Hesap ekle';

  @override
  String get editAccountTitle => 'Hesabı düzenle';

  @override
  String get openingBalanceLabel => 'Açılış bakiyesi';

  @override
  String get openingDateLabel => 'Açılış tarihi';

  @override
  String get accountSaveFailed => 'Hesap kaydedilemedi. Tekrar deneyin.';

  @override
  String get transferTitle => 'Transfer';

  @override
  String get editTransferTitle => 'Transferi düzenle';

  @override
  String get transferLabel => 'Transfer';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Kaynak';

  @override
  String get toAccountLabel => 'Hedef';

  @override
  String get sameAccountError => 'İki farklı hesap seçin';

  @override
  String get needTwoAccounts =>
      'Hesaplar arasında para aktarmak için ikinci bir hesap ekleyin.';

  @override
  String get addTransferButton => 'Transfer Ekle';

  @override
  String get transferSaveFailed => 'Transfer kaydedilemedi. Tekrar deneyin.';

  @override
  String get searchHint => 'İşlemlerde ara';

  @override
  String get allTypesFilter => 'Tümü';

  @override
  String get allCategoriesFilter => 'Tüm kategoriler';

  @override
  String get allAccountsFilter => 'Tüm hesaplar';

  @override
  String get allTimeFilter => 'Tüm zamanlar';

  @override
  String get clearDatesTooltip => 'Tarihleri temizle';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sonuç',
      one: '1 sonuç',
    );
    return '$_temp0 · Gelir $income · Gider $expense';
  }

  @override
  String get noSearchResults => 'Eşleşen işlem yok.';

  @override
  String get budgetsTitle => 'Bütçeler';

  @override
  String get budgetsTooltip => 'Bütçeler';

  @override
  String get overallBudget => 'Genel';

  @override
  String get noBudget => 'Bütçe yok';

  @override
  String budgetsHint(String period) {
    return 'Limitler $period itibarıyla geçerlidir; önceki dönemler kendi limitlerini korur.';
  }

  @override
  String get budgetLimitLabel => 'Dönem başına limit';

  @override
  String get budgetSaveFailed => 'Bütçe kaydedilemedi. Tekrar deneyin.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent / $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return '$remaining kaldı · günde $perDay';
  }

  @override
  String budgetLeft(String remaining) {
    return '$remaining kaldı';
  }

  @override
  String budgetOverBy(String amount) {
    return '$amount aşıldı';
  }

  @override
  String get budgetLimitReached => 'Limite ulaşıldı';

  @override
  String budgetLimitOnly(String limit) {
    return 'Limit $limit';
  }

  @override
  String get recurringTitle => 'Tekrarlanan';

  @override
  String get addRecurringTooltip => 'Tekrarlanan ekle';

  @override
  String get addRecurringTitle => 'Tekrarlanan ekle';

  @override
  String get editRecurringTitle => 'Tekrarlananı düzenle';

  @override
  String get dueHeader => 'Zamanı gelenler';

  @override
  String get upcomingHeader => 'Önümüzdeki 30 gün';

  @override
  String get rulesHeader => 'Kurallar';

  @override
  String get nothingUpcoming => 'Önümüzdeki 30 günde bir şey yok.';

  @override
  String get noRules => 'Henüz tekrarlanan işlem yok.';

  @override
  String get postButton => 'İşle';

  @override
  String get skipButton => 'Atla';

  @override
  String get postFailed => 'İşlem kaydedilemedi. Tekrar deneyin.';

  @override
  String get recurringSaveFailed =>
      'Tekrarlanan işlem kaydedilemedi. Tekrar deneyin.';

  @override
  String get everyLabel => 'Her';

  @override
  String get frequencyDays => 'Gün';

  @override
  String get frequencyWeeks => 'Hafta';

  @override
  String get frequencyMonths => 'Ay';

  @override
  String get frequencyYears => 'Yıl';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count günde bir',
      one: 'Her gün',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count haftada bir',
      one: 'Her hafta',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ayda bir',
      one: 'Her ay',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yılda bir',
      one: 'Her yıl',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Duraklatıldı';
  }

  @override
  String get startsLabel => 'Başlangıç';

  @override
  String get endsLabel => 'Bitiş';

  @override
  String get endNever => 'Hiçbir zaman';

  @override
  String get endAfter => 'Tekrar sayısıyla';

  @override
  String get endOnDate => 'Tarihte';

  @override
  String get timesLabel => 'Kez';

  @override
  String get endsOnLabel => 'Bitiş tarihi';

  @override
  String get wholeNumberInvalid => '1 veya daha büyük bir tam sayı girin';

  @override
  String get endDateInvalid => 'Bitiş tarihi başlangıçtan sonra olmalı';

  @override
  String get autoPostLabel => 'Otomatik işle';

  @override
  String get autoPostSubtitle =>
      'Aksi halde Zamanı gelenler\'de bir dokunuş bekler';

  @override
  String get pauseTooltip => 'Duraklat';

  @override
  String get resumeTooltip => 'Sürdür';

  @override
  String get categoryFood => 'Yemek';

  @override
  String get categoryGroceries => 'Market';

  @override
  String get categoryTransport => 'Ulaşım';

  @override
  String get categoryShopping => 'Alışveriş';

  @override
  String get categoryBills => 'Faturalar';

  @override
  String get categoryRent => 'Kira';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryEducation => 'Eğitim';

  @override
  String get categoryEntertainment => 'Eğlence';

  @override
  String get categorySalary => 'Maaş';

  @override
  String get categoryBusiness => 'İş';

  @override
  String get categoryInvestment => 'Yatırım';

  @override
  String get categoryGift => 'Hediye';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get previousPeriodTooltip => 'Önceki dönem';

  @override
  String get nextPeriodTooltip => 'Sonraki dönem';

  @override
  String get insightsTooltip => 'Analizler';

  @override
  String get insightsTitle => 'Analizler';

  @override
  String get calendarTab => 'Takvim';

  @override
  String get trendTab => 'Eğilim';

  @override
  String get noIncomeInPeriod => 'Bu dönemde henüz gelir yok.';

  @override
  String totalIncome(String amount) {
    return 'Toplam gelir: $amount';
  }

  @override
  String get calendarHint => 'İşlemlerini görmek için bir güne dokunun.';

  @override
  String get dayEmpty => 'Bu günde bir şey yok.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ay',
      one: '1 ay',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Gelir $income · Gider $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Dönem başına ortalama · Gelir $income · Gider $expense';
  }

  @override
  String get weekStartLabel => 'Haftanın ilk günü';

  @override
  String weekStartDefault(String day) {
    return 'Varsayılan ($day)';
  }

  @override
  String get firstRunTitle => 'Monthly Expenses\'a hoş geldiniz';

  @override
  String get firstRunMessage =>
      'Harcamalarınızı ve kazançlarınızı takip edin. Verileriniz bu cihazda kalır.';

  @override
  String get addFirstTransactionButton => 'İlk işleminizi ekleyin';

  @override
  String get exportCsvMenu => 'CSV dışa aktar';

  @override
  String get exportCsvTooltip => 'CSV dışa aktar';

  @override
  String get csvExported => 'CSV kaydedildi';

  @override
  String get csvExportFailed => 'CSV dışa aktarılamadı. Tekrar deneyin.';

  @override
  String get backupTitle => 'Yedekleme ve geri yükleme';

  @override
  String get backupIntro =>
      'Yedekler, seçtiğiniz yere kaydettiğiniz dosyalardır. Hiçbir şey otomatik olarak yüklenmez veya gönderilmez.';

  @override
  String get backUpNowTitle => 'Şimdi yedekle';

  @override
  String lastBackupLine(String date) {
    return 'Son yedekleme $date';
  }

  @override
  String get neverBackedUp => 'Henüz yedek yok';

  @override
  String get backupSaved => 'Yedek kaydedildi';

  @override
  String get backupSaveFailed => 'Yedek kaydedilemedi. Tekrar deneyin.';

  @override
  String get restoreFromFileTitle => 'Dosyadan geri yükle';

  @override
  String get restoreFromFileSubtitle =>
      'Bir yedeği verilerinizle birleştirin veya verilerinizi onunla değiştirin';

  @override
  String get backupReminderLabel => 'Yedekleme hatırlatıcısı';

  @override
  String get backupReminderSubtitle => '20 işlemden sonra 30 günde bir';

  @override
  String get backupReminderNever =>
      'Verilerinizi güvende tutmak için yedekleyin';

  @override
  String backupReminderSince(String date) {
    return 'Son yedekleme $date. Yenisinin zamanı geldi mi?';
  }

  @override
  String get notNowTooltip => 'Şimdi değil';

  @override
  String get keptBackupsHeader => 'Otomatik yedekler';

  @override
  String get keptBackupsHint =>
      'Her geri yüklemeden önce bu cihaza kaydedilir.';

  @override
  String get noKeptBackups => 'Henüz yok.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count işlem',
      one: '1 işlem',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Yedeği geri yükle';

  @override
  String get mergeOption => 'Birleştir';

  @override
  String get mergeOptionSubtitle =>
      'Verilerinizi koruyun ve yedektekileri ekleyin. İkisinde de olan kayıtlarda daha yeni değişiklik geçerli olur.';

  @override
  String get replaceOption => 'Değiştir';

  @override
  String get replaceOptionSubtitle =>
      'Verilerinizi silin ve yalnızca yedeği ayarlarıyla birlikte kullanın.';

  @override
  String get restoreSafetyNote =>
      'Önce mevcut verilerinizin bir kopyası Otomatik yedekler altına kaydedilir.';

  @override
  String get restoreButton => 'Geri yükle';

  @override
  String get restoreKeptTitle => 'Bu kopya geri yüklensin mi?';

  @override
  String restoreKeptMessage(String date) {
    return 'Verileriniz $date tarihli kopyayla değiştirilir. Önce mevcut verilerinizin bir kopyası kaydedilir.';
  }

  @override
  String get backupInvalid => 'Bu dosya bir Monthly Expenses yedeği değil.';

  @override
  String get backupTooNew =>
      'Bu yedek uygulamanın daha yeni bir sürümünden. Uygulamayı güncelleyip tekrar deneyin.';

  @override
  String get backupOpenFailed => 'Dosya açılamadı. Tekrar deneyin.';

  @override
  String get backupRestoreFailed =>
      'Yedek geri yüklenemedi. Verileriniz değiştirilmedi.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count işlem geri yüklendi',
      one: '1 işlem geri yüklendi',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Birleştirildi: $added eklendi, $updated güncellendi, $unchanged değişmedi';
  }

  @override
  String get appLockLabel => 'Uygulama kilidi';

  @override
  String get appLockSubtitle =>
      'Parmak iziniz, yüzünüz veya ekran kilidinizle açın';

  @override
  String get appLockUnavailable =>
      'Uygulama kilidini kullanmak için bu cihazda bir ekran kilidi ayarlayın';

  @override
  String get appLockReason => 'Monthly Expenses kilidini aç';

  @override
  String get appLockFailed =>
      'Kimliğiniz doğrulanamadı. Uygulama kilidi değiştirilmedi.';

  @override
  String get lockedTitle => 'Monthly Expenses kilitli';

  @override
  String get unlockButton => 'Kilidi aç';

  @override
  String get widgetShowAmountsLabel => 'Tutarları widget\'ta göster';

  @override
  String get widgetShowAmountsSubtitle =>
      'Uygulama kilidi açıkken ana ekran widget\'ı tutarları gizler';

  @override
  String get widgetLeftLabel => 'Kalan';

  @override
  String get widgetAddExpense => 'Gider ekle';

  @override
  String get widgetAddIncome => 'Gelir ekle';

  @override
  String get widgetAmountsHidden => 'Tutarlar uygulama kilidiyle gizlendi';

  @override
  String get notesTitle => 'Notlar';

  @override
  String get addNoteTooltip => 'Not ekle';

  @override
  String get addNoteTitle => 'Not ekle';

  @override
  String get editNoteTitle => 'Notu düzenle';

  @override
  String get noteTextLabel => 'Not';

  @override
  String get noteTextRequired => 'Bir metin girin';

  @override
  String get noteAmountOptionalLabel => 'Tutar (isteğe bağlı)';

  @override
  String get noteDueDateToggle => 'Son tarih belirle';

  @override
  String get noteDueDateLabel => 'Son tarih';

  @override
  String get noteReminderToggle => 'Bana hatırlat';

  @override
  String get noteReminderTimeLabel => 'Hatırlatma saati';

  @override
  String get noteReminderTimeUnset => 'Bir saat seçin';

  @override
  String get noteCategoryOptionalLabel => 'Kategori (isteğe bağlı)';

  @override
  String get noteCategoryNone => 'Yok';

  @override
  String get recordNoteButton => 'İşlem olarak kaydet';

  @override
  String get noteMarkDoneTooltip => 'Tamamlandı olarak işaretle';

  @override
  String get noteMarkOpenTooltip => 'Açık olarak işaretle';

  @override
  String get notesEmptyTitle => 'Henüz bir şey yok';

  @override
  String get notesEmptyMessage =>
      'Notlar, isteğe bağlı bir tarih, tutar ve kategoriyle yapılacak veya kontrol edilecek şeyleri hatırlatır.';

  @override
  String get addNoteButton => 'Not ekle';

  @override
  String get notesOpenHeader => 'Açık';

  @override
  String get notesDoneHeader => 'Tamamlandı';

  @override
  String get noteDeleted => 'Not silindi.';

  @override
  String get noteSaveFailed => 'Not kaydedilemedi. Tekrar deneyin.';

  @override
  String get noteDeleteFailed => 'Not silinemedi. Tekrar deneyin.';

  @override
  String get noteRestoreFailed => 'Not geri yüklenemedi. Tekrar deneyin.';

  @override
  String get notesSearchHint => 'Notlarda ara';

  @override
  String get noteFilterAll => 'Tümü';

  @override
  String get noteFilterOverdue => 'Gecikmiş';

  @override
  String get noteFilterDueToday => 'Bugün son tarih';

  @override
  String get noteFilterUpcoming => 'Yaklaşan';

  @override
  String get noteFilterNoDate => 'Tarihsiz';

  @override
  String get noNoteResults => 'Eşleşen not yok.';

  @override
  String get noteLinkedTransactionLabel => 'Bir işlem olarak kaydedildi';

  @override
  String get noteLinkedNoteLabel => 'Bir nottan';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notun son tarihi geldi',
      one: '1 notun son tarihi geldi',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Son tarihi gelen notlar';

  @override
  String get noteReminderTitle => 'Not hatırlatması';

  @override
  String get noteReminderLockedTitle => 'Son tarihi gelen bir not var';

  @override
  String get noteReminderPermissionDenied =>
      'Not hatırlatmaları alabilmek için sistem ayarlarından bildirimleri açın.';

  @override
  String reportRange(String from, String to) {
    return '$from - $to';
  }

  @override
  String reportCreated(String when) {
    return 'Oluşturulma: $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Sayfa $page / $pages';
  }

  @override
  String get reportNet => 'Net';

  @override
  String get reportOpeningBalance => 'Açılış bakiyesi';

  @override
  String get reportClosingBalance => 'Kapanış bakiyesi';

  @override
  String get reportSpendingHeader => 'Kategoriye göre harcama';

  @override
  String get reportEarningHeader => 'Kategoriye göre gelir';

  @override
  String get reportTrendHeader => 'Eğilim';

  @override
  String get reportEntriesHeader => 'İşlemler';

  @override
  String get reportUpcomingHeader => 'Yaklaşan';

  @override
  String get reportUpcomingNote =>
      'İleri tarihli olduğundan yukarıdaki toplamlara dahil değil.';

  @override
  String get reportAmountColumn => 'Tutar';

  @override
  String get reportShareColumn => 'Pay';

  @override
  String get reportBudgetColumn => 'Bütçe';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$limit bütçesinin $used kadarı';
  }

  @override
  String get reportDetailsColumn => 'Ayrıntılar';

  @override
  String get reportEmpty => 'Bu tarihler için raporlanacak bir şey yok.';

  @override
  String get exportPdfMenu => 'PDF dışa aktar';

  @override
  String get reportTitle => 'PDF dışa aktar';

  @override
  String get reportPreviewTitle => 'Rapor';

  @override
  String get reportCoversHeader => 'Kapsamı';

  @override
  String get reportRangePeriod => 'Bu dönem';

  @override
  String get reportRangeCustom => 'Tarihler';

  @override
  String get reportRangeYear => 'Yıl';

  @override
  String get reportFromLabel => 'Başlangıç';

  @override
  String get reportToLabel => 'Bitiş';

  @override
  String get reportYearLabel => 'Yıl';

  @override
  String get reportAccountLabel => 'Hesap';

  @override
  String get reportAllAccounts => 'Tüm hesaplar';

  @override
  String get reportIncludeHeader => 'İçeriği';

  @override
  String get reportIncludeSubtitle =>
      'Paylaşmak istemediğiniz her şeyi çıkarın.';

  @override
  String get reportIncludeTransactions => 'İşlem listesi';

  @override
  String get reportIncludeDetails => 'Başlıklar ve notlar';

  @override
  String get reportIncludeAccounts => 'Hesap adları';

  @override
  String get reportCreateButton => 'Raporu oluştur';

  @override
  String get reportBuilding => 'Rapor oluşturuluyor';

  @override
  String get reportFailed => 'Rapor oluşturulamadı. Tekrar deneyin.';

  @override
  String get reportRangeBackwards => 'İlk tarih son tarihten önce olmalı.';
}
