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
  'ź': 'z', 'ż': 'z', 'ž': 'z',
};

/// Lowercases [text] and strips common accents, so "Café" matches "cafe"
/// (SRCH-1).
String foldForSearch(String text) {
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split('')) {
    buffer.write(_plainLetters[char] ?? char);
  }
  return buffer.toString();
}
