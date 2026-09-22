// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Monthly Expenses';

  @override
  String get settingsTooltip => 'Pengaturan';

  @override
  String get transferTooltip => 'Transfer';

  @override
  String get searchTooltip => 'Cari';

  @override
  String get addButton => 'Tambah';

  @override
  String get emptyPeriod => 'Belum ada transaksi di periode ini.';

  @override
  String get balanceLabel => 'Saldo';

  @override
  String get expandSummaryTooltip => 'Tampilkan pemasukan dan pengeluaran';

  @override
  String get collapseSummaryTooltip => 'Tampilkan saldo saja';

  @override
  String get periodNetLabel => 'Periode ini';

  @override
  String carriedForwardLine(String amount) {
    return 'Saldo dibawa $amount';
  }

  @override
  String get incomeLabel => 'Pemasukan';

  @override
  String get expenseLabel => 'Pengeluaran';

  @override
  String upcomingCategory(String category) {
    return '$category · Mendatang';
  }

  @override
  String get upcomingLabel => 'Mendatang';

  @override
  String detailAdded(String date) {
    return 'Ditambahkan $date';
  }

  @override
  String detailChanged(String date) {
    return 'Terakhir diubah $date';
  }

  @override
  String recurringDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transaksi berulang jatuh tempo',
      one: '1 transaksi berulang jatuh tempo',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardSummary(String percent, int over) {
    String _temp0 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$percent terpakai · $over melebihi batas',
      one: '$percent terpakai · 1 melebihi batas',
      zero: '$percent terpakai',
    );
    return '$_temp0';
  }

  @override
  String budgetsCardPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anggaran ditetapkan',
      one: '1 anggaran ditetapkan',
    );
    return '$_temp0';
  }

  @override
  String get deleteFailed => 'Transaksi gagal dihapus. Coba lagi.';

  @override
  String get transactionDeleted => 'Transaksi dihapus';

  @override
  String get transferDeleted => 'Transfer dihapus';

  @override
  String get undoButton => 'Urungkan';

  @override
  String get undoFailed => 'Gagal mengurungkan. Coba lagi.';

  @override
  String get restoreFailed => 'Transaksi gagal dipulihkan. Coba lagi.';

  @override
  String get restoreTransferFailed =>
      'Transfer tidak bisa dipulihkan. Coba lagi.';

  @override
  String get addTransactionTitle => 'Tambah Transaksi';

  @override
  String get editTransactionTitle => 'Ubah Transaksi';

  @override
  String get transactionDetailTitle => 'Detail';

  @override
  String get editTooltip => 'Ubah';

  @override
  String get deleteTooltip => 'Hapus';

  @override
  String get duplicateTooltip => 'Duplikat';

  @override
  String get rowMenuTooltip => 'Tindakan lain';

  @override
  String get deleteTransactionTitle => 'Hapus transaksi ini?';

  @override
  String get deleteTransactionMessage =>
      'Masuk ke sampah dan bisa dipulihkan selama 30 hari.';

  @override
  String get discardChangesTitle => 'Buang perubahan?';

  @override
  String get discardChangesMessage => 'Yang kamu ketik di sini belum disimpan.';

  @override
  String get discardButton => 'Buang';

  @override
  String get keepEditingButton => 'Lanjut mengedit';

  @override
  String get titleOptionalLabel => 'Judul (opsional)';

  @override
  String get amountLabel => 'Jumlah';

  @override
  String get amountRequired => 'Masukkan jumlah';

  @override
  String get amountInvalid => 'Masukkan jumlah yang valid';

  @override
  String amountResult(String amount) {
    return '= $amount';
  }

  @override
  String get backspaceTooltip => 'Hapus mundur';

  @override
  String get hideKeypadTooltip => 'Sembunyikan keypad';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get categoryRequired => 'Pilih kategori';

  @override
  String get accountLabel => 'Akun';

  @override
  String get accountRequired => 'Pilih akun';

  @override
  String get dateLabel => 'Tanggal';

  @override
  String get noteLabel => 'Catatan';

  @override
  String get previousDayTooltip => 'Hari sebelumnya';

  @override
  String get nextDayTooltip => 'Hari berikutnya';

  @override
  String get noteOptionalLabel => 'Catatan (opsional)';

  @override
  String get saveChangesButton => 'Simpan Perubahan';

  @override
  String get addTransactionButton => 'Tambah Transaksi';

  @override
  String get saveAndAddAnotherButton => 'Simpan & tambah lagi';

  @override
  String get transactionAdded => 'Transaksi ditambahkan';

  @override
  String get saveFailed => 'Transaksi gagal disimpan. Coba lagi.';

  @override
  String get noExpensesInPeriod => 'Belum ada pengeluaran di periode ini.';

  @override
  String totalSpent(String amount) {
    return 'Total pengeluaran: $amount';
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
  String get settingsTitle => 'Pengaturan';

  @override
  String get drawerAddHeader => 'Tambah';

  @override
  String get drawerAddExpense => 'Tambah pengeluaran';

  @override
  String get drawerAddIncome => 'Tambah pemasukan';

  @override
  String get drawerPlanHeader => 'Rencana';

  @override
  String get drawerReviewHeader => 'Tinjau';

  @override
  String get drawerSpending => 'Pengeluaran per kategori';

  @override
  String get drawerManageHeader => 'Kelola';

  @override
  String get drawerDataHeader => 'Data';

  @override
  String get currencyLabel => 'Mata uang';

  @override
  String get currencySearchHint => 'Cari mata uang';

  @override
  String changeCurrencyTitle(String code) {
    return 'Ganti mata uang ke $code?';
  }

  @override
  String get changeCurrencyMessage =>
      'Jumlah tetap sama; hanya label mata uangnya yang berubah.';

  @override
  String get changeButton => 'Ganti';

  @override
  String get cancelButton => 'Batal';

  @override
  String get saveButton => 'Simpan';

  @override
  String get removeButton => 'Hapus';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get languageSystem => 'Bawaan sistem';

  @override
  String get monthStartLabel => 'Hari pertama bulan';

  @override
  String get monthStartLastDay => 'Hari terakhir';

  @override
  String get showCarriedForwardLabel => 'Bawa saldo maju';

  @override
  String get showCarriedForwardSubtitle =>
      'Setiap periode dimulai dari saldo sebelumnya';

  @override
  String get trashTitle => 'Sampah';

  @override
  String get trashEmpty => 'Sampah kosong.';

  @override
  String trashItemSubtitle(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'dihapus permanen dalam $days hari',
      one: 'dihapus permanen dalam 1 hari',
    );
    return '$amount · $_temp0';
  }

  @override
  String get restoreTooltip => 'Pulihkan';

  @override
  String get categoriesTitle => 'Kategori';

  @override
  String get addCategoryTooltip => 'Tambah kategori';

  @override
  String get addCategoryTitle => 'Tambah kategori';

  @override
  String get editCategoryTitle => 'Ubah kategori';

  @override
  String get categoryNameLabel => 'Nama';

  @override
  String get categoryNameRequired => 'Masukkan nama';

  @override
  String get categoryNameTaken => 'Nama itu sudah dipakai';

  @override
  String get archiveAction => 'Arsipkan';

  @override
  String get unarchiveAction => 'Batal arsip';

  @override
  String get deleteAction => 'Hapus';

  @override
  String get archivedHeader => 'Diarsipkan';

  @override
  String get categorySaveFailed => 'Kategori gagal disimpan. Coba lagi.';

  @override
  String get accountsTitle => 'Akun';

  @override
  String get accountCash => 'Tunai';

  @override
  String get accountTypeLabel => 'Jenis';

  @override
  String get accountTypeCash => 'Tunai';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCard => 'Kartu';

  @override
  String get accountTypeOther => 'Lainnya';

  @override
  String get addAccountTooltip => 'Tambah akun';

  @override
  String get addAccountTitle => 'Tambah akun';

  @override
  String get editAccountTitle => 'Ubah akun';

  @override
  String get openingBalanceLabel => 'Saldo awal';

  @override
  String get openingDateLabel => 'Tanggal pembukaan';

  @override
  String get accountSaveFailed => 'Akun gagal disimpan. Coba lagi.';

  @override
  String get transferTitle => 'Transfer';

  @override
  String get editTransferTitle => 'Ubah transfer';

  @override
  String get transferLabel => 'Transfer';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get fromAccountLabel => 'Dari';

  @override
  String get toAccountLabel => 'Ke';

  @override
  String get sameAccountError => 'Pilih dua akun yang berbeda';

  @override
  String get needTwoAccounts =>
      'Tambah akun kedua untuk memindahkan uang antar akun.';

  @override
  String get addTransferButton => 'Tambah Transfer';

  @override
  String get transferSaveFailed => 'Transfer gagal disimpan. Coba lagi.';

  @override
  String get searchHint => 'Cari transaksi';

  @override
  String get allTypesFilter => 'Semua';

  @override
  String get allCategoriesFilter => 'Semua kategori';

  @override
  String get allAccountsFilter => 'Semua akun';

  @override
  String get allTimeFilter => 'Semua waktu';

  @override
  String get clearDatesTooltip => 'Hapus tanggal';

  @override
  String searchSummary(int count, String income, String expense) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hasil',
      one: '1 hasil',
    );
    return '$_temp0 · Pemasukan $income · Pengeluaran $expense';
  }

  @override
  String get noSearchResults => 'Tidak ada transaksi yang cocok.';

  @override
  String get budgetsTitle => 'Anggaran';

  @override
  String get budgetsTooltip => 'Anggaran';

  @override
  String get overallBudget => 'Keseluruhan';

  @override
  String get noBudget => 'Tanpa anggaran';

  @override
  String budgetsHint(String period) {
    return 'Batas berlaku mulai $period; periode sebelumnya tetap dengan batasnya sendiri.';
  }

  @override
  String get budgetLimitLabel => 'Batas per periode';

  @override
  String get budgetSaveFailed => 'Anggaran gagal disimpan. Coba lagi.';

  @override
  String budgetSpentOfLimit(String spent, String limit) {
    return '$spent dari $limit';
  }

  @override
  String budgetLeftPerDay(String remaining, String perDay) {
    return 'Sisa $remaining · $perDay per hari';
  }

  @override
  String homeSpentPerDay(String amount, String perDay) {
    return 'Terpakai $amount · $perDay per hari sejauh ini';
  }

  @override
  String get homeSetBudget => 'Atur anggaran bulanan';

  @override
  String budgetLeft(String remaining) {
    return 'Sisa $remaining';
  }

  @override
  String budgetOverBy(String amount) {
    return 'Kelebihan $amount';
  }

  @override
  String get budgetLimitReached => 'Batas tercapai';

  @override
  String budgetLimitOnly(String limit) {
    return 'Batas $limit';
  }

  @override
  String get recurringTitle => 'Berulang';

  @override
  String get addRecurringTooltip => 'Tambah berulang';

  @override
  String get addRecurringTitle => 'Tambah transaksi berulang';

  @override
  String get editRecurringTitle => 'Ubah transaksi berulang';

  @override
  String get dueHeader => 'Jatuh tempo';

  @override
  String get upcomingHeader => '30 hari ke depan';

  @override
  String get rulesHeader => 'Aturan';

  @override
  String get nothingUpcoming => 'Tidak ada apa pun dalam 30 hari ke depan.';

  @override
  String get noRules => 'Belum ada transaksi berulang.';

  @override
  String get postButton => 'Catat';

  @override
  String get skipButton => 'Lewati';

  @override
  String get postFailed => 'Transaksi gagal dicatat. Coba lagi.';

  @override
  String get recurringSaveFailed =>
      'Transaksi berulang gagal disimpan. Coba lagi.';

  @override
  String get everyLabel => 'Setiap';

  @override
  String get frequencyDays => 'Hari';

  @override
  String get frequencyWeeks => 'Minggu';

  @override
  String get frequencyMonths => 'Bulan';

  @override
  String get frequencyYears => 'Tahun';

  @override
  String scheduleDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Setiap $count hari',
      one: 'Setiap hari',
    );
    return '$_temp0';
  }

  @override
  String scheduleWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Setiap $count minggu',
      one: 'Setiap minggu',
    );
    return '$_temp0';
  }

  @override
  String scheduleMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Setiap $count bulan',
      one: 'Setiap bulan',
    );
    return '$_temp0';
  }

  @override
  String scheduleYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Setiap $count tahun',
      one: 'Setiap tahun',
    );
    return '$_temp0';
  }

  @override
  String pausedSchedule(String schedule) {
    return '$schedule · Dijeda';
  }

  @override
  String get startsLabel => 'Mulai';

  @override
  String get endsLabel => 'Berakhir';

  @override
  String get endNever => 'Tidak pernah';

  @override
  String get endAfter => 'Setelah';

  @override
  String get endOnDate => 'Pada tanggal';

  @override
  String get timesLabel => 'Kali';

  @override
  String get endsOnLabel => 'Berakhir pada';

  @override
  String get wholeNumberInvalid => 'Masukkan bilangan bulat mulai dari 1';

  @override
  String get endDateInvalid => 'Tanggal akhir harus setelah tanggal mulai';

  @override
  String get autoPostLabel => 'Catat otomatis';

  @override
  String get autoPostSubtitle =>
      'Jika tidak, transaksi menunggu di Jatuh Tempo untuk diketuk';

  @override
  String get pauseTooltip => 'Jeda';

  @override
  String get resumeTooltip => 'Lanjutkan';

  @override
  String get categoryFood => 'Makanan';

  @override
  String get categoryGroceries => 'Belanja bulanan';

  @override
  String get categoryTransport => 'Transportasi';

  @override
  String get categoryShopping => 'Belanja';

  @override
  String get categoryBills => 'Tagihan';

  @override
  String get categoryRent => 'Sewa';

  @override
  String get categoryHealth => 'Kesehatan';

  @override
  String get categoryEducation => 'Pendidikan';

  @override
  String get categoryEntertainment => 'Hiburan';

  @override
  String get categorySalary => 'Gaji';

  @override
  String get categoryBusiness => 'Bisnis';

  @override
  String get categoryInvestment => 'Investasi';

  @override
  String get categoryGift => 'Hadiah';

  @override
  String get categoryOther => 'Lainnya';

  @override
  String get previousPeriodTooltip => 'Periode sebelumnya';

  @override
  String get wholePeriodTooltip => 'Tampilkan seluruh periode';

  @override
  String get nextPeriodTooltip => 'Periode berikutnya';

  @override
  String get insightsTooltip => 'Wawasan';

  @override
  String get insightsTitle => 'Wawasan';

  @override
  String get calendarTab => 'Kalender';

  @override
  String get trendTab => 'Tren';

  @override
  String get noIncomeInPeriod => 'Belum ada pemasukan di periode ini.';

  @override
  String totalIncome(String amount) {
    return 'Total pemasukan: $amount';
  }

  @override
  String get calendarHint => 'Ketuk tanggal untuk melihat transaksinya.';

  @override
  String get dayEmpty => 'Tidak ada apa pun di hari ini.';

  @override
  String trendMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bulan',
      one: '1 bulan',
    );
    return '$_temp0';
  }

  @override
  String incomeExpenseLine(String income, String expense) {
    return 'Pemasukan $income · Pengeluaran $expense';
  }

  @override
  String trendAverage(String income, String expense) {
    return 'Rata-rata per periode · Pemasukan $income · Pengeluaran $expense';
  }

  @override
  String get weekStartLabel => 'Hari pertama minggu';

  @override
  String weekStartDefault(String day) {
    return 'Bawaan ($day)';
  }

  @override
  String get firstRunTitle => 'Selamat datang di Monthly Expenses';

  @override
  String get firstRunMessage =>
      'Catat pengeluaran dan pemasukan Anda. Data Anda tetap di perangkat ini.';

  @override
  String get addFirstTransactionButton => 'Tambah transaksi pertama Anda';

  @override
  String get setupIntro =>
      'Pilih bahasa dan mata uang Anda. Anda bisa mengubahnya nanti di Pengaturan.';

  @override
  String get setupContinueButton => 'Lanjutkan';

  @override
  String get setupRestoreTitle => 'Pulihkan cadangan';

  @override
  String get setupRestoreSubtitle =>
      'Kembalikan data dan pengaturan Anda dari file cadangan';

  @override
  String get walkthroughEntryTitle => 'Catat dalam hitungan detik';

  @override
  String get walkthroughEntryBody =>
      'Keypad yang langsung menjumlahkan, foto struk, dan catatan suara saat mengetik terasa lambat.';

  @override
  String get walkthroughPlanTitle => 'Rencanakan bulan Anda';

  @override
  String get walkthroughPlanBody =>
      'Anggaran per kategori, tagihan yang berulang sendiri, dan catatan pengingat.';

  @override
  String get walkthroughInsightsTitle => 'Lihat ke mana uang Anda pergi';

  @override
  String get walkthroughInsightsBody =>
      'Grafik, kalender, dan laporan PDF atau CSV untuk periode mana pun.';

  @override
  String get walkthroughPrivacyTitle => 'Sepenuhnya milik Anda';

  @override
  String get walkthroughPrivacyBody =>
      'Tanpa akun. Yang kamu catat tetap di ponsel ini; iklan yang membiayai aplikasi ini tidak pernah melihatnya.';

  @override
  String get walkthroughBringTitle => 'Bawa data yang sudah Anda punya';

  @override
  String get walkthroughBringBody =>
      'Pindah dari aplikasi atau ponsel lain? Mulai dari cadangan atau CSV, bukan dari aplikasi kosong.';

  @override
  String get firstRunRestoreTitle => 'Pulihkan cadangan ini?';

  @override
  String get firstRunRestoreMessage =>
      'Ini mengganti semua isi aplikasi, dan mengembalikan bahasa serta mata uang saat cadangan disimpan.';

  @override
  String get walkthroughNextButton => 'Berikutnya';

  @override
  String get walkthroughStartButton => 'Mulai';

  @override
  String get walkthroughDoneButton => 'Selesai';

  @override
  String walkthroughProgress(int current, int total) {
    return 'Halaman $current dari $total';
  }

  @override
  String get walkthroughReplayTitle => 'Putar ulang panduan';

  @override
  String get walkthroughReplaySubtitle =>
      'Empat halaman yang ditampilkan saat aplikasi baru diinstal';

  @override
  String get removeAdsTitle => 'Hapus iklan';

  @override
  String get exportCsvMenu => 'Ekspor CSV';

  @override
  String get exportCsvTooltip => 'Ekspor CSV';

  @override
  String get csvExported => 'CSV disimpan';

  @override
  String get csvExportFailed => 'CSV gagal diekspor. Coba lagi.';

  @override
  String get backupTitle => 'Cadangan & pemulihan';

  @override
  String get backupIntro =>
      'Cadangan adalah file yang Anda simpan sendiri. Tidak ada yang diunggah atau dikirim otomatis.';

  @override
  String get backUpNowTitle => 'Cadangkan sekarang';

  @override
  String lastBackupLine(String date) {
    return 'Cadangan terakhir $date';
  }

  @override
  String get neverBackedUp => 'Belum pernah dicadangkan';

  @override
  String get backupSaved => 'Cadangan disimpan';

  @override
  String get backupSaveFailed => 'Cadangan gagal disimpan. Coba lagi.';

  @override
  String get restoreFromFileTitle => 'Pulihkan dari file';

  @override
  String get restoreFromFileSubtitle =>
      'Gabungkan cadangan dengan data Anda, atau ganti data Anda dengannya';

  @override
  String get backupReminderLabel => 'Pengingat cadangan';

  @override
  String get backupReminderSubtitle =>
      'Setiap 30 hari setelah Anda punya 20 transaksi';

  @override
  String get backupReminderNever => 'Cadangkan data Anda agar tetap aman';

  @override
  String backupReminderSince(String date) {
    return 'Cadangan terakhir $date. Saatnya membuat yang baru?';
  }

  @override
  String get notNowTooltip => 'Nanti saja';

  @override
  String get keptBackupsHeader => 'Cadangan otomatis';

  @override
  String get keptBackupsHint =>
      'Disimpan di perangkat ini sebelum setiap pemulihan.';

  @override
  String get noKeptBackups => 'Belum ada.';

  @override
  String backupSummary(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transaksi',
      one: '1 transaksi',
    );
    return '$date · $_temp0';
  }

  @override
  String get restoreTitle => 'Pulihkan cadangan';

  @override
  String get mergeOption => 'Gabungkan';

  @override
  String get mergeOptionSubtitle =>
      'Simpan data Anda dan tambahkan data cadangan. Jika ada data yang sama, perubahan terbaru yang dipakai.';

  @override
  String get replaceOption => 'Ganti';

  @override
  String get replaceOptionSubtitle =>
      'Hapus data Anda dan gunakan hanya data cadangan, beserta pengaturannya.';

  @override
  String get restoreSafetyNote =>
      'Salinan data Anda saat ini disimpan lebih dulu di Cadangan otomatis.';

  @override
  String get restoreButton => 'Pulihkan';

  @override
  String get restoreKeptTitle => 'Pulihkan salinan ini?';

  @override
  String restoreKeptMessage(String date) {
    return 'Data Anda diganti dengan salinan dari $date. Salinan data Anda saat ini disimpan lebih dulu.';
  }

  @override
  String get backupInvalid => 'File ini bukan cadangan Monthly Expenses.';

  @override
  String get backupTooNew =>
      'Cadangan ini dari versi aplikasi yang lebih baru. Perbarui aplikasi, lalu coba lagi.';

  @override
  String get backupOpenFailed => 'File gagal dibuka. Coba lagi.';

  @override
  String get backupRestoreFailed =>
      'Cadangan gagal dipulihkan. Data Anda tidak berubah.';

  @override
  String restoredReplace(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transaksi dipulihkan',
      one: '1 transaksi dipulihkan',
    );
    return '$_temp0';
  }

  @override
  String restoredMerge(int added, int updated, int unchanged) {
    return 'Digabungkan: $added ditambahkan, $updated diperbarui, $unchanged tidak berubah';
  }

  @override
  String get appLockLabel => 'Kunci aplikasi';

  @override
  String get appLockSubtitle =>
      'Buka dengan sidik jari, wajah, atau kunci layar Anda';

  @override
  String get appLockUnavailable =>
      'Atur kunci layar di perangkat ini untuk menggunakan kunci aplikasi';

  @override
  String get appLockReason => 'Buka kunci Monthly Expenses';

  @override
  String get appLockFailed =>
      'Gagal mengonfirmasi identitas Anda. Kunci aplikasi tidak diubah.';

  @override
  String get lockedTitle => 'Monthly Expenses terkunci';

  @override
  String get unlockButton => 'Buka kunci';

  @override
  String get widgetShowAmountsLabel => 'Tampilkan jumlah pada widget';

  @override
  String get widgetShowAmountsSubtitle =>
      'Widget layar utama menyembunyikannya saat kunci aplikasi aktif';

  @override
  String get widgetLeftLabel => 'Sisa';

  @override
  String get widgetAddExpense => 'Tambah pengeluaran';

  @override
  String get widgetAddIncome => 'Tambah pemasukan';

  @override
  String get widgetAmountsHidden => 'Jumlah disembunyikan oleh kunci aplikasi';

  @override
  String get notesTitle => 'Catatan';

  @override
  String get addNoteTooltip => 'Tambah catatan';

  @override
  String get addNoteTitle => 'Tambah catatan';

  @override
  String get editNoteTitle => 'Ubah catatan';

  @override
  String get noteTextLabel => 'Catatan';

  @override
  String get noteTextRequired => 'Masukkan teks';

  @override
  String get noteAmountOptionalLabel => 'Jumlah (opsional)';

  @override
  String get noteDueDateToggle => 'Atur tanggal jatuh tempo';

  @override
  String get noteDueDateLabel => 'Tanggal jatuh tempo';

  @override
  String get noteReminderToggle => 'Ingatkan saya';

  @override
  String get noteReminderTimeLabel => 'Waktu pengingat';

  @override
  String get noteReminderTimeUnset => 'Pilih waktu';

  @override
  String get noteCategoryOptionalLabel => 'Kategori (opsional)';

  @override
  String get noteCategoryNone => 'Tidak ada';

  @override
  String get recordNoteButton => 'Catat sebagai transaksi';

  @override
  String get noteMarkDoneTooltip => 'Tandai selesai';

  @override
  String get noteMarkOpenTooltip => 'Tandai belum selesai';

  @override
  String get notesEmptyTitle => 'Belum ada apa-apa di sini';

  @override
  String get notesEmptyMessage =>
      'Catatan mengingatkan hal yang perlu dilakukan atau diperiksa, dengan tanggal, jumlah, dan kategori opsional.';

  @override
  String get addNoteButton => 'Tambah catatan';

  @override
  String get notesOpenHeader => 'Belum selesai';

  @override
  String get notesDoneHeader => 'Selesai';

  @override
  String get noteDeleted => 'Catatan dihapus.';

  @override
  String get noteSaveFailed => 'Catatan gagal disimpan. Coba lagi.';

  @override
  String get noteDeleteFailed => 'Catatan gagal dihapus. Coba lagi.';

  @override
  String get noteRestoreFailed => 'Catatan gagal dipulihkan. Coba lagi.';

  @override
  String get notesSearchHint => 'Cari catatan';

  @override
  String get noteFilterAll => 'Semua';

  @override
  String get noteFilterOverdue => 'Terlambat';

  @override
  String get noteFilterDueToday => 'Jatuh tempo hari ini';

  @override
  String get noteFilterUpcoming => 'Mendatang';

  @override
  String get noteFilterNoDate => 'Tanpa tanggal';

  @override
  String get noNoteResults => 'Tidak ada catatan yang cocok.';

  @override
  String get noteLinkedTransactionLabel => 'Dicatat sebagai transaksi';

  @override
  String get noteLinkedNoteLabel => 'Dari sebuah catatan';

  @override
  String notesDueNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catatan jatuh tempo',
      one: '1 catatan jatuh tempo',
    );
    return '$_temp0';
  }

  @override
  String get dayNotesDueHeader => 'Catatan jatuh tempo';

  @override
  String get noteReminderTitle => 'Pengingat catatan';

  @override
  String get noteReminderLockedTitle => 'Ada catatan jatuh tempo';

  @override
  String get noteReminderPermissionDenied =>
      'Aktifkan notifikasi di pengaturan sistem untuk menerima pengingat catatan.';

  @override
  String reportRange(String from, String to) {
    return '$from hingga $to';
  }

  @override
  String reportCreated(String when) {
    return 'Dibuat $when';
  }

  @override
  String reportPageOf(int page, int pages) {
    return 'Halaman $page dari $pages';
  }

  @override
  String get reportNet => 'Bersih';

  @override
  String get reportOpeningBalance => 'Saldo awal';

  @override
  String get reportClosingBalance => 'Saldo akhir';

  @override
  String get reportSpendingHeader => 'Pengeluaran per kategori';

  @override
  String get reportEarningHeader => 'Pemasukan per kategori';

  @override
  String get reportTrendHeader => 'Tren';

  @override
  String get reportEntriesHeader => 'Transaksi';

  @override
  String get reportUpcomingHeader => 'Mendatang';

  @override
  String get reportUpcomingNote =>
      'Bertanggal maju, jadi belum dihitung dalam total di atas.';

  @override
  String get reportAmountColumn => 'Jumlah';

  @override
  String get reportShareColumn => 'Porsi';

  @override
  String get reportBudgetColumn => 'Anggaran';

  @override
  String reportBudgetOf(String used, String limit) {
    return '$used dari $limit';
  }

  @override
  String get reportDetailsColumn => 'Detail';

  @override
  String get reportEmpty => 'Tidak ada yang bisa dilaporkan untuk tanggal ini.';

  @override
  String get exportPdfMenu => 'Ekspor PDF';

  @override
  String get reportTitle => 'Ekspor PDF';

  @override
  String get reportNoFontTitle => 'Belum tersedia dalam bahasa ini';

  @override
  String get reportNoFontBody =>
      'Laporan memerlukan fon untuk aksaranya, dan fon Tionghoa, Jepang, dan Korea terlalu besar untuk dibawa aplikasi. Versi berikutnya akan menawarkan unduhannya.';

  @override
  String get reportPreviewTitle => 'Laporan';

  @override
  String get reportCoversHeader => 'Cakupan laporan';

  @override
  String get reportRangePeriod => 'Periode ini';

  @override
  String get reportRangeCustom => 'Tanggal';

  @override
  String get reportRangeYear => 'Tahun';

  @override
  String get reportFromLabel => 'Dari';

  @override
  String get reportToLabel => 'Sampai';

  @override
  String get reportYearLabel => 'Tahun';

  @override
  String get reportAccountLabel => 'Akun';

  @override
  String get reportAllAccounts => 'Semua akun';

  @override
  String get reportIncludeHeader => 'Yang disertakan';

  @override
  String get reportIncludeSubtitle =>
      'Hilangkan apa pun yang tidak ingin Anda bagikan.';

  @override
  String get reportIncludeTransactions => 'Daftar transaksi';

  @override
  String get reportIncludeDetails => 'Judul dan catatan';

  @override
  String get reportIncludeAccounts => 'Nama akun';

  @override
  String get reportCreateButton => 'Buat laporan';

  @override
  String get reportBuilding => 'Membuat laporan';

  @override
  String get reportFailed => 'Laporan gagal dibuat. Coba lagi.';

  @override
  String get reportRangeBackwards =>
      'Tanggal awal harus sebelum tanggal akhir.';

  @override
  String get importTitle => 'Impor CSV';

  @override
  String get importSubtitle => 'Bawa transaksi dari aplikasi lain';

  @override
  String get importIntro =>
      'Pilih file CSV dan Anda akan melihat hasil bacaan aplikasi sebelum apa pun ditambahkan. Impor hanya menambah data — tidak pernah mengganti atau menghapus data yang sudah ada.';

  @override
  String get importChooseFile => 'Pilih file';

  @override
  String get importChooseAnother => 'Pilih file lain';

  @override
  String get importReadFailed => 'File gagal dibaca. Coba lagi.';

  @override
  String get importRefusedEmpty => 'Tidak ada isi dalam file itu.';

  @override
  String get importRefusedNoDate =>
      'Tidak ada kolom di file itu yang bisa dibaca sebagai tanggal, jadi tidak dapat diimpor.';

  @override
  String get importRefusedNoAmount =>
      'Tidak ada kolom di file itu yang bisa dibaca sebagai jumlah, jadi tidak dapat diimpor.';

  @override
  String get importRefusedNoRows =>
      'Tidak ada baris di file itu yang bisa dibaca, jadi tidak ada yang bisa diimpor.';

  @override
  String get importColumnsHeader => 'Kolom';

  @override
  String get importColumnsSubtitle =>
      'Ubah bagian yang salah dibaca oleh aplikasi.';

  @override
  String get importColumnNone => 'Tidak dipakai';

  @override
  String get importFieldType => 'Jenis';

  @override
  String get importFieldToAccount => 'Ke akun';

  @override
  String get importFieldTitle => 'Judul';

  @override
  String get importFieldNote => 'Catatan';

  @override
  String get importDateOrderLabel => 'Tanggal seperti 03/04 berarti';

  @override
  String get importDayFirst => 'Hari dulu';

  @override
  String get importMonthFirst => 'Bulan dulu';

  @override
  String get importCountsHeader => 'Yang akan terjadi';

  @override
  String importWillImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris akan diimpor',
      one: '1 baris akan diimpor',
      zero: 'Tidak ada yang akan diimpor',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris memiliki tanggal yang tidak bisa dibaca aplikasi',
      one: '1 baris memiliki tanggal yang tidak bisa dibaca aplikasi',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAmount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris memiliki jumlah yang tidak bisa dibaca aplikasi',
      one: '1 baris memiliki jumlah yang tidak bisa dibaca aplikasi',
    );
    return '$_temp0';
  }

  @override
  String importSkippedZero(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris tidak memiliki nilai uang sama sekali',
      one: '1 baris tidak memiliki nilai uang sama sekali',
    );
    return '$_temp0';
  }

  @override
  String importSkippedAlreadyThere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris sudah ada di aplikasi',
      one: '1 baris sudah ada di aplikasi',
    );
    return '$_temp0';
  }

  @override
  String importSkippedTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transfer hanya menyebutkan satu akun',
      one: '1 transfer hanya menyebutkan satu akun',
    );
    return '$_temp0';
  }

  @override
  String get importRowUnreadableDate => 'Tanggal tidak bisa dibaca';

  @override
  String get importRowUnreadableAmount => 'Jumlah tidak bisa dibaca';

  @override
  String get importRowZero => 'Tidak ada nilai uang sama sekali';

  @override
  String get importRowAlreadyThere => 'Sudah ada di aplikasi';

  @override
  String get importRowIncompleteTransfer => 'Hanya satu akun yang disebutkan';

  @override
  String get importNamesHeader => 'Nama yang belum ada di aplikasi ini';

  @override
  String get importNamesSubtitle =>
      'Pilih menjadi apa masing-masing. Impor tidak pernah membuat kategori atau akun baru.';

  @override
  String get importRowsHeader => 'Baris pertama, sesuai hasil bacaan aplikasi';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dan $count lainnya',
      one: 'dan 1 lainnya',
    );
    return '$_temp0';
  }

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Impor $count baris',
      one: 'Impor 1 baris',
      zero: 'Tidak ada yang bisa diimpor',
    );
    return '$_temp0';
  }

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transaksi diimpor',
      one: '1 transaksi diimpor',
    );
    return '$_temp0';
  }

  @override
  String get importFailed =>
      'File itu gagal diimpor. Tidak ada yang ditambahkan.';

  @override
  String get attachmentsLabel => 'Lampiran';

  @override
  String get photoLabel => 'Foto';

  @override
  String get photoAdd => 'Tambah foto';

  @override
  String get photoTake => 'Ambil foto';

  @override
  String get photoChoose => 'Pilih foto';

  @override
  String get photoRemove => 'Hapus foto';

  @override
  String get photoMissing => 'Foto ini tidak ditemukan.';

  @override
  String get voiceNoteLabel => 'Catatan suara';

  @override
  String get voiceRecord => 'Rekam catatan suara';

  @override
  String voiceRecording(int seconds) {
    return 'Merekam, $seconds detik lagi';
  }

  @override
  String get voiceStop => 'Berhenti';

  @override
  String get voicePlay => 'Putar';

  @override
  String get voicePause => 'Jeda';

  @override
  String get voiceRemove => 'Hapus catatan suara';

  @override
  String get voiceMissing => 'Catatan suara ini tidak ditemukan.';

  @override
  String get microphoneRefused => 'Mikrofon dinonaktifkan untuk aplikasi ini.';

  @override
  String backupIncludesAttachments(String size) {
    return 'Termasuk lampiran, $size MB';
  }

  @override
  String get removeAdsBody =>
      'Menyembunyikan semua iklan dengan satu kali pembayaran. Ini terhubung ke akun toko kamu, jadi akan kembali meski ganti ponsel atau instal ulang.';

  @override
  String removeAdsBuyButton(String price) {
    return 'Hapus iklan seharga $price';
  }

  @override
  String get removeAdsOwned => 'Iklan sudah dimatikan. Terima kasih.';

  @override
  String get removeAdsPending => 'Menunggu toko…';

  @override
  String get removeAdsUnavailable =>
      'Toko belum punya apa pun untuk dijual di sini. Coba lagi nanti.';

  @override
  String get removeAdsFailed =>
      'Transaksi gagal, dan kamu tidak dikenai biaya.';

  @override
  String get restorePurchasesButton => 'Pulihkan pembelian';

  @override
  String get payNothingWithheld =>
      'Semua fitur tetap gratis, dengan atau tanpa iklan.';

  @override
  String get plusTitle => 'Plus';

  @override
  String get plusComingSoon => 'Segera hadir';

  @override
  String get plusBody =>
      'Koneksi bank yang mengambil transaksimu untuk dikonfirmasi. Fitur ini belum selesai, jadi belum ada yang bisa dibeli.';

  @override
  String get privacyOptionsTitle => 'Opsi privasi';

  @override
  String get privacyOptionsSubtitle =>
      'Ubah pilihanmu tentang iklan yang dipersonalisasi';

  @override
  String get dueEntryReminderTitle => 'Entri jatuh tempo';

  @override
  String dueEntryReminderOne(String title) {
    return '$title jatuh tempo hari ini dan masih menunggu.';
  }

  @override
  String get dueEntryReminderUntitled =>
      'Entri berulang jatuh tempo hari ini dan masih menunggu.';

  @override
  String dueEntryReminderMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ada $count entri berulang jatuh tempo hari ini.',
      one: 'Ada $count entri berulang jatuh tempo hari ini.',
    );
    return '$_temp0';
  }

  @override
  String get emptyDayReminderTitle => 'Belum ada catatan hari ini';

  @override
  String get emptyDayReminderBody => 'Catat pengeluaranmu selagi masih ingat.';

  @override
  String get reminderLockedTitle => 'Ada sesuatu yang menunggu';

  @override
  String get nudgeSettingsTitle => 'Ingatkan aku di hari kosong';

  @override
  String get nudgeSettingsSubtitle =>
      'Satu pengingat di malam hari, hanya pada hari tanpa catatan apa pun.';

  @override
  String get nudgeOfferTitle => 'Pengingat di hari kamu lupa?';

  @override
  String get nudgeOfferBody =>
      'Satu pengingat pada waktu pilihanmu, hanya pada hari tanpa catatan apa pun. Bisa dimatikan kapan saja.';

  @override
  String get nudgeOfferYes => 'Ya, ingatkan aku';

  @override
  String get nudgeOfferNo => 'Tidak';

  @override
  String get nudgeStoppedNotice =>
      'Pengingat berhenti setelah tiga kali tak dijawab. Aktifkan lagi kapan saja.';

  @override
  String get nudgePermissionDenied =>
      'Aktifkan notifikasi di pengaturan sistem untuk pengingat.';
}
