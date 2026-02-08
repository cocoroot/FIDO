import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'services/passcode_service.dart';
import 'services/fido_management_service.dart';
import 'screens/auth/biometric_auth_screen.dart';
import 'screens/auth/fido_auth_screen.dart';
import 'screens/auth/passcode_input_screen.dart';
import 'screens/auth/passcode_setup_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: '肥後銀行 バンキングアプリ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

/// スプラッシュ画面（認証フロー振り分け）
/// 
/// 認証方式の優先順位:
/// 1. パスコード未設定 → パスコード設定画面
/// 2. FIDO認証有効 → FIDO認証画面（Keypasco SDK使用）
/// 3. 従来の生体認証有効 → 生体認証画面（顔認証）
/// 4. どちらも無効 → パスコード入力画面
/// 5. 既にログイン済み → ホーム画面
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // スプラッシュ表示（最低1秒）
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final passcodeService = PasscodeService();
    final fidoManagement = FidoManagementService();

    // 認証状態を復元
    await authProvider.restoreAuthState();

    // パスコード設定チェック
    final isPasscodeSet = await passcodeService.isPasscodeSet();

    if (!mounted) return;

    Widget nextScreen;

    if (!isPasscodeSet) {
      // パスコード未設定 → 設定画面へ
      nextScreen = const PasscodeSetupScreen();
    } else if (authProvider.isAuthenticated) {
      // 既にログイン済み → ホーム画面へ
      nextScreen = const HomeScreen();
    } else {
      // 🔐 認証方式の優先順位を決定
      // 1. FIDO認証が有効な場合 → FIDO認証画面
      // 2. 従来の生体認証が有効な場合 → 生体認証画面
      // 3. どちらも無効な場合 → パスコード入力画面
      
      final isFidoEnabled = await fidoManagement.isFidoEnabled();
      
      if (isFidoEnabled) {
        // FIDO認証優先
        nextScreen = const FidoAuthScreen();
      } else {
        // 従来の生体認証をチェック
        final prefs = await SharedPreferences.getInstance();
        final isBiometricEnabled = prefs.getBool('biometric_enabled') ?? true;

        if (isBiometricEnabled) {
          // 従来の生体認証（顔認証）
          nextScreen = const BiometricAuthScreen();
        } else {
          // パスコード入力
          nextScreen = const PasscodeInputScreen();
        }
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 肥後銀行ロゴ
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
