import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/passcode_service.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';

/// 4桁パスコード入力画面
/// 
/// 実際の肥後銀行アプリと同様の4桁パスコード入力UI
/// - テンキーで数字入力
/// - ドット表示で入力状態を可視化
class PasscodeInputScreen extends StatefulWidget {
  const PasscodeInputScreen({super.key});

  @override
  State<PasscodeInputScreen> createState() => _PasscodeInputScreenState();
}

class _PasscodeInputScreenState extends State<PasscodeInputScreen> {
  final PasscodeService _passcodeService = PasscodeService();
  String _passcode = '';
  bool _isVerifying = false;

  void _onNumberTap(String number) {
    if (_passcode.length < 4) {
      setState(() {
        _passcode += number;
      });

      // 4桁入力完了時に自動検証
      if (_passcode.length == 4) {
        _verifyPasscode();
      }
    }
  }

  void _onDeleteTap() {
    if (_passcode.isNotEmpty) {
      setState(() {
        _passcode = _passcode.substring(0, _passcode.length - 1);
      });
    }
  }

  Future<void> _verifyPasscode() async {
    setState(() => _isVerifying = true);

    // パスコード検証
    final isValid = await _passcodeService.verifyPasscode(_passcode);

    if (mounted) {
      if (isValid) {
        // 認証成功 → ユーザー情報を取得してホーム画面へ
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.restoreAuthState();
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // 認証失敗 → パスコードをクリアしてエラー表示
        setState(() {
          _passcode = '';
          _isVerifying = false;
        });
        _showErrorMessage('パスコードが正しくありません');
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('パスコードの入力'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 説明テキスト
                  const Text(
                    'アプリ起動時に利用する',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    'パスコードを入力してください',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 数字4桁表示
                  const Text(
                    '数字４桁',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // パスコードドット表示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _passcode.length
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      );
                    }),
                  ),
                  
                  if (_isVerifying) ...[
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
            
            // テンキー
            Container(
              color: const Color(0xFFE8F5F7),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  // 数字ボタン 1-3
                  _buildNumberRow(['1', '2', '3']),
                  const SizedBox(height: 8),
                  
                  // 数字ボタン 4-6
                  _buildNumberRow(['4', '5', '6']),
                  const SizedBox(height: 8),
                  
                  // 数字ボタン 7-9
                  _buildNumberRow(['7', '8', '9']),
                  const SizedBox(height: 8),
                  
                  // 0と削除ボタン
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 80), // 空白
                      _buildNumberButton('0'),
                      _buildDeleteButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildNumberButton(number)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: _isVerifying ? null : () => _onNumberTap(number),
      child: Container(
        width: 80,
        height: 64,
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _isVerifying ? null : _onDeleteTap,
      child: Container(
        width: 80,
        height: 64,
        alignment: Alignment.center,
        child: const Icon(
          Icons.backspace_outlined,
          size: 28,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
