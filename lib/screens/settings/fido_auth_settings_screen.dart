import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/fido_management_service.dart';

/// FIDO認証設定画面（生体認証設定と同様の形式）
/// 
/// - FIDO認証の有効化/無効化トグル
/// - 有効化時にKeypasco SDKを呼び出してFIDO認証を設定
class FidoAuthSettingsScreen extends StatefulWidget {
  const FidoAuthSettingsScreen({super.key});

  @override
  State<FidoAuthSettingsScreen> createState() => _FidoAuthSettingsScreenState();
}

class _FidoAuthSettingsScreenState extends State<FidoAuthSettingsScreen> {
  final FidoManagementService _fidoManagement = FidoManagementService();
  
  bool _isFidoEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    final enabled = await _fidoManagement.isFidoEnabled();
    
    setState(() {
      _isFidoEnabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleFido(bool value) async {
    if (value) {
      // FIDO認証を有効化 → Keypasco SDK呼び出し
      await _registerFido();
    } else {
      // FIDO認証を無効化
      setState(() => _isFidoEnabled = false);
      await _fidoManagement.setFidoEnabled(false);
      await _fidoManagement.clearFidoCredential();
      
      if (mounted) {
        _showMessage('FIDO認証を無効にしました');
      }
    }
  }

  Future<void> _registerFido() async {
    // FIDO認証登録を実行（Keypasco SDK呼び出し）
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      _showMessage('ユーザー情報が取得できません', isError: true);
      return;
    }

    // Keypasco SDK呼び出し
    final result = await authProvider.fidoAuthService.registerPasskey(
      userId: user.id,
      userName: user.name,
    );

    if (mounted) {
      if (result.success && result.credentialId != null) {
        // 登録成功
        await _fidoManagement.registerFidoCredential(result.credentialId!);
        await _fidoManagement.setFidoEnabled(true);
        
        setState(() => _isFidoEnabled = true);
        _showSuccessDialog();
      } else {
        _showMessage(
          result.errorMessage ?? 'FIDO認証の登録に失敗しました',
          isError: true,
        );
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 12),
            const Text('登録完了'),
          ],
        ),
        content: const Text(
          'FIDO認証が正常に登録されました。\n'
          '次回起動時から、生体認証後にFIDO認証が実行されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FIDO認証の変更'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // 説明テキスト
                const Text(
                  'FIDO認証を有効にすると、起動時に生体認証の後、Keypasco技術によるセキュアなFIDO認証が実行されます。',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // FIDO認証トグル（生体認証設定と同じスタイル）
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.fidoAuthLabel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AppStrings.fidoAuthSubLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isFidoEnabled,
                        onChanged: _toggleFido,
                        activeTrackColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // FIDO認証の説明
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, 
                            size: 20, 
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'FIDO認証について',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• FIDO2標準に準拠した最先端のパスワードレス認証\n'
                        '• Keypasco SDKを使用した高度なセキュリティ\n'
                        '• フィッシング攻撃への耐性が高い\n'
                        '• 生体情報はデバイス内に安全に保存\n'
                        '• サーバーに機密情報が送信されることはありません',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[800],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
