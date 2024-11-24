import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_info.freezed.dart';
part 'student_info.g.dart';

@freezed
class StudentInfo with _$StudentInfo {
  const factory StudentInfo({
    required String id,
    required String name,
    @Default(true) bool isPresent,
  }) = _StudentInfo;

  factory StudentInfo.fromJson(Map<String, dynamic> json) =>
      _$StudentInfoFromJson(json);
} 