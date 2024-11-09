import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    @JsonKey(name: 'ho') required String firstName,
    @JsonKey(name: 'ten') required String lastName,
    @JsonKey(name: 'username') required String email,
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'active') required String status,
    required String role,
    @JsonKey(name: 'class_list') required List<dynamic> classList,
    String? avatar,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
