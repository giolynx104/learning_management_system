import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';

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
    final appBarState = ref.watch(appBarNotifierProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: hideAppBar 
          ? null 
          : AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appBarState.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset(
                    'assets/images/HUST_white.png',
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              centerTitle: appBarState.centerTitle,
              elevation: appBarState.elevation,
              backgroundColor: appBarState.backgroundColor ?? theme.colorScheme.primary,
              foregroundColor: appBarState.foregroundColor ?? theme.colorScheme.onPrimary,
              automaticallyImplyLeading: appBarState.automaticallyImplyLeading,
              leading: appBarState.leading,
              actions: appBarState.actions,
              bottom: appBarState.bottom,
            ),
      body: child,
    );
  }
}
