import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_submission.freezed.dart';
part 'assignment_submission.g.dart';

@freezed
class AssignmentSubmission with _$AssignmentSubmission {
  const factory AssignmentSubmission({
    required int id,
    @JsonKey(name: 'assignment_id') required int assignmentId,
    @JsonKey(name: 'submission_time') required DateTime submissionTime,
    double? grade,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'text_response') String? textResponse,
    @JsonKey(name: 'student_account') required StudentAccount studentAccount,
  }) = _AssignmentSubmission;

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) =>
      _$AssignmentSubmissionFromJson(json);
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