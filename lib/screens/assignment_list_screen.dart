import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/models/assignment.dart';
import 'package:learning_management_system/providers/assignment_provider.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/widgets/assignment_card.dart';
import 'package:learning_management_system/services/assignment_service.dart';

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
              if (!isLecturer) const Tab(text: 'Upcoming'),
              Tab(text: isLecturer ? 'Active' : 'Overdue'),
              const Tab(text: 'Completed'),
            ],
          ),
        ),
        body: assignmentsAsync.when(
          data: (assignments) => TabBarView(
            children: [
              if (!isLecturer)
                _AssignmentTabContent(
                  assignments: assignments.getUpcomingAssignments(),
                  isTeacher: isLecturer,
                  onTap: (assignment) => _handleAssignmentTap(
                    context,
                    assignment,
                    isLecturer,
                    ref,
                  ),
                  onEdit: isLecturer ? _handleEditAssignment : null,
                  onDelete: isLecturer ? _handleDeleteAssignment : null,
                  onViewResponse: isLecturer ? _handleViewResponse : null,
                ),
              _AssignmentTabContent(
                assignments: isLecturer
                    ? assignments.getActiveAssignments()
                    : assignments.getOverdueAssignments(),
                isTeacher: isLecturer,
                onTap: (assignment) => _handleAssignmentTap(
                  context,
                  assignment,
                  isLecturer,
                  ref,
                ),
                onEdit: isLecturer ? _handleEditAssignment : null,
                onDelete: isLecturer ? _handleDeleteAssignment : null,
                onViewResponse: isLecturer ? _handleViewResponse : null,
              ),
              _AssignmentTabContent(
                assignments: isLecturer
                    ? assignments.getExpiredAssignments()
                    : assignments.getCompletedAssignments(),
                isTeacher: isLecturer,
                onTap: (assignment) => _handleAssignmentTap(
                  context,
                  assignment,
                  isLecturer,
                  ref,
                ),
                onEdit: isLecturer ? _handleEditAssignment : null,
                onDelete: isLecturer ? _handleDeleteAssignment : null,
                onViewResponse: isLecturer ? _handleViewResponse : null,
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
    Assignment assignment,
    bool isTeacher,
    WidgetRef ref,
  ) {
    if (!isTeacher) {
      context.pushNamed(
        Routes.submitAssignmentName,
        pathParameters: {'assignmentId': assignment.id},
        extra: assignment,
      );
    }
  }

  Future<void> _handleEditAssignment(BuildContext context, WidgetRef ref, Assignment assignment) async {
    final result = await context.pushNamed(
      Routes.editAssignmentName,
      pathParameters: {'assignmentId': assignment.id},
      extra: assignment,
    );
    if (result == true) {
      ref.invalidate(assignmentListProvider(classId));
    }
  }

  Future<void> _handleViewResponse(BuildContext context, WidgetRef ref, Assignment assignment) async {
    final result = await context.pushNamed(
      Routes.responseAssignmentName,
      pathParameters: {'assignmentId': assignment.id},
    );
    if (result == true) {
      ref.invalidate(assignmentListProvider(classId));
    }
  }

  Future<void> _handleCreateAssignment(BuildContext context, WidgetRef ref) async {
    final result = await context.pushNamed(
      Routes.createAssignmentName,
      pathParameters: {'classId': classId},
    );
    if (result == true) {
      ref.invalidate(assignmentListProvider(classId));
    }
  }

  Future<void> _handleDeleteAssignment(BuildContext context, WidgetRef ref, Assignment assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(assignmentServiceProvider.notifier).deleteAssignment(
        token: ref.read(authProvider).value?.token ?? '',
        assignmentId: assignment.id,
      );
      ref.invalidate(assignmentListProvider(classId));
    }
  }
}

class _AssignmentTabContent extends ConsumerWidget {
  final List<Assignment> assignments;
  final bool isTeacher;
  final void Function(Assignment) onTap;
  final Function(BuildContext, WidgetRef, Assignment)? onEdit;
  final Function(BuildContext, WidgetRef, Assignment)? onDelete;
  final Function(BuildContext, WidgetRef, Assignment)? onViewResponse;

  const _AssignmentTabContent({
    required this.assignments,
    required this.isTeacher,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewResponse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          isTeacher: isTeacher,
          onTap: () => onTap(assignment),
          onEdit: onEdit != null ? () => onEdit!(context, ref, assignment) : null,
          onDelete: onDelete != null ? () => onDelete!(context, ref, assignment) : null,
          onViewResponse: onViewResponse != null ? () => onViewResponse!(context, ref, assignment) : null,
        );
      },
    );
  }
}
