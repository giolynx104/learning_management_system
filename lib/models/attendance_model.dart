import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
class AttendanceRequest with _$AttendanceRequest {
  const factory AttendanceRequest({
    @JsonKey(name: 'token') required String token,
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'date') required String date,
    @JsonKey(name: 'attendance_list') required List<int> attendanceList,
  }) = _AttendanceRequest;

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) => 
      _$AttendanceRequestFromJson(json);
} 