import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:file_picker/file_picker.dart';

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
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: user.avatar != null 
                                ? NetworkImage(user.avatar!) 
                                : null,
                              child: user.avatar == null ? Text(
                                '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                                style: theme.textTheme.headlineMedium,
                              ) : null,
                            ),
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: () => _updateAvatar(context, ref),
                              ),
                            ),
                          ],
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
                          try {
                            // Reset app bar through router navigation
                            context.go(Routes.signin); // This will trigger router's redirect
                            
                            // Perform sign out
                            await ref.read(authProvider.notifier).signOut();
                          } catch (e) {
                            if (context.mounted) {
                              // Show error using SelectableText.rich for better error visibility
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sign Out Error'),
                                  content: SelectableText.rich(
                                    TextSpan(
                                      text: e.toString(),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
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

  Future<void> _updateAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        
        // Show loading overlay using GoRouter's overlay
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => WillPopScope(
              onWillPop: () async => false,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        try {
          // Update avatar
          await ref.read(authProvider.notifier).updateAvatar(filePath);

          if (context.mounted) {
            // First pop the loading dialog
            context.pop();
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            // First pop the loading dialog
            context.pop();
            
            // Show error dialog using GoRouter
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Update Failed'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
} 