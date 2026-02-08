import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FIDO認証管理サービス
/// 
/// FIDO認証の有効化状態と設定を管理します。
/// 従来の生体認証（顔認証）とは別の認証方式として扱います。
class FidoManagementService {
  static const String _fidoEnabledKey = 'fido_authentication_enabled';
  static const String _fidoRegisteredKey = 'fido_credential_registered';
  static const String _fidoCredentialIdKey = 'fido_credential_id';
  
  /// FIDO認証が有効化されているか確認
  Future<bool> isFidoEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_fidoEnabledKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FIDO enabled check error: $e');
      }
      return false;
    }
  }

  /// FIDO認証を有効化/無効化
  Future<bool> setFidoEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_fidoEnabledKey, enabled);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Set FIDO enabled error: $e');
      }
      return false;
    }
  }

  /// FIDO認証情報が登録されているか確認
  Future<bool> isFidoRegistered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_fidoRegisteredKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FIDO registered check error: $e');
      }
      return false;
    }
  }

  /// FIDO認証情報を登録
  Future<bool> registerFidoCredential(String credentialId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fidoCredentialIdKey, credentialId);
      await prefs.setBool(_fidoRegisteredKey, true);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Register FIDO credential error: $e');
      }
      return false;
    }
  }

  /// FIDO認証情報をクリア（解除）
  Future<bool> clearFidoCredential() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fidoCredentialIdKey);
      await prefs.setBool(_fidoRegisteredKey, false);
      await prefs.setBool(_fidoEnabledKey, false);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Clear FIDO credential error: $e');
      }
      return false;
    }
  }

  /// 保存されているFIDO認証情報ID取得
  Future<String?> getCredentialId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fidoCredentialIdKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Get credential ID error: $e');
      }
      return null;
    }
  }
}
