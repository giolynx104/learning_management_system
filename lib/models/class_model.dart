import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_model.freezed.dart';
part 'class_model.g.dart';

DateTime _dateFromJson(String date) => DateTime.parse(date);
String _dateToJson(DateTime date) => date.toIso8601String();

@freezed
class ClassModel with _$ClassModel {
  const factory ClassModel({
    required int id,
    required String classId,
    required String className,
    String? schedule,
    required int lecturerId,
    required int maxStudentAmount,
    String? attachedCode,
    required String classType,
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) 
    required DateTime startDate,
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime endDate,
    required String status,
  }) = _ClassModel;

  factory ClassModel.fromJson(Map<String, dynamic> json) => 
      _$ClassModelFromJson(json);
} 