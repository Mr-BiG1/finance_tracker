class Expense {
  String id;
  String category;
  double amount;
  DateTime date;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "category": category,
      "amount": amount,
      "date": date.toIso8601String(),
    };
  }
}
