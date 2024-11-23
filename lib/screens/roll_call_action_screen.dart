import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/providers/attendance_provider.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/models/student_info.dart';
import 'package:go_router/go_router.dart';

class RollCallActionScreen extends HookConsumerWidget {
  final String classId;

  const RollCallActionScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final students = useState<List<StudentInfo>>([]);
    final showOnlyAbsent = useState(false);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    
    final attendanceState = ref.watch(takeAttendanceProvider);

    useEffect(() {
      Future<void> loadStudents() async {
        try {
          isLoading.value = true;
          error.value = null;
          
          final token = ref.read(authProvider).value?.token;
          if (token == null) {
            throw Exception('No authentication token found');
          }

          final classInfo = await ref.read(classServiceProvider.notifier).getClassInfo(
            token: token,
            classId: classId,
          );

          if (classInfo == null) {
            throw Exception('Failed to fetch class information');
          }

          // Convert student list to StudentInfo objects
          students.value = classInfo.studentList.map((student) {
            final studentData = student as Map<String, dynamic>;
            return StudentInfo(
              id: studentData['id']?.toString() ?? '',
              name: '${studentData['first_name'] ?? ''} ${studentData['last_name'] ?? ''}'.trim(),
              isPresent: true,
            );
          }).toList();

        } catch (e) {
          error.value = e.toString();
        } finally {
          isLoading.value = false;
        }
      }

      loadStudents();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        actions: [
          IconButton(
            icon: Icon(
              showOnlyAbsent.value ? Icons.person_off_outlined : Icons.people,
            ),
            onPressed: () => showOnlyAbsent.value = !showOnlyAbsent.value,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate.value)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 7),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      selectedDate.value = date;
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : error.value != null
                    ? Center(
                        child: Text(
                          'Error: ${error.value}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      )
                    : students.value.isEmpty
                        ? const Center(
                            child: Text('No students found in this class'),
                          )
                        : ListView.builder(
                            itemCount: students.value.length,
                            itemBuilder: (context, index) {
                              final student = students.value[index];
                              if (showOnlyAbsent.value && student.isPresent) {
                                return const SizedBox.shrink();
                              }
                              return CheckboxListTile(
                                title: Text(student.name),
                                subtitle: Text('ID: ${student.id}'),
                                value: student.isPresent,
                                onChanged: (value) {
                                  final newStudents = [...students.value];
                                  newStudents[index] = student.copyWith(
                                    isPresent: value ?? true,
                                  );
                                  students.value = newStudents;
                                },
                              );
                            },
                          ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: attendanceState.isLoading
                  ? null
                  : () async {
                      final absentStudents = students.value
                          .where((s) => !s.isPresent)
                          .map((s) => s.id)
                          .toList();

                      await ref
                          .read(takeAttendanceProvider.notifier)
                          .submit(
                            classId: classId,
                            date: selectedDate.value,
                            absentStudentIds: absentStudents,
                          )
                          .then((_) {
                        context.pop();
                      }).catchError((error) {
                        // Error is handled by the attendanceState
                      });
                    },
              child: Text(
                attendanceState.isLoading ? 'Submitting...' : 'Submit Attendance',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
