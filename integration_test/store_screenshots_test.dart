// Renders the Play Store screenshots on an Android device or emulator: six
// real screens with sample data, in every store language, each framed under
// a caption in that language. Android draws the text and emoji itself, so
// they look exactly as they do on a phone.
//
//   flutter test integration_test/store_screenshots_test.dart -d emulator-5554 [--dart-define=ONLY=en-US,ar]
//   adb pull /sdcard/Download/store-screenshots <folder>
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:monthly_expense_app/l10n/app_localizations.dart';
import 'package:monthly_expense_app/l10n/languages.dart';
import 'package:monthly_expense_app/models/account.dart';
import 'package:monthly_expense_app/models/budget.dart';
import 'package:monthly_expense_app/models/category.dart';
import 'package:monthly_expense_app/models/money.dart';
import 'package:monthly_expense_app/models/recurring_rule.dart';
import 'package:monthly_expense_app/models/transaction.dart';
import 'package:monthly_expense_app/providers/ads_provider.dart';
import 'package:monthly_expense_app/providers/settings_provider.dart';
import 'package:monthly_expense_app/providers/transaction_provider.dart';
import 'package:monthly_expense_app/screens/add_transaction_screen.dart';
import 'package:monthly_expense_app/screens/budgets_screen.dart';
import 'package:monthly_expense_app/screens/home_screen.dart';
import 'package:monthly_expense_app/screens/insights_screen.dart';
import 'package:monthly_expense_app/screens/recurring_screen.dart';
import 'package:monthly_expense_app/services/attachment_service.dart';
import 'package:monthly_expense_app/services/authenticator.dart';
import 'package:monthly_expense_app/services/backup_service.dart';
import 'package:monthly_expense_app/services/reminder_service.dart';

import '../test/helpers.dart';
import '../tool/render_app_icons_test.dart' show AppIconPainter;

const _only = String.fromEnvironment('ONLY');

const _purple = Color(0xFF6C5CE7);
final _today = DateTime(2026, 9, 24, 21);

/// A Play listing language: its code, the app language it shows, the
/// currency its sample data is in and how many of those make a dollar.
typedef _Store = ({String code, String app, String currency, num rate});

const List<_Store> _stores = [
  (code: 'en-US', app: 'en', currency: 'USD', rate: 1),
  (code: 'ar', app: 'ar', currency: 'SAR', rate: 3.75),
  (code: 'bn-BD', app: 'bn', currency: 'BDT', rate: 110),
  (code: 'zh-CN', app: 'zh', currency: 'CNY', rate: 7),
  (code: 'nl-NL', app: 'nl', currency: 'EUR', rate: 0.9),
  (code: 'fr-FR', app: 'fr', currency: 'EUR', rate: 0.9),
  (code: 'de-DE', app: 'de', currency: 'EUR', rate: 0.9),
  (code: 'el-GR', app: 'el', currency: 'EUR', rate: 0.9),
  (code: 'hi-IN', app: 'hi', currency: 'INR', rate: 80),
  (code: 'id', app: 'id', currency: 'IDR', rate: 15000),
  (code: 'it-IT', app: 'it', currency: 'EUR', rate: 0.9),
  (code: 'ja-JP', app: 'ja', currency: 'JPY', rate: 150),
  (code: 'ko-KR', app: 'ko', currency: 'KRW', rate: 1300),
  (code: 'pl-PL', app: 'pl', currency: 'PLN', rate: 4),
  (code: 'pt-BR', app: 'pt', currency: 'BRL', rate: 5),
  (code: 'pt-PT', app: 'pt', currency: 'EUR', rate: 0.9),
  (code: 'ru-RU', app: 'ru', currency: 'RUB', rate: 90),
  (code: 'es-ES', app: 'es', currency: 'EUR', rate: 0.9),
  (code: 'es-419', app: 'es', currency: 'MXN', rate: 18),
  (code: 'th', app: 'th', currency: 'THB', rate: 35),
  (code: 'tr-TR', app: 'tr', currency: 'TRY', rate: 35),
  (code: 'ur', app: 'ur', currency: 'PKR', rate: 280),
  (code: 'vi', app: 'vi', currency: 'VND', rate: 25000),
];

