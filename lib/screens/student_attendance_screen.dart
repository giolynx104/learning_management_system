import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/models/class_detail_model.dart';
import 'package:learning_management_system/routes/routes.dart';

class StudentAttendanceScreen extends HookConsumerWidget {
  final String classId;

  const StudentAttendanceScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classInfo = useState<ClassDetailModel?>(null);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    final token = ref.watch(authProvider).value?.token;

    useEffect(() {
      Future<void> loadClassInfo() async {
        try {
          isLoading.value = true;
          error.value = null;

          if (token == null) {
            throw Exception('No authentication token found');
          }

          final info = await ref.read(classServiceProvider.notifier).getClassDetail(
            token: token,
            classId: classId,
          );

          if (info == null) {
            throw Exception('Failed to fetch class information');
          }

          classInfo.value = info;
        } catch (e) {
          error.value = e.toString();
        } finally {
          isLoading.value = false;
        }
      }

      loadClassInfo();
      return null;
    }, [token]);

    if (isLoading.value) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.value != null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: ${error.value}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      );
    }

    if (classInfo.value == null) {
      return const Scaffold(
        body: Center(
          child: Text('No class information found'),
        ),
      );
    }

    final info = classInfo.value!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.className,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Class ID: ${info.classId}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Class Type',
                        value: info.classType,
                      ),
                      const SizedBox(height: 8),
                      _InfoCard(
                        title: 'Lecturer',
                        value: info.lecturerName ?? 'Not assigned',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      context.pushNamed(
                        Routes.absenceRequest,
                        pathParameters: {'classId': classId},
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Absence Request'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () {
                      context.pushNamed(
                        Routes.absenceRequestList,
                        pathParameters: {'classId': classId},
                      );
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View My Absence Requests'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 