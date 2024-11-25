import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:developer' as developer;

part 'survey.freezed.dart';
part 'survey.g.dart';

@freezed
@JsonSerializable()
class Survey with _$Survey {
  const factory Survey({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'file_url') String? file,
    @JsonKey(includeFromJson: false) @Default(false) bool isSubmitted,
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
    final classId = json['class_id'] is int ? 
        json['class_id'].toString() : json['class_id'];
    
    final survey = _$SurveyFromJson({
      'id': id,
      'title': json['title'],
      'description': json['description'],
      'file_url': json['file_url'],
      'deadline': json['deadline'],
      'class_id': classId,
    });

    developer.log(
      'Created Survey object: ${survey.toString()}',
      name: 'Survey.fromJson',
    );

    return survey;
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