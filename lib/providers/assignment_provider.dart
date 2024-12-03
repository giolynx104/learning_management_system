import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/models/assignment.dart';

part 'assignment_provider.g.dart';

@riverpod
Future<List<Assignment>> assignmentList(
  Ref ref,
  String classId,
) async {
  final authState = ref.read(authProvider);
  final user = authState.value;

  if (user == null || user.token == null) {
    throw Exception('Not authenticated');
  }

  return ref.read(assignmentServiceProvider.notifier).getAllAssignments(
        token: user.token!,
        classId: classId,
      );
}

// Add extension methods for Assignment list
extension AssignmentListExtension on List<Assignment> {
  List<Assignment> getUpcomingAssignments() {
    final now = DateTime.now();
    return where((a) => a.deadline.isAfter(now) && !a.isSubmitted).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // For lecturer view - active assignments (not yet expired)
  List<Assignment> getActiveAssignments() {
    final now = DateTime.now();
    return where((a) => a.deadline.isAfter(now)).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // For lecturer view - expired assignments
  List<Assignment> getExpiredAssignments() {
    final now = DateTime.now();
    return where((a) => a.deadline.isBefore(now)).toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));
  }

  // For student view - overdue assignments
  List<Assignment> getOverdueAssignments() {
    final now = DateTime.now();
    return where((a) => a.deadline.isBefore(now) && !a.isSubmitted).toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));
  }

  // For student view - completed assignments
  List<Assignment> getCompletedAssignments() {
    return where((a) => a.isSubmitted).toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));
  }
}

@riverpod
class SubmitAssignment extends _$SubmitAssignment {
  AssignmentService get _assignmentService =>
      ref.read(assignmentServiceProvider.notifier);

  @override
  FutureOr<void> build() => null;

  Future<void> submit({
    required String assignmentId,
    required PlatformFile file,
    required String textResponse,
  }) async {
    final authState = await ref.read(authProvider.future);
    if (authState == null) throw Exception('Not authenticated');

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _assignmentService.submitAssignment(
        token: authState.token!,
        assignmentId: assignmentId,
        file: file,
      );

      // Invalidate the assignment list to force a refresh
      ref.invalidate(assignmentListProvider);
    });
  }
}
