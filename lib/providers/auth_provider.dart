import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/fido_auth_service.dart';
import '../services/banking_service.dart';

/// 認証状態を管理するProvider
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  final FidoAuthService _fidoService = FidoAuthService();
  final BankingService _bankingService = BankingService();

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// アプリ起動時に認証状態を復元
  Future<void> restoreAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (userId != null && isLoggedIn) {
        // ユーザー情報を取得
        _user = await _bankingService.getUserInfo(userId);
        _isAuthenticated = true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Auth restore error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// パスキーで登録
  Future<bool> registerWithPasskey({
    required String userId,
    required String userName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 生体認証の可用性チェック
      final isBiometricAvailable = await _fidoService.isBiometricAvailable();
      if (!isBiometricAvailable) {
        _errorMessage = 'このデバイスは生体認証に対応していません';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // FIDO登録
      final result = await _fidoService.registerPasskey(
        userId: userId,
        userName: userName,
      );

      if (result.success) {
        // ユーザー情報を取得
        _user = await _bankingService.updateFidoRegistration(userId, true);
        _isAuthenticated = true;

        // 認証状態を保存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        await prefs.setBool('isLoggedIn', true);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage ?? '登録に失敗しました';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '予期しないエラーが発生しました';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Registration error: $e');
      }
      return false;
    }
  }

  /// パスキーで認証
  Future<bool> authenticateWithPasskey(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // FIDO認証
      final result = await _fidoService.authenticateWithPasskey(userId: userId);

      if (result.success) {
        // ユーザー情報を取得
        _user = await _bankingService.getUserInfo(userId);
        _isAuthenticated = true;

        // 認証状態を保存
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        await prefs.setBool('isLoggedIn', true);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage ?? '認証に失敗しました';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '予期しないエラーが発生しました';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Authentication error: $e');
      }
      return false;
    }
  }

  /// ログアウト
  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.setBool('isLoggedIn', false);

    notifyListeners();
  }

  /// エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
