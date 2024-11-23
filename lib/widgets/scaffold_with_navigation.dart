import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/destinations.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<Destination> destinations;

  const ScaffoldWithNavigation({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: destinations,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
} 