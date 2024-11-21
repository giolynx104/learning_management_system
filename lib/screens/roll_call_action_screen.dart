import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
import 'package:learning_management_system/services/attendance_service.dart';
import 'package:learning_management_system/models/attendance_model.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class RollCallActionScreen extends ConsumerStatefulWidget {
  final String classId;

  const RollCallActionScreen({
    super.key,
    required this.classId,
  });

  @override
  ConsumerState<RollCallActionScreen> createState() =>
      _RollCallActionScreenState();
}

class _RollCallActionScreenState extends ConsumerState<RollCallActionScreen> {
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarProvider.notifier).updateAppBar(
        title: 'Take Roll Call',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show roll call history
            },
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    ref.read(appBarProvider.notifier).reset();
    super.dispose();
  }

  final ClassInfo classInfo = const ClassInfo(
    name: 'Advanced Mathematics',
    id: 'MATH301',
    totalStudents: 30,
  );

  List<Student> students = List.generate(
    30,
    (index) => Student(
      name: 'Student ${index + 1}',
      id: 'S${(index + 1).toString().padLeft(3, '0')}',
      isPresent: true,
    ),
  );

  bool showOnlyAbsent = false;

  Future<void> _showCancelConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Roll Call',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: const Text(
            'Are you sure you want to cancel this roll call?',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: const Text(
                'No',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text(
                'Yes',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.go(Routes.rollCall);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAttendance() async {
    try {
      setState(() {
        isSubmitting = true;
      });

      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated) {
        throw Exception('Not authenticated');
      }

      // Get present students' IDs
      final presentStudentIds = students
          .where((student) => student.isPresent)
          .map((student) =>
              int.parse(student.id.substring(1))) // Remove 'S' prefix
          .toList();

      // Use the attendance service directly
      await ref.read(attendanceServiceProvider.notifier).submitAttendance(
            token: authState.token ?? '',
            classId: widget.classId,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            attendanceList: presentStudentIds,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('/class_management/roll-call/${widget.classId}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(now);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[900],
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classInfo.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Class ID: ${classInfo.id}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: $formattedDate',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitAttendance,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: _showCancelConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red[900],
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showOnlyAbsent = !showOnlyAbsent;
                      });
                    },
                    child:
                        Text(showOnlyAbsent ? 'Show All' : 'Show Only Absent'),
                  ),
                  Text(
                      'Total Present: ${students.where((s) => s.isPresent).length}'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Student ID')),
                    DataColumn(label: Text('Present')),
                  ],
                  rows: students
                      .where((student) => !showOnlyAbsent || !student.isPresent)
                      .map(
                        (student) => DataRow(
                          cells: [
                            DataCell(Text(student.name)),
                            DataCell(Text(student.id)),
                            DataCell(
                              Checkbox(
                                value: student.isPresent,
                                onChanged: (bool? value) {
                                  setState(() {
                                    student.isPresent = value ?? true;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Student {
  final String name;
  final String id;
  bool isPresent;

  Student({
    required this.name,
    required this.id,
    required this.isPresent,
  });
}

class ClassInfo {
  final String name;
  final String id;
  final int totalStudents;

  const ClassInfo({
    required this.name,
    required this.id,
    required this.totalStudents,
  });
}
