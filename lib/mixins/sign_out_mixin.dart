import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';

mixin SignOutMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final _storageService = StorageService();

  Future<void> handleSignOut() async {
    if (!mounted) return;
    
    try {
      // Reset app bar through router navigation
      context.go(Routes.signin); // This will trigger router's redirect
      
      // Clear storage and sign out
      await _storageService.clearToken();
      await ref.read(authProvider.notifier).signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }
}
