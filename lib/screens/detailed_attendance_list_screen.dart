import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/providers/attendance_provider.dart';
import 'package:learning_management_system/models/attendance_list_model.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
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
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate.value),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2101),
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
              data: (data) {
                if (data == null || data.attendanceDetails.isEmpty) {
                  return const Center(
                    child: Text('No attendance records found for this date'),
                  );
                }

                return ListView.builder(
                  itemCount: data.attendanceDetails.length,
                  itemBuilder: (context, index) {
                    final detail = data.attendanceDetails[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text('Student ID: ${detail.studentId}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: detail.status.toLowerCase() == 'present'
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            detail.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) {
                String errorMessage;
                if (error is ApiException) {
                  errorMessage = error.message;
                } else {
                  errorMessage = 'Failed to load attendance data';
                }
                
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => ref.refresh(
                            getAttendanceListProvider(classId, selectedDate.value),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            minimumSize: const Size(80, 36),
                          ),
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 