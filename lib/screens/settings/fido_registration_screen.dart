import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/fido_management_service.dart';

/// FIDO認証登録画面
/// 
/// ユーザーがFIDO認証を初めて設定する画面
class FidoRegistrationScreen extends StatefulWidget {
  const FidoRegistrationScreen({super.key});

  @override
  State<FidoRegistrationScreen> createState() => _FidoRegistrationScreenState();
}

class _FidoRegistrationScreenState extends State<FidoRegistrationScreen> {
  final FidoManagementService _fidoManagement = FidoManagementService();
  bool _isRegistering = false;
  bool _agreedToTerms = false;

  Future<void> _handleRegister() async {
    if (!_agreedToTerms) {
      _showMessage('利用規約に同意してください', isError: true);
      return;
    }

    setState(() => _isRegistering = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      setState(() => _isRegistering = false);
      _showMessage('ユーザー情報が取得できません', isError: true);
      return;
    }

    // FIDO認証登録（Keypasco SDK呼び出し）
    final result = await authProvider.fidoAuthService.registerPasskey(
      userId: user.id,
      userName: user.name,
    );

    if (mounted) {
      setState(() => _isRegistering = false);

      if (result.success && result.credentialId != null) {
        // 登録成功 → credentialIdを保存
        await _fidoManagement.registerFidoCredential(result.credentialId!);
        await _fidoManagement.setFidoEnabled(true);
        
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
      barrierDismissible: false,
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
          '次回起動時からFIDO認証でログインできます。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
              Navigator.of(context).pop(true); // 登録画面を閉じる（成功）
            },
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
        title: const Text('FIDO認証の登録'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 説明セクション
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.security, size: 64, color: Colors.blue[700]),
                  const SizedBox(height: 16),
                  Text(
                    'FIDO認証を登録',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keypasco技術を使用した、より安全な認証方式を設定します。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 登録手順
            _buildStep(
              number: '1',
              title: '利用規約を確認',
              description: 'FIDO認証の利用規約をご確認ください',
            ),
            
            const SizedBox(height: 16),
            
            _buildStep(
              number: '2',
              title: '生体認証の実行',
              description: '登録ボタンをタップすると、生体認証が開始されます',
            ),
            
            const SizedBox(height: 16),
            
            _buildStep(
              number: '3',
              title: '登録完了',
              description: '次回起動時からFIDO認証が利用可能になります',
            ),
            
            const SizedBox(height: 32),
            
            // 利用規約同意チェックボックス
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: _isRegistering 
                        ? null 
                        : (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isRegistering
                          ? null
                          : () {
                              setState(() {
                                _agreedToTerms = !_agreedToTerms;
                              });
                            },
                      child: const Text(
                        'FIDO認証の利用規約に同意します',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 登録ボタン
            ElevatedButton.icon(
              onPressed: _isRegistering ? null : _handleRegister,
              icon: _isRegistering
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.fingerprint),
              label: Text(_isRegistering ? '登録中...' : 'FIDO認証を登録'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // セキュリティ情報
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'セキュリティについて',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityPoint('FIDO2標準に準拠した最先端の認証技術'),
                  const SizedBox(height: 8),
                  _buildSecurityPoint('Keypasco SDKによる高度なセキュリティ'),
                  const SizedBox(height: 8),
                  _buildSecurityPoint('生体情報はデバイス内に安全に保存'),
                  const SizedBox(height: 8),
                  _buildSecurityPoint('フィッシング攻撃への高い耐性'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: Colors.green[700], size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.green[800]),
          ),
        ),
      ],
    );
  }
}
