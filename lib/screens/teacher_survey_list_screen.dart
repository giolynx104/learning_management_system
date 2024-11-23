import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:learning_management_system/widgets/survey_tab_bar.dart';

class TeacherSurveyListScreen extends HookConsumerWidget {
  final String classId;

  const TeacherSurveyListScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('TeacherSurveyListScreen - ClassId: $classId');

    final List<TeacherSurvey> surveys = [
      TeacherSurvey(
        name: 'Survey 1',
        description: 'Description for Survey 1',
        file: 'path/to/survey1.docx',
        responseCount: 10,
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        className: 'Math 101',
      ),
      TeacherSurvey(
        name: 'Survey 2',
        description: 'Description for Survey 2',
        file: 'path/to/survey2.docx',
        responseCount: 5,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1)),
        className: 'Science 101',
      ),
    ];

    List<TeacherSurvey> getUpcomingSurveys() {
      return surveys
          .where((survey) => survey.endTime.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.endTime.compareTo(b.endTime));
    }

    List<TeacherSurvey> getOverdueSurveys() {
      return surveys
          .where((survey) => survey.endTime.isBefore(DateTime.now()))
          .toList()
        ..sort((a, b) => a.endTime.compareTo(b.endTime));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Assignments'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const SurveyTabBar(
            tabLabels: ['Active', 'Expired'],
          ),
        ),
        body: TabBarView(
          children: [
            SurveyTabContent(
              title: 'Active',
              surveys: getUpcomingSurveys(),
            ),
            SurveyTabContent(
              title: 'Expired',
              surveys: getOverdueSurveys(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(Routes.nestedCreateSurvey),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SurveyTabContent extends StatelessWidget {
  final String title;
  final List<TeacherSurvey> surveys;

  const SurveyTabContent({
    super.key,
    required this.title,
    required this.surveys,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: surveys.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final startTimeFormatted =
            DateFormat('HH:mm dd-MM-yyyy').format(survey.startTime);
        final endTimeFormatted =
            DateFormat('HH:mm dd-MM-yyyy').format(survey.endTime);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            survey.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'From: $startTimeFormatted',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'To: $endTimeFormatted',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'responses',
                          child: Row(
                            children: [
                              Icon(Icons.assessment),
                              SizedBox(width: 8),
                              Text('View Responses'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            context.push(
                              Routes.nestedEditSurvey,
                              extra: TeacherSmallSurvey(
                                name: survey.name,
                                description: survey.description,
                                file: survey.file,
                                startTime: survey.startTime,
                                endTime: survey.endTime,
                              ),
                            );
                            break;
                          case 'delete':
                            // TODO: Implement delete
                            break;
                          case 'responses':
                            // TODO: Implement view responses
                            break;
                        }
                      },
                    ),
                  ],
                ),
                if (survey.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    survey.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Responses: ${survey.responseCount}',
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
        );
      },
    );
  }
}

class TeacherSurvey {
  final String name;
  final String? description;
  final String? file;
  final int responseCount;
  final DateTime startTime;
  final DateTime endTime;
  final String className;

  TeacherSurvey({
    required this.name,
    this.description,
    this.file,
    required this.responseCount,
    required this.startTime,
    required this.endTime,
    required this.className,
  });
}
