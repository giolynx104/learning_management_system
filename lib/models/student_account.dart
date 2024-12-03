import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_account.freezed.dart';
part 'student_account.g.dart';

@freezed
class StudentAccount with _$StudentAccount {
  const factory StudentAccount({
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'first_name') required String firstName,
    required String email,
    @JsonKey(name: 'student_id') required String studentId,
  }) = _StudentAccount;

  factory StudentAccount.fromJson(Map<String, dynamic> json) =>
      _$StudentAccountFromJson(json);
} 