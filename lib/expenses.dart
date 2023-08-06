class Expenses {
  String id;
  String category;
  String name;
  int price;
  DateTime date;
  String notes;
  List<ExpenseRecord> history;

  Expenses({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    required this.date,
    required this.notes,
    List<ExpenseRecord>? history,
  }) : history = history ?? [];
}

class ExpenseCategory {
  final String name;
  final double percentage;

  ExpenseCategory({required this.name, required this.percentage});
}

class ExpenseRecord {
  final DateTime date;
  final int price;
  final String expenseId;

  ExpenseRecord({
    required this.date,
    required this.price,
    required this.expenseId,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'price': price,
      'expenseId': expenseId,
    };
  }

  factory ExpenseRecord.fromMap(Map<String, dynamic> map) {
    return ExpenseRecord(
      date: map['date'].toDate(),
      price: map['price'],
      expenseId: map['expenseId'],
    );
  }

}
