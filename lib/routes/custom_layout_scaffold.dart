import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/destinations.dart';
import 'package:learning_management_system/mixins/sign_out_mixin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';

class LayoutScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Destination> destinations;
  const LayoutScaffold({
    required this.destinations,
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('LayoutScaffold'));

  @override
  ConsumerState<LayoutScaffold> createState() => _LayoutScaffoldState();
}

class _LayoutScaffoldState extends ConsumerState<LayoutScaffold> with SignOutMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarProvider.notifier).updateAppBar(
        title: widget.destinations[widget.navigationShell.currentIndex].label,
      );
    });
  }

  void updateAppBarTitle(int index) {
    ref.read(appBarProvider.notifier).updateAppBar(
      title: widget.destinations[index].label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarState = ref.watch(appBarProvider);

    return Scaffold(
      appBar: appBarState.showDefaultAppBar
          ? appBarState.customAppBar as PreferredSizeWidget? ??
              AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: Text(
                  appBarState.title,
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
                actions: appBarState.actions,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
          : null,
      drawer: Consumer(
        builder: (context, ref, child) {
          final userState = ref.watch(authProvider);

          return userState.when(
            data: (user) {
              if (user == null) return const SizedBox.shrink();
              
              return Container(
                color: Theme.of(context).colorScheme.surface,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(
                        "${user.firstName} ${user.lastName}",
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      accountEmail: Text(
                        user.email,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      currentAccountPicture: user.avatar != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(user.avatar!),
                              backgroundColor: Theme.of(context).colorScheme.surface,
                            )
                          : CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              child: const Icon(Icons.person),
                            ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: const Text("Trực tuyến"),
                      onTap: () {
                        // Handle online status click
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text("Cài đặt trạng thái thông báo"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Cài đặt"),
                      onTap: () {},
                    ),
                    const Divider(),
                    const ListTile(
                      title: Text("Tài khoản và tổ chức"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text("Hanoi University of Science and Technology"),
                      subtitle: Text(user.email),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text("Thêm tài khoản"),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        handleSignOut(); // This comes from SignOutMixin
                      },
                    ),
                  ],
                ),
              );
            },
            loading: () => Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Text('Error loading user data: $error'),
              ),
            ),
          );
        },
      ),
      // Wrap the body in SafeArea to avoid layout issues
      body: SafeArea(
        child: widget.navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(index);
          updateAppBarTitle(index);
        },
        indicatorColor: Colors.red,
        destinations: widget.destinations
            .map((destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  label: destination.label,
                  selectedIcon: Icon(destination.onPressedIcon, color: Colors.white),
                ))
            .toList(),
      ),
    );
  }
}
