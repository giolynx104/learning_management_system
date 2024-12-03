import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class TeacherHomeScreen extends HookConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).value;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user?.firstName ?? 'Teacher'}!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your classes and track student progress',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Teaching Actions Section
              Text(
                'Teaching Actions',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _ActionCard(
                    icon: Icons.class_,
                    title: 'My Classes',
                    subtitle: 'Manage your classes',
                    color: theme.colorScheme.primary,
                    onTap: () => context.goNamed(Routes.classesName),
                  ),
                  _ActionCard(
                    icon: Icons.assignment,
                    title: 'Assignments',
                    subtitle: 'Create and grade assignments',
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to assignments when implemented
                    },
                  ),
                  _ActionCard(
                    icon: Icons.people,
                    title: 'Attendance',
                    subtitle: 'Take class attendance',
                    color: Colors.green,
                    onTap: () {
                      // Navigate to attendance when implemented
                    },
                  ),
                  _ActionCard(
                    icon: Icons.chat,
                    title: 'Messages',
                    subtitle: 'Chat with students',
                    color: Colors.blue,
                    onTap: () => context.goNamed(Routes.chatName),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Class Overview Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Class Overview',
                    style: theme.textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.goNamed(Routes.classesName),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildClassOverview(theme),
              
              const SizedBox(height: 32),
              
              // Recent Activities Section
              Text(
                'Recent Activities',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildRecentActivities(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassOverview(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOverviewItem(
              theme,
              icon: Icons.class_,
              title: 'Active Classes',
              value: '5',
              color: theme.colorScheme.primary,
            ),
            const Divider(height: 32),
            _buildOverviewItem(
              theme,
              icon: Icons.assignment_turned_in,
              title: 'Pending Assignments',
              value: '12',
              color: Colors.orange,
            ),
            const Divider(height: 32),
            _buildOverviewItem(
              theme,
              icon: Icons.people_outline,
              title: 'Total Students',
              value: '150',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(ThemeData theme) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                _getActivityIcon(index),
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(_getActivityTitle(index)),
            subtitle: Text(_getActivitySubtitle(index)),
            trailing: Text(
              _getActivityTime(index),
              style: theme.textTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }

  IconData _getActivityIcon(int index) {
    switch (index) {
      case 0:
        return Icons.assignment_turned_in;
      case 1:
        return Icons.people;
      default:
        return Icons.class_;
    }
  }

  String _getActivityTitle(int index) {
    switch (index) {
      case 0:
        return 'New Assignment Submission';
      case 1:
        return 'Attendance Taken';
      default:
        return 'Class Created';
    }
  }

  String _getActivitySubtitle(int index) {
    switch (index) {
      case 0:
        return 'John Doe submitted Assignment 3';
      case 1:
        return 'Marked attendance for Class A';
      default:
        return 'Created new class: Mathematics 101';
    }
  }

  String _getActivityTime(int index) {
    switch (index) {
      case 0:
        return '2m ago';
      case 1:
        return '1h ago';
      default:
        return '3h ago';
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
