import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_list_model.freezed.dart';
part 'class_list_model.g.dart';

@freezed
class ClassListItem with _$ClassListItem {
  const factory ClassListItem({
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'class_name') required String className,
    @JsonKey(name: 'attached_code') String? attachedCode,
    @JsonKey(name: 'class_type') required String classType,
    @JsonKey(name: 'lecturer_name') required String lecturerName,
    @JsonKey(name: 'student_count') required int studentCount,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    required String status,
  }) = _ClassListItem;

  factory ClassListItem.fromJson(Map<String, dynamic> json) => 
      _$ClassListItemFromJson(json);
} 