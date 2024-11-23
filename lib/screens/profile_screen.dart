import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) => user == null
          ? const Center(child: Text('Not logged in'))
          : ListView(
              children: [
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          child: Text(
                            '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                            style: theme.textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          user.role,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                // Settings/Actions
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        onTap: () {
                          // Navigate to settings
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        onTap: () {
                          // Navigate to help
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sign Out', 
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          await ref.read(authProvider.notifier).signOut();
                          if (context.mounted) {
                            context.go(Routes.signin);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
} 