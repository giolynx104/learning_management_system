import 'package:flutter/material.dart';
import 'package:learning_management_system/widgets/verification_dialog.dart';

/// Helper class for handling email verification workflows.
class VerificationHelper {
  /// Shows a verification dialog and handles the verification process.
  /// 
  /// Returns true if verification was successful, false otherwise.
  /// 
  /// Parameters:
  /// - [context]: The BuildContext for showing the dialog
  /// - [email]: The email address being verified
  /// - [verificationCode]: The expected verification code
  /// 
  /// Throws an exception if the context is no longer mounted.
  static Future<bool> handleVerification({
    required BuildContext context,
    required String email,
    required String verificationCode,
  }) async {
    if (!context.mounted) {
      throw Exception('Context is no longer mounted');
    }
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return VerificationDialog(
          email: email,
          verificationCode: verificationCode,
        );
      },
    );

    return result ?? false;
  }
} 