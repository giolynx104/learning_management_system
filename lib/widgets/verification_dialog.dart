import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_service_provider.dart';
import 'package:learning_management_system/providers/signup_provider.dart';
import 'package:learning_management_system/services/auth_service.dart';

/// A dialog that handles email verification code input and verification.
/// 
/// Shows a form where users can enter their verification code and handles
/// the verification process through the [SignUpProvider].
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
      final authService = ref.read(authServiceProvider);
      final isVerified = await authService.checkVerifyCode(
        email: widget.email,
        verifyCode: _codeController.text,
      );
      
      if (!mounted) return;
      
      if (isVerified) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = 'Invalid verification code');
      }
    } catch (e) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Please enter the verification code sent to ${widget.email}'),
          const SizedBox(height: 8),
          // Display the verification code
          Text(
            'Verification Code: ${widget.verificationCode}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Enter Verification Code',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verifyCode(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
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
