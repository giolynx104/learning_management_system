import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/widgets/survey_tab_bar.dart';
import 'package:learning_management_system/widgets/survey_card.dart';
import 'package:learning_management_system/providers/survey_provider.dart';

class StudentSurveyListScreen extends HookConsumerWidget {
  final String classId;
  
  const StudentSurveyListScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysAsync = ref.watch(surveyListProvider(classId));
    final surveysNotifier = ref.read(surveyListProvider(classId).notifier);
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assignment List'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: const SurveyTabBar(
            tabLabels: ['Upcoming', 'Overdue', 'Completed'],
          ),
        ),
        body: surveysAsync.when(
          data: (surveys) => TabBarView(
            children: [
              SurveyTabContent(
                title: 'Upcoming',
                surveys: surveysNotifier.getUpcomingSurveys(surveys),
                surveysNotifier: surveysNotifier,
              ),
              SurveyTabContent(
                title: 'Overdue',
                surveys: surveysNotifier.getOverdueSurveys(surveys),
                surveysNotifier: surveysNotifier,
              ),
              SurveyTabContent(
                title: 'Completed',
                surveys: surveysNotifier.getCompletedSurveys(surveys),
                surveysNotifier: surveysNotifier,
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
      ),
    );
  }
}

class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<Survey> surveys;
  final SurveyList surveysNotifier;

  const SurveyTabContent({
    super.key,
    required this.title,
    required this.surveys,
    required this.surveysNotifier,
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
          onTap: () async {
            final result = await context.pushNamed(
              Routes.submitSurveyName,
              extra: survey,
            );

            if (result == true) {
              surveysNotifier.refresh();
            }
          },
        );
      },
    );
  }
}
