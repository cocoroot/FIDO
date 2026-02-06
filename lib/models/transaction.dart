class Transaction {
  final String id;
  final DateTime date;
  final String type; // 'deposit', 'withdrawal', 'transfer'
  final double amount;
  final String description;
  final double balanceAfter;

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.description,
    required this.balanceAfter,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'amount': amount,
      'description': description,
      'balanceAfter': balanceAfter,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
    );
  }

  String get formattedAmount {
    final sign = type == 'deposit' ? '+' : '-';
    return '$sign¥${amount.toStringAsFixed(0)}';
  }

  String get typeLabel {
    switch (type) {
      case 'deposit':
        return '入金';
      case 'withdrawal':
        return '出金';
      case 'transfer':
        return '振込';
      default:
        return type;
    }
  }
}
