import 'money.dart';
import 'transaction.dart';

/// What to look for: text plus filters that combine with AND (SRCH-1,
/// SRCH-2). Null filters match everything; without a date range the search
/// covers all time.
class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.categoryId,
    this.accountId,
    this.from,
    this.to,
  });

  final String query;
  final TransactionType? type;
  final String? categoryId;
  final String? accountId;

  /// Inclusive local dates.
  final DateTime? from;
  final DateTime? to;
}

/// The matching transactions, newest first, with totals (SRCH-3).
class SearchResult {
  const SearchResult(this.transactions, this.income, this.expense);

  final List<ExpenseTransaction> transactions;

  /// Totals of the matches that already count; upcoming ones don't (BAL-4).
  final Money income;
  final Money expense;
}

const _plainLetters = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a', //
  'æ': 'ae', 'ç': 'c', 'ć': 'c', 'č': 'c', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ę': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'ł': 'l', //
  'ñ': 'n', 'ń': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
  'ø': 'o', 'ō': 'o', 'œ': 'oe', 'ś': 's', 'š': 's', 'ß': 'ss', //
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ý': 'y', 'ÿ': 'y', //
  'ź': 'z', 'ż': 'z', 'ž': 'z', //
  // Turkish: dotless ı folds with i, like İ below (LANG-4).
  'ğ': 'g', 'ı': 'i', 'ş': 's', //
  // Arabic: alef with hamza or madda, and alef maqsura.
  'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا', 'ى': 'ي',
};

/// Nonspacing marks: combining accents, the dot that lowercasing `İ` leaves,
/// and Arabic vowel marks.
final _marks = RegExp(r'\p{Mn}', unicode: true);

/// The Arabic tatweel, which only stretches a word.
final _tatweel = String.fromCharCode(0x0640);

/// Lowercases [text] and strips accents, so "Café" matches "cafe",
/// "İstanbul" matches "istanbul", and Arabic matches with or without vowel
/// marks (SRCH-1, LANG-4).
String foldForSearch(String text) {
  final buffer = StringBuffer();
  for (final char
      in text
          .toLowerCase()
          .replaceAll(_marks, '')
          .replaceAll(_tatweel, '')
          .split('')) {
    buffer.write(_plainLetters[char] ?? char);
  }
  return buffer.toString();
}
