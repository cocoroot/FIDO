class Account {
  final String id;
  final String branch;        // 支店名（例：東京支店）
  final String accountNumber; // 口座番号
  final String accountType;   // 口座種別（普通、当座など）
  final String accountHolder; // 口座名義（カタカナ）
  final double balance;       // 残高
  final bool isDisplayed;     // 残高表示ON/OFF

  Account({
    required this.id,
    required this.branch,
    required this.accountNumber,
    required this.accountType,
    required this.accountHolder,
    required this.balance,
    this.isDisplayed = true,
  });

  Account copyWith({
    String? id,
    String? branch,
    String? accountNumber,
    String? accountType,
    String? accountHolder,
    double? balance,
    bool? isDisplayed,
  }) {
    return Account(
      id: id ?? this.id,
      branch: branch ?? this.branch,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      accountHolder: accountHolder ?? this.accountHolder,
      balance: balance ?? this.balance,
      isDisplayed: isDisplayed ?? this.isDisplayed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch': branch,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'accountHolder': accountHolder,
      'balance': balance,
      'isDisplayed': isDisplayed,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      branch: json['branch'] as String,
      accountNumber: json['accountNumber'] as String,
      accountType: json['accountType'] as String,
      accountHolder: json['accountHolder'] as String,
      balance: (json['balance'] as num).toDouble(),
      isDisplayed: json['isDisplayed'] as bool? ?? true,
    );
  }

  // 口座番号フォーマット（7桁を見やすく）
  String get formattedAccountNumber {
    if (accountNumber.length == 7) {
      return accountNumber.substring(0, 3) + '-' + accountNumber.substring(3);
    }
    return accountNumber;
  }

  // 残高フォーマット
  String get formattedBalance {
    return balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
