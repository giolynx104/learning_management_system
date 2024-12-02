import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;

part 'assignment.freezed.dart';
part 'assignment.g.dart';

@freezed
@JsonSerializable()
class Assignment with _$Assignment {
  const Assignment._();

  const factory Assignment({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'lecturer_id') required String lecturerId,
    required DateTime deadline,
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'submission') Map<String, dynamic>? submission,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) {
    developer.log(
      'Parsing Assignment JSON: $json',
      name: 'Assignment.fromJson',
    );
    
    // Convert id to String if it's an int
    final id = json['id'] is int ? json['id'].toString() : json['id'];
    final lecturerId = json['lecturer_id'] is int ? json['lecturer_id'].toString() : json['lecturer_id'];
    final classId = json['class_id'] is int ? json['class_id'].toString() : json['class_id'];
    
    return _$AssignmentFromJson({
      ...json,
      'id': id,
      'lecturer_id': lecturerId,
      'class_id': classId,
    });
  }

  // Add a getter for submission status
  bool get isSubmitted => submission != null;
}

@riverpod
class AssignmentState extends _$AssignmentState {
  @override
  FutureOr<Assignment?> build() => null;

  Future<void> setAssignment(Assignment assignment) async {
    state = AsyncValue.data(assignment);
  }

  Future<void> clearAssignment() async {
    state = const AsyncValue.data(null);
  }
} 