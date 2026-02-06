import '../models/user.dart';
import '../models/transaction.dart';

/// バンキングサービス（モック実装）
/// 
/// 技術検証用のモックデータを提供します。
/// 本番環境では実際のAPIエンドポイントに接続します。
class BankingService {
  /// モックユーザーデータ
  static User getMockUser() {
    return User(
      id: 'user_001',
      name: '田中 太郎',
      accountNumber: '1234567',
      balance: 1250000,
      fidoRegistered: false,
    );
  }

  /// モック取引履歴データ
  static List<Transaction> getMockTransactions() {
    final now = DateTime.now();
    
    return [
      Transaction(
        id: 'tx_001',
        date: now.subtract(const Duration(days: 1)),
        type: 'deposit',
        amount: 50000,
        description: '給与振込',
        balanceAfter: 1250000,
      ),
      Transaction(
        id: 'tx_002',
        date: now.subtract(const Duration(days: 3)),
        type: 'withdrawal',
        amount: 20000,
        description: 'ATM出金',
        balanceAfter: 1200000,
      ),
      Transaction(
        id: 'tx_003',
        date: now.subtract(const Duration(days: 5)),
        type: 'transfer',
        amount: 15000,
        description: '振込 - 山田花子様',
        balanceAfter: 1220000,
      ),
      Transaction(
        id: 'tx_004',
        date: now.subtract(const Duration(days: 7)),
        type: 'withdrawal',
        amount: 30000,
        description: 'クレジットカード引落',
        balanceAfter: 1235000,
      ),
      Transaction(
        id: 'tx_005',
        date: now.subtract(const Duration(days: 10)),
        type: 'deposit',
        amount: 100000,
        description: '定期預金解約',
        balanceAfter: 1265000,
      ),
      Transaction(
        id: 'tx_006',
        date: now.subtract(const Duration(days: 12)),
        type: 'withdrawal',
        amount: 5000,
        description: 'コンビニATM出金',
        balanceAfter: 1165000,
      ),
      Transaction(
        id: 'tx_007',
        date: now.subtract(const Duration(days: 15)),
        type: 'transfer',
        amount: 25000,
        description: '振込 - 佐藤商事株式会社',
        balanceAfter: 1170000,
      ),
      Transaction(
        id: 'tx_008',
        date: now.subtract(const Duration(days: 18)),
        type: 'deposit',
        amount: 80000,
        description: 'ボーナス振込',
        balanceAfter: 1195000,
      ),
    ];
  }

  /// 残高照会
  Future<double> getBalance(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getMockUser().balance;
  }

  /// 取引履歴取得
  Future<List<Transaction>> getTransactions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return getMockTransactions();
  }

  /// 振込実行（モック）
  Future<bool> executeTransfer({
    required String fromAccountNumber,
    required String toAccountNumber,
    required double amount,
    required String description,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    // モック実装では常に成功
    return true;
  }

  /// ユーザー情報取得
  Future<User> getUserInfo(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getMockUser();
  }

  /// FIDO登録状態を更新
  Future<User> updateFidoRegistration(String userId, bool registered) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = getMockUser();
    return user.copyWith(fidoRegistered: registered);
  }
}
