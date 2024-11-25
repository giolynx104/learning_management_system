import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
import 'package:learning_management_system/routes/routes.dart';

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
                  icon: const Icon(Icons.notifications_outlined),
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
