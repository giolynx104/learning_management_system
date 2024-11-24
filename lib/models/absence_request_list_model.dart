import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'absence_request_list_model.freezed.dart';
part 'absence_request_list_model.g.dart';

@freezed
class AbsenceRequestListResponse with _$AbsenceRequestListResponse {
  const factory AbsenceRequestListResponse({
    required AbsenceRequestList data,
    required ResponseMeta meta,
  }) = _AbsenceRequestListResponse;

  factory AbsenceRequestListResponse.fromJson(Map<String, dynamic> json) => 
      _$AbsenceRequestListResponseFromJson(json);
}

@freezed
class AbsenceRequestList with _$AbsenceRequestList {
  const factory AbsenceRequestList({
    @JsonKey(name: 'page_content') required List<AbsenceRequestDetail> pageContent,
  }) = _AbsenceRequestList;

  factory AbsenceRequestList.fromJson(Map<String, dynamic> json) => 
      _$AbsenceRequestListFromJson(json);
}

@freezed
class StudentAccount with _$StudentAccount {
  const factory StudentAccount({
    @JsonKey(
      name: 'account_id',
      fromJson: _parseId,
    ) required int accountId,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'first_name') required String firstName,
    required String email,
    @JsonKey(
      name: 'student_id',
      fromJson: _parseId,
    ) required int studentId,
  }) = _StudentAccount;

  factory StudentAccount.fromJson(Map<String, dynamic> json) => 
      _$StudentAccountFromJson(json);
}

@freezed
class AbsenceRequestDetail with _$AbsenceRequestDetail {
  const factory AbsenceRequestDetail({
    @JsonKey(fromJson: _parseId) required int id,
    @JsonKey(name: 'student_account') required StudentAccount studentAccount,
    @JsonKey(name: 'absence_date') required String absenceDate,
    required String title,
    required String reason,
    @JsonKey(fromJson: _parseStatus) required AbsenceRequestStatus status,
    @JsonKey(name: 'response_message') String? responseMessage,
    @JsonKey(name: 'response_date') String? responseDate,
    @JsonKey(name: 'response_by') String? responseBy,
  }) = _AbsenceRequestDetail;

  factory AbsenceRequestDetail.fromJson(Map<String, dynamic> json) => 
      _$AbsenceRequestDetailFromJson(json);
}

@freezed
class ResponseMeta with _$ResponseMeta {
  const factory ResponseMeta({
    @JsonKey(fromJson: _parseCode) required String code,
    required String message,
  }) = _ResponseMeta;

  factory ResponseMeta.fromJson(Map<String, dynamic> json) => 
      _$ResponseMetaFromJson(json);
}

enum AbsenceRequestStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('ACCEPTED') accepted,
  @JsonValue('REJECTED') rejected,
}

// Helper functions for parsing
int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.parse(value);
  throw Exception('Invalid ID format: $value');
}

String _parseCode(dynamic value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  throw Exception('Invalid code format: $value');
}

AbsenceRequestStatus _parseStatus(String value) {
  switch (value.toUpperCase()) {
    case 'PENDING':
      return AbsenceRequestStatus.pending;
    case 'ACCEPTED':
      return AbsenceRequestStatus.accepted;
    case 'REJECTED':
      return AbsenceRequestStatus.rejected;
    default:
      throw Exception('Invalid status: $value');
  }
} 