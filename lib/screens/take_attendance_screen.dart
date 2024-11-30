import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/providers/attendance_provider.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/models/student_info.dart';
import 'package:learning_management_system/models/class_detail_model.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/services/notification_service.dart';

class TakeAttendanceScreen extends HookConsumerWidget {
  final String classId;

  const TakeAttendanceScreen({
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
    final classInfo = useState<ClassDetailModel?>(null);
    final isDateValid = useState(true);

    final attendanceState = ref.watch(takeAttendanceProvider);

    // Validate date against class schedule
    useEffect(() {
      if (classInfo.value != null) {
        final startDate = DateTime.parse(classInfo.value!.startDate);
        final endDate = DateTime.parse(classInfo.value!.endDate);
        
        isDateValid.value = selectedDate.value.isAfter(startDate) && 
                           selectedDate.value.isBefore(endDate.add(const Duration(days: 1)));
      }
      return null;
    }, [selectedDate.value, classInfo.value]);

    // Load class info and students
    useEffect(() {
      Future<void> loadData() async {
        try {
          isLoading.value = true;
          error.value = null;

          final token = ref.read(authProvider).value?.token;
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
          students.value = info.studentAccounts.map((student) => StudentInfo(
            id: student.studentId,
            name: '${student.firstName} ${student.lastName}'.trim(),
            isPresent: true,
          )).toList();
        } catch (e) {
          error.value = e.toString();
        } finally {
          isLoading.value = false;
        }
      }

      loadData();
      return null;
    }, []);

    Future<void> handleSubmit() async {
      try {
        final token = ref.read(authProvider).value?.token;
        if (token == null) {
          throw Exception('No authentication token found');
        }

        final absentStudents = students.value
            .where((s) => !s.isPresent)
            .map((s) => s.id)
            .toList();

        await ref.read(takeAttendanceProvider.notifier).submit(
          classId: classId,
          date: selectedDate.value,
          absentStudentIds: absentStudents,
        );

        // Send notifications to absent students
        if (classInfo.value != null) {
          final notificationService = ref.read(notificationServiceProvider.notifier);
          
          for (final studentId in absentStudents) {
            // Find the corresponding account_id for the student_id
            final studentAccount = classInfo.value!.studentAccounts
                .firstWhere((account) => account.studentId == studentId);

            try {
              await notificationService.sendNotification(
                token,
                'You were marked absent for ${classInfo.value!.className} on ${DateFormat('yyyy-MM-dd').format(selectedDate.value)}',
                studentAccount.accountId,
                'ABSENCE',
                null,
              );
            } catch (e) {
              debugPrint('Failed to send notification to student ${studentAccount.accountId}: $e');
            }
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showOnlyAbsent.value ? Icons.person_off_outlined : Icons.people,
            ),
            onPressed: () => showOnlyAbsent.value = !showOnlyAbsent.value,
            tooltip: showOnlyAbsent.value ? 'Show all students' : 'Show absent only',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate.value)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: classInfo.value == null
                                ? null
                                : () async {
                                    final startDate = DateTime.parse(classInfo.value!.startDate);
                                    final endDate = DateTime.parse(classInfo.value!.endDate);
                                    
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate.value,
                                      firstDate: startDate,
                                      lastDate: endDate,
                                    );
                                    if (date != null) {
                                      selectedDate.value = date;
                                    }
                                  },
                          ),
                        ],
                      ),
                      if (!isDateValid.value)
                        Text(
                          'Selected date must be within class schedule',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : error.value != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${error.value}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                error.value = null;
                                isLoading.value = true;
                              },
                              child: const Text('Retry'),
                            ),
                          ],
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
              onPressed: (!isDateValid.value || attendanceState.isLoading)
                  ? null
                  : handleSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                attendanceState.isLoading
                    ? 'Submitting...'
                    : 'Submit Attendance',
              ),
            ),
          ),
        ],
      ),
    );
  }
} 