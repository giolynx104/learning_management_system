import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    @JsonKey(name: 'ho') required String firstName,
    @JsonKey(name: 'ten') required String lastName,
    required String name,
    required String email,
    required String role,
    @JsonKey(name: 'status') required String status,
    String? avatar,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