/// One caption per screenshot, in the order of [_shots].
const _captions = <String, List<String>>{
  'en-US': [
    'Your month at a glance',
    'Record in seconds',
    'See where your money goes',
    'Spot trends month by month',
    'Plan ahead with budgets',
    'Know what your bills add up to',
    'See which days cost you most',
    'No account. Your records stay on your phone.',
  ],
  'ar': [
    'شهرك في لمحة',
    'سجّل في ثوانٍ',
    'اعرف أين تذهب أموالك',
    'تابع الاتجاهات شهرًا بشهر',
    'خطّط مسبقًا بالميزانيات',
    'اعرف مجموع فواتيرك',
    'شاهد أكثر الأيام تكلفة',
    'بلا حساب. سجلاتك تبقى على هاتفك.',
  ],
  'bn-BD': [
    'এক নজরে আপনার মাস',
    'মুহূর্তেই লিখে রাখুন',
    'টাকা কোথায় যায় দেখুন',
    'মাসে মাসে প্রবণতা দেখুন',
    'বাজেট দিয়ে আগে থেকে পরিকল্পনা',
    'আপনার বিলের মোট জেনে নিন',
    'কোন দিনে খরচ বেশি দেখুন',
    'কোনো অ্যাকাউন্ট নেই। রেকর্ড থাকে আপনার ফোনেই।',
  ],
  'zh-CN': [
    '本月收支一目了然',
    '几秒完成记账',
    '看清钱的去向',
    '按月查看趋势',
    '用预算提前规划',
    '账单总额一目了然',
    '看清哪几天花得最多',
    '无需账户，记录只保存在你的手机上。',
  ],
  'nl-NL': [
    'Je maand in één oogopslag',
    'In een paar seconden genoteerd',
    'Zie waar je geld heen gaat',
    'Trends per maand',
    'Vooruit plannen met budgetten',
    'Zie hoeveel je vaste lasten zijn',
    'Zie welke dagen het meest kosten',
    'Geen account. Je transacties blijven op je telefoon.',
  ],
  'fr-FR': [
    "Votre mois en un coup d'œil",
    'Notez en quelques secondes',
    'Voyez où va votre argent',
    'Suivez les tendances mois par mois',
    'Anticipez avec des budgets',
    'Sachez à combien s\'élèvent vos factures',
    'Repérez vos jours les plus coûteux',
    'Sans compte. Vos opérations restent sur votre téléphone.',
  ],
  'de-DE': [
    'Dein Monat auf einen Blick',
    'In Sekunden erfasst',
    'Sieh, wohin dein Geld geht',
    'Trends Monat für Monat',
    'Vorausplanen mit Budgets',
    'Behalte deine Rechnungen im Blick',
    'Sieh, welche Tage am meisten kosten',
    'Kein Konto. Deine Einträge bleiben auf dem Handy.',
  ],
  'el-GR': [
    'Ο μήνας σας με μια ματιά',
    'Καταχώριση σε δευτερόλεπτα',
    'Δείτε πού πηγαίνουν τα χρήματά σας',
    'Τάσεις μήνα με μήνα',
    'Προγραμματίστε με προϋπολογισμούς',
    'Δείτε πόσο βγαίνουν οι λογαριασμοί σας',
    'Δείτε ποιες μέρες κοστίζουν περισσότερο',
    'Χωρίς λογαριασμό. Οι εγγραφές σας μένουν στο κινητό σας.',
  ],
  'hi-IN': [
    'एक नज़र में आपका महीना',
    'सेकंडों में दर्ज करें',
    'देखें पैसा कहाँ जाता है',
    'महीने-दर-महीने रुझान',
    'बजट के साथ पहले से योजना',
    'जानें आपके बिल कितने बनते हैं',
    'देखें किन दिनों में खर्च सबसे ज़्यादा हुआ',
    'कोई अकाउंट नहीं। रिकॉर्ड आपके फ़ोन पर ही।',
  ],
  'id': [
    'Bulan Anda dalam sekilas',
    'Catat dalam hitungan detik',
    'Lihat ke mana uang Anda pergi',
    'Tren dari bulan ke bulan',
    'Rencanakan dengan anggaran',
    'Ketahui total tagihan Anda',
    'Lihat hari mana yang paling boros',
    'Tanpa akun. Catatan tetap di ponsel Anda.',
  ],
  'it-IT': [
    "Il tuo mese a colpo d'occhio",
    'Registra in pochi secondi',
    'Scopri dove vanno i tuoi soldi',
    "L'andamento mese per mese",
    'Pianifica con i budget',
    'Scopri a quanto ammontano le bollette',
    'Scopri quali giorni ti costano di più',
    'Nessun account. I tuoi movimenti restano sul telefono.',
  ],
  'ja-JP': [
    '今月の収支がひと目で分かる',
    '数秒で記録',
    'お金の行き先を把握',
    '月ごとの推移をチェック',
    '予算で先を見越して計画',
    '請求の合計をひと目で確認',
    '出費が多い日をひと目で確認',
    'アカウント不要。記録はスマホの中だけ。',
  ],
  'ko-KR': [
    '한 달 살림을 한눈에',
    '몇 초 만에 기록',
    '돈이 어디로 가는지 확인',
    '월별 추세 확인',
    '예산으로 미리 계획',
    '고정 지출 총액을 한눈에',
    '지출이 많은 날을 한눈에',
    '계정 없이, 기록은 휴대폰에만.',
  ],
  'pl-PL': [
    'Twój miesiąc w skrócie',
    'Zapis w kilka sekund',
    'Zobacz, dokąd idą pieniądze',
    'Trendy miesiąc po miesiącu',
    'Planuj z budżetami',
    'Sprawdź, ile wynoszą twoje rachunki',
    'Zobacz, które dni kosztują najwięcej',
    'Bez konta. Twoje wpisy zostają na telefonie.',
  ],
  'pt-BR': [
    'Seu mês em um relance',
    'Registre em segundos',
    'Veja para onde vai o seu dinheiro',
    'Tendências mês a mês',
    'Planeje com orçamentos',
    'Saiba quanto somam suas contas',
    'Veja quais dias custam mais',
    'Sem conta. Seus registros ficam no seu celular.',
  ],
  'pt-PT': [
    'O seu mês num relance',
    'Registe em segundos',
    'Veja para onde vai o seu dinheiro',
    'Tendências mês a mês',
    'Planeie com orçamentos',
    'Saiba quanto somam as suas contas',
    'Veja que dias custam mais',
    'Sem conta. Os seus registos ficam no seu telemóvel.',
  ],
  'ru-RU': [
    'Ваш месяц с первого взгляда',
    'Запись за секунды',
    'Узнайте, куда уходят деньги',
    'Динамика по месяцам',
    'Планируйте с бюджетами',
    'Узнайте сумму ваших счетов',
    'Узнайте, какие дни обходятся дороже',
    'Без аккаунта. Записи остаются на телефоне.',
  ],
  'es-ES': [
    'Tu mes de un vistazo',
    'Anota en segundos',
    'Mira adónde va tu dinero',
    'Tendencias mes a mes',
    'Planifica con presupuestos',
    'Descubre a cuánto suman tus facturas',
    'Descubre qué días te cuestan más',
    'Sin cuenta. Tus registros quedan en tu móvil.',
  ],
  'es-419': [
    'Tu mes de un vistazo',
    'Registra en segundos',
    'Mira adónde va tu dinero',
    'Tendencias mes a mes',
    'Planifica con presupuestos',
    'Descubre a cuánto suman tus cuentas',
    'Descubre qué días te cuestan más',
    'Sin cuenta. Tus registros quedan en tu celular.',
  ],
  'th': [
    'ดูเดือนของคุณได้ในพริบตา',
    'บันทึกได้ในไม่กี่วินาที',
    'ดูว่าเงินไปไหน',
    'แนวโน้มรายเดือน',
    'วางแผนล่วงหน้าด้วยงบประมาณ',
    'รู้ยอดรวมค่าใช้จ่ายประจำ',
    'ดูว่าวันไหนใช้จ่ายมากที่สุด',
    'ไม่ต้องมีบัญชี รายการอยู่ในโทรศัพท์ของคุณ',
  ],
  'tr-TR': [
    'Ayınız bir bakışta',
    'Saniyeler içinde kaydedin',
    'Paranızın nereye gittiğini görün',
    'Ay ay eğilimler',
    'Bütçelerle önceden planlayın',
    'Faturalarınızın toplamını görün',
    'Hangi günlerin daha pahalıya mal olduğunu görün',
    'Hesap yok. Kayıtlarınız telefonunuzda kalır.',
  ],
  'ur': [
    'ایک نظر میں آپ کا مہینہ',
    'سیکنڈوں میں درج کریں',
    'دیکھیں پیسہ کہاں جاتا ہے',
    'مہینہ بہ مہینہ رجحانات',
    'بجٹ کے ساتھ پہلے سے منصوبہ بندی',
    'جانیں آپ کے بل کتنے بنتے ہیں',
    'دیکھیں کن دنوں میں خرچ سب سے زیادہ ہوا',
    'کوئی اکاؤنٹ نہیں۔ ریکارڈ آپ کے فون پر۔',
  ],
  'vi': [
    'Cả tháng trong một cái nhìn',
    'Ghi lại trong vài giây',
    'Xem tiền của bạn đi đâu',
    'Xu hướng theo từng tháng',
    'Lên kế hoạch với ngân sách',
    'Biết tổng các hóa đơn của bạn',
    'Xem ngày nào tốn kém nhất',
    'Không cần tài khoản. Ghi chép lưu trên điện thoại.',
  ],
};

