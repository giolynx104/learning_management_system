import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/models/assignment.dart';
import 'package:learning_management_system/providers/assignment_provider.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/widgets/assignment_card.dart';

class AssignmentListScreen extends HookConsumerWidget {
  final String classId;

  const AssignmentListScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLecturer = authState.value?.role.toLowerCase() == 'lecturer';

    // Watch assignments for this class using family provider
    final assignmentsAsync = ref.watch(assignmentListProvider(classId));

    return DefaultTabController(
      length: isLecturer ? 2 : 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assignments'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              if (!isLecturer) Tab(text: 'Upcoming'),
              Tab(text: isLecturer ? 'Active' : 'Overdue'),
              Tab(text: isLecturer ? 'Expired' : 'Completed'),
            ],
          ),
        ),
        body: assignmentsAsync.when(
          data: (assignments) => TabBarView(
            children: [
              if (!isLecturer)
                _AssignmentTabContent(
                  assignments: assignments.getUpcomingAssignments(),
                  onTap: (assignment) => _handleAssignmentTap(
                    context,
                    assignment,
                    isLecturer,
                    ref,
                  ),
                ),
              _AssignmentTabContent(
                assignments: isLecturer
                    ? assignments.getActiveAssignments()
                    : assignments.getOverdueAssignments(),
                onTap: (assignment) => _handleAssignmentTap(
                  context,
                  assignment,
                  isLecturer,
                  ref,
                ),
              ),
              _AssignmentTabContent(
                assignments: isLecturer
                    ? assignments.getExpiredAssignments()
                    : assignments.getCompletedAssignments(),
                onTap: (assignment) => _handleAssignmentTap(
                  context,
                  assignment,
                  isLecturer,
                  ref,
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: SelectableText.rich(
              TextSpan(
                text: 'Error loading assignments: ',
                children: [
                  TextSpan(
                    text: error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: isLecturer
            ? FloatingActionButton(
                onPressed: () => _handleCreateAssignment(context, ref),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  void _handleAssignmentTap(
    BuildContext context,
    List<Assignment> assignments,
    bool isTeacher,
    WidgetRef ref,
  ) {
    if (isTeacher) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext dialogContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Assignment'),
              onTap: () async {
                dialogContext.pop();
                final result = await context.pushNamed(
                  Routes.editAssignmentName,
                  pathParameters: {'assignmentId': assignments[0].id},
                  extra: assignments,
                );
                if (result == true) {
                  ref.invalidate(assignmentListProvider(classId));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('View Responses'),
              onTap: () async {
                dialogContext.pop();
                final result = await context.pushNamed(
                  Routes.responseAssignmentName,
                  pathParameters: {'assignmentId': assignments[0].id},
                );
                if (result == true) {
                  ref.invalidate(assignmentListProvider(classId));
                }
              },
            ),
          ],
        ),
      );
    } else {
      context.pushNamed(
        Routes.submitAssignmentName,
        extra: assignments,
      );
    }
  }

  Future<void> _handleCreateAssignment(
      BuildContext context, WidgetRef ref) async {
    final result = await context.pushNamed(
      Routes.createAssignmentName,
      pathParameters: {'classId': classId},
    );

    if (result == true) {
      ref.invalidate(assignmentListProvider(classId));
    }
  }
}

class _AssignmentTabContent extends StatelessWidget {
  final List<Assignment> assignments;
  final void Function(List<Assignment>) onTap;

  const _AssignmentTabContent({
    required this.assignments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: assignments.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final endTimeFormatted =
            DateFormat('HH:mm dd-MM-yyyy').format(assignment.deadline);

        return AssignmentCard(
          endTimeFormatted: endTimeFormatted,
          name: assignment.title,
          description: assignment.description,
          onTap: () => onTap(assignments),
        );
      },
    );
  }
}
