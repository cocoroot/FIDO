import 'package:flutter/material.dart';

/// 肥後銀行アプリのカラーテーマ定義
/// 実際のアプリのスクリーンショットから抽出
class AppColors {
  // プライマリカラー（ティール）
  static const Color primary = Color(0xFF00ACC1);
  static const Color primaryDark = Color(0xFF00838F);
  
  // グラデーション背景色
  static const Color gradientStart = Color(0xFF00ACC1); // ティール
  static const Color gradientEnd = Color(0xFF66BB6A);   // グリーン
  
  // カードカラー
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);
  
  // テキストカラー
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  
  // 背景カラー
  static const Color background = Color(0xFFF5F5F5);
  
  // ボタンカラー
  static const Color buttonPrimary = Color(0xFF00838F);
  static const Color buttonSecondary = Color(0xFFB2EBF2);
  
  // アイコンカラー
  static const Color iconPrimary = Color(0xFF00838F);
  static const Color iconSecondary = Color(0xFF757575);
  
  // 区切り線
  static const Color divider = Color(0xFFE0E0E0);
  
  // ステータスカラー
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  
  // グラデーション生成
  static LinearGradient get primaryGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [gradientStart, gradientEnd],
    );
  }
}