/// The listing title in each language, for the feature graphic.
const _titles = {
  'en-US': 'Monthly Expense Tracker',
  'ar': 'متتبع المصروفات الشهرية',
  'bn-BD': 'মাসিক খরচের হিসাব',
  'zh-CN': '每月记账：收支与预算',
  'nl-NL': 'Maandelijkse uitgaventracker',
  'fr-FR': 'Suivi des dépenses mensuelles',
  'de-DE': 'Monatlicher Ausgaben-Tracker',
  'el-GR': 'Μηνιαία παρακολούθηση εξόδων',
  'hi-IN': 'मासिक खर्च ट्रैकर',
  'id': 'Pencatat Pengeluaran Bulanan',
  'it-IT': 'Monitoraggio spese mensili',
  'ja-JP': '毎月の家計簿 - 支出と予算',
  'ko-KR': '월간 지출 가계부',
  'pl-PL': 'Miesięczne wydatki i budżet',
  'pt-BR': 'Controle de gastos mensais',
  'pt-PT': 'Controlo de despesas mensais',
  'ru-RU': 'Учёт расходов по месяцам',
  'es-ES': 'Control de gastos mensuales',
  'es-419': 'Control de gastos mensuales',
  'th': 'บันทึกรายจ่ายรายเดือน',
  'tr-TR': 'Aylık Gider Takibi',
  'ur': 'ماہانہ اخراجات ٹریکر',
  'vi': 'Quản lý chi tiêu hàng tháng',
};

