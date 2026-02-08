import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/account.dart';
import 'settings/settings_screen.dart';

/// ホーム画面（実際の肥後銀行アプリ準拠）
/// 
/// - グラデーション背景
/// - 口座カード表示
/// - 8x2グリッドサービスメニュー
/// - ボトムナビゲーション
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Account? _account;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // モック口座データを取得
    await Future.delayed(const Duration(milliseconds: 500));
    _account = Account(
      id: 'account_001',
      branch: '東京支店',
      accountNumber: '1152114',
      accountType: '普通',
      accountHolder: 'ヤノ　タカシ',
      balance: 10011,
      isDisplayed: true,
    );
    
    setState(() => _isLoading = false);
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    
    if (index == 2) {
      // サービスメニュー → 設定画面へ
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    }
  }

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
              // ヘッダー
              _buildHeader(),
              
              // メインコンテンツ
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            
                            // 口座カード
                            if (_account != null) _buildAccountCard(_account!),
                            
                            const SizedBox(height: 24),
                            
                            // 口座を追加ボタン
                            _buildAddAccountButton(),
                            
                            const SizedBox(height: 32),
                            
                            // サービスメニューグリッド
                            _buildServiceGrid(),
                            
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // ロゴ
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '肥後銀行',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          
          // 現在時刻
          const Text(
            '09:17現在',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          
          // 更新アイコン
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
          
          // 通知アイコン
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          
          // 設定アイコン
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Account account) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カラーバー
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 支店・口座情報
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.branch,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${account.accountType}　${account.formattedAccountNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.accountHolder,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 残高表示トグル
              Text(
                '残高表示',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: account.isDisplayed,
                onChanged: (value) {
                  setState(() {
                    _account = account.copyWith(isDisplayed: value);
                  });
                },
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 残高
          if (account.isDisplayed)
            Text(
              '${account.formattedBalance}円',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            )
          else
            const Text(
              '＊＊＊＊＊円',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          
          const SizedBox(height: 20),
          
          // アクションボタン
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.article_outlined, size: 20),
                  label: const Text('明細'),
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
                  onPressed: () {},
                  icon: const Icon(Icons.sync_alt, size: 20),
                  label: const Text('振込・振替'),
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

  Widget _buildAddAccountButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('口座を追加'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white70),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    final services = [
      _ServiceItem(Icons.laptop_mac, 'インターネット\nバンキング'),
      _ServiceItem(Icons.trending_up, '投資信託'),
      _ServiceItem(Icons.currency_exchange, '外貨預金'),
      _ServiceItem(Icons.show_chart, '九州FG証券オン\nライントレード'),
      _ServiceItem(Icons.account_balance, 'ことら送金'),
      _ServiceItem(Icons.credit_card, 'ローン申込'),
      _ServiceItem(Icons.payment, 'クレジット/\nデビット申込'),
      _ServiceItem(Icons.receipt_long, '手数料一覧'),
      _ServiceItem(Icons.lock_outline, 'ワンタイム\nパスワード'),
      _ServiceItem(Icons.store, '店舗・ATM検索'),
      _ServiceItem(Icons.support_agent, 'お問い合わせ'),
      _ServiceItem(Icons.grid_view, 'すべて見る'),
    ];

    return Container(
      color: Colors.white.withValues(alpha: 0.15),
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceItem(service);
        },
      ),
    );
  }

  Widget _buildServiceItem(_ServiceItem service) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${service.label}（デモ）')),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            service.icon,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            service.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.credit_card),
          label: '登録口座',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps),
          label: 'サービス',
        ),
      ],
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;

  _ServiceItem(this.icon, this.label);
}
