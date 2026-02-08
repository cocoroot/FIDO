import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';

/// 生体認証設定画面（実際の肥後銀行アプリ準拠）
/// 
/// - シンプルなトグルスイッチで生体認証ON/OFF
/// - 説明テキスト表示
class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  bool _isBiometricEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() => _isBiometricEnabled = value);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? '生体認証を有効にしました' : '生体認証を無効にしました'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('生体認証の変更'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 説明テキスト
                  const Text(
                    '生体認証を利用すると、パスコード入力をせずに、アプリを利用できます。',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 生体認証トグル
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '生体認証',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: _isBiometricEnabled,
                        onChanged: _toggleBiometric,
                        activeTrackColor: AppColors.primary,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 補足説明
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, 
                              size: 20, 
                              color: AppColors.iconSecondary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '生体認証について',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• 生体情報はデバイス内に安全に保存されます\n'
                          '• サーバーに生体情報が送信されることはありません\n'
                          '• FIDO2標準に準拠した高いセキュリティ\n'
                          '• Touch IDまたはFace IDが利用できます',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
