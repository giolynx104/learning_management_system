import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    @JsonKey(name: 'ho') required String firstName,
    @JsonKey(name: 'ten') required String lastName,
    @JsonKey(name: 'email') required String email,
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'status') required String status,
    required String role,
    @JsonKey(name: 'class_list') required List<dynamic> classList,
    String? avatar,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('User.fromJson input: $json');
    
    return User(
      id: json['id'] ?? 0,
      firstName: json['ho'] ?? '',
      lastName: json['ten'] ?? '',
      email: json['email'] ?? json['username'] ?? '',
      token: json['token'] ?? '',
      status: json['status'] ?? 'Active',
      role: json['role'] ?? 'STUDENT',
      classList: json['class_list'] ?? [],
      avatar: json['avatar'],
    );
  }
}
