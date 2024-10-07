import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/routes/app_routes.dart';

class RollCallActionScreen extends ConsumerStatefulWidget {
  const RollCallActionScreen({super.key});

  @override
  ConsumerState<RollCallActionScreen> createState() => _RollCallActionScreenState();
}

class _RollCallActionScreenState extends ConsumerState<RollCallActionScreen> {
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
          title: const Text('Cancel Roll Call'),
          content: const Text('Are you sure you want to cancel this roll call?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(AppRoutes.rollCall);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(now);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classInfo.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Class ID: ${classInfo.id}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: $formattedDate',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement submit roll call
                    },
                    child: const Text('Submit'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _showCancelConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
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
                  child: Text(showOnlyAbsent ? 'Show All' : 'Show Only Absent'),
                ),
                Text('Total Present: ${students.where((s) => s.isPresent).length}'),
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
