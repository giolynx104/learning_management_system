import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/app_routes.dart';

mixin SignOutMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Future<void> handleSignOut() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _signOut();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      final storageService = StorageService();
      await storageService.clearUserSession();
      
      if (mounted) {
        // Clear user state
        ref.read(userProvider.notifier).state = null;
        
        // Navigate to sign in screen and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.signin,
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign out. Please try again.')),
        );
      }
    }
  }
} 