import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_detail_model.freezed.dart';
part 'class_detail_model.g.dart';

int _parseStudentCount(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.parse(value);
  return 0; // or throw an exception if you prefer
}

@freezed
class ClassDetailModel with _$ClassDetailModel {
  const factory ClassDetailModel({
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'class_name') required String className,
    @JsonKey(name: 'class_type') required String classType,
    @JsonKey(name: 'attached_code') String? attachedCode,
    @JsonKey(name: 'lecturer_name') String? lecturerName,
    @JsonKey(
      name: 'student_count',
      fromJson: _parseStudentCount,
    ) 
    required int studentCount,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    required String status,
    @JsonKey(name: 'student_accounts') required List<StudentAccount> studentAccounts,
  }) = _ClassDetailModel;

  factory ClassDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ClassDetailModelFromJson(json);
}

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