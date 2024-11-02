import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/services/auth_service.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/models/user.dart';

final authServiceProvider = Provider((ref) => AuthService());
final storageServiceProvider = Provider((ref) => StorageService());

final signUpProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, signUpData) async {
  final authService = ref.watch(authServiceProvider);
  return authService.signUp(
    email: signUpData['email'] as String,
    password: signUpData['password'] as String,
    uuid: signUpData['uuid'] as int,
    role: signUpData['role'] as String,
  );
});

final loginProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, loginData) async {
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  
  final response = await authService.signIn(
    email: loginData['email'] as String,
    password: loginData['password'] as String,
  );

  if (response['success'] == true && !response['needs_verification']) {
    final user = response['user'] as User;
    // Save complete user data
    await storageService.saveUserData(user);
  }

  return response;
});

final userProvider = StateProvider<User?>((ref) => null);

// Enhanced session provider that handles complete user data
final userSessionProvider = FutureProvider<User?>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  try {
    // Try to get stored user data first
    final userData = await storageService.getUserData();
    if (userData != null) {
      // If we have stored data, use it
      return userData;
    }
    
    // If no stored data but we have token, try to refresh user data
    final token = await storageService.getToken();
    if (token != null) {
      try {
        // TODO: Implement refresh token API call
        // final freshUserData = await authService.refreshUserData(token);
        // await storageService.saveUserData(freshUserData);
        // return freshUserData;
        return null;
      } catch (e) {
        // If refresh fails, clear session and return null
        await storageService.clearUserSession();
        return null;
      }
    }
    
    return null;
  } catch (e) {
    // If any error occurs, clear session and return null
    await storageService.clearUserSession();
    return null;
  }
});

// Add a provider to handle session expiry
final sessionStateProvider = StateProvider<SessionState>((ref) => SessionState.unknown);

enum SessionState {
  unknown,
  valid,
  expired,
  none,
}
