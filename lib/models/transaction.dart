enum TransactionType { income, expense }

/// A single income or expense entry.
class ExpenseTransaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? note;

  ExpenseTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.name,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: (map['type'] as String) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  ExpenseTransaction copyWith({
    String? title,
    double? amount,
    String? category,
    TransactionType? type,
    DateTime? date,
    String? note,
  }) {
    return ExpenseTransaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

/// Predefined categories, similar to typical expense-tracker apps.
class Categories {
  static const List<String> expense = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Rent',
    'Groceries',
    'Other',
  ];

  static const List<String> income = [
    'Salary',
    'Business',
    'Gift',
    'Investment',
    'Freelance',
    'Other',
  ];

  static const Map<String, String> icons = {
    'Food': '🍔',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Bills': '💡',
    'Entertainment': '🎬',
    'Health': '💊',
    'Education': '📚',
    'Rent': '🏠',
    'Groceries': '🛒',
    'Salary': '💼',
    'Business': '🏢',
    'Gift': '🎁',
    'Investment': '📈',
    'Freelance': '💻',
    'Other': '📦',
  };
}
