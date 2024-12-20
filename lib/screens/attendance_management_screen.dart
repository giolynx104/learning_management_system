import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../routes/routes.dart';
import '../providers/auth_provider.dart';
import '../services/class_service.dart';
import '../models/class_detail_model.dart';

class AttendanceManagementScreen extends HookConsumerWidget {
  final String classId;

  const AttendanceManagementScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('AttendanceManagementScreen - Build started');
    
    try {
      final classInfo = useState<ClassDetailModel?>(null);
      debugPrint('AttendanceManagementScreen - useState initialized');
      final isLoading = useState(true);
      final error = useState<String?>(null);
      final token = ref.watch(authProvider).value?.token;
      final selectedDate = useState(DateTime.now());

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
      final totalStudents = info.studentCount;
      final attendanceRate = totalStudents > 0 
          ? info.studentAccounts.length / totalStudents 
          : 0.0;

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
                          title: 'Total Students',
                          value: totalStudents.toString(),
                        ),
                        const SizedBox(height: 8),
                        _InfoCard(
                          title: 'Student Accounts',
                          value: info.studentAccounts.length.toString(),
                        ),
                        const SizedBox(height: 8),
                        _InfoCard(
                          title: 'Class Type',
                          value: info.classType,
                        ),
                        const SizedBox(height: 8),
                        _InfoCard(
                          title: 'Attendance Rate',
                          value: '${(attendanceRate * 100).toStringAsFixed(1)}%',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.pushNamed(
                          Routes.detailedAttendanceListName,
                          pathParameters: {'classId': classId},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Get Attendance List'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.pushNamed(
                          Routes.takeAttendanceName,
                          pathParameters: {'classId': classId},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Take Attendance'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.pushNamed(
                          Routes.absenceRequestListName,
                          pathParameters: {'classId': classId},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('View Absence Requests'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('AttendanceManagementScreen - Error in build: $e');
      debugPrint('AttendanceManagementScreen - Stack trace: $stackTrace');
      return Scaffold(
        body: Center(
          child: Text('Error: ${e.toString()}'),
        ),
      );
    }
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