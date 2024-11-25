import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class StudentHomeScreen extends HookConsumerWidget {
  const StudentHomeScreen({super.key});

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
                'Welcome, ${user?.firstName ?? 'Student'}!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your academic progress and stay updated',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Learning Actions Section
              Text(
                'Learning Actions',
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
                    subtitle: 'View enrolled classes',
                    color: theme.colorScheme.primary,
                    onTap: () => context.goNamed(Routes.classesName),
                  ),
                  _ActionCard(
                    icon: Icons.assignment,
                    title: 'Assignments',
                    subtitle: 'View and submit work',
                    color: Colors.orange,
                    onTap: () => context.goNamed(Routes.assignmentsName),
                  ),
                  _ActionCard(
                    icon: Icons.calendar_today,
                    title: 'Attendance',
                    subtitle: 'Check your attendance',
                    color: Colors.green,
                    onTap: () {
                      // Will be implemented with class-specific attendance
                    },
                  ),
                  _ActionCard(
                    icon: Icons.chat,
                    title: 'Messages',
                    subtitle: 'Chat with teachers',
                    color: Colors.blue,
                    onTap: () => context.goNamed(Routes.chatName),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Academic Overview Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Academic Overview',
                    style: theme.textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.goNamed(Routes.classesName),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAcademicOverview(theme),
              
              const SizedBox(height: 32),
              
              // Recent Updates Section
              Text(
                'Recent Updates',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildRecentUpdates(theme),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(Routes.classRegistrationName),
        icon: const Icon(Icons.add),
        label: const Text('Register for Class'),
      ),
    );
  }

  Widget _buildAcademicOverview(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOverviewItem(
              theme,
              icon: Icons.class_,
              title: 'Enrolled Classes',
              value: '5',
              color: theme.colorScheme.primary,
            ),
            const Divider(height: 32),
            _buildOverviewItem(
              theme,
              icon: Icons.assignment_late,
              title: 'Pending Tasks',
              value: '3',
              color: Colors.orange,
            ),
            const Divider(height: 32),
            _buildOverviewItem(
              theme,
              icon: Icons.calendar_today,
              title: 'Attendance Rate',
              value: '95%',
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

  Widget _buildRecentUpdates(ThemeData theme) {
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
                _getUpdateIcon(index),
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(_getUpdateTitle(index)),
            subtitle: Text(_getUpdateSubtitle(index)),
            trailing: Text(
              _getUpdateTime(index),
              style: theme.textTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }

  IconData _getUpdateIcon(int index) {
    switch (index) {
      case 0:
        return Icons.assignment_turned_in;
      case 1:
        return Icons.class_;
      default:
        return Icons.notifications;
    }
  }

  String _getUpdateTitle(int index) {
    switch (index) {
      case 0:
        return 'New Assignment Posted';
      case 1:
        return 'Class Schedule Updated';
      default:
        return 'Attendance Marked';
    }
  }

  String _getUpdateSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Mathematics: Chapter 3 Exercise';
      case 1:
        return 'Physics class rescheduled to 2 PM';
      default:
        return 'Present in Computer Science class';
    }
  }

  String _getUpdateTime(int index) {
    switch (index) {
      case 0:
        return '5m ago';
      case 1:
        return '2h ago';
      default:
        return '4h ago';
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
