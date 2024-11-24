import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/models/absence_request_list_model.dart';
import 'package:learning_management_system/providers/absence_request_provider.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class AbsenceRequestListScreen extends HookConsumerWidget {
  final String classId;

  const AbsenceRequestListScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState<DateTime?>(null);
    final selectedStatus = useState<AbsenceRequestStatus?>(null);
    final isTeacher = ref.watch(authProvider).value?.role.toLowerCase() == 'lecturer';

    final requestsState = ref.watch(
      getAbsenceRequestsProvider(
        classId,
        status: selectedStatus.value,
        date: selectedDate.value,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absence Requests'),
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
                DropdownButton<AbsenceRequestStatus?>(
                  value: selectedStatus.value,
                  hint: const Text('Filter by status'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All'),
                    ),
                    ...AbsenceRequestStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: (value) => selectedStatus.value = value,
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    selectedDate.value = date;
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate.value != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate.value!)
                        : 'Select Date',
                  ),
                ),
                if (selectedDate.value != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => selectedDate.value = null,
                  ),
              ],
            ),
          ),
          Expanded(
            child: requestsState.when(
              data: (data) {
                if (data.pageContent.isEmpty) {
                  return const Center(
                    child: Text('No absence requests found'),
                  );
                }

                return ListView.builder(
                  itemCount: data.pageContent.length,
                  itemBuilder: (context, index) {
                    final request = data.pageContent[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(request.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${request.absenceDate}'),
                            Text('Reason: ${request.reason}'),
                            Text('Status: ${request.status.name.toUpperCase()}'),
                            if (isTeacher)
                              Text(
                                'Student: ${request.studentAccount.firstName} ${request.studentAccount.lastName} (${request.studentAccount.studentId})',
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            request.status.name.toUpperCase(),
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

  Color _getStatusColor(AbsenceRequestStatus status) {
    switch (status) {
      case AbsenceRequestStatus.accepted:
        return Colors.green;
      case AbsenceRequestStatus.rejected:
        return Colors.red;
      case AbsenceRequestStatus.pending:
        return Colors.orange;
    }
  }
} 