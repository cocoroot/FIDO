import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/fido_management_service.dart';
import 'fido_registration_screen.dart';

/// FIDO認証設定画面
/// 
/// - FIDO認証の有効化/無効化トグル
/// - FIDO認証情報の登録状態表示
/// - FIDO認証の新規登録
/// - FIDO認証の解除
class FidoAuthSettingsScreen extends StatefulWidget {
  const FidoAuthSettingsScreen({super.key});

  @override
  State<FidoAuthSettingsScreen> createState() => _FidoAuthSettingsScreenState();
}

class _FidoAuthSettingsScreenState extends State<FidoAuthSettingsScreen> {
  final FidoManagementService _fidoManagement = FidoManagementService();
  
  bool _isFidoEnabled = false;
  bool _isFidoRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    final enabled = await _fidoManagement.isFidoEnabled();
    final registered = await _fidoManagement.isFidoRegistered();
    
    setState(() {
      _isFidoEnabled = enabled;
      _isFidoRegistered = registered;
      _isLoading = false;
    });
  }

  Future<void> _toggleFido(bool value) async {
    if (value && !_isFidoRegistered) {
      // FIDO認証を有効化しようとしたが未登録の場合
      _showMessage('FIDO認証情報を登録してください', isError: true);
      return;
    }

    setState(() => _isFidoEnabled = value);
    
    await _fidoManagement.setFidoEnabled(value);

    if (mounted) {
      _showMessage(value ? 'FIDO認証を有効にしました' : 'FIDO認証を無効にしました');
    }
  }

  Future<void> _registerFido() async {
    // FIDO認証登録画面へ遷移
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const FidoRegistrationScreen(),
      ),
    );

    if (result == true) {
      // 登録成功
      _loadSettings();
    }
  }

  Future<void> _clearFido() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FIDO認証の解除'),
        content: const Text(
          'FIDO認証情報を削除しますか？\n'
          '削除すると、再度登録が必要になります。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _fidoManagement.clearFidoCredential();
      
      if (mounted) {
        if (success) {
          _showMessage('FIDO認証情報を削除しました');
          _loadSettings();
        } else {
          _showMessage('削除に失敗しました', isError: true);
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FIDO認証の設定'),
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
                  'FIDO認証を利用すると、より安全な認証が可能になります。Keypascoの技術を使用した、パスワードレス認証です。',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // FIDO認証有効化トグル
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FIDO認証',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isFidoRegistered ? '登録済み' : '未登録',
                              style: TextStyle(
                                fontSize: 13,
                                color: _isFidoRegistered 
                                    ? AppColors.success 
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isFidoEnabled,
                        onChanged: _isFidoRegistered ? _toggleFido : null,
                        activeTrackColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 登録ボタン
                if (!_isFidoRegistered)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _registerFido,
                      icon: const Icon(Icons.add_moderator),
                      label: const Text('FIDO認証を登録する'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                
                // 解除ボタン
                if (_isFidoRegistered) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _clearFido,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('FIDO認証を解除する'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                
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
                
                const SizedBox(height: 16),
                
                // 従来の生体認証との違い
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_user, 
                            size: 20, 
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '従来の生体認証との違い',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '従来の生体認証（顔認証）に加えて、FIDO認証を有効化すると：\n'
                        '• より強固な認証が可能になります\n'
                        '• 国際標準規格に準拠した認証方式\n'
                        '• 金融機関レベルのセキュリティ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[800],
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
