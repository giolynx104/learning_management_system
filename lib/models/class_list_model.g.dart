// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassListItemImpl _$$ClassListItemImplFromJson(Map<String, dynamic> json) =>
    _$ClassListItemImpl(
      classId: json['class_id'] as String,
      className: json['class_name'] as String,
      attachedCode: json['attached_code'] as String?,
      classType: json['class_type'] as String,
      lecturerName: json['lecturer_name'] as String,
      studentCount: (json['student_count'] as num).toInt(),
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ClassListItemImplToJson(_$ClassListItemImpl instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
      'class_name': instance.className,
      'attached_code': instance.attachedCode,
      'class_type': instance.classType,
      'lecturer_name': instance.lecturerName,
      'student_count': instance.studentCount,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'status': instance.status,
    };
