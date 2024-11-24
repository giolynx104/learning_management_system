import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_model.freezed.dart';
part 'class_model.g.dart';

@freezed
class ClassModel with _$ClassModel {
  const factory ClassModel({
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'class_name') required String className,
    @JsonKey(name: 'class_type') required String classType,
    @JsonKey(name: 'attached_code') String? attachedCode,
    @JsonKey(name: 'lecturer_name') String? lecturerName,
    @JsonKey(name: 'student_count') @Default(0) int studentCount,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    required String status,
    @JsonKey(name: 'max_student_amount') int? maxStudentAmount,
    String? description,
    String? schedule,
    @JsonKey(name: 'student_list') @Default([]) List<dynamic> studentList,
    @JsonKey(name: 'assignment_list') @Default([]) List<dynamic> assignmentList,
    @JsonKey(name: 'attendance_list') @Default([]) List<dynamic> attendanceList,
  }) = _ClassModel;

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);
}
