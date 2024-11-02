// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: (json['id'] as num).toInt(),
      ho: json['ho'] as String?,
      ten: json['ten'] as String?,
      username: json['username'] as String,
      token: json['token'] as String,
      active: json['active'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      classList: (json['class_list'] as List<dynamic>?)
              ?.map((e) => ClassListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ho': instance.ho,
      'ten': instance.ten,
      'username': instance.username,
      'token': instance.token,
      'active': instance.active,
      'role': instance.role,
      'avatar': instance.avatar,
      'class_list': instance.classList,
    };

_$ClassListItemImpl _$$ClassListItemImplFromJson(Map<String, dynamic> json) =>
    _$ClassListItemImpl(
      classId: json['class_id'] as String,
      className: json['class_name'] as String,
      lecturerName: json['lecturer_name'] as String,
      studentCount: (json['student_count'] as num).toInt(),
      startDate: _dateFromJson(json['start_date'] as String),
      endDate: _dateFromJson(json['end_date'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ClassListItemImplToJson(_$ClassListItemImpl instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
      'class_name': instance.className,
      'lecturer_name': instance.lecturerName,
      'student_count': instance.studentCount,
      'start_date': _dateToJson(instance.startDate),
      'end_date': _dateToJson(instance.endDate),
      'status': instance.status,
    };
