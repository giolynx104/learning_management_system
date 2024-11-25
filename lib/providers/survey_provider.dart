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
    
    developer.log(
      'Building SurveyList provider for class $classId',
      name: 'SurveyListProvider',
    );
    
    final surveys = await _surveyService.getAllSurveys(
      token: authState.token!,
      classId: classId,
    );
    
    developer.log(
      'Got ${surveys.length} surveys from service',
      name: 'SurveyListProvider',
    );
    
    // Update submission statuses one by one to avoid race conditions
    for (final survey in surveys) {
      final isSubmitted = await _surveyService.checkSubmissionStatus(
        token: authState.token!,
        assignmentId: survey.id,
      );
      
      developer.log(
        'Initial submission status for survey ${survey.id}: $isSubmitted',
        name: 'SurveyListProvider',
      );
      
      if (isSubmitted) {
        final index = surveys.indexWhere((s) => s.id == survey.id);
        if (index != -1) {
          surveys[index] = surveys[index].copyWith(isSubmitted: true);
          developer.log(
            'Updated initial state for survey ${survey.id}: isSubmitted=true',
            name: 'SurveyListProvider',
          );
        }
      }
    }
    
    return surveys;
  }

  List<Survey> getUpcomingSurveys(List<Survey> surveys) {
    final now = DateTime.now();
    developer.log(
      'Filtering upcoming surveys. Total surveys: ${surveys.length}',
      name: 'SurveyListProvider',
    );
    
    // Log all surveys and their submission status
    for (final survey in surveys) {
      developer.log(
        'Survey ${survey.id}: isSubmitted=${survey.isSubmitted}',
        name: 'SurveyListProvider',
      );
    }
    
    final upcomingSurveys = surveys
        .where((s) {
          final isUpcoming = s.deadline.isAfter(now) && !s.isSubmitted;
          developer.log(
            'Survey ${s.id}: deadline: ${s.deadline}, isSubmitted: ${s.isSubmitted}, isUpcoming: $isUpcoming',
            name: 'SurveyListProvider',
          );
          return isUpcoming;
        })
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    
    developer.log(
      'Found ${upcomingSurveys.length} upcoming surveys',
      name: 'SurveyListProvider',
    );
    return upcomingSurveys;
  }

  List<Survey> getOverdueSurveys(List<Survey> surveys) {
    final now = DateTime.now();
    return surveys
        .where((s) => s.deadline.isBefore(now) && !s.isSubmitted)
        .toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));
  }

  List<Survey> getCompletedSurveys(List<Survey> surveys) {
    return surveys
        .where((s) => s.isSubmitted)
        .toList()
      ..sort((a, b) => b.deadline.compareTo(a.deadline));
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
      
      // Invalidate the survey list to force a refresh
      ref.invalidate(surveyListProvider);
      
      // Wait a moment for the submission status to be updated
      await Future.delayed(const Duration(milliseconds: 500));
    });
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