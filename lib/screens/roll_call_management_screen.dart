import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/routes/app_routes.dart';

class RollCallScreen extends ConsumerWidget {
  const RollCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    const classInfo = ClassInfo(
      name: 'Advanced Mathematics',
      id: 'MATH301',
      totalAbsences: 45,
      pendingAbsentRequests: 3,
      totalStudents: 30,
      averageAttendance: 0.92,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Roll Call'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classInfo.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Class ID: ${classInfo.id}',
              style: Theme.of(context).textTheme.titleMedium,
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
              value: '${(classInfo.averageAttendance * 100).toStringAsFixed(1)}%',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.detailedRollCall);
                },
                child: const Text('View Detailed Roll Call'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.rollCallAction);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Start Roll Call Now'),
              ),
            ),
          ],
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
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
