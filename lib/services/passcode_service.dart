import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 4桁パスコード管理サービス
/// 
/// 実際のアプリと同様の4桁数字パスコードを管理します。
/// - パスコードの設定・変更
/// - パスコード検証
/// - パスコードの暗号化保存
class PasscodeService {
  static const String _passcodeKey = 'app_passcode_hash';
  static const String _passcodeSetKey = 'passcode_is_set';
  
  /// パスコードが設定されているか確認
  Future<bool> isPasscodeSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_passcodeSetKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Passcode check error: $e');
      }
      return false;
    }
  }

  /// パスコードを設定
  Future<bool> setPasscode(String passcode) async {
    try {
      // 4桁の数字チェック
      if (!_isValidPasscode(passcode)) {
        return false;
      }

      // パスコードをハッシュ化して保存
      final hashedPasscode = _hashPasscode(passcode);
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_passcodeKey, hashedPasscode);
      await prefs.setBool(_passcodeSetKey, true);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Set passcode error: $e');
      }
      return false;
    }
  }

  /// パスコードを検証
  Future<bool> verifyPasscode(String passcode) async {
    try {
      if (!_isValidPasscode(passcode)) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_passcodeKey);
      
      if (storedHash == null) {
        return false;
      }

      final inputHash = _hashPasscode(passcode);
      return inputHash == storedHash;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Verify passcode error: $e');
      }
      return false;
    }
  }

  /// パスコードを削除
  Future<bool> clearPasscode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_passcodeKey);
      await prefs.setBool(_passcodeSetKey, false);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Clear passcode error: $e');
      }
      return false;
    }
  }

  /// パスコードが4桁の数字か検証
  bool _isValidPasscode(String passcode) {
    if (passcode.length != 4) {
      return false;
    }
    return RegExp(r'^\d{4}$').hasMatch(passcode);
  }

  /// パスコードをSHA256でハッシュ化
  String _hashPasscode(String passcode) {
    final bytes = utf8.encode(passcode);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}