/// The screens, in store order: file name, whether it is dark, and how to
/// get there.
typedef _Shot = ({String name, bool dark, Widget screen});

final List<_Shot> _shots = [
  (name: '1-home', dark: false, screen: const HomeScreen()),
  (
    name: '2-add',
    dark: false,
    screen: const AddTransactionScreen(startAs: TransactionType.expense),
  ),
  (name: '3-categories', dark: false, screen: const InsightsScreen()),
  (name: '4-trend', dark: false, screen: const InsightsScreen(initialTab: 2)),
  (name: '5-budgets', dark: false, screen: const BudgetsScreen()),
  (name: '6-recurring', dark: false, screen: const RecurringScreen()),
  (
    name: '7-calendar',
    dark: false,
    screen: const InsightsScreen(initialTab: 1),
  ),
  (name: '8-home-dark', dark: true, screen: const HomeScreen()),
];

// ---------------------------------------------------------------- data ----

final _created = DateTime(2026, 1, 1);

List<Category> _categories() {
  const defaults = [
    ('cat-food', TransactionType.expense, 'food', '🍔'),
    ('cat-groceries', TransactionType.expense, 'groceries', '🛒'),
    ('cat-transport', TransactionType.expense, 'transport', '🚗'),
    ('cat-shopping', TransactionType.expense, 'shopping', '🛍️'),
    ('cat-bills', TransactionType.expense, 'bills', '💡'),
    ('cat-rent', TransactionType.expense, 'rent', '🏠'),
    ('cat-health', TransactionType.expense, 'health', '💊'),
    ('cat-education', TransactionType.expense, 'education', '📚'),
    ('cat-entertainment', TransactionType.expense, 'entertainment', '🎬'),
    ('cat-other', TransactionType.expense, 'other', '📦'),
    ('cat-salary', TransactionType.income, 'salary', '💼'),
    ('cat-business', TransactionType.income, 'business', '🏢'),
    ('cat-investment', TransactionType.income, 'investment', '📈'),
    ('cat-gift', TransactionType.income, 'gift', '🎁'),
    ('cat-income-other', TransactionType.income, 'other', '📦'),
  ];
  return [
    for (final (i, (id, type, key, icon)) in defaults.indexed)
      Category(
        id: id,
        type: type,
        defaultKey: key,
        icon: icon,
        sortOrder: i,
        createdAt: _created,
        updatedAt: _created,
      ),
  ];
}

