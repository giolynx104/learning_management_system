import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/assignment_provider.dart';
import 'package:learning_management_system/models/assignment.dart';
import 'package:intl/intl.dart';

class AssignmentListScreen extends ConsumerWidget {
  const AssignmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(assignmentListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: assignmentsAsync.when(
        data: (assignments) => _buildAssignmentList(context, ref, assignments),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildAssignmentList(BuildContext context, WidgetRef ref, List<Assignment> assignments) {
    final provider = ref.read(assignmentListProvider.notifier);
    final upcoming = provider.getUpcomingAssignments(assignments);
    final overdue = provider.getOverdueAssignments(assignments);
    final completed = provider.getCompletedAssignments(assignments);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (upcoming.isNotEmpty) ...[
          _buildSection('Upcoming Assignments', upcoming, Colors.blue),
          const SizedBox(height: 24),
        ],
        if (overdue.isNotEmpty) ...[
          _buildSection('Overdue Assignments', overdue, Colors.red),
          const SizedBox(height: 24),
        ],
        if (completed.isNotEmpty)
          _buildSection('Completed Assignments', completed, Colors.green),
      ],
    );
  }

  Widget _buildSection(String title, List<Assignment> assignments, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...assignments.map((assignment) => _buildAssignmentCard(assignment)),
      ],
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final formatter = DateFormat('MMM d, y HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          assignment.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (assignment.description != null)
              Text(assignment.description!),
            Text(
              'Due: ${formatter.format(assignment.deadline)}',
              style: TextStyle(
                color: assignment.deadline.isBefore(DateTime.now())
                    ? Colors.red
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: assignment.isSubmitted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to assignment details/submission screen
          // Will be implemented later
        },
      ),
    );
  }
} 