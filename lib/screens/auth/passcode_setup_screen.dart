import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/passcode_service.dart';

/// 4桁パスコード設定画面
/// 
/// 新規パスコード設定および確認入力
class PasscodeSetupScreen extends StatefulWidget {
  final bool isChanging; // 変更モードかどうか

  const PasscodeSetupScreen({
    super.key,
    this.isChanging = false,
  });

  @override
  State<PasscodeSetupScreen> createState() => _PasscodeSetupScreenState();
}

class _PasscodeSetupScreenState extends State<PasscodeSetupScreen> {
  final PasscodeService _passcodeService = PasscodeService();
  
  String _passcode = '';
  String _confirmPasscode = '';
  bool _isConfirmMode = false;
  bool _isSaving = false;

  void _onNumberTap(String number) {
    if (_isSaving) return;

    if (!_isConfirmMode) {
      // 初回入力
      if (_passcode.length < 4) {
        setState(() {
          _passcode += number;
        });

        // 4桁入力完了時に確認モードへ
        if (_passcode.length == 4) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _isConfirmMode = true;
              });
            }
          });
        }
      }
    } else {
      // 確認入力
      if (_confirmPasscode.length < 4) {
        setState(() {
          _confirmPasscode += number;
        });

        // 4桁入力完了時に検証
        if (_confirmPasscode.length == 4) {
          _verifyAndSavePasscode();
        }
      }
    }
  }

  void _onDeleteTap() {
    if (_isSaving) return;

    if (!_isConfirmMode) {
      if (_passcode.isNotEmpty) {
        setState(() {
          _passcode = _passcode.substring(0, _passcode.length - 1);
        });
      }
    } else {
      if (_confirmPasscode.isNotEmpty) {
        setState(() {
          _confirmPasscode = _confirmPasscode.substring(0, _confirmPasscode.length - 1);
        });
      }
    }
  }

  Future<void> _verifyAndSavePasscode() async {
    if (_passcode != _confirmPasscode) {
      // パスコードが一致しない
      _showErrorMessage('パスコードが一致しません');
      setState(() {
        _passcode = '';
        _confirmPasscode = '';
        _isConfirmMode = false;
      });
      return;
    }

    setState(() => _isSaving = true);

    // パスコードを保存
    final success = await _passcodeService.setPasscode(_passcode);

    if (mounted) {
      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorMessage('パスコードの保存に失敗しました');
        setState(() {
          _passcode = '';
          _confirmPasscode = '';
          _isConfirmMode = false;
          _isSaving = false;
        });
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 12),
            Text(widget.isChanging ? '変更完了' : '設定完了'),
          ],
        ),
        content: Text(widget.isChanging
            ? 'パスコードが変更されました。'
            : 'パスコードが設定されました。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
              Navigator.of(context).pop(); // 設定画面に戻る
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
        title: Text(widget.isChanging ? 'パスコードの変更' : 'パスコードの設定'),
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
                  Text(
                    _isConfirmMode
                        ? '確認のため、もう一度'
                        : 'アプリ起動時に利用する',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _isConfirmMode
                        ? 'パスコードを入力してください'
                        : 'パスコードを設定してください',
                    style: const TextStyle(
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
                      final currentPasscode = _isConfirmMode ? _confirmPasscode : _passcode;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < currentPasscode.length
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      );
                    }),
                  ),
                  
                  if (_isSaving) ...[
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
                  _buildNumberRow(['1', '2', '3']),
                  const SizedBox(height: 8),
                  _buildNumberRow(['4', '5', '6']),
                  const SizedBox(height: 8),
                  _buildNumberRow(['7', '8', '9']),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 80),
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
      onTap: () => _onNumberTap(number),
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
      onTap: _onDeleteTap,
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
