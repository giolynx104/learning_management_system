import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_list_model.freezed.dart';
part 'attendance_list_model.g.dart';

@freezed
class AttendanceListResponse with _$AttendanceListResponse {
  const factory AttendanceListResponse({
    @JsonKey(name: 'attendance_student_details')
    required List<AttendanceDetail> attendanceDetails,
  }) = _AttendanceListResponse;

  factory AttendanceListResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceListResponseFromJson(json);
}

@freezed
class AttendanceDetail with _$AttendanceDetail {
  const factory AttendanceDetail({
    @JsonKey(name: 'attendance_id') required String attendanceId,
    @JsonKey(name: 'student_id') required String studentId,
    required String status,
  }) = _AttendanceDetail;

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDetailFromJson(json);
} 