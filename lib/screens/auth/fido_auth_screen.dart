import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';
import 'biometric_auth_screen.dart';
import 'passcode_input_screen.dart';

/// 起動時FIDO認証画面
/// 
/// FIDO認証が有効化されている場合に表示される認証画面
/// - FIDO認証（Keypasco SDK）で認証
/// - 従来の生体認証またはパスコードへフォールバック可能
class FidoAuthScreen extends StatefulWidget {
  const FidoAuthScreen({super.key});

  @override
  State<FidoAuthScreen> createState() => _FidoAuthScreenState();
}

class _FidoAuthScreenState extends State<FidoAuthScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // 画面表示後に自動でFIDO認証を開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFidoAuth();
    });
  }

  Future<void> _handleFidoAuth() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // FIDO認証を実行（Keypasco SDK呼び出し）
    final success = await authProvider.authenticateWithPasskey('user_001');

    if (mounted) {
      if (success) {
        // 認証成功 → ホーム画面へ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // 認証失敗 → エラーメッセージ表示
        setState(() => _isAuthenticating = false);
        _showErrorMessage(authProvider.errorMessage ?? 'FIDO認証に失敗しました');
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _switchToBiometric() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BiometricAuthScreen()),
    );
  }

  void _switchToPasscode() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PasscodeInputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 肥後銀行ロゴ
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // タイトル
                const Text(
                  '肥後銀行',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'こころをかたちにするぞという\n銀行',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 80),
                
                // FIDO認証アイコン
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // メッセージ
                if (_isAuthenticating)
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'FIDO認証中...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      const Text(
                        'FIDO認証でログイン',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keypasco技術によるセキュアな認証',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // 再試行ボタン
                      ElevatedButton(
                        onPressed: _handleFidoAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'FIDO認証する',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 40),
                
                // フォールバックオプション
                Column(
                  children: [
                    TextButton(
                      onPressed: _switchToBiometric,
                      child: const Text(
                        '従来の生体認証で認証',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _switchToPasscode,
                      child: const Text(
                        'パスコードで認証',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