/// A believable month, in dollars: day, category, amount. Income first.
const _month = [
  (1, 'cat-salary', 3200.0),
  (15, 'cat-business', 450.0),
  (1, 'cat-rent', 1100.0),
  (2, 'cat-food', 12.5),
  (3, 'cat-groceries', 62.4),
  (4, 'cat-transport', 40.0),
  (5, 'cat-bills', 85.0),
  (6, 'cat-food', 18.0),
  (7, 'cat-entertainment', 14.99),
  (8, 'cat-bills', 45.0),
  (9, 'cat-health', 23.4),
  (10, 'cat-groceries', 48.15),
  (12, 'cat-food', 9.75),
  (13, 'cat-shopping', 89.99),
  (14, 'cat-transport', 15.5),
  (16, 'cat-education', 29.0),
  (17, 'cat-groceries', 71.9),
  (19, 'cat-food', 24.3),
  (20, 'cat-entertainment', 32.0),
  (21, 'cat-transport', 22.0),
  (23, 'cat-groceries', 35.2),
  (24, 'cat-food', 15.5),
  (24, 'cat-groceries', 41.8),
  (24, 'cat-transport', 18.0),
];

/// [dollars] in the store's currency, rounded the way prices are.
Money _money(num dollars, _Store store) {
  final amount = dollars * store.rate;
  final step = switch (store.rate) {
    >= 10000 => 1000,
    >= 1000 => 100,
    >= 100 => 10,
    >= 50 => 1,
    _ => 0.01,
  };
  final rounded = (amount / step).round() * step;
  return Money((rounded * 1000).round());
}

List<ExpenseTransaction> _transactions(_Store store) {
  final list = <ExpenseTransaction>[];
  // Five earlier months, a little different each, so the trend has a shape.
  // Side income moves too, and tops out at 550 so the chart's highest
  // label sits clear of the gridline labels.
  const scale = {4: 1.03, 5: 0.95, 6: 0.92, 7: 1.08, 8: 0.97, 9: 1.0};
  const business = {4: 300, 5: 420, 6: 550, 7: 380, 8: 450, 9: 500};
  for (final MapEntry(key: month, value: factor) in scale.entries) {
    for (final (i, (day, category, dollars)) in _month.indexed) {
      final date = DateTime(2026, month, day, 9 + i % 9);
      if (date.isAfter(_today)) continue;
      final income = category == 'cat-salary' || category == 'cat-business';
      // Fixed amounts stay fixed; the rest move with the month.
      final fixed = income || category == 'cat-rent' || category == 'cat-bills';
      list.add(
        ExpenseTransaction(
          id: 'tx-$month-$i',
          title: '',
          amount: _money(
            category == 'cat-business'
                ? business[month]!
                : fixed
                ? dollars
                : dollars * factor,
            store,
          ),
          categoryId: category,
          accountId: Account.cashId,
          type: income ? TransactionType.income : TransactionType.expense,
          date: date,
          createdAt: date,
          updatedAt: date,
        ),
      );
    }
  }
  return list;
}

