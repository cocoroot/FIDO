import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_biometric_service.dart';
import '../../services/fido_management_service.dart';
import '../home_screen.dart';
import 'passcode_input_screen.dart';

/// 起動時生体認証画面（従来の顔認証・指紋認証）
/// 
/// アプリ起動時に表示される認証画面
/// - ローカル生体認証（顔認証 / 指紋認証）で認証
/// - FIDO認証設定済みの場合は、生体認証成功後にFIDO認証も実行
/// - パスコード入力へ切り替え可能
class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalBiometricService _biometricService = LocalBiometricService();
  final FidoManagementService _fidoManagement = FidoManagementService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // 画面表示後に自動でローカル生体認証を開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleBiometricAuth();
    });
  }

  Future<void> _handleBiometricAuth() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    // ステップ1: ローカル生体認証を実行
    final biometricResult = await _biometricService.authenticate();

    if (mounted) {
      if (biometricResult.success) {
        // 生体認証成功 → FIDO認証設定チェック
        final isFidoEnabled = await _fidoManagement.isFidoEnabled();
        
        if (isFidoEnabled) {
          // FIDO認証が設定済み → FIDO認証も実行
          await _executeFidoAuth();
        } else {
          // FIDO認証未設定 → そのままログイン
          await _completeLogin();
        }
      } else {
        // 認証失敗 → エラーメッセージ表示
        setState(() => _isAuthenticating = false);
        _showErrorMessage(biometricResult.errorMessage ?? '認証に失敗しました');
      }
    }
  }

  Future<void> _executeFidoAuth() async {
    if (!mounted) return;

    // FIDO認証を実行
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fidoSuccess = await authProvider.authenticateWithPasskey('user_001');

    if (mounted) {
      if (fidoSuccess) {
        // FIDO認証成功 → ホーム画面へ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // FIDO認証失敗
        setState(() => _isAuthenticating = false);
        _showErrorMessage('FIDO認証に失敗しました');
      }
    }
  }

  Future<void> _completeLogin() async {
    // ログイン状態を保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', 'user_001'); // モックユーザーID
    await prefs.setBool('isLoggedIn', true);
    
    // AuthProviderの状態を更新
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.restoreAuthState();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
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
                
                // 指紋アイコン
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint,
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
                        '認証中...',
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
                        '生体認証でログイン',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Touch IDまたはFace IDで認証してください',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // 再試行ボタン
                      ElevatedButton(
                        onPressed: _handleBiometricAuth,
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
                          '認証する',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 40),
                
                // パスコードに切り替え
                TextButton(
                  onPressed: _switchToPasscode,
                  child: const Text(
                    'パスコードで認証',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
