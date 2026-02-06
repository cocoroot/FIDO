import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

/// FIDO登録画面
/// 
/// 初回ユーザーがパスキー（生体認証）を登録するための画面
class FidoRegisterScreen extends StatefulWidget {
  const FidoRegisterScreen({super.key});

  @override
  State<FidoRegisterScreen> createState() => _FidoRegisterScreenState();
}

class _FidoRegisterScreenState extends State<FidoRegisterScreen> {
  final _userIdController = TextEditingController(text: 'user_001');
  final _userNameController = TextEditingController(text: '田中 太郎');
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreedToTerms) {
      _showErrorDialog('利用規約に同意してください');
      return;
    }

    final userId = _userIdController.text.trim();
    final userName = _userNameController.text.trim();

    if (userId.isEmpty || userName.isEmpty) {
      _showErrorDialog('すべての項目を入力してください');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 登録処理
    final success = await authProvider.registerWithPasskey(
      userId: userId,
      userName: userName,
    );

    if (success && mounted) {
      // 登録成功
      _showSuccessDialog();
    } else if (mounted && authProvider.errorMessage != null) {
      _showErrorDialog(authProvider.errorMessage!);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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
            Icon(Icons.check_circle, color: Colors.green[600], size: 32),
            const SizedBox(width: 12),
            const Text('登録完了'),
          ],
        ),
        content: const Text('パスキーが正常に登録されました。\n今後はこのデバイスで安全にログインできます。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text('ホーム画面へ'),
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
        title: const Text('生体認証の登録'),
        backgroundColor: const Color(0xFF003D7A),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
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
                      Icon(Icons.fingerprint, size: 64, color: Colors.blue[700]),
                      const SizedBox(height: 16),
                      Text(
                        'パスキーを登録',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '生体認証を使って、安全かつ簡単にログインできるようになります。',
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
                
                // ユーザーID入力
                TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: 'ユーザーID',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // ユーザー名入力
                TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: 'お名前',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 利用規約同意チェックボックス
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF003D7A),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreedToTerms = !_agreedToTerms;
                            });
                          },
                          child: const Text(
                            '生体認証の利用規約に同意します',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 登録ボタン
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003D7A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fingerprint, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  '生体認証を設定',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
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
                      _buildSecurityPoint('生体情報はデバイス内に安全に保存されます'),
                      const SizedBox(height: 8),
                      _buildSecurityPoint('サーバーに生体情報が送信されることはありません'),
                      const SizedBox(height: 8),
                      _buildSecurityPoint('FIDO2標準に準拠した高いセキュリティ'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
