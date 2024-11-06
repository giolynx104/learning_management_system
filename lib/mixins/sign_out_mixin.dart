import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';

mixin SignOutMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final _storageService = StorageService();

  Future<void> handleSignOut() async {
    try {
      await _storageService.clearUserSession();
      if (!mounted) return;
      
      await ref.read(authProvider.notifier).logout();
      
      if (!mounted) return;
      context.go(Routes.signin);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }
} 