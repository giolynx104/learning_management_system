import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/providers/attendance_provider.dart';
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
    final students = useState<List<Student>>([]);
    final showOnlyAbsent = useState(false);
    
    final attendanceState = ref.watch(takeAttendanceProvider);

    useEffect(() {
      // TODO: Fetch students for this class
      students.value = List.generate(
        30,
        (index) => Student(
          id: (index + 1).toString(),
          name: 'Student ${index + 1}',
          isPresent: true,
        ),
      );
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
            child: attendanceState.when(
              data: (_) => ListView.builder(
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
                      newStudents[index] = Student(
                        id: student.id,
                        name: student.name,
                        isPresent: value ?? true,
                      );
                      students.value = newStudents;
                    },
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: SelectableText.rich(
                  TextSpan(
                    text: 'Error: ',
                    children: [
                      TextSpan(
                        text: error.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class Student {
  final String name;
  final String id;
  final bool isPresent;

  const Student({
    required this.name,
    required this.id,
    required this.isPresent,
  });
}
