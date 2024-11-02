import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

DateTime _dateFromJson(String date) => DateTime.parse(date);
String _dateToJson(DateTime date) => date.toIso8601String().split('T')[0];

@freezed
class User with _$User {
  const factory User({
    required int id,
    String? ho,
    String? ten,
    required String username,
    required String token,
    @JsonKey(name: 'active') required String active,
    required String role,
    String? avatar,
    @JsonKey(name: 'class_list', defaultValue: [])
    required List<ClassListItem> classList,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class ClassListItem with _$ClassListItem {
  const factory ClassListItem({
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'class_name') required String className,
    @JsonKey(name: 'lecturer_name') required String lecturerName,
    @JsonKey(name: 'student_count') required int studentCount,
    @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime startDate,
    @JsonKey(name: 'end_date', fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime endDate,
    required String status,
  }) = _ClassListItem;

  factory ClassListItem.fromJson(Map<String, dynamic> json) =>
      _$ClassListItemFromJson(json);
}
