import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/account.dart';
import 'settings/settings_screen.dart';

/// ホーム画面（実際の肥後銀行アプリに準拠）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showBalance = true;
  int _selectedIndex = 0;

  // モック口座データ
  final Account _account = Account(
    id: 'acc_001',
    branch: '東京支店',
    accountType: '普通',
    accountNumber: '1234567',
    accountHolder: 'ヤノ　タカシ',
    balance: 10011,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // トップバー
              _buildTopBar(),
              
              // コンテンツエリア
              Expanded(
                child: _selectedIndex == 0
                    ? _buildHomeContent()
                    : _buildOtherContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // トップバー
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 肥後銀行ロゴ
          Row(
            children: [
              Image.asset(
                'assets/icon/app_icon.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.bankTagline,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    AppStrings.bankName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // 右側アイコン
          Row(
            children: [
              // 現在時刻
              Text(
                _getCurrentTime(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              // リフレッシュアイコン
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.dataRefreshed)),
                  );
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
              // 通知アイコン
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.notificationDemo)),
                  );
                },
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 設定アイコン
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ホームコンテンツ
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // 口座カード
          _buildAccountCard(),
          const SizedBox(height: 16),
          // 口座を追加ボタン
          _buildAddAccountButton(),
          const SizedBox(height: 24),
          // サービスグリッド
          _buildServiceGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 口座カード
  Widget _buildAccountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カードヘッダー（支店名・口座番号・残高表示トグル）
          Row(
            children: [
              // カラーアイコン
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _account.branch,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_account.accountType}　${_account.accountNumber}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _account.accountHolder,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 残高表示トグル
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    AppStrings.balanceDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Switch(
                    value: _showBalance,
                    onChanged: (value) {
                      setState(() => _showBalance = value);
                    },
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 残高表示
          Center(
            child: Text(
              _showBalance
                  ? '${_account.formattedBalance}円'
                  : '******円',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // アクションボタン
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.statementDemo)),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text(AppStrings.statement),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.transferDemo)),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text(AppStrings.transfer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 口座を追加ボタン
  Widget _buildAddAccountButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.addAccountDemo)),
          );
        },
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(AppStrings.addAccount),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.divider),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  // サービスグリッド
  Widget _buildServiceGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 1行目
          Row(
            children: [
              _buildServiceItem(Icons.computer, AppStrings.internetBanking),
              _buildServiceItem(Icons.insights, AppStrings.investmentTrust),
              _buildServiceItem(Icons.attach_money, AppStrings.foreignDeposit),
              _buildServiceItem(Icons.trending_up, AppStrings.kyushuFgSecurities),
            ],
          ),
          const SizedBox(height: 16),
          // 2行目
          Row(
            children: [
              _buildServiceItem(Icons.sync_alt, AppStrings.kotoraTransfer),
              _buildServiceItem(Icons.payment, AppStrings.loanApplication),
              _buildServiceItem(Icons.credit_card, AppStrings.cardApplication),
              _buildServiceItem(Icons.currency_yen, AppStrings.feeList),
            ],
          ),
          const SizedBox(height: 16),
          // 3行目
          Row(
            children: [
              _buildServiceItem(Icons.password, AppStrings.oneTimePassword),
              _buildServiceItem(Icons.store, AppStrings.branchAtmSearch),
              _buildServiceItem(Icons.headset_mic, AppStrings.contactUs),
              _buildServiceItem(Icons.grid_view, AppStrings.viewAll),
            ],
          ),
        ],
      ),
    );
  }

  // サービスアイテム
  Widget _buildServiceItem(IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label（デモ）')),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // その他のコンテンツ
  Widget _buildOtherContent() {
    return Center(
      child: Text(
        [AppStrings.home, AppStrings.registeredAccounts, AppStrings.services][_selectedIndex],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ボトムナビゲーション
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: AppStrings.registeredAccounts,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: AppStrings.services,
        ),
      ],
    );
  }

  // 現在時刻を取得
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}現在';
  }
}
