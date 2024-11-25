import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/models/assignment.dart';

part 'assignment_provider.g.dart';

@riverpod
class AssignmentList extends _$AssignmentList {
  AssignmentService get _assignmentService => ref.read(assignmentServiceProvider.notifier);
  
  @override
  FutureOr<List<Assignment>> build() async {
    final authState = await ref.read(authProvider.future);
    if (authState == null) throw Exception('Not authenticated');
    
    return _assignmentService.getStudentAssignments(
      token: authState.token!,
    );
  }

  List<Assignment> getUpcomingAssignments(List<Assignment> assignments) {
    final now = DateTime.now();
    return assignments
        .where((a) => a.deadline.isAfter(now) && !a.isSubmitted)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<Assignment> getOverdueAssignments(List<Assignment> assignments) {
    final now = DateTime.now();
    return assignments
        .where((a) => a.deadline.isBefore(now) && !a.isSubmitted)
        .toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));
  }

  List<Assignment> getCompletedAssignments(List<Assignment> assignments) {
    return assignments
        .where((a) => a.isSubmitted)
        .toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
} 