/// The bills the Recurring screen exists to total up: rent and the utilities
/// that arrive whether or not anybody thinks about them, a subscription, and
/// the salary that pays for them. Dated so the next one is a few days out,
/// which is what the header says (RCR-8).
List<RecurringRule> _rules(_Store store) {
  RecurringRule rule(
    String id,
    String category,
    num dollars,
    int day, {
    TransactionType type = TransactionType.expense,
    RecurrenceFrequency every = RecurrenceFrequency.month,
  }) {
    final start = DateTime(2026, 4, day);
    return RecurringRule(
      id: id,
      amount: _money(dollars, store),
      categoryId: category,
      accountId: Account.cashId,
      type: type,
      frequency: every,
      interval: 1,
      startDate: start,
      endType: RecurrenceEnd.never,
      // Established rules, but nothing left waiting: a listing photograph of
      // six months of unhandled bills sells nobody anything.
      activeFrom: _today,
      createdAt: _created,
      updatedAt: _created,
    );
  }

  return [
    // The salary falls a day after the rent, so the line names a bill —
    // the header above it is about bills.
    rule('rule-salary', 'cat-salary', 3200, 2, type: TransactionType.income),
    rule('rule-rent', 'cat-rent', 1100, 1),
    rule('rule-bills', 'cat-bills', 85, 5),
    // A different category, or the list shows the same word twice: the rows
    // are named after their category, which is what gets translated.
    rule('rule-insurance', 'cat-health', 45, 8),
    rule('rule-streaming', 'cat-entertainment', 14.99, 7),
  ];
}

List<Budget> _budgets(_Store store) => [
  for (final (i, (category, dollars)) in [
    (null, 1900),
    ('cat-groceries', 250),
    ('cat-food', 120),
    ('cat-transport', 100),
    ('cat-entertainment', 40),
  ].indexed)
    Budget(
      id: 'budget-$i',
      categoryId: category,
      limit: _money(dollars, store),
      effectiveFrom: DateTime(2026, 4, 1),
      createdAt: _created,
      updatedAt: _created,
    ),
];

// --------------------------------------------------------------- frame ----

/// The phone's screen, in logical pixels, and the frame's.
const _phone = Size(412, 840);
const _canvas = Size(1080, 1920);
const _ratio = 2.625;

ThemeData _theme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _purple, brightness: brightness),
  useMaterial3: true,
);

Widget _app(
  TransactionProvider provider,
  SettingsProvider settings,
  _Shot shot,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: provider),
      ChangeNotifierProvider(
        create: (_) => AdsProvider(
          settings,
          ads: FakeAdService(),
          purchases: FakePurchases(),
        ),
      ),
      Provider<BackupService>.value(value: testBackupService(FakeDB())),
      Provider<Authenticator>.value(value: FakeAuthenticator()),
      Provider<ReminderService>.value(value: FakeReminderService()),
      Provider<AttachmentService>.value(value: FakeAttachments()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.locale,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: shot.dark ? ThemeMode.dark : ThemeMode.light,
      home: shot.screen,
    ),
  );
}

Widget _statusBar(bool dark) {
  final color = dark ? Colors.white : const Color(0xFF1C1B1F);
  return SizedBox(
    height: 24,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const Spacer(),
          Icon(Icons.wifi, size: 15, color: color),
          const SizedBox(width: 4),
          Icon(Icons.signal_cellular_alt, size: 15, color: color),
          const SizedBox(width: 4),
          Icon(Icons.battery_full, size: 15, color: color),
        ],
      ),
    ),
  );
}

