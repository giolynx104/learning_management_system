import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/providers/attendance_provider.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/models/attendance_list_model.dart';
import 'package:go_router/go_router.dart';

class DetailedAttendanceListScreen extends HookConsumerWidget {
  final String classId;

  const DetailedAttendanceListScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final attendanceState = ref.watch(
      getAttendanceListProvider(classId, selectedDate.value),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Date: '),
                TextButton(
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate.value),
                  ),
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
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
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