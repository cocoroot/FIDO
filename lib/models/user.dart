class User {
  final String id;
  final String name;
  final String accountNumber;
  final double balance;
  final bool fidoRegistered;

  User({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.balance,
    this.fidoRegistered = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? accountNumber,
    double? balance,
    bool? fidoRegistered,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      fidoRegistered: fidoRegistered ?? this.fidoRegistered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'accountNumber': accountNumber,
      'balance': balance,
      'fidoRegistered': fidoRegistered,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      accountNumber: json['accountNumber'] as String,
      balance: (json['balance'] as num).toDouble(),
      fidoRegistered: json['fidoRegistered'] as bool? ?? false,
    );
  }
}
