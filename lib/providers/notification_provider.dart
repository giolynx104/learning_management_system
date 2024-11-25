import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/services/notification_service.dart'; 
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final notificationService = ref.read(notificationServiceProvider.notifier);

  final authState = ref.watch(authProvider);

  final token = authState.token;
  if (token == null) {
    return 0;
  }

  try {
    final count = await notificationService.getUnreadNotificationCount(token);
    return count;
  } catch (e) {
    if (e is UnauthorizedException) {
      ref.read(authProvider.notifier).signOut();
    }
    return 0;
  }
});
