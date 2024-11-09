import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_model.freezed.dart';
part 'class_model.g.dart';

@freezed
class ClassModel with _$ClassModel {
  const factory ClassModel({
    required int id,
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'class_name') required String className,
    String? schedule,
    @JsonKey(name: 'lecturer_id') required int lecturerId,
    @JsonKey(name: 'max_student_amount') required int maxStudentAmount,
    @JsonKey(name: 'attached_code') String? attachedCode,
    @JsonKey(name: 'class_type') required String classType,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    required String status,
  }) = _ClassModel;

  factory ClassModel.fromJson(Map<String, dynamic> json) => 
      _$ClassModelFromJson(json);
} 