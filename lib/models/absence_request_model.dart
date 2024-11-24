import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'absence_request_model.freezed.dart';
part 'absence_request_model.g.dart';

@freezed
class AbsenceRequest with _$AbsenceRequest {
  const factory AbsenceRequest({
    required String classId,
    required String title,
    required String reason,
    required String date,
    String? proofFile,  // Made optional
  }) = _AbsenceRequest;

  factory AbsenceRequest.fromJson(Map<String, dynamic> json) => 
      _$AbsenceRequestFromJson(json);
}

@freezed
class AbsenceRequestResponse with _$AbsenceRequestResponse {
  const factory AbsenceRequestResponse({
    @JsonKey(name: 'request_id') required String requestId,
    required String status,
    String? message,
  }) = _AbsenceRequestResponse;

  factory AbsenceRequestResponse.fromJson(Map<String, dynamic> json) => 
      _$AbsenceRequestResponseFromJson(json);
} 