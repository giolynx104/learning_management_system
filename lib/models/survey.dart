import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;

part 'survey.freezed.dart';
part 'survey.g.dart';

@freezed
class Survey with _$Survey {
  const factory Survey({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'file_url') String? file,
    @Default(false) bool isSubmitted,
    required DateTime deadline,
    @JsonKey(name: 'class_id') required String classId,
  }) = _Survey;

  factory Survey.fromJson(Map<String, dynamic> json) {
    developer.log(
      'Parsing Survey JSON: $json',
      name: 'Survey.fromJson',
    );
    
    // Convert id to String if it's an int
    final id = json['id'] is int ? json['id'].toString() : json['id'];
    // Convert class_id to String if it's an int
    final classId = json['class_id'] is int ? json['class_id'].toString() : json['class_id'];
    
    return Survey(
      id: id as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      file: json['file_url'] as String?,
      isSubmitted: false,
      deadline: DateTime.parse(json['deadline'] as String),
      classId: classId as String,
    );
  }
}

@riverpod
class SurveyState extends _$SurveyState {
  @override
  FutureOr<Survey?> build() => null;

  Future<void> setSurvey(Survey survey) async {
    state = AsyncValue.data(survey);
  }

  Future<void> clearSurvey() async {
    state = const AsyncValue.data(null);
  }
}