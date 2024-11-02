// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassModelImpl _$$ClassModelImplFromJson(Map<String, dynamic> json) =>
    _$ClassModelImpl(
      id: (json['id'] as num).toInt(),
      classId: json['classId'] as String,
      className: json['className'] as String,
      schedule: json['schedule'] as String?,
      lecturerId: (json['lecturerId'] as num).toInt(),
      maxStudentAmount: (json['maxStudentAmount'] as num).toInt(),
      attachedCode: json['attachedCode'] as String?,
      classType: json['classType'] as String,
      startDate: _dateFromJson(json['startDate'] as String),
      endDate: _dateFromJson(json['endDate'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ClassModelImplToJson(_$ClassModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'className': instance.className,
      'schedule': instance.schedule,
      'lecturerId': instance.lecturerId,
      'maxStudentAmount': instance.maxStudentAmount,
      'attachedCode': instance.attachedCode,
      'classType': instance.classType,
      'startDate': _dateToJson(instance.startDate),
      'endDate': _dateToJson(instance.endDate),
      'status': instance.status,
    };
