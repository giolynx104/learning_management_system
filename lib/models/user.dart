import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    @JsonKey(defaultValue: '0') required String id,
    @JsonKey(name: 'ho', defaultValue: '') required String firstName,
    @JsonKey(name: 'ten', defaultValue: '') required String lastName,
    @JsonKey(name: 'email', defaultValue: '') required String email,
    @JsonKey(name: 'token', defaultValue: '') required String token,
    @JsonKey(name: 'status', defaultValue: 'Active') required String status,
    @JsonKey(defaultValue: 'STUDENT') required String role,
    @JsonKey(name: 'class_list', defaultValue: []) required List<dynamic> classList,
    String? avatar,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
