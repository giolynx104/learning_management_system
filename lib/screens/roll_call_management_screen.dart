import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';

class RollCallScreen extends HookConsumerWidget {
  final String classId;

  const RollCallScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classInfo = ClassInfo(
      name: 'Advanced Mathematics',
      id: 'MATH301',
      totalAbsences: 45,
      pendingAbsentRequests: 3,
      totalStudents: 30,
      averageAttendance: 0.92,
    );

    return Scaffold(
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
                        classInfo.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Class ID: ${classInfo.id}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Total Absences',
                        value: classInfo.totalAbsences.toString(),
                      ),
                      const SizedBox(height: 8),
                      _InfoCard(
                        title: 'Pending Absent Requests',
                        value: classInfo.pendingAbsentRequests.toString(),
                      ),
                      const SizedBox(height: 8),
                      _InfoCard(
                        title: 'Total Students',
                        value: classInfo.totalStudents.toString(),
                      ),
                      const SizedBox(height: 8),
                      _InfoCard(
                        title: 'Average Attendance',
                        value:
                            '${(classInfo.averageAttendance * 100).toStringAsFixed(1)}%',
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
                        Routes.detailedAttendanceList,
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
                        Routes.rollCallAction,
                        pathParameters: {'classId': classId},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Take Attendance'),
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

class ClassInfo {
  final String name;
  final String id;
  final int totalAbsences;
  final int pendingAbsentRequests;
  final int totalStudents;
  final double averageAttendance;

  const ClassInfo({
    required this.name,
    required this.id,
    required this.totalAbsences,
    required this.pendingAbsentRequests,
    required this.totalStudents,
    required this.averageAttendance,
  });
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
