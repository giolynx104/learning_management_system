import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/services/survey_service.dart';
import 'package:learning_management_system/widgets/survey_tab_bar.dart';
import 'package:learning_management_system/widgets/survey_card.dart';
import 'package:learning_management_system/providers/survey_provider.dart';
import 'dart:developer' as developer;

class TeacherSurveyListScreen extends HookConsumerWidget {
  final String classId;
  
  const TeacherSurveyListScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysAsync = ref.watch(surveyListProvider(classId));
    final surveysNotifier = ref.read(surveyListProvider(classId).notifier);

    Future<void> deleteSurvey(String surveyId) async {
      try {
        final authState = await ref.read(authProvider.future);
        if (authState == null) throw Exception('Not authenticated');

        await ref.read(surveyServiceProvider.notifier).deleteSurvey(
          token: authState.token!,
          surveyId: surveyId,
        );

        // Refresh survey list after deletion
        surveysNotifier.refresh();
      } catch (e, stack) {
        developer.log(
          'Error deleting survey: $e',
          name: 'TeacherSurveyList',
          error: e,
          stackTrace: stack,
        );
        // Show error to user
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting survey: $e')),
          );
        }
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Assignment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: const SurveyTabBar(
            tabLabels: ['Active', 'Expired'],
          ),
        ),
        body: surveysAsync.when(
          data: (surveys) => TabBarView(
            children: [
              SurveyTabContent(
                title: 'Active',
                surveys: surveysNotifier.getUpcomingSurveys(surveys),
                onDelete: deleteSurvey,
                onRefresh: () => surveysNotifier.refresh(),
                onTap: (survey) => _handleSurveyTap(context, survey),
              ),
              SurveyTabContent(
                title: 'Expired',
                surveys: surveysNotifier.getOverdueSurveys(surveys),
                onDelete: deleteSurvey,
                onRefresh: () => surveysNotifier.refresh(),
                onTap: (survey) => _handleSurveyTap(context, survey),
              ),
            ],
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: SelectableText.rich(
              TextSpan(
                text: 'Error loading surveys: ',
                children: [
                  TextSpan(
                    text: error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _handleCreateSurvey(context, surveysNotifier),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _handleSurveyTap(BuildContext context, Survey survey) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Assignment'),
            onTap: () {
              context.pop();
              context.pushNamed(
                Routes.editSurveyName,
                pathParameters: {'surveyId': survey.id},
                extra: survey,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('View Responses'),
            onTap: () {
              context.pop();
              context.pushNamed(
                Routes.responseSurveyName,
                pathParameters: {'surveyId': survey.id},
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateSurvey(
    BuildContext context,
    SurveyList surveysNotifier,
  ) async {
    final result = await context.pushNamed(
      Routes.createSurveyName,
      pathParameters: {'classId': classId},
    );

    if (result == true) {
      surveysNotifier.refresh();
    }
  }
}

// Update SurveyTabContent to include onTap handler
class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<Survey> surveys;
  final Function(String)? onDelete;
  final VoidCallback? onRefresh;
  final Function(Survey) onTap;

  const SurveyTabContent({
    super.key,
    required this.title,
    required this.surveys,
    this.onDelete,
    this.onRefresh,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: surveys.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final endTimeFormatted = 
            DateFormat('HH:mm dd-MM-yyyy').format(survey.deadline);

        return SurveyCard(
          endTimeFormatted: endTimeFormatted,
          name: survey.title,
          description: survey.description,
          onDelete: onDelete != null ? () => onDelete!(survey.id) : null,
          onEdit: () {
            context.pushNamed(
              Routes.editSurveyName,
              pathParameters: {'surveyId': survey.id},
              extra: survey,
            );
          },
          onViewResponse: () {
            context.pushNamed(
              Routes.responseSurveyName,
              pathParameters: {'surveyId': survey.id},
            );
          },
        );
      },
    );
  }
}
