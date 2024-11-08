// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassModelImpl _$$ClassModelImplFromJson(Map<String, dynamic> json) =>
    _$ClassModelImpl(
      id: (json['id'] as num).toInt(),
      classId: json['class_id'] as String,
      className: json['class_name'] as String,
      schedule: json['schedule'] as String?,
      lecturerId: (json['lecturer_id'] as num).toInt(),
      maxStudentAmount: (json['max_student_amount'] as num).toInt(),
      attachedCode: json['attached_code'] as String?,
      classType: json['class_type'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ClassModelImplToJson(_$ClassModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_id': instance.classId,
      'class_name': instance.className,
      'schedule': instance.schedule,
      'lecturer_id': instance.lecturerId,
      'max_student_amount': instance.maxStudentAmount,
      'attached_code': instance.attachedCode,
      'class_type': instance.classType,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'status': instance.status,
    };
