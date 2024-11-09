// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: (json['id'] as num).toInt(),
      firstName: json['ho'] as String,
      lastName: json['ten'] as String,
      email: json['username'] as String,
      token: json['token'] as String,
      status: json['active'] as String,
      role: json['role'] as String,
      classList: json['class_list'] as List<dynamic>,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ho': instance.firstName,
      'ten': instance.lastName,
      'username': instance.email,
      'token': instance.token,
      'active': instance.status,
      'role': instance.role,
      'class_list': instance.classList,
      'avatar': instance.avatar,
    };
