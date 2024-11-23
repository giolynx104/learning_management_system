import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/providers/attendance_provider.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/models/attendance_list_model.dart';

class DetailedAttendanceListScreen extends HookConsumerWidget {
  final String classId;

  const DetailedAttendanceListScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final attendanceState = ref.watch(getAttendanceListProvider);
    final token = ref.watch(authProvider).value?.token;

    Future<void> fetchAttendance() async {
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await ref.read(getAttendanceListProvider.notifier).fetch(
            classId: classId,
            date: selectedDate.value,
            token: token,
      );
    }

    useEffect(() {
      Future(() {
        fetchAttendance();
      });
      return null;
    }, [selectedDate.value, token]);

    if (token == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view attendance'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance List'),
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
                      firstDate: DateTime(2020),
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
              data: (AttendanceListResponse? data) {
                if (data == null || data.attendanceDetails.isEmpty) {
                  return const Center(
                    child: Text('No attendance records found for this date'),
                  );
                }

                return ListView.builder(
                  itemCount: data.attendanceDetails.length,
                  itemBuilder: (context, index) {
                    final record = data.attendanceDetails[index];
                    return ListTile(
                      leading: Icon(
                        record.status == 'PRESENT'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: record.status == 'PRESENT'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text('Student ID: ${record.studentId}'),
                      subtitle: Text('Status: ${record.status}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: ${error.toString()}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 