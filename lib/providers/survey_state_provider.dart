import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/survey.dart';

part 'survey_state_provider.g.dart';

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