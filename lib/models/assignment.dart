import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;

part 'assignment.freezed.dart';
part 'assignment.g.dart';

@freezed
class Assignment with _$Assignment {
  const factory Assignment({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'lecturer_id') required String lecturerId,
    required DateTime deadline,
    @JsonKey(name: 'class_id') required String classId,
    @Default(false) @JsonKey(name: 'is_submitted') bool isSubmitted,
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
    
    return Assignment(
      id: id as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String?,
      lecturerId: lecturerId as String,
      deadline: DateTime.parse(json['deadline'] as String),
      classId: classId as String,
      isSubmitted: json['is_submitted'] as bool? ?? false,
    );
  }
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