import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/services/verification_service.dart';

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
  final _codeController = TextEditingController();
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
      final userId = await ref.read(verificationServiceProvider).verifyCode(
        email: widget.email,
        code: _codeController.text,
      );
      
      if (!mounted) return;
      Navigator.of(context).pop(userId);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Email Verification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your verification code is:',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          SelectableText(
            widget.verificationCode,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Enter verification code',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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