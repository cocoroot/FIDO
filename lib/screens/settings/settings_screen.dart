import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'biometric_settings_screen.dart';
import 'passcode_change_screen.dart';
import 'fido_auth_settings_screen.dart';

/// 設定画面（実際の肥後銀行アプリ準拠）
/// 
/// メニュー項目:
/// - ヘルプ
/// - 利用規約
/// - アカウントの管理
/// - 利用端末の管理
/// - パスコードの変更
/// - 生体認証の変更
/// - アプリを終了する
/// - 退会の手続き
/// - ライセンス
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: AppStrings.helpMenu,
            onTap: () {
              _showMessage(context, 'ヘルプ（デモ）');
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: AppStrings.termsMenu,
            onTap: () {
              _showMessage(context, '利用規約（デモ）');
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            title: AppStrings.accountManagement,
            onTap: () {
              _showMessage(context, 'アカウントの管理（デモ）');
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.phone_android,
            title: AppStrings.deviceManagement,
            onTap: () {
              _showMessage(context, '利用端末の管理（デモ）');
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.lock_outline,
            title: AppStrings.passcodeChange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PasscodeChangeScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.fingerprint,
            title: AppStrings.biometricChange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BiometricSettingsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.verified_user,
            title: AppStrings.fidoAuthChange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FidoAuthSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.exit_to_app,
            title: AppStrings.appExit,
            onTap: () {
              _handleLogout(context);
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.cancel_outlined,
            title: AppStrings.withdrawal,
            titleColor: AppColors.error,
            onTap: () {
              _showMessage(context, '退会の手続き（デモ）');
            },
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: Icons.article_outlined,
            title: AppStrings.licenses,
            onTap: () {
              showLicensePage(context: context);
            },
          ),
          const SizedBox(height: 32),
          
          // アプリバージョン
          const Center(
            child: Text(
              AppStrings.appVersion,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.iconSecondary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: titleColor ?? AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.iconSecondary),
        onTap: onTap,
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.appExit),
        content: const Text(AppStrings.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.exitButton),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
