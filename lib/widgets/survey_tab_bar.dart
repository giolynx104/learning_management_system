import 'package:flutter/material.dart';

class SurveyTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabLabels;

  const SurveyTabBar({
    super.key,
    required this.tabLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      tabs: tabLabels.map((label) => Tab(text: label)).toList(),
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      labelColor: theme.colorScheme.onPrimary,
      unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
      indicatorColor: theme.colorScheme.onPrimary,
      indicatorWeight: 3,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 