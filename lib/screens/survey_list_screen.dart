import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/screens/submit_survey_screen.dart';

class SurveyListScreen extends ConsumerStatefulWidget {
  const SurveyListScreen({super.key});

  @override
  ConsumerState<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends ConsumerState<SurveyListScreen> {
  final List<Survey> surveys = [
    Survey(
      name: 'Survey 1',
      description: 'This is a description for Survey 1',
      file: 'path/to/survey1.docx',
      answerDescription: null,
      answerFile: null,
      endTime: DateTime.now().add(const Duration(hours: 1)),
      turnInTime: null,
      className: 'Math 101',
    ),
    Survey(
      name: 'Survey 2',
      description: 'This is a description for Survey 2',
      file: 'path/to/survey2.docx',
      answerDescription: null,
      answerFile: null,
      endTime: DateTime.now().subtract(const Duration(hours: 1)),
      turnInTime: null,
      className: 'Science 101',
    ),
    Survey(
      name: 'Survey 3',
      description: null,
      file: null,
      answerDescription: 'Answer description for Survey 3',
      answerFile: 'path/to/answer3.docx',
      endTime: DateTime.now().add(const Duration(hours: 2)),
      turnInTime: DateTime.now().subtract(const Duration(minutes: 30)),
      className: 'History 101',
    ),
  ];

  List<Survey> getUpcomingSurveys() {
    return surveys
        .where((survey) => 
            survey.endTime.isAfter(DateTime.now()) && 
            survey.turnInTime == null)
        .toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  List<Survey> getOverdueSurveys() {
    return surveys
        .where((survey) => 
            survey.endTime.isBefore(DateTime.now()) && 
            survey.turnInTime == null)
        .toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
  }

  List<Survey> getCompletedSurveys() {
    return surveys
        .where((survey) => survey.turnInTime != null)
        .toList()
      ..sort((a, b) => a.turnInTime!.compareTo(b.turnInTime!));
  }

  void _navigateToSubmitSurvey(Survey survey) {
    context.push(
      Routes.nestedSubmitSurvey,
      extra: SmallSurvey(
        name: survey.name,
        description: survey.description,
        file: survey.file,
        answerDescription: survey.answerDescription,
        answerFile: survey.answerFile,
        endTime: survey.endTime,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appBarNotifierProvider.notifier).setAppBar(
        title: 'Surveys',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    ref.read(appBarNotifierProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SURVEY LIST',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Times New Roman',
                ),
              ),
              Image.asset(
                'assets/images/HUST_white.png',
                height: 30,
                fit: BoxFit.contain,
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Overdue'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SurveyTabContent(
              title: 'Upcoming',
              surveys: getUpcomingSurveys(),
              onSurveyTap: _navigateToSubmitSurvey,
            ),
            SurveyTabContent(
              title: 'Overdue',
              surveys: getOverdueSurveys(),
              onSurveyTap: _navigateToSubmitSurvey,
            ),
            SurveyTabContent(
              title: 'Completed',
              surveys: getCompletedSurveys(),
              onSurveyTap: _navigateToSubmitSurvey,
            ),
          ],
        ),
      ),
    );
  }
}

class Survey {
  final String name;
  final String? description;
  final String? file;
  final String? answerDescription;
  final String? answerFile;
  final DateTime endTime;
  final DateTime? turnInTime;
  final String className;

  const Survey({
    required this.name,
    this.description,
    this.file,
    this.answerDescription,
    this.answerFile,
    required this.endTime,
    required this.turnInTime,
    required this.className,
  });
}

class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<Survey> surveys;
  final Function(Survey) onSurveyTap;

  const SurveyTabContent({
    super.key,
    required this.title,
    required this.surveys,
    required this.onSurveyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView.builder(
      itemCount: surveys.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final endTimeFormatted = DateFormat('HH:mm dd-MM-yyyy').format(survey.endTime);
        final turnInTimeFormatted = survey.turnInTime != null
            ? DateFormat('HH:mm dd-MM-yyyy').format(survey.turnInTime!)
            : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onSurveyTap(survey),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    endTimeFormatted,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    survey.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (survey.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      survey.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (survey.turnInTime != null)
                    Text(
                      'Submitted at: $turnInTimeFormatted',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Text(
                    'Class: ${survey.className}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
