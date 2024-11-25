import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as developer;
import 'package:learning_management_system/services/survey_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/models/survey.dart';

part 'survey_provider.g.dart';

@riverpod
class SurveyList extends _$SurveyList {
  SurveyService get _surveyService => ref.read(surveyServiceProvider.notifier);
  
  @override
  FutureOr<List<Survey>> build(String classId) async {
    final authState = await ref.read(authProvider.future);
    if (authState == null) throw Exception('Not authenticated');
    
    final surveys = await _surveyService.getAllSurveys(
      token: authState.token!,
      classId: classId,
    );
    
    await _updateSubmissionStatuses(surveys, authState.token!);
    return surveys;
  }

  Future<void> _updateSubmissionStatuses(List<Survey> surveys, String token) async {
    await Future.wait(
      surveys.map((survey) => _updateSubmissionStatus(survey, token)),
    );
  }

  Future<void> _updateSubmissionStatus(Survey survey, String token) async {
    try {
      final isSubmitted = await _surveyService.checkSubmissionStatus(
        token: token,
        assignmentId: survey.id,
      );
      state = AsyncValue.data(state.value!.map((s) =>
        s.id == survey.id ? survey.copyWith(isSubmitted: isSubmitted) : s
      ).toList());
    } catch (e, stack) {
      developer.log(
        'Error checking submission status: $e',
        name: 'SurveyListProvider',
        error: e,
        stackTrace: stack,
      );
    }
  }

  List<Survey> getUpcomingSurveys(List<Survey> surveys) {
    final now = DateTime.now();
    return surveys
        .where((s) => s.deadline.isAfter(now) && !s.isSubmitted)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<Survey> getOverdueSurveys(List<Survey> surveys) {
    final now = DateTime.now();
    return surveys
        .where((s) => s.deadline.isBefore(now) && !s.isSubmitted)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<Survey> getCompletedSurveys(List<Survey> surveys) {
    return surveys
        .where((s) => s.isSubmitted)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class SubmitSurvey extends _$SubmitSurvey {
  SurveyService get _surveyService => ref.read(surveyServiceProvider.notifier);

  @override
  FutureOr<void> build() {}

  Future<void> submit({
    required String assignmentId,
    required PlatformFile file,
    required String textResponse,
  }) async {
    final authState = await ref.read(authProvider.future);
    if (authState == null) throw Exception('Not authenticated');

    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      await _surveyService.submitSurvey(
        token: authState.token!,
        assignmentId: assignmentId,
        file: file,
        textResponse: textResponse,
      );
    });

    if (!state.hasError) {
      // Refresh survey list after successful submission
      ref.invalidate(surveyListProvider);
    }
  }
}

@riverpod
class CreateSurvey extends _$CreateSurvey {
  SurveyService get _surveyService => ref.read(surveyServiceProvider.notifier);

  @override
  FutureOr<void> build() {}

  Future<void> create({
    required String classId,
    required String title,
    required String deadline,
    required String description,
    required PlatformFile file,
  }) async {
    final authState = await ref.read(authProvider.future);
    if (authState == null) throw Exception('Not authenticated');

    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      await _surveyService.createSurvey(
        token: authState.token!,
        classId: classId,
        title: title,
        deadline: deadline,
        description: description,
        file: file,
      );
    });
  }
} 