Widget _frame({
  required String caption,
  required bool rtl,
  required bool dark,
  required Locale locale,
  required Widget app,
}) {
  final logical = _canvas / _ratio;
  const top = 36.0;
  const captionBox = 76.0;
  const bottom = 18.0;
  const bezel = 7.0;
  final scale =
      (logical.height - top - captionBox - bottom - 2 * bezel) / _phone.height;
  final screen = _phone * scale;

  // The largest size, up to 25, at which the caption fits on two lines.
  TextStyle captionStyle(double size) => TextStyle(
    locale: locale,
    fontSize: size,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  var size = 25.0;
  while (size > 14) {
    final painter = TextPainter(
      text: TextSpan(text: caption, style: captionStyle(size)),
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: logical.width - 48);
    final fits = !painter.didExceedMaxLines;
    painter.dispose();
    if (fits) break;
    size -= 1;
  }

  return Directionality(
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B6CF0), Color(0xFF4B3BC9)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: top),
          SizedBox(
            height: captionBox,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: captionStyle(size),
                ),
              ),
            ),
          ),
          _device(app: app, dark: dark, width: screen.width, bezel: bezel),
        ],
      ),
    ),
  );
}

/// The app inside a phone [width] logical pixels wide, with a status bar.
Widget _device({
  required Widget app,
  required bool dark,
  required double width,
  required double bezel,
}) {
  final scale = width / _phone.width;
  final radius = Radius.circular(26 * scale);
  return Container(
    padding: EdgeInsets.all(bezel),
    decoration: BoxDecoration(
      color: const Color(0xFF16161A),
      borderRadius: BorderRadius.all(radius + Radius.circular(bezel)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.all(radius),
      child: SizedBox.fromSize(
        size: _phone * scale,
        child: FittedBox(
          child: SizedBox.fromSize(
            size: _phone,
            child: MediaQuery(
              data: const MediaQueryData(
                size: _phone,
                devicePixelRatio: _ratio,
                padding: EdgeInsets.only(top: 24),
                viewPadding: EdgeInsets.only(top: 24),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: app),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: _statusBar(dark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The feature graphic, 1024×500 at twice this size: the icon, the listing
/// title and a line under it, beside a phone on Home that runs off the
/// bottom edge. Mirrored in right-to-left languages.
const _featureSize = Size(512, 250);

Widget _feature({
  required String title,
  required String tagline,
  required bool rtl,
  required Locale locale,
  required Widget app,
}) {
  TextStyle style(double size, FontWeight weight, Color color) => TextStyle(
    locale: locale,
    fontSize: size,
    height: 1.2,
    fontWeight: weight,
    color: color,
  );
  return Directionality(
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B6CF0), Color(0xFF4B3BC9)],
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 36,
            top: 0,
            bottom: 0,
            width: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox.square(
                  dimension: 60,
                  child: CustomPaint(
                    painter: AppIconPainter(
                      scale: 1.05,
                      background: true,
                      rounded: true,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  style: style(24, FontWeight.bold, Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  tagline,
                  maxLines: 3,
                  style: style(14, FontWeight.w500, const Color(0xDDFFFFFF)),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            end: 40,
            top: 30,
            child: _device(app: app, dark: false, width: 170, bezel: 5),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------- main ----

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stores = _only.isEmpty
      ? _stores
      : _stores.where((s) => _only.split(',').contains(s.code)).toList();

  for (final store in stores) {
    testWidgets('screenshots for ${store.code}', (tester) async {
      tester.view
        ..physicalSize = _canvas
        ..devicePixelRatio = _ratio;
      addTearDown(tester.view.reset);
      // Tests draw an outline in place of every shadow; a screenshot wants
      // the real thing.
      final shadows = debugDisableShadows;
      debugDisableShadows = false;
      // Downloads outlives the app, which the test runner uninstalls.
      final dir = Directory('/sdcard/Download/store-screenshots/${store.code}')
        ..createSync(recursive: true);

      final rtl = rightToLeftLanguages.contains(store.app);
      final locale = Locale(store.app);

      for (final (i, shot) in _shots.indexed) {
        final (provider, settings) = await _state(tester, store);
        await _save(
          tester,
          '${dir.path}/${shot.name}.png',
          _frame(
            caption: _captions[store.code]![i],
            rtl: rtl,
            dark: shot.dark,
            locale: locale,
            app: _app(provider, settings, shot),
          ),
          ratio: _ratio,
          before: shot.name == '2-add' ? _typeAmount : null,
        );
      }

      // The feature graphic, drawn at half size and saved at 1024×500.
      tester.view
        ..physicalSize = _featureSize * 2
        ..devicePixelRatio = 2;
      final (provider, settings) = await _state(tester, store);
      await _save(
        tester,
        '${dir.path}/feature-graphic.png',
        _feature(
          title: _titles[store.code]!,
          tagline: _captions[store.code]!.last,
          rtl: rtl,
          locale: locale,
          app: _app(provider, settings, _shots.first),
        ),
        ratio: 2,
      );

      // The store icon is the same in every language.
      if (store.code == 'en-US') {
        tester.view
          ..physicalSize = const Size.square(512)
          ..devicePixelRatio = 1;
        await _save(
          tester,
          '/sdcard/Download/store-screenshots/icon-512.png',
          const CustomPaint(
            painter: AppIconPainter(scale: 1, background: true),
            size: Size.square(512),
          ),
          ratio: 1,
        );
      }
      debugDisableShadows = shadows;
    });
  }
}

/// A fresh copy of the sample data, in [store]'s language and currency.
Future<(TransactionProvider, SettingsProvider)> _state(
  WidgetTester tester,
  _Store store,
) async {
  final provider = TransactionProvider(
    db: FakeDB(
      transactions: _transactions(store),
      categories: _categories(),
      rules: _rules(store),
      accounts: [
        Account(
          id: Account.cashId,
          type: AccountType.cash,
          defaultKey: 'cash',
          openingBalance: _money(1250, store),
          openingDate: DateTime(2026, 4, 1),
          sortOrder: 0,
          createdAt: _created,
          updatedAt: _created,
        ),
      ],
      budgets: _budgets(store),
    ),
    clock: () => _today,
  );
  await tester.runAsync(provider.load);
  final settings = await testSettings({
    'language': store.app,
    'currency_code': store.currency,
    'setup_done': true,
    'walkthrough_seen': true,
    'backup_reminder': false,
    // The offer is a first-run notice, not something to photograph over the
    // hero shot (NUDGE-3).
    'empty_day_nudge_offered': true,
  }, () => _today);
  return (provider, settings);
}

/// Shows [picture], lets it settle (running [before] first, if given), and
/// writes it to [path] as a PNG at [ratio] pixels per logical pixel.
Future<void> _save(
  WidgetTester tester,
  String path,
  Widget picture, {
  required double ratio,
  Future<void> Function(WidgetTester tester)? before,
}) async {
  final boundary = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: boundary, child: picture));
  for (var f = 0; f < 6; f++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  if (before != null) await before(tester);
  await tester.runAsync(() async {
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await render.toImage(pixelRatio: ratio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(png!.buffer.asUint8List());
  });
  await tester.pumpWidget(const SizedBox());
}

/// Types 45+12 on the keypad and picks Groceries, as a user would.
Future<void> _typeAmount(WidgetTester tester) async {
  for (final key in ['4', '5', '+', '1', '2']) {
    final finder = find.text(key);
    if (finder.evaluate().isEmpty) continue;
    await tester.tap(finder.last);
    await tester.pump(const Duration(milliseconds: 100));
  }
  final groceries = find.textContaining('🛒');
  if (groceries.evaluate().isNotEmpty) {
    await tester.tap(groceries.first);
  }
  // Put the keypad away before the picture is taken: half the form is
  // behind it, and the shot is meant to show the form, not the keys.
  final hide = find.byIcon(Icons.keyboard_hide_outlined);
  if (hide.evaluate().isNotEmpty) {
    await tester.tap(hide.first);
  }
  for (var f = 0; f < 6; f++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}
