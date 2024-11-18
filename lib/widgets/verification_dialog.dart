import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/signup_provider.dart';

class VerificationDialog extends ConsumerStatefulWidget {
  final String email;
  final String verificationCode;

  const VerificationDialog({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  ConsumerState<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends ConsumerState<VerificationDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Attempting verification with code: ${_codeController.text}');
      
      final authService = ref.read(authServiceProvider);
      final success = await authService.checkVerifyCode(
        email: widget.email,
        verifyCode: _codeController.text.trim(), // Ensure no whitespace
      );

      debugPrint('Verification result: $success');

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = 'Invalid verification code');
      }
    } catch (e) {
      debugPrint('Verification error: $e');
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Email Verification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please enter the verification code:'),
          const SizedBox(height: 8),
          Text(
            'Your verification code is: ${widget.verificationCode}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Verification Code',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyCode,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}
