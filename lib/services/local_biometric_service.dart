import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ローカル生体認証サービス（従来の顔認証・指紋認証）
/// 
/// FIDO認証とは別の、従来のデバイス生体認証を管理します。
/// - 顔認証（Face ID / Face Recognition）
/// - 指紋認証（Touch ID / Fingerprint）
/// 
/// これはKeypasco SDKとは無関係のローカル認証方式です。
class LocalBiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  /// ローカル生体認証が有効化されているか確認
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? true; // デフォルトtrue
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biometric enabled check error: $e');
      }
      return true;
    }
  }

  /// ローカル生体認証を有効化/無効化
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Set biometric enabled error: $e');
      }
      return false;
    }
  }

  /// ローカル生体認証を実行（モック実装）
  /// 
  /// 【実装時の注意】
  /// 本番環境では local_auth パッケージを使用して実際の生体認証を実行します。
  /// 現在はモック実装で常に成功を返します。
  Future<BiometricAuthResult> authenticate() async {
    try {
      // 🔌 将来の実装ポイント
      // import 'package:local_auth/local_auth.dart';
      // final LocalAuthentication auth = LocalAuthentication();
      // 
      // final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      // final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      // 
      // if (!canAuthenticate) {
      //   return BiometricAuthResult(success: false, errorMessage: 'このデバイスは生体認証に対応していません');
      // }
      // 
      // try {
      //   final bool didAuthenticate = await auth.authenticate(
      //     localizedReason: '肥後銀行アプリにログインするために生体認証を行ってください',
      //     options: const AuthenticationOptions(
      //       stickyAuth: true,
      //       biometricOnly: true,
      //     ),
      //   );
      //   
      //   return BiometricAuthResult(success: didAuthenticate);
      // } on PlatformException catch (e) {
      //   return BiometricAuthResult(
      //     success: false,
      //     errorMessage: e.message ?? '生体認証に失敗しました',
      //   );
      // }
      
      // 現在はモック実装（技術検証用）
      await Future.delayed(const Duration(seconds: 2));
      
      // モック: 80%の確率で成功
      final random = DateTime.now().millisecondsSinceEpoch % 10;
      if (random < 8) {
        return BiometricAuthResult(success: true);
      } else {
        return BiometricAuthResult(
          success: false,
          errorMessage: '生体認証に失敗しました。もう一度お試しください。',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Local biometric authentication error: $e');
      }
      return BiometricAuthResult(
        success: false,
        errorMessage: '予期しないエラーが発生しました',
      );
    }
  }

  /// デバイスが生体認証に対応しているか確認
  Future<bool> isDeviceSupported() async {
    try {
      // 🔌 将来の実装ポイント
      // final LocalAuthentication auth = LocalAuthentication();
      // final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      // final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      // return canAuthenticate;
      
      // 現在はモック実装（技術検証用）
      await Future.delayed(const Duration(milliseconds: 300));
      return true; // 検証用にtrueを返す
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Device support check error: $e');
      }
      return false;
    }
  }
}

/// ローカル生体認証結果
class BiometricAuthResult {
  final bool success;
  final String? errorMessage;

  BiometricAuthResult({
    required this.success,
    this.errorMessage,
  });
}
