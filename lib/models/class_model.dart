import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_model.freezed.dart';
part 'class_model.g.dart';

@freezed
class ClassModel with _$ClassModel {
  const factory ClassModel({
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'class_name') required String className,
    @JsonKey(name: 'attached_code') String? attachedCode,
    @JsonKey(name: 'class_type') required String classType,
    @JsonKey(name: 'lecturer_name') required String lecturerName,
    @JsonKey(name: 'student_count') required int studentCount,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    required String status,
    @JsonKey(name: 'student_accounts') required List<dynamic> studentAccounts,
  }) = _ClassModel;

  factory ClassModel.fromJson(Map<String, dynamic> json) => _$ClassModelFromJson(json);
}
