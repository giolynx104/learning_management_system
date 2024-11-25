import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; 
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
import 'package:learning_management_system/providers/notification_provider.dart';
import 'package:learning_management_system/services/notification_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart'; 

class CustomLayoutScaffold extends ConsumerWidget {
  final Widget child;
  final bool hideAppBar;
  final bool? resizeToAvoidBottomInset;

  const CustomLayoutScaffold({
    required this.child,
    this.hideAppBar = false,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appBarState = ref.watch(appBarNotifierProvider);
    final unreadCountAsyncValue = ref.watch(unreadNotificationCountProvider);
    int unreadCount = 0;
    unreadCountAsyncValue.when(
      data: (count) => unreadCount = count,
      loading: () => unreadCount = 0,
      error: (e, _) => unreadCount = 0,
    );

    String badgeText = '';
    double badgeSize = 20;
    double badgeRadius = 10;
    double fontSize = 12;

    if (unreadCount > 0) {
      if (unreadCount > 99) {
        badgeText = '99+';
        badgeSize = 24;
        badgeRadius = 12;
        fontSize = 12;
      } else if (unreadCount >= 10) {
        badgeText = '$unreadCount';
        badgeSize = 22;
        badgeRadius =11;
        fontSize = 12;
      } else {
        badgeText = '$unreadCount';
        badgeSize = 20;
        badgeRadius = 10;
        fontSize = 12;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: hideAppBar || appBarState.hideAppBar
          ? null
          : AppBar(
              title: Image.asset(
                'assets/images/HUST_white.png',
                height: 30,
                fit: BoxFit.contain,
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              actions: [
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: theme.colorScheme.onPrimary,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            width: badgeSize,
                            height: badgeSize,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(badgeRadius),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: 'Notifications',
                  onPressed: () {
                    context.pushNamed(Routes.notificationName);
                  },
                ),
              ],
            ),
      body: child,
    );
  }
}
